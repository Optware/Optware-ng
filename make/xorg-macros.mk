###########################################################
#
# xorg-macros
#
###########################################################

#
# XORG-MACROS_VERSION, XORG-MACROS_SITE and XORG-MACROS_SOURCE define
# the upstream location of the source code for the package.
# XORG-MACROS_DIR is the directory which is created when the source
# archive is unpacked.
# XORG-MACROS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XORG-MACROS_SITE=http://xorg.freedesktop.org/releases/individual/util
XORG-MACROS_SOURCE=util-macros-$(XORG-MACROS_VERSION).tar.gz
XORG-MACROS_VERSION=1.19.0
XORG-MACROS_DIR=util-macros-$(XORG-MACROS_VERSION)
XORG-MACROS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XORG-MACROS_DESCRIPTION=Xorg autoconf macros
XORG-MACROS_SECTION=lib
XORG-MACROS_PRIORITY=optional

#
# XORG-MACROS_IPK_VERSION should be incremented when the ipk changes.
#
XORG-MACROS_IPK_VERSION=1

#
# XORG-MACROS_CONFFILES should be a list of user-editable files
XORG-MACROS_CONFFILES=

#
# XORG-MACROS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XORG-MACROS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XORG-MACROS_CPPFLAGS=
XORG-MACROS_LDFLAGS=

#
# XORG-MACROS_BUILD_DIR is the directory in which the build is done.
# XORG-MACROS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XORG-MACROS_IPK_DIR is the directory in which the ipk is built.
# XORG-MACROS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XORG-MACROS_BUILD_DIR=$(BUILD_DIR)/xorg-macros
XORG-MACROS_SOURCE_DIR=$(SOURCE_DIR)/xorg-macros
XORG-MACROS_IPK_DIR=$(BUILD_DIR)/xorg-macros-$(XORG-MACROS_VERSION)-ipk
XORG-MACROS_IPK=$(BUILD_DIR)/xorg-macros_$(XORG-MACROS_VERSION)-$(XORG-MACROS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XORG-MACROS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XORG-MACROS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xorg-macros" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XORG-MACROS_PRIORITY)" >>$@
	@echo "Section: $(XORG-MACROS_SECTION)" >>$@
	@echo "Version: $(XORG-MACROS_VERSION)-$(XORG-MACROS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XORG-MACROS_MAINTAINER)" >>$@
	@echo "Source: $(XORG-MACROS_SITE)/$(XORG-MACROS_SOURCE)" >>$@
	@echo "Description: $(XORG-MACROS_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XORG-MACROS_SOURCE):
	$(WGET) -P $(@D) $(XORG-MACROS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xorg-macros-source: $(DL_DIR)/$(XORG-MACROS_SOURCE) $(XORG-MACROS_PATCHES)

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
$(XORG-MACROS_BUILD_DIR)/.configured: $(DL_DIR)/$(XORG-MACROS_SOURCE) $(XORG-MACROS_PATCHES) make/xorg-macros.mk
	rm -rf $(BUILD_DIR)/$(XORG-MACROS_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XORG-MACROS_SOURCE)
	if test -n "$(XORG-MACROS_PATCHES)" ; \
		then cat $(XORG-MACROS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XORG-MACROS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XORG-MACROS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XORG-MACROS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XORG-MACROS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XORG-MACROS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $@

xorg-macros-unpack: $(XORG-MACROS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XORG-MACROS_BUILD_DIR)/.built: $(XORG-MACROS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xorg-macros: $(XORG-MACROS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XORG-MACROS_BUILD_DIR)/.staged: $(XORG-MACROS_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	mv -f $(STAGING_PREFIX)/share/pkgconfig/xorg-macros.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xorg-macros.pc
	touch $@

xorg-macros-stage: $(XORG-MACROS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XORG-MACROS_IPK_DIR)/opt/sbin or $(XORG-MACROS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XORG-MACROS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XORG-MACROS_IPK_DIR)/opt/etc/xorg-macros/...
# Documentation files should be installed in $(XORG-MACROS_IPK_DIR)/opt/doc/xorg-macros/...
# Daemon startup scripts should be installed in $(XORG-MACROS_IPK_DIR)/opt/etc/init.d/S??xorg-macros
#
# You may need to patch your application to make it use these locations.
#
$(XORG-MACROS_IPK): $(XORG-MACROS_BUILD_DIR)/.built
	rm -rf $(XORG-MACROS_IPK_DIR) $(BUILD_DIR)/xorg-macros_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XORG-MACROS_BUILD_DIR) DESTDIR=$(XORG-MACROS_IPK_DIR) install
	mv -f $(XORG-MACROS_IPK_DIR)/opt/share/pkgconfig $(XORG-MACROS_IPK_DIR)/opt/lib
	$(MAKE) $(XORG-MACROS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XORG-MACROS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xorg-macros-ipk: $(XORG-MACROS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xorg-macros-clean:
	-$(MAKE) -C $(XORG-MACROS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xorg-macros-dirclean:
	rm -rf $(BUILD_DIR)/$(XORG-MACROS_DIR) $(XORG-MACROS_BUILD_DIR) $(XORG-MACROS_IPK_DIR) $(XORG-MACROS_IPK)
