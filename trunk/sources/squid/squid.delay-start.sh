#!/bin/sh
#
# wait 300s and start squid.
#
# Normally, the cache dir is on the data partition.
# The data partition is not writable when it boot up,
# if you have quota check enable.
# If you start the squid right away, it will
# quit and report 'no premission' to write cache.
# The dely-start script is used to start squid with delay.

# if you have a large HD, you may need more than 300s.

echo "wait 300 seconds:"
sleep 300
echo "start squid:"
/opt/sbin/squid -f /opt/etc/squid/squid.conf


