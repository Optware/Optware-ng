#!/bin/bash

set -e

recursive_provides()
{
	for package in `cat $TEST/$1/depends 2>/dev/null`; do
		recursive_provides $package $1
	done
	if [ -f $TEST/$1/provides.own ]; then
		cat $TEST/$1/provides.own
	else
#		echo "Missing dependency package error: package $1 required for $2 is missing" >&2
		echo "Missing $1, required for $2" >> $TEST/missing_packages.log
	fi
}

missing_libs_error_message()
{
	package="$1"
	shift 1
	echo "Package $package is missing dependencies for the following libraries:"
	echo $@ | sed 's/ /\n/g'
	echo
}

READELF="${READELF:-readelf}"
PACKAGESDIR="${PACKAGESDIR:-packages}"
TEST="${TEST:-test}"

if [ ! -d $TEST ]; then
	echo "Fatal error: no $TEST dir" >&2
	exit 1
fi

if [ -n "`ls -d $TEST/*`" ]; then
	echo "Fatal error: $TEST dir not empty" >&2
	exit 1
fi

if [ ! -f $PACKAGESDIR/Packages ]; then
	echo "Fatal error: no $PACKAGESDIR/Packages"
	exit 1
fi

PACKAGES=`sed -n '/^Package: /s/.* //p' $PACKAGESDIR/Packages`

for package in $PACKAGES; do
	mkdir -p $TEST/$package/temp

	PACKAGEINFO=`sed -n "/^Package: $package\$/,/^Package: /p" $PACKAGESDIR/Packages`

	echo "Generating $package depdendency list"
	echo `echo "$PACKAGEINFO" | sed -n 's/^Depends: //p' | sed 's/ *, */\n/g' | sed 's/ .*//'` > $TEST/$package/depends

	echo "Generating the list of libs provided by $package"
	FILENAME=`echo "$PACKAGEINFO" | sed -n 's/^Filename: //p'`
	tar -xOzf $PACKAGESDIR/$FILENAME ./data.tar.gz | tar -C $TEST/$package/temp -xzf -
	find -L $TEST/$package/temp -type f -name 'lib*.so*' | awk -F/ '{ print $NF }' | sort -u > $TEST/$package/provides.own

	echo "Generating the list of libs required for $package"
	find $TEST/$package/temp -type f -a -exec file {} \; | \
		sed -n -e 's/^\(.*\):.*ELF.*\(executable\|shared object\).*/\1/p' | \
		xargs -r -n1 $READELF -d | \
		awk '$2 ~ /NEEDED/ && $NF !~ /interpreter/ && $NF ~ /^\[?lib.*\.so/ { gsub(/[\[\]]/, "", $NF); print $NF }' | \
		sort -u > $TEST/$package/requires
	rm -rf $TEST/$package/temp
done

for package in $PACKAGES; do
	echo "Generating the list of libs recursively provided by $package"
	recursive_provides $package | sort -u > $TEST/$package/provides.recursive

	echo "Looking if any required lib is missing from provided ones for $package"
	MISSINGLIBS=""
	for lib in `cat $TEST/$package/requires`; do
		if ! cat $TEST/$package/provides.recursive | grep -xq "$lib"; then
			MISSINGLIBS="$MISSINGLIBS $lib"
		fi
	done
	if [ -n "$MISSINGLIBS" ]; then
#		missing_libs_error_message $package $MISSINGLIBS >&2
		missing_libs_error_message $package $MISSINGLIBS >> $TEST/missing_libraries_dependencies.log
	fi
done

if [ -f $TEST/missing_packages.log ]; then
	MISSINGPACKAGES=`cat $TEST/missing_packages.log | sort -u`
	echo "$MISSINGPACKAGES" > $TEST/missing_packages.log
	MISSINGPACKAGES=""
fi

echo
echo

if [ -f $TEST/missing_packages.log ] || [ -f $TEST/missing_libraries_dependencies.log ]; then
echo "FINAL REPORT. Problems found:"
	[ ! -f $TEST/missing_libraries_dependencies.log ] || cat $TEST/missing_libraries_dependencies.log
	[ ! -f $TEST/missing_packages.log ] || cat $TEST/missing_packages.log
else
	echo "FINAL REPORT: no problems found"
fi
