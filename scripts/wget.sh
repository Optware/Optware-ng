#!/bin/sh

### This script is used by Optware-ng
### to download sources using wget
### and automatically verify checksums

if [ -z "${WGET}" ]; then
	WGET=wget
fi

if [ -z "${TOP}" ]; then
	TOP=`dirname $0`
fi

${WGET} "$@" || fail=1

skip=0
next_is_file=0
next_is_dir=0
file=""
dir=""

for arg in "$@"; do

		### skip if skip flag was previously triggered
		if [ "$skip" == "1" ]; then
			skip=0
			continue
		fi

		### if previous flag was '-O', current $arg
		### is target file
		if [ "$next_is_file" == "1" ]; then
			next_is_file=0
			file="$arg"
			break
		fi

		### if previous flag was '-P', current $arg
		### is target dir
		if [ "$next_is_dir" == "1" ]; then
			next_is_dir=0
			dir="$arg"/
			continue
		fi

		### check for '-O' and '-P' switches and
		### skip switches we don't need to know here and
		### (if expected) relevant argument
		case "$arg" in
			-O)
				next_is_file=1
				continue
				;;
			-P)
				next_is_dir=1
				continue
				;;
			-[ABDiIlQRtTUwX])
				skip=1
				continue
				;;
			-*)
				continue
				;;
		esac

		### if we got here, $arg is the URL,
		### so we build file from dir
		### and URL
		file=${dir}`echo $arg | sed -e 's|/*$||' -e 's|.*/||'`
	done

if [ "x$fail" == "x1" ]; then
	echo "Download failed" >&2
	echo "Removing ${file}" >&2
	rm -f ${file}
	exit 1
fi

if [ ! -f $file ]; then
	echo "Download failed" >&2
	exit 1
fi

if [ "x${SKIP_CHECKSUM}" != "x1" ]; then
	if [ ! -f "${TOP}/checksums/$(basename ${file}).sha512" ]; then
		echo "Missing checksum for $(basename ${file})" >&2
		if [ "x${CREATE_CHECKSUM}" == "x1" ]; then
			echo "Creating ${TOP}/checksums/$(basename ${file}).sha512 as requested" >&2
			(sha512sum $file | cut -d ' ' -f1 > ${TOP}/checksums/$(basename ${file}).sha512) || exit 1
			exit 0
		fi
		echo "Removing ${file}" >&2
		rm -f ${file}
		exit 1
	fi

	if [ "`sha512sum $file | cut -d ' ' -f1`" != "`cat ${TOP}/checksums/$(basename ${file}).sha512`" ]; then
		echo "Checksum mismatch" >&2
		echo "Removing ${file}" >&2
		rm -f ${file}
		exit 1
	fi
fi

exit 0
