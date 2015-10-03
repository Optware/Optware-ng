###########################################################
#
# damageproto
#
###########################################################

#
# DAMAGEPROTO_VERSION, DAMAGEPROTO_SITE and DAMAGEPROTO_SOURCE define
# the upstream location of the source code for the package.
# DAMAGEPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# DAMAGEPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
DAMAGEPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
DAMAGEPROTO_SOURCE=damageproto-$(DAMAGEPROTO_VERSION).tar.gz
DAMAGEPROTO_VERSION=1.2.1
DAMAGEPROTO_DIR=damageproto-$(DAMAGEPROTO_VERSION)
DAMAGEPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DAMAGEPROTO_DESCRIPTION=DAMAGE Protocol headers
DAMAGEPROTO_SECTION=lib
DAMAGEPROTO_PRIORITY=optional

#
# DAMAGEPROTO_IPK_VERSION should be incremented when the ipk changes.
#
DAMAGEPROTO_IPK_VERSION=1

#
# DAMAGEPROTO_CONFFILES should be a list of user-editable files
DAMAGEPROTO_CONFFILES=

#
# DAMAGEPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DAMAGEPROTO_PATCHES=$(DAMAGEPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DAMAGEPROTO_CPPFLAGS=
DAMAGEPROTO_LDFLAGS=

#
# DAMAGEPROTO_BUILD_DIR is the directory in which the build is done.
# DAMAGEPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DAMAGEPROTO_IPK_DIR is the directory in which the ipk is built.
# DAMAGEPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DAMAGEPROTO_BUILD_DIR=$(BUILD_DIR)/damageproto
DAMAGEPROTO_SOURCE_DIR=$(SOURCE_DIR)/damageproto
DAMAGEPROTO_IPK_DIR=$(BUILD_DIR)/damageproto-$(DAMAGEPROTO_VERSION)-ipk
DAMAGEPROTO_IPK=$(BUILD_DIR)/damageproto_$(DAMAGEPROTO_VERSION)-$(DAMAGEPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(DAMAGEPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(DAMAGEPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: damageproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DAMAGEPROTO_PRIORITY)" >>$@
	@echo "Section: $(DAMAGEPROTO_SECTION)" >>$@
	@echo "Version: $(DAMAGEPROTO_VERSION)-$(DAMAGEPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DAMAGEPROTO_MAINTAINER)" >>$@
	@echo "Source: $(DAMAGEPROTO_SITE)/$(DAMAGEPROTO_SOURCE)" >>$@
	@echo "Description: $(DAMAGEPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DAMAGEPROTO_SOURCE):
	$(WGET) -P $(@D) $(DAMAGEPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

damageproto-source: $(DL_DIR)/$(DAMAGEPROTO_SOURCE) $(DAMAGEPROTO_PATCHES)

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
$(DAMAGEPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(DAMAGEPROTO_SOURCE) $(DAMAGEPROTO_PATCHES) make/damageproto.mk
	rm -rf $(BUILD_DIR)/$(DAMAGEPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(DAMAGEPROTO_SOURCE)
	if test -n "$(DAMAGEPROTO_PATCHES)" ; \
		then cat $(DAMAGEPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DAMAGEPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DAMAGEPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DAMAGEPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DAMAGEPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DAMAGEPROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
	)
	touch $@

damageproto-unpack: $(DAMAGEPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DAMAGEPROTO_BUILD_DIR)/.built: $(DAMAGEPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
damageproto: $(DAMAGEPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DAMAGEPROTO_BUILD_DIR)/.staged: $(DAMAGEPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/damageproto.pc
	touch $@

damageproto-stage: $(DAMAGEPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/damageproto/...
# Documentation files should be installed in $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/damageproto/...
# Daemon startup scripts should be installed in $(DAMAGEPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??damageproto
#
# You may need to patch your application to make it use these locations.
#
$(DAMAGEPROTO_IPK): $(DAMAGEPROTO_BUILD_DIR)/.built
	rm -rf $(DAMAGEPROTO_IPK_DIR) $(BUILD_DIR)/damageproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DAMAGEPROTO_BUILD_DIR) DESTDIR=$(DAMAGEPROTO_IPK_DIR) install
	$(MAKE) $(DAMAGEPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DAMAGEPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
damageproto-ipk: $(DAMAGEPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
damageproto-clean:
	-$(MAKE) -C $(DAMAGEPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
damageproto-dirclean:
	rm -rf $(BUILD_DIR)/$(DAMAGEPROTO_DIR) $(DAMAGEPROTO_BUILD_DIR) $(DAMAGEPROTO_IPK_DIR) $(DAMAGEPROTO_IPK)
