###########################################################
#
# xinerama
#
###########################################################
#
# XINERAMA_VERSION, XINERAMA_SITE and XINERAMA_SOURCE define
# the upstream location of the source code for the package.
# XINERAMA_DIR is the directory which is created when the source
# archive is unpacked.
# XINERAMA_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
XINERAMA_URL=http://archive.ubuntu.com/ubuntu/pool/main/libx/libxinerama/libxinerama_$(XINERAMA_VERSION).orig.tar.gz
XINERAMA_VERSION=1.1.3
XINERAMA_SOURCE=libxinerama-$(XINERAMA_VERSION).tar.gz
XINERAMA_DIR=libXinerama-$(XINERAMA_VERSION)
XINERAMA_UNZIP=zcat
XINERAMA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
XINERAMA_DESCRIPTION=X11 Xinerama extension library
XINERAMA_SECTION=libs
XINERAMA_PRIORITY=optional
XINERAMA_DEPENDS=x11, xext
XINERAMA_SUGGESTS=
XINERAMA_CONFLICTS=

#
# XINERAMA_IPK_VERSION should be incremented when the ipk changes.
#
XINERAMA_IPK_VERSION=1

#
# XINERAMA_CONFFILES should be a list of user-editable files
#XINERAMA_CONFFILES=$(TARGET_PREFIX)/etc/xinerama.conf $(TARGET_PREFIX)/etc/init.d/SXXxinerama

#
# XINERAMA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#XINERAMA_PATCHES=$(XINERAMA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XINERAMA_CPPFLAGS=
XINERAMA_LDFLAGS=

#
# XINERAMA_BUILD_DIR is the directory in which the build is done.
# XINERAMA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XINERAMA_IPK_DIR is the directory in which the ipk is built.
# XINERAMA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XINERAMA_BUILD_DIR=$(BUILD_DIR)/xinerama
XINERAMA_SOURCE_DIR=$(SOURCE_DIR)/xinerama
XINERAMA_IPK_DIR=$(BUILD_DIR)/xinerama-$(XINERAMA_VERSION)-ipk
XINERAMA_IPK=$(BUILD_DIR)/xinerama_$(XINERAMA_VERSION)-$(XINERAMA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: xinerama-source xinerama-unpack xinerama xinerama-stage xinerama-ipk xinerama-clean xinerama-dirclean xinerama-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(XINERAMA_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(XINERAMA_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(XINERAMA_SOURCE).sha512
#
$(DL_DIR)/$(XINERAMA_SOURCE):
	$(WGET) -O $@ $(XINERAMA_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
xinerama-source: $(DL_DIR)/$(XINERAMA_SOURCE) $(XINERAMA_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(XINERAMA_BUILD_DIR)/.configured: $(DL_DIR)/$(XINERAMA_SOURCE) $(XINERAMA_PATCHES) make/xinerama.mk
	$(MAKE) x11-stage xext-stage xineramaproto-stage
	rm -rf $(BUILD_DIR)/$(XINERAMA_DIR) $(@D)
	$(XINERAMA_UNZIP) $(DL_DIR)/$(XINERAMA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(XINERAMA_PATCHES)" ; \
		then cat $(XINERAMA_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(XINERAMA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XINERAMA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(XINERAMA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XINERAMA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XINERAMA_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

xinerama-unpack: $(XINERAMA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XINERAMA_BUILD_DIR)/.built: $(XINERAMA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
xinerama: $(XINERAMA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XINERAMA_BUILD_DIR)/.staged: $(XINERAMA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xinerama.pc
	rm -f $(STAGING_LIB_DIR)/libX11.la $(STAGING_LIB_DIR)/libXinerama.la
	touch $@

xinerama-stage: $(XINERAMA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/xinerama
#
$(XINERAMA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: xinerama" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XINERAMA_PRIORITY)" >>$@
	@echo "Section: $(XINERAMA_SECTION)" >>$@
	@echo "Version: $(XINERAMA_VERSION)-$(XINERAMA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XINERAMA_MAINTAINER)" >>$@
	@echo "Source: $(XINERAMA_URL)" >>$@
	@echo "Description: $(XINERAMA_DESCRIPTION)" >>$@
	@echo "Depends: $(XINERAMA_DEPENDS)" >>$@
	@echo "Suggests: $(XINERAMA_SUGGESTS)" >>$@
	@echo "Conflicts: $(XINERAMA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/xinerama/...
# Documentation files should be installed in $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/doc/xinerama/...
# Daemon startup scripts should be installed in $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??xinerama
#
# You may need to patch your application to make it use these locations.
#
$(XINERAMA_IPK): $(XINERAMA_BUILD_DIR)/.built
	rm -rf $(XINERAMA_IPK_DIR) $(BUILD_DIR)/xinerama_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XINERAMA_BUILD_DIR) DESTDIR=$(XINERAMA_IPK_DIR) install-strip
#	$(INSTALL) -d $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(XINERAMA_SOURCE_DIR)/xinerama.conf $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/xinerama.conf
#	$(INSTALL) -d $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(XINERAMA_SOURCE_DIR)/rc.xinerama $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxinerama
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINERAMA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXxinerama
	$(MAKE) $(XINERAMA_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(XINERAMA_SOURCE_DIR)/postinst $(XINERAMA_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINERAMA_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(XINERAMA_SOURCE_DIR)/prerm $(XINERAMA_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINERAMA_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(XINERAMA_IPK_DIR)/CONTROL/postinst $(XINERAMA_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(XINERAMA_CONFFILES) | sed -e 's/ /\n/g' > $(XINERAMA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XINERAMA_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(XINERAMA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xinerama-ipk: $(XINERAMA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xinerama-clean:
	rm -f $(XINERAMA_BUILD_DIR)/.built
	-$(MAKE) -C $(XINERAMA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xinerama-dirclean:
	rm -rf $(BUILD_DIR)/$(XINERAMA_DIR) $(XINERAMA_BUILD_DIR) $(XINERAMA_IPK_DIR) $(XINERAMA_IPK)
#
#
# Some sanity check for the package.
#
xinerama-check: $(XINERAMA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
