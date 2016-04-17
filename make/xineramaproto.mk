###########################################################
#
# xineramaproto
#
###########################################################

#
# XINERAMAPROTO_VERSION, XINERAMAPROTO_SITE and XINERAMAPROTO_SOURCE define
# the upstream location of the source code for the package.
# XINERAMAPROTO_DIR is the directory which is created when the source
# archive is unpacked.
# XINERAMAPROTO_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
XINERAMAPROTO_SITE=http://pkgs.fedoraproject.org/repo/pkgs/tigervnc/$(XINERAMAPROTO_SOURCE)/a8aadcb281b9c11a91303e24cdea45f5
XINERAMAPROTO_SOURCE=xineramaproto-$(XINERAMAPROTO_VERSION).tar.bz2
XINERAMAPROTO_VERSION=1.2
XINERAMAPROTO_DIR=xineramaproto-$(XINERAMAPROTO_VERSION)
XINERAMAPROTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XINERAMAPROTO_DESCRIPTION=Xinerama Protocol headers
XINERAMAPROTO_SECTION=lib
XINERAMAPROTO_PRIORITY=optional

#
# XINERAMAPROTO_IPK_VERSION should be incremented when the ipk changes.
#
XINERAMAPROTO_IPK_VERSION=1

#
# XINERAMAPROTO_CONFFILES should be a list of user-editable files
XINERAMAPROTO_CONFFILES=

#
# XINERAMAPROTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XINERAMAPROTO_PATCHES=$(XINERAMAPROTO_SOURCE_DIR)/autogen.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XINERAMAPROTO_CPPFLAGS=
XINERAMAPROTO_LDFLAGS=

#
# XINERAMAPROTO_BUILD_DIR is the directory in which the build is done.
# XINERAMAPROTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XINERAMAPROTO_IPK_DIR is the directory in which the ipk is built.
# XINERAMAPROTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XINERAMAPROTO_BUILD_DIR=$(BUILD_DIR)/xineramaproto
XINERAMAPROTO_SOURCE_DIR=$(SOURCE_DIR)/xineramaproto
XINERAMAPROTO_IPK_DIR=$(BUILD_DIR)/xineramaproto-$(XINERAMAPROTO_VERSION)-ipk
XINERAMAPROTO_IPK=$(BUILD_DIR)/xineramaproto_$(XINERAMAPROTO_VERSION)-$(XINERAMAPROTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XINERAMAPROTO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(XINERAMAPROTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xineramaproto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XINERAMAPROTO_PRIORITY)" >>$@
	@echo "Section: $(XINERAMAPROTO_SECTION)" >>$@
	@echo "Version: $(XINERAMAPROTO_VERSION)-$(XINERAMAPROTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XINERAMAPROTO_MAINTAINER)" >>$@
	@echo "Source: $(XINERAMAPROTO_SITE)/$(XINERAMAPROTO_SOURCE)" >>$@
	@echo "Description: $(XINERAMAPROTO_DESCRIPTION)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(XINERAMAPROTO_SOURCE):
	$(WGET) -P $(@D) $(XINERAMAPROTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

xineramaproto-source: $(DL_DIR)/$(XINERAMAPROTO_SOURCE) $(XINERAMAPROTO_PATCHES)

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
$(XINERAMAPROTO_BUILD_DIR)/.configured: $(DL_DIR)/$(XINERAMAPROTO_SOURCE) $(XINERAMAPROTO_PATCHES) make/xineramaproto.mk
	rm -rf $(BUILD_DIR)/$(XINERAMAPROTO_DIR) $(@D)
	tar -C $(BUILD_DIR) -xjf $(DL_DIR)/$(XINERAMAPROTO_SOURCE)
	if test -n "$(XINERAMAPROTO_PATCHES)" ; \
		then cat $(XINERAMAPROTO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XINERAMAPROTO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XINERAMAPROTO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XINERAMAPROTO_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XINERAMAPROTO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XINERAMAPROTO_LDFLAGS)" \
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

xineramaproto-unpack: $(XINERAMAPROTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XINERAMAPROTO_BUILD_DIR)/.built: $(XINERAMAPROTO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xineramaproto: $(XINERAMAPROTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XINERAMAPROTO_BUILD_DIR)/.staged: $(XINERAMAPROTO_BUILD_DIR)/.built
	rm -f $@
#	rm -rf $(STAGING_INCLUDE_DIR)/X11
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xineramaproto.pc
	touch $@

xineramaproto-stage: $(XINERAMAPROTO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/xineramaproto/...
# Documentation files should be installed in $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/doc/xineramaproto/...
# Daemon startup scripts should be installed in $(XINERAMAPROTO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xineramaproto
#
# You may need to patch your application to make it use these locations.
#
$(XINERAMAPROTO_IPK): $(XINERAMAPROTO_BUILD_DIR)/.built
	rm -rf $(XINERAMAPROTO_IPK_DIR) $(BUILD_DIR)/xineramaproto_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XINERAMAPROTO_BUILD_DIR) DESTDIR=$(XINERAMAPROTO_IPK_DIR) install
	$(MAKE) $(XINERAMAPROTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XINERAMAPROTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xineramaproto-ipk: $(XINERAMAPROTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xineramaproto-clean:
	-$(MAKE) -C $(XINERAMAPROTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xineramaproto-dirclean:
	rm -rf $(BUILD_DIR)/$(XINERAMAPROTO_DIR) $(XINERAMAPROTO_BUILD_DIR) $(XINERAMAPROTO_IPK_DIR) $(XINERAMAPROTO_IPK)
