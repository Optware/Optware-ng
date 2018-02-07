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
PHP_APACHE_DEPENDS=apache, php, libxml2, sqlite
ifeq (openldap, $(filter openldap, $(PACKAGES)))
PHP_APACHE_DEPENDS+=, cyrus-sasl-libs
endif

include make/php.mk
PHP_APACHE_VERSION=$(PHP_VERSION)

#
# PHP_APACHE_IPK_VERSION should be incremented when the ipk changes.
#
PHP_APACHE_IPK_VERSION=1

#
# PHP_APACHE_CONFFILES should be a list of user-editable files
#
PHP_APACHE_CONFFILES=$(TARGET_PREFIX)/etc/apache2/conf.d/php.conf

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
PHP_APACHE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/apache2 -I$(STAGING_INCLUDE_DIR)/libxml2 -I$(STAGING_INCLUDE_DIR)/libxslt \
			-I$(STAGING_INCLUDE_DIR)/libexslt -I$(STAGING_INCLUDE_DIR)/freetype2
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
	@$(INSTALL) -d $(@D)
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
$(PHP_APACHE_BUILD_DIR)/.configured: $(PHP_HOST_CLI) $(PHP_APACHE_PATCHES) make/php-apache.mk
	$(MAKE) php-source apache-stage bzip2-stage gdbm-stage libcurl-stage libdb-stage libgd-stage libxml2-stage \
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

	echo 'AC_CONFIG_MACRO_DIR([m4])' >> $(@D)/configure.in

	(cd $(HOST_STAGING_PREFIX)/share/aclocal; \
		cat libtool.m4 ltoptions.m4 ltversion.m4 ltsugar.m4 \
			lt~obsolete.m4 >> $(@D)/aclocal.m4 \
	)

	$(AUTORECONF1.10) -vif $(@D)
	sed -i -e 's/as_fn_error \$$? "cannot run test program while cross compiling/\$$as_echo \$$? "cannot run test program while cross compiling/' \
		-e 's|flock_type=unknown|flock_type=linux\n\$$as_echo "#define HAVE_FLOCK_LINUX /\*\*/" >>confdefs\.h|' \
		-e 's|icu_install_prefix=.*|icu_install_prefix=$(STAGING_PREFIX)|' \
		-e 's/APACHE_THREADED_MPM=.*/APACHE_THREADED_MPM="yes"/' \
		-e 's/APACHE_VERSION=.*/APACHE_VERSION=$(shell expr `echo "$(APACHE_VERSION)"|cut -d '.' -f 1` \* 1000000 + `echo "$(APACHE_VERSION)"|cut -d '.' -f 2` \* 1000 + `echo "$(APACHE_VERSION)"|cut -d '.' -f 3`)/' \
		-e 's/GCC_MAJOR_VERSION=.*/GCC_MAJOR_VERSION=$(shell $(TARGET_CC) -dumpversion|cut -d '.' -f 1)/' $(@D)/configure

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
		--enable-maintainer-zts \
		--disable-cgi \
		--disable-cli \
		--enable-bcmath=shared \
		--enable-calendar=shared \
		--enable-dba=shared \
		--with-inifile \
		--with-flatfile \
		--enable-dom=shared \
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
		--with-apxs2=$(STAGING_PREFIX)/bin/apxs \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool

	echo "#define HAVE_DLOPEN 1" >> $(@D)/main/php_config.h
	echo "#define HAVE_LIBDL 1" >> $(@D)/main/php_config.h

	sed -i -e '/#define HAVE_GD_XPM/s|^|//|' \
		-e '/#define HAVE_ATOMIC_H/s|^|//|' $(@D)/main/php_config.h

	sed -i -e 's|\$$(top_builddir)/\$$(SAPI_CLI_PATH)|$(PHP_HOST_CLI)|' \
		-e 's|-Wl,-rpath,$(STAGING_DIR)/lib|-Wl,-rpath,$(TARGET_PREFIX)/lib|g' \
		-e 's/###      or --detect-prefix//' \
		-e 's|INTL_SHARED_LIBADD =.*|INTL_SHARED_LIBADD = -L$(STAGING_LIB_DIR) -licuuc -licui18n -licuio|' $(@D)/Makefile

	touch $@

php-apache-unpack: $(PHP_APACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(PHP_APACHE_BUILD_DIR)/.built: $(PHP_APACHE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

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
	$(MAKE) -C $(@D) install-strip prefix=$(STAGING_PREFIX)
	touch $@

php-apache-stage: $(PHP_APACHE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/etc/php/...
# Documentation files should be installed in $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/doc/php/...
# Daemon startup scripts should be installed in $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php
#
# You may need to patch your application to make it use these locations.
#
$(PHP_APACHE_IPK): $(PHP_APACHE_BUILD_DIR)/.built
	rm -rf $(PHP_APACHE_IPK_DIR) $(BUILD_DIR)/php-apache_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/etc/apache2/conf.d
	$(INSTALL) -m 644 $(PHP_APACHE_SOURCE_DIR)/php.conf $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/etc/apache2/conf.d/php.conf
	$(INSTALL) -d $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/libexec
	$(INSTALL) -m 755 $(PHP_APACHE_BUILD_DIR)/libs/libphp5.so $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/libexec/libphp5.so
	$(STRIP_COMMAND) $(PHP_APACHE_IPK_DIR)$(TARGET_PREFIX)/libexec/libphp5.so
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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
