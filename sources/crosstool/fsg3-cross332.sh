#!/bin/sh
set -ex
TARBALLS_DIR=$HOME/downloads
export TARBALLS_DIR RESULT_TOP PREFIX
GCC_LANGUAGES="c,c++"
export GCC_LANGUAGES

# Really, you should do the mkdir before running this,
# and chown /opt/crosstool to yourself so you don't need to run as root.
mkdir -p $RESULT_TOP

# Build the toolchain. Takes a couple hours and a couple gigabytes.

eval `cat armv5b-softfloat-fsg3.dat gcc-3.3.2-glibc-2.2.5.dat` BINUTILS_DIR=binutils-2.15.94.0.2 LINUX_DIR=linux-2.4.22 sh all.sh --notest

echo Done.
