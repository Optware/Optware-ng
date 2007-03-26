###########################################################
#
# modutils
#
###########################################################

MODUTILS_SITE=ftp://ftp.kernel.org/pub/linux/utils/kernel/modutils/v2.4
MODUTILS_VERSION=2.4.27
MODUTILS_SOURCE=modutils-$(MODUTILS_VERSION).tar.gz
MODUTILS_DIR=modutils-$(MODUTILS_VERSION)
MODUTILS_UNZIP=zcat
MODUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MODUTILS_DESCRIPTION=Linux module utilities \
 These utilities are intended to make a Linux modular 2.2 or 2.4 \
 kernel manageable for all users, administrators and distribution \
 maintainers. For 2.6 kernels, you should use the module-init-tools \
 package.

MODUTILS_SECTION=util
MODUTILS_PRIORITY=optional
MODUTILS_DEPENDS=
MODUTILS_SUGGESTS=
MODUTILS_CONFLICTS=

#
# MODUTILS_IPK_VERSION should be incremented when the ipk changes.
#
MODUTILS_IPK_VERSION=2

#
# MODUTILS_CONFFILES should be a list of user-editable files
MODUTILS_CONFFILES=/opt/etc/init.d/S01modutils

#
# MODUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MODUTILS_PATCHES=\
	$(MODUTILS_SOURCE_DIR)/fix-path.diff \
	$(MODUTILS_SOURCE_DIR)/genksyms.diff \
	$(MODUTILS_SOURCE_DIR)/logging.patch \
	$(MODUTILS_SOURCE_DIR)/obj_kallsyms.c.patch \
	$(MODUTILS_SOURCE_DIR)/obj_mips.c.patch \
	$(MODUTILS_SOURCE_DIR)/insmod.c.patch \
	$(MODUTILS_SOURCE_DIR)/genksyms.c.patch \
	$(MODUTILS_SOURCE_DIR)/depmod.c.patch


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MODUTILS_CPPFLAGS=
MODUTILS_LDFLAGS=

#
# MODUTILS_BUILD_DIR is the directory in which the build is done.
# MODUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MODUTILS_IPK_DIR is the directory in which the ipk is built.
# MODUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MODUTILS_BUILD_DIR=$(BUILD_DIR)/modutils
MODUTILS_SOURCE_DIR=$(SOURCE_DIR)/modutils
MODUTILS_IPK_DIR=$(BUILD_DIR)/modutils-$(MODUTILS_VERSION)-ipk
MODUTILS_IPK=$(BUILD_DIR)/modutils_$(MODUTILS_VERSION)-$(MODUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MODUTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(MODUTILS_SITE)/$(MODUTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
modutils-source: $(DL_DIR)/$(MODUTILS_SOURCE) $(MODUTILS_PATCHES)

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
$(MODUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(MODUTILS_SOURCE) $(MODUTILS_PATCHES)
	rm -rf $(BUILD_DIR)/$(MODUTILS_DIR) $(MODUTILS_BUILD_DIR)
	$(MODUTILS_UNZIP) $(DL_DIR)/$(MODUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MODUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(MODUTILS_DIR) -p1 
	if test "$(BUILD_DIR)/$(MODUTILS_DIR)" != "$(MODUTILS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MODUTILS_DIR) $(MODUTILS_BUILD_DIR) ; \
	fi
	(cd $(MODUTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MODUTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MODUTILS_LDFLAGS)" \
		BUILDCC=gcc \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--disable-nls \
		--disable-static \
		--disable-strip \
	)
	touch $(MODUTILS_BUILD_DIR)/.configured

modutils-unpack: $(MODUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MODUTILS_BUILD_DIR)/.built: $(MODUTILS_BUILD_DIR)/.configured
	rm -f $(MODUTILS_BUILD_DIR)/.built
	$(MAKE) -C $(MODUTILS_BUILD_DIR) CFLAGS="$(STAGING_CPPFLAGS) $(MODUTILS_CPPFLAGS) -DMODDIR=\\\"/opt/lib/modules\\\""
	touch $(MODUTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
modutils: $(MODUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MODUTILS_BUILD_DIR)/.staged: $(MODUTILS_BUILD_DIR)/.built
	rm -f $(MODUTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(MODUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MODUTILS_BUILD_DIR)/.staged

modutils-stage: $(MODUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/modutils
#
$(MODUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(MODUTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: modutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MODUTILS_PRIORITY)" >>$@
	@echo "Section: $(MODUTILS_SECTION)" >>$@
	@echo "Version: $(MODUTILS_VERSION)-$(MODUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MODUTILS_MAINTAINER)" >>$@
	@echo "Source: $(MODUTILS_SITE)/$(MODUTILS_SOURCE)" >>$@
	@echo "Description: $(MODUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(MODUTILS_DEPENDS)" >>$@
	@echo "Suggests: $(MODUTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MODUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MODUTILS_IPK_DIR)/opt/sbin or $(MODUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MODUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MODUTILS_IPK_DIR)/opt/etc/modutils/...
# Documentation files should be installed in $(MODUTILS_IPK_DIR)/opt/doc/modutils/...
# Daemon startup scripts should be installed in $(MODUTILS_IPK_DIR)/opt/etc/init.d/S??modutils
#
# You may need to patch your application to make it use these locations.
#
$(MODUTILS_IPK): $(MODUTILS_BUILD_DIR)/.built
	rm -rf $(MODUTILS_IPK_DIR) $(BUILD_DIR)/modutils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MODUTILS_BUILD_DIR) DESTDIR=$(MODUTILS_IPK_DIR) install
	# Remove man pages
	rm -rf $(MODUTILS_IPK_DIR)/opt/man
	# Strip binaries
	$(STRIP_COMMAND) $(MODUTILS_IPK_DIR)/opt/sbin/depmod
	$(STRIP_COMMAND) $(MODUTILS_IPK_DIR)/opt/sbin/genksyms
	$(STRIP_COMMAND) $(MODUTILS_IPK_DIR)/opt/sbin/insmod
	$(STRIP_COMMAND) $(MODUTILS_IPK_DIR)/opt/sbin/modinfo
	install -d $(MODUTILS_IPK_DIR)/opt/etc/
	install -d $(MODUTILS_IPK_DIR)/opt/etc/init.d
	install -d $(MODUTILS_IPK_DIR)/opt/lib/
	install -m 755 $(MODUTILS_SOURCE_DIR)/rc.modutils $(MODUTILS_IPK_DIR)/opt/etc/init.d/S01modutils
	$(MAKE) $(MODUTILS_IPK_DIR)/CONTROL/control
	install -m 755 $(MODUTILS_SOURCE_DIR)/postinst $(MODUTILS_IPK_DIR)/CONTROL/postinst
	echo $(MODUTILS_CONFFILES) | sed -e 's/ /\n/g' > $(MODUTILS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MODUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
modutils-ipk: $(MODUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
modutils-clean:
	rm -f $(MODUTILS_BUILD_DIR)/.built
	-$(MAKE) -C $(MODUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
modutils-dirclean:
	rm -rf $(BUILD_DIR)/$(MODUTILS_DIR) $(MODUTILS_BUILD_DIR) $(MODUTILS_IPK_DIR) $(MODUTILS_IPK)
#
#
# Some sanity check for the package.
#
modutils-check: $(MODUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MODUTILS_IPK)
