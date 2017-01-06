#!/usr/bin/env bash
echo "Starting Alignak WebUI..."
screen -d -S alignak_webui -m bash -c "alignak-webui"
sleep 1
echo "Started"
