###########################################################
#
# bc
#
###########################################################

# You must replace "bc" and "BC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BC_VERSION, BC_SITE and BC_SOURCE define
# the upstream location of the source code for the package.
# BC_DIR is the directory which is created when the source
# archive is unpacked.
# BC_UNZIP is the command used to unzip the source.
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
BC_SITE=http://ftp.gnu.org/gnu/bc
BC_VERSION=1.06
BC_SOURCE=bc-$(BC_VERSION).tar.gz
BC_DIR=bc-$(BC_VERSION)
BC_UNZIP=zcat
BC_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
BC_DESCRIPTION=GNU bc is an arbitrary precision numeric processing language
BC_SECTION=misc
BC_PRIORITY=optional
BC_DEPENDS=

#
# BC_IPK_VERSION should be incremented when the ipk changes.
#
BC_IPK_VERSION=1

#
# BC_CONFFILES should be a list of user-editable files
#BC_CONFFILES=/opt/etc/bc.conf /opt/etc/init.d/SXXbc

#
# BC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BC_PATCHES=$(BC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BC_CPPFLAGS=
BC_LDFLAGS=

#
# BC_BUILD_DIR is the directory in which the build is done.
# BC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BC_IPK_DIR is the directory in which the ipk is built.
# BC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BC_BUILD_DIR=$(BUILD_DIR)/bc
BC_SOURCE_DIR=$(SOURCE_DIR)/bc
BC_IPK_DIR=$(BUILD_DIR)/bc-$(BC_VERSION)-ipk
BC_IPK=$(BUILD_DIR)/bc_$(BC_VERSION)-$(BC_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BC_SOURCE):
	$(WGET) -P $(DL_DIR) $(BC_SITE)/$(BC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bc-source: $(DL_DIR)/$(BC_SOURCE) $(BC_PATCHES)

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
$(BC_BUILD_DIR)/.configured: $(DL_DIR)/$(BC_SOURCE) $(BC_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BC_DIR) $(BC_BUILD_DIR)
	$(BC_UNZIP) $(DL_DIR)/$(BC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(BC_PATCHES) | patch -d $(BUILD_DIR)/$(BC_DIR) -p1
	mv $(BUILD_DIR)/$(BC_DIR) $(BC_BUILD_DIR)
	(cd $(BC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(BC_BUILD_DIR)/.configured

bc-unpack: $(BC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BC_BUILD_DIR)/.built: $(BC_BUILD_DIR)/.configured
	rm -f $(BC_BUILD_DIR)/.built
	$(MAKE) -C $(BC_BUILD_DIR)
	touch $(BC_BUILD_DIR)/.built

#
# This is the build convenience target.
#
bc: $(BC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BC_BUILD_DIR)/.staged: $(BC_BUILD_DIR)/.built
	rm -f $(BC_BUILD_DIR)/.staged
	$(MAKE) -C $(BC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BC_BUILD_DIR)/.staged

bc-stage: $(BC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bc
#
$(BC_IPK_DIR)/CONTROL/control:
	@install -d $(BC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BC_PRIORITY)" >>$@
	@echo "Section: $(BC_SECTION)" >>$@
	@echo "Version: $(BC_VERSION)-$(BC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BC_MAINTAINER)" >>$@
	@echo "Source: $(BC_SITE)/$(BC_SOURCE)" >>$@
	@echo "Description: $(BC_DESCRIPTION)" >>$@
	@echo "Depends: $(BC_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BC_IPK_DIR)/opt/sbin or $(BC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BC_IPK_DIR)/opt/etc/bc/...
# Documentation files should be installed in $(BC_IPK_DIR)/opt/doc/bc/...
# Daemon startup scripts should be installed in $(BC_IPK_DIR)/opt/etc/init.d/S??bc
#
# You may need to patch your application to make it use these locations.
#
$(BC_IPK): $(BC_BUILD_DIR)/.built
	rm -rf $(BC_IPK_DIR) $(BUILD_DIR)/bc_*_$(TARGET_ARCH).ipk
	umask 0022; $(MAKE) -C $(BC_BUILD_DIR) DESTDIR=$(BC_IPK_DIR) install
	$(MAKE) $(BC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bc-ipk: $(BC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bc-clean:
	-$(MAKE) -C $(BC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bc-dirclean:
	rm -rf $(BUILD_DIR)/$(BC_DIR) $(BC_BUILD_DIR) $(BC_IPK_DIR) $(BC_IPK)
