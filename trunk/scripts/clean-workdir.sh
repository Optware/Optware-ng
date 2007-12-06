#!/bin/sh

# This script will
#	rm -rf builds/$p/* builds/$p_*-ipk
# if P_IPK built, and
# either $p-stage is not used, or $p staged already

test -n "$DEBUG" && set -x

if test "x$1" = "x-d"
then shift; dry_run=1
fi

PKGS_VAR=$1
if test -z "$PKGS_VAR"; then
        echo Usage1:    $0 [-d] pkgname1 pkgname2 ...
        echo Usage2:    $0 [-d] PACKAGES
        echo	-d	dry run
	exit
fi

if test `echo $PKGS_VAR | tr [a-z] [A-Z]` = "$PKGS_VAR"
then packages=`make query-${PKGS_VAR}`
else packages=$*
fi

for p in ${packages}
do
	echo -n $p

        all_ipk_files_exist=true
        ipk_dirs=""
        for IPK in `sed -n '/^[^#].*_IPK[:? ]*=/s/[:? ]*=.*//p' make/${p}.mk`; do
            ipk=`make -s query-${IPK}`
            test -f $ipk || all_ipk_files_exist=false
            ipk_dirs="$ipk_dirs `make -s query-${IPK}_DIR`"
        done

	BUILD_DIR_VAR=`sed -n '/^[^#].*_BUILD_DIR[:? ]*=/s/[:? ]*=.*//p' make/${p}.mk | head -1`
	build_dir=`make -s query-${BUILD_DIR_VAR}`

        staging_count=`grep -l ' ${p}-stage' make/*.mk | wc -l`
        todo="skip"
        if test 0 -eq `grep -c 'IPK): .*/\.built' make/${p}.mk`; then
            todo="skip"
        elif test -d "$build_dir" -a "$all_ipk_files_exist" = "true"; then
            if test $staging_count -le 1 -o -f "$build_dir/.staged"; then
        	if ! ls $build_dir/* > /dev/null 2>&1; then
                	todo="already clean"
        	elif test -n "$dry_run"; then
                	todo="dry run"
                else
                	todo="clean"
        	fi
            fi
        fi

        echo " $todo"
        if test "$todo" = "clean"; then
               echo $build_dir/* $ipk_dirs | xargs rm -rf
        fi
done
