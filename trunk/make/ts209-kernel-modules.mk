###########################################################
#
# ts209-kernel-modules
#
###########################################################

TS209-KERNEL-MODULES_SITE=http://www.kernel.org/pub/linux/kernel/v2.6
TS209-KERNEL-MODULES_SOURCE=linux-2.6.12.6.tar.bz2
TS209-KERNEL-MODULES_VERSION=2.6.12.6-arm1
TS209-KERNEL-MODULES_DIR=linux-2.6.12.6
TS209-KERNEL-MODULES_UNZIP=bzcat
TS209-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TS209-KERNEL-MODULES_DESCRIPTION=TS-209 kernel modules
TS209-KERNEL-IMAGE_DESCRIPTION=TS-209 kernel
TS209-KERNEL-MODULES_SECTION=kernel
TS209-KERNEL-MODULES_PRIORITY=optional
TS209-KERNEL-MODULES_DEPENDS=
TS209-KERNEL-MODULES_SUGGESTS=
TS209-KERNEL-MODULES_CONFLICTS=
TS209-KERNEL-MODULES=`find $(TS209-KERNEL-MODULES_IPK_DIR) -name *.ko`

#
# TS209-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
TS209-KERNEL-MODULES_IPK_VERSION=2

#
# TS209-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#TS209-KERNEL-MODULES_CONFFILES=/opt/etc/ts209-kernel-modules.conf /opt/etc/init.d/SXXts209-kernel-modules

#
# TS209-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TS209-KERNEL-MODULES_PATCHES = \
	$(TS209-KERNEL-MODULES_SOURCE_DIR)/linux-2.6.12.6_ts109-209.patch \
	$(TS209-KERNEL-MODULES_SOURCE_DIR)/git-libata-passthru.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TS209-KERNEL-MODULES_CPPFLAGS=
TS209-KERNEL-MODULES_LDFLAGS=

TS209-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/ts209-kernel-modules
TS209-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/ts209-kernel-modules
TS209-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/ts209-kernel-modules-$(TS209-KERNEL-MODULES_VERSION)-ipk
TS209-KERNEL-MODULES_IPK=$(BUILD_DIR)/ts209-kernel-modules_$(TS209-KERNEL-MODULES_VERSION)-$(TS209-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

TS209-KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/ts209-kernel-image-$(TS209-KERNEL-MODULES_VERSION)-ipk
TS209-KERNEL-IMAG_IPK=$(BUILD_DIR)/ts209-kernel-image_$(TS209-KERNEL-MODULES_VERSION)-$(TS209-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TS209-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(TS209-KERNEL-MODULES_SITE)/$(TS209-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ts209-kernel-modules-source: $(DL_DIR)/$(TS209-KERNEL-MODULES_SOURCE) $(TS209-KERNEL-MODULES_PATCHES)

$(TS209-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(TS209-KERNEL-MODULES_SOURCE) $(TS209-KERNEL-MODULES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TS209-KERNEL-MODULES_DIR) $(TS209-KERNEL-MODULES_BUILD_DIR)
	$(TS209-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(TS209-KERNEL-MODULES_SOURCE) | \
		tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TS209-KERNEL-MODULES_PATCHES)" ; \
		then cat $(TS209-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TS209-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TS209-KERNEL-MODULES_DIR)" != "$(TS209-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TS209-KERNEL-MODULES_DIR) $(TS209-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(TS209-KERNEL-MODULES_BUILD_DIR)/.configured

ts209-kernel-modules-unpack: $(TS209-KERNEL-MODULES_BUILD_DIR)/.configured

TS209-KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(TS209-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(TS209-KERNEL-MODULES_BUILD_DIR)/.built: $(TS209-KERNEL-MODULES_BUILD_DIR)/.configured \
		$(TS209-KERNEL-MODULES_SOURCE_DIR)/qnap_ts-209.cfg make/ts209-kernel-modules.mk
	rm -f $(TS209-KERNEL-MODULES_BUILD_DIR)/.built
#	$(MAKE) -C $(TS209-KERNEL-MODULES_BUILD_DIR) $(TS209-KERNEL-MODULES-FLAGS) clean
	cp  $(TS209-KERNEL-MODULES_SOURCE_DIR)/qnap_ts-209.cfg $(TS209-KERNEL-MODULES_BUILD_DIR)/.config;
	$(MAKE) -C $(TS209-KERNEL-MODULES_BUILD_DIR) $(TS209-KERNEL-MODULES-FLAGS) oldconfig
	$(MAKE) -C $(TS209-KERNEL-MODULES_BUILD_DIR) $(TS209-KERNEL-MODULES-FLAGS) all modules
	touch $(TS209-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ts209-kernel-modules: $(TS209-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ts209-kernel-modules
#
$(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL
	( \
	  echo "Package: ts209-kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(TS209-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(TS209-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(TS209-KERNEL-MODULES_VERSION)-$(TS209-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(TS209-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(TS209-KERNEL-MODULES_SITE)/$(TS209-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(TS209-KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: ts209-kernel-image"; \
	) >> $(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	for m in $(TS209-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  install -d $(TS209-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL; \
	  rm -f $(TS209-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
          ( \
	    echo -n ", ts209-kernel-module-$$n" >> $(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	    echo "Package: ts209-kernel-module-$$n"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(TS209-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(TS209-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(TS209-KERNEL-MODULES_VERSION)-$(TS209-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(TS209-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(TS209-KERNEL-MODULES_SITE)/$(TS209-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(TS209-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(TS209-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules/$(TS209-KERNEL-MODULES_VERSION)/modules.dep|cut -d ":" -f 2`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      j=`basename $$i .ko | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	      DEPS="$$DEPS ts209-kernel-module-$$j"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(TS209-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(TS209-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(TS209-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
	done
	echo "" >> $(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL/control

$(TS209-KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(TS209-KERNEL-IMAGE_IPK_DIR)/CONTROL
	rm -f $(TS209-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	( \
	  echo "Package: ts209-kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(TS209-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(TS209-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(TS209-KERNEL-MODULES_VERSION)-$(TS209-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(TS209-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(TS209-KERNEL-MODULES_SITE)/$(TS209-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(TS209-KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $(TS209-KERNEL-IMAGE_IPK_DIR)/CONTROL/control

#
# This builds the IPK file.
#
# Binaries should be installed into $(TS209-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(TS209-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TS209-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TS209-KERNEL-MODULES_IPK_DIR)/opt/etc/ts209-kernel-modules/...
# Documentation files should be installed in $(TS209-KERNEL-MODULES_IPK_DIR)/opt/doc/ts209-kernel-modules/...
# Daemon startup scripts should be installed in $(TS209-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??ts209-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(TS209-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(TS209-KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/ts209-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/ts209-kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/ts209-kernel-image_*_$(TARGET_ARCH).ipk
	# Package the kernel image first
	rm -rf $(TS209-KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/ts209-kernel-image_*_$(TARGET_ARCH).ipk
	$(MAKE) $(TS209-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	install -m 644 $(TS209-KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/zImage $(TS209-KERNEL-IMAGE_IPK_DIR)
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(TS209-KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(TS209-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/ts209-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(TS209-KERNEL-MODULES_BUILD_DIR) $(TS209-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(TS209-KERNEL-MODULES_IPK_DIR) modules_install
	for m in $(TS209-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  ( cd $(TS209-KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -iname $$m.ko` $(TS209-KERNEL-MODULES_IPK_DIR)-$$n/`find . -iname $$m.ko` ); \
	done
	$(MAKE) $(TS209-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(TS209-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(TS209-KERNEL-MODULES_IPK_DIR)-$$n; \
	done
	rm -f $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules/$(TS209-KERNEL-MODULES_VERSION)/build
	rm -f $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules/$(TS209-KERNEL-MODULES_VERSION)/source
	rm -rf $(TS209-KERNEL-MODULES_IPK_DIR)/lib/modules/$(TS209-KERNEL-MODULES_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(TS209-KERNEL-MODULES_IPK_DIR) )
	touch $(TS209-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
ts209-kernel-modules-ipk: $(TS209-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
ts209-kernel-modules-clean:
	rm -f $(TS209-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(TS209-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ts209-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(TS209-KERNEL-MODULES_DIR) $(TS209-KERNEL-MODULES_BUILD_DIR)
	rm -rf $(TS209-KERNEL-MODULES_IPK_DIR)* $(TS209-KERNEL-IMAGE_IPK_DIR)* 
	rm -f $(BUILD_DIR)/ts209-kernel-modules_*_armeb.ipk
	rm -f $(BUILD_DIR)/ts209-kernel-module-*_armeb.ipk
	rm -f $(BUILD_DIR)/ts209-kernel-image-*_armeb.ipk

# LocalWords:  fsg
