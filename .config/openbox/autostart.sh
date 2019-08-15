#!/bin/bash
xrandr -s 3440x1440
xhost +local:docker
if [ "$DISPLAY" == ":0.0" ]
  then
	xcompmgr -d:0.0 -F &
	hsetroot -fill ~/bg.jpg &
	(conky) &
	pulseaudio --start
fi

