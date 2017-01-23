#!/usr/bin/env bash
echo "Starting Alignak WebUI..."
screen -d -S alignak-webui -m sh -c "uwsgi --ini /usr/local/etc/alignak-webui/uwsgi.ini"
sleep 1
netstat -tulpen | grep 5001
echo "Started"
