#!/usr/bin/env bash
if [ ${ALIGNAKDAEMONS} ]; then
    ALIGNAK_DAEMONS_DIR="$ALIGNAKDAEMONS"
else
    ALIGNAK_DAEMONS_DIR="/usr/local/etc/alignak/daemons"
fi

echo "Start North realm daemons..."
screen -d -S alignak_north_broker -m bash -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/North/brokerd-north.ini"
screen -d -S alignak_north_poller -m bash -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/North//pollerd-north.ini"
screen -d -S alignak_north_scheduler -m bash -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/North//schedulerd-north.ini"
screen -d -S alignak_north_receiver -m bash -c "alignak-receiver -c ${ALIGNAK_DAEMONS_DIR}/North//receiverd-north.ini"
sleep 1
echo "Start South realm daemons..."
screen -d -S alignak_south_broker -m bash -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/South/brokerd-south.ini"
screen -d -S alignak_south_poller -m bash -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/South/pollerd-south.ini"
screen -d -S alignak_south_scheduler -m bash -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/South/schedulerd-south.ini"
sleep 1
echo "Start All realm daemons..."
screen -d -S alignak_broker -m bash -c "alignak-broker -c ${ALIGNAK_DAEMONS_DIR}/brokerd.ini"
screen -d -S alignak_poller -m bash -c "alignak-poller -c ${ALIGNAK_DAEMONS_DIR}/pollerd.ini"
screen -d -S alignak_scheduler -m bash -c "alignak-scheduler -c ${ALIGNAK_DAEMONS_DIR}/schedulerd.ini"
screen -d -S alignak_receiver -m bash -c "alignak-receiver -c ${ALIGNAK_DAEMONS_DIR}/receiverd.ini"
screen -d -S alignak_reactionner -m bash -c "alignak-reactionner -c ${ALIGNAK_DAEMONS_DIR}/reactionnerd.ini"
sleep 1
echo "Start Alignak arbiter..."
if [ ${ALIGNAKCFG} ]; then
    ALIGNAK_CONFIGURATION_CFG="$ALIGNAKCFG"
else
    ALIGNAK_CONFIGURATION_CFG="/usr/local/etc/alignak/alignak.cfg"
fi
echo "Alignak main configuration file: ${ALIGNAK_CONFIGURATION_CFG}"
screen -d -S alignak_arbiter -m bash -c "alignak-arbiter -c ${ALIGNAK_DAEMONS_DIR}/arbiterd.ini --arbiter ${ALIGNAK_CONFIGURATION_CFG}"
