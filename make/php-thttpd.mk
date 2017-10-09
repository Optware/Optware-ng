###########################################################
#
# php-thttpd
#
###########################################################

# You must replace "php-thttpd" and "PHP_THTTPD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PHP_THTTPD_VERSION, PHP_THTTPD_SITE and PHP_THTTPD_SOURCE define
# the upstream location of the source code for the package.
# PHP_THTTPD_DIR is the directory which is created when the source
# archive is unpacked.
# PHP_THTTPD_UNZIP is the command used to unzip the source.
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
PHP_THTTPD_SITE=$(THTTPD_SITE)
PHP_THTTPD_VERSION:=2.21b
PHP_THTTPD_SOURCE:=thttpd-$(PHP_THTTPD_VERSION).tar.gz
PHP_THTTPD_DIR=thttpd-$(PHP_THTTPD_VERSION)
PHP_THTTPD_UNZIP=zcat
PHP_THTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_THTTPD_DESCRIPTION=php-thttpd is thttpd webserver with php support
PHP_THTTPD_SECTION=net
PHP_THTTPD_PRIORITY=optional
PHP_THTTPD_DEPENDS=php, libxml2
PHP_THTTPD_CONFLICTS=thttpd

PHP_THTTPD_LIBPHP_SITE=$(PHP_SITE)
PHP_THTTPD_LIBPHP_VERSION:=$(shell cat make/php.mk | sed -n -e 's/^PHP_VERSION *=//p')
PHP_THTTPD_LIBPHP_SOURCE:=$(shell cat make/php.mk | sed -n -e 's/^PHP_SOURCE *=//p' | sed -n -e "s|..PHP_VERSION.|${PHP_THTTPD_LIBPHP_VERSION}|p")
PHP_THTTPD_LIBPHP_DIR=$(PHP_DIR)
PHP_THTTPD_LIBPHP_UNZIP=$(PHP_UNZIP)

#
# PHP_THTTPD_IPK_VERSION should be incremented when the ipk changes.
#
PHP_THTTPD_IPK_VERSION=5

#
# PHP_THTTPD_CONFFILES should be a list of user-editable files
PHP_THTTPD_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S80thttpd $(TARGET_PREFIX)/etc/thttpd.conf 

#
# PHP_THTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PHP_THTTPD_LIBPHP_PATCHES=$(PHP_THTTPD_SOURCE_DIR)/php-5.0.3.patch $(PHP_THTTPD_SOURCE_DIR)/config.m4.patch $(PHP_THTTPD_SOURCE_DIR)/thttpd.c.patch $(PHP_THTTPD_SOURCE_DIR)/zts-without-threaded-thttpd.patch
PHP_THTTPD_PATCHES=$(PHP_THTTPD_SOURCE_DIR)/zts-without-threaded-thttpd.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHP_THTTPD_LIBPHP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2
PHP_THTTPD_LIBPHP_LDFLAGS=-ldl -lpthread
#
# PHP_THTTPD_BUILD_DIR is the directory in which the build is done.
# PHP_THTTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHP_THTTPD_IPK_DIR is the directory in which the ipk is built.
# PHP_THTTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHP_THTTPD_BUILD_DIR=$(BUILD_DIR)/php-thttpd
PHP_THTTPD_SOURCE_DIR=$(SOURCE_DIR)/php-thttpd
PHP_THTTPD_IPK_DIR=$(BUILD_DIR)/php-thttpd-$(PHP_THTTPD_VERSION)-ipk
PHP_THTTPD_IPK=$(BUILD_DIR)/php-thttpd_$(PHP_THTTPD_VERSION)-$(PHP_THTTPD_LIBPHP_VERSION)-$(PHP_THTTPD_IPK_VERSION)_$(TARGET_ARCH).ipk
PHP_THTTPD_LIBPHP_BUILD_DIR=$(PHP_THTTPD_BUILD_DIR)/_libphp

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifneq ($(PHP_THTTPD_VERSION), $(THTTPD_VERSION))
$(DL_DIR)/$(PHP_THTTPD_SOURCE):
	$(WGET) -P $(@D) $(PHP_THTTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
php-thttpd-source: $(DL_DIR)/$(PHP_THTTPD_SOURCE) $(DL_DIR)/$(PHP_THTTPD_LIBPHP_SOURCE) $(PHP_THTTPD_PATCHES) $(PHP_THTTPD_LIBPHP_PATCHES) $(PHP_PATCHES)

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

$(PHP_THTTPD_LIBPHP_BUILD_DIR)/.configured: $(PHP_HOST_CLI) $(DL_DIR)/$(PHP_THTTPD_SOURCE) $(PHP_THTTPD_LIBPHP_PATCHES) $(PHP_PATCHES) make/php-thttpd.mk
	$(MAKE) php-source bzip2-stage gdbm-stage libcurl-stage libdb-stage libgd-stage libxml2-stage \
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
	rm -rf $(BUILD_DIR)/$(PHP_DIR) $(BUILD_DIR)/$(THTTPD_DIR) $(PHP_THTTPD_BUILD_DIR)
	$(PHP_THTTPD_UNZIP) $(DL_DIR)/$(PHP_THTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(PHP_UNZIP) $(DL_DIR)/$(PHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PHP_PATCHES)"; \
	    then cat $(PHP_PATCHES) | $(PATCH) -p0 -bd $(BUILD_DIR)/$(PHP_DIR); \
	fi
	if test -n "$(PHP_THTTPD_LIBPHP_PATCHES)"; \
	    then cat $(PHP_THTTPD_LIBPHP_PATCHES) | $(PATCH) -p1 -bd $(BUILD_DIR)/$(PHP_DIR); \
	fi
	mv $(BUILD_DIR)/$(PHP_THTTPD_DIR) $(PHP_THTTPD_BUILD_DIR)
	mv $(BUILD_DIR)/$(PHP_DIR) $(@D)
	find $(PHP_THTTPD_BUILD_DIR) -type f -not -path "$(@D)/*" -exec chmod +w {} \;
	find $(PHP_THTTPD_BUILD_DIR) -type f -name '*.[ch]' -not -path "$(@D)/*" -exec sed -i -e 's/getline/&_local/g' {} \;
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
		--with-thttpd=$(PHP_THTTPD_BUILD_DIR) \
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

$(PHP_THTTPD_BUILD_DIR)/.configured: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built $(PHP_THTTPD_PATCHES)
	rm -f $(@D)/php_thttpd.c
	cp $(PHP_THTTPD_LIBPHP_BUILD_DIR)/sapi/thttpd/thttpd.c $(@D)/php_thttpd.c
	cat $(PHP_THTTPD_PATCHES) | $(PATCH) -d $(@D) -p1
	sed -i -e "s/#define CGI_TIMELIMIT .*/#define CGI_TIMELIMIT 600/" \
		-e "s/#define IDLE_READ_TIMELIMIT .*/#define IDLE_READ_TIMELIMIT 120/" \
		-e "/#define STATS_TIME/s/^/#ifdef notdef\n/" -e "/#define STATS_TIME/s/$$/#\n#endif/" $(@D)/config.h
ifeq ($(LIBC_STYLE), uclibc)
	sed -i -e '/assert.*IOV_MAX/s|^|//|' $(@D)/php_thttpd.c
endif
	rm -f $(@D)/config.cache
	(cd $(PHP_THTTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
	)
	sed -i -e "s/-o bin -g bin//g" -e \
		"s/WEBDIR=/WEBDIR=\$$(DESTDIR)/" -e \
		"s/CGIBINDIR=/CGIBINDIR=\$$(DESTDIR)/" -e \
		"s/MANDIR=/MANDIR=\$$(DESTDIR)/" -e \
		"s/WEBGROUP=/WEBGROUP=\$$(DESTDIR)/" -e \
		"s|MANDIR = .*|MANDIR = \$${prefix}/share/man|" -e\
		"s|WEBDIR = .*|WEBDIR = \$${prefix}/share/www|" $(@D)/Makefile
	sed -i -e "s|^prefix =.*|prefix =	\$$(DESTDIR)$(TARGET_PREFIX)|" -e\
		"/chgrp/s/^/#/" $(@D)/extras/Makefile
	touch $@

php-thttpd-unpack: $(PHP_THTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	sed -i -e "s/conection/connection/g" $(PHP_THTTPD_BUILD_DIR)/thttpd.c
	$(MAKE) -C $(@D) INSTALL_ROOT=$(STAGING_DIR) install-sapi
	touch $@

$(PHP_THTTPD_BUILD_DIR)/.built: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built $(PHP_THTTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) -j1 PHP_LIBS="libphp5.a -lxml2 -lcrypt -lm" CCOPT="-I$(@D)/_libphp/TSRM -I$(@D)/_libphp/Zend -include $(@D)/_libphp/Zend/zend.h"
	touch $@

#
# This is the build convenience target.
#
php-thttpd: $(PHP_THTTPD_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/php-thttpd
#
$(PHP_THTTPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PHP_THTTPD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: php-thttpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHP_THTTPD_PRIORITY)" >>$@
	@echo "Section: $(PHP_THTTPD_SECTION)" >>$@
	@echo "Version: $(PHP_THTTPD_VERSION)-$(PHP_THTTPD_LIBPHP_VERSION)-$(PHP_THTTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHP_THTTPD_MAINTAINER)" >>$@
	@echo "Source: $(PHP_THTTPD_SITE)/$(PHP_THTTPD_SOURCE)" >>$@
	@echo "Description: $(PHP_THTTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(PHP_THTTPD_DEPENDS)" >>$@
	@echo "Conflicts: $(PHP_THTTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/php-thttpd/...
# Documentation files should be installed in $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/doc/php-thttpd/...
# Daemon startup scripts should be installed in $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??php-thttpd
#
# You may need to patch your application to make it use these locations.
#
$(PHP_THTTPD_IPK): $(PHP_THTTPD_BUILD_DIR)/.built
	rm -rf $(PHP_THTTPD_IPK_DIR) $(BUILD_DIR)/php-thttpd_*_$(TARGET_ARCH).ipk
	mkdir -p $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/share/man/man1 $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/share/man/man8 $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/share/www
	$(MAKE) -C $(PHP_THTTPD_BUILD_DIR) DESTDIR=$(PHP_THTTPD_IPK_DIR) install -j1
	chmod u+rw $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/thttpd
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/makeweb
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/htpasswd
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/share/www/cgi-bin/*
	mv $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/htpasswd $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/sbin/php-thttpd-htpasswd
	$(INSTALL) -d $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/var/run/
	$(INSTALL) -d $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/var/log/
	$(INSTALL) -d $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/
	#$(INSTALL) -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/php.ini
	#sed -i  -e 's/extension=dom.so/; extension=dom.so/' $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/php.ini
	$(INSTALL) -m 644 $(PHP_THTTPD_SOURCE_DIR)/thttpd.conf $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/thttpd.conf
	$(INSTALL) -d $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(PHP_THTTPD_SOURCE_DIR)/rc.thttpd $(PHP_THTTPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S80thttpd
	$(MAKE) $(PHP_THTTPD_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(PHP_THTTPD_SOURCE_DIR)/postinst $(PHP_THTTPD_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(PHP_THTTPD_SOURCE_DIR)/prerm $(PHP_THTTPD_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PHP_THTTPD_IPK_DIR)/CONTROL/postinst $(PHP_THTTPD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PHP_THTTPD_CONFFILES) | sed -e 's/ /\n/g' > $(PHP_THTTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHP_THTTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
php-thttpd-ipk: $(PHP_THTTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
php-thttpd-clean:
	-$(MAKE) -C $(PHP_THTTPD_LIBPHP_BUILD_DIR) clean
	-$(MAKE) -C $(PHP_THTTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
php-thttpd-dirclean:
	-rm -rf $(PHP_THTTPD_BUILD_DIR) $(PHP_THTTPD_LIBPHP_BUILD_DIR) $(PHP_THTTPD_IPK_DIR) $(PHP_THTTPD_IPK)
#
#
# Some sanity check for the package.
#
php-thttpd-check: $(PHP_THTTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
