##########################################################
#
# glibc-opt
#
###########################################################
#
# Provides glibc-opt packaging for package buildroot
#

GLIBC-OPT_VERSION ?= 2.20
GLIBC-OPT_IPK_VERSION ?= 1
GLIBC-OPT_LIBS_SOURCE_DIR ?= $(TARGET_USRLIBDIR)


GLIBC-OPT_DESCRIPTION=GNU C Library
GLIBC-OPT_SECTION=base
GLIBC-OPT_PRIORITY=required
GLIBC-OPT_DEPENDS=$(strip $(if $(filter true, $(NO_LIBNSL)), , libnsl))
GLIBC-OPT_SUGGESTS=
GLIBC-OPT_CONFLICTS=

# GLIBC-OPT_IPK_DIR is the directory in which the ipk is built.
# GLIBC-OPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GLIBC-OPT_BUILD_DIR=$(BUILD_DIR)/glibc-opt
GLIBC-OPT_IPK_DIR=$(BUILD_DIR)/glibc-opt-$(GLIBC-OPT_VERSION)-ipk
GLIBC-OPT_IPK=$(BUILD_DIR)/glibc-opt_$(GLIBC-OPT_VERSION)-$(GLIBC-OPT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# For building/cleaning targets see buildroot package
#

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(GLIBC-OPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: glibc-opt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLIBC-OPT_PRIORITY)" >>$@
	@echo "Section: $(GLIBC-OPT_SECTION)" >>$@
	@echo "Version: $(GLIBC-OPT_VERSION)-$(GLIBC-OPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(GLIBC-OPT_DESCRIPTION)" >>$@
	@echo "Depends: $(GLIBC-OPT_DEPENDS)" >>$@
	@echo "Suggests: $(GLIBC-OPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(GLIBC-OPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc/glibc-opt/...
# Documentation files should be installed in $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/doc/glibc-opt/...
# Daemon startup scripts should be installed in $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??glibc-opt
#
# You may need to patch your application to make it use these locations.
#
GLIBC-OPT_LIBS?=ld libBrokenLocale libSegFault libgcc_s libanl libc libcidn libcrypt libutil \
		libdl libm libmemusage libnss_compat libnss_dns libnss_files libnss_hesiod \
		libnss_nis libnss_nisplus libpcprofile libpthread libresolv librt libthread_db

GLIBC-OPT_LIBS_PATTERN=$(patsubst %,$(GLIBC-OPT_LIBS_SOURCE_DIR)/%*so*,$(GLIBC-OPT_LIBS))

$(GLIBC-OPT_BUILD_DIR)/.staged: make/glibc-opt.mk
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	cp -af $(GLIBC-OPT_LIBS_PATTERN) $(STAGING_LIB_DIR)
	touch $@

glibc-opt-stage: $(GLIBC-OPT_BUILD_DIR)/.staged

$(GLIBC-OPT_IPK): make/glibc-opt.mk
	rm -rf $(GLIBC-OPT_IPK_DIR) $(BUILD_DIR)/glibc-opt_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(GLIBC-OPT_IPK_DIR)
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(GLIBC-OPT_IPK_DIR) install-strip
#	tar -xv -C $(GLIBC-OPT_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.$(TARGET_ARCH).tar \
#		--wildcards $(GLIBC-OPT_LIBS_PATTERN) .$(TARGET_PREFIX)/sbin/ldconfig
	$(INSTALL) -d $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -d $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	cp -af $(GLIBC-OPT_LIBS_PATTERN) $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	-$(STRIP_COMMAND) $(patsubst %, $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib/%*so*, $(GLIBC-OPT_LIBS))
	### package non-stripped libpthread and libthread_db
	cp -f $(GLIBC-OPT_LIBS_SOURCE_DIR)/libpthread* $(GLIBC-OPT_LIBS_SOURCE_DIR)/libthread_db* \
							$(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib
	# these are provided by libc-dev
	rm -f `ls $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib/*{.so,.a} | egrep -v -- '-[0-9\.]*\.so$$'` \
		$(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib/libgcc_s.so
	# create $(TARGET_PREFIX)/lib64 -> lib symlink for 64-bit archs
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/bits.c | grep -q puts.*64-bit; then \
		ln -s lib $(GLIBC-OPT_IPK_DIR)$(TARGET_PREFIX)/lib64; \
	fi
	$(MAKE) $(GLIBC-OPT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(GLIBC-OPT_IPK_DIR)/CONTROL/prerm
#	echo $(GLIBC-OPT_CONFFILES) | sed -e 's/ /\n/g' > $(GLIBC-OPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLIBC-OPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
glibc-opt-ipk: $(GLIBC-OPT_IPK)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
glibc-opt-dirclean:
	rm -rf $(GLIBC-OPT_IPK_DIR) $(GLIBC-OPT_IPK)
#
#
# Some sanity check for the package.
#
glibc-opt-check: $(GLIBC-OPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
