#!/usr/bin/env bash
echo "Start Alignak backend..."
screen -d -S alignak-backend -m bash -c "alignak-backend"
sleep 1
