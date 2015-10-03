###########################################################
#
# recordproto
#
###########################################################

#
# RECORDPROTO_VERSION, RECORDPROTO_SITE and RECORDPROTO_SOURCE define
# the upstream location of the source code for the package.
# RECORDPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# RECORDPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
RECORDPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
RECORDPROTO_SOURCE=recordproto-$(RECORDPROTO_VERSION).tar.gz
RECORDPROTO_VERSION=1.14
RECORDPROTO_DIR=recordproto-$(RECORDPROTO_VERSION)
RECORDPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RECORDPROTO_DESCRIPTION=X Record Protocol Headers
RECORDPROTO_SECTION=lib
RECORDPROTO_PRIORITY=optional

#
# RECORDPROTO_IPK_VERSION should be incremented when the ipk changes.
#
RECORDPROTO_IPK_VERSION=1

#
# RECORDPROTO_CONFFILES should be a list of user-editable files
RECORDPROTO_CONFFILES=

#
# RECORDPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RECORDPROTO_PATCHES=$(RECORDPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RECORDPROTO_CPPFLAGS=
RECORDPROTO_LDFLAGS=

#
# RECORDPROTO_BUILD_DIR is the directory in which the build is done.
# RECORDPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RECORDPROTO_IPK_DIR is the directory in which the ipk is built.
# RECORDPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RECORDPROTO_BUILD_DIR=$(BUILD_DIR)/recordproto
RECORDPROTO_SOURCE_DIR=$(SOURCE_DIR)/recordproto
RECORDPROTO_IPK_DIR=$(BUILD_DIR)/recordproto-$(RECORDPROTO_VERSION)-ipk
RECORDPROTO_IPK=$(BUILD_DIR)/recordproto_$(RECORDPROTO_VERSION)-$(RECORDPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(RECORDPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(RECORDPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: recordproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RECORDPROTO_PRIORITY)" >>$@
	@echo "Section: $(RECORDPROTO_SECTION)" >>$@
	@echo "Version: $(RECORDPROTO_VERSION)-$(RECORDPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RECORDPROTO_MAINTAINER)" >>$@
	@echo "Source: $(RECORDPROTO_SITE)/$(RECORDPROTO_SOURCE)" >>$@
	@echo "Description: $(RECORDPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RECORDPROTO_SOURCE):
	$(WGET) -P $(@D) $(RECORDPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

recordproto-source: $(DL_DIR)/$(RECORDPROTO_SOURCE) $(RECORDPROTO_PATCHES)

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
$(RECORDPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(RECORDPROTO_SOURCE) $(RECORDPROTO_PATCHES) make/recordproto.mk
	rm -rf $(BUILD_DIR)/$(RECORDPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(RECORDPROTO_SOURCE)
	if test -n "$(RECORDPROTO_PATCHES)" ; \
		then cat $(RECORDPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(RECORDPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(RECORDPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RECORDPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RECORDPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RECORDPROTO_LDFLAGS)" \
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

recordproto-unpack: $(RECORDPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RECORDPROTO_BUILD_DIR)/.built: $(RECORDPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
recordproto: $(RECORDPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RECORDPROTO_BUILD_DIR)/.staged: $(RECORDPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/recordproto.pc
	touch $@

recordproto-stage: $(RECORDPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/recordproto/...
# Documentation files should be installed in $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/recordproto/...
# Daemon startup scripts should be installed in $(RECORDPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??recordproto
#
# You may need to patch your application to make it use these locations.
#
$(RECORDPROTO_IPK): $(RECORDPROTO_BUILD_DIR)/.built
	rm -rf $(RECORDPROTO_IPK_DIR) $(BUILD_DIR)/recordproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RECORDPROTO_BUILD_DIR) DESTDIR=$(RECORDPROTO_IPK_DIR) install
	$(MAKE) $(RECORDPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RECORDPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
recordproto-ipk: $(RECORDPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
recordproto-clean:
	-$(MAKE) -C $(RECORDPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
recordproto-dirclean:
	rm -rf $(BUILD_DIR)/$(RECORDPROTO_DIR) $(RECORDPROTO_BUILD_DIR) $(RECORDPROTO_IPK_DIR) $(RECORDPROTO_IPK)
