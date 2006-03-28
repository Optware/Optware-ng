###########################################################
#
# php-fcgi - php as an fcgi module
#
###########################################################

#
# PHP_FCGI_VERSION, PHP_FCGI_SITE and PHP_FCGI_SOURCE define
# the upstream location of the source code for the package.
# PHP_FCGI_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_FCGI_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PHP_FCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_FCGI_DESCRIPTION=The php scripting language, built as an fcgi module
PHP_FCGI_SECTION=net
PHP_FCGI_PRIORITY=optional
PHP_FCGI_VERSION:=$(shell sed -n -e 's/^PHP_VERSION *=//p' make/php.mk)
PHP_FCGI_DEPENDS=php ($(PHP_FCGI_VERSION)), pcre


#
# PHP_FCGI_IPK_VERSION should be incremented when the ipk changes.
#
PHP_FCGI_IPK_VERSION=2

#
# PHP_FCGI_CONFFILES should be a list of user-editable files
#
#PHP_FCGI_CONFFILES=/opt/etc/fcgi2/conf.d/php.conf

#
# PHP_FCGI_LOCALES defines which locales get installed
#
PHP_FCGI_LOCALES=

#
# PHP_FCGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_FCGI_PATCHES=$(PHP_PATCHES)

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_FCGI_CPPFLAGS=$(PHP_CPPFLAGS)
PHP_FCGI_LDFLAGS=$(PHP_LDFLAGS)

#
# PHP_FCGI_BUILD_DIR is the directory in which the build is done.
# PHP_FCGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_FCGI_IPK_DIR is the directory in which the ipk is built.
# PHP_FCGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_FCGI_BUILD_DIR=$(BUILD_DIR)/php-fcgi
PHP_FCGI_SOURCE_DIR=$(SOURCE_DIR)/php
PHP_FCGI_IPK_DIR=$(BUILD_DIR)/php-fcgi-$(PHP_FCGI_VERSION)-ipk
PHP_FCGI_IPK=$(BUILD_DIR)/php-fcgi_$(PHP_FCGI_VERSION)-$(PHP_FCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(PHP_FCGI_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_FCGI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-fcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_FCGI_PRIORITY)" >>$@
	@echo "Section: $(PHP_FCGI_SECTION)" >>$@
	@echo "Version: $(PHP_FCGI_VERSION)-$(PHP_FCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_FCGI_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: $(PHP_FCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_FCGI_DEPENDS)" >>$@

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
php-fcgi-source: $(DL_DIR)/$(PHP_SOURCE)

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
$(PHP_FCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_SOURCE) $(PHP_FCGI_PATCHES)
	$(MAKE) libxml2-stage pcre-stage
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_FCGI_BUILD_DIR)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(PHP_FCGI_BUILD_DIR)
	cat $(PHP_FCGI_PATCHES) |patch -p0 -d $(PHP_FCGI_BUILD_DIR)
	(cd $(PHP_FCGI_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_FCGI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_FCGI_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(STAGING_LDFLAGS) $(PHP_FCGI_LDFLAGS)" \
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
		--enable-libxml \
		--with-libxml-dir=$(STAGING_PREFIX) \
		--enable-spl \
		--with-pcre-regex=$(STAGING_PREFIX) \
		--with-regex=php \
		--with-sqlite \
		--without-iconv \
		\
		--enable-memory-limit \
		--disable-cli \
		--enable-cgi \
		--enable-fastcgi \
		--enable-force-cgi-redirect \
		; \
	)
	$(PATCH_LIBTOOL) $(PHP_FCGI_BUILD_DIR)/libtool
	touch $(PHP_FCGI_BUILD_DIR)/.configured

php-fcgi-unpack: $(PHP_FCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_FCGI_BUILD_DIR)/.built: $(PHP_FCGI_BUILD_DIR)/.configured
	rm -f $(PHP_FCGI_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_FCGI_BUILD_DIR)
	touch $(PHP_FCGI_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
php-fcgi: $(PHP_FCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHP_FCGI_BUILD_DIR)/.staged: $(PHP_FCGI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PHP_FCGI_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt
	touch $@

php-fcgi-stage: $(PHP_FCGI_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_FCGI_IPK_DIR)/opt/sbin or $(PHP_FCGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_FCGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHP_FCGI_IPK_DIR)/opt/etc/php/...
# Documentation files should be installed in $(PHP_FCGI_IPK_DIR)/opt/doc/php/...
# Daemon startup scripts should be installed in $(PHP_FCGI_IPK_DIR)/opt/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_FCGI_IPK): $(PHP_FCGI_BUILD_DIR)/.built
	rm -rf $(PHP_FCGI_IPK_DIR) $(BUILD_DIR)/php-fcgi_*_$(TARGET_ARCH).ipk
	install -d $(PHP_FCGI_IPK_DIR)/opt/bin
	install -m 755 $(PHP_FCGI_BUILD_DIR)/sapi/cgi/php $(PHP_FCGI_IPK_DIR)/opt/bin/php-fcgi
	$(STRIP_COMMAND) $(PHP_FCGI_IPK_DIR)/opt/bin/php-fcgi
	$(MAKE) $(PHP_FCGI_IPK_DIR)/CONTROL/control
	echo $(PHP_FCGI_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_FCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_FCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-fcgi-ipk: $(PHP_FCGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-fcgi-clean:
	-$(MAKE) -C $(PHP_FCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-fcgi-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_FCGI_BUILD_DIR) $(PHP_FCGI_IPK_DIR) $(PHP_FCGI_IPK)
