###########################################################
#
# dfu-util
#
###########################################################

#
# DFU-UTIL_REPOSITORY defines the upstream location of the source code
# for the package.  DFU-UTIL_DIR is the directory which is created when
# this svn module is checked out.
#

DFU-UTIL_REPOSITORY=http://svn.openmoko.org/trunk/src/host/dfu-util
DFU-UTIL_DIR=dfu-util
DFU-UTIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DFU-UTIL_DESCRIPTION=USB Device Firmware Upgrade utility
DFU-UTIL_SECTION=util
DFU-UTIL_PRIORITY=optional
DFU-UTIL_DEPENDS=libusb
DFU-UTIL_SUGGESTS=
DFU-UTIL_CONFLICTS=

DFU-UTIL_SVN_TAG=1574
DFU-UTIL_VERSION=r${DFU-UTIL_SVN_TAG}
DFU-UTIL_SVN_OPTS=-r $(DFU-UTIL_SVN_TAG)

#
# DFU-UTIL_IPK_VERSION should be incremented when the ipk changes.
#
DFU-UTIL_IPK_VERSION=1

#
# DFU-UTIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DFU-UTIL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DFU-UTIL_CPPFLAGS=
DFU-UTIL_LDFLAGS=

#
# DFU-UTIL_BUILD_DIR is the directory in which the build is done.
# DFU-UTIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DFU-UTIL_IPK_DIR is the directory in which the ipk is built.
# DFU-UTIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DFU-UTIL_BUILD_DIR=$(BUILD_DIR)/dfu-util
DFU-UTIL_SOURCE_DIR=$(SOURCE_DIR)/dfu-util
DFU-UTIL_IPK_DIR=$(BUILD_DIR)/dfu-util-$(DFU-UTIL_VERSION)-ipk
DFU-UTIL_IPK=$(BUILD_DIR)/dfu-util_$(DFU-UTIL_VERSION)-$(DFU-UTIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dfu-util-source dfu-util-unpack dfu-util dfu-util-stage dfu-util-ipk dfu-util-clean dfu-util-dirclean dfu-util-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with SVN
#
$(DL_DIR)/dfu-util-$(DFU-UTIL_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(DFU-UTIL_DIR) && \
		svn co $(DFU-UTIL_REPOSITORY) $(DFU-UTIL_SVN_OPTS) $(DFU-UTIL_DIR) && \
		tar -czf $@ $(DFU-UTIL_DIR) && \
		rm -rf $(DFU-UTIL_DIR) \
	)

dfu-util-source: $(DL_DIR)/dfu-util-$(DFU-UTIL_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(DFU-UTIL_BUILD_DIR)/.configured: $(DL_DIR)/dfu-util-$(DFU-UTIL_VERSION).tar.gz
	$(MAKE) libusb-stage
	rm -rf $(BUILD_DIR)/$(DFU-UTIL_DIR) $(DFU-UTIL_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/dfu-util-$(DFU-UTIL_VERSION).tar.gz
	if test -n "$(DFU-UTIL_PATCHES)" ; \
		then cat $(DFU-UTIL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DFU-UTIL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DFU-UTIL_DIR)" != "$(DFU-UTIL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DFU-UTIL_DIR) $(DFU-UTIL_BUILD_DIR) ; \
	fi
	sed -i -e 's|\[config.h\]|config.h|g' $(DFU-UTIL_BUILD_DIR)/configure.ac
	(cd $(DFU-UTIL_BUILD_DIR); ./autogen.sh )
	(cd $(DFU-UTIL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DFU-UTIL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DFU-UTIL_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(DFU-UTIL_BUILD_DIR)/.configured

dfu-util-unpack: $(DFU-UTIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DFU-UTIL_BUILD_DIR)/.built: $(DFU-UTIL_BUILD_DIR)/.configured
	rm -f $(DFU-UTIL_BUILD_DIR)/.built
	$(MAKE) -C $(DFU-UTIL_BUILD_DIR) bin_PROGRAMS=dfu-util
	touch $(DFU-UTIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dfu-util: $(DFU-UTIL_BUILD_DIR)/.built

dfu-util-stage:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dfu-util
#
$(DFU-UTIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dfu-util" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DFU-UTIL_PRIORITY)" >>$@
	@echo "Section: $(DFU-UTIL_SECTION)" >>$@
	@echo "Version: $(DFU-UTIL_VERSION)-$(DFU-UTIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DFU-UTIL_MAINTAINER)" >>$@
	@echo "Source: $(DFU-UTIL_REPOSITORY)" >>$@
	@echo "Description: $(DFU-UTIL_DESCRIPTION)" >>$@
	@echo "Depends: $(DFU-UTIL_DEPENDS)" >>$@
	@echo "Suggests: $(DFU-UTIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(DFU-UTIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DFU-UTIL_IPK_DIR)/opt/sbin or $(DFU-UTIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DFU-UTIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DFU-UTIL_IPK_DIR)/opt/etc/dfu-util/...
# Documentation files should be installed in $(DFU-UTIL_IPK_DIR)/opt/doc/dfu-util/...
# Daemon startup scripts should be installed in $(DFU-UTIL_IPK_DIR)/opt/etc/init.d/S??dfu-util
#
# You may need to patch your application to make it use these locations.
#
$(DFU-UTIL_IPK): $(DFU-UTIL_BUILD_DIR)/.built
	rm -rf $(DFU-UTIL_IPK_DIR) $(BUILD_DIR)/dfu-util_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DFU-UTIL_BUILD_DIR) bin_PROGRAMS=dfu-util DESTDIR=$(DFU-UTIL_IPK_DIR) install
	$(MAKE) $(DFU-UTIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DFU-UTIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dfu-util-ipk: $(DFU-UTIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dfu-util-clean:
	rm -f $(DFU-UTIL_BUILD_DIR)/.built
	-$(MAKE) -C $(DFU-UTIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dfu-util-dirclean:
	rm -rf $(BUILD_DIR)/$(DFU-UTIL_DIR) $(DFU-UTIL_BUILD_DIR) $(DFU-UTIL_IPK_DIR) $(DFU-UTIL_IPK)

#
# Some sanity check for the package.
#
dfu-util-check: $(DFU-UTIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DFU-UTIL_IPK)
