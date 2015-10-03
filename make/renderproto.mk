###########################################################
#
# renderproto
#
###########################################################

#
# RENDERPROTO_VERSION, RENDERPROTO_SITE and RENDERPROTO_SOURCE define
# the upstream location of the source code for the package.
# RENDERPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# RENDERPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
RENDERPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
RENDERPROTO_SOURCE=renderproto-$(RENDERPROTO_VERSION).tar.gz
RENDERPROTO_VERSION=0.11
RENDERPROTO_DIR=renderproto-$(RENDERPROTO_VERSION)
RENDERPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RENDERPROTO_DESCRIPTION=X Render Protocol Headers
RENDERPROTO_SECTION=lib
RENDERPROTO_PRIORITY=optional

#
# RENDERPROTO_IPK_VERSION should be incremented when the ipk changes.
#
RENDERPROTO_IPK_VERSION=1

#
# RENDERPROTO_CONFFILES should be a list of user-editable files
RENDERPROTO_CONFFILES=

#
# RENDERPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RENDERPROTO_PATCHES=$(RENDERPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RENDERPROTO_CPPFLAGS=
RENDERPROTO_LDFLAGS=

#
# RENDERPROTO_BUILD_DIR is the directory in which the build is done.
# RENDERPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RENDERPROTO_IPK_DIR is the directory in which the ipk is built.
# RENDERPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RENDERPROTO_BUILD_DIR=$(BUILD_DIR)/renderproto
RENDERPROTO_SOURCE_DIR=$(SOURCE_DIR)/renderproto
RENDERPROTO_IPK_DIR=$(BUILD_DIR)/renderproto-$(RENDERPROTO_VERSION)-ipk
RENDERPROTO_IPK=$(BUILD_DIR)/renderproto_$(RENDERPROTO_VERSION)-$(RENDERPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(RENDERPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(RENDERPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: renderproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RENDERPROTO_PRIORITY)" >>$@
	@echo "Section: $(RENDERPROTO_SECTION)" >>$@
	@echo "Version: $(RENDERPROTO_VERSION)-$(RENDERPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RENDERPROTO_MAINTAINER)" >>$@
	@echo "Source: $(RENDERPROTO_SITE)/$(RENDERPROTO_SOURCE)" >>$@
	@echo "Description: $(RENDERPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RENDERPROTO_SOURCE):
	$(WGET) -P $(@D) $(RENDERPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

renderproto-source: $(DL_DIR)/$(RENDERPROTO_SOURCE) $(RENDERPROTO_PATCHES)

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
$(RENDERPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(RENDERPROTO_SOURCE) $(RENDERPROTO_PATCHES) make/renderproto.mk
	rm -rf $(BUILD_DIR)/$(RENDERPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(RENDERPROTO_SOURCE)
	if test -n "$(RENDERPROTO_PATCHES)" ; \
		then cat $(RENDERPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RENDERPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RENDERPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RENDERPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RENDERPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RENDERPROTO_LDFLAGS)" \
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

renderproto-unpack: $(RENDERPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RENDERPROTO_BUILD_DIR)/.built: $(RENDERPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
renderproto: $(RENDERPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RENDERPROTO_BUILD_DIR)/.staged: $(RENDERPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/renderproto.pc
	touch $@

renderproto-stage: $(RENDERPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/renderproto/...
# Documentation files should be installed in $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/renderproto/...
# Daemon startup scripts should be installed in $(RENDERPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??renderproto
#
# You may need to patch your application to make it use these locations.
#
$(RENDERPROTO_IPK): $(RENDERPROTO_BUILD_DIR)/.built
	rm -rf $(RENDERPROTO_IPK_DIR) $(BUILD_DIR)/renderproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RENDERPROTO_BUILD_DIR) DESTDIR=$(RENDERPROTO_IPK_DIR) install
	$(MAKE) $(RENDERPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RENDERPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
renderproto-ipk: $(RENDERPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
renderproto-clean:
	-$(MAKE) -C $(RENDERPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
renderproto-dirclean:
	rm -rf $(BUILD_DIR)/$(RENDERPROTO_DIR) $(RENDERPROTO_BUILD_DIR) $(RENDERPROTO_IPK_DIR) $(RENDERPROTO_IPK)
