###########################################################
#
# kernel-modules
#
###########################################################

ifeq ($(OPTWARE_TARGET), $(filter tsx19, $(OPTWARE_TARGET)))

TSX19_KERNEL_SITE=http://www.qnap.com
TSX19_KERNEL_SOURCE=QNAP_TS_X19_GPL_linux-2.6.22.18.tar.bz2
# KERNEL_SOURCE_SITE=http://www.kernel.org/pub/linux/kernel/v2.6
# KERNEL_SOURCE=linux-2.6.22.18.tar.bz2
KERNEL_VERSION=2.6.22.18
KERNEL-MODULES_DIR=linux-$(KERNEL_VERSION)
KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>

KERNEL-IMAGE_DESCRIPTION=Kernel
KERNEL-MODULE_DESCRIPTION=Kernel module
KERNEL-MODULES_DESCRIPTION=Kernel modules

KERNEL-MODULES_SECTION=kernel
KERNEL-MODULES_PRIORITY=optional
KERNEL-MODULES_DEPENDS=
KERNEL-MODULES_SUGGESTS=
KERNEL-MODULES_CONFLICTS=
KERNEL-MODULES=`find $(KERNEL-MODULES_IPK_DIR) -name *.ko`

#
# KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
KERNEL-MODULES_IPK_VERSION=1

#
# KERNEL-MODULES_CONFFILES should be a list of user-editable files
#KERNEL-MODULES_CONFFILES=/opt/etc/kernel-modules.conf /opt/etc/init.d/SXXkernel-modules

#
# KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#KERNEL-MODULES_PATCHES = \
	$(TSX19_KERNEL_SOURCE_DIR)/arch-arm-Makefile.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KERNEL-MODULES_CPPFLAGS=
KERNEL-MODULES_LDFLAGS=

TSX19_KERNEL_SOURCE_DIR=$(SOURCE_DIR)/kernel-modules/qnap-ts-x19
KERNEL_BUILD_DIR=$(BUILD_DIR)/linux-2.6.22.18

KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/kernel-modules-$(KERNEL_VERSION)-ipk
KERNEL-MODULE_IPKS_DIR=$(BUILD_DIR)/kernel-module-$(KERNEL_VERSION)-ipks
KERNEL-MODULES_IPK=$(BUILD_DIR)/kernel-modules_$(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/kernel-image-$(KERNEL_VERSION)-ipk
KERNEL-IMAG_IPK=$(BUILD_DIR)/kernel-image_$(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TSX19_KERNEL_SOURCE):
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kernel-modules-source: $(DL_DIR)/$(TSX19_KERNEL_SOURCE) $(KERNEL-MODULES_PATCHES)

KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(KERNEL_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)
KERNEL-MODULES_CONFIG_METHOD=oldconfig

$(KERNEL_BUILD_DIR)/.configured: \
$(DL_DIR)/$(TSX19_KERNEL_SOURCE) $(KERNEL-MODULES_PATCHES) \
$(TSX19_KERNEL_SOURCE_DIR)/defconfig make/tsx19-kernel-modules.mk
	$(MAKE) u-boot-mkimage
	rm -rf $(KERNEL-MODULES_DIR) $(@D)
	tar -C $(BUILD_DIR) -xvjf $(DL_DIR)/$(TSX19_KERNEL_SOURCE)
	if test -n "$(KERNEL-MODULES_PATCHES)" ; \
		then cat $(KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(KERNEL-MODULES_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(KERNEL-MODULES_DIR) $(@D) ; \
	fi
	cp $(TSX19_KERNEL_SOURCE_DIR)/defconfig $(@D)/.config
	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) $(KERNEL-MODULES_CONFIG_METHOD)
	touch $@

kernel-modules-unpack: $(KERNEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KERNEL_BUILD_DIR)/.built: $(KERNEL_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(HOST_STAGING_PREFIX)/bin:$$PATH \
	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) uImage modules
	touch $@

kernel-modules: $(KERNEL_BUILD_DIR)/.built

$(KERNEL_BUILD_DIR)/.staged: $(KERNEL_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_DIR)/src/linux
	mkdir -p $(STAGING_DIR)/src/linux
	cp $(KERNEL_BUILD_DIR)/.config $(STAGING_DIR)/src/linux
	cp -a $(KERNEL_BUILD_DIR)/* $(STAGING_DIR)/src/linux
	touch $@

kernel-modules-stage: $(KERNEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/kernel-modules
#
$(KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(@D)
	( \
	  echo "Package: kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(TSX19_KERNEL_SOURCE_SITE)/$(TSX19_KERNEL_SOURCE)"; \
	  echo "Description: $(KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: kernel-image"; \
	) >> $@
	for m in $(KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  install -d $(KERNEL-MODULE_IPKS_DIR)/$$n/CONTROL; \
	  rm -f $(KERNEL-MODULE_IPKS_DIR)/$$n/CONTROL/control; \
          ( \
	    echo -n ", kernel-module-$$n" >> $@; \
	    echo "Package: kernel-module-$$n"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(TSX19_KERNEL_SOURCE_SITE)/$(TSX19_KERNEL_SOURCE)"; \
	    echo "Description: $(KERNEL-MODULE_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "/$$m.ko:" $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules/$(KERNEL_VERSION)*/modules.dep|cut -d ":" -f 2`; do \
	      if test -n "$$DEPS"; then DEPS="$$DEPS,"; fi; \
	      j=`basename $$i .ko | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	      DEPS="$$DEPS kernel-module-$$j"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(KERNEL-MODULE_IPKS_DIR)/$$n/CONTROL/control; \
	done
	echo "" >> $@

$(KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(@D)
	rm -f $@
	( \
	  echo "Package: kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(TSX19_KERNEL_SOURCE_SITE)/$(TSX19_KERNEL_SOURCE)"; \
	  echo "Description: $(KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $@

#
# This builds the IPK files.
#
$(KERNEL_BUILD_DIR)/.ipkdone: $(KERNEL_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
#	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
#	# Package the kernel image first
#	rm -rf $(KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
#	$(MAKE) $(KERNEL-IMAGE_IPK_DIR)/CONTROL/control
#	install -d $(KERNEL-IMAGE_IPK_DIR)/boot/
#	install -m 644 $(KERNEL_BUILD_DIR)/arch/arm/boot/uImage \
		$(KERNEL-IMAGE_IPK_DIR)/boot/uImage-$(KERNEL_VERSION)-optware-build-$(KERNEL-MODULES_IPK_VERSION)
#	( cd $(BUILD_DIR); $(IPKG_BUILD) $(KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(KERNEL-MODULES_IPK_DIR)* $(KERNEL-MODULE_IPKS_DIR)
	mkdir -p $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules
	$(MAKE) -C $(KERNEL_BUILD_DIR) $(KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(KERNEL-MODULES_IPK_DIR)/opt modules_install
	for m in $(KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  ( cd $(KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -iname $$m.ko` $(KERNEL-MODULE_IPKS_DIR)/$$n/`find . -iname $$m.ko` ); \
	done
	$(MAKE) $(KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(KERNEL-MODULE_IPKS_DIR)/$$n; \
	done
	rm -f $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules/$(KERNEL_VERSION)/build
	rm -f $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules/$(KERNEL_VERSION)/source
	rm -rf $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules/$(KERNEL_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(KERNEL-MODULES_IPK_DIR) )
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
kernel-modules-ipk: $(KERNEL_BUILD_DIR)/.ipkdone
tsx19-kernel-modules-ipk: $(KERNEL_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
kernel-modules-clean:
	rm -f $(KERNEL_BUILD_DIR)/.built
	-$(MAKE) -C $(KERNEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(KERNEL-MODULES_DIR) $(KERNEL_BUILD_DIR)
	rm -rf $(KERNEL-MODULES_IPK_DIR)* $(KERNEL-IMAGE_IPK_DIR)* $(KERNEL-MODULE_IPKS_DIR)
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk

endif
