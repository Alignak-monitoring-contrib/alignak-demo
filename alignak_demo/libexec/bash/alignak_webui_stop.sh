#!/usr/bin/env bash
echo "Stopping Alignak WebUI..."
kill -INT `cat /tmp/alignak-webui.pid`
sleep 1
echo "Stopped"
