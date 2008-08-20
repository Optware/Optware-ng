## Toplevel Makefile for cross-compilation of perl
#
## $Id$

export TOPDIR=${shell pwd}
include $(TOPDIR)/config
export CFLAGS
export SYS=$(ARCH)-$(OS)
export CROSS=$(ARCH)-$(OS)-
# GCC bug http://gcc.gnu.org/bugzilla/show_bug.cgi?id=14279
# prevents using -O2 for all files when target is ia64, arm or powerpc
# see also https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=141694
export FULL_OPTIMIZATION = -fexpensive-optimizations -fomit-frame-pointer
#export OPTIMIZATION = -O2

export CC = $(CROSS)gcc
export CXX = $(CROSS)g++
export LD = $(CROSS)ld
export STRIP = $(CROSS)strip
export AR = $(CROSS)ar
export RANLIB = $(CROSS)ranlib


## Optimisation work
ifeq ($(ARCH),arm)
 ifdef CONFIG_TARGET_ARM_SA11X0
   ifndef Architecture
     Architecture = armv4l-strongarm
   endif
   FULL_OPTIMIZATION += -march=armv4 -mtune=strongarm1100 -mapcs-32
   OPTIMIZATION += -march=armv4 -mtune=strongarm1100 -mapcs-32
 endif
endif

CFLAGS+=$(FULL_OPTIMIZATION)

all:
	@echo Please read the README file before doing anything else.

gen_patch:
	diff -Bbur ../Makefile.SH Makefile.SH > Makefile.SH.patch
	diff -Bbur ../installperl installperl > installperl.patch

patch:
	cd .. ; if [ ! -e ./CROSS_PATCHED ] ; then \
		patch -p1 < Cross/Makefile.SH.patch; \
		patch -p1 < Cross/installperl.patch ; mv installperl installperl-patched; \
		sed -e 's/XXSTRIPXX/$(SYS)/' installperl-patched > installperl; \
		touch CROSS_PATCHED ; fi

dry_patch:
	cd .. ;	patch --dry-run -p1 < Cross/Makefile.SH.patch; \
		patch --dry-run -p1 < Cross/installperl.patch; \

perl_Configure:
	@echo Perl cross-build directory is $(TOPDIR)
	@echo Target arch is $(SYS)
	@echo toolchain: $(CC), $(CXX), $(LD), $(STRIP), $(AR), $(RANLIB)
	@echo Optimizations: $(FULL_OPTIMIZATION)
	$(TOPDIR)/generate_config_sh config.sh-$(SYS) > $(TOPDIR)/../config.sh
	cd $(TOPDIR)/.. ; ./Configure -S

perl:
	cd $(TOPDIR)/.. ; make depend ; make ; make more
	cd $(TOPDIR)/.. ; mkdir -p fake_config_library ; cp lib/Config.pm lib/Config_heavy.pl fake_config_library
	cd $(TOPDIR)/.. ; $(MAKE) more2 "PERLRUN=hostperl -I$(TOPDIR)/../fake_config_library -MConfig"
	cd $(TOPDIR)/.. ; $(MAKE) more3 "PERLRUN=hostperl -I$(TOPDIR)/../fake_config_library -MConfig"
	cd $(TOPDIR)/.. ; $(MAKE) more4 "PERLRUN=hostperl -I$(TOPDIR)/../fake_config_library -MConfig"
	cd $(TOPDIR)/.. ; rm -rf install_me_here
#	cd $(TOPDIR)/.. ; make install-strip
	cd $(TOPDIR)/.. ; sh -x Cross/warp
