#!/bin/sh
#
# wait 300s and start squid.
# for some reason, need to wait until klogd startd
# under nslu-linux v2.12
#

echo "wait 300 seconds:"
sleep 300
echo "start squid:"
/opt/sbin/squid -f /opt/etc/squid/squid.conf -S -F


