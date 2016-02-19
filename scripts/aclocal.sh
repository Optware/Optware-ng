#!/bin/bash

### This script is used by Optware-ng
### to automatically add libtool m4 scripts
### to aclocal.m4.
### This fixes libtool versions mismatch
### issue that occurs with some software
### (in most cases)

if [ -z "${ACLOCAL}" ]; then
	ACLOCAL=aclocal
fi

if [ -z "${TOP}" ]; then
	TOP=`dirname $0`/..
fi

if [ "x${SKIP_ACLOCAL}" == "x1" ]; then
	exit 0
fi

${ACLOCAL} "$@" || exit 1

( (cd "${TOP}/host/staging/opt/share/aclocal"; cat libtool.m4 ltoptions.m4 ltversion.m4 ltsugar.m4 lt~obsolete.m4) >> aclocal.m4) || exit 1
