###########################################################
#
# usb-modeswitch
#
###########################################################
#
# USB_MODESWITCH_VERSION, USB_MODESWITCH_SITE and USB_MODESWITCH_SOURCE define
# the upstream location of the source code for the package.
# USB_MODESWITCH_DIR is the directory which is created when the source
# archive is unpacked.
# USB_MODESWITCH_UNZIP is the command used to unzip the source.
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
USB_MODESWITCH_REPOSITORY=https://git.openwrt.org/project/usbmode.git
USB_MODESWITCH_VERSION=20170524
USB_MODESWITCH_COMMIT=453da8e540b1c53d357b897d6c70372cd4633390
USB_MODESWITCH_SOURCE=usb-modeswitch-$(USB_MODESWITCH_VERSION).tar.gz
USB_MODESWITCH_DIR=usb-modeswitch-$(USB_MODESWITCH_VERSION)
USB_MODESWITCH_UNZIP=zcat
USB_MODESWITCH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
USB_MODESWITCH_DESCRIPTION=USB mode switching utility
USB_MODESWITCH_SECTION=utils
USB_MODESWITCH_PRIORITY=optional
USB_MODESWITCH_DEPENDS=libubox, libblobmsg-json, libusb1
USB_MODESWITCH_SUGGESTS=
USB_MODESWITCH_CONFLICTS=

USB_MODESWITCH_DATA_URL=http://www.draisberghof.de/usb_modeswitch/$(USB_MODESWITCH_DATA_SRC)
USB_MODESWITCH_DATA_VERSION=20170205
USB_MODESWITCH_DATA_SRC=usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION).tar.bz2
USB_MODESWITCH_DATA_UNZIP=bzcat
USB_MODESWITCH_DATA_DIR=$(USB_MODESWITCH_BUILD_DIR)/usb-modeswitch-data-$(USB_MODESWITCH_DATA_VERSION)/usb_modeswitch.d

#
# USB_MODESWITCH_IPK_VERSION should be incremented when the ipk changes.
#
USB_MODESWITCH_IPK_VERSION=1

#
# USB_MODESWITCH_CONFFILES should be a list of user-editable files
#USB_MODESWITCH_CONFFILES=$(TARGET_PREFIX)/etc/usb-modeswitch.conf $(TARGET_PREFIX)/etc/init.d/SXXusb-modeswitch

#
# USB_MODESWITCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
USB_MODESWITCH_PATCHES=\
$(USB_MODESWITCH_SOURCE_DIR)/optware_config_file.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
USB_MODESWITCH_CPPFLAGS=
USB_MODESWITCH_LDFLAGS=

#
# USB_MODESWITCH_BUILD_DIR is the directory in which the build is done.
# USB_MODESWITCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# USB_MODESWITCH_IPK_DIR is the directory in which the ipk is built.
# USB_MODESWITCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
USB_MODESWITCH_BUILD_DIR=$(BUILD_DIR)/usb-modeswitch
USB_MODESWITCH_SOURCE_DIR=$(SOURCE_DIR)/usb-modeswitch
USB_MODESWITCH_IPK_DIR=$(BUILD_DIR)/usb-modeswitch-$(USB_MODESWITCH_VERSION)-ipk
USB_MODESWITCH_IPK=$(BUILD_DIR)/usb-modeswitch_$(USB_MODESWITCH_VERSION)-$(USB_MODESWITCH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: usb-modeswitch-source usb-modeswitch-unpack usb-modeswitch usb-modeswitch-stage usb-modeswitch-ipk usb-modeswitch-clean usb-modeswitch-dirclean usb-modeswitch-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(USB_MODESWITCH_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(USB_MODESWITCH_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(USB_MODESWITCH_SOURCE).sha512
#
$(DL_DIR)/$(USB_MODESWITCH_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf usb-modeswitch && \
		git clone --bare $(USB_MODESWITCH_REPOSITORY) usb-modeswitch && \
		(cd usb-modeswitch && \
		git archive --format=tar --prefix=$(USB_MODESWITCH_DIR)/ $(USB_MODESWITCH_COMMIT) | gzip > $@) && \
		rm -rf usb-modeswitch ; \
	)

$(DL_DIR)/$(USB_MODESWITCH_DATA_SRC):
	$(WGET) -O $@ $(USB_MODESWITCH_DATA_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
usb-modeswitch-source: $(DL_DIR)/$(USB_MODESWITCH_SOURCE) \
		$(DL_DIR)/$(USB_MODESWITCH_DATA_SRC) \
		$(USB_MODESWITCH_PATCHES)

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
$(USB_MODESWITCH_BUILD_DIR)/.configured: $(DL_DIR)/$(USB_MODESWITCH_SOURCE) \
		$(DL_DIR)/$(USB_MODESWITCH_DATA_SRC) \
		$(USB_MODESWITCH_PATCHES) make/usb-modeswitch.mk
	$(MAKE) libubox-stage libusb1-stage
	rm -rf $(BUILD_DIR)/$(USB_MODESWITCH_DIR) $(@D)
	$(USB_MODESWITCH_UNZIP) $(DL_DIR)/$(USB_MODESWITCH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(USB_MODESWITCH_PATCHES)" ; \
		then cat $(USB_MODESWITCH_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(USB_MODESWITCH_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(USB_MODESWITCH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(USB_MODESWITCH_DIR) $(@D) ; \
	fi
	$(USB_MODESWITCH_DATA_UNZIP) $(DL_DIR)/$(USB_MODESWITCH_DATA_SRC) | tar -C $(@D) -xvf -
	for file in $(USB_MODESWITCH_DATA_DIR)/* ; \
	do \
		if grep -q -E '(Quanta|Option|Blackberry|Pantech)Mode' "$$file" ; then \
			rm "$$file" ; \
		fi \
	done
	cp -f $(USB_MODESWITCH_SOURCE_DIR)/data/* $(USB_MODESWITCH_DATA_DIR)/
	for file in $(USB_MODESWITCH_DATA_DIR)/usb_modeswitch.d/*-* ; \
	do \
		[ -f "$$file" ] || continue ; \
		FILENAME=$$(basename $$file) ; \
		NEWNAME=$${FILENAME//-/:} ; \
		mv -f "$$file" "$(USB_MODESWITCH_DATA_DIR)/$$NEWNAME" ; \
	done
	perl $(@D)/convert-modeswitch.pl \
		$(USB_MODESWITCH_DATA_DIR)/* \
		> $(@D)/usb-mode.json
	cd $(@D); \
		CFLAGS="$(STAGING_CPPFLAGS) $(USB_MODESWITCH_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(USB_MODESWITCH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		cmake \
		$(CMAKE_CONFIGURE_OPTS) \
		-DCMAKE_C_FLAGS="$(STAGING_CPPFLAGS) $(USB_MODESWITCH_CPPFLAGS)" \
		-DCMAKE_CXX_FLAGS="$(STAGING_CPPFLAGS) $(USB_MODESWITCH_CPPFLAGS)" \
		-DCMAKE_EXE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		-DCMAKE_MODULE_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		-DCMAKE_SHARED_LINKER_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		-DCMAKE_C_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		-DCMAKE_CXX_LINK_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)" \
		-DCMAKE_SHARED_LIBRARY_C_FLAGS:STRING="$(STAGING_LDFLAGS) $(USB_MODESWITCH_LDFLAGS)"
	touch $@

usb-modeswitch-unpack: $(USB_MODESWITCH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(USB_MODESWITCH_BUILD_DIR)/.built: $(USB_MODESWITCH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
usb-modeswitch: $(USB_MODESWITCH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(USB_MODESWITCH_BUILD_DIR)/.staged: $(USB_MODESWITCH_BUILD_DIR)/.built
	rm -f $@
	touch $@

usb-modeswitch-stage: $(USB_MODESWITCH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/usb-modeswitch
#
$(USB_MODESWITCH_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: usb-modeswitch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(USB_MODESWITCH_PRIORITY)" >>$@
	@echo "Section: $(USB_MODESWITCH_SECTION)" >>$@
	@echo "Version: $(USB_MODESWITCH_VERSION)-$(USB_MODESWITCH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(USB_MODESWITCH_MAINTAINER)" >>$@
	@echo "Source: $(USB_MODESWITCH_REPOSITORY)" >>$@
	@echo "Description: $(USB_MODESWITCH_DESCRIPTION)" >>$@
	@echo "Depends: $(USB_MODESWITCH_DEPENDS)" >>$@
	@echo "Suggests: $(USB_MODESWITCH_SUGGESTS)" >>$@
	@echo "Conflicts: $(USB_MODESWITCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/sbin or $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/usb-modeswitch/...
# Documentation files should be installed in $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/doc/usb-modeswitch/...
# Daemon startup scripts should be installed in $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??usb-modeswitch
#
# You may need to patch your application to make it use these locations.
#
$(USB_MODESWITCH_IPK): $(USB_MODESWITCH_BUILD_DIR)/.built
	rm -rf $(USB_MODESWITCH_IPK_DIR) $(BUILD_DIR)/usb-modeswitch_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/sbin/ \
			$(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 755 $(USB_MODESWITCH_BUILD_DIR)/usbmode $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/sbin/
	$(INSTALL) -m 644 $(USB_MODESWITCH_BUILD_DIR)/usb-mode.json $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(STRIP_COMMAND) $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/sbin/usbmode
#	$(INSTALL) -d $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(USB_MODESWITCH_SOURCE_DIR)/usb-modeswitch.conf $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/usb-modeswitch.conf
#	$(INSTALL) -d $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(USB_MODESWITCH_SOURCE_DIR)/rc.usb-modeswitch $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXusb-modeswitch
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(USB_MODESWITCH_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXusb-modeswitch
	$(MAKE) $(USB_MODESWITCH_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(USB_MODESWITCH_SOURCE_DIR)/postinst $(USB_MODESWITCH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(USB_MODESWITCH_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(USB_MODESWITCH_SOURCE_DIR)/prerm $(USB_MODESWITCH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(USB_MODESWITCH_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(USB_MODESWITCH_IPK_DIR)/CONTROL/postinst $(USB_MODESWITCH_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(USB_MODESWITCH_CONFFILES) | sed -e 's/ /\n/g' > $(USB_MODESWITCH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(USB_MODESWITCH_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(USB_MODESWITCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
usb-modeswitch-ipk: $(USB_MODESWITCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
usb-modeswitch-clean:
	rm -f $(USB_MODESWITCH_BUILD_DIR)/.built
	-$(MAKE) -C $(USB_MODESWITCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
usb-modeswitch-dirclean:
	rm -rf $(BUILD_DIR)/$(USB_MODESWITCH_DIR) $(USB_MODESWITCH_BUILD_DIR) $(USB_MODESWITCH_IPK_DIR) $(USB_MODESWITCH_IPK)
#
#
# Some sanity check for the package.
#
usb-modeswitch-check: $(USB_MODESWITCH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
