###########################################################
#
# oww
#
###########################################################

# You must replace "oww" and "OWW" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# OWW_VERSION, OWW_SITE and OWW_SOURCE define
# the upstream location of the source code for the package.
# OWW_DIR is the directory which is created when the source
# archive is unpacked.
# OWW_UNZIP is the command used to unzip the source.
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
OWW_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/oww
OWW_VERSION=0.82.0
#OWW_SITE=http://192.168.1.6/~sjm/oww
#OWW_VERSION=0.82.0
OWW_SOURCE=oww-$(OWW_VERSION).tar.gz
OWW_DIR=oww-$(OWW_VERSION)
OWW_UNZIP=zcat
OWW_MAINTAINER=Simon Melhuish - simon@melhuish.info
OWW_DESCRIPTION=Oww reads from a DalSemi/AAG weather station.
OWW_SECTION=misc
OWW_PRIORITY=optional
OWW_DEPENDS=libcurl, libusb
OWW_SUGGESTS=
OWW_CONFLICTS=

#
# OWW_IPK_VERSION should be incremented when the ipk changes.
#
OWW_IPK_VERSION=1

#
# OWW_CONFFILES should be a list of user-editable files
#OWW_CONFFILES=/opt/etc/oww.conf /opt/etc/init.d/SXXoww

#
# OWW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OWW_PATCHES=$(OWW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OWW_CPPFLAGS=
OWW_LDFLAGS=

#
# OWW_BUILD_DIR is the directory in which the build is done.
# OWW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OWW_IPK_DIR is the directory in which the ipk is built.
# OWW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OWW_BUILD_DIR=$(BUILD_DIR)/oww
OWW_SOURCE_DIR=$(SOURCE_DIR)/oww
OWW_IPK_DIR=$(BUILD_DIR)/oww-$(OWW_VERSION)-ipk
OWW_IPK=$(BUILD_DIR)/oww_$(OWW_VERSION)-$(OWW_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OWW_SOURCE):
	$(WGET) -P $(DL_DIR) $(OWW_SITE)/$(OWW_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
oww-source: $(DL_DIR)/$(OWW_SOURCE) $(OWW_PATCHES)

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
$(OWW_BUILD_DIR)/.configured: $(DL_DIR)/$(OWW_SOURCE) $(OWW_PATCHES)
	$(MAKE) libcurl-stage libusb-stage
	rm -rf $(BUILD_DIR)/$(OWW_DIR) $(OWW_BUILD_DIR)
	$(OWW_UNZIP) $(DL_DIR)/$(OWW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(OWW_PATCHES) | patch -d $(BUILD_DIR)/$(OWW_DIR) -p1
	mv $(BUILD_DIR)/$(OWW_DIR) $(OWW_BUILD_DIR)
	(cd $(OWW_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OWW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OWW_LDFLAGS)" \
		LIBUSB_CONFIG=$(STAGING_PREFIX)/bin/libusb-config \
		_libcurl_config=$(STAGING_PREFIX)/bin/curl-config \
		ac_cv_header_libintl_h=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-gui \
	)
	touch $(OWW_BUILD_DIR)/.configured

oww-unpack: $(OWW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OWW_BUILD_DIR)/.built: $(OWW_BUILD_DIR)/.configured
	rm -f $(OWW_BUILD_DIR)/.built
	$(MAKE) -C $(OWW_BUILD_DIR)
	touch $(OWW_BUILD_DIR)/.built

#
# This is the build convenience target.
#
oww: $(OWW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OWW_BUILD_DIR)/.staged: $(OWW_BUILD_DIR)/.built
	rm -f $(OWW_BUILD_DIR)/.staged
	$(MAKE) -C $(OWW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(OWW_BUILD_DIR)/.staged

oww-stage: $(OWW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/oww
#
$(OWW_IPK_DIR)/CONTROL/control:
	@install -d $(OWW_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: oww" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OWW_PRIORITY)" >>$@
	@echo "Section: $(OWW_SECTION)" >>$@
	@echo "Version: $(OWW_VERSION)-$(OWW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OWW_MAINTAINER)" >>$@
	@echo "Source: $(OWW_SITE)/$(OWW_SOURCE)" >>$@
	@echo "Description: $(OWW_DESCRIPTION)" >>$@
	@echo "Depends: $(OWW_DEPENDS)" >>$@
	@echo "Suggests: $(OWW_SUGGESTS)" >>$@
	@echo "Conflicts: $(OWW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OWW_IPK_DIR)/opt/sbin or $(OWW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OWW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OWW_IPK_DIR)/opt/etc/oww/...
# Documentation files should be installed in $(OWW_IPK_DIR)/opt/doc/oww/...
# Daemon startup scripts should be installed in $(OWW_IPK_DIR)/opt/etc/init.d/S??oww
#
# You may need to patch your application to make it use these locations.
#
$(OWW_IPK): $(OWW_BUILD_DIR)/.built
	rm -rf $(OWW_IPK_DIR) $(BUILD_DIR)/oww_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OWW_BUILD_DIR) DESTDIR=$(OWW_IPK_DIR) install-strip
#	install -d $(OWW_IPK_DIR)/opt/etc/
#	install -m 644 $(OWW_SOURCE_DIR)/oww.conf $(OWW_IPK_DIR)/opt/etc/oww.conf
	install -d $(OWW_IPK_DIR)/opt/etc/init.d
	install -m 755 $(OWW_SOURCE_DIR)/rc.oww $(OWW_IPK_DIR)/opt/etc/init.d/S80oww
	$(MAKE) $(OWW_IPK_DIR)/CONTROL/control
	install -m 755 $(OWW_SOURCE_DIR)/postinst $(OWW_IPK_DIR)/CONTROL/postinst
	install -m 755 $(OWW_SOURCE_DIR)/prerm $(OWW_IPK_DIR)/CONTROL/prerm
	echo $(OWW_CONFFILES) | sed -e 's/ /\n/g' > $(OWW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OWW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
oww-ipk: $(OWW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
oww-clean:
	-$(MAKE) -C $(OWW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
oww-dirclean:
	rm -rf $(BUILD_DIR)/$(OWW_DIR) $(OWW_BUILD_DIR) $(OWW_IPK_DIR) $(OWW_IPK)
