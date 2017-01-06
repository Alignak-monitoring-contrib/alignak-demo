#!/usr/bin/env bash
echo "Starting Alignak backend..."
screen -d -S alignak-backend -m bash -c "alignak-backend"
sleep 1
echo "Started"
