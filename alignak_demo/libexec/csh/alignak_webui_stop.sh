#!/bin/sh
echo "Stopping Alignak WebUI..."
screen -X -S alignak-webui quit
sleep 1
echo "Stopped"
