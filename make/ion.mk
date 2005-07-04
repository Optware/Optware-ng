###########################################################
#
# ion
#
###########################################################

#
# ION_VERSION, ION_SITE and ION_SOURCE define
# the upstream location of the source code for the package.
# ION_DIR is the directory which is created when the source
# archive is unpacked.
# ION_UNZIP is the command used to unzip the source.
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
ION_SITE=http://modeemi.cs.tut.fi/~tuomov/ion/dl
ION_VERSION=20050625
ION_SOURCE=ion-3ds-$(ION_VERSION).tar.gz
ION_DIR=ion-3ds-$(ION_VERSION)
ION_UNZIP=zcat
ION_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
ION_DESCRIPTION=Ion is a tiling tabbed window manager designed with keyboard users in mind.
ION_SECTION=x11
ION_PRIORITY=optional
ION_DEPENDS=lua

#
# ION_IPK_VERSION should be incremented when the ipk changes.
#
ION_IPK_VERSION=1

#
# ION_CONFFILES should be a list of user-editable files
#ION_CONFFILES=/opt/etc/ion.conf /opt/etc/init.d/SXXion

#
# ION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ION_PATCHES=$(ION_SOURCE_DIR)/configure.ac.patch $(ION_SOURCE_DIR)/Makefiles.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ION_CPPFLAGS=
ION_LDFLAGS=-lXau

#
# ION_BUILD_DIR is the directory in which the build is done.
# ION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ION_IPK_DIR is the directory in which the ipk is built.
# ION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ION_BUILD_DIR=$(BUILD_DIR)/ion
ION_SOURCE_DIR=$(SOURCE_DIR)/ion
ION_IPK_DIR=$(BUILD_DIR)/ion-$(ION_VERSION)-ipk
ION_IPK=$(BUILD_DIR)/ion_$(ION_VERSION)-$(ION_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ION_SOURCE):
	$(WGET) -P $(DL_DIR) $(ION_SITE)/$(ION_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ion-source: $(DL_DIR)/$(ION_SOURCE) $(ION_PATCHES)

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
$(ION_BUILD_DIR)/.configured: $(DL_DIR)/$(ION_SOURCE) $(ION_PATCHES)
	$(MAKE) lua-stage
	rm -rf $(BUILD_DIR)/$(ION_DIR) $(ION_BUILD_DIR)
	$(ION_UNZIP) $(DL_DIR)/$(ION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ION_PATCHES) | patch -d $(BUILD_DIR)/$(ION_DIR) -p1
	mv $(BUILD_DIR)/$(ION_DIR) $(ION_BUILD_DIR)
	(cd $(ION_BUILD_DIR); \
		autoreconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ION_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
                --x-includes=$(STAGING_INCLUDE_DIR) \
                --x-libraries=$(STAGING_LIB_DIR) \
		--with-lua-includes=$(STAGING_INCLUDE_DIR) \
		--with-lua-libraries=$(STAGING_LIB_DIR) \
		--disable-nls \
	)
	touch $(ION_BUILD_DIR)/.configured

ion-unpack: $(ION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ION_BUILD_DIR)/.built: $(ION_BUILD_DIR)/.configured
	rm -f $(ION_BUILD_DIR)/.built
	$(MAKE) -C $(ION_BUILD_DIR)
	touch $(ION_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ion: $(ION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ION_BUILD_DIR)/.staged: $(ION_BUILD_DIR)/.built
	rm -f $(ION_BUILD_DIR)/.staged
	$(MAKE) -C $(ION_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ION_BUILD_DIR)/.staged

ion-stage: $(ION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ion
#
$(ION_IPK_DIR)/CONTROL/control:
	@install -d $(ION_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ION_PRIORITY)" >>$@
	@echo "Section: $(ION_SECTION)" >>$@
	@echo "Version: $(ION_VERSION)-$(ION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ION_MAINTAINER)" >>$@
	@echo "Source: $(ION_SITE)/$(ION_SOURCE)" >>$@
	@echo "Description: $(ION_DESCRIPTION)" >>$@
	@echo "Depends: $(ION_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ION_IPK_DIR)/opt/sbin or $(ION_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ION_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ION_IPK_DIR)/opt/etc/ion/...
# Documentation files should be installed in $(ION_IPK_DIR)/opt/doc/ion/...
# Daemon startup scripts should be installed in $(ION_IPK_DIR)/opt/etc/init.d/S??ion
#
# You may need to patch your application to make it use these locations.
#
$(ION_IPK): $(ION_BUILD_DIR)/.built
	rm -rf $(ION_IPK_DIR) $(BUILD_DIR)/ion_*_$(TARGET_ARCH).ipk
	$(TARGET_CONFIGURE_OPTS) \
	$(MAKE) -C $(ION_BUILD_DIR) prefix=$(ION_IPK_DIR)/opt LOCALEDIR=$(ION_IPK_DIR)/opt/share/locale install
	$(MAKE) $(ION_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ion-ipk: $(ION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ion-clean:
	-$(MAKE) -C $(ION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ion-dirclean:
	rm -rf $(BUILD_DIR)/$(ION_DIR) $(ION_BUILD_DIR) $(ION_IPK_DIR) $(ION_IPK)
