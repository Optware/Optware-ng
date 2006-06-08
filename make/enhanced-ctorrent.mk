###########################################################
#
# enhanced-ctorrent
#
###########################################################

#
# ORIGINAL_CTORRENT_BASE_VERSION and ENHANCED_CTORRENT_VERSION define
# the upstream version of Enhanced CTorrent
# ENHANCED_CTORRENT_SITE and ENHANCED_CTORRENT_SOURCE define
# the upstream location of the source code for the package.
# ENHANCED_CTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# ENHANCED_CTORRENT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
ENHANCED_CTORRENT_SITE=http://www.rahul.net/dholmes/ctorrent
ORIGINAL_CTORRENT_BASE_VERSION=1.3.4
ENHANCED_CTORRENT_VERSION=dnh2
ENHANCED_CTORRENT_SOURCE=ctorrent-$(ORIGINAL_CTORRENT_BASE_VERSION)-$(ENHANCED_CTORRENT_VERSION).tar.gz
ENHANCED_CTORRENT_DIR=ctorrent-$(ENHANCED_CTORRENT_VERSION)
ENHANCED_CTORRENT_UNZIP=zcat
ENHANCED_CTORRENT_MAINTAINER=Fernando Carolo <carolo@gmail.com>
ENHANCED_CTORRENT_DESCRIPTION=Enhanced CTorrent is a revised version of CTorrent
ENHANCED_CTORRENT_SECTION=net
ENHANCED_CTORRENT_PRIORITY=optional
ENHANCED_CTORRENT_DEPENDS=libstdc++, openssl
ENHANCED_CTORRENT_SUGGESTS=
ENHANCED_CTORRENT_CONFLICTS=

#
# ENHANCED_CTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
ENHANCED_CTORRENT_IPK_VERSION=1

#
# ENHANCED_CTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ENHANCED_CTORRENT_PATCHES=$(ENHANCED_CTORRENT_SOURCE_DIR)/btfiles.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ENHANCED_CTORRENT_CPPFLAGS=
ENHANCED_CTORRENT_LDFLAGS=

#
# ENHANCED_CTORRENT_BUILD_DIR is the directory in which the build is done.
# ENHANCED_CTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ENHANCED_CTORRENT_IPK_DIR is the directory in which the ipk is built.
# ENHANCED_CTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ENHANCED_CTORRENT_BUILD_DIR=$(BUILD_DIR)/enhanced-ctorrent
ENHANCED_CTORRENT_SOURCE_DIR=$(SOURCE_DIR)/enhanced-ctorrent
ENHANCED_CTORRENT_IPK_DIR=$(BUILD_DIR)/enhanced-ctorrent-$(ENHANCED_CTORRENT_VERSION)-ipk
ENHANCED_CTORRENT_IPK=$(BUILD_DIR)/enhanced-ctorrent_$(ENHANCED_CTORRENT_VERSION)-$(ENHANCED_CTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ENHANCED_CTORRENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(ENHANCED_CTORRENT_SITE)/$(ENHANCED_CTORRENT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
enhanced-ctorrent-source: $(DL_DIR)/$(ENHANCED_CTORRENT_SOURCE) $(ENHANCED_CTORRENT_PATCHES)

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
$(ENHANCED_CTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(ENHANCED_CTORRENT_SOURCE) $(ENHANCED_CTORRENT_PATCHES)
	$(MAKE) openssl-stage libstdc++-stage
	rm -rf $(BUILD_DIR)/$(ENHANCED_CTORRENT_DIR) $(ENHANCED_CTORRENT_BUILD_DIR)
	$(ENHANCED_CTORRENT_UNZIP) $(DL_DIR)/$(ENHANCED_CTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ENHANCED_CTORRENT_PATCHES) | patch -d $(BUILD_DIR)/$(ENHANCED_CTORRENT_DIR) -p1
	mv $(BUILD_DIR)/$(ENHANCED_CTORRENT_DIR) $(ENHANCED_CTORRENT_BUILD_DIR)
	(cd $(ENHANCED_CTORRENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ENHANCED_CTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ENHANCED_CTORRENT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(ENHANCED_CTORRENT_BUILD_DIR)/.configured

enhanced-ctorrent-unpack: $(ENHANCED_CTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(ENHANCED_CTORRENT_BUILD_DIR)/enhanced-ctorrent: $(ENHANCED_CTORRENT_BUILD_DIR)/.configured
	$(MAKE) -C $(ENHANCED_CTORRENT_BUILD_DIR)

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
enhanced-ctorrent: $(ENHANCED_CTORRENT_BUILD_DIR)/enhanced-ctorrent

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/enhanced-ctorrent
#
$(ENHANCED_CTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(ENHANCED_CTORRENT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: enhanced-ctorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ENHANCED_CTORRENT_PRIORITY)" >>$@
	@echo "Section: $(ENHANCED_CTORRENT_SECTION)" >>$@
	@echo "Version: $(ENHANCED_CTORRENT_VERSION)-$(ENHANCED_CTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ENHANCED_CTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(ENHANCED_CTORRENT_SITE)/$(ENHANCED_CTORRENT_SOURCE)" >>$@
	@echo "Description: $(ENHANCED_CTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(ENHANCED_CTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(ENHANCED_CTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(ENHANCED_CTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# The binary for Enhanced Ctorrent will be installed as enhanced-ctorrent,
# in order to prevent a conflict with the original CTorrent package
# available in the Optware repository. 
#
# Binaries should be installed into $(ENHANCED_CTORRENT_IPK_DIR)/opt/sbin or $(ENHANCED_CTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ENHANCED_CTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ENHANCED_CTORRENT_IPK_DIR)/opt/etc/enhanced-ctorrent/...
# Documentation files should be installed in $(ENHANCED_CTORRENT_IPK_DIR)/opt/doc/enhanced-ctorrent/...
# Daemon startup scripts should be installed in $(ENHANCED_CTORRENT_IPK_DIR)/opt/etc/init.d/S??enhanced-ctorrent
#
# You may need to patch your application to make it use these locations.
#
$(ENHANCED_CTORRENT_IPK): $(ENHANCED_CTORRENT_BUILD_DIR)/enhanced-ctorrent
	rm -rf $(ENHANCED_CTORRENT_IPK_DIR) $(ENHANCED_CTORRENT_IPK)
	install -d $(ENHANCED_CTORRENT_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(ENHANCED_CTORRENT_BUILD_DIR)/ctorrent -o $(ENHANCED_CTORRENT_IPK_DIR)/opt/bin/enhanced-ctorrent
#	install -d $(ENHANCED_CTORRENT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ENHANCED_CTORRENT_SOURCE_DIR)/rc.enhanced-ctorrent $(ENHANCED_CTORRENT_IPK_DIR)/opt/etc/init.d/SXXenhanced-ctorrent
	$(MAKE) $(ENHANCED_CTORRENT_IPK_DIR)/CONTROL/control
#	install -m 644 $(ENHANCED_CTORRENT_SOURCE_DIR)/postinst $(ENHANCED_CTORRENT_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(ENHANCED_CTORRENT_SOURCE_DIR)/prerm $(ENHANCED_CTORRENT_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ENHANCED_CTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
enhanced-ctorrent-ipk: $(ENHANCED_CTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
enhanced-ctorrent-clean:
	-$(MAKE) -C $(ENHANCED_CTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
enhanced-ctorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(ENHANCED_CTORRENT_DIR) $(ENHANCED_CTORRENT_BUILD_DIR) $(ENHANCED_CTORRENT_IPK_DIR) $(ENHANCED_CTORRENT_IPK)
