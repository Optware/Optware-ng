###########################################################
#
# php-apache - php as an apache module
#
###########################################################

#
# PHP_APACHE_VERSION, PHP_APACHE_SITE and PHP_APACHE_SOURCE define
# the upstream location of the source code for the package.
# PHP_APACHE_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_APACHE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PHP_APACHE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_APACHE_DESCRIPTION=The php scripting language, built as an apache module
PHP_APACHE_SECTION=net
PHP_APACHE_PRIORITY=optional
PHP_APACHE_DEPENDS=apache (>= 2.0.53-9), php (>= 5.0.3-8), libxml2

PHP_APACHE_VERSION:=$(shell sed -n -e 's/^PHP_VERSION *=//p' make/php.mk)

#
# PHP_APACHE_IPK_VERSION should be incremented when the ipk changes.
#
PHP_APACHE_IPK_VERSION=2

#
# PHP_APACHE_CONFFILES should be a list of user-editable files
#
PHP_APACHE_CONFFILES=/opt/etc/apache2/conf.d/php.conf

#
# PHP_APACHE_LOCALES defines which locales get installed
#
PHP_APACHE_LOCALES=

#
# PHP_APACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_APACHE_PATCHES=$(PHP_PATCHES)

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_APACHE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/apache2 -I$(STAGING_INCLUDE_DIR)/libxml2
PHP_APACHE_LDFLAGS=-ldl -lpthread

#
# PHP_APACHE_BUILD_DIR is the directory in which the build is done.
# PHP_APACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_APACHE_IPK_DIR is the directory in which the ipk is built.
# PHP_APACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_APACHE_BUILD_DIR=$(BUILD_DIR)/php-apache
PHP_APACHE_SOURCE_DIR=$(SOURCE_DIR)/php
PHP_APACHE_IPK_DIR=$(BUILD_DIR)/php-apache-$(PHP_APACHE_VERSION)-ipk
PHP_APACHE_IPK=$(BUILD_DIR)/php-apache_$(PHP_APACHE_VERSION)-$(PHP_APACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: php-apache-source php-apache-unpack php-apache php-apache-stage php-apache-ipk php-apache-clean php-apache-dirclean php-apache-check

#
# Automatically create a ipkg control file
#
$(PHP_APACHE_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_APACHE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-apache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_APACHE_PRIORITY)" >>$@
	@echo "Section: $(PHP_APACHE_SECTION)" >>$@
	@echo "Version: $(PHP_APACHE_VERSION)-$(PHP_APACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_APACHE_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: $(PHP_APACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_APACHE_DEPENDS)" >>$@

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
php-apache-source: $(DL_DIR)/$(PHP_SOURCE)

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
$(PHP_APACHE_BUILD_DIR)/.configured: \
		$(PHP_APACHE_PATCHES)
	$(MAKE) $(DL_DIR)/$(PHP_SOURCE)
	$(MAKE) apache-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_APACHE_BUILD_DIR)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(PHP_APACHE_BUILD_DIR)
	cat $(PHP_APACHE_PATCHES) |patch -p0 -d $(PHP_APACHE_BUILD_DIR)
	(cd $(PHP_APACHE_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_APACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_APACHE_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(STAGING_LDFLAGS) $(PHP_APACHE_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		PHP_LIBXML_DIR=$(STAGING_PREFIX) \
		EXTENSION_DIR=/opt/lib/php/extensions \
		ac_cv_func_memcmp_working=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-config-file-scan-dir=/opt/etc/php.d \
		--with-layout=GNU \
		--disable-static \
		$(PHP_CONFIGURE_THREAD_ARGS) \
		--disable-dom \
		--disable-xml \
		--enable-libxml \
		--with-apxs2=$(STAGING_DIR)/opt/sbin/apxs \
		--without-pear \
		--without-iconv \
	)
	$(PATCH_LIBTOOL) $(PHP_BUILD_DIR)/libtool
	touch $(PHP_APACHE_BUILD_DIR)/.configured

php-apache-unpack: $(PHP_APACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_APACHE_BUILD_DIR)/.built: $(PHP_APACHE_BUILD_DIR)/.configured
	rm -f $(PHP_APACHE_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_APACHE_BUILD_DIR)
	touch $(PHP_APACHE_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
php-apache: $(PHP_APACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHP_APACHE_BUILD_DIR)/.staged: $(PHP_APACHE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PHP_APACHE_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	touch $@

php-apache-stage: $(PHP_APACHE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_APACHE_IPK_DIR)/opt/sbin or $(PHP_APACHE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_APACHE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHP_APACHE_IPK_DIR)/opt/etc/php/...
# Documentation files should be installed in $(PHP_APACHE_IPK_DIR)/opt/doc/php/...
# Daemon startup scripts should be installed in $(PHP_APACHE_IPK_DIR)/opt/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_APACHE_IPK): $(PHP_APACHE_BUILD_DIR)/.built
	rm -rf $(PHP_APACHE_IPK_DIR) $(BUILD_DIR)/php-apache_*_$(TARGET_ARCH).ipk
	install -d $(PHP_APACHE_IPK_DIR)/opt/etc/apache2/conf.d
	install -m 644 $(PHP_APACHE_SOURCE_DIR)/php.conf $(PHP_APACHE_IPK_DIR)/opt/etc/apache2/conf.d/php.conf
	install -d $(PHP_APACHE_IPK_DIR)/opt/libexec
	install -m 755 $(PHP_APACHE_BUILD_DIR)/libs/libphp5.so $(PHP_APACHE_IPK_DIR)/opt/libexec/libphp5.so
	$(STRIP_COMMAND) $(PHP_APACHE_IPK_DIR)/opt/libexec/libphp5.so
	$(MAKE) $(PHP_APACHE_IPK_DIR)/CONTROL/control
	echo $(PHP_APACHE_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_APACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_APACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-apache-ipk: $(PHP_APACHE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-apache-clean:
	-$(MAKE) -C $(PHP_APACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-apache-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_APACHE_BUILD_DIR) $(PHP_APACHE_IPK_DIR) $(PHP_APACHE_IPK)
#
#
# Some sanity check for the package.
#
php-apache-check: $(PHP_APACHE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PHP_APACHE_IPK)
