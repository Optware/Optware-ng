###########################################################
#
# bluez2-libs
#
###########################################################

#
# BLUEZ2-LIBS_VERSION, BLUEZ2-LIBS_SITE and BLUEZ2-LIBS_SOURCE define
# the upstream location of the source code for the package.
# BLUEZ2-LIBS_DIR is the directory which is created when the source
# archive is unpacked.
# BLUEZ2-LIBS_UNZIP is the command used to unzip the source.
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
BLUEZ2-LIBS_SITE=http://bluez.sf.net/download
BLUEZ2-LIBS_VERSION=2.25
BLUEZ2-LIBS_SOURCE=bluez-libs-$(BLUEZ2-LIBS_VERSION).tar.gz
BLUEZ2-LIBS_DIR=bluez-libs-$(BLUEZ2-LIBS_VERSION)
BLUEZ2-LIBS_UNZIP=zcat
BLUEZ2-LIBS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BLUEZ2-LIBS_DESCRIPTION=Bluetooth libraries.
BLUEZ2-LIBS_SECTION=misc
BLUEZ2-LIBS_PRIORITY=optional
BLUEZ2-LIBS_DEPENDS=
BLUEZ2-LIBS_SUGGESTS=
BLUEZ2-LIBS_CONFLICTS=bluez-libs

#
# BLUEZ2-LIBS_IPK_VERSION should be incremented when the ipk changes.
#
BLUEZ2-LIBS_IPK_VERSION=1

#
# BLUEZ2-LIBS_CONFFILES should be a list of user-editable files
#BLUEZ2-LIBS_CONFFILES=/opt/etc/bluez-libs.conf /opt/etc/init.d/SXXbluez-libs

#
# BLUEZ2-LIBS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BLUEZ2-LIBS_PATCHES=$(BLUEZ2-LIBS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BLUEZ2-LIBS_CPPFLAGS=
BLUEZ2-LIBS_LDFLAGS=

#
# BLUEZ2-LIBS_BUILD_DIR is the directory in which the build is done.
# BLUEZ2-LIBS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BLUEZ2-LIBS_IPK_DIR is the directory in which the ipk is built.
# BLUEZ2-LIBS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BLUEZ2-LIBS_BUILD_DIR=$(BUILD_DIR)/bluez2-libs
BLUEZ2-LIBS_SOURCE_DIR=$(SOURCE_DIR)/bluez2-libs
BLUEZ2-LIBS_IPK_DIR=$(BUILD_DIR)/bluez2-libs-$(BLUEZ2-LIBS_VERSION)-ipk
BLUEZ2-LIBS_IPK=$(BUILD_DIR)/bluez2-libs_$(BLUEZ2-LIBS_VERSION)-$(BLUEZ2-LIBS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BLUEZ2-LIBS_SOURCE):
	$(WGET) -P $(@D) $(BLUEZ2-LIBS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bluez2-libs-source: $(DL_DIR)/$(BLUEZ2-LIBS_SOURCE) $(BLUEZ2-LIBS_PATCHES)

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
$(BLUEZ2-LIBS_BUILD_DIR)/.configured: $(DL_DIR)/$(BLUEZ2-LIBS_SOURCE) $(BLUEZ2-LIBS_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BLUEZ2-LIBS_DIR) $(@D)
	$(BLUEZ2-LIBS_UNZIP) $(DL_DIR)/$(BLUEZ2-LIBS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(BLUEZ2-LIBS_PATCHES) | patch -d $(BUILD_DIR)/$(BLUEZ2-LIBS_DIR) -p1
	mv $(BUILD_DIR)/$(BLUEZ2-LIBS_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BLUEZ2-LIBS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BLUEZ2-LIBS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bluez2-libs-unpack: $(BLUEZ2-LIBS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BLUEZ2-LIBS_BUILD_DIR)/.built: $(BLUEZ2-LIBS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bluez2-libs: $(BLUEZ2-LIBS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BLUEZ2-LIBS_BUILD_DIR)/.staged: $(BLUEZ2-LIBS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install-strip
	rm -f $(STAGING_LIB_DIR)/libbluetooth.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/bluez.pc
	touch $@

bluez2-libs-stage: $(BLUEZ2-LIBS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bluez2-libs
#
$(BLUEZ2-LIBS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bluez2-libs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BLUEZ2-LIBS_PRIORITY)" >>$@
	@echo "Section: $(BLUEZ2-LIBS_SECTION)" >>$@
	@echo "Version: $(BLUEZ2-LIBS_VERSION)-$(BLUEZ2-LIBS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BLUEZ2-LIBS_MAINTAINER)" >>$@
	@echo "Source: $(BLUEZ2-LIBS_SITE)/$(BLUEZ2-LIBS_SOURCE)" >>$@
	@echo "Description: $(BLUEZ2-LIBS_DESCRIPTION)" >>$@
	@echo "Depends: $(BLUEZ2-LIBS_DEPENDS)" >>$@
	@echo "Suggests: $(BLUEZ2-LIBS_SUGGESTS)" >>$@
	@echo "Conflicts: $(BLUEZ2-LIBS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BLUEZ2-LIBS_IPK_DIR)/opt/sbin or $(BLUEZ2-LIBS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BLUEZ2-LIBS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BLUEZ2-LIBS_IPK_DIR)/opt/etc/bluez-libs/...
# Documentation files should be installed in $(BLUEZ2-LIBS_IPK_DIR)/opt/doc/bluez-libs/...
# Daemon startup scripts should be installed in $(BLUEZ2-LIBS_IPK_DIR)/opt/etc/init.d/S??bluez-libs
#
# You may need to patch your application to make it use these locations.
#
$(BLUEZ2-LIBS_IPK): $(BLUEZ2-LIBS_BUILD_DIR)/.built
	rm -rf $(BLUEZ2-LIBS_IPK_DIR) $(BUILD_DIR)/bluez2-libs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BLUEZ2-LIBS_BUILD_DIR) DESTDIR=$(BLUEZ2-LIBS_IPK_DIR) install-strip
	rm -f $(BLUEZ2-LIBS_IPK_DIR)/opt/lib/libbluetooth.la
	$(MAKE) $(BLUEZ2-LIBS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BLUEZ2-LIBS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bluez2-libs-ipk: $(BLUEZ2-LIBS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bluez2-libs-clean:
	-$(MAKE) -C $(BLUEZ2-LIBS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bluez2-libs-dirclean:
	rm -rf $(BUILD_DIR)/$(BLUEZ2-LIBS_DIR) $(BLUEZ2-LIBS_BUILD_DIR) $(BLUEZ2-LIBS_IPK_DIR) $(BLUEZ2-LIBS_IPK)
