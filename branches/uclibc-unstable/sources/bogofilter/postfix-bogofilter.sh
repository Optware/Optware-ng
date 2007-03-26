#!/bin/sh

BOGOFILTER=/opt/bin/bogofilter
SPOOL_DIR=/opt/var/spool/bogofilter
POSTFIX=/opt/sbin/sendmail
export BOGOFILTER_DIR=/opt/var/spool/bogofilter

# Exit codes from <sysexits.h>
EX_TEMPFAIL=75
EX_UNAVAILABLE=69

cd $SPOOL_DIR || { echo $SPOOL_DIR does not exist; exit $EX_TEMPFAIL; }

# Clean up when done or when aborting.
trap "rm -f msg.$$ ; exit $EX_TEMPFAIL" 0 1 2 3 15

# bogofilter -e returns: 0 for OK, nonzero for error
rm -f msg.$$ || exit $EX_TEMPFAIL
$BOGOFILTER -p -u -e > msg.$$ || exit $EX_TEMPFAIL

exec <msg.$$ || exit $EX_TEMPFAIL
rm -f msg.$$ # safe, we hold the file descriptor
exec $POSTFIX "$@"
exit $EX_TEMPFAIL

