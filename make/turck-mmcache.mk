###########################################################
#
# turck-mmcache
#
###########################################################

# You must replace "turck-mmcache" and "TURCK-MMCACHE" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# TURCK_MMCACHE_VERSION, TURCK_MMCACHE_SITE and TURCK_MMCACHE_SOURCE define
# the upstream location of the source code for the package.
# TURCK_MMCACHE_DIR is the directory which is created when the source
# archive is unpacked.
# TURCK_MMCACHE_UNZIP is the command used to unzip the source.
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
TURCK_MMCACHE_SITE=http://dl.sourceforge.net/sourceforge/turck-mmcache
TURCK_MMCACHE_VERSION=2.4.6
TURCK_MMCACHE_SOURCE=turck-mmcache-$(TURCK_MMCACHE_VERSION).tar.bz2
TURCK_MMCACHE_DIR=turck-mmcache-$(TURCK_MMCACHE_VERSION)
TURCK_MMCACHE_UNZIP=bzcat
TURCK_MMCACHE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
TURCK_MMCACHE_DESCRIPTION=Shared memory caching support for php
TURCK_MMCACHE_SECTION=web
TURCK_MMCACHE_PRIORITY=optional
TURCK_MMCACHE_DEPENDS=php
TURCK_MMCACHE_CONFLICTS=

#
# TURCK_MMCACHE_IPK_VERSION should be incremented when the ipk changes.
#
TURCK_MMCACHE_IPK_VERSION=1

#
# TURCK_MMCACHE_CONFFILES should be a list of user-editable files
TURCK_MMCACHE_CONFFILES=/opt/etc/php.d/turck-mmcache.ini

#
# TURCK_MMCACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TURCK_MMCACHE_PATCHES=$(TURCK_MMCACHE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TURCK_MMCACHE_CPPFLAGS=-DMM_SEM_IPC -DMM_SHM_IPC -I$(STAGING_INCLUDE_DIR)/php -I$(STAGING_INCLUDE_DIR)/php/main -I$(STAGING_INCLUDE_DIR)/php/Zend -I$(STAGING_INCLUDE_DIR)/php/TSRM
TURCK_MMCACHE_LDFLAGS=

#
# TURCK_MMCACHE_BUILD_DIR is the directory in which the build is done.
# TURCK_MMCACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TURCK_MMCACHE_IPK_DIR is the directory in which the ipk is built.
# TURCK_MMCACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TURCK_MMCACHE_BUILD_DIR=$(BUILD_DIR)/turck-mmcache
TURCK_MMCACHE_SOURCE_DIR=$(SOURCE_DIR)/turck-mmcache
TURCK_MMCACHE_IPK_DIR=$(BUILD_DIR)/turck-mmcache-$(TURCK_MMCACHE_VERSION)-ipk
TURCK_MMCACHE_IPK=$(BUILD_DIR)/turck-mmcache_$(TURCK_MMCACHE_VERSION)-$(TURCK_MMCACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TURCK_MMCACHE_SOURCE):
	$(WGET) -P $(DL_DIR) $(TURCK_MMCACHE_SITE)/$(TURCK_MMCACHE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
turck-mmcache-source: $(DL_DIR)/$(TURCK_MMCACHE_SOURCE) $(TURCK_MMCACHE_PATCHES)

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
$(TURCK_MMCACHE_BUILD_DIR)/.configured: $(DL_DIR)/$(TURCK_MMCACHE_SOURCE) $(TURCK_MMCACHE_PATCHES)
	$(MAKE) php-stage
	rm -rf $(BUILD_DIR)/$(TURCK_MMCACHE_DIR) $(TURCK_MMCACHE_BUILD_DIR)
	$(TURCK_MMCACHE_UNZIP) $(DL_DIR)/$(TURCK_MMCACHE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(TURCK_MMCACHE_PATCHES) | patch -d $(BUILD_DIR)/$(TURCK_MMCACHE_DIR) -p1
	mv $(BUILD_DIR)/$(TURCK_MMCACHE_DIR) $(TURCK_MMCACHE_BUILD_DIR)
	(cd $(TURCK_MMCACHE_BUILD_DIR); \
		$(STAGING_DIR)/bin/phpize; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TURCK_MMCACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TURCK_MMCACHE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-php-config=$(STAGING_DIR)/opt/bin/php-config \
	)
	touch $(TURCK_MMCACHE_BUILD_DIR)/.configured

turck-mmcache-unpack: $(TURCK_MMCACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TURCK_MMCACHE_BUILD_DIR)/.built: $(TURCK_MMCACHE_BUILD_DIR)/.configured
	rm -f $(TURCK_MMCACHE_BUILD_DIR)/.built
	$(MAKE) -C $(TURCK_MMCACHE_BUILD_DIR)
	touch $(TURCK_MMCACHE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
turck-mmcache: $(TURCK_MMCACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TURCK_MMCACHE_BUILD_DIR)/.staged: $(TURCK_MMCACHE_BUILD_DIR)/.built
	rm -f $(TURCK_MMCACHE_BUILD_DIR)/.staged
	$(MAKE) -C $(TURCK_MMCACHE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TURCK_MMCACHE_BUILD_DIR)/.staged

turck-mmcache-stage: $(TURCK_MMCACHE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/turck-mmcache
#
$(TURCK_MMCACHE_IPK_DIR)/CONTROL/control:
	@install -d $(TURCK_MMCACHE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: turck-mmcache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TURCK_MMCACHE_PRIORITY)" >>$@
	@echo "Section: $(TURCK_MMCACHE_SECTION)" >>$@
	@echo "Version: $(TURCK_MMCACHE_VERSION)-$(TURCK_MMCACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TURCK_MMCACHE_MAINTAINER)" >>$@
	@echo "Source: $(TURCK_MMCACHE_SITE)/$(TURCK_MMCACHE_SOURCE)" >>$@
	@echo "Description: $(TURCK_MMCACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(TURCK_MMCACHE_DEPENDS)" >>$@
	@echo "Conflicts: $(TURCK_MMCACHE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TURCK_MMCACHE_IPK_DIR)/opt/sbin or $(TURCK_MMCACHE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TURCK_MMCACHE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TURCK_MMCACHE_IPK_DIR)/opt/etc/turck-mmcache/...
# Documentation files should be installed in $(TURCK_MMCACHE_IPK_DIR)/opt/doc/turck-mmcache/...
# Daemon startup scripts should be installed in $(TURCK_MMCACHE_IPK_DIR)/opt/etc/init.d/S??turck-mmcache
#
# You may need to patch your application to make it use these locations.
#
$(TURCK_MMCACHE_IPK): $(TURCK_MMCACHE_BUILD_DIR)/.built
	rm -rf $(TURCK_MMCACHE_IPK_DIR) $(BUILD_DIR)/turck-mmcache_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TURCK_MMCACHE_BUILD_DIR) INSTALL_ROOT=$(TURCK_MMCACHE_IPK_DIR) install
	install -d $(TURCK_MMCACHE_IPK_DIR)/opt/tmp/mmcache
	install -d $(TURCK_MMCACHE_IPK_DIR)/opt/etc/php.d
	install -m 644 $(TURCK_MMCACHE_SOURCE_DIR)/turck-mmcache.ini $(TURCK_MMCACHE_IPK_DIR)/opt/etc\/php.d/turck-mmcache.ini
	$(MAKE) $(TURCK_MMCACHE_IPK_DIR)/CONTROL/control
	echo $(TURCK_MMCACHE_CONFFILES) | sed -e 's/ /\n/g' > $(TURCK_MMCACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TURCK_MMCACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
turck-mmcache-ipk: $(TURCK_MMCACHE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
turck-mmcache-clean:
	-$(MAKE) -C $(TURCK_MMCACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
turck-mmcache-dirclean:
	rm -rf $(BUILD_DIR)/$(TURCK_MMCACHE_DIR) $(TURCK_MMCACHE_BUILD_DIR) $(TURCK_MMCACHE_IPK_DIR) $(TURCK_MMCACHE_IPK)
