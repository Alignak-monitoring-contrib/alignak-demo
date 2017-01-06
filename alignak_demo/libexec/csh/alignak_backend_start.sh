#!/bin/sh
echo "Start Alignak backend..."
screen -d -S alignak_backend -m csh -c "alignak-backend"
sleep 1
