#!/bin/sh
echo "Stop Python processes..."
killall python2.7
sleep 5
killall -KILL python2.7
