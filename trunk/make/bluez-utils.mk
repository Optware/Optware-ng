###########################################################
#
# bluez-utils
#
###########################################################

#
# BLUEZ-UTILS_VERSION, BLUEZ-UTILS_SITE and BLUEZ-UTILS_SOURCE define
# the upstream location of the source code for the package.
# BLUEZ-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BLUEZ-UTILS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
BLUEZ-UTILS_SITE=http://bluez.sf.net/download
BLUEZ-UTILS_VERSION=2.21
BLUEZ-UTILS_SOURCE=bluez-utils-$(BLUEZ-UTILS_VERSION).tar.gz
BLUEZ-UTILS_DIR=bluez-utils-$(BLUEZ-UTILS_VERSION)
BLUEZ-UTILS_UNZIP=zcat
BLUEZ-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BLUEZ-UTILS_DESCRIPTION=Bluetooth utilities.
BLUEZ-UTILS_SECTION=misc
BLUEZ-UTILS_PRIORITY=optional
BLUEZ-UTILS_DEPENDS=bluez-libs
BLUEZ-UTILS_SUGGESTS=
BLUEZ-UTILS_CONFLICTS=

#
# BLUEZ-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
BLUEZ-UTILS_IPK_VERSION=1

#
# BLUEZ-UTILS_CONFFILES should be a list of user-editable files
#BLUEZ-UTILS_CONFFILES=/opt/etc/bluez-utils.conf /opt/etc/init.d/SXXbluez-utils

#
# BLUEZ-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BLUEZ-UTILS_PATCHES=$(BLUEZ-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BLUEZ-UTILS_CPPFLAGS=
BLUEZ-UTILS_LDFLAGS=

#
# BLUEZ-UTILS_BUILD_DIR is the directory in which the build is done.
# BLUEZ-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BLUEZ-UTILS_IPK_DIR is the directory in which the ipk is built.
# BLUEZ-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BLUEZ-UTILS_BUILD_DIR=$(BUILD_DIR)/bluez-utils
BLUEZ-UTILS_SOURCE_DIR=$(SOURCE_DIR)/bluez-utils
BLUEZ-UTILS_IPK_DIR=$(BUILD_DIR)/bluez-utils-$(BLUEZ-UTILS_VERSION)-ipk
BLUEZ-UTILS_IPK=$(BUILD_DIR)/bluez-utils_$(BLUEZ-UTILS_VERSION)-$(BLUEZ-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BLUEZ-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(BLUEZ-UTILS_SITE)/$(BLUEZ-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bluez-utils-source: $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) $(BLUEZ-UTILS_PATCHES)

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
$(BLUEZ-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) $(BLUEZ-UTILS_PATCHES)
	$(MAKE) bluez-libs-stage
	rm -rf $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(BLUEZ-UTILS_BUILD_DIR)
	$(BLUEZ-UTILS_UNZIP) $(DL_DIR)/$(BLUEZ-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(BLUEZ-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) -p1
	mv $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(BLUEZ-UTILS_BUILD_DIR)
	(cd $(BLUEZ-UTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BLUEZ-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BLUEZ-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(BLUEZ-UTILS_BUILD_DIR)/libtool
	touch $(BLUEZ-UTILS_BUILD_DIR)/.configured

bluez-utils-unpack: $(BLUEZ-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BLUEZ-UTILS_BUILD_DIR)/.built: $(BLUEZ-UTILS_BUILD_DIR)/.configured
	rm -f $(BLUEZ-UTILS_BUILD_DIR)/.built
	$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR)
	touch $(BLUEZ-UTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
bluez-utils: $(BLUEZ-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BLUEZ-UTILS_BUILD_DIR)/.staged: $(BLUEZ-UTILS_BUILD_DIR)/.built
	rm -f $(BLUEZ-UTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-strip
	touch $(BLUEZ-UTILS_BUILD_DIR)/.staged

bluez-utils-stage: $(BLUEZ-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bluez-utils
#
$(BLUEZ-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(BLUEZ-UTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bluez-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BLUEZ-UTILS_PRIORITY)" >>$@
	@echo "Section: $(BLUEZ-UTILS_SECTION)" >>$@
	@echo "Version: $(BLUEZ-UTILS_VERSION)-$(BLUEZ-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BLUEZ-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(BLUEZ-UTILS_SITE)/$(BLUEZ-UTILS_SOURCE)" >>$@
	@echo "Description: $(BLUEZ-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BLUEZ-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BLUEZ-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BLUEZ-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BLUEZ-UTILS_IPK_DIR)/opt/sbin or $(BLUEZ-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BLUEZ-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/etc/bluez-utils/...
# Documentation files should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/doc/bluez-utils/...
# Daemon startup scripts should be installed in $(BLUEZ-UTILS_IPK_DIR)/opt/etc/init.d/S??bluez-utils
#
# You may need to patch your application to make it use these locations.
#
$(BLUEZ-UTILS_IPK): $(BLUEZ-UTILS_BUILD_DIR)/.built
	rm -rf $(BLUEZ-UTILS_IPK_DIR) $(BUILD_DIR)/bluez-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR) DESTDIR=$(BLUEZ-UTILS_IPK_DIR) install-strip
	$(MAKE) $(BLUEZ-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BLUEZ-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bluez-utils-ipk: $(BLUEZ-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bluez-utils-clean:
	-$(MAKE) -C $(BLUEZ-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bluez-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(BLUEZ-UTILS_DIR) $(BLUEZ-UTILS_BUILD_DIR) $(BLUEZ-UTILS_IPK_DIR) $(BLUEZ-UTILS_IPK)
