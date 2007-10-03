###########################################################
#
# mssii-kernel-modules
#
###########################################################

#MSSII-KERNEL-MODULES_SITE=http://www.kernel.org/pub/linux/kernel/v2.6
#MSSII-KERNEL-MODULES_VERSION=2.6.12.6
MSSII-KERNEL-MODULES_SOURCE=MSSII_3.1.2.src-kernel.tar.bz2
MSSII-KERNEL-MODULES_DIR=linux-$(MSSII-KERNEL-MODULES_VERSION)
MSSII-KERNEL-MODULES_UNZIP=bzcat
MSSII-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MSSII-KERNEL-MODULES_DESCRIPTION=MSS II kernel modules
MSSII-KERNEL-IMAGE_DESCRIPTION=MSS II kernel
MSSII-KERNEL-MODULES_SECTION=kernel
MSSII-KERNEL-MODULES_PRIORITY=optional
MSSII-KERNEL-MODULES_DEPENDS=
MSSII-KERNEL-MODULES_SUGGESTS=
MSSII-KERNEL-MODULES_CONFLICTS=
MSSII-KERNEL-MODULES=`find $(MSSII-KERNEL-MODULES_IPK_DIR) -name *.ko`

#
# MSSII-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
MSSII-KERNEL-MODULES_IPK_VERSION=1

#
# MSSII-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#MSSII-KERNEL-MODULES_CONFFILES=/opt/etc/mssii-kernel-modules.conf /opt/etc/init.d/SXXmssii-kernel-modules

#
# MSSII-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MSSII-KERNEL-MODULES_PATCHES = \
	$(MSSII-KERNEL-MODULES_SOURCE_DIR)/arch-arm-Makefile.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MSSII-KERNEL-MODULES_CPPFLAGS=
MSSII-KERNEL-MODULES_LDFLAGS=

MSSII-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/mssii-kernel-modules
MSSII-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/mssii-kernel-modules
MSSII-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/mssii-kernel-modules-$(MSSII-KERNEL-MODULES_VERSION)-ipk
MSSII-KERNEL-MODULES_IPK=$(BUILD_DIR)/mssii-kernel-modules_$(MSSII-KERNEL-MODULES_VERSION)-$(MSSII-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

MSSII-KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/mssii-kernel-image-$(MSSII-KERNEL-MODULES_VERSION)-ipk
MSSII-KERNEL-IMAG_IPK=$(BUILD_DIR)/mssii-kernel-image_$(MSSII-KERNEL-MODULES_VERSION)-$(MSSII-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MSSII-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(MSSII-KERNEL-MODULES_SITE)/$(MSSII-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mssii-kernel-modules-source: $(DL_DIR)/$(MSSII-KERNEL-MODULES_SOURCE) $(MSSII-KERNEL-MODULES_PATCHES)

$(MSSII-KERNEL-MODULES_BUILD_DIR)/.configured: \
$(DL_DIR)/$(MSSII-KERNEL-MODULES_SOURCE) \
$(MSSII-KERNEL-MODULES_PATCHES) \
$(MSSII-KERNEL-MODULES_SOURCE_DIR)/defconfig \
make/mssii-kernel-modules.mk
	$(MAKE) u-boot-mkimage
	rm -rf $(BUILD_DIR)/$(MSSII-KERNEL-MODULES_DIR) $(MSSII-KERNEL-MODULES_BUILD_DIR)
	mkdir -p $(MSSII-KERNEL-MODULES_BUILD_DIR)
	$(MSSII-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(MSSII-KERNEL-MODULES_SOURCE) | \
		tar -C $(MSSII-KERNEL-MODULES_BUILD_DIR) -xvf -
	if test -n "$(MSSII-KERNEL-MODULES_PATCHES)" ; \
		then cat $(MSSII-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MSSII-KERNEL-MODULES_DIR) -p1 ; \
	fi
#	if test "$(BUILD_DIR)/$(MSSII-KERNEL-MODULES_DIR)" != "$(MSSII-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MSSII-KERNEL-MODULES_DIR) $(MSSII-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $@

mssii-kernel-modules-unpack: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.configured

MSSII-KERNEL-MODULES-FLAGS = ARCH=arm EXTRAVERSION=.6-arm1 ROOTDIR=$(MSSII-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(MSSII-KERNEL-MODULES_BUILD_DIR)/.built: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) $(MSSII-KERNEL-MODULES-FLAGS) clean
	cp  $(MSSII-KERNEL-MODULES_SOURCE_DIR)/defconfig $(MSSII-KERNEL-MODULES_BUILD_DIR)/.config;
	$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) $(MSSII-KERNEL-MODULES-FLAGS) oldconfig
	PATH=$(HOST_STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) $(MSSII-KERNEL-MODULES-FLAGS) uImage modules
	touch $@

ifeq ($(OPTWARE_TARGET), mssii)
kmod: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.built
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/mssii-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) $(MSSII-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(MSSII-KERNEL-MODULES_IPK_DIR) modules_install
endif

#
# This is the build convenience target.
#
mssii-kernel-modules: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mssii-kernel-modules
#
$(MSSII-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(@D)
	( \
	  echo "Package: kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(MSSII-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(MSSII-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(MSSII-KERNEL-MODULES_VERSION)-$(MSSII-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(MSSII-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(MSSII-KERNEL-MODULES_SITE)/$(MSSII-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(MSSII-KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: kernel-image"; \
	) >> $(MSSII-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	for m in $(MSSII-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  install -d $(MSSII-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL; \
	  rm -f $(MSSII-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
          ( \
	    echo -n ", kernel-module-$$n" >> $(MSSII-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	    echo "Package: kernel-module-$$n"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(MSSII-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(MSSII-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(MSSII-KERNEL-MODULES_VERSION)-$(MSSII-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(MSSII-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(MSSII-KERNEL-MODULES_SITE)/$(MSSII-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(MSSII-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(MSSII-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules/$(MSSII-KERNEL-MODULES_VERSION)/modules.dep|cut -d ":" -f 2`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      j=`basename $$i .ko | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	      DEPS="$$DEPS kernel-module-$$j"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(MSSII-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(MSSII-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(MSSII-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
	done
	echo "" >> $(MSSII-KERNEL-MODULES_IPK_DIR)/CONTROL/control

$(MSSII-KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(@D)
	rm -f $(MSSII-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	( \
	  echo "Package: kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(MSSII-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(MSSII-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(MSSII-KERNEL-MODULES_VERSION)-$(MSSII-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(MSSII-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(MSSII-KERNEL-MODULES_SITE)/$(MSSII-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(MSSII-KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $(MSSII-KERNEL-IMAGE_IPK_DIR)/CONTROL/control

#
# This builds the IPK file.
#
# Binaries should be installed into $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/etc/mssii-kernel-modules/...
# Documentation files should be installed in $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/doc/mssii-kernel-modules/...
# Daemon startup scripts should be installed in $(MSSII-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??mssii-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(MSSII-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
	# Package the kernel image first
	rm -rf $(MSSII-KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/mssii-kernel-image_*_$(TARGET_ARCH).ipk
	$(MAKE) $(MSSII-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	install -m 644 $(MSSII-KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/zImage $(MSSII-KERNEL-IMAGE_IPK_DIR)
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(MSSII-KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/mssii-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) $(MSSII-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(MSSII-KERNEL-MODULES_IPK_DIR) modules_install
	for m in $(MSSII-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  ( cd $(MSSII-KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -iname $$m.ko` $(MSSII-KERNEL-MODULES_IPK_DIR)-$$n/`find . -iname $$m.ko` ); \
	done
	$(MAKE) $(MSSII-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(MSSII-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(MSSII-KERNEL-MODULES_IPK_DIR)-$$n; \
	done
	rm -f $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules/$(MSSII-KERNEL-MODULES_VERSION)/build
	rm -f $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules/$(MSSII-KERNEL-MODULES_VERSION)/source
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)/lib/modules/$(MSSII-KERNEL-MODULES_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(MSSII-KERNEL-MODULES_IPK_DIR) )
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
mssii-kernel-modules-ipk: $(MSSII-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
mssii-kernel-modules-clean:
	rm -f $(MSSII-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(MSSII-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mssii-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(MSSII-KERNEL-MODULES_DIR) $(MSSII-KERNEL-MODULES_BUILD_DIR)
	rm -rf $(MSSII-KERNEL-MODULES_IPK_DIR)* $(MSSII-KERNEL-IMAGE_IPK_DIR)* 
	rm -f $(BUILD_DIR)/kernel-modules_*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-module-*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-image-*_armeb.ipk
