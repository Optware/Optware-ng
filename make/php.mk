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
ifndef PHP_SITE
PHP_SITE=http://static.php.net/www.php.net/distributions
PHP_VERSION=5.6.33
PHP_SOURCE=php-$(PHP_VERSION).tar.bz2
PHP_DIR=php-$(PHP_VERSION)
PHP_UNZIP=bzcat
PHP_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
PHP_DESCRIPTION=The php scripting language
PHP_SECTION=net
PHP_PRIORITY=optional
PHP_DEPENDS=bzip2, openssl, zlib, libxml2, libxslt, gdbm, libdb, sqlite
ifeq (openldap, $(filter openldap, $(PACKAGES)))
PHP_DEPENDS+=, cyrus-sasl-libs, openldap-libs
endif
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PHP_DEPENDS+=, libstdc++
endif

### php host cli is needed for phar extension,
### so we have to build it first
PHP_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/php
PHP_HOST_CLI=$(HOST_STAGING_PREFIX)/bin/php

#
# PHP_IPK_VERSION should be incremented when the ipk changes.
#
PHP_IPK_VERSION=2

#
# PHP_CONFFILES should be a list of user-editable files
#
PHP_CONFFILES=$(TARGET_PREFIX)/etc/php.ini
PHP_FCGI_CONFFILES=$(TARGET_PREFIX)/etc/lighttpd/conf.d/10-php-fcgi.conf

#
# PHP_LOCALES defines which locales get installed
#
PHP_LOCALES=

#
# PHP_CONFFILES should be a list of user-editable files
#PHP_CONFFILES=$(TARGET_PREFIX)/etc/php.conf $(TARGET_PREFIX)/etc/init.d/SXXphp

#
# PHP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_PATCHES=\
	$(PHP_SOURCE_DIR)/cross-compile.patch \
	$(PHP_SOURCE_DIR)/DSA_get_default_method-detection.patch \
	$(PHP_SOURCE_DIR)/aclocal.m4.patch \
	$(PHP_SOURCE_DIR)/endian-5.0.4.patch \
	$(PHP_SOURCE_DIR)/ext-posix-uclibc.patch \
	$(PHP_SOURCE_DIR)/no_libmysql_r.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/mysql -I$(STAGING_INCLUDE_DIR)/libxml2 -I$(STAGING_INCLUDE_DIR)/libxslt -I$(STAGING_INCLUDE_DIR)/libexslt -I$(STAGING_INCLUDE_DIR)/freetype2
PHP_LDFLAGS=-ldl -lpthread -lgcc_s

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

PHP_CURL_IPK_DIR=$(BUILD_DIR)/php-curl-$(PHP_VERSION)-ipk
PHP_CURL_IPK=$(BUILD_DIR)/php-curl_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_FCGI_IPK_DIR=$(BUILD_DIR)/php-fcgi-$(PHP_VERSION)-ipk
PHP_FCGI_IPK=$(BUILD_DIR)/php-fcgi_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_GD_IPK_DIR=$(BUILD_DIR)/php-gd-$(PHP_VERSION)-ipk
PHP_GD_IPK=$(BUILD_DIR)/php-gd_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_GMP_IPK_DIR=$(BUILD_DIR)/php-gmp-$(PHP_VERSION)-ipk
PHP_GMP_IPK=$(BUILD_DIR)/php-gmp_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_ICONV_IPK_DIR=$(BUILD_DIR)/php-iconv-$(PHP_VERSION)-ipk
PHP_ICONV_IPK=$(BUILD_DIR)/php-iconv_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_IMAP_IPK_DIR=$(BUILD_DIR)/php-imap-$(PHP_VERSION)-ipk
PHP_IMAP_IPK=$(BUILD_DIR)/php-imap_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_INTL_IPK_DIR=$(BUILD_DIR)/php-intl-$(PHP_VERSION)-ipk
PHP_INTL_IPK=$(BUILD_DIR)/php-intl_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_LDAP_IPK_DIR=$(BUILD_DIR)/php-ldap-$(PHP_VERSION)-ipk
PHP_LDAP_IPK=$(BUILD_DIR)/php-ldap_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MBSTRING_IPK_DIR=$(BUILD_DIR)/php-mbstring-$(PHP_VERSION)-ipk
PHP_MBSTRING_IPK=$(BUILD_DIR)/php-mbstring_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MCRYPT_IPK_DIR=$(BUILD_DIR)/php-mcrypt-$(PHP_VERSION)-ipk
PHP_MCRYPT_IPK=$(BUILD_DIR)/php-mcrypt_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MSSQL_IPK_DIR=$(BUILD_DIR)/php-mssql-$(PHP_VERSION)-ipk
PHP_MSSQL_IPK=$(BUILD_DIR)/php-mssql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_MYSQL_IPK_DIR=$(BUILD_DIR)/php-mysql-$(PHP_VERSION)-ipk
PHP_MYSQL_IPK=$(BUILD_DIR)/php-mysql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_PGSQL_IPK_DIR=$(BUILD_DIR)/php-pgsql-$(PHP_VERSION)-ipk
PHP_PGSQL_IPK=$(BUILD_DIR)/php-pgsql_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_ODBC_IPK_DIR=$(BUILD_DIR)/php-odbc-$(PHP_VERSION)-ipk
PHP_ODBC_IPK=$(BUILD_DIR)/php-odbc_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_SNMP_IPK_DIR=$(BUILD_DIR)/php-snmp-$(PHP_VERSION)-ipk
PHP_SNMP_IPK=$(BUILD_DIR)/php-snmp_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_PEAR_IPK_DIR=$(BUILD_DIR)/php-pear-$(PHP_VERSION)-ipk
PHP_PEAR_IPK=$(BUILD_DIR)/php-pear_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_XMLRPC_IPK_DIR=$(BUILD_DIR)/php-xmlrpc-$(PHP_VERSION)-ipk
PHP_XMLRPC_IPK=$(BUILD_DIR)/php-xmlrpc_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_ZIP_IPK_DIR=$(BUILD_DIR)/php-zip-$(PHP_VERSION)-ipk
PHP_ZIP_IPK=$(BUILD_DIR)/php-zip_$(PHP_VERSION)-$(PHP_IPK_VERSION)_$(TARGET_ARCH).ipk

PHP_CONFIGURE_ARGS=
PHP_CONFIGURE_ENV=
PHP_TARGET_IPKS = \
	$(PHP_IPK) \
	$(PHP_DEV_IPK) \
	$(PHP_EMBED_IPK) \
	$(PHP_CURL_IPK) \
	$(PHP_GD_IPK) \
	$(PHP_GMP_IPK) \
	$(PHP_IMAP_IPK) \
	$(PHP_INTL_IPK) \
	$(PHP_MBSTRING_IPK) \
	$(PHP_MSSQL_IPK) \
	$(PHP_MYSQL_IPK) \
	$(PHP_ODBC_IPK) \
	$(PHP_SNMP_IPK) \
	$(PHP_PGSQL_IPK) \
	$(PHP_PEAR_IPK) \
	$(PHP_XMLRPC_IPK) \
	$(PHP_ZIP_IPK) \
	$(PHP_FCGI_IPK) \

# We need this because openldap does not build on the wl500g.
ifeq (openldap, $(filter openldap, $(PACKAGES)))
PHP_CONFIGURE_ARGS += \
		--with-ldap=shared,$(STAGING_PREFIX) \
		--with-ldap-sasl=$(STAGING_PREFIX)
PHP_CONFIGURE_ENV += LIBS=-lsasl2
PHP_TARGET_IPKS += $(PHP_LDAP_IPK)
endif

ifeq (glibc, $(LIBC_STYLE))
PHP_CONFIGURE_ARGS +=--with-iconv=shared
else
  ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
PHP_CONFIGURE_ARGS +=--with-iconv=shared,$(STAGING_PREFIX)
  else
PHP_CONFIGURE_ARGS +=--without-iconv
  endif
endif

ifeq (, $(filter --without-iconv, $(PHP_CONFIGURE_ARGS)))
PHP_TARGET_IPKS += $(PHP_ICONV_IPK)
endif

.PHONY: php-source php-unpack php php-stage php-ipk php-clean php-dirclean php-check

#
# Automatically create a ipkg control file
#
$(PHP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	@$(INSTALL) -d $(@D)
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
	@$(INSTALL) -d $(@D)
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

$(PHP_CURL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: libcurl extension for php" >>$@
	@echo "Depends: php, libcurl" >>$@

$(PHP_FCGI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-fcgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: The php scripting language, built as an fcgi module" >>$@
	@echo "Depends: php" >>$@

$(PHP_GD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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

$(PHP_GMP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-gmp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: libgmp extension for php" >>$@
	@echo "Depends: php, libgmp" >>$@

$(PHP_ICONV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-iconv" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: libiconv extension for php" >>$@
ifeq (libiconv,$(filter libiconv, $(PACKAGES)))
	@echo "Depends: php, libiconv" >>$@
else
	@echo "Depends: php" >>$@
endif

$(PHP_IMAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-imap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: imap extension for php" >>$@
	@echo "Depends: php, imap-libs, libpam, openssl" >>$@

$(PHP_INTL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-intl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: intl extension for php" >>$@
	@echo "Depends: php, icu" >>$@

$(PHP_LDAP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	@$(INSTALL) -d $(@D)
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

$(PHP_MCRYPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-mcrypt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mcrypt extension for php" >>$@
	@echo "Depends: php, libmcrypt, libtool" >>$@

$(PHP_MYSQL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mysqli and pdo_mysql extensions for php" >>$@
	@echo "Depends: php, mysql" >>$@

$(PHP_PEAR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	@$(INSTALL) -d $(@D)
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

$(PHP_MSSQL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-mssql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: mssql extension for php" >>$@
	@echo "Depends: php, freetds" >>$@

$(PHP_ODBC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-odbc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: odbc extension for php" >>$@
	@echo "Depends: php, unixodbc" >>$@

$(PHP_SNMP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-snmp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: snmp extension for php" >>$@
	@echo "Depends: php, libnetsnmp, libnl, snmp-mibs" >>$@

$(PHP_XMLRPC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-xmlrpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: xmlrpc extension for php" >>$@
ifeq (libiconv,$(filter libiconv, $(PACKAGES)))
	@echo "Depends: php, libiconv" >>$@
else
	@echo "Depends: php" >>$@
endif

$(PHP_ZIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: php-zip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_PRIORITY)" >>$@
	@echo "Section: $(PHP_SECTION)" >>$@
	@echo "Version: $(PHP_VERSION)-$(PHP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_MAINTAINER)" >>$@
	@echo "Source: $(PHP_SITE)/$(PHP_SOURCE)" >>$@
	@echo "Description: zip extension for php" >>$@
	@echo "Depends: php, libzip" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHP_SOURCE):
	$(WGET) -P $(@D) $(PHP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
$(PHP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_SOURCE) $(PHP_HOST_CLI) $(PHP_PATCHES) make/php.mk
	$(MAKE) bzip2-stage gdbm-stage libcurl-stage libdb-stage libgd-stage libxml2-stage \
		libxslt-stage openssl-stage mysql-stage postgresql-stage freetds-stage \
		unixodbc-stage imap-stage libpng-stage libjpeg-stage libzip-stage icu-stage \
		libpam-stage net-snmp-stage \
		libgmp-stage sqlite-stage libmcrypt-stage libtool-stage libtool-host-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	$(MAKE) openldap-stage cyrus-sasl-stage
endif
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(@D)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PHP_DIR) $(@D)
	if test -n "$(PHP_PATCHES)"; \
	    then cat $(PHP_PATCHES) | $(PATCH) -p0 -bd $(@D); \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i \
	    -e 's|`$$PG_CONFIG --includedir`|$(STAGING_INCLUDE_DIR)|' \
	    -e 's|`$$PG_CONFIG --libdir`|$(STAGING_LIB_DIR)|' \
	    $(@D)/ext/*pgsql/*.m4
endif
ifeq (glibc, $(LIBC_STYLE))
	sed -i -e 's|/usr/local /usr|$(shell cd $(TARGET_INCDIR)/..; pwd)|' $(@D)/ext/iconv/config.m4
endif

	sed -i -e '/extern int php_string_to_if_index/s/^/#ifndef AI_ADDRCONFIG\n#define AI_ADDRCONFIG 0\n#endif\n/' \
		$(@D)/ext/sockets/sockaddr_conv.c

	(cd $(HOST_STAGING_PREFIX)/share/aclocal; \
		cat libtool.m4 ltoptions.m4 ltversion.m4 ltsugar.m4 \
			lt~obsolete.m4 >> $(@D)/aclocal.m4 \
	)

	(cd $(HOST_STAGING_PREFIX)/share/aclocal; \
		cat libtool.m4 ltoptions.m4 ltversion.m4 ltsugar.m4 \
			lt~obsolete.m4 >> $(@D)/build/libtool.m4 \
	)

	echo 'AC_CONFIG_MACRO_DIR([m4])' >> $(@D)/configure.in

	$(AUTORECONF1.10) -vif $(@D)
	sed -i -e 's|icu_install_prefix=.*|icu_install_prefix=$(STAGING_PREFIX)|' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(PHP_CPPFLAGS) $(STAGING_LDFLAGS) $(PHP_LDFLAGS)" \
		PATH="$(STAGING_DIR)/bin:$$PATH" \
		PHP_LIBXML_DIR=$(STAGING_PREFIX) \
		EXTENSION_DIR=$(TARGET_PREFIX)/lib/php/extensions \
		ac_cv_func_memcmp_working=yes \
		cv_php_mbstring_stdarg=yes \
		STAGING_PREFIX="$(STAGING_PREFIX)" \
		$(PHP_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-config-file-scan-dir=$(TARGET_PREFIX)/etc/php.d \
		--with-layout=GNU \
		--disable-static \
		--disable-opcache \
		--enable-maintainer-zts \
		--enable-cgi \
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
		--enable-zip=shared \
		--enable-intl=shared \
		--with-bz2=shared,$(STAGING_PREFIX) \
		--with-curl=shared,$(STAGING_PREFIX) \
		--with-db4=$(STAGING_PREFIX) \
		--with-dom=shared,$(STAGING_PREFIX) \
		--with-gdbm=$(STAGING_PREFIX) \
		--with-gd=shared,$(STAGING_PREFIX) \
		--with-imap=shared,$(STAGING_PREFIX) \
		--with-imap-ssl=$(STAGING_PREFIX) \
		--without-mysql \
		--with-mysql-sock=/tmp/mysql.sock \
		--with-mysqli=shared,$(STAGING_PREFIX)/bin/mysql_config \
		--with-pgsql=shared,$(STAGING_PREFIX) \
		--with-mssql=shared,$(STAGING_PREFIX) \
		--with-unixODBC=shared,$(STAGING_PREFIX) \
		--with-openssl=shared,$(STAGING_PREFIX) \
		--with-snmp=shared,$(STAGING_PREFIX) \
		--with-sqlite=shared,$(STAGING_PREFIX) \
		--with-pdo-mysql=shared,$(STAGING_PREFIX) \
		--with-pdo-pgsql=shared,$(STAGING_PREFIX) \
		--with-pdo-sqlite=shared,$(STAGING_PREFIX) \
		--with-xsl=shared,$(STAGING_PREFIX) \
		--with-zlib=shared,$(STAGING_PREFIX) \
		--with-libxml-dir=$(STAGING_PREFIX) \
		--with-jpeg-dir=$(STAGING_PREFIX) \
		--with-png-dir=$(STAGING_PREFIX) \
		--with-freetype-dir=$(STAGING_PREFIX) \
		--with-zlib-dir=$(STAGING_PREFIX) \
		--with-libzip=$(STAGING_PREFIX) \
		--with-icu-dir=$(STAGING_PREFIX) \
		--with-gmp=shared,$(STAGING_PREFIX) \
		--with-mcrypt=shared,$(STAGING_PREFIX) \
		$(PHP_CONFIGURE_ARGS) \
		--without-pear \
		--with-xmlrpc=shared \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool

	echo "#define HAVE_DLOPEN 1" >> $(@D)/main/php_config.h
	echo "#define HAVE_LIBDL 1" >> $(@D)/main/php_config.h
	
	sed -i -e '/#define HAVE_GD_XPM/s|^|//|' \
		-e '/#define HAVE_ATOMIC_H/s|^|//|' $(@D)/main/php_config.h

	sed -i -e 's|\$$(top_builddir)/\$$(SAPI_CLI_PATH)|$(PHP_HOST_CLI)|' \
		-e 's|-Wl,-rpath,$(STAGING_LIB_DIR)|-Wl,-rpath,$(TARGET_PREFIX)/lib|g' \
		-e 's/###      or --detect-prefix//' \
		-e 's|INTL_SHARED_LIBADD =.*|INTL_SHARED_LIBADD = -L$(STAGING_LIB_DIR) -licuuc -licui18n -licuio|' \
		-e 's|^program_prefix =.*|program_prefix =|' $(@D)/Makefile

	# workaround for /opt/lib/php/extensions/intl.so: undefined symbol: spoofchecker_register_Spoofchecker_class
	for obj in spoofchecker spoofchecker_class spoofchecker_create spoofchecker_main; do \
		(echo "ext/intl/spoofchecker/$${obj}.lo: $(@D)/ext/intl/spoofchecker/$${obj}.c"; \
		 echo "	\$$(LIBTOOL) --mode=compile \$$(CC)  -Wno-write-strings -Iext/intl/ -I$(@D)/ext/intl/ \$$(COMMON_FLAGS) \$$(CFLAGS_CLEAN) \$$(EXTRA_CFLAGS) -fPIC -c $(@D)/ext/intl/spoofchecker/$${obj}.c -o ext/intl/spoofchecker/$${obj}.lo") >> $(@D)/Makefile; \
	done
	sed -i -e '/^shared_objects_intl/s|$$| $(addprefix ext/intl/spoofchecker/,spoofchecker.lo spoofchecker_class.lo spoofchecker_create.lo spoofchecker_main.lo)|' $(@D)/Makefile

	touch $@

php-unpack: $(PHP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_BUILD_DIR)/.built: $(PHP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

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
	$(MAKE) -C $(@D) INSTALL_ROOT=$(STAGING_DIR) program_prefix="" install
	cp -af $(STAGING_PREFIX)/bin/php-config $(STAGING_DIR)/bin/php-config
	cp -af $(STAGING_PREFIX)/bin/phpize $(STAGING_DIR)/bin/phpize
	sed -i -e "s!^prefix=.*!prefix='$(STAGING_PREFIX)'!" \
		-e "s|^datarootdir=.*|datarootdir='$(STAGING_PREFIX)/share'|" $(STAGING_DIR)/bin/phpize
	sed -i -e 's!^prefix=.*!prefix="$(STAGING_PREFIX)"!' \
		-e 's|^datarootdir=.*|datarootdir="$(STAGING_PREFIX)/share"|' $(STAGING_DIR)/bin/php-config
	touch $@

php-stage: $(PHP_BUILD_DIR)/.staged

$(PHP_HOST_CLI): host/.configured $(DL_DIR)/$(PHP_SOURCE)
	rm -rf $(HOST_BUILD_DIR)/$(PHP_DIR) $(PHP_HOST_BUILD_DIR)
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(PHP_DIR)" != "$(PHP_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(PHP_DIR) $(PHP_HOST_BUILD_DIR) ; \
	fi
	(cd $(PHP_HOST_BUILD_DIR); \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX) \
		--disable-all \
		--enable-phar \
		--disable-cgi \
	)
	$(MAKE) -C $(PHP_HOST_BUILD_DIR) program_prefix="" install

php-host-stage: $(PHP_HOST_CLI)

php-host-dirclean:
	rm -rf $(HOST_BUILD_DIR)/$(PHP_DIR) $(PHP_HOST_BUILD_DIR)
	rm -f $(PHP_HOST_CLI)

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_IPK_DIR)$(TARGET_PREFIX)/etc/php/...
# Documentation files should be installed in $(PHP_IPK_DIR)$(TARGET_PREFIX)/doc/php/...
# Daemon startup scripts should be installed in $(PHP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_TARGET_IPKS): $(PHP_BUILD_DIR)/.built
	rm -rf $(PHP_IPK_DIR) $(BUILD_DIR)/php_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(PHP_IPK_DIR)$(TARGET_PREFIX)/var/lib/php/session
	chmod a=rwx $(PHP_IPK_DIR)$(TARGET_PREFIX)/var/lib/php/session
	$(MAKE) -C $(PHP_BUILD_DIR) INSTALL_ROOT=$(PHP_IPK_DIR) install
	$(STRIP_COMMAND) $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin/php
	$(STRIP_COMMAND) $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin/php-cgi
	$(STRIP_COMMAND) $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	$(STRIP_COMMAND) $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/*.so
	rm -f $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/*.a
	$(INSTALL) -d $(PHP_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -d $(PHP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_IPK_DIR)$(TARGET_PREFIX)/etc/php.ini
	### now make php-dev
	rm -rf $(PHP_DEV_IPK_DIR) $(BUILD_DIR)/php-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_DEV_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/php
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/build $(PHP_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/php/
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/include $(PHP_DEV_IPK_DIR)$(TARGET_PREFIX)/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_DEV_IPK_DIR)
	### now make php-embed
	rm -rf $(PHP_EMBED_IPK_DIR) $(BUILD_DIR)/php-embed_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_EMBED_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_EMBED_IPK_DIR)$(TARGET_PREFIX)/lib/
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/libphp5.so $(PHP_EMBED_IPK_DIR)$(TARGET_PREFIX)/lib
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_EMBED_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_EMBED_IPK_DIR)
	### now make php-curl
	rm -rf $(PHP_CURL_IPK_DIR) $(BUILD_DIR)/php-curl_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_CURL_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_CURL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_CURL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/curl.so $(PHP_CURL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/curl.so
	echo extension=curl.so >$(PHP_CURL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/curl.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_CURL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_CURL_IPK_DIR)
	### now make php-fcgi
	rm -rf $(PHP_FCGI_IPK_DIR) $(BUILD_DIR)/php-fcgi_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_FCGI_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_FCGI_IPK_DIR)$(TARGET_PREFIX)/bin
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin/php-cgi $(PHP_FCGI_IPK_DIR)$(TARGET_PREFIX)/bin/php-fcgi
	$(STRIP_COMMAND) $(PHP_FCGI_IPK_DIR)$(TARGET_PREFIX)/bin/php-fcgi
	$(INSTALL) -d $(PHP_FCGI_IPK_DIR)$(TARGET_PREFIX)/etc/lighttpd/conf.d
	$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/php-fcgi-lighttpd.conf $(PHP_FCGI_IPK_DIR)$(TARGET_PREFIX)/etc/lighttpd/conf.d/10-php-fcgi.conf
	echo $(PHP_FCGI_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_FCGI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_FCGI_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_FCGI_IPK_DIR)
	### now make php-gd
	rm -rf $(PHP_GD_IPK_DIR) $(BUILD_DIR)/php-gd_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_GD_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_GD_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_GD_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/gd.so $(PHP_GD_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/gd.so
	echo extension=gd.so >$(PHP_GD_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/gd.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_GD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_GD_IPK_DIR)
	### now make php-gmp
	rm -rf $(PHP_GMP_IPK_DIR) $(BUILD_DIR)/php-gmp_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_GMP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_GMP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_GMP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/gmp.so $(PHP_GMP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/gmp.so
	echo extension=gmp.so >$(PHP_GMP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/gmp.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_GMP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_GMP_IPK_DIR)
ifeq (, $(filter --without-iconv, $(PHP_CONFIGURE_ARGS)))
	### now make php-iconv
	rm -rf $(PHP_ICONV_IPK_DIR) $(BUILD_DIR)/php-iconv_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_ICONV_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_ICONV_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_ICONV_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/iconv.so $(PHP_ICONV_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/iconv.so
	echo extension=iconv.so >$(PHP_ICONV_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/iconv.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_ICONV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_ICONV_IPK_DIR)
endif
	### now make php-imap
	rm -rf $(PHP_IMAP_IPK_DIR) $(BUILD_DIR)/php-imap_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_IMAP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_IMAP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_IMAP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/imap.so $(PHP_IMAP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/imap.so
	echo extension=imap.so >$(PHP_IMAP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/imap.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IMAP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_IMAP_IPK_DIR)
	### now make php-intl
	rm -rf $(PHP_INTL_IPK_DIR) $(BUILD_DIR)/php-intl_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_INTL_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_INTL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_INTL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/intl.so $(PHP_INTL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/intl.so
	echo extension=intl.so >$(PHP_INTL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/intl.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_INTL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_INTL_IPK_DIR)
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	### now make php-ldap
	rm -rf $(PHP_LDAP_IPK_DIR) $(BUILD_DIR)/php-ldap_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_LDAP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_LDAP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_LDAP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/ldap.so $(PHP_LDAP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/ldap.so
	echo extension=ldap.so >$(PHP_LDAP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/ldap.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_LDAP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_LDAP_IPK_DIR)
endif
	### now make php-mbstring
	rm -rf $(PHP_MBSTRING_IPK_DIR) $(BUILD_DIR)/php-mbstring_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MBSTRING_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_MBSTRING_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_MBSTRING_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/mbstring.so $(PHP_MBSTRING_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/mbstring.so
	echo extension=mbstring.so >$(PHP_MBSTRING_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/mbstring.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MBSTRING_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_MBSTRING_IPK_DIR)
	### now make php-mcrypt
	rm -rf $(PHP_MCRYPT_IPK_DIR) $(BUILD_DIR)/php-mcrypt_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MCRYPT_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_MCRYPT_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_MCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/mcrypt.so $(PHP_MCRYPT_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/mcrypt.so
	echo extension=mcrypt.so >$(PHP_MCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/mcrypt.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MCRYPT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_MCRYPT_IPK_DIR)
	### now make php-mysql
	rm -rf $(PHP_MYSQL_IPK_DIR) $(BUILD_DIR)/php-mysql_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MYSQL_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_MYSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/*mysql*.so $(PHP_MYSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=mysqli.so >$(PHP_MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/mysql.ini
	echo extension=pdo_mysql.so >>$(PHP_MYSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/mysql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MYSQL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_MYSQL_IPK_DIR)
	### now make php-pear
	rm -rf $(PHP_PEAR_IPK_DIR) $(BUILD_DIR)/php-pear_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_PEAR_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/postinst.pear $(PHP_PEAR_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/prerm.pear $(PHP_PEAR_IPK_DIR)/CONTROL/prerm
	$(INSTALL) -d $(PHP_PEAR_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/pear.conf $(PHP_PEAR_IPK_DIR)$(TARGET_PREFIX)/etc/pear.conf.new
	$(INSTALL) -d $(PHP_PEAR_IPK_DIR)$(TARGET_PREFIX)/etc/pearkeys
	$(INSTALL) -d $(PHP_PEAR_IPK_DIR)$(TARGET_PREFIX)/tmp
	cp -a $(PHP_BUILD_DIR)/pear $(PHP_PEAR_IPK_DIR)$(TARGET_PREFIX)/tmp
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_PEAR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_PEAR_IPK_DIR)
	### now make php-pgsql
	rm -rf $(PHP_PGSQL_IPK_DIR) $(BUILD_DIR)/php-pgsql_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_PGSQL_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_PGSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_PGSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/*pgsql*.so $(PHP_PGSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=pgsql.so >$(PHP_PGSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/pgsql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_PGSQL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_PGSQL_IPK_DIR)
	### now make php-mssql
	rm -rf $(PHP_MSSQL_IPK_DIR) $(BUILD_DIR)/php-mssql_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_MSSQL_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_MSSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_MSSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/mssql.so $(PHP_MSSQL_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=mssql.so >$(PHP_MSSQL_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/mssql.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_MSSQL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_MSSQL_IPK_DIR)
	### now make php-odbc
	rm -rf $(PHP_ODBC_IPK_DIR) $(BUILD_DIR)/php-odbc_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_ODBC_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_ODBC_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_ODBC_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/odbc.so $(PHP_ODBC_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=odbc.so >$(PHP_ODBC_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/odbc.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_ODBC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_ODBC_IPK_DIR)
	### now make php-snmp
	rm -rf $(PHP_SNMP_IPK_DIR) $(BUILD_DIR)/php-snmp_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_SNMP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/snmp.so $(PHP_SNMP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=snmp.so >$(PHP_SNMP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/snmp.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_SNMP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_SNMP_IPK_DIR)
	### now make php-xmlrpc
	rm -rf $(PHP_XMLRPC_IPK_DIR) $(BUILD_DIR)/php-xmlrpc_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_XMLRPC_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_XMLRPC_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_XMLRPC_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/xmlrpc.so $(PHP_XMLRPC_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=xmlrpc.so >$(PHP_XMLRPC_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/xmlrpc.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_XMLRPC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_XMLRPC_IPK_DIR)
	### now make php-zip
	rm -rf $(PHP_ZIP_IPK_DIR) $(BUILD_DIR)/php-zip_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PHP_ZIP_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PHP_ZIP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions
	$(INSTALL) -d $(PHP_ZIP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d
	mv $(PHP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/zip.so $(PHP_ZIP_IPK_DIR)$(TARGET_PREFIX)/lib/php/extensions/
	echo extension=zip.so >$(PHP_ZIP_IPK_DIR)$(TARGET_PREFIX)/etc/php.d/zip.ini
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_ZIP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_ZIP_IPK_DIR)
	### finally the main ipk
	rm -f $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin/phar
	ln -s phar.phar $(PHP_IPK_DIR)$(TARGET_PREFIX)/bin/phar
	$(MAKE) $(PHP_IPK_DIR)/CONTROL/control
	echo $(PHP_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PHP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-ipk: $(PHP_TARGET_IPKS)

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
	$(PHP_CURL_IPK_DIR) $(PHP_CURL_IPK) \
	$(PHP_GD_IPK_DIR) $(PHP_GD_IPK) \
	$(PHP_IMAP_IPK_DIR) $(PHP_IMAP_IPK) \
	$(PHP_MBSTRING_IPK_DIR) $(PHP_MBSTRING_IPK) \
	$(PHP_MSSQL_IPK_DIR) $(PHP_MSSQL_IPK) \
	$(PHP_MYSQL_IPK_DIR) $(PHP_MYSQL_IPK) \
	$(PHP_PEAR_IPK_DIR) $(PHP_PEAR_IPK) \
	$(PHP_PGSQL_IPK_DIR) $(PHP_PGSQL_IPK) \
	$(PHP_ODBC_IPK_DIR) $(PHP_ODBC_IPK) \
	;
ifeq (, $(filter --without-iconv, $(PHP_CONFIGURE_ARGS)))
	rm -rf $(PHP_ICONV_IPK_DIR) $(PHP_ICONV_IPK)
endif
ifeq (openldap, $(filter openldap, $(PACKAGES)))
	rm -rf $(PHP_LDAP_IPK_DIR) $(PHP_LDAP_IPK)
endif


#
# Some sanity check for the package.
#
php-check: $(PHP_TARGET_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
endif
