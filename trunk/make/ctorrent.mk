###########################################################
#
# ctorrent
#
###########################################################

#
# CTORRENT_VERSION, CTORRENT_SITE and CTORRENT_SOURCE define
# the upstream location of the source code for the package.
# CTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# CTORRENT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
CTORRENT_SITE=http://heanet.dl.sourceforge.net/sourceforge/ctorrent
CTORRENT_VERSION=1.3.3
CTORRENT_SOURCE=ctorrent-$(CTORRENT_VERSION).tar.gz
CTORRENT_DIR=ctorrent-$(CTORRENT_VERSION)
CTORRENT_UNZIP=zcat
#
# CTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
CTORRENT_IPK_VERSION=1

#
# CTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CTORRENT_PATCHES=$(CTORRENT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CTORRENT_CPPFLAGS=
CTORRENT_LDFLAGS=

#
# CTORRENT_BUILD_DIR is the directory in which the build is done.
# CTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CTORRENT_IPK_DIR is the directory in which the ipk is built.
# CTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CTORRENT_BUILD_DIR=$(BUILD_DIR)/ctorrent
CTORRENT_SOURCE_DIR=$(SOURCE_DIR)/ctorrent
CTORRENT_IPK_DIR=$(BUILD_DIR)/ctorrent-$(CTORRENT_VERSION)-ipk
CTORRENT_IPK=$(BUILD_DIR)/ctorrent_$(CTORRENT_VERSION)-$(CTORRENT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CTORRENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(CTORRENT_SITE)/$(CTORRENT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ctorrent-source: $(DL_DIR)/$(CTORRENT_SOURCE) $(CTORRENT_PATCHES)

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
$(CTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(CTORRENT_SOURCE) $(CTORRENT_PATCHES)
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(CTORRENT_DIR) $(CTORRENT_BUILD_DIR)
	$(CTORRENT_UNZIP) $(DL_DIR)/$(CTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(CTORRENT_PATCHES) | patch -d $(BUILD_DIR)/$(CTORRENT_DIR) -p1
	mv $(BUILD_DIR)/$(CTORRENT_DIR) $(CTORRENT_BUILD_DIR)
	(cd $(CTORRENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CTORRENT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(CTORRENT_BUILD_DIR)/.configured

ctorrent-unpack: $(CTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(CTORRENT_BUILD_DIR)/ctorrent: $(CTORRENT_BUILD_DIR)/.configured
	$(MAKE) -C $(CTORRENT_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ctorrent: $(CTORRENT_BUILD_DIR)/ctorrent

#
# This builds the IPK file.
#
# Binaries should be installed into $(CTORRENT_IPK_DIR)/opt/sbin or $(CTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CTORRENT_IPK_DIR)/opt/etc/ctorrent/...
# Documentation files should be installed in $(CTORRENT_IPK_DIR)/opt/doc/ctorrent/...
# Daemon startup scripts should be installed in $(CTORRENT_IPK_DIR)/opt/etc/init.d/S??ctorrent
#
# You may need to patch your application to make it use these locations.
#
$(CTORRENT_IPK): $(CTORRENT_BUILD_DIR)/ctorrent
	rm -rf $(CTORRENT_IPK_DIR) $(CTORRENT_IPK)
	install -d $(CTORRENT_IPK_DIR)/opt/bin
	$(TARGET_STRIP) $(CTORRENT_BUILD_DIR)/ctorrent -o $(CTORRENT_IPK_DIR)/opt/bin/ctorrent
#	install -d $(CTORRENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CTORRENT_SOURCE_DIR)/rc.ctorrent $(CTORRENT_IPK_DIR)/opt/etc/init.d/SXXctorrent
	install -d $(CTORRENT_IPK_DIR)/CONTROL
	install -m 644 $(CTORRENT_SOURCE_DIR)/control $(CTORRENT_IPK_DIR)/CONTROL/control
#	install -m 644 $(CTORRENT_SOURCE_DIR)/postinst $(CTORRENT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(CTORRENT_SOURCE_DIR)/prerm $(CTORRENT_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ctorrent-ipk: $(CTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ctorrent-clean:
	-$(MAKE) -C $(CTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ctorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(CTORRENT_DIR) $(CTORRENT_BUILD_DIR) $(CTORRENT_IPK_DIR) $(CTORRENT_IPK)
