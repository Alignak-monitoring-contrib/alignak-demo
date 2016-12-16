#!/bin/sh

# send_nsca_host.sh
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

usage() {
    cat << END

Usage: $0 host_name service_description state output

state may be: OK, WARNING, CRITICAL, UNKNOWN, or the corresponding integer code
END
}

# NSCA receiver host
receiver_host=127.0.0.1

if ! test "$1"
then
   echo "Missing parameter for host_name"
   usage >&2
   exit 2
fi

if ! test "$2"
then
   echo "Missing parameter for state"
   usage >&2
   exit 2
fi

# Convert the state string to the corresponding return code
return_code=-1

case "$2" in
    UP)
        return_code=0
        ;;
    UNREACHABLE)
        return_code=1
        ;;
    DOWN)
        return_code=2
        ;;
    UNKNOWN)
        return_code=3
        ;;
    *)
        return_code=$3
        ;;
esac

echo "Sending $1\t$return_code\t$3"
/bin/echo -e "$1\t$return_code\t$3\n" | /usr/sbin/send_nsca -H $receiver_host -p 5667 -c /etc/send_nsca.cfg