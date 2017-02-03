#!/bin/sh
echo "Starting Alignak backend..."
screen -d -S alignak-backend -m sh -c "alignak-backend-uwsgi"
sleep 1
netstat -tulpen | grep 5000
echo "Started"
