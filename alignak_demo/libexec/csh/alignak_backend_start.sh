#!/bin/sh
echo "Starting Alignak backend..."
screen -d -S alignak-backend -m sh -c "uwsgi --ini /usr/local/etc/alignak-backend/uwsgi.ini"
sleep 1
netstat -tulpen | grep 5000
echo "Started"
