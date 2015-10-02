###########################################################
#
# pthread-stubs
#
###########################################################

#
# PTHREAD-STUBS_VERSION, PTHREAD-STUBS_SITE and PTHREAD-STUBS_SOURCE define
# the upstream location of the source code for the package.
# PTHREAD-STUBS_DIR is the directory which is created when the source
# archive is unpacked.
#
PTHREAD-STUBS_SITE=http://xorg.freedesktop.org/releases/individual/lib
PTHREAD-STUBS_SOURCE=libpthread-stubs-$(PTHREAD-STUBS_VERSION).tar.gz
PTHREAD-STUBS_VERSION=0.1
PTHREAD-STUBS_DIR=libpthread-stubs-$(PTHREAD-STUBS_VERSION)
PTHREAD-STUBS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PTHREAD-STUBS_DESCRIPTION=X authorization library
PTHREAD-STUBS_SECTION=lib
PTHREAD-STUBS_PRIORITY=optional
PTHREAD-STUBS_DEPENDS=

#
# PTHREAD-STUBS_IPK_VERSION should be incremented when the ipk changes.
#
PTHREAD-STUBS_IPK_VERSION=1

#
# PTHREAD-STUBS_CONFFILES should be a list of user-editable files
PTHREAD-STUBS_CONFFILES=

#
# PTHREAD-STUBS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PTHREAD-STUBS_PATCHES=$(PTHREAD-STUBS_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PTHREAD-STUBS_CPPFLAGS=
PTHREAD-STUBS_LDFLAGS=

#
# PTHREAD-STUBS_BUILD_DIR is the directory in which the build is done.
# PTHREAD-STUBS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PTHREAD-STUBS_IPK_DIR is the directory in which the ipk is built.
# PTHREAD-STUBS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PTHREAD-STUBS_BUILD_DIR=$(BUILD_DIR)/pthread-stubs
PTHREAD-STUBS_SOURCE_DIR=$(SOURCE_DIR)/pthread-stubs
PTHREAD-STUBS_IPK_DIR=$(BUILD_DIR)/pthread-stubs-$(PTHREAD-STUBS_VERSION)-ipk
PTHREAD-STUBS_IPK=$(BUILD_DIR)/pthread-stubs_$(PTHREAD-STUBS_VERSION)-$(PTHREAD-STUBS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PTHREAD-STUBS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PTHREAD-STUBS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pthread-stubs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PTHREAD-STUBS_PRIORITY)" >>$@
	@echo "Section: $(PTHREAD-STUBS_SECTION)" >>$@
	@echo "Version: $(PTHREAD-STUBS_VERSION)-$(PTHREAD-STUBS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PTHREAD-STUBS_MAINTAINER)" >>$@
	@echo "Source: $(PTHREAD-STUBS_SITE)/$(PTHREAD-STUBS_SOURCE)" >>$@
	@echo "Description: $(PTHREAD-STUBS_DESCRIPTION)" >>$@
	@echo "Depends: $(PTHREAD-STUBS_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PTHREAD-STUBS_SOURCE):
	$(WGET) -P $(@D) $(PTHREAD-STUBS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

pthread-stubs-source: $(DL_DIR)/$(PTHREAD-STUBS_SOURCE) $(PTHREAD-STUBS_PATCHES)

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
$(PTHREAD-STUBS_BUILD_DIR)/.configured: $(DL_DIR)/$(PTHREAD-STUBS_SOURCE) $(PTHREAD-STUBS_PATCHES) make/pthread-stubs.mk
	$(MAKE) xproto-stage
	rm -rf $(BUILD_DIR)/$(PTHREAD-STUBS_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(PTHREAD-STUBS_SOURCE)
	if test -n "$(PTHREAD-STUBS_PATCHES)" ; \
		then cat $(PTHREAD-STUBS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PTHREAD-STUBS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PTHREAD-STUBS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PTHREAD-STUBS_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PTHREAD-STUBS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PTHREAD-STUBS_LDFLAGS)" \
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

pthread-stubs-unpack: $(PTHREAD-STUBS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PTHREAD-STUBS_BUILD_DIR)/.built: $(PTHREAD-STUBS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pthread-stubs: $(PTHREAD-STUBS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PTHREAD-STUBS_BUILD_DIR)/.staged: $(PTHREAD-STUBS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/pthread-stubs.pc
	rm -f $(STAGING_LIB_DIR)/libPTHREAD-STUBS.la
	touch $@

pthread-stubs-stage: $(PTHREAD-STUBS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PTHREAD-STUBS_IPK_DIR)/opt/sbin or $(PTHREAD-STUBS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PTHREAD-STUBS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PTHREAD-STUBS_IPK_DIR)/opt/etc/pthread-stubs/...
# Documentation files should be installed in $(PTHREAD-STUBS_IPK_DIR)/opt/doc/pthread-stubs/...
# Daemon startup scripts should be installed in $(PTHREAD-STUBS_IPK_DIR)/opt/etc/init.d/S??pthread-stubs
#
# You may need to patch your application to make it use these locations.
#
$(PTHREAD-STUBS_IPK): $(PTHREAD-STUBS_BUILD_DIR)/.built
	rm -rf $(PTHREAD-STUBS_IPK_DIR) $(BUILD_DIR)/pthread-stubs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PTHREAD-STUBS_BUILD_DIR) DESTDIR=$(PTHREAD-STUBS_IPK_DIR) install-strip
	$(MAKE) $(PTHREAD-STUBS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(PTHREAD-STUBS_SOURCE_DIR)/postinst $(PTHREAD-STUBS_IPK_DIR)/CONTROL/postinst
	rm -f $(PTHREAD-STUBS_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PTHREAD-STUBS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pthread-stubs-ipk: $(PTHREAD-STUBS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pthread-stubs-clean:
	-$(MAKE) -C $(PTHREAD-STUBS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pthread-stubs-dirclean:
	rm -rf $(BUILD_DIR)/$(PTHREAD-STUBS_DIR) $(PTHREAD-STUBS_BUILD_DIR) $(PTHREAD-STUBS_IPK_DIR) $(PTHREAD-STUBS_IPK)
