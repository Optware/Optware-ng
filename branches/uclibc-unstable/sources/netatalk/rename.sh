#!/bin/bash 

for f in opt/*/armv5b-softfloat-linux-*; do n=`echo $f | sed -e 's/armv5b-softfloat-linux-//'`; mv $f $n; done
