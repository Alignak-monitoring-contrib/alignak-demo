#!/bin/sh
echo "Starting Alignak WebUI..."
screen -d -S alignak-webui -m sh -c "alignak-webui"
sleep 1
echo "Started"
