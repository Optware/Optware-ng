###########################################################
#
# xtst
#
###########################################################

#
# XTST_VERSION, XTST_SITE and XTST_SOURCE define
# the upstream location of the source code for the package.
# XTST_DIR is the directory which is created when the source
# archive is unpacked.
#
XTST_SITE=http://xorg.freedesktop.org/releases/individual/lib
XTST_SOURCE=libXtst-$(XTST_VERSION).tar.gz
XTST_VERSION=1.2.2
XTST_FULL_VERSION=release-$(XTST_VERSION)
XTST_DIR=libXtst-$(XTST_VERSION)
XTST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XTST_DESCRIPTION=X test library
XTST_SECTION=lib
XTST_PRIORITY=optional
XTST_DEPENDS=x11, xext, xi

#
# XTST_IPK_VERSION should be incremented when the ipk changes.
#
XTST_IPK_VERSION=2

#
# XTST_CONFFILES should be a list of user-editable files
XTST_CONFFILES=

#
# XTST_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XTST_PATCHES=$(XTST_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XTST_CPPFLAGS=
XTST_LDFLAGS=

#
# XTST_BUILD_DIR is the directory in which the build is done.
# XTST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XTST_IPK_DIR is the directory in which the ipk is built.
# XTST_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XTST_BUILD_DIR=$(BUILD_DIR)/xtst
XTST_SOURCE_DIR=$(SOURCE_DIR)/xtst
XTST_IPK_DIR=$(BUILD_DIR)/xtst-$(XTST_FULL_VERSION)-ipk
XTST_IPK=$(BUILD_DIR)/xtst_$(XTST_FULL_VERSION)-$(XTST_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XTST_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XTST_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xtst" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XTST_PRIORITY)" >>$@
	@echo "Section: $(XTST_SECTION)" >>$@
	@echo "Version: $(XTST_FULL_VERSION)-$(XTST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XTST_MAINTAINER)" >>$@
	@echo "Source: $(XTST_SITE)/$(XTST_SOURCE)" >>$@
	@echo "Description: $(XTST_DESCRIPTION)" >>$@
	@echo "Depends: $(XTST_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XTST_SOURCE):
	$(WGET) -P $(@D) $(XTST_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xtst-source: $(DL_DIR)/$(XTST_SOURCE) $(XTST_PATCHES)

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
$(XTST_BUILD_DIR)/.configured: $(DL_DIR)/$(XTST_SOURCE) $(XTST_PATCHES) make/xtst.mk
	$(MAKE) xorg-macros-stage x11-stage xext-stage xi-stage \
		recordproto-stage xextproto-stage inputproto-stage
	rm -rf $(BUILD_DIR)/$(XTST_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XTST_SOURCE)
	if test -n "$(XTST_PATCHES)" ; \
		then cat $(XTST_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XTST_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XTST_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XTST_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XTST_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XTST_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--enable-malloc0returnsnull \
	)
	touch $@

xtst-unpack: $(XTST_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XTST_BUILD_DIR)/.built: $(XTST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xtst: $(XTST_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XTST_BUILD_DIR)/.staged: $(XTST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xtst.pc
	rm -f $(STAGING_LIB_DIR)/libXtst.la
	touch $@

xtst-stage: $(XTST_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XTST_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XTST_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XTST_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XTST_IPK_DIR)$(TARGET_PREFIX)/etc/xtst/...
# Documentation files should be installed in $(XTST_IPK_DIR)$(TARGET_PREFIX)/doc/xtst/...
# Daemon startup scripts should be installed in $(XTST_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xtst
#
# You may need to patch your application to make it use these locations.
#
$(XTST_IPK): $(XTST_BUILD_DIR)/.built
	rm -rf $(XTST_IPK_DIR) $(BUILD_DIR)/xtst_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XTST_BUILD_DIR) DESTDIR=$(XTST_IPK_DIR) install-strip
	$(MAKE) $(XTST_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(XTST_SOURCE_DIR)/postinst $(XTST_IPK_DIR)/CONTROL/postinst
	rm -f $(XTST_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XTST_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xtst-ipk: $(XTST_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xtst-clean:
	-$(MAKE) -C $(XTST_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xtst-dirclean:
	rm -rf $(BUILD_DIR)/$(XTST_DIR) $(XTST_BUILD_DIR) $(XTST_IPK_DIR) $(XTST_IPK)
