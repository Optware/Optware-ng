###########################################################
#
# wpa-supplicant
#
###########################################################

# You must replace "wpa-supplicant" and "WPA_SUPPLICANT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# WPA_SUPPLICANT_VERSION, WPA_SUPPLICANT_SITE and WPA_SUPPLICANT_SOURCE define
# the upstream location of the source code for the package.
# WPA_SUPPLICANT_DIR is the directory which is created when the source
# archive is unpacked.
# WPA_SUPPLICANT_UNZIP is the command used to unzip the source.
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
WPA_SUPPLICANT_SITE=http://hostap.epitest.fi/releases
ifneq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
WPA_SUPPLICANT_VERSION=2.4
WPA_SUPPLICANT_IPK_VERSION=3
else
WPA_SUPPLICANT_VERSION=0.5.8
WPA_SUPPLICANT_IPK_VERSION=3
endif
WPA_SUPPLICANT_SOURCE=wpa_supplicant-$(WPA_SUPPLICANT_VERSION).tar.gz
WPA_SUPPLICANT_DIR=wpa_supplicant-$(WPA_SUPPLICANT_VERSION)
WPA_SUPPLICANT_UNZIP=zcat
WPA_SUPPLICANT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WPA_SUPPLICANT_DESCRIPTION=wpa_supplicant is a WPA Supplicant for Linux, BSD and Windows with support for WPA and WPA2 (IEEE 802.11i / RSN)
WPA_SUPPLICANT_SECTION=net
WPA_SUPPLICANT_PRIORITY=optional
WPA_SUPPLICANT_DEPENDS=openssl, ncurses, readline
WPA_SUPPLICANT_SUGGESTS=
WPA_SUPPLICANT_CONFLICTS=

#
# WPA_SUPPLICANT_IPK_VERSION should be incremented when the ipk changes.
# defined aboce
#WPA_SUPPLICANT_IPK_VERSION=1

#
# WPA_SUPPLICANT_CONFFILES should be a list of user-editable files
WPA_SUPPLICANT_CONFFILES=$(TARGET_PREFIX)/etc/wpa-supplicant.conf 

#
# WPA_SUPPLICANT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# WPA_SUPPLICANT_PATCHES=$(WPA_SUPPLICANT_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WPA_SUPPLICANT_CPPFLAGS=
WPA_SUPPLICANT_LDFLAGS=

#
# WPA_SUPPLICANT_BUILD_DIR is the directory in which the build is done.
# WPA_SUPPLICANT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WPA_SUPPLICANT_IPK_DIR is the directory in which the ipk is built.
# WPA_SUPPLICANT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WPA_SUPPLICANT_BUILD_DIR=$(BUILD_DIR)/wpa-supplicant
WPA_SUPPLICANT_SOURCE_DIR=$(SOURCE_DIR)/wpa-supplicant
WPA_SUPPLICANT_IPK_DIR=$(BUILD_DIR)/wpa-supplicant-$(WPA_SUPPLICANT_VERSION)-ipk
WPA_SUPPLICANT_IPK=$(BUILD_DIR)/wpa-supplicant_$(WPA_SUPPLICANT_VERSION)-$(WPA_SUPPLICANT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wpa-supplicant-source wpa-supplicant-unpack wpa-supplicant wpa-supplicant-stage wpa-supplicant-ipk wpa-supplicant-clean wpa-supplicant-dirclean wpa-supplicant-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WPA_SUPPLICANT_SOURCE):
	$(WGET) -P $(@D) $(WPA_SUPPLICANT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wpa-supplicant-source: $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) $(WPA_SUPPLICANT_PATCHES)

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
$(WPA_SUPPLICANT_BUILD_DIR)/.configured: $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) $(WPA_SUPPLICANT_PATCHES) make/wpa-supplicant.mk
	$(MAKE) openssl-stage readline-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR) $(@D)
	$(WPA_SUPPLICANT_UNZIP) $(DL_DIR)/$(WPA_SUPPLICANT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WPA_SUPPLICANT_PATCHES)" ; \
		then cat $(WPA_SUPPLICANT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR) -p1 ; \
	fi
	mkdir -p $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/proto
ifneq ($(WPA_SUPPLICANT_VERSION), 0.5.8)
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/defconfig $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/wpa_supplicant/.config
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/typedefs.h $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/wpa_supplicant/typedefs.h
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/wlioctl.h $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/wpa_supplicant/wlioctl.h
else
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/defconfig $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/.config
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/typedefs.h $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/typedefs.h
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/wlioctl.h $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/wlioctl.h
	sed -i -e 's/restrict/_&/g' $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/driver_broadcom.c
endif
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/proto/*.h $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR)/proto
	mv $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR) $(@D)
	touch $@

wpa-supplicant-unpack: $(WPA_SUPPLICANT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WPA_SUPPLICANT_BUILD_DIR)/.built: $(WPA_SUPPLICANT_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(WPA_SUPPLICANT_VERSION), 0.5.8)
	CC="$(TARGET_CC)" \
	LDFLAGS="$(STAGING_LDFLAGS)" \
	CPPFLAGS="$(STAGING_CPPFLAGS)"  \
	CFLAGS="$(STAGING_CPPFLAGS)" \
	LIBS="$(STAGING_LDFLAGS)" \
	$(MAKE) -C $(@D)/wpa_supplicant
else
	CC="$(TARGET_CC)" \
	LDFLAGS="$(STAGING_LDFLAGS)" \
	CPPFLAGS="$(STAGING_CPPFLAGS)"  \
	CFLAGS="$(STAGING_CPPFLAGS)" \
	LIBS="$(STAGING_LDFLAGS)" \
	$(MAKE) -C $(@D)
endif
	touch $@

#
# This is the build convenience target.
#
wpa-supplicant: $(WPA_SUPPLICANT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(WPA_SUPPLICANT_BUILD_DIR)/.staged: $(WPA_SUPPLICANT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#wpa-supplicant-stage: $(WPA_SUPPLICANT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wpa-supplicant
#
$(WPA_SUPPLICANT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: wpa-supplicant" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WPA_SUPPLICANT_PRIORITY)" >>$@
	@echo "Section: $(WPA_SUPPLICANT_SECTION)" >>$@
	@echo "Version: $(WPA_SUPPLICANT_VERSION)-$(WPA_SUPPLICANT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WPA_SUPPLICANT_MAINTAINER)" >>$@
	@echo "Source: $(WPA_SUPPLICANT_SITE)/$(WPA_SUPPLICANT_SOURCE)" >>$@
	@echo "Description: $(WPA_SUPPLICANT_DESCRIPTION)" >>$@
	@echo "Depends: $(WPA_SUPPLICANT_DEPENDS)" >>$@
	@echo "Suggests: $(WPA_SUPPLICANT_SUGGESTS)" >>$@
	@echo "Conflicts: $(WPA_SUPPLICANT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/etc/wpa-supplicant/...
# Documentation files should be installed in $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/doc/wpa-supplicant/...
# Daemon startup scripts should be installed in $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??wpa-supplicant
#
# You may need to patch your application to make it use these locations.
#
$(WPA_SUPPLICANT_IPK): $(WPA_SUPPLICANT_BUILD_DIR)/.built
	rm -rf $(WPA_SUPPLICANT_IPK_DIR) $(BUILD_DIR)/wpa-supplicant_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin
ifneq ($(WPA_SUPPLICANT_VERSION), 0.5.8)
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_supplicant/wpa_cli $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_cli
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_supplicant/wpa_passphrase $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_passphrase
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_supplicant/wpa_supplicant $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_supplicant
else
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_cli $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_cli
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_passphrase $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_passphrase
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_BUILD_DIR)/wpa_supplicant $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_supplicant
endif
	$(STRIP_COMMAND) $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_cli
	$(STRIP_COMMAND) $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_passphrase
	$(STRIP_COMMAND) $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/sbin/wpa_supplicant
	$(INSTALL) -d -d $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -m 644 $(WPA_SUPPLICANT_SOURCE_DIR)/wpa-supplicant.conf $(WPA_SUPPLICANT_IPK_DIR)$(TARGET_PREFIX)/etc/wpa-supplicant.conf
	$(MAKE) $(WPA_SUPPLICANT_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_SOURCE_DIR)/postinst $(WPA_SUPPLICANT_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(WPA_SUPPLICANT_SOURCE_DIR)/prerm $(WPA_SUPPLICANT_IPK_DIR)/CONTROL/prerm
	echo $(WPA_SUPPLICANT_CONFFILES) | sed -e 's/ /\n/g' > $(WPA_SUPPLICANT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WPA_SUPPLICANT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wpa-supplicant-ipk: $(WPA_SUPPLICANT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wpa-supplicant-clean:
	rm -f $(WPA_SUPPLICANT_BUILD_DIR)/.built
	-$(MAKE) -C $(WPA_SUPPLICANT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wpa-supplicant-dirclean:
	rm -rf $(BUILD_DIR)/$(WPA_SUPPLICANT_DIR) $(WPA_SUPPLICANT_BUILD_DIR) $(WPA_SUPPLICANT_IPK_DIR) $(WPA_SUPPLICANT_IPK)
#
#
# Some sanity check for the package.
#
wpa-supplicant-check: $(WPA_SUPPLICANT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

