###########################################################
#
# vt4-kernel-modules
#
###########################################################

VT4-KERNEL-MODULES_SITE=http://ftp.osuosl.org/pub/nslu2/sources
VT4-KERNEL-MODULES_SOURCE=vt4kern-1.5.tar.bz2
VT4-KERNEL-MODULES_VERSION=2.6.15
VT4-KERNEL-MODULES_DIR=linux-sl3516
VT4-KERNEL-MODULES_UNZIP=bzcat
VT4-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VT4-KERNEL-MODULES_DESCRIPTION=VT4 modules
VT4-KERNEL-IMAGE_DESCRIPTION=VT4 kernel
VT4-KERNEL-MODULES_SECTION=kernel
VT4-KERNEL-MODULES_PRIORITY=optional
VT4-KERNEL-MODULES_DEPENDS=
VT4-KERNEL-MODULES_SUGGESTS=
VT4-KERNEL-MODULES_CONFLICTS=
VT4-KERNEL-MODULES=`find $(VT4-KERNEL-MODULES_IPK_DIR) -name *.ko`

#
# VT4-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
VT4-KERNEL-MODULES_IPK_VERSION=1

#
# VT4-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#VT4-KERNEL-MODULES_CONFFILES=/opt/etc/vt4-kernel-modules.conf /opt/etc/init.d/SXXvt4-kernel-modules

#
# VT4-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VT4-KERNEL-MODULES_PATCHES = 

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VT4-KERNEL-MODULES_CPPFLAGS=
VT4-KERNEL-MODULES_LDFLAGS=

VT4-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/vt4-kernel-modules
VT4-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/vt4-kernel-modules
VT4-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/vt4-kernel-modules-$(VT4-KERNEL-MODULES_VERSION)-ipk
VT4-KERNEL-MODULES_IPK=$(BUILD_DIR)/vt4-kernel-modules_$(VT4-KERNEL-MODULES_VERSION)-$(VT4-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

VT4-KERNEL-IMAGE_IPK_DIR=$(BUILD_DIR)/vt4-kernel-image-$(VT4-KERNEL-MODULES_VERSION)-ipk
VT4-KERNEL-IMAG_IPK=$(BUILD_DIR)/vt4-kernel-image_$(VT4-KERNEL-MODULES_VERSION)-$(VT4-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VT4-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(VT4-KERNEL-MODULES_SITE)/$(VT4-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vt4-kernel-modules-source: $(DL_DIR)/$(VT4-KERNEL-MODULES_SOURCE) $(VT4-KERNEL-MODULES_PATCHES)

$(VT4-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(VT4-KERNEL-MODULES_SOURCE) $(VT4-KERNEL-MODULES_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(VT4-KERNEL-MODULES_DIR) $(VT4-KERNEL-MODULES_BUILD_DIR)
	$(VT4-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(VT4-KERNEL-MODULES_SOURCE) | \
		tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VT4-KERNEL-MODULES_PATCHES)" ; \
		then cat $(VT4-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VT4-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(VT4-KERNEL-MODULES_DIR)" != "$(VT4-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(VT4-KERNEL-MODULES_DIR) $(VT4-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(VT4-KERNEL-MODULES_BUILD_DIR)/.configured

vt4-kernel-modules-unpack: $(VT4-KERNEL-MODULES_BUILD_DIR)/.configured

VT4-KERNEL-MODULES-FLAGS = ARCH=arm ROOTDIR=$(VT4-KERNEL-MODULES_BUILD_DIR) CROSS_COMPILE=$(TARGET_CROSS)

#
# This builds the actual binary.
#
$(VT4-KERNEL-MODULES_BUILD_DIR)/.built: $(VT4-KERNEL-MODULES_BUILD_DIR)/.configured \
		$(VT4-KERNEL-MODULES_SOURCE_DIR)/defconfig make/vt4-kernel-modules.mk
	rm -f $(VT4-KERNEL-MODULES_BUILD_DIR)/.built
#	$(MAKE) -C $(VT4-KERNEL-MODULES_BUILD_DIR) $(VT4-KERNEL-MODULES-FLAGS) clean
	cp  $(VT4-KERNEL-MODULES_SOURCE_DIR)/defconfig $(VT4-KERNEL-MODULES_BUILD_DIR)/.config;
	$(MAKE) -C $(VT4-KERNEL-MODULES_BUILD_DIR) $(VT4-KERNEL-MODULES-FLAGS) oldconfig
	$(MAKE) -C $(VT4-KERNEL-MODULES_BUILD_DIR) $(VT4-KERNEL-MODULES-FLAGS) all modules
	touch $(VT4-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
vt4-kernel-modules: $(VT4-KERNEL-MODULES_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vt4-kernel-modules
#
$(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	install -d $(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL
	( \
	  echo "Package: kernel-modules"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(VT4-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(VT4-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(VT4-KERNEL-MODULES_VERSION)-$(VT4-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(VT4-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(VT4-KERNEL-MODULES_SITE)/$(VT4-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(VT4-KERNEL-MODULES_DESCRIPTION)"; \
	  echo -n "Depends: kernel-image"; \
	) >> $(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	for m in $(VT4-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  install -d $(VT4-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL; \
	  rm -f $(VT4-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
          ( \
	    echo -n ", kernel-module-$$n" >> $(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL/control; \
	    echo "Package: kernel-module-$$n"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(VT4-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(VT4-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(VT4-KERNEL-MODULES_VERSION)-$(VT4-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Maintainer: $(VT4-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(VT4-KERNEL-MODULES_SITE)/$(VT4-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(VT4-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(VT4-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "$$m.ko:" $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(VT4-KERNEL-MODULES_VERSION)/modules.dep|cut -d ":" -f 2`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      j=`basename $$i .ko | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	      DEPS="$$DEPS kernel-module-$$j"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(VT4-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(VT4-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(VT4-KERNEL-MODULES_IPK_DIR)-$$n/CONTROL/control; \
	done
	echo "" >> $(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL/control

$(VT4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control:
	install -d $(VT4-KERNEL-IMAGE_IPK_DIR)/CONTROL
	rm -f $(VT4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	( \
	  echo "Package: kernel-image"; \
	  echo "Architecture: $(TARGET_ARCH)"; \
	  echo "Priority: $(VT4-KERNEL-MODULES_PRIORITY)"; \
	  echo "Section: $(VT4-KERNEL-MODULES_SECTION)"; \
	  echo "Version: $(VT4-KERNEL-MODULES_VERSION)-$(VT4-KERNEL-MODULES_IPK_VERSION)"; \
	  echo "Maintainer: $(VT4-KERNEL-MODULES_MAINTAINER)"; \
	  echo "Source: $(VT4-KERNEL-MODULES_SITE)/$(VT4-KERNEL-MODULES_SOURCE)"; \
	  echo "Description: $(VT4-KERNEL-IMAGE_DESCRIPTION)"; \
	) >> $(VT4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control

#
# This builds the IPK file.
#
# Binaries should be installed into $(VT4-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(VT4-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VT4-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VT4-KERNEL-MODULES_IPK_DIR)/opt/etc/vt4-kernel-modules/...
# Documentation files should be installed in $(VT4-KERNEL-MODULES_IPK_DIR)/opt/doc/vt4-kernel-modules/...
# Daemon startup scripts should be installed in $(VT4-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??vt4-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(VT4-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(VT4-KERNEL-MODULES_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/kernel-modules_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/kernel-image_*_$(TARGET_ARCH).ipk
	# Package the kernel image first
	rm -rf $(VT4-KERNEL-IMAGE_IPK_DIR)* $(BUILD_DIR)/vt4-kernel-image_*_$(TARGET_ARCH).ipk
	$(MAKE) $(VT4-KERNEL-IMAGE_IPK_DIR)/CONTROL/control
	install -m 644 $(VT4-KERNEL-MODULES_BUILD_DIR)/arch/arm/boot/zImage $(VT4-KERNEL-IMAGE_IPK_DIR)
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(VT4-KERNEL-IMAGE_IPK_DIR) )
	# Now package the kernel modules
	rm -rf $(VT4-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/vt4-kernel-modules_*_$(TARGET_ARCH).ipk
	rm -rf $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules
	mkdir -p $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules
	$(MAKE) -C $(VT4-KERNEL-MODULES_BUILD_DIR) $(VT4-KERNEL-MODULES-FLAGS) \
		INSTALL_MOD_PATH=$(VT4-KERNEL-MODULES_IPK_DIR) modules_install
	for m in $(VT4-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  ( cd $(VT4-KERNEL-MODULES_IPK_DIR) ; install -D -m 644 `find . -iname $$m.ko` $(VT4-KERNEL-MODULES_IPK_DIR)-$$n/`find . -iname $$m.ko` ); \
	done
	$(MAKE) $(VT4-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(VT4-KERNEL-MODULES); do \
	  m=`basename $$m .ko`; \
	  n=`echo $$m | sed -e 's/_/-/g' | tr '[A-Z]' '[a-z]'`; \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(VT4-KERNEL-MODULES_IPK_DIR)-$$n; \
	done
	rm -f $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(VT4-KERNEL-MODULES_VERSION)/build
	rm -f $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(VT4-KERNEL-MODULES_VERSION)/source
	rm -rf $(VT4-KERNEL-MODULES_IPK_DIR)/lib/modules/$(VT4-KERNEL-MODULES_VERSION)/kernel
	( cd $(BUILD_DIR); $(IPKG_BUILD) $(VT4-KERNEL-MODULES_IPK_DIR) )
	touch $(VT4-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
vt4-kernel-modules-ipk: $(VT4-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
vt4-kernel-modules-clean:
	rm -f $(VT4-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(VT4-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vt4-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(VT4-KERNEL-MODULES_DIR) $(VT4-KERNEL-MODULES_BUILD_DIR)
	rm -rf $(VT4-KERNEL-MODULES_IPK_DIR)* $(VT4-KERNEL-IMAGE_IPK_DIR)* 
	rm -f $(BUILD_DIR)/kernel-modules_*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-module-*_armeb.ipk
	rm -f $(BUILD_DIR)/kernel-image-*_armeb.ipk

# LocalWords:  fsg
