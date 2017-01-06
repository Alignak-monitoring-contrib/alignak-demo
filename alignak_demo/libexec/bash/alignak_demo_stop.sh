#!/usr/bin/env bash
echo "Stopping Alignak arbiter..."
screen -X -S alignak_arbiter quit
echo "Stopped"

echo "Stopping 'North' realm daemons..."
screen -X -S alignak_north_receiver quit
screen -X -S alignak_north_poller quit
screen -X -S alignak_north_broker quit
screen -X -S alignak_north_scheduler quit
echo "Stopped"
sleep 1

echo "Stopping 'South' realm daemons..."
screen -X -S alignak_south_poller quit
screen -X -S alignak_south_broker quit
screen -X -S alignak_south_scheduler quit
echo "Stopped"
sleep 1

echo "Stopping 'All' realm daemons..."
screen -X -S alignak_broker quit
screen -X -S alignak_poller quit
screen -X -S alignak_scheduler quit
screen -X -S alignak_receiver quit
screen -X -S alignak_reactionner quit
echo "Stopped"
sleep 1
