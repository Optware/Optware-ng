###########################################################
#
# fsg3v4-kernel-modules
#
###########################################################

FSG3V4-KERNEL-MODULES_SITE=http://www.kernel.org/pub/linux/kernel/v2.6/
FSG3V4-KERNEL-MODULES_SOURCE=linux-2.6.18.tar.bz2
FSG3V4-KERNEL-MODULES_VERSION=2.6.18
FSG3V4-KERNEL-MODULES_DIR=linux-2.6.18
FSG3V4-KERNEL-MODULES_UNZIP=bzcat
FSG3V4-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FSG3V4-KERNEL-MODULES_DESCRIPTION=FSG-3 V4 kernel modules
FSG3V4-KERNEL-IMAGE_DESCRIPTION=FSG-3 V4 kernel
FSG3V4-KERNEL-MODULES_SECTION=kernel
FSG3V4-KERNEL-MODULES_PRIORITY=optional
FSG3V4-KERNEL-MODULES_DEPENDS=
FSG3V4-KERNEL-MODULES_SUGGESTS=
FSG3V4-KERNEL-MODULES_CONFLICTS=
FSG3V4-KERNEL-MODULES= \
	tun \
	usbnet asix cdc_ether kaweth net1080 pegasus zaurus \
	usbserial ftdi_sio mct_u232 pl2303 \
	firmware_class \
	hci_usb bluetooth bnep l2cap rfcomm sco \
	exportfs lockd nfs nfsd sunrpc

# videodev pwc nfsd soundcore audio rtl8150 hfc_usb isdn isdn_bsdcomp dss1_divert hisax slhc

#
# FSG3V4-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
FSG3V4-KERNEL-MODULES_IPK_VERSION=2

#
# FSG3V4-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#FSG3V4-KERNEL-MODULES_CONFFILES=/opt/etc/fsg3v4-kernel-modules.conf /opt/etc/init.d/SXXfsg3v4-kernel-modules

#
# FSG3V4-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FSG3V4-KERNEL-MODULES_PATCHES = \
	$(FSG3V4-KERNEL-MODULES_SOURCE_DIR)/linux-2.6.18-fsg3.patch \
	$(FSG3V4-KERNEL-MODULES_SOURCE_DIR)/10-remove-ixp4xx-drivers.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FSG3V4-KERNEL-MODULES_CPPFLAGS=
FSG3V4-KERNEL-MODULES_LDFLAGS=

FSG3V4-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/fsg3v4-kernel-modules
FSG3V4-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/fsg3v4-kernel-modules
FSG3V4-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/fsg3v4-kernel-modules-$(FSG3V4-KERNEL-MODULES_VERSION)-ipk
FSG3V4-KERNEL-MODULES_IPK=$(BUILD_DIR)/fsg3v4-kernel-modules_$(FSG3V4-KERNEL-MODULES_VERSION)-$(FSG3V4-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

FSG3V4-KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/fsg3v4-kernel-image-$(FSG3V4-KERNEL-MODULES_VERSION)-ipk
FSG3V4-KERNEL-IMAG_IPK=$(BUILD_DIR)/fsg3v4-kernel-image_$(FSG3V4-KERNEL-MODULES_VERSION)-$(FSG3V4-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FSG3V4-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(FSG3V4-KERNEL-MODULES_SITE)/$(FSG3V4-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fsg3v4-kernel-modules-source: $(DL_DIR)/$(FSG3V4-KERNEL-MODULES_SOURCE) $(FSG3V4-KERNEL-MODULES_PATCHES)

$(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(FSG3V4-KERNEL-MODULES_SOURCE) $(FSG3V4-KERNEL-MODULES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FSG3V4-KERNEL-MODULES_DIR) $(FSG3V4-KERNEL-MODULES_BUILD_DIR)
	$(FSG3V4-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(FSG3V4-KERNEL-MODULES_SOURCE) | \
		tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FSG3V4-KERNEL-MODULES_PATCHES)" ; \
		then cat $(FSG3V4-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FSG3V4-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FSG3V4-KERNEL-MODULES_DIR)" != "$(FSG3V4-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FSG3V4-KERNEL-MODULES_DIR) $(FSG3V4-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.configured

fsg3v4-kernel-modules-unpack: $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.configured

FSG3V4-KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(FSG3V4-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built: $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.configured \
		$(FSG3V4-KERNEL-MODULES_SOURCE_DIR)/defconfig make/fsg3v4-kernel-modules.mk
	rm -f $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built
#	$(MAKE) -C $(FSG3V4-KERNEL-MODULES_BUILD_DIR) $(FSG3V4-KERNEL-MODULES-FLAGS) clean
	cp  $(FSG3V4-KERNEL-MODULES_SOURCE_DIR)/defconfig $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.config;
	$(MAKE) -C $(FSG3V4-KERNEL-MODULES_BUILD_DIR) $(FSG3V4-KERNEL-MODULES-FLAGS) oldconfig
	$(MAKE) -C $(FSG3V4-KERNEL-MODULES_BUILD_DIR) $(FSG3V4-KERNEL-MODULES-FLAGS) all modules
	touch $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
fsg3v4-kernel-modules: $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fsg3v4-kernel-modules
#
$(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL
	( \
	  echo "Package: kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(FSG3V4-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(FSG3V4-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(FSG3V4-KERNEL-MODULES_VERSION)-$(FSG3V4-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(FSG3V4-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(FSG3V4-KERNEL-MODULES_SITE)/$(FSG3V4-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(FSG3V4-KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: kernel-image"; \
	) >> $(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	for m in $(FSG3V4-KERNEL-MODULES); do \
	  install -d $(FSG3V4-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL; \
	  rm -f $(FSG3V4-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
          ( \
	    echo -n ", kernel-module-`echo $$m|sed -e 's/_/-/g'`" >> $(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	    echo "Package: kernel-module-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(FSG3V4-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(FSG3V4-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(FSG3V4-KERNEL-MODULES_VERSION)-$(FSG3V4-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(FSG3V4-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(FSG3V4-KERNEL-MODULES_SITE)/$(FSG3V4-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(FSG3V4-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(FSG3V4-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(FSG3V4-KERNEL-MODULES_VERSION)/modules.dep|cut -d ":" -f 2|sed -e 's/_/-/g'`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      DEPS="$$DEPS kernel-module-$$i"; \
            done; \
            echo "$$DEPS" | sed -e 's|/.*/||g' -e 's|\.ko||g';\
	    echo "Suggests: $(FSG3V4-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(FSG3V4-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(FSG3V4-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
	done
	echo "" >> $(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL/control

$(FSG3V4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(FSG3V4-KERNEL-IMAGE_IPK_DIR)/CONTROL
	rm -f $(FSG3V4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	( \
	  echo "Package: kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(FSG3V4-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(FSG3V4-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(FSG3V4-KERNEL-MODULES_VERSION)-$(FSG3V4-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(FSG3V4-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(FSG3V4-KERNEL-MODULES_SITE)/$(FSG3V4-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(FSG3V4-KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $(FSG3V4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control

#
# This builds the IPK file.
#
# Binaries should be installed into $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/etc/fsg3v4-kernel-modules/...
# Documentation files should be installed in $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/doc/fsg3v4-kernel-modules/...
# Daemon startup scripts should be installed in $(FSG3V4-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??fsg3v4-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built
	# Package the kernel image first
	rm -rf $(FSG3V4-KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/fsg3v4-kernel-image_*_$(TARGET_ARCH).ipk
	$(MAKE) $(FSG3V4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	install -m 644 $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/zImage $(FSG3V4-KERNEL-IMAGE_IPK_DIR)
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3V4-KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(FSG3V4-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/fsg3v4-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(FSG3V4-KERNEL-MODULES_BUILD_DIR) $(FSG3V4-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(FSG3V4-KERNEL-MODULES_IPK_DIR) modules_install
	for m in $(FSG3V4-KERNEL-MODULES); do \
	  ( cd $(FSG3V4-KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -name $$m.ko` $(FSG3V4-KERNEL-MODULES_IPK_DIR)-$$m/`find . -name $$m.ko` ); \
	done
	$(MAKE) $(FSG3V4-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(FSG3V4-KERNEL-MODULES); do \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3V4-KERNEL-MODULES_IPK_DIR)-$$m; \
	done
	rm -f $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(FSG3V4-KERNEL-MODULES_VERSION)/build
	rm -f $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(FSG3V4-KERNEL-MODULES_VERSION)/source
	rm -rf $(FSG3V4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(FSG3V4-KERNEL-MODULES_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3V4-KERNEL-MODULES_IPK_DIR) )
	touch $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
fsg3v4-kernel-modules-ipk: $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
fsg3v4-kernel-modules-clean:
	rm -f $(FSG3V4-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(FSG3V4-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fsg3v4-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(FSG3V4-KERNEL-MODULES_DIR) $(FSG3V4-KERNEL-MODULES_BUILD_DIR)
	rm -rf $(FSG3V4-KERNEL-MODULES_IPK_DIR)* $(FSG3V4-KERNEL-IMAGE_IPK_DIR)* 
	rm -f $(BUILD_DIR)/kernel-modules_*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-modules-*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-image-*_armeb.ipk

# LocalWords:  fsg
