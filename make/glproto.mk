###########################################################
#
# glproto
#
###########################################################

#
# GLPROTO_VERSION, GLPROTO_SITE and GLPROTO_SOURCE define
# the upstream location of the source code for the package.
# GLPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# GLPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GLPROTO_SITE=http://xorg.freedesktop.org/releases/individual/proto
GLPROTO_SOURCE=glproto-$(GLPROTO_VERSION).tar.gz
GLPROTO_VERSION=1.4.17
GLPROTO_DIR=glproto-$(GLPROTO_VERSION)
GLPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GLPROTO_DESCRIPTION=GL Protocol headers
GLPROTO_SECTION=lib
GLPROTO_PRIORITY=optional

#
# GLPROTO_IPK_VERSION should be incremented when the ipk changes.
#
GLPROTO_IPK_VERSION=1

#
# GLPROTO_CONFFILES should be a list of user-editable files
GLPROTO_CONFFILES=

#
# GLPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GLPROTO_PATCHES=$(GLPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GLPROTO_CPPFLAGS=
GLPROTO_LDFLAGS=

#
# GLPROTO_BUILD_DIR is the directory in which the build is done.
# GLPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GLPROTO_IPK_DIR is the directory in which the ipk is built.
# GLPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GLPROTO_BUILD_DIR=$(BUILD_DIR)/glproto
GLPROTO_SOURCE_DIR=$(SOURCE_DIR)/glproto
GLPROTO_IPK_DIR=$(BUILD_DIR)/glproto-$(GLPROTO_VERSION)-ipk
GLPROTO_IPK=$(BUILD_DIR)/glproto_$(GLPROTO_VERSION)-$(GLPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(GLPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(GLPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: glproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GLPROTO_PRIORITY)" >>$@
	@echo "Section: $(GLPROTO_SECTION)" >>$@
	@echo "Version: $(GLPROTO_VERSION)-$(GLPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GLPROTO_MAINTAINER)" >>$@
	@echo "Source: $(GLPROTO_SITE)/$(GLPROTO_SOURCE)" >>$@
	@echo "Description: $(GLPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GLPROTO_SOURCE):
	$(WGET) -P $(@D) $(GLPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

glproto-source: $(DL_DIR)/$(GLPROTO_SOURCE) $(GLPROTO_PATCHES)

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
$(GLPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(GLPROTO_SOURCE) $(GLPROTO_PATCHES) make/glproto.mk
	rm -rf $(BUILD_DIR)/$(GLPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(GLPROTO_SOURCE)
	if test -n "$(GLPROTO_PATCHES)" ; \
		then cat $(GLPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GLPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(GLPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GLPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GLPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GLPROTO_LDFLAGS)" \
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

glproto-unpack: $(GLPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GLPROTO_BUILD_DIR)/.built: $(GLPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
glproto: $(GLPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GLPROTO_BUILD_DIR)/.staged: $(GLPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/glproto.pc
	touch $@

glproto-stage: $(GLPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(GLPROTO_IPK_DIR)/opt/sbin or $(GLPROTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GLPROTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GLPROTO_IPK_DIR)/opt/etc/glproto/...
# Documentation files should be installed in $(GLPROTO_IPK_DIR)/opt/doc/glproto/...
# Daemon startup scripts should be installed in $(GLPROTO_IPK_DIR)/opt/etc/init.d/S??glproto
#
# You may need to patch your application to make it use these locations.
#
$(GLPROTO_IPK): $(GLPROTO_BUILD_DIR)/.built
	rm -rf $(GLPROTO_IPK_DIR) $(BUILD_DIR)/glproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GLPROTO_BUILD_DIR) DESTDIR=$(GLPROTO_IPK_DIR) install
	$(MAKE) $(GLPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GLPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
glproto-ipk: $(GLPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
glproto-clean:
	-$(MAKE) -C $(GLPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
glproto-dirclean:
	rm -rf $(BUILD_DIR)/$(GLPROTO_DIR) $(GLPROTO_BUILD_DIR) $(GLPROTO_IPK_DIR) $(GLPROTO_IPK)
