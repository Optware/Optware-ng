###########################################################
#
# vorbisgain
#
###########################################################
#
# VORBISGAIN_VERSION, VORBISGAIN_SITE and VORBISGAIN_SOURCE define
# the upstream location of the source code for the package.
# VORBISGAIN_DIR is the directory which is created when the source
# archive is unpacked.
# VORBISGAIN_UNZIP is the command used to unzip the source.
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
VORBISGAIN_URL=https://www.sjeng.org/ftp/vorbis/$(VORBISGAIN_SOURCE)
VORBISGAIN_VERSION=0.36
VORBISGAIN_SOURCE=vorbisgain-$(VORBISGAIN_VERSION).zip
VORBISGAIN_DIR=vorbisgain-$(VORBISGAIN_VERSION)
VORBISGAIN_UNZIP=unzip
VORBISGAIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VORBISGAIN_DESCRIPTION=VorbisGain is a utility that uses a psychoacoustic method to correct the volume of an Ogg Vorbis file to a predefined standardized loudness.
VORBISGAIN_SECTION=media
VORBISGAIN_PRIORITY=optional
VORBISGAIN_DEPENDS=libvorbis, libogg
VORBISGAIN_SUGGESTS=
VORBISGAIN_CONFLICTS=

#
# VORBISGAIN_IPK_VERSION should be incremented when the ipk changes.
#
VORBISGAIN_IPK_VERSION=2

#
# VORBISGAIN_CONFFILES should be a list of user-editable files
#VORBISGAIN_CONFFILES=$(TARGET_PREFIX)/etc/vorbisgain.conf $(TARGET_PREFIX)/etc/init.d/SXXvorbisgain

#
# VORBISGAIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VORBISGAIN_PATCHES=$(VORBISGAIN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VORBISGAIN_CPPFLAGS=
VORBISGAIN_LDFLAGS=

#
# VORBISGAIN_BUILD_DIR is the directory in which the build is done.
# VORBISGAIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VORBISGAIN_IPK_DIR is the directory in which the ipk is built.
# VORBISGAIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VORBISGAIN_BUILD_DIR=$(BUILD_DIR)/vorbisgain
VORBISGAIN_SOURCE_DIR=$(SOURCE_DIR)/vorbisgain
VORBISGAIN_IPK_DIR=$(BUILD_DIR)/vorbisgain-$(VORBISGAIN_VERSION)-ipk
VORBISGAIN_IPK=$(BUILD_DIR)/vorbisgain_$(VORBISGAIN_VERSION)-$(VORBISGAIN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vorbisgain-source vorbisgain-unpack vorbisgain vorbisgain-stage vorbisgain-ipk vorbisgain-clean vorbisgain-dirclean vorbisgain-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(VORBISGAIN_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(VORBISGAIN_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(VORBISGAIN_SOURCE).sha512
#
$(DL_DIR)/$(VORBISGAIN_SOURCE):
	$(WGET) -O $@ $(VORBISGAIN_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vorbisgain-source: $(DL_DIR)/$(VORBISGAIN_SOURCE) $(VORBISGAIN_PATCHES)

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
$(VORBISGAIN_BUILD_DIR)/.configured: $(DL_DIR)/$(VORBISGAIN_SOURCE) $(VORBISGAIN_PATCHES) make/vorbisgain.mk
	$(MAKE) libvorbis-stage libogg-stage
	rm -rf $(BUILD_DIR)/$(VORBISGAIN_DIR) $(@D)
	unzip $(DL_DIR)/$(VORBISGAIN_SOURCE) -d $(BUILD_DIR)
	if test -n "$(VORBISGAIN_PATCHES)" ; \
		then cat $(VORBISGAIN_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(VORBISGAIN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VORBISGAIN_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(VORBISGAIN_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VORBISGAIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VORBISGAIN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

vorbisgain-unpack: $(VORBISGAIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VORBISGAIN_BUILD_DIR)/.built: $(VORBISGAIN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
vorbisgain: $(VORBISGAIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VORBISGAIN_BUILD_DIR)/.staged: $(VORBISGAIN_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

vorbisgain-stage: $(VORBISGAIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vorbisgain
#
$(VORBISGAIN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: vorbisgain" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VORBISGAIN_PRIORITY)" >>$@
	@echo "Section: $(VORBISGAIN_SECTION)" >>$@
	@echo "Version: $(VORBISGAIN_VERSION)-$(VORBISGAIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VORBISGAIN_MAINTAINER)" >>$@
	@echo "Source: $(VORBISGAIN_URL)" >>$@
	@echo "Description: $(VORBISGAIN_DESCRIPTION)" >>$@
	@echo "Depends: $(VORBISGAIN_DEPENDS)" >>$@
	@echo "Suggests: $(VORBISGAIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(VORBISGAIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/vorbisgain/...
# Documentation files should be installed in $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/doc/vorbisgain/...
# Daemon startup scripts should be installed in $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??vorbisgain
#
# You may need to patch your application to make it use these locations.
#
$(VORBISGAIN_IPK): $(VORBISGAIN_BUILD_DIR)/.built
	rm -rf $(VORBISGAIN_IPK_DIR) $(BUILD_DIR)/vorbisgain_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(VORBISGAIN_BUILD_DIR) DESTDIR=$(VORBISGAIN_IPK_DIR) install-strip
#	$(INSTALL) -d $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(VORBISGAIN_SOURCE_DIR)/vorbisgain.conf $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/vorbisgain.conf
#	$(INSTALL) -d $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(VORBISGAIN_SOURCE_DIR)/rc.vorbisgain $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXvorbisgain
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VORBISGAIN_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXvorbisgain
	$(MAKE) $(VORBISGAIN_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(VORBISGAIN_SOURCE_DIR)/postinst $(VORBISGAIN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VORBISGAIN_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(VORBISGAIN_SOURCE_DIR)/prerm $(VORBISGAIN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(VORBISGAIN_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(VORBISGAIN_IPK_DIR)/CONTROL/postinst $(VORBISGAIN_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(VORBISGAIN_CONFFILES) | sed -e 's/ /\n/g' > $(VORBISGAIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VORBISGAIN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(VORBISGAIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vorbisgain-ipk: $(VORBISGAIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vorbisgain-clean:
	rm -f $(VORBISGAIN_BUILD_DIR)/.built
	-$(MAKE) -C $(VORBISGAIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vorbisgain-dirclean:
	rm -rf $(BUILD_DIR)/$(VORBISGAIN_DIR) $(VORBISGAIN_BUILD_DIR) $(VORBISGAIN_IPK_DIR) $(VORBISGAIN_IPK)
#
#
# Some sanity check for the package.
#
vorbisgain-check: $(VORBISGAIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
