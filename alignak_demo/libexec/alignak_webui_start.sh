#!/bin/sh
echo "Starting Alignak WebUI..."
screen -d -S alignak-webui -m sh -c "alignak-webui-uwsgi"
sleep 1
netstat -tulpen | grep 5001
echo "Started"
