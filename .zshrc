# If you come from bash you might have to change your $PATH.
#
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

export PATH="$PATH:$HOME/.local/bin:/snap/bin:/usr/local/go/bin:/home/lucas/go/bin/:/home/lucas/.cargo/bin/"
export QT_STYLE_OVERRIDE=kvantum
export AWS_PROFILE=sandbox
export AWS_SDK_LOAD_CONFIG=1
# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="agnoster"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  vi-mode
	zsh-z
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias clip="xclip -selection clipboard"
alias gs="git status"
alias gc="git commit "
alias gp="git push"
alias ga="git add"
alias pj="cd ~/projects"
#alias find="fdfind"
alias ls="exa"
alias cat="bat"
#alias grep="rg"
alias v="vim"
alias https-server="sudo http-server -S -C ~/.creds/cert.pem -K ~/.creds/key.pem -p 443"
alias clipdiff="diff <(xclip -o)"
alias gitaz="cp /home/lucas/.gitconfig-azure /home/lucas/.gitconfig"
alias gitaws="cp /home/lucas/.gitconfig-aws /home/lucas/.gitconfig"
alias assume-role='function(){eval $(command assume-role $@);}'
alias awsume=". awsume"
alias szrc="source ~/.zshrc"
alias genpwd="< /dev/urandom tr -dc '_A-Z-a-z-0-9$!#@%^&*(){},./' | head -c${1:-16};echo;"

function eap {
	export AWS_PROFILE="$1";
}

function pnv {
	sam build -t $1 && sam package --s3-bucket aspen-sandbox-cf-resources --s3-prefix $2 --template-file $1 --output-template-file deployment_template.yaml
}

function por {
	 sam build -t $1 && sam package --s3-bucket cf-templates-aspen-us-west-2 --s3-prefix $2 --template-file $1 --output-template-file deployment_template.yaml
}

function fr {
	aws codecommit list-repositories | grep -i "$1";
}

function ccl {
	if [ -z "$2" ];
		then cd ~/projects/SANDBOX && git clone $(aws codecommit get-repository --repository-name "$1" | jq '.repositoryMetadata.cloneUrlHttp' | sed -e 's/^"//' -e 's/"$//');
		else cd ~/projects/"$2" && git clone $(aws codecommit get-repository --repository-name "$1" | jq '.repositoryMetadata.cloneUrlHttp' | sed -e 's/^"//' -e 's/"$//');
	fi
}

function fs {
	aws secretsmanager list-secrets | grep -i "$1" | grep -v "ARN";
}

function rs {
	aws secretsmanager get-secret-value --secret-id "$1" | jq .SecretString -r | jq .
}

function us {
	new_secret=$(aws secretsmanager get-secret-value --secret-id "$1" | jq .SecretString -r | jq ."\"$2\" = \"$3\"");
	echo "$new_secret";
	aws secretsmanager update-secret --secret-id "$1" --secret-string "$new_secret";
}

function pks {
	printf "%s" "$1" | base64 -d -w 0 | js-beautify | less;
}

function ccm {
	curr_dir=$(pwd);
	cd "$1";
	for i in $(ls); do
		echo "$i";
		cd "$i";
		if [ $? -eq 0 ]; then
			git status;
			cd ..;
		fi
	done
	cd "$curr_dir";
}

function cog_log {
	access_token=$(aws cognito-idp initiate-auth --auth-flow USER_PASSWORD_AUTH --auth-parameters USERNAME="$1",PASSWORD="$2" --client-id "$3" | jq -r ".AuthenticationResult.AccessToken");
	echo $access_token;
	echo $access_token|clip;
}

function touch_mkdir {
	filename=$(echo "$1" | rev | cut -d '/' -f 1 | rev);
	path=$(echo "$1" | rev | cut -d '/' -f 2- | rev);
	mkdir -p "$path";
	cd "$path";
	touch "$filename";
}

function syncprojects {
  python3 /home/lucas/projects/SANDBOX/sh-util/clockify-quickbase-integration/sync_projects.py
}

function hours {
  python3 /home/lucas/projects/SANDBOX/sh-util/clockify-quickbase-integration/write_hours.py
}

source ~/.local/lib/python3.8/site-packages/powerline/bindings/zsh/powerline.zsh

#source ~/enhancd/init.sh

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
zstyle ':completion:*' menu select
