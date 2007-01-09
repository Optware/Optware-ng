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
PHP_VERSION=5.2.0
PHP_SOURCE=php-$(PHP_VERSION).tar.bz2
PHP_DIR=php-$(PHP_VERSION)
PHP_UNZIP=bzcat
PHP_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_DESCRIPTION=The php scripting language
PHP_SECTION=net
PHP_PRIORITY=optional
ifeq (openldap, $(filter openldap, $(PACKAGES)))
PHP_DEPENDS=bzip2, openssl, zlib, libcurl, libxml2, libxslt, gdbm, libdb, pcre, cyrus-sasl-libs, openldap-libs
else
PHP_DEPENDS=bzip2, openssl, zlib, libcurl, libxml2, libxslt, gdbm, libdb, pcre
endif

#
# PHP_IPK_VERSION should be incremented when the ipk changes.
#
PHP_IPK_VERSION=3

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
PHP_PATCHES=\
	$(PHP_SOURCE_DIR)/aclocal.m4.patch \
	$(PHP_SOURCE_DIR)/configure.in.patch \
	$(PHP_SOURCE_DIR)/threads.m4.patch \
	$(PHP_SOURCE_DIR)/endian-5.0.4.patch \
	$(PHP_SOURCE_DIR)/zend_strtod.patch \
	$(PHP_SOURCE_DIR)/php-5.2.0-and-curl-7.16.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2 -I$(STAGING_INCLUDE_DIR)/libxslt -I$(STAGING_INCLUDE_DIR)/libexslt 
PHP_LDFLAGS=-L$(STAGING_LIB_DIR)/mysql -Wl,-rpath=/opt/lib/mysql -ldl -lpthread

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

PHP_EMBED_IPK_DIR=$(BUILD_DIR)/php-embed-$(PHP_VERSION)-ipk
PHP_EMBED_IPK=$(BUILD_DIR)/php-embed_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_GD_IPK_DIR=$(BUILD_DIR)/php-gd-$(PHP_VERSION)-ipk
PHP_GD_IPK=$(BUILD_DIR)/php-gd_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_IMAP_IPK_DIR=$(BUILD_DIR)/php-imap-$(PHP_VERSION)-ipk
PHP_IMAP_IPK=$(BUILD_DIR)/php-imap_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_LDAP_IPK_DIR=$(BUILD_DIR)/php-ldap-$(PHP_VERSION)-ipk
PHP_LDAP_IPK=$(BUILD_DIR)/php-ldap_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MBSTRING_IPK_DIR=$(BUILD_DIR)/php-mbstring-$(PHP_VERSION)-ipk
PHP_MBSTRING_IPK=$(BUILD_DIR)/php-mbstring_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MYSQL_IPK_DIR=$(BUILD_DIR)/php-mysql-$(PHP_VERSION)-ipk
PHP_MYSQL_IPK=$(BUILD_DIR)/php-mysql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_PGSQL_IPK_DIR=$(BUILD_DIR)/php-pgsql-$(PHP_VERSION)-ipk
PHP_PGSQL_IPK=$(BUILD_DIR)/php-pgsql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_PEAR_IPK_DIR=$(BUILD_DIR)/php-pear-$(PHP_VERSION)-ipk
PHP_PEAR_IPK=$(BUILD_DIR)/php-pear_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

# We need this because openldap does not build on the wl500g.
ifneq ($(OPTWARE_TARGET),wl500g)
PHP_CONFIGURE_TARGET_ARGS= \
		--with-ldap=shared,$(STAGING_PREFIX) \
		--with-ldap-sasl=$(STAGING_PREFIX)
PHP_CONFIGURE_ENV=LIBS=-lsasl2
else
PHP_CONFIGURE_TARGET_ARGS=
PHP_CONFIGURE_ENV=
endif

PHP_CONFIGURE_THREAD_ARGS= \
		--enable-maintainer-zts 

.PHONY: php-source php-unpack php php-stage php-ipk php-clean php-dirclean php-check

#
# Automatically create a ipkg control file
#
$(PHP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
	@install -d $(@D)
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

$(PHP_EMBED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-embed" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: php embedded library - the embed SAPI" >>$@
	@echo "Depends: php" >>$@

$(PHP_GD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(PHP_IMAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-imap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: imap extension for php" >>$@
	@echo "Depends: php, imap-libs" >>$@

$(PHP_LDAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(PHP_MBSTRING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-mbstring" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mbstring extension for php" >>$@
	@echo "Depends: php" >>$@

$(PHP_MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(PHP_PEAR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-pear" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: PHP Extension and Application Repository" >>$@
	@echo "Depends: php" >>$@

$(PHP_PGSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: php-pgsql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: pgsql extension for php" >>$@
	@echo "Depends: php, postgresql" >>$@

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
$(PHP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_SOURCE) $(PHP_PATCHES)
	$(MAKE) bzip2-stage 
	$(MAKE) gdbm-stage 
	$(MAKE) libcurl-stage
	$(MAKE) libdb-stage
	$(MAKE) libgd-stage 
	$(MAKE) libxml2-stage 
	$(MAKE) libxslt-stage 
	$(MAKE) openssl-stage 
	$(MAKE) mysql-stage
	$(MAKE) postgresql-stage
	$(MAKE) imap-stage
	$(MAKE) libpng-stage
	$(MAKE) libjpeg-stage
	$(MAKE) pcre-stage
ifneq ($(OPTWARE_TARGET),wl500g)
	$(MAKE) openldap-stage
	$(MAKE) cyrus-sasl-stage
endif
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR)
	if test -n "$(PHP_PATCHES)"; \
	    then cat $(PHP_PATCHES) | patch -p0 -bd $(PHP_BUILD_DIR); \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i \
	    -e 's|`$$PG_CONFIG --includedir`|$(STAGING_INCLUDE_DIR)|' \
	    -e 's|`$$PG_CONFIG --libdir`|$(STAGING_LIB_DIR)|' \
	    $(PHP_BUILD_DIR)/ext/*pgsql/*.m4
endif
	(cd $(PHP_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS) $(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		PHP_LIBXML_DIR=$(STAGING_PREFIX) \
		EXTENSION_DIR=/opt/lib/php/extensions \
		ac_cv_func_memcmp_working=yes \
		cv_php_mbstring_stdarg=yes \
		STAGING_PREFIX="$(STAGING_PREFIX)" \
		$(PHP_CONFIGURE_ENV) \
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
		--enable-dom=shared \
		--enable-embed=shared \
		--enable-exif=shared \
		--enable-ftp=shared \
		--enable-mbstring=shared \
		--enable-pdo=shared \
		--enable-shmop=shared \
		--enable-sockets=shared \
		--enable-sysvmsg=shared \
		--enable-sysvshm=shared \
		--enable-sysvsem=shared \
		--enable-xml=shared \
		--enable-xmlreader=shared \
		--with-bz2=shared,$(STAGING_PREFIX) \
		--with-curl=shared,$(STAGING_PREFIX) \
		--with-db4=$(STAGING_PREFIX) \
		--with-dom=shared,$(STAGING_PREFIX) \
		--with-gdbm=$(STAGING_PREFIX) \
		--with-gd=shared,$(STAGING_PREFIX) \
		--with-imap=shared,$(STAGING_PREFIX) \
		--with-mysql=shared,$(STAGING_PREFIX) \
		--with-mysql-sock=/tmp/mysql.sock \
		--with-mysqli=shared,$(STAGING_PREFIX)/bin/mysql_config \
		--with-pgsql=shared,$(STAGING_PREFIX) \
		--with-openssl=shared,$(STAGING_PREFIX) \
		--with-sqlite=shared \
		--with-pdo-mysql=shared,$(STAGING_PREFIX) \
		--with-pdo-pgsql=shared,$(STAGING_PREFIX) \
		--with-pdo-sqlite=shared \
		--with-xsl=shared,$(STAGING_PREFIX) \
		--with-zlib=shared,$(STAGING_PREFIX) \
		--with-libxml-dir=$(STAGING_PREFIX) \
		--with-jpeg-dir=$(STAGING_PREFIX) \
		--with-png-dir=$(STAGING_PREFIX) \
		--with-freetype-dir=$(STAGING_PREFIX) \
		--with-zlib-dir=$(STAGING_PREFIX) \
		--with-pcre-regex=$(STAGING_PREFIX) \
		$(PHP_CONFIGURE_TARGET_ARGS) \
		$(PHP_CONFIGURE_THREAD_ARGS) \
		--without-iconv \
		--without-pear \
	)
	$(PATCH_LIBTOOL) $(PHP_BUILD_DIR)/libtool
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
$(PHP_BUILD_DIR)/.staged: $(PHP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PHP_BUILD_DIR) INSTALL_ROOT=$(STAGING_DIR) program_prefix="" install
	cp $(STAGING_PREFIX)/bin/php-config $(STAGING_DIR)/bin/php-config
	cp $(STAGING_PREFIX)/bin/phpize $(STAGING_DIR)/bin/phpize
	sed -i -e 's!prefix=.*!prefix=$(STAGING_PREFIX)!' $(STAGING_DIR)/bin/phpize
	chmod a+rx $(STAGING_DIR)/bin/phpize
	touch $@

php-stage: $(PHP_BUILD_DIR)/.staged

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
	$(MAKE) -C $(PHP_BUILD_DIR) INSTALL_ROOT=$(PHP_IPK_DIR) program_prefix="" install
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/bin/php
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/lib/*.so
	$(STRIP_COMMAND) $(PHP_IPK_DIR)/opt/lib/php/extensions/*.so
	rm -f $(PHP_IPK_DIR)/opt/lib/php/extensions/*.a
	install -d $(PHP_IPK_DIR)/opt/etc
	install -d $(PHP_IPK_DIR)/opt/etc/php.d
	install -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_IPK_DIR)/opt/etc/php.ini
	### now make php-dev
	rm -rf $(PHP_DEV_IPK_DIR) $(BUILD_DIR)/php-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_DEV_IPK_DIR)/CONTROL/control
	install -d $(PHP_DEV_IPK_DIR)/opt/lib/php
	mv $(PHP_IPK_DIR)/opt/lib/php/build $(PHP_DEV_IPK_DIR)/opt/lib/php/
	mv $(PHP_IPK_DIR)/opt/include $(PHP_DEV_IPK_DIR)/opt/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_DEV_IPK_DIR)
	### now make php-embed
	rm -rf $(PHP_EMBED_IPK_DIR) $(BUILD_DIR)/php-embed_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_EMBED_IPK_DIR)/CONTROL/control
	install -d $(PHP_EMBED_IPK_DIR)/opt/lib/
	mv $(PHP_IPK_DIR)/opt/lib/libphp5.so $(PHP_EMBED_IPK_DIR)/opt/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_EMBED_IPK_DIR)
	### now make php-gd
	rm -rf $(PHP_GD_IPK_DIR) $(BUILD_DIR)/php-gd_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_GD_IPK_DIR)/CONTROL/control
	install -d $(PHP_GD_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_GD_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/gd.so $(PHP_GD_IPK_DIR)/opt/lib/php/extensions/gd.so
	echo extension=gd.so >$(PHP_GD_IPK_DIR)/opt/etc/php.d/gd.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_GD_IPK_DIR)
	### now make php-imap
	rm -rf $(PHP_IMAP_IPK_DIR) $(BUILD_DIR)/php-imap_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_IMAP_IPK_DIR)/CONTROL/control
	install -d $(PHP_IMAP_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_IMAP_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/imap.so $(PHP_IMAP_IPK_DIR)/opt/lib/php/extensions/imap.so
	echo extension=imap.so >$(PHP_IMAP_IPK_DIR)/opt/etc/php.d/imap.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IMAP_IPK_DIR)
ifneq ($(OPTWARE_TARGET),wl500g)
	### now make php-ldap
	rm -rf $(PHP_LDAP_IPK_DIR) $(BUILD_DIR)/php-ldap_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_LDAP_IPK_DIR)/CONTROL/control
	install -d $(PHP_LDAP_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_LDAP_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/ldap.so $(PHP_LDAP_IPK_DIR)/opt/lib/php/extensions/ldap.so
	echo extension=ldap.so >$(PHP_LDAP_IPK_DIR)/opt/etc/php.d/ldap.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_LDAP_IPK_DIR)
endif
	### now make php-mbstring
	rm -rf $(PHP_MBSTRING_IPK_DIR) $(BUILD_DIR)/php-mbstring_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MBSTRING_IPK_DIR)/CONTROL/control
	install -d $(PHP_MBSTRING_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_MBSTRING_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/mbstring.so $(PHP_MBSTRING_IPK_DIR)/opt/lib/php/extensions/mbstring.so
	echo extension=mbstring.so >$(PHP_MBSTRING_IPK_DIR)/opt/etc/php.d/mbstring.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MBSTRING_IPK_DIR)
	### now make php-mysql
	rm -rf $(PHP_MYSQL_IPK_DIR) $(BUILD_DIR)/php-mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MYSQL_IPK_DIR)/CONTROL/control
	install -d $(PHP_MYSQL_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_MYSQL_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/*mysql*.so $(PHP_MYSQL_IPK_DIR)/opt/lib/php/extensions/
	echo extension=mysql.so >$(PHP_MYSQL_IPK_DIR)/opt/etc/php.d/mysql.ini
	echo extension=mysqli.so >>$(PHP_MYSQL_IPK_DIR)/opt/etc/php.d/mysql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MYSQL_IPK_DIR)
	### now make php-pear
	rm -rf $(PHP_PEAR_IPK_DIR) $(BUILD_DIR)/php-pear_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_PEAR_IPK_DIR)/CONTROL/control
	install -m 644 $(PHP_SOURCE_DIR)/postinst.pear $(PHP_PEAR_IPK_DIR)/CONTROL/postinst
	install -m 644 $(PHP_SOURCE_DIR)/prerm.pear $(PHP_PEAR_IPK_DIR)/CONTROL/prerm
	install -d $(PHP_PEAR_IPK_DIR)/tmp
	cp -a $(PHP_BUILD_DIR)/pear $(PHP_PEAR_IPK_DIR)/tmp
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_PEAR_IPK_DIR)
	### now make php-pgsql
	rm -rf $(PHP_PGSQL_IPK_DIR) $(BUILD_DIR)/php-pgsql_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_PGSQL_IPK_DIR)/CONTROL/control
	install -d $(PHP_PGSQL_IPK_DIR)/opt/lib/php/extensions
	install -d $(PHP_PGSQL_IPK_DIR)/opt/etc/php.d
	mv $(PHP_IPK_DIR)/opt/lib/php/extensions/*pgsql*.so $(PHP_PGSQL_IPK_DIR)/opt/lib/php/extensions/
	echo extension=pgsql.so >$(PHP_PGSQL_IPK_DIR)/opt/etc/php.d/pgsql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_PGSQL_IPK_DIR)
	### finally the main ipkg
	$(MAKE) $(PHP_IPK_DIR)/CONTROL/control
	echo $(PHP_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ifneq ($(OPTWARE_TARGET),wl500g)
php-ipk: $(PHP_IPK) \
	$(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK) \
	$(PHP_GD_IPK) \
	$(PHP_IMAP_IPK) \
	$(PHP_LDAP_IPK) \
	$(PHP_MBSTRING_IPK) \
	$(PHP_MYSQL_IPK) \
	$(PHP_PGSQL_IPK) \
	$(PHP_PEAR_IPK)
else
php-ipk: $(PHP_IPK) \
	$(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK) \
	$(PHP_GD_IPK) \
	$(PHP_IMAP_IPK) \
	$(PHP_MBSTRING_IPK) \
	$(PHP_MYSQL_IPK) \
	$(PHP_PGSQL_IPK) \
	$(PHP_PEAR_IPK)
endif

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
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(PHP_BUILD_DIR) \
	$(PHP_IPK_DIR) $(PHP_IPK) \
	$(PHP_DEV_IPK_DIR) $(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK_DIR) $(PHP_EMBED_IPK) \
	$(PHP_GD_IPK_DIR) $(PHP_GD_IPK) \
	$(PHP_IMAP_IPK_DIR) $(PHP_IMAP_IPK) \
	$(PHP_MBSTRING_IPK_DIR) $(PHP_MBSTRING_IPK) \
	$(PHP_MYSQL_IPK_DIR) $(PHP_MYSQL_IPK) \
	$(PHP_PGSQL_IPK_DIR) $(PHP_PGSQL_IPK) \
	$(PHP_PEAR_IPK_DIR) $(PHP_PEAR_IPK)
ifneq ($(OPTWARE_TARGET),wl500g)
	rm -rf $(PHP_LDAP_IPK_DIR) $(PHP_LDAP_IPK)
endif

#
# Some sanity check for the package.
#
php-check: php-ipk
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
	$(PHP_IPK) \
	$(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK) \
	$(PHP_GD_IPK) \
	$(PHP_IMAP_IPK) \
	$(PHP_MBSTRING_IPK) \
	$(PHP_MYSQL_IPK) \
	$(PHP_PGSQL_IPK) \
	$(PHP_PEAR_IPK)
ifneq ($(OPTWARE_TARGET),wl500g)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PHP_LDAP_IPK)
endif
