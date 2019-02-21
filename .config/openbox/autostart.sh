#!/bin/bash
xrandr -s 1920x1200
xhost +local:docker
if [ "$DISPLAY" == ":0.0" ]
  then
	xcompmgr -d:0.0 -F &
	hsetroot -fill ~/bg.jpg &
	(conky) &
fi

