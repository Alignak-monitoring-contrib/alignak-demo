#!/usr/bin/env bash
echo "Stop Python processes..."
killall screen
sleep 5
killall -KILL /usr/bin/python
