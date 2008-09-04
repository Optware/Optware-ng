###########################################################
#
# dt2-kernel-modules
#
###########################################################

DT2-KERNEL-MODULES_SITE=http://sources.nslu2-linux.org/sources
DT2-KERNEL-MODULES_SOURCE=dt2kern-2.4.tar.gz
DT2-KERNEL-MODULES_VERSION=2.6.12.6-arm1
DT2-KERNEL-MODULES_DIR=dt2kern-2.4/linux-88fxx81
DT2-KERNEL-MODULES_UNZIP=zcat
DT2-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DT2-KERNEL-MODULES_DESCRIPTION=DataTank2 kernel modules
DT2-KERNEL-IMAGE_DESCRIPTION=DataTank2 kernel
DT2-KERNEL-MODULES_SECTION=kernel
DT2-KERNEL-MODULES_PRIORITY=optional
DT2-KERNEL-MODULES_DEPENDS=
DT2-KERNEL-MODULES_SUGGESTS=
DT2-KERNEL-MODULES_CONFLICTS=
DT2-KERNEL-MODULES=`find $(DT2-KERNEL-MODULES_IPK_DIR) -name *.ko`

#
# DT2-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
DT2-KERNEL-MODULES_IPK_VERSION=4

#
# DT2-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#DT2-KERNEL-MODULES_CONFFILES=/opt/etc/dt2-kernel-modules.conf /opt/etc/init.d/SXXdt2-kernel-modules

#
# DT2-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DT2-KERNEL-MODULES_PATCHES = 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DT2-KERNEL-MODULES_CPPFLAGS=
DT2-KERNEL-MODULES_LDFLAGS=

DT2-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/dt2-kernel-modules
DT2-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/dt2-kernel-modules
DT2-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/dt2-kernel-modules-$(DT2-KERNEL-MODULES_VERSION)-ipk
DT2-KERNEL-MODULES_IPK=$(BUILD_DIR)/dt2-kernel-modules_$(DT2-KERNEL-MODULES_VERSION)-$(DT2-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

DT2-KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/dt2-kernel-image-$(DT2-KERNEL-MODULES_VERSION)-ipk
DT2-KERNEL-IMAG_IPK=$(BUILD_DIR)/dt2-kernel-image_$(DT2-KERNEL-MODULES_VERSION)-$(DT2-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DT2-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(DT2-KERNEL-MODULES_SITE)/$(DT2-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dt2-kernel-modules-source: $(DL_DIR)/$(DT2-KERNEL-MODULES_SOURCE) $(DT2-KERNEL-MODULES_PATCHES)

$(DT2-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(DT2-KERNEL-MODULES_SOURCE) $(DT2-KERNEL-MODULES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DT2-KERNEL-MODULES_DIR) $(DT2-KERNEL-MODULES_BUILD_DIR)
	$(DT2-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(DT2-KERNEL-MODULES_SOURCE) | \
		tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DT2-KERNEL-MODULES_PATCHES)" ; \
		then cat $(DT2-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DT2-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DT2-KERNEL-MODULES_DIR)" != "$(DT2-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DT2-KERNEL-MODULES_DIR) $(DT2-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(DT2-KERNEL-MODULES_BUILD_DIR)/.configured

dt2-kernel-modules-unpack: $(DT2-KERNEL-MODULES_BUILD_DIR)/.configured

DT2-KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(DT2-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(DT2-KERNEL-MODULES_BUILD_DIR)/.built: $(DT2-KERNEL-MODULES_BUILD_DIR)/.configured \
		$(DT2-KERNEL-MODULES_SOURCE_DIR)/defconfig make/dt2-kernel-modules.mk
	rm -f $(DT2-KERNEL-MODULES_BUILD_DIR)/.built
#	$(MAKE) -C $(DT2-KERNEL-MODULES_BUILD_DIR) $(DT2-KERNEL-MODULES-FLAGS) clean
	cp  $(DT2-KERNEL-MODULES_SOURCE_DIR)/defconfig $(DT2-KERNEL-MODULES_BUILD_DIR)/.config;
	$(MAKE) -C $(DT2-KERNEL-MODULES_BUILD_DIR) $(DT2-KERNEL-MODULES-FLAGS) oldconfig
	$(MAKE) -C $(DT2-KERNEL-MODULES_BUILD_DIR) $(DT2-KERNEL-MODULES-FLAGS) all modules
	touch $(DT2-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dt2-kernel-modules: $(DT2-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dt2-kernel-modules
#
$(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL
	( \
	  echo "Package: kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(DT2-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(DT2-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(DT2-KERNEL-MODULES_VERSION)-$(DT2-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(DT2-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(DT2-KERNEL-MODULES_SITE)/$(DT2-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(DT2-KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: kernel-image"; \
	) >> $(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	for m in $(DT2-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  install -d $(DT2-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL; \
	  rm -f $(DT2-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
          ( \
	    echo -n ", kernel-module-$$n" >> $(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	    echo "Package: kernel-module-$$n"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(DT2-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(DT2-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(DT2-KERNEL-MODULES_VERSION)-$(DT2-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(DT2-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(DT2-KERNEL-MODULES_SITE)/$(DT2-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(DT2-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(DT2-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules/$(DT2-KERNEL-MODULES_VERSION)/modules.dep|cut -d ":" -f 2`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      j=`basename $$i .ko | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	      DEPS="$$DEPS kernel-module-$$j"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(DT2-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(DT2-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(DT2-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
	done
	echo "" >> $(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL/control

$(DT2-KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(DT2-KERNEL-IMAGE_IPK_DIR)/CONTROL
	rm -f $(DT2-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	( \
	  echo "Package: kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(DT2-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(DT2-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(DT2-KERNEL-MODULES_VERSION)-$(DT2-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(DT2-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(DT2-KERNEL-MODULES_SITE)/$(DT2-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(DT2-KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $(DT2-KERNEL-IMAGE_IPK_DIR)/CONTROL/control

#
# This builds the IPK file.
#
# Binaries should be installed into $(DT2-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(DT2-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DT2-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DT2-KERNEL-MODULES_IPK_DIR)/opt/etc/dt2-kernel-modules/...
# Documentation files should be installed in $(DT2-KERNEL-MODULES_IPK_DIR)/opt/doc/dt2-kernel-modules/...
# Daemon startup scripts should be installed in $(DT2-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??dt2-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(DT2-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(DT2-KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
	# Package the kernel image first
	rm -rf $(DT2-KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/dt2-kernel-image_*_$(TARGET_ARCH).ipk
	$(MAKE) $(DT2-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	install -m 644 $(DT2-KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/zImage $(DT2-KERNEL-IMAGE_IPK_DIR)
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(DT2-KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(DT2-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/dt2-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(DT2-KERNEL-MODULES_BUILD_DIR) $(DT2-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(DT2-KERNEL-MODULES_IPK_DIR) modules_install
	for m in $(DT2-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  ( cd $(DT2-KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -iname $$m.ko` $(DT2-KERNEL-MODULES_IPK_DIR)-$$n/`find . -iname $$m.ko` ); \
	done
	$(MAKE) $(DT2-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(DT2-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(DT2-KERNEL-MODULES_IPK_DIR)-$$n; \
	done
	rm -f $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules/$(DT2-KERNEL-MODULES_VERSION)/build
	rm -f $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules/$(DT2-KERNEL-MODULES_VERSION)/source
	rm -rf $(DT2-KERNEL-MODULES_IPK_DIR)/lib/modules/$(DT2-KERNEL-MODULES_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(DT2-KERNEL-MODULES_IPK_DIR) )
	touch $(DT2-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
dt2-kernel-modules-ipk: $(DT2-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
dt2-kernel-modules-clean:
	rm -f $(DT2-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(DT2-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dt2-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(DT2-KERNEL-MODULES_DIR) $(DT2-KERNEL-MODULES_BUILD_DIR)
	rm -rf $(DT2-KERNEL-MODULES_IPK_DIR)* $(DT2-KERNEL-IMAGE_IPK_DIR)* 
	rm -f $(BUILD_DIR)/kernel-modules_*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-module-*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-image-*_armeb.ipk

# LocalWords:  fsg
