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
PHP_THTTPD_VERSION:=$(shell cat make/thttpd.mk | sed -n -e 's/^THTTPD_VERSION *=//p')
PHP_THTTPD_SOURCE:=$(shell cat make/thttpd.mk | sed -n -e 's/^THTTPD_SOURCE *=//p' | sed -n -e "s|..THTTPD_VERSION.|${PHP_THTTPD_VERSION}|p")
PHP_THTTPD_DIR=$(THTTPD_DIR)
PHP_THTTPD_UNZIP=$(THTTPD_UNZIP)
PHP_THTTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHP_THTTPD_DESCRIPTION=php-thttpd is thttpd webserver with php support
PHP_THTTPD_SECTION=net
PHP_THTTPD_PRIORITY=optional
PHP_THTTPD_DEPENDS=php (>= 5.0.3-8), libxml2
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
PHP_THTTPD_CONFFILES=/opt/etc/init.d/S80thttpd /opt/etc/thttpd.conf 

#
# PHP_THTTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PHP_THTTPD_LIBPHP_PATCHES=$(PHP_THTTPD_SOURCE_DIR)/php-5.0.3.patch $(PHP_THTTPD_SOURCE_DIR)/config.m4.patch $(PHP_THTTPD_SOURCE_DIR)/thttpd.c.patch $(PHP_THTTPD_SOURCE_DIR)/zts-without-threaded-thttpd.patch
PHP_THTTPD_PATCHES=$(THTTPD_PATCHES)

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

$(PHP_THTTPD_LIBPHP_BUILD_DIR)/.configured: $(DL_DIR)/$(PHP_THTTPD_SOURCE) $(DL_DIR)/$(PHP_THTTPD_LIBPHP_SOURCE) $(PHP_THTTPD_LIBPHP_PATCHES) $(PHP_PATCHES)
	$(MAKE) libxml2-stage
	rm -rf $(BUILD_DIR)/$(PHP_THTTPD_DIR) $(BUILD_DIR)/$(PHP_THTTPD_LIBPHP_DIR)
	rm -rf $(PHP_THTTPD_BUILD_DIR) $(PHP_THTTPD_LIBPHP_BUILD_DIR)
	$(PHP_THTTPD_UNZIP) $(DL_DIR)/$(PHP_THTTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	$(PHP_THTTPD_LIBPHP_UNZIP) $(DL_DIR)/$(PHP_THTTPD_LIBPHP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PHP_PATCHES) | patch -d $(BUILD_DIR)/$(PHP_THTTPD_LIBPHP_DIR) -p0
	cat $(PHP_THTTPD_LIBPHP_PATCHES) | patch -d $(BUILD_DIR)/$(PHP_THTTPD_LIBPHP_DIR) -p1 
	mv $(BUILD_DIR)/$(PHP_THTTPD_DIR) $(PHP_THTTPD_BUILD_DIR)
	mv $(BUILD_DIR)/$(PHP_THTTPD_LIBPHP_DIR) $(PHP_THTTPD_LIBPHP_BUILD_DIR)
	(cd $(PHP_THTTPD_LIBPHP_BUILD_DIR); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PHP_THTTPD_LIBPHP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(STAGING_LDFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		PHP_LIBXML_DIR=$(STAGING_PREFIX) \
		EXTENSION_DIR=/opt/lib/php/extensions \
		ac_cv_func_memcmp_working=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-config-file-scan-dir=/opt/etc/php.d \
		--with-layout=GNU \
		$(PHP_CONFIGURE_THREAD_ARGS) \
		--disable-static \
		--disable-dom \
		--disable-xml \
		--enable-libxml \
		--with-thttpd=$(PHP_THTTPD_BUILD_DIR) \
		--without-pear \
		--without-iconv \
		--disable-cli \
	)
	touch $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.configured

$(PHP_THTTPD_BUILD_DIR)/.configured: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built $(PHP_THTTPD_PATCHES)
	cat $(PHP_THTTPD_PATCHES) | patch -d $(PHP_THTTPD_BUILD_DIR) -p1
ifeq ($(LIBC_STYLE), uclibc)
	sed -i -e '/assert.*IOV_MAX/s|^|//|' $(PHP_THTTPD_BUILD_DIR)/php_thttpd.c
endif
	(cd $(PHP_THTTPD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) $(PHP_THTTPD_LIBPHP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(PHP_THTTPD_BUILD_DIR)/.configured

php-thttpd-unpack: $(PHP_THTTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.configured
	rm -f $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_THTTPD_LIBPHP_BUILD_DIR)
	$(MAKE) -C $(PHP_THTTPD_LIBPHP_BUILD_DIR) INSTALL_ROOT=$(STAGING_DIR) install-sapi
	touch $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built

$(PHP_THTTPD_BUILD_DIR)/.built: $(PHP_THTTPD_LIBPHP_BUILD_DIR)/.built $(PHP_THTTPD_BUILD_DIR)/.configured
	rm -f $(PHP_THTTPD_BUILD_DIR)/.built
	$(MAKE) -C $(PHP_THTTPD_BUILD_DIR) PHP_LIBS="libphp5.a -lxml2 -lcrypt -lm"
	touch $(PHP_THTTPD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
php-thttpd: $(PHP_THTTPD_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/php-thttpd
#
$(PHP_THTTPD_IPK_DIR)/CONTROL/control:
	@install -d $(PHP_THTTPD_IPK_DIR)/CONTROL
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
# Binaries should be installed into $(PHP_THTTPD_IPK_DIR)/opt/sbin or $(PHP_THTTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHP_THTTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHP_THTTPD_IPK_DIR)/opt/etc/php-thttpd/...
# Documentation files should be installed in $(PHP_THTTPD_IPK_DIR)/opt/doc/php-thttpd/...
# Daemon startup scripts should be installed in $(PHP_THTTPD_IPK_DIR)/opt/etc/init.d/S??php-thttpd
#
# You may need to patch your application to make it use these locations.
#
$(PHP_THTTPD_IPK): $(PHP_THTTPD_BUILD_DIR)/.built
	rm -rf $(PHP_THTTPD_IPK_DIR) $(BUILD_DIR)/php-thttpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PHP_THTTPD_BUILD_DIR) DESTDIR=$(PHP_THTTPD_IPK_DIR) install
	chmod u+rw $(PHP_THTTPD_IPK_DIR)/opt/sbin/*
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)/opt/sbin/thttpd
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)/opt/sbin/makeweb
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)/opt/sbin/htpasswd
	$(STRIP_COMMAND) $(PHP_THTTPD_IPK_DIR)/opt/share/www/cgi-bin/*
	mv $(PHP_THTTPD_IPK_DIR)/opt/sbin/htpasswd $(PHP_THTTPD_IPK_DIR)/opt/sbin/php-thttpd-htpasswd
	install -d $(PHP_THTTPD_IPK_DIR)/opt/var/run/
	install -d $(PHP_THTTPD_IPK_DIR)/opt/var/log/
	install -d $(PHP_THTTPD_IPK_DIR)/opt/etc/
	#install -m 644 $(PHP_SOURCE_DIR)/php.ini $(PHP_THTTPD_IPK_DIR)/opt/etc/php.ini
	#sed -i  -e 's/extension=dom.so/; extension=dom.so/' $(PHP_THTTPD_IPK_DIR)/opt/etc/php.ini
	install -m 644 $(PHP_THTTPD_SOURCE_DIR)/thttpd.conf $(PHP_THTTPD_IPK_DIR)/opt/etc/thttpd.conf
	install -d $(PHP_THTTPD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PHP_THTTPD_SOURCE_DIR)/rc.thttpd $(PHP_THTTPD_IPK_DIR)/opt/etc/init.d/S80thttpd
	$(MAKE) $(PHP_THTTPD_IPK_DIR)/CONTROL/control
	install -m 755 $(PHP_THTTPD_SOURCE_DIR)/postinst $(PHP_THTTPD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(PHP_THTTPD_SOURCE_DIR)/prerm $(PHP_THTTPD_IPK_DIR)/CONTROL/prerm
	if test "/opt" = "$(IPKG_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(IPKG_PREFIX)/bin/&|' \
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
