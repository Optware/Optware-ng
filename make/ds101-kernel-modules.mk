###########################################################
#
# ds101-kernel-modules
#
###########################################################

# Unfortunately the kernel sources at http://www.dachsweb.de/synology-linux-2.4.22.tar.bz2
# are lacking the IXP drivers sources required for the ds101(j) and we need to get the 294 Mb
# of the full synology GPL sources...
DS101-KERNEL-MODULES_SITE=http://www.nas-forum.com/tracker
DS101-KERNEL-MODULES_SYNO_VERSION=385
DS101-KERNEL-MODULES_VERSION=2.4.22
DS101-KERNEL-MODULES_SOURCE=synogpl-$(DS101-KERNEL-MODULES_SYNO_VERSION).tbz
DS101-KERNEL-MODULES_DIR=source/uclinux2422
DS101-KERNEL-MODULES_UNZIP=bzcat
DS101-KERNEL-MODULES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DS101-KERNEL-MODULES_DESCRIPTION=DS-101 kernel module
DS101-KERNEL-MODULES_SECTION=kernel
DS101-KERNEL-MODULES_PRIORITY=optional
DS101-KERNEL-MODULES_DEPENDS=
DS101-KERNEL-MODULES_SUGGESTS=
DS101-KERNEL-MODULES_CONFLICTS=
DS101-KERNEL-MODULES=nfsd isofs loop tun ethertap

#
# DS101-KERNEL-MODULES_IPK_VERSION should be incremented when the ipk changes.
#
DS101-KERNEL-MODULES_IPK_VERSION=2

#
# DS101-KERNEL-MODULES_CONFFILES should be a list of user-editable files
#DS101-KERNEL-MODULES_CONFFILES=/opt/etc/ds101-kernel-modules.conf /opt/etc/init.d/SXXds101-kernel-modules

#
# DS101-KERNEL-MODULES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DS101-KERNEL-MODULES_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DS101-KERNEL-MODULES_CPPFLAGS=
DS101-KERNEL-MODULES_LDFLAGS=

DS101-KERNEL-MODULES_BUILD_DIR=$(BUILD_DIR)/ds101-kernel-modules
DS101-KERNEL-MODULES_SOURCE_DIR=$(SOURCE_DIR)/ds101-kernel-modules
DS101-KERNEL-MODULES_IPK_DIR=$(BUILD_DIR)/ds101-kernel-modules-$(DS101-KERNEL-MODULES_VERSION)-ipk
DS101-KERNEL-MODULES_IPK=$(BUILD_DIR)/ds101-kernel-modules_$(DS101-KERNEL-MODULES_VERSION)-$(DS101-KERNEL-MODULES_IPK_VERSION)_$(TARGET_ARCH).ipk
DS101-KERNEL-MODULES_SCRIPTS=$(shell ls $(DS101-KERNEL-MODULES_SOURCE_DIR)/S*mod_*)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DS101-KERNEL-MODULES_SOURCE):
	$(WGET) -P $(DL_DIR) $(DS101-KERNEL-MODULES_SITE)/$(DS101-KERNEL-MODULES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ds101-kernel-modules-source: $(DL_DIR)/$(DS101-KERNEL-MODULES_SOURCE) $(DS101-KERNEL-MODULES_PATCHES)

$(DS101-KERNEL-MODULES_BUILD_DIR)/.configured: $(DL_DIR)/$(DS101-KERNEL-MODULES_SOURCE) $(DS101-KERNEL-MODULES_PATCHES) make/ds101-kernel-modules.mk \
        $(DS101-KERNEL-MODULES_BUILD_DIR)/.unpacked \
        $(DS101-KERNEL-MODULES_SOURCE_DIR)/armeb-config
	(cd $(DS101-KERNEL-MODULES_BUILD_DIR); \
	  rm -f IXP400lib; \
	  ln -sf vendors/Intel/IXDP425/ixp400-1.3 IXP400lib; \
	  cd IXP400lib/ixp425_xscale_sw/buildUtils; \
	  sed -e 's|^LINUX_CROSS_COMPILE=.*$$|LINUX_CROSS_COMPILE=$(TARGET_CROSS)|' environment.linux.ixpj >environment.linux.tmp; \
	  mv environment.linux.tmp environment.linux; \
	  sed -e 's|^LINUX_SRC=.*$$|LINUX_SRC=$(DS101-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x|' environment.linux >environment.linux.tmp; \
	  mv environment.linux.tmp environment.linux; \
	  sed -e 's|^IX_XSCALE_SW=.*$$|IX_XSCALE_SW=$(DS101-KERNEL-MODULES_BUILD_DIR)/IXP400lib/ixp425_xscale_sw|' environment.linux >environment.linux.tmp; \
	  mv environment.linux.tmp environment.linux; \
	  echo ROOTDIR=$(DS101-KERNEL-MODULES_BUILD_DIR) >>environment.linux; \
	  export ROOTDIR=$(DS101-KERNEL-MODULES_BUILD_DIR); \
	  cd ..; \
	  sed -e 's|-Wa,-mxscale||' Makefile >Makefile.tmp; \
	  mv Makefile.tmp Makefile; \
	  cd ../../linux-2.4.x; \
	  sed -e 's|CROSS_COMPILE =.*$$|CROSS_COMPILE=$(TARGET_CROSS)|' Makefile.ixpj >Makefile; \
	  cp  $(DS101-KERNEL-MODULES_SOURCE_DIR)/armeb-config .config; \
	  $(MAKE) oldconfig; $(MAKE) dep \
	)
	touch $(DS101-KERNEL-MODULES_BUILD_DIR)/.configured

$(DS101-KERNEL-MODULES_BUILD_DIR)/.unpacked: $(DL_DIR)/$(DS101-KERNEL-MODULES_SOURCE) $(DS101-KERNEL-MODULES_PATCHES)
	rm -rf $(BUILD_DIR)/$(DS101-KERNEL-MODULES_DIR) $(DS101-KERNEL-MODULES_BUILD_DIR)
	$(DS101-KERNEL-MODULES_UNZIP) $(DL_DIR)/$(DS101-KERNEL-MODULES_SOURCE) | tar -C $(BUILD_DIR) -xvf - source/uclinux2422
	if test -n "$(DS101-KERNEL-MODULES_PATCHES)" ; \
		then cat $(DS101-KERNEL-MODULES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DS101-KERNEL-MODULES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(DS101-KERNEL-MODULES_DIR)" != "$(DS101-KERNEL-MODULES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DS101-KERNEL-MODULES_DIR) $(DS101-KERNEL-MODULES_BUILD_DIR) ; \
	fi
	touch $(DS101-KERNEL-MODULES_BUILD_DIR)/.unpacked

ds101-kernel-modules-unpack: $(DS101-KERNEL-MODULES_BUILD_DIR)/.unpacked

#
# This builds the actual binary.
#
$(DS101-KERNEL-MODULES_BUILD_DIR)/.built: $(DS101-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(DS101-KERNEL-MODULES_BUILD_DIR)/.built
	(cd $(DS101-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x; \
	  export ROOTDIR=$(DS101-KERNEL-MODULES_BUILD_DIR); \
	  $(MAKE) modules \
	)
	touch $(DS101-KERNEL-MODULES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ds101-kernel-modules: $(DS101-KERNEL-MODULES_BUILD_DIR)/.built

#
## If you are building a library, then you need to stage it too.
#
$(DS101-KERNEL-MODULES_BUILD_DIR)/.staged: $(DS101-KERNEL-MODULES_BUILD_DIR)/.configured
	rm -f $(DS101-KERNEL-MODULES_BUILD_DIR)/.staged
	mkdir -p $(STAGING_DIR)/src/linux
	cp -a $(DS101-KERNEL-MODULES_BUILD_DIR)/* $(STAGING_DIR)/src/linux
	touch $(DS101-KERNEL-MODULES_BUILD_DIR)/.staged

ds101-kernel-modules-stage: $(DS101-KERNEL-MODULES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ds101-kernel-modules
#
$(DS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control:
	for m in $(DS101-KERNEL-MODULES); do \
	  install -d $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL; \
	  rm -f $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
          ( \
	    echo "Package: kernel-module-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Architecture: $(TARGET_ARCH)"; \
	    echo "Priority: $(DS101-KERNEL-MODULES_PRIORITY)"; \
	    echo "Section: $(DS101-KERNEL-MODULES_SECTION)"; \
	    echo "Version: $(DS101-KERNEL-MODULES_VERSION)-$(DS101-KERNEL-MODULES_IPK_VERSION)"; \
	    echo "Replaces: kernel-modules-`echo $$m|sed -e 's/_/-/g'`"; \
	    echo "Maintainer: $(DS101-KERNEL-MODULES_MAINTAINER)"; \
	    echo "Source: $(DS101-KERNEL-MODULES_SITE)/$(DS101-KERNEL-MODULES_SOURCE)"; \
	    echo "Description: $(DS101-KERNEL-MODULES_DESCRIPTION) $$m"; \
	    echo -n "Depends: "; \
            DEPS="$(DS101-KERNEL-MODULES_DEPENDS)"; \
	    for i in `grep "^$$m:" $(DS101-KERNEL-MODULES_SOURCE_DIR)/modules.dep|cut -d ":" -f 2|sed -e 's/_/-/g'`; do \
	      if test -n "$$DEPS"; \
	      then DEPS="$$DEPS,"; \
	      fi; \
	      DEPS="$$DEPS kernel-module-$$i"; \
            done; \
            echo "$$DEPS";\
	    echo "Suggests: $(DS101-KERNEL-MODULES_SUGGESTS)"; \
	    echo "Conflicts: $(DS101-KERNEL-MODULES_CONFLICTS)"; \
	  ) >> $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/control; \
	  echo "#! /bin/sh" > $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/postinst ;\
	  echo "echo running /opt/etc/init.d/S01mod_$$m" >> $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/postinst ;\
	  echo "/opt/etc/init.d/S01mod_$$m" >> $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/postinst ;\
	  echo "#! /bin/sh" > $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/prerm ;\
	  echo "echo trying rmmod $$m" > $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/prerm ;\
	  echo "rmmod $$m" >> $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/prerm ;\
	  echo "exit 0" >> $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/CONTROL/prerm ;\
	done
	install -d $(DS101-KERNEL-MODULES_IPK_DIR)/CONTROL; \
	touch $(DS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control
#
# This builds the IPK file.
#
# Binaries should be installed into $(DS101-KERNEL-MODULES_IPK_DIR)/opt/sbin or $(DS101-KERNEL-MODULES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DS101-KERNEL-MODULES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DS101-KERNEL-MODULES_IPK_DIR)/opt/etc/ds101-kernel-modules/...
# Documentation files should be installed in $(DS101-KERNEL-MODULES_IPK_DIR)/opt/doc/ds101-kernel-modules/...
# Daemon startup scripts should be installed in $(DS101-KERNEL-MODULES_IPK_DIR)/opt/etc/init.d/S??ds101-kernel-modules
#
# You may need to patch your application to make it use these locations.
#
$(DS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone: $(DS101-KERNEL-MODULES_BUILD_DIR)/.built $(DS101-KERNEL-MODULES_SCRIPTS)
	rm -rf $(DS101-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module_*_$(TARGET_ARCH).ipk
	(cd $(DS101-KERNEL-MODULES_BUILD_DIR)/linux-2.4.x; \
	  export ROOTDIR=$(DS101-KERNEL-MODULES_BUILD_DIR); \
	  INSTALL_MOD_PATH=$(DS101-KERNEL-MODULES_IPK_DIR)/opt $(MAKE) modules_install \
	)
	rm -rf $(DS101-KERNEL-MODULES_IPK_DIR)/lib/modules/2.4.22-uc0/kernel/drivers/synobios
	for m in $(DS101-KERNEL-MODULES); do \
	  install -d $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	  install -m 644 `find $(DS101-KERNEL-MODULES_IPK_DIR) -name $$m.o` $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/lib/modules; \
	  install -d $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/etc/init.d; \
	  if [ -f $(DS101-KERNEL-MODULES_SOURCE_DIR)/S01mod_$$m ] ; then \
		install -m 755  $(DS101-KERNEL-MODULES_SOURCE_DIR)/S01mod_$$m $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/etc/init.d; \
	  else 	install -m 755  $(DS101-KERNEL-MODULES_SOURCE_DIR)/S01mod_generic $(DS101-KERNEL-MODULES_IPK_DIR)-$$m/opt/etc/init.d/S01mod_$$m; \
	  fi;\
	done
	$(MAKE) $(DS101-KERNEL-MODULES_IPK_DIR)/CONTROL/control
	for m in $(DS101-KERNEL-MODULES); do \
	  cd $(BUILD_DIR); $(IPKG_BUILD) $(DS101-KERNEL-MODULES_IPK_DIR)-$$m; \
	done
	touch $(DS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to create the IPK file.
#
ds101-kernel-modules-ipk: $(DS101-KERNEL-MODULES_BUILD_DIR)/.ipkdone

#
# This is called from the top level makefile to clean all of the built files.
#
ds101-kernel-modules-clean:
	rm -f $(DS101-KERNEL-MODULES_BUILD_DIR)/.built
	-$(MAKE) -C $(DS101-KERNEL-MODULES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ds101-kernel-modules-dirclean:
	rm -rf $(BUILD_DIR)/$(DS101-KERNEL-MODULES_DIR) $(DS101-KERNEL-MODULES_BUILD_DIR) $(DS101-KERNEL-MODULES_IPK_DIR)* $(BUILD_DIR)/kernel-module-*_$(TARGET_ARCH).ipk
