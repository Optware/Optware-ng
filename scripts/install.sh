#!/bin/bash

### This script is used by Optware-ng
### to install rc scripts and configs
### and automatically replace all
### %OPTWARE_TARGET_PREFIX% occurences with
### ${TARGET_PREFIX}

if [ -z "${TARGET_PREFIX}" ]; then
	TARGET_PREFIX=/opt
fi

install "$@" || exit 1

for arg in "$@"; do
	last=$arg
done

if [ -f $last ]; then

	### this means that
	### 	`install.sh [KEY] <SOURCE_FILE> <TARGET_FILE>`
	###  was called,
	### so we just call `sed ...` on the target and exit
	### (if target is text file and it contains %OPTWARE_TARGET_PREFIX%)
	if [ -n "`file $last | grep text`" ] && [ -n "`cat $last | grep %OPTWARE_TARGET_PREFIX%`" ]; then
		sed -i -e "s|%OPTWARE_TARGET_PREFIX%|${TARGET_PREFIX}|g" $last
	fi

else

	### this means that
	### 	`install.sh [KEY] <SOURCE_FILES> <TARGET_DIR>`
	### or
	### 	`install.sh [KEY] -d <TARGET_DIRS>`
	###  was called

	skip=0
	no_more_flags=0

	for arg in "$@"; do

		### don't do anything if installing a dir
		if [ "$arg" == "-d" ]; then
			exit 0
		fi

		### skip if skip flag was previously triggered
		if [ "$skip" == "1" ]; then
			skip=0
			continue
		fi

		if [ "$no_more_flags" != "1" ]; then

			### skip install switch and (if expected)
			### relevant argument
			case "$arg" in
				-[gmoSt])
					skip=1
					continue
					;;
				--)
					no_more_flags=1
					continue
					;;
				-*)
					continue
					;;
			esac
		fi

		### don't do anything on the last argument,
		### since it's the target dir
		if [ "$arg" == "$last" ]; then
			exit 0
		fi

		### if we got here, $arg is a file and $last is the dir
		### it was installed to;
		### still make the check to be safe
		file=${last}/`basename $arg`
		if [ -f $file ]; then

			### $file exists; if it is text and contains %OPTWARE_TARGET_PREFIX%,
			### apply `sed ...` on it
			if [ -n "`file $file | grep text`" ] && [ -n "`cat $file | grep %OPTWARE_TARGET_PREFIX%`" ]; then
				sed -i -e "s|%OPTWARE_TARGET_PREFIX%|${TARGET_PREFIX}|g" $file
			fi
		fi
	done

fi
