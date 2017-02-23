#!/bin/sh
# Set alignak user as owner (if anyone launched alignak as root...)
chown alignak /usr/local/var/run/alignak/*
chown alignak /usr/local/var/log/alignak/*

if [ ${ALIGNAKCFG} ]; then
    ALIGNAK_CONFIGURATION_CFG="$ALIGNAKCFG"
else
    ALIGNAK_CONFIGURATION_CFG="/usr/local/etc/alignak/alignak.cfg"
fi
echo "Alignak main configuration file: ${ALIGNAK_CONFIGURATION_CFG}"

if [ ${ALIGNAKDAEMONS} ]; then
    ALIGNAK_DAEMONS_DIR="$ALIGNAKDAEMONS"
else
    ALIGNAK_DAEMONS_DIR="/usr/local/etc/alignak/daemons"
fi
echo "Alignak daemons configuration directory is: $ALIGNAK_DAEMONS_DIR"

echo "Starting 'North' realm daemons..."
echo " - broker..."
screen -d -S alignak_north_broker -m sh -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/North/brokerd-north.ini"
echo " - poller..."
screen -d -S alignak_north_poller -m sh -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/North//pollerd-north.ini"
echo " - scheduler..."
screen -d -S alignak_north_scheduler -m sh -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/North//schedulerd-north.ini"
echo " - receiver..."
screen -d -S alignak_north_receiver -m sh -c "alignak-receiver -c ${ALIGNAK_DAEMONS_DIR}/North//receiverd-north.ini"
echo "Started"
sleep 1

echo "Starting 'South' realm daemons..."
echo " - broker..."
screen -d -S alignak_south_broker -m sh -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/South/brokerd-south.ini"
echo " - poller..."
screen -d -S alignak_south_poller -m sh -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/South/pollerd-south.ini"
echo " - scheduler..."
screen -d -S alignak_south_scheduler -m sh -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/South/schedulerd-south.ini"
echo "Started"
sleep 1

echo "Starting 'South-East' realm daemons..."
echo " - broker..."
screen -d -S alignak_south_east_broker -m sh -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/South/South-East/brokerd-south-east.ini"
echo " - poller..."
screen -d -S alignak_south_east_poller -m sh -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/South/South-East/pollerd-south-east.ini"
echo " - scheduler..."
screen -d -S alignak_south_east_scheduler -m sh -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/South/South-East/schedulerd-south-east.ini"
echo "Started"
sleep 1

echo "Starting 'All' realm daemons..."
echo " - broker..."
screen -d -S alignak_broker -m sh -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/brokerd.ini"
echo " - poller..."
screen -d -S alignak_poller -m sh -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/pollerd.ini"
echo " - scheduler..."
screen -d -S alignak_scheduler -m sh -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/schedulerd.ini"
echo " - receiver..."
screen -d -S alignak_receiver -m sh -c "alignak-receiver -c ${ALIGNAK_DAEMONS_DIR}/receiverd.ini"
echo " - reactionner..."
screen -d -S alignak_reactionner -m sh -c "alignak-reactionner -c ${ALIGNAK_DAEMONS_DIR}/reactionnerd.ini"
echo "Started"
sleep 1

echo "Starting Alignak arbiter..."
screen -d -S alignak_arbiter -m sh -c "alignak-arbiter -c ${ALIGNAK_DAEMONS_DIR}/arbiterd.ini --arbiter ${ALIGNAK_CONFIGURATION_CFG}"
echo "Started"
