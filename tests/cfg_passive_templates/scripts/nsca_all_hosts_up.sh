#!/bin/sh

# nsca_all_hosts_up.sh
#
# This script will send a passive check result for an host to the NSCA receiver.
#
# Arguments:
#  $1 = host_name (Short name of host that the service is associated with)
#  $2 = return_code (An integer that determines the state
#       of the host check, 0=UP, 1=UNREACHABLE, 2=CRITICAL, 3=UNKNOWN).
#  $3 = plugin_output (A text string that should be used as the plugin
#       output for the host check)
#
# Note:
# Modify the receiver_host variable to match the name or IP address
# of the Alignak receiver daemon.

./send_nsca_host.sh test.host.A 0 'Host is UP'
./send_nsca_host.sh test.host.B 0 'Host is UP'
./send_nsca_host.sh test.host.C 0 'Host is UP'
./send_nsca_host.sh test.host.D 0 'Host is UP'
./send_nsca_host.sh test.host.E 0 'Host is UP'
