#!/usr/bin/env bash
# Set alignak user as owner (if anyone launched alignak as root...)
chown alignak /usr/local/var/run/alignak/*
chown alignak /usr/local/var/log/alignak/*
#su -m alignak << EOF
start_screens_alignak_all.sh &
#exit
#EOF
