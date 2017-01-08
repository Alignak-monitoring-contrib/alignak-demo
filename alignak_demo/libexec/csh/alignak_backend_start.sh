#!/bin/sh
echo "Starting Alignak backend..."
screen -d -S alignak-backend -m csh -c "alignak-backend"
sleep 1
echo "Started"
