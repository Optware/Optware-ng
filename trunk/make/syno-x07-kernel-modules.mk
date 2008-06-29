###########################################################
#
# kernel-modules
#
###########################################################

ifeq ($(OPTWARE_TARGET), $(filter syno-x07, $(OPTWARE_TARGET)))

SYNO-X07-GPL-SOURCE_SITE=http://gpl.nas-central.org/SYNOLOGY/x07-series
SYNO-X07-GPL-SOURCE=synogpl-514_for_x07_only.tbz

KERNEL_VERSION=2.6.15
KERNEL-MODULES_DIR=synogpl-514
KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>

#KERNEL-IMAGE_DESCRIPTION=Synology x07 (Marvell mv5281) kernel
KERNEL-MODULE_DESCRIPTION=Synology x07 (Marvell mv5281) kernel module
KERNEL-MODULES_DESCRIPTION=Synology x07 (Marvell mv5281) kernel modules

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
	$(KERNEL-MODULES_SOURCE_DIR)/arch-arm-Makefile.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KERNEL-MODULES_CPPFLAGS=
KERNEL-MODULES_LDFLAGS=

KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/kernel-modules/syno-x07
KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/kernel-modules

KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/kernel-modules-$(KERNEL_VERSION)-ipk
KERNEL-MODULE_IPKS_DIR=$(BUILD_DIR)/kernel-module-$(KERNEL_VERSION)-ipks
KERNEL-MODULES_IPK=$(BUILD_DIR)/kernel-modules_$(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/kernel-image-$(KERNEL_VERSION)-ipk
KERNEL-IMAG_IPK=$(BUILD_DIR)/kernel-image_$(KERNEL_VERSION)-$(KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SYNO-X07-GPL-SOURCE):
	$(WGET) -P $(@D) $(SYNO-X07-GPL-SOURCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kernel-modules-source: $(DL_DIR)/$(SYNO-X07-GPL-SOURCE) $(KERNEL-MODULES_PATCHES)

$(KERNEL-MODULES_BUILD_DIR)/.configured: \
$(DL_DIR)/$(SYNO-X07-GPL-SOURCE) $(KERNEL-MODULES_PATCHES) \
$(KERNEL-MODULES_SOURCE_DIR)/defconfig make/syno-x07-kernel-modules.mk
	rm -rf $(BUILD_DIR)/$(KERNEL-MODULES_DIR) $(@D)
	mkdir -p $(BUILD_DIR)/$(KERNEL-MODULES_DIR)
	tar -C $(BUILD_DIR)/$(KERNEL-MODULES_DIR) -xvjf $(DL_DIR)/$(SYNO-X07-GPL-SOURCE) source/linux-2.6.15
	mv $(BUILD_DIR)/$(KERNEL-MODULES_DIR)/source/linux-2.6.15 $(@D)
	rm -rf $(BUILD_DIR)/$(KERNEL-MODULES_DIR)
	if test -n "$(KERNEL-MODULES_PATCHES)" ; \
		then cat $(KERNEL-MODULES_PATCHES) | patch -d $(@D) -p1 ; \
	fi
#	if test "$(BUILD_DIR)/$(KERNEL-MODULES_DIR)" != "$(KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KERNEL-MODULES_DIR) $(KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $@

kernel-modules-unpack: $(KERNEL-MODULES_BUILD_DIR)/.configured

KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(KERNEL-MODULES_BUILD_DIR)/.built: $(KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) clean
	cp $(KERNEL-MODULES_SOURCE_DIR)/defconfig $(@D)/.config
	mkdir -p $(@D)/drivers/synobios
	cp $(KERNEL-MODULES_SOURCE_DIR)/drivers-synobios-Kconfig $(@D)/drivers/synobios/Kconfig
	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) oldconfig
#	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) menuconfig
#	PATH=$(HOST_STAGING_PREFIX)/bin:$$PATH
	$(MAKE) -C $(@D) $(KERNEL-MODULES-FLAGS) modules
	touch $@

kernel-modules: $(KERNEL-MODULES_BUILD_DIR)/.built

$(KERNEL-MODULES_BUILD_DIR)/.staged: $(KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_DIR)/src/linux
	mkdir -p $(STAGING_DIR)/src/linux
	cp $(KERNEL-MODULES_BUILD_DIR)/.config $(STAGING_DIR)/src/linux
	cp -a $(KERNEL-MODULES_BUILD_DIR)/* $(STAGING_DIR)/src/linux
	touch $@

kernel-modules-stage: $(KERNEL-MODULES_BUILD_DIR)/.staged

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
	  echo "Source: $(SYNO-X07-GPL-SOURCE_SITE)/$(SYNO-X07-GPL-SOURCE)"; \
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
	    echo "Source: $(SYNO-X07-GPL-SOURCE_SITE)/$(SYNO-X07-GPL-SOURCE)"; \
	    echo "Description: $(KERNEL-MODULE_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules/$(KERNEL_VERSION)/modules.dep|cut -d ":" -f 2`; do \
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
	  echo "Source: $(SYNO-X07-GPL-SOURCE_SITE)/$(SYNO-X07-GPL-SOURCE)"; \
	  echo "Description: $(KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $@

#
# This builds the IPK files.
#
$(KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
#	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
#	# Package the kernel image first
#	rm -rf $(KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
#	$(MAKE) $(KERNEL-IMAGE_IPK_DIR)/CONTROL/control
#	install -d $(KERNEL-IMAGE_IPK_DIR)/boot/
#	install -m 644 $(KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/uImage \
		$(KERNEL-IMAGE_IPK_DIR)/boot/uImage-$(KERNEL_VERSION)-optware-build-$(KERNEL-MODULES_IPK_VERSION)
#	( cd $(BUILD_DIR); $(IPKG_BUILD) $(KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(KERNEL-MODULES_IPK_DIR)* $(KERNEL-MODULE_IPKS_DIR)
	mkdir -p $(KERNEL-MODULES_IPK_DIR)/opt/lib/modules
	$(MAKE) -C $(KERNEL-MODULES_BUILD_DIR) $(KERNEL-MODULES-FLAGS) \
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
kernel-modules-ipk: $(KERNEL-MODULES_BUILD_DIR)/.ipkdone
syno-x07-kernel-modules-ipk: $(KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
kernel-modules-clean:
	rm -f $(KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(KERNEL-MODULES_DIR) $(KERNEL-MODULES_BUILD_DIR)
	rm -rf $(KERNEL-MODULES_IPK_DIR)* $(KERNEL-IMAGE_IPK_DIR)* $(KERNEL-MODULE_IPKS_DIR)
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk

endif
