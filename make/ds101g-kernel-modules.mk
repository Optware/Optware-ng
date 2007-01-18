###########################################################
#
# ds101g-kernel-modules
#
###########################################################

DS101G-KERNEL-MODULES_SITE=http://www.dachsweb.de
DS101G-KERNEL-MODULES_VERSION=2.4.22
DS101G-KERNEL-MODULES_SOURCE=synology-linux-$(DS101G-KERNEL-MODULES_VERSION).tar.bz2
DS101G-KERNEL-MODULES_DIR=linux-$(DS101G-KERNEL-MODULES_VERSION)
DS101G-KERNEL-MODULES_UNZIP=bzcat
DS101G-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DS101G-KERNEL-MODULES_DESCRIPTION=DS-101G+ kernel module
DS101G-KERNEL-MODULES_SECTION=kernel
DS101G-KERNEL-MODULES_PRIORITY=optional
DS101G-KERNEL-MODULES_DEPENDS=
DS101G-KERNEL-MODULES_SUGGESTS=
DS101G-KERNEL-MODULES_CONFLICTS=
DS101G-KERNEL-MODULES=videodev pwc nfsd soundcore audio rtl8150 hfc_usb \
	isdn isdn_bsdcomp dss1_divert hisax slhc isofs sr_mod cdrom \
	ethertap tun

#
# DS101G-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
DS101G-KERNEL-MODULES_IPK_VERSION=5

#
# DS101G-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#DS101G-KERNEL-MODULES_CONFFILES=/opt/etc/ds101g-kernel-modules.conf /opt/etc/init.d/SXXds101g-kernel-modules

#
# DS101G-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DS101G-KERNEL-MODULES_PATCHES=\
  $(DS101G-KERNEL-MODULES_SOURCE_DIR)/pwc.patch \
  $(DS101G-KERNEL-MODULES_SOURCE_DIR)/pwc-fix_endianness.patch \
  $(DS101G-KERNEL-MODULES_SOURCE_DIR)/hfc_usb.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DS101G-KERNEL-MODULES_CPPFLAGS=
DS101G-KERNEL-MODULES_LDFLAGS=

DS101G-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/ds101g-kernel-modules
DS101G-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/ds101g-kernel-modules
DS101G-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/ds101g-kernel-modules-$(DS101G-KERNEL-MODULES_VERSION)-ipk
DS101G-KERNEL-MODULES_IPK=$(BUILD_DIR)/ds101g-kernel-modules_$(DS101G-KERNEL-MODULES_VERSION)-$(DS101G-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DS101G-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(DS101G-KERNEL-MODULES_SITE)/$(DS101G-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ds101g-kernel-modules-source: $(DL_DIR)/$(DS101G-KERNEL-MODULES_SOURCE) $(DS101G-KERNEL-MODULES_PATCHES)

$(DS101G-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(DS101G-KERNEL-MODULES_SOURCE) $(DS101G-KERNEL-MODULES_PATCHES) make/ds101g-kernel-modules.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DS101G-KERNEL-MODULES_DIR) $(DS101G-KERNEL-MODULES_BUILD_DIR)
	$(DS101G-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(DS101G-KERNEL-MODULES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DS101G-KERNEL-MODULES_PATCHES)" ; \
		then cat $(DS101G-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DS101G-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DS101G-KERNEL-MODULES_DIR)" != "$(DS101G-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DS101G-KERNEL-MODULES_DIR) $(DS101G-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	(cd $(DS101G-KERNEL-MODULES_BUILD_DIR); \
	  cp  $(DS101G-KERNEL-MODULES_SOURCE_DIR)/Makefile.powerpc .; \
	  sed -e 's|@TARGET_CROSS@|$(TARGET_CROSS)|' Makefile.powerpc >Makefile; \
	  cp  $(DS101G-KERNEL-MODULES_SOURCE_DIR)/powerpc-config .config; \
	  $(MAKE) oldconfig; $(MAKE) dep \
	)
	touch $(DS101G-KERNEL-MODULES_BUILD_DIR)/.configured

ds101g-kernel-modules-unpack: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DS101G-KERNEL-MODULES_BUILD_DIR)/.built: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(DS101G-KERNEL-MODULES_BUILD_DIR)/.built
	$(MAKE) -C $(DS101G-KERNEL-MODULES_BUILD_DIR) modules
	touch $(DS101G-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ds101g-kernel-modules: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.built

#
## If you are building a library, then you need to stage it too.
#
$(DS101G-KERNEL-MODULES_BUILD_DIR)/.staged: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(DS101G-KERNEL-MODULES_BUILD_DIR)/.staged
	mkdir -p $(STAGING_DIR)/src/linux
	cp -a $(DS101G-KERNEL-MODULES_BUILD_DIR)/* $(STAGING_DIR)/src/linux
	touch $(DS101G-KERNEL-MODULES_BUILD_DIR)/.staged

ds101g-kernel-modules-stage: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ds101g-kernel-modules
#
$(DS101G-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	for m in $(DS101G-KERNEL-MODULES); do \
	  install -d $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL; \
	  rm -f $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
          ( \
	    echo "Package: kernel-module-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(DS101G-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(DS101G-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(DS101G-KERNEL-MODULES_VERSION)-$(DS101G-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Replaces: kernel-modules-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Maintainer: $(DS101G-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(DS101G-KERNEL-MODULES_SITE)/$(DS101G-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(DS101G-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(DS101G-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "^$$m:" $(DS101G-KERNEL-MODULES_SOURCE_DIR)/modules.dep|cut -d ":" -f 2|sed -e 's/_/-/g'`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      DEPS="$$DEPS kernel-module-$$i"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(DS101G-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(DS101G-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
	done
	install -d $(DS101G-KERNEL-MODULES_IPK_DIR)/CONTROL; \
	touch $(DS101G-KERNEL-MODULES_IPK_DIR)/CONTROL/control
#
# This builds the IPK file.
#
# Binaries should be installed into $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/etc/ds101g-kernel-modules/...
# Documentation files should be installed in $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/doc/ds101g-kernel-modules/...
# Daemon startup scripts should be installed in $(DS101G-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??ds101g-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(DS101G-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.built
	rm -rf $(DS101G-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module_*_$(TARGET_ARCH).ipk
	INSTALL_MOD_PATH=$(DS101G-KERNEL-MODULES_IPK_DIR)/opt \
	$(MAKE) -C $(DS101G-KERNEL-MODULES_BUILD_DIR) modules_install
	rm -rf $(DS101G-KERNEL-MODULES_IPK_DIR)/lib/modules/2.4.22-uc0/kernel/drivers/synobios
	for m in $(DS101G-KERNEL-MODULES); do \
	  install -d $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	  install -m 644 `find $(DS101G-KERNEL-MODULES_IPK_DIR) -name $$m.o` $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	done
	$(MAKE) $(DS101G-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(DS101G-KERNEL-MODULES); do \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(DS101G-KERNEL-MODULES_IPK_DIR)-$$m; \
	done
	touch $(DS101G-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
ds101g-kernel-modules-ipk: $(DS101G-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
ds101g-kernel-modules-clean:
	rm -f $(DS101G-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(DS101G-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ds101g-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(DS101G-KERNEL-MODULES_DIR) $(DS101G-KERNEL-MODULES_BUILD_DIR) $(DS101G-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module-*_powerpc.ipk
