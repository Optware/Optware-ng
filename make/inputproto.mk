###########################################################
#
# inputproto
#
###########################################################

#
# INPUTPROTO_VERSION, INPUTPROTO_SITE and INPUTPROTO_SOURCE define
# the upstream location of the source code for the package.
# INPUTPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# INPUTPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
INPUTPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
INPUTPROTO_SOURCE=inputproto-$(INPUTPROTO_VERSION).tar.gz
INPUTPROTO_VERSION=2.2.99.1
INPUTPROTO_DIR=inputproto-$(INPUTPROTO_VERSION)
INPUTPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INPUTPROTO_DESCRIPTION=X Input Extension
INPUTPROTO_SECTION=lib
INPUTPROTO_PRIORITY=optional

#
# INPUTPROTO_IPK_VERSION should be incremented when the ipk changes.
#
INPUTPROTO_IPK_VERSION=1

#
# INPUTPROTO_CONFFILES should be a list of user-editable files
INPUTPROTO_CONFFILES=

#
# INPUTPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
INPUTPROTO_PATCHES=$(INPUTPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INPUTPROTO_CPPFLAGS=
INPUTPROTO_LDFLAGS=

#
# INPUTPROTO_BUILD_DIR is the directory in which the build is done.
# INPUTPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INPUTPROTO_IPK_DIR is the directory in which the ipk is built.
# INPUTPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INPUTPROTO_BUILD_DIR=$(BUILD_DIR)/inputproto
INPUTPROTO_SOURCE_DIR=$(SOURCE_DIR)/inputproto
INPUTPROTO_IPK_DIR=$(BUILD_DIR)/inputproto-$(INPUTPROTO_VERSION)-ipk
INPUTPROTO_IPK=$(BUILD_DIR)/inputproto_$(INPUTPROTO_VERSION)-$(INPUTPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(INPUTPROTO_IPK_DIR)/CONTROL/control:
	@install -d $(INPUTPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: inputproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INPUTPROTO_PRIORITY)" >>$@
	@echo "Section: $(INPUTPROTO_SECTION)" >>$@
	@echo "Version: $(INPUTPROTO_VERSION)-$(INPUTPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INPUTPROTO_MAINTAINER)" >>$@
	@echo "Source: $(INPUTPROTO_SITE)/$(INPUTPROTO_SOURCE)" >>$@
	@echo "Description: $(INPUTPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INPUTPROTO_SOURCE):
	$(WGET) -P $(@D) $(INPUTPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

inputproto-source: $(DL_DIR)/$(INPUTPROTO_SOURCE) $(INPUTPROTO_PATCHES)

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
$(INPUTPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(INPUTPROTO_SOURCE) $(INPUTPROTO_PATCHES) make/inputproto.mk
	rm -rf $(BUILD_DIR)/$(INPUTPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(INPUTPROTO_SOURCE)
	if test -n "$(INPUTPROTO_PATCHES)" ; \
		then cat $(INPUTPROTO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INPUTPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(INPUTPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(INPUTPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); chmod +x autogen.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INPUTPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INPUTPROTO_LDFLAGS)" \
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

inputproto-unpack: $(INPUTPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INPUTPROTO_BUILD_DIR)/.built: $(INPUTPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
inputproto: $(INPUTPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(INPUTPROTO_BUILD_DIR)/.staged: $(INPUTPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/inputproto.pc
	touch $@

inputproto-stage: $(INPUTPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(INPUTPROTO_IPK_DIR)/opt/sbin or $(INPUTPROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INPUTPROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INPUTPROTO_IPK_DIR)/opt/etc/inputproto/...
# Documentation files should be installed in $(INPUTPROTO_IPK_DIR)/opt/doc/inputproto/...
# Daemon startup scripts should be installed in $(INPUTPROTO_IPK_DIR)/opt/etc/init.d/S??inputproto
#
# You may need to patch your application to make it use these locations.
#
$(INPUTPROTO_IPK): $(INPUTPROTO_BUILD_DIR)/.built
	rm -rf $(INPUTPROTO_IPK_DIR) $(BUILD_DIR)/inputproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(INPUTPROTO_BUILD_DIR) DESTDIR=$(INPUTPROTO_IPK_DIR) install
	$(MAKE) $(INPUTPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INPUTPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
inputproto-ipk: $(INPUTPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
inputproto-clean:
	-$(MAKE) -C $(INPUTPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
inputproto-dirclean:
	rm -rf $(BUILD_DIR)/$(INPUTPROTO_DIR) $(INPUTPROTO_BUILD_DIR) $(INPUTPROTO_IPK_DIR) $(INPUTPROTO_IPK)
