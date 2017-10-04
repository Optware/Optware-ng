###########################################################
#
# mac
#
###########################################################
#
# MAC_VERSION, MAC_SITE and MAC_SOURCE define
# the upstream location of the source code for the package.
# MAC_DIR is the directory which is created when the source
# archive is unpacked.
# MAC_UNZIP is the command used to unzip the source.
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
MAC_URL=http://etree.org/shnutils/shntool/support/formats/ape/unix/$(MAC_VERSION)/mac-$(MAC_VERSION).tar.gz
MAC_VERSION=3.99-u4-b5-s7
MAC_SOURCE=mac-$(MAC_VERSION).tar.gz
MAC_DIR=mac-$(MAC_VERSION)
MAC_UNZIP=zcat
MAC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MAC_DESCRIPTION=Monkey's Audio Codec, a lossless audio codec.
MAC_SECTION=audio
MAC_PRIORITY=optional
MAC_DEPENDS=
MAC_SUGGESTS=
MAC_CONFLICTS=

#
# MAC_IPK_VERSION should be incremented when the ipk changes.
#
MAC_IPK_VERSION=2

#
# MAC_CONFFILES should be a list of user-editable files
#MAC_CONFFILES=$(TARGET_PREFIX)/etc/mac.conf $(TARGET_PREFIX)/etc/init.d/SXXmac

#
# MAC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MAC_PATCHES=\
$(MAC_SOURCE_DIR)/max_min.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MAC_CPPFLAGS=
MAC_LDFLAGS=

#
# MAC_BUILD_DIR is the directory in which the build is done.
# MAC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MAC_IPK_DIR is the directory in which the ipk is built.
# MAC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MAC_BUILD_DIR=$(BUILD_DIR)/mac
MAC_SOURCE_DIR=$(SOURCE_DIR)/mac
MAC_IPK_DIR=$(BUILD_DIR)/mac-$(MAC_VERSION)-ipk
MAC_IPK=$(BUILD_DIR)/mac_$(MAC_VERSION)-$(MAC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mac-source mac-unpack mac mac-stage mac-ipk mac-clean mac-dirclean mac-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(MAC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(MAC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(MAC_SOURCE).sha512
#
$(DL_DIR)/$(MAC_SOURCE):
	$(WGET) -O $@ $(MAC_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mac-source: $(DL_DIR)/$(MAC_SOURCE) $(MAC_PATCHES)

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
$(MAC_BUILD_DIR)/.configured: $(DL_DIR)/$(MAC_SOURCE) $(MAC_PATCHES) make/mac.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MAC_DIR) $(@D)
	$(MAC_UNZIP) $(DL_DIR)/$(MAC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MAC_PATCHES)" ; \
		then cat $(MAC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MAC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MAC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MAC_DIR) $(@D) ; \
	fi
	(\
		echo "#define __MAX(a,b)    (((a) > (b)) ? (a) : (b))"; \
		echo "#define __MIN(a,b)    (((a) < (b)) ? (a) : (b))"; \
	) > $(@D)/max_min.h
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MAC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MAC_LDFLAGS)" \
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

mac-unpack: $(MAC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MAC_BUILD_DIR)/.built: $(MAC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) AM_CPPFLAGS="-include $(@D)/max_min.h"
	touch $@

#
# This is the build convenience target.
#
mac: $(MAC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MAC_BUILD_DIR)/.staged: $(MAC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mac-stage: $(MAC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mac
#
$(MAC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mac" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MAC_PRIORITY)" >>$@
	@echo "Section: $(MAC_SECTION)" >>$@
	@echo "Version: $(MAC_VERSION)-$(MAC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MAC_MAINTAINER)" >>$@
	@echo "Source: $(MAC_URL)" >>$@
	@echo "Description: $(MAC_DESCRIPTION)" >>$@
	@echo "Depends: $(MAC_DEPENDS)" >>$@
	@echo "Suggests: $(MAC_SUGGESTS)" >>$@
	@echo "Conflicts: $(MAC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MAC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MAC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MAC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/mac/...
# Documentation files should be installed in $(MAC_IPK_DIR)$(TARGET_PREFIX)/doc/mac/...
# Daemon startup scripts should be installed in $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mac
#
# You may need to patch your application to make it use these locations.
#
$(MAC_IPK): $(MAC_BUILD_DIR)/.built
	rm -rf $(MAC_IPK_DIR) $(BUILD_DIR)/mac_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MAC_BUILD_DIR) DESTDIR=$(MAC_IPK_DIR) install-strip
#	$(INSTALL) -d $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MAC_SOURCE_DIR)/mac.conf $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/mac.conf
#	$(INSTALL) -d $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MAC_SOURCE_DIR)/rc.mac $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmac
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MAC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmac
	$(MAKE) $(MAC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MAC_SOURCE_DIR)/postinst $(MAC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MAC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MAC_SOURCE_DIR)/prerm $(MAC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MAC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MAC_IPK_DIR)/CONTROL/postinst $(MAC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MAC_CONFFILES) | sed -e 's/ /\n/g' > $(MAC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MAC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MAC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mac-ipk: $(MAC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mac-clean:
	rm -f $(MAC_BUILD_DIR)/.built
	-$(MAKE) -C $(MAC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mac-dirclean:
	rm -rf $(BUILD_DIR)/$(MAC_DIR) $(MAC_BUILD_DIR) $(MAC_IPK_DIR) $(MAC_IPK)
#
#
# Some sanity check for the package.
#
mac-check: $(MAC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
