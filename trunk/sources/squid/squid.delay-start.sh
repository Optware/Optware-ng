#!/bin/sh
#
# wait 300s and start squid.
#
# Normally, the cache dir is on the data partition.
# The data partition is not writable when it boot up.
# If you start the squid right away, it will
# quit and report 'no premission' to write cache.
# The dely-start script is used to start squid with delay.

echo "wait 300 seconds:"
sleep 300
echo "start squid:"
/opt/sbin/squid -f /opt/etc/squid/squid.conf -S -F


