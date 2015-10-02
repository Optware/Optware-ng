#!/bin/sh

BOGOFILTER=%OPTWARE_TARGET_PREFIX%/bin/bogofilter
SPOOL_DIR=%OPTWARE_TARGET_PREFIX%/var/spool/bogofilter
POSTFIX=%OPTWARE_TARGET_PREFIX%/sbin/sendmail
export BOGOFILTER_DIR=%OPTWARE_TARGET_PREFIX%/var/spool/bogofilter

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

