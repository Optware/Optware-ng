###########################################################
#
# e2tools
#
###########################################################

#
# E2TOOLS_VERSION, E2TOOLS_SITE and E2TOOLS_SOURCE define
# the upstream location of the source code for the package.
# E2TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# E2TOOLS_UNZIP is the command used to unzip the source.
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
E2TOOLS_SITE=http://home.earthlink.net/~k_sheff/sw/e2tools
E2TOOLS_VERSION=0.0.16
E2TOOLS_SOURCE=e2tools-$(E2TOOLS_VERSION).tar.gz
E2TOOLS_DIR=e2tools-$(E2TOOLS_VERSION)
E2TOOLS_UNZIP=zcat
E2TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
E2TOOLS_DESCRIPTION=Ext2 tools
E2TOOLS_SECTION=admin
E2TOOLS_PRIORITY=optional
E2TOOLS_DEPENDS=e2fsprogs
E2TOOLS_SUGGESTS=
E2TOOLS_CONFLICTS=

#
# E2TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
E2TOOLS_IPK_VERSION=3

#
# E2TOOLS_CONFFILES should be a list of user-editable files
E2TOOLS_CONFFILES=

#
# E2TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
E2TOOLS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
E2TOOLS_CPPFLAGS=
E2TOOLS_LDFLAGS=

#
# E2TOOLS_BUILD_DIR is the directory in which the build is done.
# E2TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# E2TOOLS_IPK_DIR is the directory in which the ipk is built.
# E2TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
E2TOOLS_BUILD_DIR=$(BUILD_DIR)/e2tools
E2TOOLS_SOURCE_DIR=$(SOURCE_DIR)/e2tools
E2TOOLS_IPK_DIR=$(BUILD_DIR)/e2tools-$(E2TOOLS_VERSION)-ipk
E2TOOLS_IPK=$(BUILD_DIR)/e2tools_$(E2TOOLS_VERSION)-$(E2TOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(E2TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(E2TOOLS_SITE)/$(E2TOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
e2tools-source: $(DL_DIR)/$(E2TOOLS_SOURCE) $(E2TOOLS_PATCHES)

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
$(E2TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(E2TOOLS_SOURCE) $(E2TOOLS_PATCHES)
	$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(E2TOOLS_DIR) $(E2TOOLS_BUILD_DIR)
	$(E2TOOLS_UNZIP) $(DL_DIR)/$(E2TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(E2TOOLS_PATCHES)" ; \
		then cat $(E2TOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(E2TOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(E2TOOLS_DIR)" != "$(E2TOOLS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(E2TOOLS_DIR) $(E2TOOLS_BUILD_DIR) ; \
	fi
	(cd $(E2TOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(E2TOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(E2TOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -ie '/^INCLUDES/s|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|' $(E2TOOLS_BUILD_DIR)/Makefile
	touch $(E2TOOLS_BUILD_DIR)/.configured

e2tools-unpack: $(E2TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(E2TOOLS_BUILD_DIR)/.built: $(E2TOOLS_BUILD_DIR)/.configured
	rm -f $(E2TOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(E2TOOLS_BUILD_DIR)
	touch $(E2TOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
e2tools: $(E2TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(E2TOOLS_BUILD_DIR)/.staged: $(E2TOOLS_BUILD_DIR)/.built
	rm -f $(E2TOOLS_BUILD_DIR)/.staged
	$(MAKE) -C $(E2TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(E2TOOLS_BUILD_DIR)/.staged

e2tools-stage: $(E2TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/e2tools
#
$(E2TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(E2TOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: e2tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(E2TOOLS_PRIORITY)" >>$@
	@echo "Section: $(E2TOOLS_SECTION)" >>$@
	@echo "Version: $(E2TOOLS_VERSION)-$(E2TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(E2TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(E2TOOLS_SITE)/$(E2TOOLS_SOURCE)" >>$@
	@echo "Description: $(E2TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(E2TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(E2TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(E2TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(E2TOOLS_IPK_DIR)/opt/sbin or $(E2TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(E2TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(E2TOOLS_IPK_DIR)/opt/etc/e2tools/...
# Documentation files should be installed in $(E2TOOLS_IPK_DIR)/opt/doc/e2tools/...
# Daemon startup scripts should be installed in $(E2TOOLS_IPK_DIR)/opt/etc/init.d/S??e2tools
#
# You may need to patch your application to make it use these locations.
#
$(E2TOOLS_IPK): $(E2TOOLS_BUILD_DIR)/.built
	rm -rf $(E2TOOLS_IPK_DIR) $(BUILD_DIR)/e2tools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(E2TOOLS_BUILD_DIR) DESTDIR=$(E2TOOLS_IPK_DIR) install
	$(MAKE) $(E2TOOLS_IPK_DIR)/CONTROL/control
	echo $(E2TOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(E2TOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(E2TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
e2tools-ipk: $(E2TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
e2tools-clean:
	rm -f $(E2TOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(E2TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
e2tools-dirclean:
	rm -rf $(BUILD_DIR)/$(E2TOOLS_DIR) $(E2TOOLS_BUILD_DIR) $(E2TOOLS_IPK_DIR) $(E2TOOLS_IPK)
