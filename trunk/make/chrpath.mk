###########################################################
#
# chrpath
#
###########################################################

#
# CHRPATH_VERSION, CHRPATH_SITE and CHRPATH_SOURCE define
# the upstream location of the source code for the package.
# CHRPATH_DIR is the directory which is created when the source
# archive is unpacked.
# CHRPATH_UNZIP is the command used to unzip the source.
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
CHRPATH_SITE=http://www.tux.org/pub/X-Windows/ftp.hungry.com/chrpath
# the main site seems to have problem with passive ftp downloading ftp://ftp.hungry.com/pub/hungry/chrpath/chrpath-0.13.tar.gz
CHRPATH_VERSION=0.13
CHRPATH_SOURCE=chrpath-$(CHRPATH_VERSION).tar.gz
CHRPATH_DIR=chrpath-$(CHRPATH_VERSION)
CHRPATH_UNZIP=zcat
CHRPATH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHRPATH_DESCRIPTION=chrpath allows you to modify the dynamic library load path (rpath and runpath) of compiled programs and libraries.
CHRPATH_SECTION=misc
CHRPATH_PRIORITY=optional
CHRPATH_DEPENDS=
CHRPATH_SUGGESTS=
CHRPATH_CONFLICTS=

#
# CHRPATH_IPK_VERSION should be incremented when the ipk changes.
#
CHRPATH_IPK_VERSION=1

#
# CHRPATH_CONFFILES should be a list of user-editable files
#CHRPATH_CONFFILES=/opt/etc/chrpath.conf /opt/etc/init.d/SXXchrpath

#
# CHRPATH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CHRPATH_PATCHES=$(CHRPATH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHRPATH_CPPFLAGS=
CHRPATH_LDFLAGS=

#
# CHRPATH_BUILD_DIR is the directory in which the build is done.
# CHRPATH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHRPATH_IPK_DIR is the directory in which the ipk is built.
# CHRPATH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHRPATH_BUILD_DIR=$(BUILD_DIR)/chrpath
CHRPATH_SOURCE_DIR=$(SOURCE_DIR)/chrpath
CHRPATH_IPK_DIR=$(BUILD_DIR)/chrpath-$(CHRPATH_VERSION)-ipk
CHRPATH_IPK=$(BUILD_DIR)/chrpath_$(CHRPATH_VERSION)-$(CHRPATH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CHRPATH_SOURCE):
	$(WGET) -P $(DL_DIR) $(CHRPATH_SITE)/$(CHRPATH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
chrpath-source: $(DL_DIR)/$(CHRPATH_SOURCE) $(CHRPATH_PATCHES)

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
$(CHRPATH_BUILD_DIR)/.configured: $(DL_DIR)/$(CHRPATH_SOURCE) $(CHRPATH_PATCHES) make/chrpath.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CHRPATH_DIR) $(CHRPATH_BUILD_DIR)
	$(CHRPATH_UNZIP) $(DL_DIR)/$(CHRPATH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(CHRPATH_PATCHES) | patch -d $(BUILD_DIR)/$(CHRPATH_DIR) -p1
	mv $(BUILD_DIR)/$(CHRPATH_DIR) $(CHRPATH_BUILD_DIR)
	cp -f $(SOURCE_DIR)/common/config.* $(CHRPATH_BUILD_DIR)/
	(cd $(CHRPATH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CHRPATH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CHRPATH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(CHRPATH_BUILD_DIR)/.configured

chrpath-unpack: $(CHRPATH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHRPATH_BUILD_DIR)/.built: $(CHRPATH_BUILD_DIR)/.configured
	rm -f $(CHRPATH_BUILD_DIR)/.built
	$(MAKE) -C $(CHRPATH_BUILD_DIR)
	touch $(CHRPATH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
chrpath: $(CHRPATH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHRPATH_BUILD_DIR)/.staged: $(CHRPATH_BUILD_DIR)/.built
	rm -f $(CHRPATH_BUILD_DIR)/.staged
	$(MAKE) -C $(CHRPATH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CHRPATH_BUILD_DIR)/.staged

chrpath-stage: $(CHRPATH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/chrpath
#
$(CHRPATH_IPK_DIR)/CONTROL/control:
	@install -d $(CHRPATH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: chrpath" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHRPATH_PRIORITY)" >>$@
	@echo "Section: $(CHRPATH_SECTION)" >>$@
	@echo "Version: $(CHRPATH_VERSION)-$(CHRPATH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHRPATH_MAINTAINER)" >>$@
	@echo "Source: $(CHRPATH_SITE)/$(CHRPATH_SOURCE)" >>$@
	@echo "Description: $(CHRPATH_DESCRIPTION)" >>$@
	@echo "Depends: $(CHRPATH_DEPENDS)" >>$@
	@echo "Suggests: $(CHRPATH_SUGGESTS)" >>$@
	@echo "Conflicts: $(CHRPATH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHRPATH_IPK_DIR)/opt/sbin or $(CHRPATH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHRPATH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CHRPATH_IPK_DIR)/opt/etc/chrpath/...
# Documentation files should be installed in $(CHRPATH_IPK_DIR)/opt/doc/chrpath/...
# Daemon startup scripts should be installed in $(CHRPATH_IPK_DIR)/opt/etc/init.d/S??chrpath
#
# You may need to patch your application to make it use these locations.
#
$(CHRPATH_IPK): $(CHRPATH_BUILD_DIR)/.built
	rm -rf $(CHRPATH_IPK_DIR) $(BUILD_DIR)/chrpath_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CHRPATH_BUILD_DIR) DESTDIR=$(CHRPATH_IPK_DIR) install
	cd $(CHRPATH_IPK_DIR)/opt/bin; ln -s $(GNU_TARGET_NAME)-chrpath chrpath
	$(STRIP_COMMAND) $(CHRPATH_IPK_DIR)/opt/bin/$(GNU_TARGET_NAME)-chrpath
	$(MAKE) $(CHRPATH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CHRPATH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
chrpath-ipk: $(CHRPATH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
chrpath-clean:
	-$(MAKE) -C $(CHRPATH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
chrpath-dirclean:
	rm -rf $(BUILD_DIR)/$(CHRPATH_DIR) $(CHRPATH_BUILD_DIR) $(CHRPATH_IPK_DIR) $(CHRPATH_IPK)
