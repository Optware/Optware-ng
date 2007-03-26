#!/bin/sh

for i in `find . -name Makefile.in` 
do 
	mv $i $i.orig 
	cat $i.orig | sed -r -e 's/^CPPFLAGS *= *$/CPPFLAGS=@CPPFLAGS@/' > $i
done 
exit 0