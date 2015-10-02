#!/bin/sh

if ! test -e /bin/bash
then ln -sf %OPTWARE_TARGET_PREFIX%/bin/bash /bin/bash
fi
