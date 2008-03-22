###########################################################
#
# bluez2-utils
#
###########################################################

#
# BLUEZ2-UTILS_VERSION, BLUEZ2-UTILS_SITE and BLUEZ2-UTILS_SOURCE define
# the upstream location of the source code for the package.
# BLUEZ2-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# BLUEZ2-UTILS_UNZIP is the command used to unzip the source.
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
BLUEZ2-UTILS_SITE=http://bluez.sf.net/download
BLUEZ2-UTILS_VERSION=2.25
BLUEZ2-UTILS_SOURCE=bluez-utils-$(BLUEZ2-UTILS_VERSION).tar.gz
BLUEZ2-UTILS_DIR=bluez-utils-$(BLUEZ2-UTILS_VERSION)
BLUEZ2-UTILS_UNZIP=zcat
BLUEZ2-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BLUEZ2-UTILS_DESCRIPTION=Bluetooth utilities.
BLUEZ2-UTILS_SECTION=misc
BLUEZ2-UTILS_PRIORITY=optional
BLUEZ2-UTILS_DEPENDS=bluez2-libs
BLUEZ2-UTILS_SUGGESTS=
BLUEZ2-UTILS_CONFLICTS=bluez-utils

#
# BLUEZ2-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
BLUEZ2-UTILS_IPK_VERSION=4

#
# BLUEZ2-UTILS_CONFFILES should be a list of user-editable files
#BLUEZ2-UTILS_CONFFILES=/opt/etc/bluez-utils.conf /opt/etc/init.d/SXXbluez-utils
BLUEZ2-UTILS_CONFFILES=\
	/opt/etc/bluetooth/hcid.conf \
	/opt/etc/bluetooth/rfcomm.conf \
	/opt/etc/init.d/S75bluez-utils \
	/opt/etc/default/bluetooth

#
# BLUEZ2-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BLUEZ2-UTILS_PATCHES=$(BLUEZ2-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BLUEZ2-UTILS_CPPFLAGS=
BLUEZ2-UTILS_LDFLAGS=

#
# BLUEZ2-UTILS_BUILD_DIR is the directory in which the build is done.
# BLUEZ2-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BLUEZ2-UTILS_IPK_DIR is the directory in which the ipk is built.
# BLUEZ2-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BLUEZ2-UTILS_BUILD_DIR=$(BUILD_DIR)/bluez2-utils
BLUEZ2-UTILS_SOURCE_DIR=$(SOURCE_DIR)/bluez2-utils
BLUEZ2-UTILS_IPK_DIR=$(BUILD_DIR)/bluez2-utils-$(BLUEZ2-UTILS_VERSION)-ipk
BLUEZ2-UTILS_IPK=$(BUILD_DIR)/bluez2-utils_$(BLUEZ2-UTILS_VERSION)-$(BLUEZ2-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BLUEZ2-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(BLUEZ2-UTILS_SITE)/$(BLUEZ2-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bluez2-utils-source: $(DL_DIR)/$(BLUEZ2-UTILS_SOURCE) $(BLUEZ2-UTILS_PATCHES)

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
$(BLUEZ2-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(BLUEZ2-UTILS_SOURCE) $(BLUEZ2-UTILS_PATCHES)
	$(MAKE) bluez2-libs-stage
	rm -rf $(BUILD_DIR)/$(BLUEZ2-UTILS_DIR) $(BLUEZ2-UTILS_BUILD_DIR)
	$(BLUEZ2-UTILS_UNZIP) $(DL_DIR)/$(BLUEZ2-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(BLUEZ2-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(BLUEZ2-UTILS_DIR) -p1
	mv $(BUILD_DIR)/$(BLUEZ2-UTILS_DIR) $(BLUEZ2-UTILS_BUILD_DIR)
	(cd $(BLUEZ2-UTILS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BLUEZ2-UTILS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BLUEZ2-UTILS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(BLUEZ2-UTILS_BUILD_DIR)/libtool
	touch $(BLUEZ2-UTILS_BUILD_DIR)/.configured

bluez2-utils-unpack: $(BLUEZ2-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BLUEZ2-UTILS_BUILD_DIR)/.built: $(BLUEZ2-UTILS_BUILD_DIR)/.configured
	rm -f $(BLUEZ2-UTILS_BUILD_DIR)/.built
	$(MAKE) -C $(BLUEZ2-UTILS_BUILD_DIR)
	touch $(BLUEZ2-UTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
bluez2-utils: $(BLUEZ2-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BLUEZ2-UTILS_BUILD_DIR)/.staged: $(BLUEZ2-UTILS_BUILD_DIR)/.built
	rm -f $(BLUEZ2-UTILS_BUILD_DIR)/.staged
	$(MAKE) -C $(BLUEZ2-UTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-strip
	touch $(BLUEZ2-UTILS_BUILD_DIR)/.staged

bluez2-utils-stage: $(BLUEZ2-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bluez2-utils
#
$(BLUEZ2-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(BLUEZ2-UTILS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bluez2-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BLUEZ2-UTILS_PRIORITY)" >>$@
	@echo "Section: $(BLUEZ2-UTILS_SECTION)" >>$@
	@echo "Version: $(BLUEZ2-UTILS_VERSION)-$(BLUEZ2-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BLUEZ2-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(BLUEZ2-UTILS_SITE)/$(BLUEZ2-UTILS_SOURCE)" >>$@
	@echo "Description: $(BLUEZ2-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(BLUEZ2-UTILS_DEPENDS)" >>$@
	@echo "Suggests: $(BLUEZ2-UTILS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BLUEZ2-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BLUEZ2-UTILS_IPK_DIR)/opt/sbin or $(BLUEZ2-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BLUEZ2-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/bluez-utils/...
# Documentation files should be installed in $(BLUEZ2-UTILS_IPK_DIR)/opt/doc/bluez-utils/...
# Daemon startup scripts should be installed in $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/init.d/S??bluez-utils
#
# You may need to patch your application to make it use these locations.
#
$(BLUEZ2-UTILS_IPK): $(BLUEZ2-UTILS_BUILD_DIR)/.built
	rm -rf $(BLUEZ2-UTILS_IPK_DIR) $(BUILD_DIR)/bluez2-utils_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BLUEZ2-UTILS_BUILD_DIR) DESTDIR=$(BLUEZ2-UTILS_IPK_DIR) install-strip
	install -d $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/bluetooth
	install -m 0644 $(BLUEZ2-UTILS_SOURCE_DIR)/hcid.conf $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/bluetooth/hcid.conf
	install -m 0644 $(BLUEZ2-UTILS_SOURCE_DIR)/rfcomm.conf $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/bluetooth/rfcomm.conf
	install -d $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/default
	install -m 0644 $(BLUEZ2-UTILS_SOURCE_DIR)/bluetooth.default $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/default/bluetooth
	install -d $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/init.d
	install -m 0755 $(BLUEZ2-UTILS_SOURCE_DIR)/bluetooth.init $(BLUEZ2-UTILS_IPK_DIR)/opt/etc/init.d/S75bluez-utils
	$(MAKE) $(BLUEZ2-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BLUEZ2-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bluez2-utils-ipk: $(BLUEZ2-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bluez2-utils-clean:
	-$(MAKE) -C $(BLUEZ2-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bluez2-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(BLUEZ2-UTILS_DIR) $(BLUEZ2-UTILS_BUILD_DIR) $(BLUEZ2-UTILS_IPK_DIR) $(BLUEZ2-UTILS_IPK)
