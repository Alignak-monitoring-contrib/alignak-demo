#!/bin/sh

# send_nsca_service.sh
#
# This script will send a passive check result for a service to the NSCA receiver.
#
# Arguments:
#  $1 = host_name (Short name of host that the service is associated with)
#  $2 = svc_description (Description of the service)
#  $3 = return_code (An integer that determines the state
#       of the service check, 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN).
#  $4 = plugin_output (A text string that should be used as the plugin
#       output for the service check)
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
   echo "Missing parameter for service_description"
   usage >&2
   exit 2
fi

if ! test "$3"
then
   echo "Missing parameter for state"
   usage >&2
   exit 2
fi

# Convert the state string to the corresponding return code
return_code=-1

case "$3" in
    OK)
        return_code=0
        ;;
    WARNING)
        return_code=1
        ;;
    CRITICAL)
        return_code=2
        ;;
    UNKNOWN)
        return_code=3
        ;;
    *)
        return_code=$3
        ;;
esac

echo "Sending $1\t$2\t$return_code\t$4"
/bin/echo -e "$1\t$2\t$return_code\t$4\n" | /usr/sbin/send_nsca -H $receiver_host -p 5667 -c /etc/send_nsca.cfg