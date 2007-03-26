###########################################################
#
# appweb
#
###########################################################
#
# $Header$

# You must replace "appweb" and "APPWEB-PHP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# APPWEB_VERSION, APPWEB_SITE and APPWEB_SOURCE define
# the upstream location of the source code for the package.
# APPWEB_DIR is the directory which is created when the source
# archive is unpacked.
# APPWEB_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
APPWEB_SITE=http://www.appwebserver.org/software
APPWEB_VERSION=2.1.0
APPWEB_VERSION_EXTRA=2
APPWEB_SOURCE=appWeb-src-$(APPWEB_VERSION)-$(APPWEB_VERSION_EXTRA).tar.gz
APPWEB_DIR=appWeb-$(APPWEB_VERSION)
APPWEB_UNZIP=zcat
APPWEB_MAINTAINER=Matt McNeill <matt_mcneill@hotmail.com>
APPWEB_DESCRIPTION=AppWeb is the leading web server technology for embedding in devices and applications. Supports embedded javascript, CGI, Virtual Sites, SSL, user passwords, virtual directories - all with minimal memory footprint.
APPWEB_SECTION=net
APPWEB_PRIORITY=optional
APPWEB_DEPENDS=openssl, php-embed
APPWEB_CONFLICTS=

#
# APPWEB_IPK_VERSION should be incremented when the ipk changes.
#
APPWEB_IPK_VERSION=1

#
# APPWEB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
APPWEB_PATCHES=$(APPWEB_SOURCE_DIR)/buildutilsfortargetenv.patch \
	$(APPWEB_SOURCE_DIR)/rpath.patch \
	$(APPWEB_SOURCE_DIR)/http.h.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APPWEB_CPPFLAGS=
APPWEB_LDFLAGS=

#
# APPWEB_BUILD_DIR is the directory in which the build is done.
# APPWEB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# APPWEB_IPK_DIR is the directory in which the ipk is built.
# APPWEB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
APPWEB_BUILD_DIR=$(BUILD_DIR)/appweb
APPWEB_SOURCE_DIR=$(SOURCE_DIR)/appweb
APPWEB_IPK_DIR=$(BUILD_DIR)/appweb-$(APPWEB_VERSION)-ipk
APPWEB_IPK=$(BUILD_DIR)/appweb_$(APPWEB_VERSION)-$(APPWEB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#

$(DL_DIR)/$(APPWEB_SOURCE):
	$(WGET) -P $(DL_DIR) $(APPWEB_SITE)/$(APPWEB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
appweb-source: $(DL_DIR)/$(APPWEB_SOURCE) $(APPWEB_PATCHES)

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
# ***
# NOTE: according to the appweb build instructions the paths for the loadable
#       modules must be relative paths - please dont replace the ../../../../staging
#       with the makefile symbol 
#
#       see the following for more information:
#       http://www.appwebserver.org/products/appWeb/doc/source/packages.html
#
$(APPWEB_BUILD_DIR)/.configured: $(DL_DIR)/$(APPWEB_SOURCE) $(APPWEB_PATCHES)
	$(MAKE) openssl-stage php-stage
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR)
	$(APPWEB_UNZIP) $(DL_DIR)/$(APPWEB_SOURCE) | tar -C $(BUILD_DIR) -xvf -

	cat $(APPWEB_PATCHES) | patch -d $(BUILD_DIR)/$(APPWEB_DIR) -p1

	# need to remove the appweb samples directory which 
	# can only be built statically
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR)/appWebSamples

	#need to update the configure script for 2.0.3
	#wget http://www.appwebserver.org/software/configure $(BUILD_DIR)/$(APPWEB_DIR)/configure
	cp $(APPWEB_SOURCE_DIR)/configure $(BUILD_DIR)/$(APPWEB_DIR)/

	mv $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR)
	(cd $(APPWEB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APPWEB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APPWEB_LDFLAGS)" \
		./configure \
		--type=RELEASE \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--docDir=/opt/var/appWeb/doc \
		--incDir=/opt/include \
		--libDir=/opt/lib \
		--sbinDir=/opt/sbin \
		--srcDir=/opt/src \
		--webDir=/opt/var/appWeb/web \
		--buildNumber=$(APPWEB_IPK_VERSION) \
		--port=7777 --sslPort=4443 \
		--disable-static \
		--enable-shared \
		--with-admin=loadable \
		--with-ssl=loadable \
		--with-openssl=loadable \
		--with-openssl-iflags="-I$(STAGING_PREFIX)/include/" \
		--with-openssl-dir="../../staging/opt/lib" \
		--with-openssl-libs="crypto ssl" \
		--with-php5=loadable \
		--with-php5-dir="../../staging/opt/lib" \
		--with-php5-iflags="-I$(STAGING_PREFIX)/include/php/ -I$(STAGING_PREFIX)/include/php/Zend -I$(STAGING_PREFIX)/include/php/TSRM -I$(STAGING_PREFIX)/include/php/main -I$(STAGING_PREFIX)/include/php/regex" \
		--with-php5-ldflags="$(STAGING_LDFLAGS)" \
		--with-php5-libs="php5 dl crypt db m xml2 z c" \
		--disable-test \
	)
	touch $(APPWEB_BUILD_DIR)/.configured


appweb-unpack: $(APPWEB_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(APPWEB_BUILD_DIR)/bin/appWeb: $(APPWEB_BUILD_DIR)/.configured
	$(MAKE) -C $(APPWEB_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
appweb: $(APPWEB_BUILD_DIR)/bin/appWeb

# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/appweb
#
$(APPWEB_IPK_DIR)/CONTROL/control:
	@install -d $(APPWEB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: appweb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(APPWEB_PRIORITY)" >>$@
	@echo "Section: $(APPWEB_SECTION)" >>$@
	@echo "Version: $(APPWEB_VERSION)-$(APPWEB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APPWEB_MAINTAINER)" >>$@
	@echo "Source: $(APPWEB_SITE)/$(APPWEB_SOURCE)" >>$@
	@echo "Description: $(APPWEB_DESCRIPTION)" >>$@
	@echo "Depends: $(APPWEB_DEPENDS)" >>$@
	@echo "Conflicts: $(APPWEB_CONFLICTS)" >>$@

#
#
# This builds the IPK file.
#
# Binaries should be installed into $(APPWEB_IPK_DIR)/opt/sbin or $(APPWEB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APPWEB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(APPWEB_IPK_DIR)/opt/etc/appweb/...
# Documentation files should be installed in $(APPWEB_IPK_DIR)/opt/doc/appweb/...
# Daemon startup scripts should be installed in $(APPWEB_IPK_DIR)/opt/etc/init.d/S??appweb
#
# You may need to patch your application to make it use these locations.
#
$(APPWEB_IPK): $(APPWEB_BUILD_DIR)/bin/appWeb
	rm -rf $(APPWEB_IPK_DIR) $(BUILD_DIR)/appweb_*_$(TARGET_ARCH).ipk

	# Copy shared libraries
	install -d $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libadminModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libadminModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libappWeb.so.1.0.0 $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libappWeb.so.1.0.0
	( cd $(APPWEB_IPK_DIR)/opt/lib ; ln -s libappWeb.so.1.0.0 libappWeb.so.1 )
	( cd $(APPWEB_IPK_DIR)/opt/lib ; ln -s libappWeb.so.1 libappWeb.so )
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libauthModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libauthModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcapiModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libcapiModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcgiModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libcgiModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcopyModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libcopyModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libegiModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libegiModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libejs.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libejs.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libespModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libespModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libmpr.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libmpr.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libopenSslModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libopenSslModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libphp5Module.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libphp5Module.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libsslModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libsslModule.so
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libuploadModule.so $(APPWEB_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)/opt/lib/libuploadModule.so

	# Copy executables
	install -d $(APPWEB_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/appWeb -o $(APPWEB_IPK_DIR)/opt/sbin/appWeb
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpClient -o $(APPWEB_IPK_DIR)/opt/sbin/httpClient
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpPassword -o $(APPWEB_IPK_DIR)/opt/sbin/httpPassword
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpComp -o $(APPWEB_IPK_DIR)/opt/sbin/httpComp
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/charGen -o $(APPWEB_IPK_DIR)/opt/sbin/charGen

	# Create log directories
	install -d $(APPWEB_IPK_DIR)/opt/var/appWeb/logs

	# Copy default site files and certificates
	install -d $(APPWEB_IPK_DIR)/opt/var/appWeb/web
	cp -r $(APPWEB_BUILD_DIR)/appWeb/web $(APPWEB_IPK_DIR)/opt/var/appWeb/
	chmod -R a+rX $(APPWEB_IPK_DIR)/opt/var/appWeb/web
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/mime.types $(APPWEB_IPK_DIR)/opt/var/appWeb
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/server.crt $(APPWEB_IPK_DIR)/opt/var/appWeb
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/server.key.pem $(APPWEB_IPK_DIR)/opt/var/appWeb

	# Copy documentation
	install -d $(APPWEB_IPK_DIR)/opt/doc/appweb
	install -m 644 $(APPWEB_BUILD_DIR)/COPYRIGHT.TXT $(APPWEB_IPK_DIR)/opt/doc/appweb/COPYRIGHT.txt
	install -m 644 $(APPWEB_BUILD_DIR)/README_SRC.TXT $(APPWEB_IPK_DIR)/opt/doc/appweb/README.txt
	install -m 644 $(APPWEB_BUILD_DIR)/LICENSE.TXT $(APPWEB_IPK_DIR)/opt/doc/appweb/LICENSE.txt

	# Copy service startup and configuration files
	install -d $(APPWEB_IPK_DIR)/opt/etc
#	install -m 644 $(APPWEB_SOURCE_DIR)/appWeb-php.conf $(APPWEB_IPK_DIR)/opt/etc/appWeb.conf
	install -m 644 $(APPWEB_SOURCE_DIR)/appWeb-php.conf $(APPWEB_IPK_DIR)/opt/var/appWeb/appWeb.conf
	install -d $(APPWEB_IPK_DIR)/opt/etc/init.d
	install -m 755 $(APPWEB_SOURCE_DIR)/rc.appweb $(APPWEB_IPK_DIR)/opt/etc/init.d/S81appweb

	# Copy ipkg control files
	$(MAKE) $(APPWEB_IPK_DIR)/CONTROL/control
	install -m 644 $(APPWEB_SOURCE_DIR)/postinst $(APPWEB_IPK_DIR)/CONTROL/postinst
	install -m 644 $(APPWEB_SOURCE_DIR)/prerm $(APPWEB_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APPWEB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
appweb-ipk: $(APPWEB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
appweb-clean:
	-$(MAKE) -C $(APPWEB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
appweb-dirclean:
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR) $(APPWEB_IPK_DIR) $(APPWEB_IPK)
