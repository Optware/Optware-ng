###########################################################
#
# fsg3-kernel-modules
#
###########################################################

FSG3-KERNEL-MODULES_SITE=http://www.openfsg.com/download
FSG3-KERNEL-MODULES_VERSION=2.4.27
FSG3-KERNEL-MODULES_SOURCE=source-fcsnap-3.1.15.tar.bz2
FSG3-KERNEL-MODULES_DIR=fcsnap
FSG3-KERNEL-MODULES_UNZIP=bzcat
FSG3-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FSG3-KERNEL-MODULES_DESCRIPTION=FSG-3 kernel modules
FSG3-KERNEL-MODULES_SECTION=kernel
FSG3-KERNEL-MODULES_PRIORITY=optional
FSG3-KERNEL-MODULES_DEPENDS=
FSG3-KERNEL-MODULES_SUGGESTS=
FSG3-KERNEL-MODULES_CONFLICTS=
FSG3-KERNEL-MODULES= \
	mii \
	tun \
	usbnet \
	usbserial ftdi_sio pl2303 mct_u232 \
	ip_conntrack_ftp ip_nat_ftp

# videodev pwc nfsd soundcore audio rtl8150 hfc_usb isdn isdn_bsdcomp dss1_divert hisax slhc

#
# FSG3-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
FSG3-KERNEL-MODULES_IPK_VERSION=4

#
# FSG3-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#FSG3-KERNEL-MODULES_CONFFILES=/opt/etc/fsg3-kernel-modules.conf /opt/etc/init.d/SXXfsg3-kernel-modules

#
# FSG3-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FSG3-KERNEL-MODULES_PATCHES=
#  $(FSG3-KERNEL-MODULES_SOURCE_DIR)/pwc.patch \
#  $(FSG3-KERNEL-MODULES_SOURCE_DIR)/pwc-fix_endianness.patch \
#  $(FSG3-KERNEL-MODULES_SOURCE_DIR)/hfc_usb.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FSG3-KERNEL-MODULES_CPPFLAGS=
FSG3-KERNEL-MODULES_LDFLAGS=

FSG3-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/fsg3-kernel-modules
FSG3-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/fsg3-kernel-modules
FSG3-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/fsg3-kernel-modules-$(FSG3-KERNEL-MODULES_VERSION)-ipk
FSG3-KERNEL-MODULES_IPK=$(BUILD_DIR)/fsg3-kernel-modules_$(FSG3-KERNEL-MODULES_VERSION)-$(FSG3-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FSG3-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(FSG3-KERNEL-MODULES_SITE)/$(FSG3-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fsg3-kernel-modules-source: $(DL_DIR)/$(FSG3-KERNEL-MODULES_SOURCE) $(FSG3-KERNEL-MODULES_PATCHES)

$(FSG3-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(FSG3-KERNEL-MODULES_SOURCE) $(FSG3-KERNEL-MODULES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FSG3-KERNEL-MODULES_DIR) $(FSG3-KERNEL-MODULES_BUILD_DIR)
	$(FSG3-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(FSG3-KERNEL-MODULES_SOURCE) | \
		tar -C $(BUILD_DIR) -xvf - fcsnap/Makefile fcsnap/linux-2.4.x fcsnap/freeswan
	if test -n "$(FSG3-KERNEL-MODULES_PATCHES)" ; \
		then cat $(FSG3-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FSG3-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FSG3-KERNEL-MODULES_DIR)" != "$(FSG3-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FSG3-KERNEL-MODULES_DIR) $(FSG3-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(FSG3-KERNEL-MODULES_BUILD_DIR)/.configured

fsg3-kernel-modules-unpack: $(FSG3-KERNEL-MODULES_BUILD_DIR)/.configured

FSG3-KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(FSG3-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(FSG3-KERNEL-MODULES_BUILD_DIR)/.built: $(FSG3-KERNEL-MODULES_BUILD_DIR)/.configured \
		$(FSG3-KERNEL-MODULES_SOURCE_DIR)/defconfig make/fsg3-kernel-modules.mk
	rm -f $(FSG3-KERNEL-MODULES_BUILD_DIR)/.built
#	$(MAKE) -C $(FSG3-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x $(FSG3-KERNEL-MODULES-FLAGS) clean
	cp  $(FSG3-KERNEL-MODULES_SOURCE_DIR)/defconfig $(FSG3-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x/.config;
	$(MAKE) -C $(FSG3-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x $(FSG3-KERNEL-MODULES-FLAGS) oldconfig dep
	$(MAKE) -C $(FSG3-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x $(FSG3-KERNEL-MODULES-FLAGS) all modules
	touch $(FSG3-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
fsg3-kernel-modules: $(FSG3-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fsg3-kernel-modules
#
$(FSG3-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	for m in $(FSG3-KERNEL-MODULES); do \
	  install -d $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL; \
	  rm -f $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
          ( \
	    echo "Package: kernel-module-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(FSG3-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(FSG3-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(FSG3-KERNEL-MODULES_VERSION)-$(FSG3-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(FSG3-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(FSG3-KERNEL-MODULES_SITE)/$(FSG3-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(FSG3-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(FSG3-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "^$$m:" $(FSG3-KERNEL-MODULES_SOURCE_DIR)/modules.dep|cut -d ":" -f 2|sed -e 's/_/-/g'`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      DEPS="$$DEPS kernel-modules-$$i"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(FSG3-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(FSG3-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
	done
	install -d $(FSG3-KERNEL-MODULES_IPK_DIR)/CONTROL; \
	touch $(FSG3-KERNEL-MODULES_IPK_DIR)/CONTROL/control
#
# This builds the IPK file.
#
# Binaries should be installed into $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/etc/fsg3-kernel-modules/...
# Documentation files should be installed in $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/doc/fsg3-kernel-modules/...
# Daemon startup scripts should be installed in $(FSG3-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??fsg3-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(FSG3-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(FSG3-KERNEL-MODULES_BUILD_DIR)/.built
	rm -rf $(FSG3-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/fsg3-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(FSG3-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(FSG3-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(FSG3-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x $(FSG3-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(FSG3-KERNEL-MODULES_IPK_DIR) DEPMOD=true modules_install
	for m in $(FSG3-KERNEL-MODULES); do \
	  install -d $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	  install -m 644 `find $(FSG3-KERNEL-MODULES_IPK_DIR) -name $$m.o` $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	done
	$(MAKE) $(FSG3-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(FSG3-KERNEL-MODULES); do \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3-KERNEL-MODULES_IPK_DIR)-$$m; \
	done
	touch $(FSG3-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
fsg3-kernel-modules-ipk: $(FSG3-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
fsg3-kernel-modules-clean:
	rm -f $(FSG3-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(FSG3-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fsg3-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(FSG3-KERNEL-MODULES_DIR) $(FSG3-KERNEL-MODULES_BUILD_DIR) $(FSG3-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-modules-*_powerpc.ipk
