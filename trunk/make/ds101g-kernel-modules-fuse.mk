###########################################################
#
# ds101g-kernel-modules-fuse
#
###########################################################

DS101G-KERNEL-MODULES-FUSE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/fuse
DS101G-KERNEL-MODULES-FUSE_VERSION=2.5.3
DS101G-KERNEL-MODULES-FUSE_SOURCE=fuse-$(DS101G-KERNEL-MODULES-FUSE_VERSION).tar.gz
DS101G-KERNEL-MODULES-FUSE_DIR=fuse-$(DS101G-KERNEL-MODULES-FUSE_VERSION)
DS101G-KERNEL-MODULES-FUSE_UNZIP=zcat
DS101G-KERNEL-MODULES-FUSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DS101G-KERNEL-MODULES-FUSE_DESCRIPTION=With FUSE it is possible to implement a fully functional filesystem in a userspace program
DS101G-KERNEL-MODULES-FUSE_SECTION=kernel
DS101G-KERNEL-MODULES-FUSE_PRIORITY=optional
DS101G-KERNEL-MODULES-FUSE_DEPENDS=
DS101G-KERNEL-MODULES-FUSE_SUGGESTS=
DS101G-KERNEL-MODULES-FUSE_CONFLICTS=

#
# DS101G-KERNEL-MODULES-FUSE_IPK_VERSION should be incremented when the ipk changes.
#
DS101G-KERNEL-MODULES-FUSE_IPK_VERSION=2

#
# DS101G-KERNEL-MODULES-FUSE_CONFFILES should be a list of user-editable files
#DS101G-KERNEL-MODULES-FUSE_CONFFILES=/opt/etc/ds101g-kernel-modules-fuse.conf /opt/etc/init.d/SXXds101g-kernel-modules-fuse

#
# DS101G-KERNEL-MODULES-FUSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
DS101G-KERNEL-MODULES-FUSE_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DS101G-KERNEL-MODULES-FUSE_CPPFLAGS=
DS101G-KERNEL-MODULES-FUSE_LDFLAGS=

#
# DS101G-KERNEL-MODULES-FUSE_BUILD_DIR is the directory in which the build is done.
# DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DS101G-KERNEL-MODULES-FUSE_IPK_DIR is the directory in which the ipk is built.
# DS101G-KERNEL-MODULES-FUSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DS101G-KERNEL-MODULES-FUSE_BUILD_DIR=$(BUILD_DIR)/ds101g-kernel-modules-fuse
DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR=$(SOURCE_DIR)/ds101g-kernel-modules-fuse
DS101G-KERNEL-MODULES-FUSE_IPK_DIR=$(BUILD_DIR)/ds101g-kernel-modules-fuse-$(DS101G-KERNEL-MODULES-FUSE_VERSION)-ipk
DS101G-KERNEL-MODULES-FUSE_IPK=$(BUILD_DIR)/kernel-module-fuse_$(DS101G-KERNEL-MODULES-FUSE_VERSION)-$(DS101G-KERNEL-MODULES-FUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ds101g-kernel-modules-fuse-source ds101g-kernel-modules-fuse-unpack ds101g-kernel-modules-fuse ds101g-kernel-modules-fuse-stage ds101g-kernel-modules-fuse-ipk ds101g-kernel-modules-fuse-clean ds101g-kernel-modules-fuse-dirclean ds101g-kernel-modules-fuse-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE):
	$(WGET) -P $(DL_DIR) $(DS101G-KERNEL-MODULES-FUSE_SITE)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ds101g-kernel-modules-fuse-source: $(DL_DIR)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE) $(DS101G-KERNEL-MODULES-FUSE_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.configured: $(DL_DIR)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE) $(DS101G-KERNEL-MODULES-FUSE_PATCHES) make/ds101g-kernel-modules-fuse.mk
	$(MAKE) ds101g-kernel-modules-stage 
	rm -rf $(BUILD_DIR)/$(DS101G-KERNEL-MODULES-FUSE_DIR) $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)
	$(DS101G-KERNEL-MODULES-FUSE_UNZIP) $(DL_DIR)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DS101G-KERNEL-MODULES-FUSE_PATCHES)" ; \
		then cat $(DS101G-KERNEL-MODULES-FUSE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DS101G-KERNEL-MODULES-FUSE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DS101G-KERNEL-MODULES-FUSE_DIR)" != "$(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DS101G-KERNEL-MODULES-FUSE_DIR) $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) ; \
	fi
	(cd $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DS101G-KERNEL-MODULES-FUSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DS101G-KERNEL-MODULES-FUSE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--program-prefix="" \
		--disable-nls \
		--disable-static \
		--enable-kernel-module \
		--with-kernel=$(STAGING_DIR)/src/linux \
	)
	$(PATCH_LIBTOOL) $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/libtool
	touch $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.configured

ds101g-kernel-modules-fuse-unpack: $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built: $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.configured
	rm -f $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built
	$(MAKE) -C $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS)
	touch $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ds101g-kernel-modules-fuse: $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.staged: $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built
	rm -f $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.staged
	mkdir -p $(STAGING_DIR)/dev/fuse
	$(MAKE) -C $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -rf $(STAGING_DIR)/dev/fuse
	touch $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.staged

ds101g-kernel-modules-fuse-stage: $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ds101g-kernel-modules-fuse
#
$(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: kernel-module-fuse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DS101G-KERNEL-MODULES-FUSE_PRIORITY)" >>$@
	@echo "Section: $(DS101G-KERNEL-MODULES-FUSE_SECTION)" >>$@
	@echo "Version: $(DS101G-KERNEL-MODULES-FUSE_VERSION)-$(DS101G-KERNEL-MODULES-FUSE_IPK_VERSION)" >>$@
	@echo "Replaces: ds101g-kernel-modules-fuse" >>$@
	@echo "Maintainer: $(DS101G-KERNEL-MODULES-FUSE_MAINTAINER)" >>$@
	@echo "Source: $(DS101G-KERNEL-MODULES-FUSE_SITE)/$(DS101G-KERNEL-MODULES-FUSE_SOURCE)" >>$@
	@echo "Description: $(DS101G-KERNEL-MODULES-FUSE_DESCRIPTION)" >>$@
	@echo "Depends: $(DS101G-KERNEL-MODULES-FUSE_DEPENDS)" >>$@
	@echo "Suggests: $(DS101G-KERNEL-MODULES-FUSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(DS101G-KERNEL-MODULES-FUSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/sbin or $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/ds101g-kernel-modules-fuse/...
# Documentation files should be installed in $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/doc/ds101g-kernel-modules-fuse/...
# Daemon startup scripts should be installed in $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/init.d/S??ds101g-kernel-modules-fuse
#
# You may need to patch your application to make it use these locations.
#
$(DS101G-KERNEL-MODULES-FUSE_IPK): $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built
	rm -rf $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR) $(BUILD_DIR)/ds101g-kernel-modules-fuse_*_$(TARGET_ARCH).ipk
	mkdir -p $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/dev/fuse
	$(MAKE) -C $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) DESTDIR=$(DS101G-KERNEL-MODULES-FUSE_IPK_DIR) $(TARGET_CONFIGURE_OPTS) install
	rm -rf $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/dev
	mv $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/{etc,sbin} $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt
	mkdir -p $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/lib/modules
	find $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR) -name "fuse.*o" -exec mv "{}"  $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/lib/modules ";"
	rm -rf $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/lib
	$(STRIP_COMMAND) $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/bin/*
	$(STRIP_COMMAND) $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/lib/lib*.so
	install -d $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/
#	install -m 644 $(DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR)/ds101g-kernel-modules-fuse.conf $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/ds101g-kernel-modules-fuse.conf
#	install -d $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR)/rc.ds101g-kernel-modules-fuse $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/init.d/SXXds101g-kernel-modules-fuse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/opt/etc/init.d/SXXds101g-kernel-modules-fuse
	$(MAKE) $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/control
	install -m 755 $(DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR)/postinst $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/postinst
	install -m 755 $(DS101G-KERNEL-MODULES-FUSE_SOURCE_DIR)/prerm $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/prerm
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/prerm
	echo $(DS101G-KERNEL-MODULES-FUSE_CONFFILES) | sed -e 's/ /\n/g' > $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ds101g-kernel-modules-fuse-ipk: $(DS101G-KERNEL-MODULES-FUSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ds101g-kernel-modules-fuse-clean:
	rm -f $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR)/.built
	-$(MAKE) -C $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ds101g-kernel-modules-fuse-dirclean:
	rm -rf $(BUILD_DIR)/$(DS101G-KERNEL-MODULES-FUSE_DIR) $(DS101G-KERNEL-MODULES-FUSE_BUILD_DIR) $(DS101G-KERNEL-MODULES-FUSE_IPK_DIR) $(DS101G-KERNEL-MODULES-FUSE_IPK)
#
#
# Some sanity check for the package.
#
ds101g-kernel-modules-fuse-check: $(DS101G-KERNEL-MODULES-FUSE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DS101G-KERNEL-MODULES-FUSE_IPK)
