#!/bin/bash

if [ "$1" == save ]; then
	for i in $(seq 0 10); do
		i3-resurrect save -w "$i";
	done
elif [ "$1" == restore ]; then
	for i in $(seq 0 10); do
		i3-resurrect restore -w "$i";
	done
else
	echo "Usage: save_restore.sh save | restore"
fi
