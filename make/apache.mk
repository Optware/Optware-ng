###########################################################
#
# apache
#
###########################################################

#
# APACHE_VERSION, APACHE_SITE and APACHE_SOURCE define
# the upstream location of the source code for the package.
# APACHE_DIR is the directory which is created when the source
# archive is unpacked.
# APACHE_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
APACHE_SITE=http://mirrors.ccs.neu.edu/Apache/dist/httpd
APACHE_VERSION=2.0.53
APACHE_SOURCE=httpd-$(APACHE_VERSION).tar.bz2
APACHE_DIR=httpd-$(APACHE_VERSION)
APACHE_UNZIP=bzcat
APACHE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
APACHE_DESCRIPTION=The internet\'s most popular web server
APACHE_SECTION=lib
APACHE_PRIORITY=optional
APACHE_DEPENDS=apr, apr-util, openssl

#
# APACHE_IPK_VERSION should be incremented when the ipk changes.
#
APACHE_IPK_VERSION=2

#
# APACHE_CONFFILES should be a list of user-editable files
#
APACHE_CONFFILES=/opt/etc/apache2/httpd.conf /opt/etc/apache2/ssl.conf /opt/etc/init.d/S80apache

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
APACHE_PATCHES=$(APACHE_SOURCE_DIR)/hostcc.patch $(APACHE_SOURCE_DIR)/hostcc-pcre.patch $(APACHE_SOURCE_DIR)/apxs.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
APACHE_CPPFLAGS=
APACHE_LDFLAGS=

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
APACHE_IPK=$(BUILD_DIR)/apache_$(APACHE_VERSION)-$(APACHE_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(APACHE_IPK_DIR)/CONTROL/control:
	@install -d $(APACHE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: apache" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(APACHE_PRIORITY)" >>$@
	@echo "Section: $(APACHE_SECTION)" >>$@
	@echo "Version: $(APACHE_VERSION)-$(APACHE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(APACHE_MAINTAINER)" >>$@
	@echo "Source: $(APACHE_SITE)/$(APACHE_SOURCE)" >>$@
	@echo "Description: $(APACHE_DESCRIPTION)" >>$@
	@echo "Depends: $(APACHE_DEPENDS)" >>$@

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
$(APACHE_BUILD_DIR)/.configured: $(DL_DIR)/$(APACHE_SOURCE) \
		$(STAGING_DIR)/opt/bin/apr-config \
		$(STAGING_DIR)/opt/bin/apu-config \
		$(APACHE_PATCHES)
	$(MAKE) expat-stage
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR)
	$(APACHE_UNZIP) $(DL_DIR)/$(APACHE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR)
	cat $(APACHE_PATCHES) |patch -p0 -d $(APACHE_BUILD_DIR)
	sed -i -e "s% *installbuilddir: .*% installbuilddir: $(STAGING_DIR)/opt/share/apache2/build%" $(APACHE_BUILD_DIR)/config.layout
	cp $(APACHE_SOURCE_DIR)/httpd-std.conf.in $(APACHE_BUILD_DIR)/docs/conf
	(cd $(APACHE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(APACHE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(APACHE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-layout=GNU \
		--enable-mods-shared=all \
		--with-apr=$(STAGING_DIR)/opt \
		--with-apr-util=$(STAGING_DIR)/opt \
		--with-expat=/opt \
		--with-port=8000 \
	)
	touch $(APACHE_BUILD_DIR)/.configured

apache-unpack: $(APACHE_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(APACHE_BUILD_DIR)/.built: $(APACHE_BUILD_DIR)/.configured
	rm -f $(APACHE_BUILD_DIR)/.built
	$(MAKE) -C $(APACHE_BUILD_DIR) HOSTCC=$(HOSTCC)
	touch $(APACHE_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
apache: $(APACHE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/sbin/apxs: $(APACHE_BUILD_DIR)/.built
	rm -f $(STAGING_DIR)/opt/sbin/apxs
	$(MAKE) -C $(APACHE_BUILD_DIR) install installbuilddir=/opt/share/apache2/build DESTDIR=$(STAGING_DIR)
	touch $(STAGING_DIR)/opt/sbin/apxs
	rm -rf $(STAGING_DIR)/opt/share/apache2/manual
	rm -rf $(STAGING_DIR)/opt/share/apache2/htdocs
	rm -rf $(STAGING_DIR)/opt/share/apache2/error
	rm -rf $(STAGING_DIR)/opt/share/apache2/icons
	rm -rf $(STAGING_DIR)/opt/share/apache2/cgi-bin

apache-stage: $(STAGING_DIR)/opt/sbin/apxs

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
$(APACHE_IPK): $(APACHE_BUILD_DIR)/.built
	rm -rf $(APACHE_IPK_DIR) $(BUILD_DIR)/apache_*_armeb.ipk
	$(MAKE) -C $(APACHE_BUILD_DIR) DESTDIR=$(APACHE_IPK_DIR) installbuilddir=/opt/share/apache2/build install
	rm -rf $(APACHE_IPK_DIR)/opt/share/apache2/manual
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/libexec/*.so
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/ab
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/checkgid
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htdbm
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htdigest
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/htpasswd
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/httpd
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/logresolve
	$(TARGET_STRIP) $(APACHE_IPK_DIR)/opt/sbin/rotatelogs
	sed -i -e "s%$(STAGING_DIR)%%" $(APACHE_IPK_DIR)/opt/sbin/apxs
	sed -i -e "s%^#!.*perl%#!/opt/bin/perl%" $(APACHE_IPK_DIR)/opt/sbin/apxs
	sed -i -e "s%^#!.*perl%#!/opt/bin/perl%" $(APACHE_IPK_DIR)/opt/sbin/dbmmanage
	install -d $(APACHE_IPK_DIR)/opt/etc/apache2/conf.d
	install -d $(APACHE_IPK_DIR)/opt/etc/init.d
	install -m 755 $(APACHE_SOURCE_DIR)/rc.apache $(APACHE_IPK_DIR)/opt/etc/init.d/S80apache
	$(MAKE) $(APACHE_IPK_DIR)/CONTROL/control
	install -m 755 $(APACHE_SOURCE_DIR)/prerm $(APACHE_IPK_DIR)/CONTROL/prerm
	install -m 755 $(APACHE_SOURCE_DIR)/postinst $(APACHE_IPK_DIR)/CONTROL/postinst
	echo $(APACHE_CONFFILES) | sed -e 's/ /\n/g' > $(APACHE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(APACHE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
apache-ipk: $(APACHE_IPK)

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
	rm -rf $(BUILD_DIR)/$(APACHE_DIR) $(APACHE_BUILD_DIR) $(APACHE_IPK_DIR) $(APACHE_IPK)
