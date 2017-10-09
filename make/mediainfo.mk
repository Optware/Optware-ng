###########################################################
#
# mediainfo
#
###########################################################
#
# MEDIAINFO_VERSION, MEDIAINFO_SITE and MEDIAINFO_SOURCE define
# the upstream location of the source code for the package.
# MEDIAINFO_DIR is the directory which is created when the source
# archive is unpacked.
# MEDIAINFO_UNZIP is the command used to unzip the source.
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
MEDIAINFO_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/mediainfo/mediainfo_$(MEDIAINFO_VERSION).tar.xz
MEDIAINFO_VERSION=0.7.98
MEDIAINFO_SOURCE=mediainfo_$(MEDIAINFO_VERSION).tar.xz
MEDIAINFO_DIR=MediaInfo
MEDIAINFO_UNZIP=xzcat
MEDIAINFO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEDIAINFO_DESCRIPTION=MediaInfo is a convenient unified display of the most relevant technical and tag data for video and audio files.
MEDIAINFO_SECTION=media
MEDIAINFO_PRIORITY=optional
MEDIAINFO_DEPENDS=zlib, libzen, libmediainfo, libstdc++
MEDIAINFO_SUGGESTS=
MEDIAINFO_CONFLICTS=

#
# MEDIAINFO_IPK_VERSION should be incremented when the ipk changes.
#
MEDIAINFO_IPK_VERSION=2

#
# MEDIAINFO_CONFFILES should be a list of user-editable files
#MEDIAINFO_CONFFILES=$(TARGET_PREFIX)/etc/mediainfo.conf $(TARGET_PREFIX)/etc/init.d/SXXmediainfo

#
# MEDIAINFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MEDIAINFO_PATCHES=$(MEDIAINFO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEDIAINFO_CPPFLAGS=
MEDIAINFO_LDFLAGS=

#
# MEDIAINFO_BUILD_DIR is the directory in which the build is done.
# MEDIAINFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEDIAINFO_IPK_DIR is the directory in which the ipk is built.
# MEDIAINFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEDIAINFO_BUILD_DIR=$(BUILD_DIR)/mediainfo
MEDIAINFO_SOURCE_DIR=$(SOURCE_DIR)/mediainfo
MEDIAINFO_IPK_DIR=$(BUILD_DIR)/mediainfo-$(MEDIAINFO_VERSION)-ipk
MEDIAINFO_IPK=$(BUILD_DIR)/mediainfo_$(MEDIAINFO_VERSION)-$(MEDIAINFO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mediainfo-source mediainfo-unpack mediainfo mediainfo-stage mediainfo-ipk mediainfo-clean mediainfo-dirclean mediainfo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(MEDIAINFO_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(MEDIAINFO_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(MEDIAINFO_SOURCE).sha512
#
$(DL_DIR)/$(MEDIAINFO_SOURCE):
	$(WGET) -O $@ $(MEDIAINFO_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mediainfo-source: $(DL_DIR)/$(MEDIAINFO_SOURCE) $(MEDIAINFO_PATCHES)

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
$(MEDIAINFO_BUILD_DIR)/.configured: $(DL_DIR)/$(MEDIAINFO_SOURCE) $(MEDIAINFO_PATCHES) make/mediainfo.mk
	$(MAKE) zlib-stage libzen-stage libmediainfo-stage
	rm -rf $(BUILD_DIR)/$(MEDIAINFO_DIR) $(@D)
	$(MEDIAINFO_UNZIP) $(DL_DIR)/$(MEDIAINFO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEDIAINFO_PATCHES)" ; \
		then cat $(MEDIAINFO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MEDIAINFO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEDIAINFO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MEDIAINFO_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)/Project/GNU/CLI
	(cd $(@D)/Project/GNU/CLI; \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MEDIAINFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MEDIAINFO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--enable-shared \
	)
	$(PATCH_LIBTOOL) $(@D)/Project/GNU/CLI/libtool
	touch $@

mediainfo-unpack: $(MEDIAINFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEDIAINFO_BUILD_DIR)/.built: $(MEDIAINFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/CLI
	touch $@

#
# This is the build convenience target.
#
mediainfo: $(MEDIAINFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEDIAINFO_BUILD_DIR)/.staged: $(MEDIAINFO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/CLI DESTDIR=$(STAGING_DIR) install
	touch $@

mediainfo-stage: $(MEDIAINFO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mediainfo
#
$(MEDIAINFO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mediainfo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEDIAINFO_PRIORITY)" >>$@
	@echo "Section: $(MEDIAINFO_SECTION)" >>$@
	@echo "Version: $(MEDIAINFO_VERSION)-$(MEDIAINFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEDIAINFO_MAINTAINER)" >>$@
	@echo "Source: $(MEDIAINFO_URL)" >>$@
	@echo "Description: $(MEDIAINFO_DESCRIPTION)" >>$@
	@echo "Depends: $(MEDIAINFO_DEPENDS)" >>$@
	@echo "Suggests: $(MEDIAINFO_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEDIAINFO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/mediainfo/...
# Documentation files should be installed in $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/doc/mediainfo/...
# Daemon startup scripts should be installed in $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mediainfo
#
# You may need to patch your application to make it use these locations.
#
$(MEDIAINFO_IPK): $(MEDIAINFO_BUILD_DIR)/.built
	rm -rf $(MEDIAINFO_IPK_DIR) $(BUILD_DIR)/mediainfo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEDIAINFO_BUILD_DIR)/Project/GNU/CLI DESTDIR=$(MEDIAINFO_IPK_DIR) install-strip
#	$(INSTALL) -d $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MEDIAINFO_SOURCE_DIR)/mediainfo.conf $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/mediainfo.conf
#	$(INSTALL) -d $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MEDIAINFO_SOURCE_DIR)/rc.mediainfo $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmediainfo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmediainfo
	$(MAKE) $(MEDIAINFO_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MEDIAINFO_SOURCE_DIR)/postinst $(MEDIAINFO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIAINFO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MEDIAINFO_SOURCE_DIR)/prerm $(MEDIAINFO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIAINFO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MEDIAINFO_IPK_DIR)/CONTROL/postinst $(MEDIAINFO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MEDIAINFO_CONFFILES) | sed -e 's/ /\n/g' > $(MEDIAINFO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEDIAINFO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MEDIAINFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mediainfo-ipk: $(MEDIAINFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mediainfo-clean:
	rm -f $(MEDIAINFO_BUILD_DIR)/.built
	-$(MAKE) -C $(MEDIAINFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mediainfo-dirclean:
	rm -rf $(BUILD_DIR)/$(MEDIAINFO_DIR) $(MEDIAINFO_BUILD_DIR) $(MEDIAINFO_IPK_DIR) $(MEDIAINFO_IPK)
#
#
# Some sanity check for the package.
#
mediainfo-check: $(MEDIAINFO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
