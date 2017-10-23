###########################################################
#
# libusb for Linksys NSLU2
#
# Copyright (C) 2004 Peter Urbanec
#
# Released under GPL
#
#   #######################################################
#   
#   2005-07-01 - Updated to 0.1.10a, with debian patchset
#                Should work alot better.         - daka
#   2007-08-03 - Updated to 0.1.12, debian patchset
#   		 already in upstream.		  - bzhou
#
###########################################################

LIBUSB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libusb/
LIBUSB_VERSION:=0.1.12
LIBUSB_SOURCE=libusb-$(LIBUSB_VERSION).tar.gz
LIBUSB_DIR=libusb-$(LIBUSB_VERSION)
LIBUSB_UNZIP=zcat
LIBUSB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUSB_DESCRIPTION=Library for interfacing to the USB subsystem.
LIBUSB_SECTION=libs
LIBUSB_PRIORITY=optional
LIBUSB_DEPENDS=
LIBUSB_SUGGESTS=
LIBUSB_CONFLICTS=

#
# LIBUSB_IPK_VERSION should be incremented when the ipk changes.
#
LIBUSB_IPK_VERSION=2
#
# LIBUSB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUSB_PATCHES=\
$(LIBUSB_SOURCE_DIR)/digitemp.patch \
$(LIBUSB_SOURCE_DIR)/no-werror.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUSB_CPPFLAGS=
LIBUSB_LDFLAGS=

#
# LIBUSB_BUILD_DIR is the directory in which the build is done.
# LIBUSB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUSB_IPK_DIR is the directory in which the ipk is built.
# LIBUSB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUSB_BUILD_DIR=$(BUILD_DIR)/libusb
LIBUSB_SOURCE_DIR=$(SOURCE_DIR)/libusb
LIBUSB_IPK_DIR=$(BUILD_DIR)/libusb-$(LIBUSB_VERSION)-ipk
LIBUSB_IPK=$(BUILD_DIR)/libusb_$(LIBUSB_VERSION)-$(LIBUSB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libusb-source libusb-unpack libusb libusb-stage libusb-ipk libusb-clean libusb-dirclean libusb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUSB_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBUSB_SITE)/$(LIBUSB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libusb-source: $(DL_DIR)/$(LIBUSB_SOURCE)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(LIBUSB_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUSB_SOURCE) $(LIBUSB_PATCHES) make/libusb.mk
	rm -rf $(BUILD_DIR)/$(LIBUSB_DIR) $(LIBUSB_BUILD_DIR)
	$(LIBUSB_UNZIP) $(DL_DIR)/$(LIBUSB_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(LIBUSB_PATCHES)"; then \
		cat $(LIBUSB_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(LIBUSB_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(LIBUSB_DIR) $(LIBUSB_BUILD_DIR)
	(cd $(LIBUSB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUSB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUSB_LDFLAGS)" \
		./configure \
		--enable-shared \
		--disable-static \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-build-docs \
		--prefix=$(TARGET_PREFIX) \
	)
	$(PATCH_LIBTOOL) $(LIBUSB_BUILD_DIR)/libtool
	touch $(LIBUSB_BUILD_DIR)/.configured

libusb-unpack: $(LIBUSB_BUILD_DIR)/.configured

$(LIBUSB_BUILD_DIR)/.built: $(LIBUSB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBUSB_BUILD_DIR) \
		SUBDIRS=. lib_LTLIBRARIES=libusb.la
	touch $@

libusb: $(LIBUSB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUSB_BUILD_DIR)/.staged: $(LIBUSB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBUSB_BUILD_DIR) DESTDIR=$(STAGING_DIR) \
		SUBDIRS=. lib_LTLIBRARIES=libusb.la install
	rm -f $(STAGING_LIB_DIR)/libusb.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libusb.pc
	touch $@

libusb-stage: $(LIBUSB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libusb
#
$(LIBUSB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(LIBUSB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libusb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUSB_PRIORITY)" >>$@
	@echo "Section: $(LIBUSB_SECTION)" >>$@
	@echo "Version: $(LIBUSB_VERSION)-$(LIBUSB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUSB_MAINTAINER)" >>$@
	@echo "Source: $(LIBUSB_SITE)/$(LIBUSB_SOURCE)" >>$@
	@echo "Description: $(LIBUSB_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUSB_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUSB_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUSB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/etc/libusb/...
# Documentation files should be installed in $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/doc/libusb/...
# Daemon startup scripts should be installed in $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libusb
#
# You may need to patch your application to make it use these locations.
#
$(LIBUSB_IPK): $(LIBUSB_BUILD_DIR)/.built
	rm -rf $(LIBUSB_IPK_DIR) $(BUILD_DIR)/libusb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUSB_BUILD_DIR) DESTDIR=$(LIBUSB_IPK_DIR) \
		SUBDIRS=. lib_LTLIBRARIES=libusb.la install-strip
	( cd $(LIBUSB_BUILD_DIR)/tests ; \
		$(TARGET_CC) -o $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/bin/testlibusb testlibusb.c \
			-I$(STAGING_INCLUDE_DIR) -L$(STAGING_LIB_DIR) -lusb \
			-Wl,--rpath -Wl,$(TARGET_PREFIX)/lib )
	$(STRIP_COMMAND) $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/bin/testlibusb
#	rm -rf $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/include
#	rm -rf $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/bin/libusb-config
	rm -f $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/lib/*.la $(LIBUSB_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(MAKE) $(LIBUSB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUSB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libusb-ipk: $(LIBUSB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libusb-clean:
	-$(MAKE) -C $(LIBUSB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libusb-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUSB_DIR) $(LIBUSB_BUILD_DIR) $(LIBUSB_IPK_DIR) $(LIBUSB_IPK)

#
# Some sanity check for the package.
#
libusb-check: $(LIBUSB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBUSB_IPK)
