#!/usr/bin/env python

import fileinput
import os
import sys

from slimit import minify

if len(sys.argv) != 2:
    print "Specify a source js"
    sys.exit(1)

file_dbg_js = os.path.abspath(sys.argv[1])

with open(file_dbg_js, 'r') as in_file:
    print minify(in_file.read())
