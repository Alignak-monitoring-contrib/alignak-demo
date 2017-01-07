#!/usr/bin/env bash
echo "Stopping Alignak arbiter..."
screen -X -S alignak_arbiter quit
echo "Stopped"

echo "Stopping 'North' realm daemons..."
echo " - receiver..."
screen -X -S alignak_north_receiver quit
echo " - poller..."
screen -X -S alignak_north_poller quit
echo " - broker..."
screen -X -S alignak_north_broker quit
echo " - scheduler..."
screen -X -S alignak_north_scheduler quit
echo "Stopped"
sleep 1

echo "Stopping 'South' realm daemons..."
echo " - poller..."
screen -X -S alignak_south_poller quit
echo " - broker..."
screen -X -S alignak_south_broker quit
echo " - scheduler..."
screen -X -S alignak_south_scheduler quit
echo "Stopped"
sleep 1

echo "Stopping 'All' realm daemons..."
echo " - broker..."
screen -X -S alignak_broker quit
echo " - poller..."
screen -X -S alignak_poller quit
echo " - scheduler..."
screen -X -S alignak_scheduler quit
echo " - receiver..."
screen -X -S alignak_receiver quit
echo " - reactionner..."
screen -X -S alignak_reactionner quit
echo "Stopped"
sleep 1
