###########################################################
#
# cdrtools
#
###########################################################

#
# CDRTOOLS_VERSION, CDRTOOLS_SITE and CDRTOOLS_SOURCE define
# the upstream location of the source code for the package.
# CDRTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# CDRTOOLS_UNZIP is the command used to unzip the source.
#

CDRTOOLS_SITE=ftp://ftp.berlios.de/pub/cdrecord
CDRTOOLS_VERSION=2.01
CDRTOOLS_SOURCE=cdrtools-$(CDRTOOLS_VERSION).tar.gz
CDRTOOLS_DIR=cdrtools-$(CDRTOOLS_VERSION)
CDRTOOLS_UNZIP=zcat
CDRTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CDRTOOLS_DESCRIPTION=low-level CD recording tools: cdrecord, mkisofs, etc.
CDRTOOLS_SECTION=extras
CDRTOOLS_PRIORITY=optional
CDRTOOLS_DEPENDS=
CDRTOOLS_SUGGESTS=kernel-module-cdrom, kernel-module-sr-mod, \
	kernel-module-sg, kernel-module-isofs
CDRTOOLS_CONFLICTS=

#
# CDRTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
CDRTOOLS_IPK_VERSION=4

#
# Force using gcc rather than cc
#
CDRTOOLS_MAKE=$(MAKE) CCOM=gcc

#
# CDRTOOLS_CONFFILES should be a list of user-editable files
CDRTOOLS_CONFFILES=

#
# CDRTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CDRTOOLS_PATCHES=$(CDRTOOLS_SOURCE_DIR)/cdrtools-$(CDRTOOLS_VERSION).patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CDRTOOLS_CPPFLAGS=
CDRTOOLS_LDFLAGS=-Wl,--strip-all

ifeq (uclibc, $(LIBC_STYLE))
CDRTOOLS_CONFIG_ENVS=export \
	ac_cv_prog_cc_cross=yes \
	ac_cv_func_ecvt=no \
	ac_cv_func_fcvt=no \
	ac_cv_func_gcvt=no \
	ac_cv_func_isinf=no \
	ac_cv_func_isnan=no \
	;
else
CDRTOOLS_CONFIG_ENVS=\
	if test ! -f "$(CDRTOOLS_BUILD_DIR)/incs/arch-linux-gcc/config.cache"; \
	    then export \
	ac_cv_prog_cc_cross=yes \
	ac_cv_dev_minor_bits=8 \
	ac_cv_dev_minor_noncontig=no \
	ac_cv_c_bitfields_htol=yes \
	ac_cv_type_prototypes=yes \
	ac_cv_sizeof_char=1 \
	ac_cv_sizeof_short_int=2 \
	ac_cv_sizeof_int=4 \
	ac_cv_sizeof_long_int=4 \
	ac_cv_sizeof_long_long=8 \
	ac_cv_sizeof_char_p=4 \
	ac_cv_sizeof_unsigned_char=1 \
	ac_cv_sizeof_unsigned_short_int=2 \
	ac_cv_sizeof_unsigned_int=4 \
	ac_cv_sizeof_unsigned_long_int=4 \
	ac_cv_sizeof_unsigned_long_long=8 \
	ac_cv_sizeof_unsigned_char_p=4 \
	ac_cv_func_mlock=yes \
	ac_cv_func_mlockall=yes \
	ac_cv_func_ecvt=yes \
	ac_cv_func_fcvt=yes \
	ac_cv_func_gcvt=no \
	ac_cv_func_dtoa_r=no \
	ac_cv_func_sys_siglist=yes \
	ac_cv_func_bsd_getpgrp=no ac_cv_func_bsd_setpgrp=no \
	ac_cv_no_user_malloc=no \
	ac_cv_hard_symlinks=yes \
	ac_cv_link_nofollow=yes \
	ac_cv_access_e_ok=no \
	\
	ac_cv_func_mmap_fixed_mapped=yes \
	ac_cv_func_wait3_rusage=yes \
	ac_cv_func_smmap=yes \
	ac_cv_type_char_unsigned=yes \
	; fi;
endif
#
# CDRTOOLS_BUILD_DIR is the directory in which the build is done.
# CDRTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CDRTOOLS_IPK_DIR is the directory in which the ipk is built.
# CDRTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CDRTOOLS_BUILD_DIR=$(BUILD_DIR)/cdrtools
CDRTOOLS_SOURCE_DIR=$(SOURCE_DIR)/cdrtools
CDRTOOLS_IPK_DIR=$(BUILD_DIR)/cdrtools-$(CDRTOOLS_VERSION)-ipk
CDRTOOLS_IPK=$(BUILD_DIR)/cdrtools_$(CDRTOOLS_VERSION)-$(CDRTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CDRTOOLS_SOURCE):
	$(WGET) -P $(@D) $(CDRTOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cdrtools-source: $(DL_DIR)/$(CDRTOOLS_SOURCE) $(CDRTOOLS_PATCHES)

#
# This target unpacks and patches the source code in the build directory.
# It does not do any configuration, since that happens as part of the
# first "make".
#
$(CDRTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(CDRTOOLS_SOURCE) $(CDRTOOLS_PATCHES)
	rm -rf $(BUILD_DIR)/$(CDRTOOLS_DIR) $(@D)
	$(CDRTOOLS_UNZIP) $(DL_DIR)/$(CDRTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CDRTOOLS_PATCHES)" ; \
		then cat $(CDRTOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CDRTOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CDRTOOLS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CDRTOOLS_DIR) $(@D) ; \
	fi
	sed -i \
	    -e 's|$$(_MACHCMD)|echo unknown|' \
	    -e 's|$$(_ARCHCMD)|echo arch|' \
	    -e '/^XK_ARCH:=	/s|uname -m *|echo arch |' \
	    -e '/^OSNAME:=	/s|$$.*|linux|' \
	    -e '/^OSREL:=	/s|$$.*|2.4.22-xfs|' \
	    -e '/^__gmake_warn:=/s!$$(shell .*)$$!!' \
	    $(@D)/RULES/mk-*.id
	sed -i \
	    -e 's|$$(PTARGETC) > |cp $(CDRTOOLS_SOURCE_DIR)/`basename $$@` |' \
	    $(@D)/RULES/rules.inc
	sed -i \
	    -e 's|; gcc|; $(TARGET_CC)|' \
	    $(@D)/RULES/arch-linux-cc.rul \
	    $(@D)/RULES/arch-linux-gcc.rul
	sed -i -e 's|$${CC-cc}|$(TARGET_CC)|g' $(@D)/conf/configure
	mkdir -p $(@D)/incs/arch-linux-gcc/
ifneq ($(HOSTCC), $(TARGET_CC))
	[ -e "$(CDRTOOLS_SOURCE_DIR)/optware-$(OPTWARE_TARGET)-config.cache" ] && \
		cp $(CDRTOOLS_SOURCE_DIR)/optware-$(OPTWARE_TARGET)-config.cache \
			$(@D)/incs/arch-linux-gcc/config.cache || \
	[ -e "$(CDRTOOLS_SOURCE_DIR)/$(TARGET_ARCH)-config.cache" ] && \
		cp $(CDRTOOLS_SOURCE_DIR)/$(TARGET_ARCH)-config.cache \
			$(@D)/incs/arch-linux-gcc/config.cache || \
	true
endif
	touch $@

cdrtools-unpack: $(CDRTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binaries.
#
$(CDRTOOLS_BUILD_DIR)/.built: $(CDRTOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(CDRTOOLS_CONFIG_ENVS) \
	$(TARGET_CONFIGURE_OPTS) \
	CPPFLAGS="$(STAGING_CPPFLAGS) $(CDRTOOLS_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(CDRTOOLS_LDFLAGS)" \
	CONFFLAGS="--build=$(GNU_HOST_NAME) --host=$(GNU_TARGET_NAME) --target=$(GNU_TARGET_NAME)" \
	$(CDRTOOLS_MAKE) -C $(@D) LDOPTX=$(CDRTOOLS_LDFLAGS);
	touch $@

#
# This is the build convenience target.
#
cdrtools: $(CDRTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CDRTOOLS_BUILD_DIR)/.staged: $(CDRTOOLS_BUILD_DIR)/.built
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
	$(CDRTOOLS_MAKE) -C $(CDRTOOLS_BUILD_DIR) LDOPTX=$(CDRTOOLS_LDFLAGS) \
		INS_BASE=$(STAGING_DIR) install
	touch $@

cdrtools-stage: $(CDRTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cdrtools
#
$(CDRTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(CDRTOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cdrtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CDRTOOLS_PRIORITY)" >>$@
	@echo "Section: $(CDRTOOLS_SECTION)" >>$@
	@echo "Version: $(CDRTOOLS_VERSION)-$(CDRTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CDRTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(CDRTOOLS_SITE)/$(CDRTOOLS_SOURCE)" >>$@
	@echo "Description: $(CDRTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(CDRTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(CDRTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(CDRTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CDRTOOLS_IPK_DIR)/opt/sbin or $(CDRTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CDRTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CDRTOOLS_IPK_DIR)/opt/etc/cdrtools/...
# Documentation files should be installed in $(CDRTOOLS_IPK_DIR)/opt/doc/cdrtools/...
# Daemon startup scripts should be installed in $(CDRTOOLS_IPK_DIR)/opt/etc/init.d/S??cdrtools
#
# You may need to patch your application to make it use these locations.
#
$(CDRTOOLS_IPK): $(CDRTOOLS_BUILD_DIR)/.built
	rm -rf $(CDRTOOLS_IPK_DIR) $(BUILD_DIR)/cdrtools_*_$(TARGET_ARCH).ipk
	$(TARGET_CONFIGURE_OPTS) \
	$(CDRTOOLS_MAKE) -C $(CDRTOOLS_BUILD_DIR) LDOPTX=$(CDRTOOLS_LDFLAGS) \
		INS_BASE=$(CDRTOOLS_IPK_DIR)/opt install
	$(MAKE) $(CDRTOOLS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CDRTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cdrtools-ipk: $(CDRTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cdrtools-clean:
	rm -f $(CDRTOOLS_BUILD_DIR)/.built
	-$(CDRTOOLS_MAKE) -C $(CDRTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cdrtools-dirclean:
	rm -rf $(BUILD_DIR)/$(CDRTOOLS_DIR) $(CDRTOOLS_BUILD_DIR) $(CDRTOOLS_IPK_DIR) $(CDRTOOLS_IPK)

#
# Some sanity check for the package.
#
cdrtools-check: $(CDRTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CDRTOOLS_IPK)
