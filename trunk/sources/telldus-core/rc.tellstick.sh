#!/bin/sh
#
# $Id$
#

insmod usbserial
insmod ftdi_sio

if [ -e /dev/ttyUSB0 ];then
   device=/dev/ttyUSB0
else
   mknod /dev/ttyUSB0 c 188 0
   device=/dev/ttyUSB0
fi

if [ ! -e /dev/tellstick ];then
   ln -sf $device /dev/tellstick
fi

echo "/dev/tellstick initialised..."

