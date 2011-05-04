#!/bin/sh
#
# This delay starting up squid until quotacheck is finish.
#
# Normally, the cache dir is on the data partition.
# The data partition is not writable when it boot up,
# if you have quotacheck enable.
# If you start the squid right away, it will
# quit and report 'no premission' to write cache.
# The dely-start script is used to start squid with delay.

# if you have a large HD, you may have a long delay.

while [ -n "`pidof quotacheck`" ]
do
   echo "wait 60 seconds:"
   sleep 60
done

echo "start squid:"
/opt/sbin/squid -f /opt/etc/squid/squid.conf

