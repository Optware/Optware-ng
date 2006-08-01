###########################################################
#
# gift
#
###########################################################

# You must replace "gift" and "GIFT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFT_VERSION, GIFT_SITE and GIFT_SOURCE define
# the upstream location of the source code for the package.
# GIFT_DIR is the directory which is created when the source
# archive is unpacked.
# GIFT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gift
GIFT_VERSION=0.11.8.1
GIFT_SOURCE=gift-$(GIFT_VERSION).tar.bz2
GIFT_DIR=gift-$(GIFT_VERSION)
GIFT_UNZIP=bzcat
GIFT_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFT_SECTION=net
GIFT_PRIORITY=optional
GIFT_DEPENDS=libogg, libvorbis, libtool
GIFT_DESCRIPTION=gIFt is a multi-platform multi-networks peer-to-peer client. gIFt runs as a daemon on the computer. It can be controlled using several interfaces.

#
# GIFT_IPK_VERSION should be incremented when the ipk changes.
#
GIFT_IPK_VERSION=4

#
# GIFT_CONFFILES should be a list of user-editable files
GIFT_CONFFILES=/opt/share/giFT/giftd.conf /opt/etc/init.d/S30giftd /usr/sbin/giftd_wrapper

#
# GIFT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFT_PATCHES=$(GIFT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFT_CPPFLAGS=
GIFT_LDFLAGS=

#
# GIFT_BUILD_DIR is the directory in which the build is done.
# GIFT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFT_IPK_DIR is the directory in which the ipk is built.
# GIFT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFT_BUILD_DIR=$(BUILD_DIR)/gift
GIFT_SOURCE_DIR=$(SOURCE_DIR)/gift
GIFT_IPK_DIR=$(BUILD_DIR)/gift-$(GIFT_VERSION)-ipk
GIFT_IPK=$(BUILD_DIR)/gift_$(GIFT_VERSION)-$(GIFT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFT_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIFT_SITE)/$(GIFT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-source: $(DL_DIR)/$(GIFT_SOURCE) $(GIFT_PATCHES)

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
$(GIFT_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFT_SOURCE) $(GIFT_PATCHES)
	$(MAKE) libogg-stage libvorbis-stage libtool-stage
	rm -rf $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR)
	$(GIFT_UNZIP) $(DL_DIR)/$(GIFT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFT_PATCHES) | patch -d $(BUILD_DIR)/$(GIFT_DIR) -p1
	mv $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR)
	(cd $(GIFT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFT_BUILD_DIR)/.configured

gift-unpack: $(GIFT_BUILD_DIR)/.configured

#
# This builds the actual binary.

$(GIFT_BUILD_DIR)/.built: $(GIFT_BUILD_DIR)/.configured
	rm -f $(GIFT_BUILD_DIR)/.built
	$(MAKE) -C $(GIFT_BUILD_DIR)
	touch $(GIFT_BUILD_DIR)/.built

gift: $(GIFT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GIFT_BUILD_DIR)/.staged: $(GIFT_BUILD_DIR)/.built
	rm -f $(GIFT_BUILD_DIR)/.staged
	$(MAKE) -C $(GIFT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_DIR)/opt/lib/libgift.la $(STAGING_DIR)/opt/lib/libgiftproto.la
	rm -f $(STAGING_DIR)/opt/bin/giftd $(STAGING_DIR)/opt/bin/gift-setup
	touch $(GIFT_BUILD_DIR)/.staged

gift-stage: $(GIFT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift
#
$(GIFT_IPK_DIR)/CONTROL/control:
	@install -d $(GIFT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gift" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFT_PRIORITY)" >>$@
	@echo "Section: $(GIFT_SECTION)" >>$@
	@echo "Version: $(GIFT_VERSION)-$(GIFT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFT_MAINTAINER)" >>$@
	@echo "Source: $(GIFT_SITE)/$(GIFT_SOURCE)" >>$@
	@echo "Description: $(GIFT_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFT_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFT_IPK_DIR)/opt/sbin or $(GIFT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFT_IPK_DIR)/opt/etc/gift/...
# Documentation files should be installed in $(GIFT_IPK_DIR)/opt/doc/gift/...
# Daemon startup scripts should be installed in $(GIFT_IPK_DIR)/opt/etc/init.d/S??gift
#
# You may need to patch your application to make it use these locations.
#
$(GIFT_IPK): $(GIFT_BUILD_DIR)/.built
	rm -rf $(GIFT_IPK_DIR) $(BUILD_DIR)/gift_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GIFT_BUILD_DIR) DESTDIR=$(GIFT_IPK_DIR) install-strip
	install -d $(GIFT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(GIFT_SOURCE_DIR)/S30giftd $(GIFT_IPK_DIR)/opt/etc/init.d/S30giftd
	install -d $(GIFT_IPK_DIR)/opt/sbin
	install -m 755 $(GIFT_SOURCE_DIR)/giftd_wrapper $(GIFT_IPK_DIR)/opt/sbin
	install -d $(GIFT_IPK_DIR)/CONTROL
	$(MAKE) $(GIFT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-ipk: $(GIFT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-clean:
	-$(MAKE) -C $(GIFT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFT_DIR) $(GIFT_BUILD_DIR) $(GIFT_IPK_DIR) $(GIFT_IPK)
