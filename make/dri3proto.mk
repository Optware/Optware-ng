###########################################################
#
# dri3proto
#
###########################################################

#
# DRI3PROTO_VERSION, DRI3PROTO_SITE and DRI3PROTO_SOURCE define
# the upstream location of the source code for the package.
# DRI3PROTO_DIR is the directory which is created when the source
# archive is unpacked.
# DRI3PROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
DRI3PROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
DRI3PROTO_SOURCE=dri3proto-$(DRI3PROTO_VERSION).tar.gz
DRI3PROTO_VERSION=1.0
DRI3PROTO_DIR=dri3proto-$(DRI3PROTO_VERSION)
DRI3PROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DRI3PROTO_DESCRIPTION=DRI3 Protocol headers
DRI3PROTO_SECTION=lib
DRI3PROTO_PRIORITY=optional

#
# DRI3PROTO_IPK_VERSION should be incremented when the ipk changes.
#
DRI3PROTO_IPK_VERSION=1

#
# DRI3PROTO_CONFFILES should be a list of user-editable files
DRI3PROTO_CONFFILES=

#
# DRI3PROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DRI3PROTO_PATCHES=$(DRI3PROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DRI3PROTO_CPPFLAGS=
DRI3PROTO_LDFLAGS=

#
# DRI3PROTO_BUILD_DIR is the directory in which the build is done.
# DRI3PROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DRI3PROTO_IPK_DIR is the directory in which the ipk is built.
# DRI3PROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DRI3PROTO_BUILD_DIR=$(BUILD_DIR)/dri3proto
DRI3PROTO_SOURCE_DIR=$(SOURCE_DIR)/dri3proto
DRI3PROTO_IPK_DIR=$(BUILD_DIR)/dri3proto-$(DRI3PROTO_VERSION)-ipk
DRI3PROTO_IPK=$(BUILD_DIR)/dri3proto_$(DRI3PROTO_VERSION)-$(DRI3PROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(DRI3PROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(DRI3PROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dri3proto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DRI3PROTO_PRIORITY)" >>$@
	@echo "Section: $(DRI3PROTO_SECTION)" >>$@
	@echo "Version: $(DRI3PROTO_VERSION)-$(DRI3PROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DRI3PROTO_MAINTAINER)" >>$@
	@echo "Source: $(DRI3PROTO_SITE)/$(DRI3PROTO_SOURCE)" >>$@
	@echo "Description: $(DRI3PROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DRI3PROTO_SOURCE):
	$(WGET) -P $(@D) $(DRI3PROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

dri3proto-source: $(DL_DIR)/$(DRI3PROTO_SOURCE) $(DRI3PROTO_PATCHES)

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
$(DRI3PROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(DRI3PROTO_SOURCE) $(DRI3PROTO_PATCHES) make/dri3proto.mk
	rm -rf $(BUILD_DIR)/$(DRI3PROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(DRI3PROTO_SOURCE)
	if test -n "$(DRI3PROTO_PATCHES)" ; \
		then cat $(DRI3PROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DRI3PROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DRI3PROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DRI3PROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DRI3PROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DRI3PROTO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

dri3proto-unpack: $(DRI3PROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DRI3PROTO_BUILD_DIR)/.built: $(DRI3PROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dri3proto: $(DRI3PROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DRI3PROTO_BUILD_DIR)/.staged: $(DRI3PROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/dri3proto.pc
	touch $@

dri3proto-stage: $(DRI3PROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(DRI3PROTO_IPK_DIR)/opt/sbin or $(DRI3PROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DRI3PROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DRI3PROTO_IPK_DIR)/opt/etc/dri3proto/...
# Documentation files should be installed in $(DRI3PROTO_IPK_DIR)/opt/doc/dri3proto/...
# Daemon startup scripts should be installed in $(DRI3PROTO_IPK_DIR)/opt/etc/init.d/S??dri3proto
#
# You may need to patch your application to make it use these locations.
#
$(DRI3PROTO_IPK): $(DRI3PROTO_BUILD_DIR)/.built
	rm -rf $(DRI3PROTO_IPK_DIR) $(BUILD_DIR)/dri3proto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DRI3PROTO_BUILD_DIR) DESTDIR=$(DRI3PROTO_IPK_DIR) install
	$(MAKE) $(DRI3PROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DRI3PROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dri3proto-ipk: $(DRI3PROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dri3proto-clean:
	-$(MAKE) -C $(DRI3PROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dri3proto-dirclean:
	rm -rf $(BUILD_DIR)/$(DRI3PROTO_DIR) $(DRI3PROTO_BUILD_DIR) $(DRI3PROTO_IPK_DIR) $(DRI3PROTO_IPK)
