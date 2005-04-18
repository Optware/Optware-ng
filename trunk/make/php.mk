###########################################################
#
# php
#
###########################################################

#
# PHP_VERSION, PHP_SITE and PHP_SOURCE define
# the upstream location of the source code for the package.
# PHP_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
PHP_SITE=http://static.php.net/www.php.net/distributions/
PHP_VERSION=5.0.3
PHP_SOURCE=php-$(PHP_VERSION).tar.bz2
PHP_DIR=php-$(PHP_VERSION)
PHP_UNZIP=bzcat
PHP_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_DESCRIPTION=The php scripting language
PHP_SECTION=net
PHP_PRIORITY=optional
PHP_DEPENDS=bzip2, openssl, zlib, libxml2, libxslt, gdbm, libdb

#
# PHP_IPK_VERSION should be incremented when the ipk changes.
#
PHP_IPK_VERSION=6

#
# PHP_CONFFILES should be a list of user-editable files
#
PHP_CONFFILES=/opt/etc/php.ini

#
# PHP_LOCALES defines which locales get installed
#
PHP_LOCALES=

#
# PHP_CONFFILES should be a list of user-editable files
#PHP_CONFFILES=/opt/etc/php.conf /opt/etc/init.d/SXXphp

#
# PHP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_PATCHES=$(PHP_SOURCE_DIR)/aclocal.m4.patch $(PHP_SOURCE_DIR)/zend-m4.patch $(PHP_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2 -I$(STAGING_INCLUDE_DIR)/libxslt -I$(STAGING_INCLUDE_DIR)/libexslt 
PHP_LDFLAGS=-ldl

#
# PHP_BUILD_DIR is the directory in which the build is done.
# PHP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_IPK_DIR is the directory in which the ipk is built.
# PHP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_BUILD_DIR=$(BUILD_DIR)/php
PHP_SOURCE_DIR=$(SOURCE_DIR)/php
PHP_IPK_DIR=$(BUILD_DIR)/php-$(PHP_VERSION)-ipk
PHP_IPK=$(BUILD_DIR)/php_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_DEV_IPK_DIR=$(BUILD_DIR)/php-dev-$(PHP_VERSION)-ipk
PHP_DEV_IPK=$(BUILD_DIR)/php-dev_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_GD_IPK_DIR=$(BUILD_DIR)/php-gd-$(PHP_VERSION)-ipk
PHP_GD_IPK=$(BUILD_DIR)/php-gd_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_LDAP_IPK_DIR=$(BUILD_DIR)/php-ldap-$(PHP_VERSION)-ipk
PHP_LDAP_IPK=$(BUILD_DIR)/php-ldap_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MYSQL_IPK_DIR=$(BUILD_DIR)/php-mysql-$(PHP_VERSION)-ipk
PHP_MYSQL_IPK=$(BUILD_DIR)/php-mysql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk


#
# Automatically create a ipkg control file
#
$(PHP_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: $(PHP_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_DEPENDS)" >>$@

$(PHP_DEV_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_DEV_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: php native development environment" >>$@
	@echo "Depends: php" >>$@

$(PHP_GD_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_GD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-gd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: libgd extension for php" >>$@
	@echo "Depends: php, libgd" >>$@

$(PHP_LDAP_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_LDAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-ldap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: ldap extension for php" >>$@
	@echo "Depends: php, openldap-libs" >>$@

$(PHP_MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_MYSQL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mysql extension for php" >>$@
	@echo "Depends: php, mysql" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PHP_SITE)/$(PHP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-source: $(DL_DIR)/$(PHP_SOURCE) $(PHP_PATCHES)

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
$(PHP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_SOURCE) \
		$(PHP_PATCHES)
	$(MAKE) bzip2-stage libgd-stage libxml2-stage libxslt-stage gdbm-stage openssl-stage openldap-stage libdb-stage
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR)
	cat $(PHP_PATCHES) |patch -p0 -d $(PHP_BUILD_DIR)
	(cd $(PHP_BUILD_DIR); \
		autoconf; \
		sed -i \
		    -e 's|sys_lib_search_path_spec="/lib /usr/lib /usr/local/lib"|sys_lib_search_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
		    -e 's|sys_lib_dlsearch_path_spec="/lib /usr/lib"|sys_lib_dlsearch_path_spec="$(TARGET_LIBDIR) $(STAGING_LIB_DIR)"|' \
			configure ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS) $(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		XML2_CONFIG=$(STAGING_DIR)/bin/xml2-config \
		EXTENSION_DIR=/opt/lib/php/extensions \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-config-file-scan-dir=/opt/etc/php.d \
		--with-layout=GNU \
		--disable-static \
		--enable-bcmath=shared \
		--enable-calendar=shared \
		--enable-dba=shared \
		--with-inifile \
		--with-flatfile \
		--enable-dbx=shared \
		--enable-dom=shared \
		--enable-exif=shared \
		--enable-ftp=shared \
		--enable-shmop=shared \
		--enable-sockets=shared \
		--enable-sysvmsg=shared \
		--enable-sysvshm=shared \
		--enable-sysvsem=shared \
		--with-bz2=shared,$(STAGING_DIR)/opt \
		--with-db4=$(STAGING_DIR)/opt \
		--with-dom=shared,$(STAGING_DIR)/opt \
		--with-gdbm=$(STAGING_DIR)/opt \
		--with-gd=shared,$(STAGING_DIR)/opt \
		--with-ldap=shared,$(STAGING_DIR)/opt \
		--with-ldap-sasl=$(STAGING_DIR)/opt \
		--with-mysql=shared,$(STAGING_DIR)/opt \
		--with-mysql-sock=/tmp/mysql.sock \
		--with-openssl=shared,$(STAGING_DIR)/opt \
		--with-xsl=shared,$(STAGING_DIR)/opt \
		--with-zlib=shared,$(STAGING_DIR)/opt \
		--with-libxml-dir=$(STAGING_DIR)/opt \
		--with-jpeg-dir=$(STAGING_DIR)/opt \
		--with-png-dir=$(STAGING_DIR)/opt \
		--with-freetype-dir=$(STAGING_DIR)/opt \
		--with-zlib-dir=$(STAGING_DIR)/opt \
		--without-iconv \
		--without-pear \
	)
	touch $(PHP_BUILD_DIR)/.configured

php-unpack: $(PHP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_BUILD_DIR)/.built: $(PHP_BUILD_DIR)/.configured
	rm -f $(PHP_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_BUILD_DIR)
	touch $(PHP_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
php: $(PHP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/bin/php: $(PHP_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_BUILD_DIR) install-strip prefix=$(STAGING_DIR)/opt

php-stage: $(STAGING_DIR)/opt/bin/php

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_IPK_DIR)/opt/sbin or $(PHP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHP_IPK_DIR)/opt/etc/php/...
# Documentation files should be installed in $(PHP_IPK_DIR)/opt/doc/php/...
# Daemon startup scripts should be installed in $(PHP_IPK_DIR)/opt/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_IPK): $(PHP_BUILD_DIR)/.built
	rm -rf $(PHP_IPK_DIR) $(BUILD_DIR)/php_*_$(TARGET_ARCH).ipk
	install -d $(PHP_IPK_DIR)/opt/var/lib/php/session
	chmod a=rwx $(PHP_IPK_DIR)/opt/var/lib/php/session
	$(MAKE) -C $(PHP_BUILD_DIR) INSTALL_ROOT=$(PHP_IPK_DIR) install
	$(TARGET_STRIP) $(PHP_IPK_DIR)/opt/bin/php
	rm -f $(PHP_IPK_DIR)/opt/lib/php/extensions/*.a
	install -d $(PHP_IPK_DIR)/opt/etc
	install -d $(PHP_IPK_DIR)/opt/etc/php.d
	install -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_IPK_DIR)/opt/etc/php.ini
	### now make php-dev
	$(MAKE) $(PHP_DEV_IPK_DIR)/CONTROL/control
	install -d $(PHP_DEV_IPK_DIR)/opt/lib/php
	mv $(PHP_IPK_DIR)/opt/lib/php/build $(PHP_DEV_IPK_DIR)/opt/lib/php/build
	install -d $(PHP_DEV_IPK_DIR)/opt/include
	mv $(PHP_IPK_DIR)/opt/include $(PHP_DEV_IPK_DIR)/opt/include
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_DEV_IPK_DIR)
	### now make php-gd
	$(MAKE) $(PHP_GD_IPK_DIR)/CONTROL/control
	install -d $(PHP_GD_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_GD_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/gd.so $(PHP_GD_IPK_DIR)/opt/lib/php/extensions/gd.so
	echo extension=gd.so >$(PHP_GD_IPK_DIR)/opt/etc/php.d/gd.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_GD_IPK_DIR)
	### now make php-ldap
	$(MAKE) $(PHP_LDAP_IPK_DIR)/CONTROL/control
	install -d $(PHP_LDAP_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_LDAP_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/ldap.so $(PHP_LDAP_IPK_DIR)/opt/lib/php/extensions/ldap.so
	echo extension=ldap.so >$(PHP_LDAP_IPK_DIR)/opt/etc/php.d/ldap.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_LDAP_IPK_DIR)
	### now make php-mysql
	$(MAKE) $(PHP_MYSQL_IPK_DIR)/CONTROL/control
	install -d $(PHP_MYSQL_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_MYSQL_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/mysql.so $(PHP_MYSQL_IPK_DIR)/opt/lib/php/extensions/mysql.so
	echo extension=mysql.so >$(PHP_MYSQL_IPK_DIR)/opt/etc/php.d/mysql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MYSQL_IPK_DIR)
	### finally the main ipkg
	$(MAKE) $(PHP_IPK_DIR)/CONTROL/control
	echo $(PHP_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-ipk: $(PHP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-clean:
	-$(MAKE) -C $(PHP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-dirclean:
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR) $(PHP_IPK_DIR) $(PHP_IPK)
