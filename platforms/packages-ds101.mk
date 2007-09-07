# Packages that *only* work for ds101 - do not just put new packages here.
SPECIFIC_PACKAGES = \
	ds101-bootstrap \
	ds101-kernel-modules \

# Packages that do not work for ds101.
# gnuplot - matrix.c:337: In function `lu_decomp': internal compiler error: Segmentation fault
BROKEN_PACKAGES = \
	bpalogin \
	freeradius gnuplot \
	imagemagick \
	ldconfig lftp \
	monotone motion \
	qemu qemu-libc-i386 \
