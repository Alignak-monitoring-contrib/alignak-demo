#!/bin/sh
echo "Stopping Alignak arbiter..."
pkill -f alignak-arbiter
echo "Stopped"

echo "Stopping Alignak daemons..."
echo " - broker..."
pkill -f alignak-broker
echo " - poller..."
pkill -f alignak-poller
echo " - scheduler..."
pkill -f alignak-scheduler
echo " - receiver..."
pkill -f alignak-receiver
echo " - reactionner..."
pkill -f alignak-reactionner
echo "Stopped"
sleep 1
