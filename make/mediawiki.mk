###########################################################
#
# mediawiki
#
###########################################################

#
# MEDIAWIKI_VERSION, MEDIAWIKI_SITE and MEDIAWIKI_SOURCE define
# the upstream location of the source code for the package.
# MEDIAWIKI_DIR is the directory which is created when the source
# archive is unpacked.
# MEDIAWIKI_UNZIP is the command used to unzip the source.
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
MEDIAWIKI_SITE=http://dl.sf.net/sourceforge/wikipedia
MEDIAWIKI_VERSION=1.4.0
MEDIAWIKI_SOURCE=mediawiki-$(MEDIAWIKI_VERSION).tar.gz
MEDIAWIKI_DIR=mediawiki-$(MEDIAWIKI_VERSION)
MEDIAWIKI_UNZIP=zcat
MEDIAWIKI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEDIAWIKI_DESCRIPTION=A fast, full-featured, wiki based on php.
MEDIAWIKI_SECTION=web
MEDIAWIKI_PRIORITY=optional
MEDIAWIKI_DEPENDS=php-mysql, mysql
MEDIAWIKI_SUGGESTS=php-apache, eaccelerator
MEDIAWIKI_CONFLICTS=

MEDIAWIKI_INSTALL_DIR=/opt/share/www/mediawiki

#
# MEDIAWIKI_IPK_VERSION should be incremented when the ipk changes.
#
MEDIAWIKI_IPK_VERSION=1

#
# MEDIAWIKI_CONFFILES should be a list of user-editable files
#MEDIAWIKI_CONFFILES=$(MEDIAWIKI_INSTALL_DIR)/LocalSettings.php

#
# MEDIAWIKI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MEDIAWIKI_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEDIAWIKI_CPPFLAGS=
MEDIAWIKI_LDFLAGS=

#
# MEDIAWIKI_BUILD_DIR is the directory in which the build is done.
# MEDIAWIKI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEDIAWIKI_IPK_DIR is the directory in which the ipk is built.
# MEDIAWIKI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEDIAWIKI_BUILD_DIR=$(BUILD_DIR)/mediawiki
MEDIAWIKI_SOURCE_DIR=$(SOURCE_DIR)/mediawiki
MEDIAWIKI_IPK_DIR=$(BUILD_DIR)/mediawiki-$(MEDIAWIKI_VERSION)-ipk
MEDIAWIKI_IPK=$(BUILD_DIR)/mediawiki_$(MEDIAWIKI_VERSION)-$(MEDIAWIKI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MEDIAWIKI_SOURCE):
	$(WGET) -P $(DL_DIR) $(MEDIAWIKI_SITE)/$(MEDIAWIKI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mediawiki-source: $(DL_DIR)/$(MEDIAWIKI_SOURCE) $(MEDIAWIKI_PATCHES)

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
$(MEDIAWIKI_BUILD_DIR)/.configured: $(DL_DIR)/$(MEDIAWIKI_SOURCE) $(MEDIAWIKI_PATCHES)
	rm -rf $(BUILD_DIR)/$(MEDIAWIKI_DIR) $(MEDIAWIKI_BUILD_DIR)
	$(MEDIAWIKI_UNZIP) $(DL_DIR)/$(MEDIAWIKI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(MEDIAWIKI_PATCHES) | patch -d $(BUILD_DIR)/$(MEDIAWIKI_DIR) -p1
	mv $(BUILD_DIR)/$(MEDIAWIKI_DIR) $(MEDIAWIKI_BUILD_DIR)
	touch $(MEDIAWIKI_BUILD_DIR)/.configured

mediawiki-unpack: $(MEDIAWIKI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEDIAWIKI_BUILD_DIR)/.built: $(MEDIAWIKI_BUILD_DIR)/.configured
	touch $(MEDIAWIKI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mediawiki: $(MEDIAWIKI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEDIAWIKI_BUILD_DIR)/.staged: $(MEDIAWIKI_BUILD_DIR)/.built
	touch $(MEDIAWIKI_BUILD_DIR)/.staged

mediawiki-stage: $(MEDIAWIKI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mediawiki
#
$(MEDIAWIKI_IPK_DIR)/CONTROL/control:
	@install -d $(MEDIAWIKI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mediawiki" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEDIAWIKI_PRIORITY)" >>$@
	@echo "Section: $(MEDIAWIKI_SECTION)" >>$@
	@echo "Version: $(MEDIAWIKI_VERSION)-$(MEDIAWIKI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEDIAWIKI_MAINTAINER)" >>$@
	@echo "Source: $(MEDIAWIKI_SITE)/$(MEDIAWIKI_SOURCE)" >>$@
	@echo "Description: $(MEDIAWIKI_DESCRIPTION)" >>$@
	@echo "Depends: $(MEDIAWIKI_DEPENDS)" >>$@
	@echo "Suggests: $(MEDIAWIKI_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEDIAWIKI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEDIAWIKI_IPK_DIR)/opt/sbin or $(MEDIAWIKI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEDIAWIKI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MEDIAWIKI_IPK_DIR)/opt/etc/mediawiki/...
# Documentation files should be installed in $(MEDIAWIKI_IPK_DIR)/opt/doc/mediawiki/...
# Daemon startup scripts should be installed in $(MEDIAWIKI_IPK_DIR)/opt/etc/init.d/S??mediawiki
#
# You may need to patch your application to make it use these locations.
#
$(MEDIAWIKI_IPK): $(MEDIAWIKI_BUILD_DIR)/.built
	rm -rf $(MEDIAWIKI_IPK_DIR) $(BUILD_DIR)/mediawiki_*_$(TARGET_ARCH).ipk
	install -d $(MEDIAWIKI_IPK_DIR)$(MEDIAWIKI_INSTALL_DIR)
	cp -a $(MEDIAWIKI_BUILD_DIR)/* $(MEDIAWIKI_IPK_DIR)$(MEDIAWIKI_INSTALL_DIR)/
	chmod a+rwx $(MEDIAWIKI_IPK_DIR)$(MEDIAWIKI_INSTALL_DIR)/config
	$(MAKE) $(MEDIAWIKI_IPK_DIR)/CONTROL/control
	install -m 755 $(MEDIAWIKI_SOURCE_DIR)/postinst $(MEDIAWIKI_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(MEDIAWIKI_SOURCE_DIR)/prerm $(MEDIAWIKI_IPK_DIR)/CONTROL/prerm
	#echo $(MEDIAWIKI_CONFFILES) | sed -e 's/ /\n/g' > $(MEDIAWIKI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEDIAWIKI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mediawiki-ipk: $(MEDIAWIKI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mediawiki-clean:
	-$(MAKE) -C $(MEDIAWIKI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mediawiki-dirclean:
	rm -rf $(BUILD_DIR)/$(MEDIAWIKI_DIR) $(MEDIAWIKI_BUILD_DIR) $(MEDIAWIKI_IPK_DIR) $(MEDIAWIKI_IPK)
