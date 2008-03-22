#!/bin/sh

[ -e /opt/etc/default/openssh ] && . /opt/etc/default/openssh

if [ "$SSHD_ENABLE" = "no" ]; then
    exit
fi

if [ -f /opt/var/run/sshd.pid ] ; then
  kill `cat /opt/var/run/sshd.pid`
else
  if [ -n "$SSHD_NO_PID_KILLALL" ] ; then
    killall $SSHD_NO_PID_KILLALL
  else
    killall /opt/sbin/sshd
  fi
fi

rm -f /opt/var/run/sshd.pid

umask 077

/opt/sbin/sshd
