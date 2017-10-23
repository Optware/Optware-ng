###########################################################
#
# libusb1
#
###########################################################

# You must replace "libusb1" and "LIBUSB1" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBUSB1_VERSION, LIBUSB1_SITE and LIBUSB1_SOURCE define
# the upstream location of the source code for the package.
# LIBUSB1_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUSB1_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#

LIBUSB1_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libusb
LIBUSB1_VERSION:=1.0.19
LIBUSB1_SOURCE=libusb-$(LIBUSB1_VERSION).tar.bz2
LIBUSB1_DIR=libusb-$(LIBUSB1_VERSION)
LIBUSB1_UNZIP=bzcat
LIBUSB1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUSB1_DESCRIPTION=Library for interfacing to the USB subsystem.
LIBUSB1_SECTION=libs
LIBUSB1_PRIORITY=optional
LIBUSB1_DEPENDS=
LIBUSB1_SUGGESTS=
LIBUSB1_CONFLICTS=

#
# LIBUSB1_IPK_VERSION should be incremented when the ipk changes.
#
LIBUSB1_IPK_VERSION=2
#
# LIBUSB1_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBUSB1_PATCHES=$(LIBUSB1_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUSB1_CPPFLAGS=
LIBUSB1_LDFLAGS=

#
# LIBUSB1_BUILD_DIR is the directory in which the build is done.
# LIBUSB1_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUSB1_IPK_DIR is the directory in which the ipk is built.
# LIBUSB1_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUSB1_BUILD_DIR=$(BUILD_DIR)/libusb1
LIBUSB1_SOURCE_DIR=$(SOURCE_DIR)/libusb1
LIBUSB1_IPK_DIR=$(BUILD_DIR)/libusb1-$(LIBUSB1_VERSION)-ipk
LIBUSB1_IPK=$(BUILD_DIR)/libusb1_$(LIBUSB1_VERSION)-$(LIBUSB1_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libusb1-source libusb1-unpack libusb1 libusb1-stage libusb1-ipk libusb1-clean libusb1-dirclean libusb1-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBUSB1_SOURCE):
	$(WGET) -P $(@D) $(LIBUSB1_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libusb1-source: $(DL_DIR)/$(LIBUSB1_SOURCE)

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
$(LIBUSB1_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUSB1_SOURCE) $(LIBUSB1_PATCHES) make/libusb1.mk
	rm -rf $(BUILD_DIR)/$(LIBUSB1_DIR) $(@D)
	$(LIBUSB1_UNZIP) $(DL_DIR)/$(LIBUSB1_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(LIBUSB1_PATCHES)"; then \
		cat $(LIBUSB1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(LIBUSB1_DIR) -p1; \
	fi
	if test "$(BUILD_DIR)/$(LIBUSB1_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUSB1_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUSB1_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUSB1_LDFLAGS)" \
		./configure \
		--enable-shared \
		--disable-static \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-build-docs \
		--disable-udev \
		--prefix=$(TARGET_PREFIX) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libusb1-unpack: $(LIBUSB1_BUILD_DIR)/.configured

$(LIBUSB1_BUILD_DIR)/.built: $(LIBUSB1_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBUSB1_BUILD_DIR)
	touch $@

libusb1: $(LIBUSB1_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUSB1_BUILD_DIR)/.staged: $(LIBUSB1_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBUSB1_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libusb-1.0.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libusb-1.0.pc
	touch $@

libusb1-stage: $(LIBUSB1_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libusb1
#
$(LIBUSB1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libusb1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUSB1_PRIORITY)" >>$@
	@echo "Section: $(LIBUSB1_SECTION)" >>$@
	@echo "Version: $(LIBUSB1_VERSION)-$(LIBUSB1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUSB1_MAINTAINER)" >>$@
	@echo "Source: $(LIBUSB1_SITE)/$(LIBUSB1_SOURCE)" >>$@
	@echo "Description: $(LIBUSB1_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUSB1_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUSB1_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUSB1_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/etc/libusb1/...
# Documentation files should be installed in $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/doc/libusb1/...
# Daemon startup scripts should be installed in $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libusb1
#
# You may need to patch your application to make it use these locations.
#
$(LIBUSB1_IPK): $(LIBUSB1_BUILD_DIR)/.built
	rm -rf $(LIBUSB1_IPK_DIR) $(BUILD_DIR)/libusb1_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUSB1_BUILD_DIR) DESTDIR=$(LIBUSB1_IPK_DIR) install-strip
	rm -rf $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/lib/*.la $(LIBUSB1_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(MAKE) $(LIBUSB1_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUSB1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libusb1-ipk: $(LIBUSB1_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libusb1-clean:
	-$(MAKE) -C $(LIBUSB1_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libusb1-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUSB1_DIR) $(LIBUSB1_BUILD_DIR) $(LIBUSB1_IPK_DIR) $(LIBUSB1_IPK)

#
# Some sanity check for the package.
#
libusb1-check: $(LIBUSB1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
