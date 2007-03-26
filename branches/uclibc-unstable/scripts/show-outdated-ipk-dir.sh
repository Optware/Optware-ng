#!/bin/sh

# sample usage:
#   ./scripts/rm-outdated-ipk-dir.sh builds/*-ipk
#   ./scripts/rm-outdated-ipk-dir.sh {nslu2,wl500g}/builds/*-ipk
# don't be scared, this program won't actually remove directories
# it just prints out 'rm -rf' commands.

for d in $*
do
    [ 0 != `expr match $d '.*-ipk$'` ] || exit -1
    [ -d $d ] || exit -2
    pattern=`echo $d | sed 's/-\([0-9]\)\([^-]*\)-ipk/_\1\2-*.ipk/'`
    [ `echo $pattern` = "$pattern" ] && echo rm -rf $d # || echo \# keep $d \& `echo $pattern`
done
