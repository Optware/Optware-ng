###########################################################
#
# eaccelerator
#
###########################################################

#
# EACCELERATOR_VERSION, EACCELERATOR_SITE and EACCELERATOR_SOURCE define
# the upstream location of the source code for the package.
# EACCELERATOR_DIR is the directory which is created when the source
# archive is unpacked.
# EACCELERATOR_UNZIP is the command used to unzip the source.
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
EACCELERATOR_VER=0.9.5.3
EACCELERATOR_VERSION:=$(EACCELERATOR_VER)-$(shell sed -n -e 's/^PHP_VERSION *=//p' make/php.mk)
EACCELERATOR_SITE=http://bart.eaccelerator.net/source/$(EACCELERATOR_VER)
EACCELERATOR_SOURCE=eaccelerator-$(EACCELERATOR_VER).tar.bz2
EACCELERATOR_DIR=eaccelerator-$(EACCELERATOR_VER)
EACCELERATOR_UNZIP=bzcat
EACCELERATOR_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
EACCELERATOR_DESCRIPTION=Yet another php cache / accelerator
EACCELERATOR_SECTION=web
EACCELERATOR_PRIORITY=optional
EACCELERATOR_DEPENDS=php
EACCELERATOR_CONFLICTS=

#
# EACCELERATOR_IPK_VERSION should be incremented when the ipk changes.
#
EACCELERATOR_IPK_VERSION=1

#
# EACCELERATOR_CONFFILES should be a list of user-editable files
EACCELERATOR_CONFFILES=/opt/etc/php.d/eaccelerator.ini

#
# EACCELERATOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# EACCELERATOR_PATCHES=$(EACCELERATOR_SOURCE_DIR)/uclibc.patch


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EACCELERATOR_CPPFLAGS=-DMM_SEM_IPC -DMM_SHM_IPC -I$(STAGING_INCLUDE_DIR)/php -I$(STAGING_INCLUDE_DIR)/php/main -I$(STAGING_INCLUDE_DIR)/php/Zend -I$(STAGING_INCLUDE_DIR)/php/TSRM
EACCELERATOR_LDFLAGS=

#
# EACCELERATOR_BUILD_DIR is the directory in which the build is done.
# EACCELERATOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EACCELERATOR_IPK_DIR is the directory in which the ipk is built.
# EACCELERATOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EACCELERATOR_BUILD_DIR=$(BUILD_DIR)/eaccelerator
EACCELERATOR_SOURCE_DIR=$(SOURCE_DIR)/eaccelerator
EACCELERATOR_IPK_DIR=$(BUILD_DIR)/eaccelerator-$(EACCELERATOR_VERSION)-ipk
EACCELERATOR_IPK=$(BUILD_DIR)/eaccelerator_$(EACCELERATOR_VERSION)-$(EACCELERATOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: eaccelerator-source eaccelerator-unpack eaccelerator eaccelerator-stage eaccelerator-ipk eaccelerator-clean eaccelerator-dirclean eaccelerator-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EACCELERATOR_SOURCE):
	$(WGET) -P $(@D) $(EACCELERATOR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
eaccelerator-source: $(DL_DIR)/$(EACCELERATOR_SOURCE) $(EACCELERATOR_PATCHES)

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
$(EACCELERATOR_BUILD_DIR)/.configured: $(DL_DIR)/$(EACCELERATOR_SOURCE) $(EACCELERATOR_PATCHES) \
make/eaccelerator.mk make/php.mk
	$(MAKE) php-stage
	rm -rf $(BUILD_DIR)/$(EACCELERATOR_DIR) $(@D)
	$(EACCELERATOR_UNZIP) $(DL_DIR)/$(EACCELERATOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EACCELERATOR_PATCHES)" ; \
		then cat $(EACCELERATOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(EACCELERATOR_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(EACCELERATOR_DIR) $(@D)
	(cd $(@D); \
		WANT_AUTOMAKE=1.6 $(STAGING_DIR)/bin/phpize; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EACCELERATOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EACCELERATOR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-eaccelerator=shared \
		--with-php-config=$(STAGING_DIR)/opt/bin/php-config \
		--with-eaccelerator-userid='"nobody"' \
	)
	touch $@

eaccelerator-unpack: $(EACCELERATOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EACCELERATOR_BUILD_DIR)/.built: $(EACCELERATOR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) INCLUDES=""
	touch $@

#
# This is the build convenience target.
#
eaccelerator: $(EACCELERATOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EACCELERATOR_BUILD_DIR)/.staged: $(EACCELERATOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

eaccelerator-stage: $(EACCELERATOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/eaccelerator
#
$(EACCELERATOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: eaccelerator" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EACCELERATOR_PRIORITY)" >>$@
	@echo "Section: $(EACCELERATOR_SECTION)" >>$@
	@echo "Version: $(EACCELERATOR_VERSION)-$(EACCELERATOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EACCELERATOR_MAINTAINER)" >>$@
	@echo "Source: $(EACCELERATOR_SITE)/$(EACCELERATOR_SOURCE)" >>$@
	@echo "Description: $(EACCELERATOR_DESCRIPTION)" >>$@
	@echo "Depends: php (>= $(PHP_VERSION))" >>$@
	@echo "Conflicts: $(EACCELERATOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EACCELERATOR_IPK_DIR)/opt/sbin or $(EACCELERATOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EACCELERATOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EACCELERATOR_IPK_DIR)/opt/etc/eaccelerator/...
# Documentation files should be installed in $(EACCELERATOR_IPK_DIR)/opt/doc/eaccelerator/...
# Daemon startup scripts should be installed in $(EACCELERATOR_IPK_DIR)/opt/etc/init.d/S??eaccelerator
#
# You may need to patch your application to make it use these locations.
#
$(EACCELERATOR_IPK): $(EACCELERATOR_BUILD_DIR)/.built
	rm -rf $(EACCELERATOR_IPK_DIR) $(BUILD_DIR)/eaccelerator_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EACCELERATOR_BUILD_DIR) INSTALL_ROOT=$(EACCELERATOR_IPK_DIR) install
	$(STRIP_COMMAND) $(EACCELERATOR_IPK_DIR)/opt/lib/php/extensions/eaccelerator.so
	install -d $(EACCELERATOR_IPK_DIR)/opt/tmp/eaccelerator
	install -d $(EACCELERATOR_IPK_DIR)/opt/etc/php.d
	install -m 644 $(EACCELERATOR_SOURCE_DIR)/eaccelerator.ini $(EACCELERATOR_IPK_DIR)/opt/etc/php.d/eaccelerator.ini
	$(MAKE) $(EACCELERATOR_IPK_DIR)/CONTROL/control
	echo $(EACCELERATOR_CONFFILES) | sed -e 's/ /\n/g' > $(EACCELERATOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EACCELERATOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
eaccelerator-ipk: $(EACCELERATOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
eaccelerator-clean:
	-$(MAKE) -C $(EACCELERATOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
eaccelerator-dirclean:
	rm -rf $(BUILD_DIR)/$(EACCELERATOR_DIR) $(EACCELERATOR_BUILD_DIR) $(EACCELERATOR_IPK_DIR) $(EACCELERATOR_IPK)

#
# Some sanity check for the package.
#
eaccelerator-check: $(EACCELERATOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(EACCELERATOR_IPK)
