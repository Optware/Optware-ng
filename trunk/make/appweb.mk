###########################################################
#
# appweb
#
###########################################################

# You must replace "appweb" and "APPWEB" with the lower case name and
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
APPWEB_VERSION=1.2.3
APPWEB_VERSION_EXTRA=0
APPWEB_SOURCE=appWeb-src-$(APPWEB_VERSION)-$(APPWEB_VERSION_EXTRA).tar.gz
APPWEB_DIR=appWeb-$(APPWEB_VERSION)
APPWEB_UNZIP=zcat

#
# APPWEB_IPK_VERSION should be incremented when the ipk changes.
#
APPWEB_IPK_VERSION=1

#
# APPWEB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
APPWEB_PATCHES=$(APPWEB_SOURCE_DIR)/nonrootinstall.patch

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
APPWEB_IPK=$(BUILD_DIR)/appweb_$(APPWEB_VERSION)-$(APPWEB_IPK_VERSION)_armeb.ipk

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
$(APPWEB_BUILD_DIR)/.configured: $(DL_DIR)/$(APPWEB_SOURCE) $(APPWEB_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR)
	$(APPWEB_UNZIP) $(DL_DIR)/$(APPWEB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(APPWEB_PATCHES) | patch -d $(BUILD_DIR)/$(APPWEB_DIR) -p0
	mv $(BUILD_DIR)/$(APPWEB_DIR) $(APPWEB_BUILD_DIR)
	(cd $(APPWEB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APPWEB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APPWEB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
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
#	$(MAKE) DESTDIR=$(APPWEB_IPK_DIR) SKIP_PERMS=1 -C $(APPWEB_BUILD_DIR) install
	install -d $(APPWEB_IPK_DIR)/CONTROL
	install -m 644 $(APPWEB_SOURCE_DIR)/control $(APPWEB_IPK_DIR)/CONTROL/control
	install -m 644 $(APPWEB_SOURCE_DIR)/postinst $(APPWEB_IPK_DIR)/CONTROL/postinst
	#$(STRIP) $(APPWEB_BUILD_DIR)/appweb -o $(APPWEB_IPK_DIR)/opt/bin/appweb
	#
	# Copy file package ./http/package/LINUX/http.files ...
	install -d $(APPWEB_IPK_DIR)/opt/sbin
	install -m 755 $(APPWEB_BUILD_DIR)/bin/httpClient $(APPWEB_IPK_DIR)/opt/sbin/httpClient
	install -m 755 $(APPWEB_BUILD_DIR)/bin/httpPassword $(APPWEB_IPK_DIR)/opt/sbin/httpPassword
	install -d $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libappWeb.so.1.0.0 $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libminiStdc++.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libadminModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libauthModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcapiModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcgiModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libcopyModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libegiModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libejsModule.so $(APPWEB_IPK_DIR)/opt/lib
	install -m 755 $(APPWEB_BUILD_DIR)/bin/libespModule.so $(APPWEB_IPK_DIR)/opt/lib
	# Copy file package ./appWeb/package/LINUX/appWeb.files ...
	install -d $(APPWEB_IPK_DIR)/opt/sbin
	$(TARGET_STRIP) $(APPWEB_BUILD_DIR)/bin/appWeb -o $(APPWEB_IPK_DIR)/opt/sbin/appWeb
	install -d $(APPWEB_IPK_DIR)/opt/etc/init.d
	install -m 755 $(APPWEB_SOURCE_DIR)/rc.appweb $(APPWEB_IPK_DIR)/opt/etc/init.d/S81appweb
	install -d $(APPWEB_IPK_DIR)/opt/var/appWeb/logs
	install -d $(APPWEB_IPK_DIR)/opt/var/appWeb/web
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/web/index.html $(APPWEB_IPK_DIR)/opt/var/appWeb/web
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/web/test* $(APPWEB_IPK_DIR)/opt/var/appWeb/web
	install -m 644 $(APPWEB_BUILD_DIR)/appWeb/mime.types $(APPWEB_IPK_DIR)/opt/var/appWeb
	install -m 644 $(APPWEB_SOURCE_DIR)/appWeb.conf $(APPWEB_IPK_DIR)/opt/etc/appWeb.conf
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
