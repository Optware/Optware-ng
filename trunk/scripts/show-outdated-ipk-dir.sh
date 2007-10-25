#!/bin/sh

# sample usage:
#   ./scripts/$0 builds/*-ipk
#   ./scripts/$0 {nslu2,wl500g}/builds/*-ipk
# don't be scared, this program won't actually remove directories
# it just prints out 'rm -rf' commands.

for d in $*
do
    [ -d $d ] || exit -1
    [ -r $d/CONTROL/control ] || exit -2
    p=`awk '/^Package:/ {print $2}' $d/CONTROL/control`
    v=`awk '/^Version:/ {print $2}' $d/CONTROL/control`
    a=`awk '/^Architecture:/ {print $2}' $d/CONTROL/control`
    ipk=`dirname $d`/"${p}_${v}_${a}.ipk"
    [ -f $ipk ] || echo rm -rf $d
done
