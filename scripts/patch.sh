#!/bin/bash

### This script is used by Optware-ng
### to automatically replace all
### %OPTWARE_TARGET_PREFIX% occurences with
### ${TARGET_PREFIX} before
### applying patches

if [ -z "${TARGET_PREFIX}" ]; then
	TARGET_PREFIX=/opt
fi

(sed -e "s|%OPTWARE_TARGET_PREFIX%|${TARGET_PREFIX}|g" | patch "$@") < /dev/stdin
