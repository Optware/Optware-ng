#!/bin/sh
set -ex
TARBALLS_DIR=$HOME/downloads
export TARBALLS_DIR RESULT_TOP
GCC_LANGUAGES="c,c++"
export GCC_LANGUAGES
#CANADIAN_CROSS="YES"

# Really, you should do the mkdir before running this,
# and chown /opt/crosstool to yourself so you don't need to run as root.
mkdir -p $RESULT_TOP

export GCC_HOST AR AS LD NM CC GCC CXX RANLIB PATH GPROF

# Build the toolchain. Takes a couple hours and a couple gigabytes.

eval `cat armv5b-softfloat.dat gcc-3.3.4-glibc-2.2.5.dat` LINUX_DIR=linux-2.4.22 sh all.sh --notest

echo Done.
