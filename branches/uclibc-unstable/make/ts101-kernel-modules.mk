###########################################################
#
# ts101-kernel-modules
#
###########################################################

TS101-KERNEL-MODULES_SITE=http://mirror.kynisk.com/ts/kernel/
TS101-KERNEL-MODULES_VERSION=2.6.12.3
TS101-KERNEL-MODULES_SOURCE=qnap-kernel-$(TS101-KERNEL-MODULES_VERSION).tar.bz2
TS101-KERNEL-MODULES_DIR=linux-$(TS101-KERNEL-MODULES_VERSION)
TS101-KERNEL-MODULES_UNZIP=bzcat
TS101-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TS101-KERNEL-MODULES_DESCRIPTION=TS-101 kernel module
TS101-KERNEL-MODULES_SECTION=kernel
TS101-KERNEL-MODULES_PRIORITY=optional
TS101-KERNEL-MODULES_DEPENDS=
TS101-KERNEL-MODULES_SUGGESTS=
TS101-KERNEL-MODULES_CONFLICTS=
#TS101-KERNEL-MODULES=videodev pwc nfsd soundcore audio rtl8150 hfc_usb \
#	isdn isdn_bsdcomp dss1_divert hisax slhc isofs sr_mod cdrom \
#	ethertap tun

#
# TS101-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
TS101-KERNEL-MODULES_IPK_VERSION=1

#
# TS101-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#TS101-KERNEL-MODULES_CONFFILES=/opt/etc/ts101-kernel-modules.conf /opt/etc/init.d/SXXts101-kernel-modules

#
# TS101-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TS101-KERNEL-MODULES_PATCHES=\
#  $(TS101-KERNEL-MODULES_SOURCE_DIR)/pwc.patch \
#  $(TS101-KERNEL-MODULES_SOURCE_DIR)/pwc-fix_endianness.patch \
#  $(TS101-KERNEL-MODULES_SOURCE_DIR)/hfc_usb.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TS101-KERNEL-MODULES_CPPFLAGS=
TS101-KERNEL-MODULES_LDFLAGS=

TS101-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/ts101-kernel-modules
TS101-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/ts101-kernel-modules
TS101-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/ts101-kernel-modules-$(TS101-KERNEL-MODULES_VERSION)-ipk
TS101-KERNEL-MODULES_IPK=$(BUILD_DIR)/ts101-kernel-modules_$(TS101-KERNEL-MODULES_VERSION)-$(TS101-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TS101-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(TS101-KERNEL-MODULES_SITE)/$(TS101-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ts101-kernel-modules-source: $(DL_DIR)/$(TS101-KERNEL-MODULES_SOURCE) $(TS101-KERNEL-MODULES_PATCHES)

$(TS101-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(TS101-KERNEL-MODULES_SOURCE) $(TS101-KERNEL-MODULES_PATCHES) make/ts101-kernel-modules.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TS101-KERNEL-MODULES_DIR) $(TS101-KERNEL-MODULES_BUILD_DIR)
	$(TS101-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(TS101-KERNEL-MODULES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TS101-KERNEL-MODULES_PATCHES)" ; \
		then cat $(TS101-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TS101-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TS101-KERNEL-MODULES_DIR)" != "$(TS101-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TS101-KERNEL-MODULES_DIR) $(TS101-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	(cd $(TS101-KERNEL-MODULES_BUILD_DIR); \
	  cp  $(TS101-KERNEL-MODULES_SOURCE_DIR)/kernel.defconfig .config; \
	  ARCH=ppc $(MAKE) oldconfig \
	)
	touch $(TS101-KERNEL-MODULES_BUILD_DIR)/.configured

ts101-kernel-modules-unpack: $(TS101-KERNEL-MODULES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TS101-KERNEL-MODULES_BUILD_DIR)/.built: $(TS101-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(TS101-KERNEL-MODULES_BUILD_DIR)/.built
	ARCH=ppc CROSS_COMPILE=$(TARGET_CROSS) $(MAKE) -C $(TS101-KERNEL-MODULES_BUILD_DIR) modules
	touch $(TS101-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ts101-kernel-modules: $(TS101-KERNEL-MODULES_BUILD_DIR)/.built

#
## If you are building a library, then you need to stage it too.
#
$(TS101-KERNEL-MODULES_BUILD_DIR)/.staged: $(TS101-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(TS101-KERNEL-MODULES_BUILD_DIR)/.staged
	mkdir -p $(STAGING_DIR)/src/linux
	cp -a $(TS101-KERNEL-MODULES_BUILD_DIR)/* $(STAGING_DIR)/src/linux
	touch $(TS101-KERNEL-MODULES_BUILD_DIR)/.staged

ts101-kernel-modules-stage: $(TS101-KERNEL-MODULES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ts101-kernel-modules
#
$(TS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	for m in $(TS101-KERNEL-MODULES); do \
	  install -d $(TS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL; \
	  rm -f $(TS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
          ( \
	    echo "Package: kernel-module-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(TS101-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(TS101-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(TS101-KERNEL-MODULES_VERSION)-$(TS101-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Replaces: kernel-modules-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Maintainer: $(TS101-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(TS101-KERNEL-MODULES_SITE)/$(TS101-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(TS101-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(TS101-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "^$$m:" $(TS101-KERNEL-MODULES_SOURCE_DIR)/modules.dep|cut -d ":" -f 2|sed -e 's/_/-/g'`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      DEPS="$$DEPS kernel-module-$$i"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(TS101-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(TS101-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(TS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
	done
	install -d $(TS101-KERNEL-MODULES_IPK_DIR)/CONTROL; \
	touch $(TS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control
#
# This builds the IPK file.
#
# Binaries should be installed into $(TS101-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(TS101-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TS101-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TS101-KERNEL-MODULES_IPK_DIR)/opt/etc/ts101-kernel-modules/...
# Documentation files should be installed in $(TS101-KERNEL-MODULES_IPK_DIR)/opt/doc/ts101-kernel-modules/...
# Daemon startup scripts should be installed in $(TS101-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??ts101-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(TS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(TS101-KERNEL-MODULES_BUILD_DIR)/.built
	rm -rf $(TS101-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module_*_$(TARGET_ARCH).ipk
	INSTALL_MOD_PATH=$(TS101-KERNEL-MODULES_IPK_DIR)/opt \
	$(MAKE) -C $(TS101-KERNEL-MODULES_BUILD_DIR) modules_install
	for m in $(TS101-KERNEL-MODULES); do \
	  install -d $(TS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	  install -m 644 `find $(TS101-KERNEL-MODULES_IPK_DIR) -name $$m.ko` $(TS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	done
	$(MAKE) $(TS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(TS101-KERNEL-MODULES); do \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(TS101-KERNEL-MODULES_IPK_DIR)-$$m; \
	done
	touch $(TS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
ts101-kernel-modules-ipk: $(TS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
ts101-kernel-modules-clean:
	rm -f $(TS101-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(TS101-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ts101-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(TS101-KERNEL-MODULES_DIR) $(TS101-KERNEL-MODULES_BUILD_DIR) $(TS101-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module-*_powerpc.ipk
