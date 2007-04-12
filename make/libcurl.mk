###########################################################
#
# libcurl
#
###########################################################

# You must replace "libcurl" and "LIBCURL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBCURL_VERSION, LIBCURL_SITE and LIBCURL_SOURCE define
# the upstream location of the source code for the package.
# LIBCURL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBCURL_UNZIP is the command used to unzip the source.
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
LIBCURL_SITE= http://curl.haxx.se/download
LIBCURL_VERSION=7.16.2
LIBCURL_SOURCE=curl-$(LIBCURL_VERSION).tar.gz
LIBCURL_DIR=curl-$(LIBCURL_VERSION)
LIBCURL_UNZIP=zcat
LIBCURL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBCURL_DESCRIPTION=Curl is a command line tool for transferring files with URL syntax, supporting FTP, FTPS, HTTP, HTTPS, GOPHER, TELNET, DICT, FILE and LDAP. Curl supports HTTPS certificates, HTTP POST, HTTP PUT, FTP uploading, kerberos, HTTP form based upload, proxies, cookies, user+password authentication, file transfer resume, http proxy tunneling and a busload of other useful tricks.
LIBCURL_SECTION=libs
LIBCURL_PRIORITY=optional
LIBCURL_DEPENDS=openssl
LIBCURL_CONFLICTS=

#
# LIBCURL_IPK_VERSION should be incremented when the ipk changes.
#
LIBCURL_IPK_VERSION=1

#
# LIBCURL_CONFFILES should be a list of user-editable files
LIBCURL_CONFFILES=#/opt/etc/libcurl.conf /opt/etc/init.d/SXXlibcurl

#
# LIBCURL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBCURL_PATCHES=#$(LIBCURL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBCURL_CPPFLAGS=
LIBCURL_LDFLAGS=-lssl

#
# LIBCURL_BUILD_DIR is the directory in which the build is done.
# LIBCURL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBCURL_IPK_DIR is the directory in which the ipk is built.
# LIBCURL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBCURL_BUILD_DIR=$(BUILD_DIR)/libcurl
LIBCURL_SOURCE_DIR=$(SOURCE_DIR)/libcurl
LIBCURL_IPK_DIR=$(BUILD_DIR)/libcurl-$(LIBCURL_VERSION)-ipk
LIBCURL_IPK=$(BUILD_DIR)/libcurl_$(LIBCURL_VERSION)-$(LIBCURL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libcurl-source libcurl-unpack libcurl libcurl-stage libcurl-ipk libcurl-clean libcurl-dirclean libcurl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBCURL_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBCURL_SITE)/$(LIBCURL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libcurl-source: $(DL_DIR)/$(LIBCURL_SOURCE) $(LIBCURL_PATCHES)

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
$(LIBCURL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBCURL_SOURCE) $(LIBCURL_PATCHES) make/libcurl.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR)
	$(LIBCURL_UNZIP) $(DL_DIR)/$(LIBCURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBCURL_PATCHES) | patch -d $(BUILD_DIR)/$(LIBCURL_DIR) -p1
	mv $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR)
	(cd $(LIBCURL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBCURL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBCURL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--without-libidn \
		--with-random="/dev/urandom" \
	)
	touch $@

libcurl-unpack: $(LIBCURL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBCURL_BUILD_DIR)/.built: $(LIBCURL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBCURL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libcurl: $(LIBCURL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBCURL_BUILD_DIR)/.staged: $(LIBCURL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBCURL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|-I$${prefix}/include|-I$(STAGING_INCLUDE_DIR)|' $(STAGING_PREFIX)/bin/curl-config
	install -d $(STAGING_DIR)/bin
	cp $(STAGING_DIR)/opt/bin/curl-config $(STAGING_DIR)/bin/curl-config
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libcurl.pc
	rm -f $(STAGING_LIB_DIR)/libcurl.la
	touch $@

libcurl-stage: $(LIBCURL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libcurl
#
$(LIBCURL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libcurl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBCURL_PRIORITY)" >>$@
	@echo "Section: $(LIBCURL_SECTION)" >>$@
	@echo "Version: $(LIBCURL_VERSION)-$(LIBCURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBCURL_MAINTAINER)" >>$@
	@echo "Source: $(LIBCURL_SITE)/$(LIBCURL_SOURCE)" >>$@
	@echo "Description: $(LIBCURL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBCURL_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBCURL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBCURL_IPK_DIR)/opt/sbin or $(LIBCURL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBCURL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBCURL_IPK_DIR)/opt/etc/libcurl/...
# Documentation files should be installed in $(LIBCURL_IPK_DIR)/opt/doc/libcurl/...
# Daemon startup scripts should be installed in $(LIBCURL_IPK_DIR)/opt/etc/init.d/S??libcurl
#
# You may need to patch your application to make it use these locations.
#
$(LIBCURL_IPK): $(LIBCURL_BUILD_DIR)/.built
	rm -rf $(LIBCURL_IPK_DIR) $(BUILD_DIR)/libcurl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBCURL_BUILD_DIR) DESTDIR=$(LIBCURL_IPK_DIR) install-strip
	rm -f $(LIBCURL_IPK_DIR)/opt/lib/libcurl.a
	#install -d $(LIBCURL_IPK_DIR)/opt/etc/
	#install -m 644 $(LIBCURL_SOURCE_DIR)/libcurl.conf $(LIBCURL_IPK_DIR)/opt/etc/libcurl.conf
	#install -d $(LIBCURL_IPK_DIR)/opt/etc/init.d
	#install -m 755 $(LIBCURL_SOURCE_DIR)/rc.libcurl $(LIBCURL_IPK_DIR)/opt/etc/init.d/SXXlibcurl
	$(MAKE) $(LIBCURL_IPK_DIR)/CONTROL/control
	#install -m 755 $(LIBCURL_SOURCE_DIR)/postinst $(LIBCURL_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(LIBCURL_SOURCE_DIR)/prerm $(LIBCURL_IPK_DIR)/CONTROL/prerm
	echo $(LIBCURL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBCURL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBCURL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libcurl-ipk: $(LIBCURL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libcurl-clean:
	-$(MAKE) -C $(LIBCURL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libcurl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBCURL_DIR) $(LIBCURL_BUILD_DIR) $(LIBCURL_IPK_DIR) $(LIBCURL_IPK)

#
# Some sanity check for the package.
#
libcurl-check: $(LIBCURL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBCURL_IPK)
