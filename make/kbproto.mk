###########################################################
#
# kbproto
#
###########################################################

#
# KBPROTO_VERSION, KBPROTO_SITE and KBPROTO_SOURCE define
# the upstream location of the source code for the package.
# KBPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# KBPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
KBPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
KBPROTO_SOURCE=kbproto-$(KBPROTO_VERSION).tar.gz
KBPROTO_VERSION=1.0.6
KBPROTO_DIR=kbproto-$(KBPROTO_VERSION)
KBPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
KBPROTO_DESCRIPTION=X Keyboard Extension
KBPROTO_SECTION=lib
KBPROTO_PRIORITY=optional

#
# KBPROTO_IPK_VERSION should be incremented when the ipk changes.
#
KBPROTO_IPK_VERSION=1

#
# KBPROTO_CONFFILES should be a list of user-editable files
KBPROTO_CONFFILES=

#
# KBPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
KBPROTO_PATCHES=$(KBPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KBPROTO_CPPFLAGS=
KBPROTO_LDFLAGS=

#
# KBPROTO_BUILD_DIR is the directory in which the build is done.
# KBPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KBPROTO_IPK_DIR is the directory in which the ipk is built.
# KBPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KBPROTO_BUILD_DIR=$(BUILD_DIR)/kbproto
KBPROTO_SOURCE_DIR=$(SOURCE_DIR)/kbproto
KBPROTO_IPK_DIR=$(BUILD_DIR)/kbproto-$(KBPROTO_VERSION)-ipk
KBPROTO_IPK=$(BUILD_DIR)/kbproto_$(KBPROTO_VERSION)-$(KBPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(KBPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(KBPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: kbproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KBPROTO_PRIORITY)" >>$@
	@echo "Section: $(KBPROTO_SECTION)" >>$@
	@echo "Version: $(KBPROTO_VERSION)-$(KBPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KBPROTO_MAINTAINER)" >>$@
	@echo "Source: $(KBPROTO_SITE)/$(KBPROTO_SOURCE)" >>$@
	@echo "Description: $(KBPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KBPROTO_SOURCE):
	$(WGET) -P $(@D) $(KBPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

kbproto-source: $(DL_DIR)/$(KBPROTO_SOURCE) $(KBPROTO_PATCHES)

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
$(KBPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(KBPROTO_SOURCE) $(KBPROTO_PATCHES) make/kbproto.mk
	rm -rf $(BUILD_DIR)/$(KBPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(KBPROTO_SOURCE)
	if test -n "$(KBPROTO_PATCHES)" ; \
		then cat $(KBPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(KBPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(KBPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(KBPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KBPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KBPROTO_LDFLAGS)" \
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

kbproto-unpack: $(KBPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KBPROTO_BUILD_DIR)/.built: $(KBPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
kbproto: $(KBPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KBPROTO_BUILD_DIR)/.staged: $(KBPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/kbproto.pc
	touch $@

kbproto-stage: $(KBPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/kbproto/...
# Documentation files should be installed in $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/kbproto/...
# Daemon startup scripts should be installed in $(KBPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??kbproto
#
# You may need to patch your application to make it use these locations.
#
$(KBPROTO_IPK): $(KBPROTO_BUILD_DIR)/.built
	rm -rf $(KBPROTO_IPK_DIR) $(BUILD_DIR)/kbproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(KBPROTO_BUILD_DIR) DESTDIR=$(KBPROTO_IPK_DIR) install
	$(MAKE) $(KBPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KBPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
kbproto-ipk: $(KBPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
kbproto-clean:
	-$(MAKE) -C $(KBPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kbproto-dirclean:
	rm -rf $(BUILD_DIR)/$(KBPROTO_DIR) $(KBPROTO_BUILD_DIR) $(KBPROTO_IPK_DIR) $(KBPROTO_IPK)
