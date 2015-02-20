###########################################################
#
# xextproto
#
###########################################################

#
# XEXTPROTO_VERSION, XEXTPROTO_SITE and XEXTPROTO_SOURCE define
# the upstream location of the source code for the package.
# XEXTPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# XEXTPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XEXTPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
XEXTPROTO_SOURCE=xextproto-$(XEXTPROTO_VERSION).tar.gz
XEXTPROTO_VERSION=7.3.0
XEXTPROTO_DIR=xextproto-$(XEXTPROTO_VERSION)
XEXTPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XEXTPROTO_DESCRIPTION=X Protocol Extensions
XEXTPROTO_SECTION=lib
XEXTPROTO_PRIORITY=optional

#
# XEXTPROTO_IPK_VERSION should be incremented when the ipk changes.
#
XEXTPROTO_IPK_VERSION=1

#
# XEXTPROTO_CONFFILES should be a list of user-editable files
XEXTPROTO_CONFFILES=

#
# XEXTPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XEXTPROTO_PATCHES=$(XEXTPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XEXTPROTO_CPPFLAGS=
XEXTPROTO_LDFLAGS=

#
# XEXTPROTO_BUILD_DIR is the directory in which the build is done.
# XEXTPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XEXTPROTO_IPK_DIR is the directory in which the ipk is built.
# XEXTPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XEXTPROTO_BUILD_DIR=$(BUILD_DIR)/xextproto
XEXTPROTO_SOURCE_DIR=$(SOURCE_DIR)/xextproto
XEXTPROTO_IPK_DIR=$(BUILD_DIR)/xextproto-$(XEXTPROTO_VERSION)-ipk
XEXTPROTO_IPK=$(BUILD_DIR)/xextproto_$(XEXTPROTO_VERSION)-$(XEXTPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XEXTPROTO_IPK_DIR)/CONTROL/control:
	@install -d $(XEXTPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xextproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XEXTPROTO_PRIORITY)" >>$@
	@echo "Section: $(XEXTPROTO_SECTION)" >>$@
	@echo "Version: $(XEXTPROTO_VERSION)-$(XEXTPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XEXTPROTO_MAINTAINER)" >>$@
	@echo "Source: $(XEXTPROTO_SITE)/$(XEXTPROTO_SOURCE)" >>$@
	@echo "Description: $(XEXTPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XEXTPROTO_SOURCE):
	$(WGET) -P $(@D) $(XEXTPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xextproto-source: $(DL_DIR)/$(XEXTPROTO_SOURCE) $(XEXTPROTO_PATCHES)

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
$(XEXTPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(XEXTPROTO_SOURCE) $(XEXTPROTO_PATCHES) make/xextproto.mk
	rm -rf $(BUILD_DIR)/$(XEXTPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XEXTPROTO_SOURCE)
	if test -n "$(XEXTPROTO_PATCHES)" ; \
		then cat $(XEXTPROTO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XEXTPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XEXTPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XEXTPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XEXTPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XEXTPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

xextproto-unpack: $(XEXTPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XEXTPROTO_BUILD_DIR)/.built: $(XEXTPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xextproto: $(XEXTPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XEXTPROTO_BUILD_DIR)/.staged: $(XEXTPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xextproto.pc
	touch $@

xextproto-stage: $(XEXTPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XEXTPROTO_IPK_DIR)/opt/sbin or $(XEXTPROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XEXTPROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XEXTPROTO_IPK_DIR)/opt/etc/xextproto/...
# Documentation files should be installed in $(XEXTPROTO_IPK_DIR)/opt/doc/xextproto/...
# Daemon startup scripts should be installed in $(XEXTPROTO_IPK_DIR)/opt/etc/init.d/S??xextproto
#
# You may need to patch your application to make it use these locations.
#
$(XEXTPROTO_IPK): $(XEXTPROTO_BUILD_DIR)/.built
	rm -rf $(XEXTPROTO_IPK_DIR) $(BUILD_DIR)/xextproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XEXTPROTO_BUILD_DIR) DESTDIR=$(XEXTPROTO_IPK_DIR) install
	$(MAKE) $(XEXTPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XEXTPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xextproto-ipk: $(XEXTPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xextproto-clean:
	-$(MAKE) -C $(XEXTPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xextproto-dirclean:
	rm -rf $(BUILD_DIR)/$(XEXTPROTO_DIR) $(XEXTPROTO_BUILD_DIR) $(XEXTPROTO_IPK_DIR) $(XEXTPROTO_IPK)
