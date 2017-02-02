#!/bin/sh
echo "Stopping Alignak backend..."
kill -INT `cat /tmp/alignak-backend.pid`
sleep 1
echo "Stopped"
