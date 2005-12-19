###########################################################
#
# phpmyadmin
#
###########################################################

#
# PHPMYADMIN_VERSION, PHPMYADMIN_SITE and PHPMYADMIN_SOURCE define
# the upstream location of the source code for the package.
# PHPMYADMIN_DIR is the directory which is created when the source
# archive is unpacked.
# PHPMYADMIN_UNZIP is the command used to unzip the source.
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
PHPMYADMIN_SITE=http://dl.sourceforge.net/sourceforge/phpmyadmin
PHPMYADMIN_VERSION=2.6.2
PHPMYADMIN_SOURCE=phpMyAdmin-$(PHPMYADMIN_VERSION).tar.bz2
PHPMYADMIN_DIR=phpMyAdmin-$(PHPMYADMIN_VERSION)
PHPMYADMIN_UNZIP=bzcat
PHPMYADMIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHPMYADMIN_DESCRIPTION=Web-based administration interface for mysql
PHPMYADMIN_SECTION=web
PHPMYADMIN_PRIORITY=optional
PHPMYADMIN_DEPENDS=php-mysql, php-mbstring, mysql
PHPMYADMIN_SUGGESTS=php-apache, eaccelerator
PHPMYADMIN_CONFLICTS=

PHPMYADMIN_INSTALL_DIR=/opt/share/www/phpmyadmin

#
# PHPMYADMIN_IPK_VERSION should be incremented when the ipk changes.
#
PHPMYADMIN_IPK_VERSION=2

#
# PHPMYADMIN_CONFFILES should be a list of user-editable files
PHPMYADMIN_CONFFILES=$(PHPMYADMIN_INSTALL_DIR)/config.inc.php

#
# PHPMYADMIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHPMYADMIN_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHPMYADMIN_CPPFLAGS=
PHPMYADMIN_LDFLAGS=

#
# PHPMYADMIN_BUILD_DIR is the directory in which the build is done.
# PHPMYADMIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHPMYADMIN_IPK_DIR is the directory in which the ipk is built.
# PHPMYADMIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHPMYADMIN_BUILD_DIR=$(BUILD_DIR)/phpmyadmin
PHPMYADMIN_SOURCE_DIR=$(SOURCE_DIR)/phpmyadmin
PHPMYADMIN_IPK_DIR=$(BUILD_DIR)/phpmyadmin-$(PHPMYADMIN_VERSION)-ipk
PHPMYADMIN_IPK=$(BUILD_DIR)/phpmyadmin_$(PHPMYADMIN_VERSION)-$(PHPMYADMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHPMYADMIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PHPMYADMIN_SITE)/$(PHPMYADMIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
phpmyadmin-source: $(DL_DIR)/$(PHPMYADMIN_SOURCE) $(PHPMYADMIN_PATCHES)

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
$(PHPMYADMIN_BUILD_DIR)/.configured: $(DL_DIR)/$(PHPMYADMIN_SOURCE) $(PHPMYADMIN_PATCHES)
	rm -rf $(BUILD_DIR)/$(PHPMYADMIN_DIR) $(PHPMYADMIN_BUILD_DIR)
	$(PHPMYADMIN_UNZIP) $(DL_DIR)/$(PHPMYADMIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PHPMYADMIN_PATCHES) | patch -d $(BUILD_DIR)/$(PHPMYADMIN_DIR) -p1
	mv $(BUILD_DIR)/$(PHPMYADMIN_DIR) $(PHPMYADMIN_BUILD_DIR)
	touch $(PHPMYADMIN_BUILD_DIR)/.configured

phpmyadmin-unpack: $(PHPMYADMIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHPMYADMIN_BUILD_DIR)/.built: $(PHPMYADMIN_BUILD_DIR)/.configured
	touch $(PHPMYADMIN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
phpmyadmin: $(PHPMYADMIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHPMYADMIN_BUILD_DIR)/.staged: $(PHPMYADMIN_BUILD_DIR)/.built
	touch $(PHPMYADMIN_BUILD_DIR)/.staged

phpmyadmin-stage: $(PHPMYADMIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/phpmyadmin
#
$(PHPMYADMIN_IPK_DIR)/CONTROL/control:
	@install -d $(PHPMYADMIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: phpmyadmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHPMYADMIN_PRIORITY)" >>$@
	@echo "Section: $(PHPMYADMIN_SECTION)" >>$@
	@echo "Version: $(PHPMYADMIN_VERSION)-$(PHPMYADMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHPMYADMIN_MAINTAINER)" >>$@
	@echo "Source: $(PHPMYADMIN_SITE)/$(PHPMYADMIN_SOURCE)" >>$@
	@echo "Description: $(PHPMYADMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PHPMYADMIN_DEPENDS)" >>$@
	@echo "Suggests: $(PHPMYADMIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHPMYADMIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHPMYADMIN_IPK_DIR)/opt/sbin or $(PHPMYADMIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHPMYADMIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHPMYADMIN_IPK_DIR)/opt/etc/phpmyadmin/...
# Documentation files should be installed in $(PHPMYADMIN_IPK_DIR)/opt/doc/phpmyadmin/...
# Daemon startup scripts should be installed in $(PHPMYADMIN_IPK_DIR)/opt/etc/init.d/S??phpmyadmin
#
# You may need to patch your application to make it use these locations.
#
$(PHPMYADMIN_IPK): $(PHPMYADMIN_BUILD_DIR)/.built
	rm -rf $(PHPMYADMIN_IPK_DIR) $(BUILD_DIR)/phpmyadmin_*_$(TARGET_ARCH).ipk
	install -d $(PHPMYADMIN_IPK_DIR)$(PHPMYADMIN_INSTALL_DIR)
	cp -a $(PHPMYADMIN_BUILD_DIR)/* $(PHPMYADMIN_IPK_DIR)$(PHPMYADMIN_INSTALL_DIR)
	$(MAKE) $(PHPMYADMIN_IPK_DIR)/CONTROL/control
	#install -m 755 $(PHPMYADMIN_SOURCE_DIR)/postinst $(PHPMYADMIN_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(PHPMYADMIN_SOURCE_DIR)/prerm $(PHPMYADMIN_IPK_DIR)/CONTROL/prerm
	echo $(PHPMYADMIN_CONFFILES) | sed -e 's/ /\n/g' > $(PHPMYADMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHPMYADMIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
phpmyadmin-ipk: $(PHPMYADMIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
phpmyadmin-clean:
	-$(MAKE) -C $(PHPMYADMIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
phpmyadmin-dirclean:
	rm -rf $(BUILD_DIR)/$(PHPMYADMIN_DIR) $(PHPMYADMIN_BUILD_DIR) $(PHPMYADMIN_IPK_DIR) $(PHPMYADMIN_IPK)
