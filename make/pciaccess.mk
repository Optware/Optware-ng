###########################################################
#
# pciaccess
#
###########################################################

#
# PCIACCESS_VERSION, PCIACCESS_SITE and PCIACCESS_SOURCE define
# the upstream location of the source code for the package.
# PCIACCESS_DIR is the directory which is created when the source
# archive is unpacked.
#
PCIACCESS_SITE=http://xorg.freedesktop.org/releases/individual/lib
PCIACCESS_SOURCE=libpciaccess-$(PCIACCESS_VERSION).tar.gz
PCIACCESS_VERSION=0.13.3
PCIACCESS_FULL_VERSION=$(PCIACCESS_VERSION)
PCIACCESS_DIR=libpciaccess-$(PCIACCESS_VERSION)
PCIACCESS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCIACCESS_DESCRIPTION=Generic PCI access library for X
PCIACCESS_SECTION=lib
PCIACCESS_PRIORITY=optional
PCIACCESS_DEPENDS=

#
# PCIACCESS_IPK_VERSION should be incremented when the ipk changes.
#
PCIACCESS_IPK_VERSION=1

#
# PCIACCESS_CONFFILES should be a list of user-editable files
PCIACCESS_CONFFILES=

#
# PCIACCESS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PCIACCESS_PATCHES=$(PCIACCESS_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCIACCESS_CPPFLAGS=
PCIACCESS_LDFLAGS=

#
# PCIACCESS_BUILD_DIR is the directory in which the build is done.
# PCIACCESS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCIACCESS_IPK_DIR is the directory in which the ipk is built.
# PCIACCESS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCIACCESS_BUILD_DIR=$(BUILD_DIR)/pciaccess
PCIACCESS_SOURCE_DIR=$(SOURCE_DIR)/pciaccess
PCIACCESS_IPK_DIR=$(BUILD_DIR)/pciaccess-$(PCIACCESS_FULL_VERSION)-ipk
PCIACCESS_IPK=$(BUILD_DIR)/pciaccess_$(PCIACCESS_FULL_VERSION)-$(PCIACCESS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PCIACCESS_IPK_DIR)/CONTROL/control:
	@install -d $(PCIACCESS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pciaccess" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCIACCESS_PRIORITY)" >>$@
	@echo "Section: $(PCIACCESS_SECTION)" >>$@
	@echo "Version: $(PCIACCESS_FULL_VERSION)-$(PCIACCESS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCIACCESS_MAINTAINER)" >>$@
	@echo "Source: $(PCIACCESS_SITE)/$(PCIACCESS_SOURCE)" >>$@
	@echo "Description: $(PCIACCESS_DESCRIPTION)" >>$@
	@echo "Depends: $(PCIACCESS_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCIACCESS_SOURCE):
	$(WGET) -P $(@D) $(PCIACCESS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

pciaccess-source: $(DL_DIR)/$(PCIACCESS_SOURCE) $(PCIACCESS_PATCHES)

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(PCIACCESS_BUILD_DIR)/.configured: $(DL_DIR)/$(PCIACCESS_SOURCE) $(PCIACCESS_PATCHES) make/pciaccess.mk
	$(MAKE) xorg-macros-stage
	rm -rf $(BUILD_DIR)/$(PCIACCESS_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(PCIACCESS_SOURCE)
	if test -n "$(PCIACCESS_PATCHES)" ; \
		then cat $(PCIACCESS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PCIACCESS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PCIACCESS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PCIACCESS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PCIACCESS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PCIACCESS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

pciaccess-unpack: $(PCIACCESS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCIACCESS_BUILD_DIR)/.built: $(PCIACCESS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pciaccess: $(PCIACCESS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCIACCESS_BUILD_DIR)/.staged: $(PCIACCESS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/pciaccess.pc
	rm -f $(STAGING_LIB_DIR)/libpciaccess.la
	touch $@

pciaccess-stage: $(PCIACCESS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCIACCESS_IPK_DIR)/opt/sbin or $(PCIACCESS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCIACCESS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PCIACCESS_IPK_DIR)/opt/etc/pciaccess/...
# Documentation files should be installed in $(PCIACCESS_IPK_DIR)/opt/doc/pciaccess/...
# Daemon startup scripts should be installed in $(PCIACCESS_IPK_DIR)/opt/etc/init.d/S??pciaccess
#
# You may need to patch your application to make it use these locations.
#
$(PCIACCESS_IPK): $(PCIACCESS_BUILD_DIR)/.built
	rm -rf $(PCIACCESS_IPK_DIR) $(BUILD_DIR)/pciaccess_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCIACCESS_BUILD_DIR) DESTDIR=$(PCIACCESS_IPK_DIR) install-strip
	$(MAKE) $(PCIACCESS_IPK_DIR)/CONTROL/control
#	install -m 644 $(PCIACCESS_SOURCE_DIR)/postinst $(PCIACCESS_IPK_DIR)/CONTROL/postinst
	rm -f $(PCIACCESS_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCIACCESS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pciaccess-ipk: $(PCIACCESS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pciaccess-clean:
	-$(MAKE) -C $(PCIACCESS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pciaccess-dirclean:
	rm -rf $(BUILD_DIR)/$(PCIACCESS_DIR) $(PCIACCESS_BUILD_DIR) $(PCIACCESS_IPK_DIR) $(PCIACCESS_IPK)
