#!/bin/sh

### This script is used by Optware-ng
### to isolate cross-compilation .pc files
### from system ones

PKG_CONFIG=pkg-config

for arg in "$@"; do
	case "$arg" in
	--version | --atleast-pkgconfig-version | --atleast-pkgconfig-version=*)
		${PKG_CONFIG} "$@"
		exit $?
		;;
	esac
done

if [ -z "${PKG_CONFIG_PATH}" ]; then
	echo 'Error: PKG_CONFIG_PATH cannot be empty when cross-compiling' 1>&2
	exit 1
fi

export PKG_CONFIG_LIBDIR=`echo "${PKG_CONFIG_PATH}" | cut -d ':' -f1`

${PKG_CONFIG} "$@"
exit $?
