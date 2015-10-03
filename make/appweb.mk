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
APPWEB_DEPENDS=openssl, php-embed, psmisc
APPWEB_SUGGESTS=
APPWEB_CONFLICTS=

#
# APPWEB_IPK_VERSION should be incremented when the ipk changes.
#
APPWEB_IPK_VERSION=2

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

.PHONY: appweb-source appweb-unpack appweb appweb-stage appweb-ipk appweb-clean appweb-dirclean appweb-check

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

	cat $(APPWEB_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(APPWEB_DIR) -p1

	# need to remove the appweb samples directory which 
	# can only be built statically
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR)/appWebSamples

	#need to update the configure script for 2.0.3
	#wget http://www.appwebserver.org/software/configure $(BUILD_DIR)/$(APPWEB_DIR)/configure
	$(INSTALL) -m 644 $(APPWEB_SOURCE_DIR)/configure $(BUILD_DIR)/$(APPWEB_DIR)/

	mv $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR)
	(cd $(APPWEB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APPWEB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APPWEB_LDFLAGS)" \
		./configure \
		--type=RELEASE \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--docDir=$(TARGET_PREFIX)/var/appWeb/doc \
		--incDir=$(TARGET_PREFIX)/include \
		--libDir=$(TARGET_PREFIX)/lib \
		--sbinDir=$(TARGET_PREFIX)/sbin \
		--srcDir=$(TARGET_PREFIX)/src \
		--webDir=$(TARGET_PREFIX)/var/appWeb/web \
		--buildNumber=$(APPWEB_IPK_VERSION) \
		--port=7777 --sslPort=4443 \
		--disable-static \
		--enable-shared \
		--with-admin=loadable \
		--with-ssl=loadable \
		--with-openssl=loadable \
		--with-openssl-iflags="-I$(STAGING_INCLUDE_DIR)/" \
		--with-openssl-dir="../../staging$(TARGET_PREFIX)/lib" \
		--with-openssl-libs="crypto ssl" \
		--with-php5=loadable \
		--with-php5-dir="../../staging$(TARGET_PREFIX)/lib" \
		--with-php5-iflags="-I$(STAGING_INCLUDE_DIR)/php/ -I$(STAGING_INCLUDE_DIR)/php/Zend -I$(STAGING_INCLUDE_DIR)/php/TSRM -I$(STAGING_INCLUDE_DIR)/php/main -I$(STAGING_INCLUDE_DIR)/php/regex" \
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
$(APPWEB_BUILD_DIR)/.built: $(APPWEB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(APPWEB_BUILD_DIR)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
appweb: $(APPWEB_BUILD_DIR)/.built

# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/appweb
#
$(APPWEB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(APPWEB_IPK_DIR)/CONTROL
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
	@echo "Suggests: $(APPWEB_SUGGESTS)" >>$@
	@echo "Conflicts: $(APPWEB_CONFLICTS)" >>$@

#
#
# This builds the IPK file.
#
# Binaries should be installed into $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc/appweb/...
# Documentation files should be installed in $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/doc/appweb/...
# Daemon startup scripts should be installed in $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??appweb
#
# You may need to patch your application to make it use these locations.
#
$(APPWEB_IPK): $(APPWEB_BUILD_DIR)/.built
	rm -rf $(APPWEB_IPK_DIR) $(BUILD_DIR)/appweb_*_$(TARGET_ARCH).ipk

	# Copy shared libraries
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libadminModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libadminModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libappWeb.so.1.0.0 $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libappWeb.so.1.0.0
	( cd $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib ; ln -s libappWeb.so.1.0.0 libappWeb.so.1 )
	( cd $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib ; ln -s libappWeb.so.1 libappWeb.so )
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libauthModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libauthModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libcapiModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libcapiModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libcgiModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libcgiModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libcopyModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libcopyModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libegiModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libegiModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libejs.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libejs.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libespModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libespModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libmpr.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libmpr.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libopenSslModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libopenSslModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libphp5Module.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libphp5Module.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libsslModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libsslModule.so
	$(INSTALL) -m 755 $(APPWEB_BUILD_DIR)/bin/libuploadModule.so $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/lib/libuploadModule.so

	# Copy executables
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/appWeb -o $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin/appWeb
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpClient -o $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin/httpClient
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpPassword -o $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin/httpPassword
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/httpComp -o $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin/httpComp
	$(STRIP_COMMAND) $(APPWEB_BUILD_DIR)/bin/charGen -o $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/sbin/charGen

	# Create log directories
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb/logs

	# Copy default site files and certificates
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb/web
	cp -r $(APPWEB_BUILD_DIR)/appWeb/web $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb/
	chmod -R a+rX $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb/web
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/appWeb/mime.types $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/appWeb/server.crt $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/appWeb/server.key.pem $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb

	# Copy documentation
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/doc/appweb
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/COPYRIGHT.TXT $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/doc/appweb/COPYRIGHT.txt
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/README_SRC.TXT $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/doc/appweb/README.txt
	$(INSTALL) -m 644 $(APPWEB_BUILD_DIR)/LICENSE.TXT $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/doc/appweb/LICENSE.txt

	# Copy service startup and configuration files
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc
#	$(INSTALL) -m 644 $(APPWEB_SOURCE_DIR)/appWeb-php.conf $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc/appWeb.conf
	$(INSTALL) -m 644 $(APPWEB_SOURCE_DIR)/appWeb-php.conf $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/var/appWeb/appWeb.conf
	$(INSTALL) -d $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(APPWEB_SOURCE_DIR)/rc.appweb $(APPWEB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S81appweb

	# Copy ipkg control files
	$(MAKE) $(APPWEB_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(APPWEB_SOURCE_DIR)/postinst $(APPWEB_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 644 $(APPWEB_SOURCE_DIR)/prerm $(APPWEB_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APPWEB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
appweb-ipk: $(APPWEB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
appweb-clean:
	rm -f $(APPWEB_BUILD_DIR)/.built
	-$(MAKE) -C $(APPWEB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
appweb-dirclean:
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR) $(APPWEB_IPK_DIR) $(APPWEB_IPK)

#
#
# Some sanity check for the package.
#
appweb-check: $(APPWEB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

