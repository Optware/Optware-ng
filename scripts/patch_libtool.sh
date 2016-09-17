#!/bin/bash

xassembler_patch()
{
	for file in $@; do
	if cat $file | grep -xq "      -Xassembler)"; then
		continue
	fi
	(cat $SOURCES/libtool/xassembler.patch | sed -n '/^--- a\/build-aux\/ltmain\.sh$/,$p' | 
		patch -s $file
	) || exit 1
	done
}

SOURCES="${SOURCES:-`dirname $0`/../sources}"

sed "$@" || exit 1

next_is_script=1
no_more_flags=0

files=""

for arg in "$@"; do
	if [[ "$arg" == "--" ]] && [[ "$no_more_flags" == "0" ]]; then
		no_more_flags=1
		continue
	fi

	if [[ "$arg" == "-e" ]] && [[ "$no_more_flags" == "0" ]]; then
		next_is_script=1
		continue
	fi

	if [[ "$next_is_script" == "1" ]]; then
		next_is_script=0
		continue
	fi

	if [[ $arg == -* ]] && [[ "$no_more_flags" == "0" ]]; then
		continue
	fi

	files="$files $arg"
done

xassembler_patch $files
