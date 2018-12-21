DISPLAY=:0.0 openbox-session & export O_PID=$!
DISPLAY=:0.1 openbox-session &
wait $O_PID
