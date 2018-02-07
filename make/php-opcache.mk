###########################################################
#
# php-opcache - php opcache module
#
###########################################################

#
# PHP_OPCACHE_VERSION, PHP_OPCACHE_SITE and PHP_OPCACHE_SOURCE define
# the upstream location of the source code for the package.
# PHP_OPCACHE_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_OPCACHE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PHP_OPCACHE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_OPCACHE_DESCRIPTION=opcache zend extension for php
PHP_OPCACHE_SECTION=net
PHP_OPCACHE_PRIORITY=optional
PHP_OPCACHE_DEPENDS=php

include make/php.mk
PHP_OPCACHE_VERSION=$(PHP_VERSION)

#
# PHP_OPCACHE_IPK_VERSION should be incremented when the ipk changes.
#
PHP_OPCACHE_IPK_VERSION=1

#
# PHP_OPCACHE_CONFFILES should be a list of user-editable files
#
PHP_OPCACHE_CONFFILES=$(TARGET_PREFIX)/etc/php.d/opcache.ini

#
# PHP_OPCACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_OPCACHE_PATCHES=$(PHP_OPCACHE_SOURCE_DIR)/opcache.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_OPCACHE_CPPFLAGS=
PHP_OPCACHE_LDFLAGS=

#
# PHP_OPCACHE_BUILD_DIR is the directory in which the build is done.
# PHP_OPCACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_OPCACHE_IPK_DIR is the directory in which the ipk is built.
# PHP_OPCACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_OPCACHE_BUILD_DIR=$(BUILD_DIR)/php-opcache
PHP_OPCACHE_SOURCE_DIR=$(SOURCE_DIR)/php
PHP_OPCACHE_IPK_DIR=$(BUILD_DIR)/php-opcache-$(PHP_OPCACHE_VERSION)-ipk
PHP_OPCACHE_IPK=$(BUILD_DIR)/php-opcache_$(PHP_OPCACHE_VERSION)-$(PHP_OPCACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: php-opcache-source php-opcache-unpack php-opcache php-opcache-$ php-opcache-ipk php-opcache-clean php-opcache-dirclean php-opcache-check

#
# Automatically create a ipkg control file
#
$(PHP_OPCACHE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-opcache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_OPCACHE_PRIORITY)" >>$@
	@echo "Section: $(PHP_OPCACHE_SECTION)" >>$@
	@echo "Version: $(PHP_OPCACHE_VERSION)-$(PHP_OPCACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_OPCACHE_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: $(PHP_OPCACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_OPCACHE_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(PHP_SOURCE):
#	$(WGET) -P $(DL_DIR) $(PHP_SITE)/$(PHP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-opcache-source: $(DL_DIR)/$(PHP_SOURCE)

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
# If the compilation of the package requires other packages to be $d
# first, then do that first (e.g. "$(MAKE) <bar>-$ <baz>-$").
#
$(PHP_OPCACHE_BUILD_DIR)/.configured: $(PHP_OPCACHE_PATCHES) make/php-opcache.mk
	$(MAKE) php-stage
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(@D)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf - $(PHP_DIR)/ext/opcache
	mv $(BUILD_DIR)/$(PHP_DIR) $(@D)
	if test -n "$(PHP_OPCACHE_PATCHES)"; \
	    then cat $(PHP_OPCACHE_PATCHES) | $(PATCH) -p1 -bd $(@D); \
	fi
	cd $(@D)/ext/opcache; $(STAGING_DIR)/bin/phpize
	(cd $(@D)/ext/opcache; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-static \
		--enable-opcache=shared \
		--with-php-config=$(STAGING_DIR)/bin/php-config \
	)
	$(PATCH_LIBTOOL) $(@D)/ext/opcache/libtool
	touch $@

php-opcache-unpack: $(PHP_OPCACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_OPCACHE_BUILD_DIR)/.built: $(PHP_OPCACHE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/ext/opcache
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
php-opcache: $(PHP_OPCACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHP_OPCACHE_BUILD_DIR)/.staged: $(PHP_OPCACHE_BUILD_DIR)/.built
	rm -f $@
	touch $@

php-opcache-stage: $(PHP_OPCACHE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/etc/php/...
# Documentation files should be installed in $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/doc/php/...
# Daemon startup scripts should be installed in $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_OPCACHE_IPK): $(PHP_OPCACHE_BUILD_DIR)/.built
	rm -rf $(PHP_OPCACHE_IPK_DIR) $(BUILD_DIR)/php-opcache_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -m 755 $(PHP_OPCACHE_BUILD_DIR)/ext/opcache/modules/opcache.so \
				$(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(STRIP_COMMAND) $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/opcache.so
	$(INSTALL) -d $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	echo zend_extension=opcache.so > $(PHP_OPCACHE_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/opcache.ini
	$(MAKE) $(PHP_OPCACHE_IPK_DIR)/CONTROL/control
	echo $(PHP_OPCACHE_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_OPCACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_OPCACHE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_OPCACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-opcache-ipk: $(PHP_OPCACHE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-opcache-clean:
	-$(MAKE) -C $(PHP_OPCACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-opcache-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_OPCACHE_BUILD_DIR) $(PHP_OPCACHE_IPK_DIR) $(PHP_OPCACHE_IPK)
#
#
# Some sanity check for the package.
#
php-opcache-check: $(PHP_OPCACHE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
