###########################################################
#
# wget-ssl
#
###########################################################

#
# WGET-SSL_VERSION, WGET-SSL_SITE and WGET-SSL_SOURCE define
# the upstream location of the source code for the package.
# WGET-SSL_DIR is the directory which is created when the source
# archive is unpacked.
# WGET-SSL_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
WGET-SSL_SITE=http://ftp.gnu.org/pub/gnu/wget
WGET-SSL_VERSION=1.9.1
WGET-SSL_SOURCE=wget-$(WGET-SSL_VERSION).tar.gz
WGET-SSL_DIR=wget-$(WGET-SSL_VERSION)
WGET-SSL_UNZIP=zcat

#
# WGET-SSL_IPK_VERSION should be incremented when the ipk changes.
#
WGET-SSL_IPK_VERSION=1

#
# WGET-SSL_CONFFILES should be a list of user-editable files
WGET-SSL_CONFFILES=/opt/etc/wgetrc

#
# WGET-SSL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WGET-SSL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WGET-SSL_CPPFLAGS=
WGET-SSL_LDFLAGS=

#
# WGET-SSL_BUILD_DIR is the directory in which the build is done.
# WGET-SSL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WGET-SSL_IPK_DIR is the directory in which the ipk is built.
# WGET-SSL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WGET-SSL_BUILD_DIR=$(BUILD_DIR)/wget-ssl
WGET-SSL_SOURCE_DIR=$(SOURCE_DIR)/wget-ssl
WGET-SSL_IPK_DIR=$(BUILD_DIR)/wget-ssl-$(WGET-SSL_VERSION)-ipk
WGET-SSL_IPK=$(BUILD_DIR)/wget-ssl_$(WGET-SSL_VERSION)-$(WGET-SSL_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget-ssl.
#
$(DL_DIR)/$(WGET-SSL_SOURCE):
	$(WGET) -P $(DL_DIR) $(WGET-SSL_SITE)/$(WGET-SSL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wget-ssl-source: $(DL_DIR)/$(WGET-SSL_SOURCE) $(WGET-SSL_PATCHES)

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
$(WGET-SSL_BUILD_DIR)/.configured: $(DL_DIR)/$(WGET-SSL_SOURCE) $(WGET-SSL_PATCHES)
ifneq ($(HOST_MACHINE),armv5b)
	$(MAKE) openssl-stage
endif
	rm -rf $(BUILD_DIR)/$(WGET-SSL_DIR) $(WGET-SSL_BUILD_DIR)
	$(WGET-SSL_UNZIP) $(DL_DIR)/$(WGET-SSL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(WGET-SSL_PATCHES) | patch -d $(BUILD_DIR)/$(WGET-SSL_DIR) -p1
	mv $(BUILD_DIR)/$(WGET-SSL_DIR) $(WGET-SSL_BUILD_DIR)
	(cd $(WGET-SSL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WGET-SSL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WGET-SSL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(WGET-SSL_BUILD_DIR)/.configured

wget-ssl-unpack: $(WGET-SSL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WGET-SSL_BUILD_DIR)/.built: $(WGET-SSL_BUILD_DIR)/.configured
	rm -f $(WGET-SSL_BUILD_DIR)/.built
	$(MAKE) -C $(WGET-SSL_BUILD_DIR)
	touch $(WGET-SSL_BUILD_DIR)/.built

#
#
wget-ssl: $(WGET-SSL_BUILD_DIR)/.built

#
# This builds the IPK file.
#
# Binaries should be installed into $(WGET-SSL_IPK_DIR)/opt/sbin or $(WGET-SSL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WGET-SSL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WGET-SSL_IPK_DIR)/opt/etc/wget/...
# Documentation files should be installed in $(WGET-SSL_IPK_DIR)/opt/doc/wget/...
# Daemon startup scripts should be installed in $(WGET-SSL_IPK_DIR)/opt/etc/init.d/S??wget
#
# You may need to patch your application to make it use these locations.
#
$(WGET-SSL_IPK): $(WGET-SSL_BUILD_DIR)/.built
	rm -rf $(WGET-SSL_IPK_DIR) $(BUILD_DIR)/wget-ssl_*_armeb.ipk
	install -d $(WGET-SSL_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(WGET-SSL_BUILD_DIR)/src/wget -o $(WGET-SSL_IPK_DIR)/opt/bin/wget
	install -d $(WGET-SSL_IPK_DIR)/opt/etc/
	install -m 755 $(WGET-SSL_BUILD_DIR)/doc/sample.wgetrc $(WGET-SSL_IPK_DIR)/opt/etc/wgetrc
	install -d $(WGET-SSL_IPK_DIR)/CONTROL
	install -m 644 $(WGET-SSL_SOURCE_DIR)/control $(WGET-SSL_IPK_DIR)/CONTROL/control
#	install -m 644 $(WGET-SSL_SOURCE_DIR)/postinst $(WGET-SSL_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(WGET-SSL_SOURCE_DIR)/prerm $(WGET-SSL_IPK_DIR)/CONTROL/prerm
	echo $(WGET-SSL_CONFFILES) | sed -e 's/ /\n/g' > $(WGET-SSL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WGET-SSL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wget-ssl-ipk: $(WGET-SSL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wget-ssl-clean:
	-$(MAKE) -C $(WGET-SSL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wget-ssl-dirclean:
	rm -rf $(BUILD_DIR)/$(WGET-SSL_DIR) $(WGET-SSL_BUILD_DIR) $(WGET-SSL_IPK_DIR) $(WGET-SSL_IPK)
