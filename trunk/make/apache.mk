###########################################################
#
# apache
#
###########################################################
#
# $id$
#
# APACHE_VERSION, APACHE_SITE and APACHE_SOURCE define
# the upstream location of the source code for the package.
# APACHE_DIR is the directory which is created when the source
# archive is unpacked.
# APACHE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
APACHE_SITE=http://www.apache.org/dist/httpd
APACHE_VERSION=2.2.8
APACHE_SOURCE=httpd-$(APACHE_VERSION).tar.bz2
APACHE_DIR=httpd-$(APACHE_VERSION)
APACHE_UNZIP=bzcat
APACHE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
APACHE_DESCRIPTION=The most popular web server on the internet
APACHE_SECTION=lib
APACHE_PRIORITY=optional
APACHE_DEPENDS=apr (>= $(APR_VERSION)), apr-util (>= $(APR_UTIL_VERSION)), \
	e2fsprogs, expat, openssl, zlib $(APACHE_TARGET_DEPENDS)

APACHE_MPM=worker
#APACHE_MPM=prefork

#
# APACHE_IPK_VERSION should be incremented when the ipk changes.
#
APACHE_IPK_VERSION=1

#
# APACHE_CONFFILES should be a list of user-editable files
#
APACHE_CONFFILES=/opt/etc/apache2/httpd.conf \
		/opt/etc/apache2/extra/httpd-ssl.conf \
		/opt/etc/init.d/S80apache

#
# APACHE_LOCALES defines which locales get installed
#
APACHE_LOCALES=

#
# APACHE_CONFFILES should be a list of user-editable files
#APACHE_CONFFILES=/opt/etc/apache.conf /opt/etc/init.d/SXXapache

#
# APACHE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
APACHE_PATCHES=$(APACHE_SOURCE_DIR)/hostcc.patch \
		$(APACHE_SOURCE_DIR)/hostcc-pcre.patch \
		$(APACHE_SOURCE_DIR)/apxs.patch \
		$(APACHE_SOURCE_DIR)/ulimit.patch
# if the platform does not have a daemon user and group, use nobody/-1
ifneq ($(OPTWARE_TARGET), $(filter slugosbe slugosle, $(OPTWARE_TARGET)))
APACHE_PATCHES += $(APACHE_SOURCE_DIR)/httpd-conf-in.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APACHE_CPPFLAGS=
APACHE_LDFLAGS=

# We need this because openldap does not build on some platforms.
ifeq (openldap, $(filter openldap, $(PACKAGES)))
APACHE_CONFIGURE_TARGET_ARGS= \
		--enable-ldap \
		--enable-auth-ldap
APACHE_TARGET_DEPENDS=,openldap-libs
else
APACHE_CONFIGURE_TARGET_ARGS=
APACHE_TARGET_DEPENDS=
endif

#
# APACHE_BUILD_DIR is the directory in which the build is done.
# APACHE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APACHE_IPK_DIR is the directory in which the ipk is built.
# APACHE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APACHE_BUILD_DIR=$(BUILD_DIR)/apache
APACHE_SOURCE_DIR=$(SOURCE_DIR)/apache
APACHE_IPK_DIR=$(BUILD_DIR)/apache-$(APACHE_VERSION)-ipk
APACHE_IPK=$(BUILD_DIR)/apache_$(APACHE_VERSION)-$(APACHE_IPK_VERSION)_$(TARGET_ARCH).ipk
APACHE_MANUAL_IPK_DIR=$(BUILD_DIR)/apache-manual-$(APACHE_VERSION)-ipk
APACHE_MANUAL_IPK=$(BUILD_DIR)/apache-manual_$(APACHE_VERSION)-$(APACHE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: apache-source apache-unpack apache apache-stage apache-ipk apache-clean apache-dirclean apache-check

#
# Automatically create a ipkg control file
#
$(APACHE_IPK_DIR)/CONTROL/control:
	@install -d $(APACHE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: apache" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APACHE_PRIORITY)" >>$@
	@echo "Section: $(APACHE_SECTION)" >>$@
	@echo "Version: $(APACHE_VERSION)-$(APACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APACHE_MAINTAINER)" >>$@
	@echo "Source: $(APACHE_SITE)/$(APACHE_SOURCE)" >>$@
	@echo "Description: $(APACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(APACHE_DEPENDS)" >>$@

$(APACHE_MANUAL_IPK_DIR)/CONTROL/control:
	@install -d $(APACHE_MANUAL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: apache-manual" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APACHE_PRIORITY)" >>$@
	@echo "Section: $(APACHE_SECTION)" >>$@
	@echo "Version: $(APACHE_VERSION)-$(APACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APACHE_MAINTAINER)" >>$@
	@echo "Source: $(APACHE_SITE)/$(APACHE_SOURCE)" >>$@
	@echo "Description: Online documentation for the apache webserver" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(APACHE_SOURCE):
	$(WGET) -P $(DL_DIR) $(APACHE_SITE)/$(APACHE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
apache-source: $(DL_DIR)/$(APACHE_SOURCE) $(APACHE_PATCHES)

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
$(APACHE_BUILD_DIR)/.configured: $(DL_DIR)/$(APACHE_SOURCE) $(APACHE_PATCHES) make/apache.mk
	if test -d $(STAGING_INCLUDE_DIR)/apache2; then \
		cd $(STAGING_INCLUDE_DIR)/apache2/ && rm -f `ls | egrep -v '^apr|^apu'`; \
	fi
	$(MAKE) zlib-stage
	$(MAKE) e2fsprogs-stage
	$(MAKE) expat-stage
	$(MAKE) openssl-stage
	$(MAKE) apr-util-stage
	rm -rf $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR)
	$(APACHE_UNZIP) $(DL_DIR)/$(APACHE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR)
	cat $(APACHE_PATCHES) |patch -p0 -d $(APACHE_BUILD_DIR)
	sed -i -e "s% *installbuilddir: .*% installbuilddir: $(STAGING_DIR)/opt/share/apache2/build%" \
		-e 's%[ \t]\{1,\}prefix: .*%    prefix: /opt%' \
		-e "s% *htdocsdir: .*% htdocsdir: /opt/share/www%" \
		$(APACHE_BUILD_DIR)/config.layout
	#cp $(APACHE_SOURCE_DIR)/httpd-std.conf.in $(APACHE_BUILD_DIR)/docs/conf
	(cd $(APACHE_BUILD_DIR); \
		autoconf ; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APACHE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ap_void_ptr_lt_long=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-layout=GNU \
		--with-mpm=$(APACHE_MPM) \
		--enable-mods-shared=all \
		--enable-ssl \
		--enable-proxy \
		--enable-cache \
		--enable-disk-cache \
		--enable-file-cache \
		--enable-mem-cache \
		--enable-deflate \
		$(APACHE_CONFIGURE_TARGET_ARGS) \
		--with-z=$(STAGING_DIR)/opt \
		--with-ssl=$(STAGING_DIR)/opt \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr-util=$(STAGING_DIR)/opt \
		--with-expat=/opt \
		--with-port=8000 \
	)
	touch $@

apache-unpack: $(APACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(APACHE_BUILD_DIR)/.built: $(APACHE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(APACHE_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
apache: $(APACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(APACHE_BUILD_DIR)/.staged: $(APACHE_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_PREFIX)/libexec/mod_*.so
	$(MAKE) -C $(APACHE_BUILD_DIR) install installbuilddir=/opt/share/apache2/build DESTDIR=$(STAGING_DIR)
	sed -i -e 's!includedir = .*!includedir = $(STAGING_DIR)/opt/include/apache2!' $(STAGING_PREFIX)/share/apache2/build/config_vars.mk
	touch $@

apache-stage: $(APACHE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(APACHE_IPK_DIR)/opt/sbin or $(APACHE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APACHE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APACHE_IPK_DIR)/opt/etc/apache/...
# Documentation files should be installed in $(APACHE_IPK_DIR)/opt/doc/apache/...
# Daemon startup scripts should be installed in $(APACHE_IPK_DIR)/opt/etc/init.d/S??apache
#
# You may need to patch your application to make it use these locations.
#
$(APACHE_IPK) $(APACHE_MANUAL_IPK): $(APACHE_BUILD_DIR)/.built
	rm -rf $(APACHE_IPK_DIR) $(BUILD_DIR)/apache_*_$(TARGET_ARCH).ipk $(APACHE_MANUAL_IPK_DIR) $(BUILD_DIR)/apache-manual_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(APACHE_BUILD_DIR) DESTDIR=$(APACHE_IPK_DIR) installbuilddir=/opt/share/apache2/build install
	rm -rf $(APACHE_IPK_DIR)/opt/share/apache2/manual
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/libexec/*.so
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/ab
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/checkgid
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htcacheclean
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htdbm
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htdigest
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htpasswd
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/httxt2dbm
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/httpd
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/logresolve
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/rotatelogs
	mv $(APACHE_IPK_DIR)/opt/sbin/httpd $(APACHE_IPK_DIR)/opt/sbin/apache-httpd
	mv $(APACHE_IPK_DIR)/opt/sbin/htpasswd $(APACHE_IPK_DIR)/opt/sbin/apache-htpasswd
	rm -f $(APACHE_IPK_DIR)/opt/man/man1/htpasswd.1
	sed -i -e "s%$(STAGING_DIR)%%" $(APACHE_IPK_DIR)/opt/sbin/apxs
	sed -i -e "s%^#!.*perl%#!/opt/bin/perl%" $(APACHE_IPK_DIR)/opt/sbin/apxs
	sed -i -e "s%^#!.*perl%#!/opt/bin/perl%" $(APACHE_IPK_DIR)/opt/sbin/dbmmanage
	install -d $(APACHE_IPK_DIR)/opt/etc/apache2/conf.d
	install -d $(APACHE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(APACHE_SOURCE_DIR)/rc.apache $(APACHE_IPK_DIR)/opt/etc/init.d/S80apache
	$(MAKE) $(APACHE_IPK_DIR)/CONTROL/control
	install -m 755 $(APACHE_SOURCE_DIR)/prerm $(APACHE_IPK_DIR)/CONTROL/prerm
	install -m 755 $(APACHE_SOURCE_DIR)/postinst $(APACHE_IPK_DIR)/CONTROL/postinst
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(APACHE_IPK_DIR)/CONTROL/postinst $(APACHE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(APACHE_CONFFILES) | sed -e 's/ /\n/g' > $(APACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APACHE_IPK_DIR)
	$(MAKE) -C $(APACHE_BUILD_DIR) DESTDIR=$(APACHE_MANUAL_IPK_DIR) installbuilddir=/opt/share/apache2/build install-man
	rm -rf $(APACHE_MANUAL_IPK_DIR)/opt/man
	$(MAKE) $(APACHE_MANUAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APACHE_MANUAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
apache-ipk: $(APACHE_IPK) $(APACHE_MANUAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
apache-clean:
	-$(MAKE) -C $(APACHE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
apache-dirclean:
	rm -rf $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR) $(APACHE_IPK_DIR) $(APACHE_IPK) $(APACHE_MANUAL_IPK_DIR) $(APACHE_MANUAL_IPK)

#
# Some sanity check for the package.
#
apache-check: $(APACHE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(APACHE_IPK) $(APACHE_MANUAL_IPK)
