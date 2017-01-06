#!/usr/bin/env bash
echo "Stopping Alignak backend..."
screen -X -S alignak-backend quit
sleep 1
echo "Stopped"
