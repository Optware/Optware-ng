###########################################################
#
# libmediainfo
#
###########################################################
#
# LIBMEDIAINFO_VERSION, LIBMEDIAINFO_SITE and LIBMEDIAINFO_SOURCE define
# the upstream location of the source code for the package.
# LIBMEDIAINFO_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMEDIAINFO_UNZIP is the command used to unzip the source.
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
LIBMEDIAINFO_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/mediainfo/libmediainfo_$(LIBMEDIAINFO_VERSION).tar.xz
LIBMEDIAINFO_VERSION=0.7.98
LIBMEDIAINFO_SOURCE=libmediainfo_$(LIBMEDIAINFO_VERSION).tar.xz
LIBMEDIAINFO_DIR=MediaInfoLib
LIBMEDIAINFO_UNZIP=xzcat
LIBMEDIAINFO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMEDIAINFO_DESCRIPTION=MediaInfo(Lib) is a convenient unified display of the most relevant technical and tag data for video and audio files.
LIBMEDIAINFO_SECTION=lib
LIBMEDIAINFO_PRIORITY=optional
LIBMEDIAINFO_DEPENDS=libstdc++, libzen
LIBMEDIAINFO_SUGGESTS=
LIBMEDIAINFO_CONFLICTS=

#
# LIBMEDIAINFO_IPK_VERSION should be incremented when the ipk changes.
#
LIBMEDIAINFO_IPK_VERSION=2

#
# LIBMEDIAINFO_CONFFILES should be a list of user-editable files
#LIBMEDIAINFO_CONFFILES=$(TARGET_PREFIX)/etc/libmediainfo.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmediainfo

#
# LIBMEDIAINFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMEDIAINFO_PATCHES=$(LIBMEDIAINFO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMEDIAINFO_CPPFLAGS=
LIBMEDIAINFO_LDFLAGS=

#
# LIBMEDIAINFO_BUILD_DIR is the directory in which the build is done.
# LIBMEDIAINFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMEDIAINFO_IPK_DIR is the directory in which the ipk is built.
# LIBMEDIAINFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMEDIAINFO_BUILD_DIR=$(BUILD_DIR)/libmediainfo
LIBMEDIAINFO_SOURCE_DIR=$(SOURCE_DIR)/libmediainfo
LIBMEDIAINFO_IPK_DIR=$(BUILD_DIR)/libmediainfo-$(LIBMEDIAINFO_VERSION)-ipk
LIBMEDIAINFO_IPK=$(BUILD_DIR)/libmediainfo_$(LIBMEDIAINFO_VERSION)-$(LIBMEDIAINFO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmediainfo-source libmediainfo-unpack libmediainfo libmediainfo-stage libmediainfo-ipk libmediainfo-clean libmediainfo-dirclean libmediainfo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBMEDIAINFO_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBMEDIAINFO_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBMEDIAINFO_SOURCE).sha512
#
$(DL_DIR)/$(LIBMEDIAINFO_SOURCE):
	$(WGET) -O $@ $(LIBMEDIAINFO_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmediainfo-source: $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) $(LIBMEDIAINFO_PATCHES)

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
$(LIBMEDIAINFO_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) $(LIBMEDIAINFO_PATCHES) make/libmediainfo.mk
	$(MAKE) libzen-stage
	rm -rf $(BUILD_DIR)/$(LIBMEDIAINFO_DIR) $(@D)
	$(LIBMEDIAINFO_UNZIP) $(DL_DIR)/$(LIBMEDIAINFO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMEDIAINFO_PATCHES)" ; \
		then cat $(LIBMEDIAINFO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMEDIAINFO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMEDIAINFO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMEDIAINFO_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)/Project/GNU/Library
	(cd $(@D)/Project/GNU/Library; \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMEDIAINFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMEDIAINFO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/Project/GNU/Library/libtool
	touch $@

libmediainfo-unpack: $(LIBMEDIAINFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMEDIAINFO_BUILD_DIR)/.built: $(LIBMEDIAINFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/Library
	touch $@

#
# This is the build convenience target.
#
libmediainfo: $(LIBMEDIAINFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMEDIAINFO_BUILD_DIR)/.staged: $(LIBMEDIAINFO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D)/Project/GNU/Library DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmediainfo.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmediainfo.pc
	touch $@

libmediainfo-stage: $(LIBMEDIAINFO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmediainfo
#
$(LIBMEDIAINFO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmediainfo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMEDIAINFO_PRIORITY)" >>$@
	@echo "Section: $(LIBMEDIAINFO_SECTION)" >>$@
	@echo "Version: $(LIBMEDIAINFO_VERSION)-$(LIBMEDIAINFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMEDIAINFO_MAINTAINER)" >>$@
	@echo "Source: $(LIBMEDIAINFO_URL)" >>$@
	@echo "Description: $(LIBMEDIAINFO_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMEDIAINFO_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMEDIAINFO_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMEDIAINFO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/libmediainfo/...
# Documentation files should be installed in $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/doc/libmediainfo/...
# Daemon startup scripts should be installed in $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmediainfo
#
# You may need to patch your application to make it use these locations.
#
$(LIBMEDIAINFO_IPK): $(LIBMEDIAINFO_BUILD_DIR)/.built
	rm -rf $(LIBMEDIAINFO_IPK_DIR) $(BUILD_DIR)/libmediainfo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMEDIAINFO_BUILD_DIR)/Project/GNU/Library DESTDIR=$(LIBMEDIAINFO_IPK_DIR) install-strip
	rm -f $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/lib/libmediainfo.la
#	$(INSTALL) -d $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBMEDIAINFO_SOURCE_DIR)/libmediainfo.conf $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/libmediainfo.conf
#	$(INSTALL) -d $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBMEDIAINFO_SOURCE_DIR)/rc.libmediainfo $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmediainfo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMEDIAINFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmediainfo
	$(MAKE) $(LIBMEDIAINFO_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMEDIAINFO_SOURCE_DIR)/postinst $(LIBMEDIAINFO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMEDIAINFO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMEDIAINFO_SOURCE_DIR)/prerm $(LIBMEDIAINFO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMEDIAINFO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMEDIAINFO_IPK_DIR)/CONTROL/postinst $(LIBMEDIAINFO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBMEDIAINFO_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMEDIAINFO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMEDIAINFO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBMEDIAINFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmediainfo-ipk: $(LIBMEDIAINFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmediainfo-clean:
	rm -f $(LIBMEDIAINFO_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMEDIAINFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmediainfo-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMEDIAINFO_DIR) $(LIBMEDIAINFO_BUILD_DIR) $(LIBMEDIAINFO_IPK_DIR) $(LIBMEDIAINFO_IPK)
#
#
# Some sanity check for the package.
#
libmediainfo-check: $(LIBMEDIAINFO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
