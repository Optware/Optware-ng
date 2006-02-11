#        ##########################################################
#
# libftdi
#
###########################################################
#
# LIBFTDI_VERSION, LIBFTDI_SITE and LIBFTDI_SOURCE define
# the upstream location of the source code for the package.
# LIBFTDI_DIR is the directory which is created when the source
# archive is unpacked.
# LIBFTDI_UNZIP is the command used to unzip the source.
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
LIBFTDI_SITE=http://www.intra2net.com/de/produkte/opensource/ftdi/TGZ/
LIBFTDI_VERSION=0.7
LIBFTDI_SOURCE=libftdi-$(LIBFTDI_VERSION).tar.gz
LIBFTDI_DIR=libftdi-$(LIBFTDI_VERSION)
LIBFTDI_UNZIP=zcat
LIBFTDI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBFTDI_DESCRIPTION=Library to access the FTDI (usb2serial) chip in userspace via libusb
LIBFTDI_SECTION=libs,
LIBFTDI_PRIORITY=optional
LIBFTDI_DEPENDS=libusb
LIBFTDI_SUGGESTS=
LIBFTDI_CONFLICTS=

#
# LIBFTDI_IPK_VERSION should be incremented when the ipk changes.
#
LIBFTDI_IPK_VERSION=1

#
# LIBFTDI_CONFFILES should be a list of user-editable files
LIBFTDI_CONFFILES=

#
# LIBFTDI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBFTDI_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBFTDI_CPPFLAGS=
LIBFTDI_LDFLAGS=

#
# LIBFTDI_BUILD_DIR is the directory in which the build is done.
# LIBFTDI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBFTDI_IPK_DIR is the directory in which the ipk is built.
# LIBFTDI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBFTDI_BUILD_DIR=$(BUILD_DIR)/libftdi
LIBFTDI_SOURCE_DIR=$(SOURCE_DIR)/libftdi
LIBFTDI_IPK_DIR=$(BUILD_DIR)/libftdi-$(LIBFTDI_VERSION)-ipk
LIBFTDI_IPK=$(BUILD_DIR)/libftdi_$(LIBFTDI_VERSION)-$(LIBFTDI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBFTDI_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBFTDI_SITE)/$(LIBFTDI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libftdi-source: $(DL_DIR)/$(LIBFTDI_SOURCE) $(LIBFTDI_PATCHES)

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
$(LIBFTDI_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBFTDI_SOURCE) $(LIBFTDI_PATCHES)
	$(MAKE) libusb-stage 
	rm -rf $(BUILD_DIR)/$(LIBFTDI_DIR) $(LIBFTDI_BUILD_DIR)
	$(LIBFTDI_UNZIP) $(DL_DIR)/$(LIBFTDI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBFTDI_PATCHES)" ; \
		then cat $(LIBFTDI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBFTDI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBFTDI_DIR)" != "$(LIBFTDI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBFTDI_DIR) $(LIBFTDI_BUILD_DIR) ; \
	fi
	# use usb-config from the target, not from host
	(cd $(LIBFTDI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH=staging/opt/bin/:$(PATH) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBFTDI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBFTDI_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBFTDI_BUILD_DIR)/libtool
	touch $(LIBFTDI_BUILD_DIR)/.configured

libftdi-unpack: $(LIBFTDI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBFTDI_BUILD_DIR)/.built: $(LIBFTDI_BUILD_DIR)/.configured
	rm -f $(LIBFTDI_BUILD_DIR)/.built
	$(MAKE) -C $(LIBFTDI_BUILD_DIR)
	touch $(LIBFTDI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libftdi: $(LIBFTDI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBFTDI_BUILD_DIR)/.staged: $(LIBFTDI_BUILD_DIR)/.built
	rm -f $(LIBFTDI_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBFTDI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBFTDI_BUILD_DIR)/.staged

libftdi-stage: $(LIBFTDI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libftdi
#
$(LIBFTDI_IPK_DIR)/CONTROL/control:
	@install -d $(LIBFTDI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libftdi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBFTDI_PRIORITY)" >>$@
	@echo "Section: $(LIBFTDI_SECTION)" >>$@
	@echo "Version: $(LIBFTDI_VERSION)-$(LIBFTDI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBFTDI_MAINTAINER)" >>$@
	@echo "Source: $(LIBFTDI_SITE)/$(LIBFTDI_SOURCE)" >>$@
	@echo "Description: $(LIBFTDI_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBFTDI_DEPENDS)" >>$@
	@echo "Suggests: $(LIBFTDI_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBFTDI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBFTDI_IPK_DIR)/opt/sbin or $(LIBFTDI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBFTDI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBFTDI_IPK_DIR)/opt/etc/libftdi/...
# Documentation files should be installed in $(LIBFTDI_IPK_DIR)/opt/doc/libftdi/...
# Daemon startup scripts should be installed in $(LIBFTDI_IPK_DIR)/opt/etc/init.d/S??libftdi
#
# You may need to patch your application to make it use these locations.
#
$(LIBFTDI_IPK): $(LIBFTDI_BUILD_DIR)/.built
	rm -rf $(LIBFTDI_IPK_DIR) $(BUILD_DIR)/libftdi_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBFTDI_BUILD_DIR) DESTDIR=$(LIBFTDI_IPK_DIR) install-strip
	$(MAKE) $(LIBFTDI_IPK_DIR)/CONTROL/control
	echo $(LIBFTDI_CONFFILES) | sed -e 's/ /\n/g' > $(LIBFTDI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBFTDI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libftdi-ipk: $(LIBFTDI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libftdi-clean:
	rm -f $(LIBFTDI_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBFTDI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libftdi-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBFTDI_DIR) $(LIBFTDI_BUILD_DIR) $(LIBFTDI_IPK_DIR) $(LIBFTDI_IPK)
