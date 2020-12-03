#!/bin/bash

urxvt -e cmatrix -n -u 'ACTG' &

sleep 0.5

i3-msg fullscreen global

i3lock -n; i3-msg kill
