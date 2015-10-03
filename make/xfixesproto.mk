###########################################################
#
# xfixesproto
#
###########################################################

#
# XFIXESPROTO_VERSION, XFIXESPROTO_SITE and XFIXESPROTO_SOURCE define
# the upstream location of the source code for the package.
# XFIXESPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# XFIXESPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XFIXESPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
XFIXESPROTO_SOURCE=fixesproto-$(XFIXESPROTO_VERSION).tar.gz
XFIXESPROTO_VERSION=3.0.2
XFIXESPROTO_DIR=fixesproto-$(XFIXESPROTO_VERSION)
XFIXESPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XFIXESPROTO_DESCRIPTION=X fixes headers
XFIXESPROTO_SECTION=lib
XFIXESPROTO_PRIORITY=optional

#
# XFIXESPROTO_IPK_VERSION should be incremented when the ipk changes.
#
XFIXESPROTO_IPK_VERSION=1

#
# XFIXESPROTO_CONFFILES should be a list of user-editable files
XFIXESPROTO_CONFFILES=

#
# XFIXESPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XFIXESPROTO_PATCHES=$(XFIXESPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XFIXESPROTO_CPPFLAGS=
XFIXESPROTO_LDFLAGS=

#
# XFIXESPROTO_BUILD_DIR is the directory in which the build is done.
# XFIXESPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XFIXESPROTO_IPK_DIR is the directory in which the ipk is built.
# XFIXESPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XFIXESPROTO_BUILD_DIR=$(BUILD_DIR)/xfixesproto
XFIXESPROTO_SOURCE_DIR=$(SOURCE_DIR)/xfixesproto
XFIXESPROTO_IPK_DIR=$(BUILD_DIR)/xfixesproto-$(XFIXESPROTO_VERSION)-ipk
XFIXESPROTO_IPK=$(BUILD_DIR)/xfixesproto_$(XFIXESPROTO_VERSION)-$(XFIXESPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XFIXESPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XFIXESPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xfixesproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XFIXESPROTO_PRIORITY)" >>$@
	@echo "Section: $(XFIXESPROTO_SECTION)" >>$@
	@echo "Version: $(XFIXESPROTO_VERSION)-$(XFIXESPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XFIXESPROTO_MAINTAINER)" >>$@
	@echo "Source: $(XFIXESPROTO_SITE)/$(XFIXESPROTO_SOURCE)" >>$@
	@echo "Description: $(XFIXESPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XFIXESPROTO_SOURCE):
	$(WGET) -P $(@D) $(XFIXESPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xfixesproto-source: $(DL_DIR)/$(XFIXESPROTO_SOURCE) $(XFIXESPROTO_PATCHES)

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
$(XFIXESPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(XFIXESPROTO_SOURCE) $(XFIXESPROTO_PATCHES) make/xfixesproto.mk
	rm -rf $(BUILD_DIR)/$(XFIXESPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(XFIXESPROTO_SOURCE)
	if test -n "$(XFIXESPROTO_PATCHES)" ; \
		then cat $(XFIXESPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XFIXESPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XFIXESPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XFIXESPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XFIXESPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XFIXESPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	touch $@

xfixesproto-unpack: $(XFIXESPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XFIXESPROTO_BUILD_DIR)/.built: $(XFIXESPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xfixesproto: $(XFIXESPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XFIXESPROTO_BUILD_DIR)/.staged: $(XFIXESPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/fixesproto.pc
	touch $@

xfixesproto-stage: $(XFIXESPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XFIXESPROTO_IPK_DIR)/opt/sbin or $(XFIXESPROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XFIXESPROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XFIXESPROTO_IPK_DIR)/opt/etc/xfixesproto/...
# Documentation files should be installed in $(XFIXESPROTO_IPK_DIR)/opt/doc/xfixesproto/...
# Daemon startup scripts should be installed in $(XFIXESPROTO_IPK_DIR)/opt/etc/init.d/S??xfixesproto
#
# You may need to patch your application to make it use these locations.
#
$(XFIXESPROTO_IPK): $(XFIXESPROTO_BUILD_DIR)/.built
	rm -rf $(XFIXESPROTO_IPK_DIR) $(BUILD_DIR)/xfixesproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XFIXESPROTO_BUILD_DIR) DESTDIR=$(XFIXESPROTO_IPK_DIR) install
	$(MAKE) $(XFIXESPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XFIXESPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xfixesproto-ipk: $(XFIXESPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xfixesproto-clean:
	-$(MAKE) -C $(XFIXESPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xfixesproto-dirclean:
	rm -rf $(BUILD_DIR)/$(XFIXESPROTO_DIR) $(XFIXESPROTO_BUILD_DIR) $(XFIXESPROTO_IPK_DIR) $(XFIXESPROTO_IPK)
