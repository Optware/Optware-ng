###########################################################
#
# giFT-FastTrack
#
###########################################################

# You must replace "giFT-FastTrack" and "GIFTFASTTRACK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFTFASTTRACK_VERSION, GIFTFASTTRACK_SITE and GIFTFASTTRACK_SOURCE define
# the upstream location of the source code for the package.
# GIFTFASTTRACK_DIR is the directory which is created when the source
# archive is unpacked.
# GIFTFASTTRACK_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFTFASTTRACK_SITE=http://download.berlios.de/gift-fasttrack
GIFTFASTTRACK_VERSION=0.8.9
GIFTFASTTRACK_SOURCE=giFT-FastTrack-$(GIFTFASTTRACK_VERSION).tar.gz
GIFTFASTTRACK_DIR_REMOTE=giFT-FastTrack-$(GIFTFASTTRACK_VERSION)
GIFTFASTTRACK_DIR=gift-fasttrack-$(GIFTFASTTRACK_VERSION)
GIFTFASTTRACK_UNZIP=zcat
GIFTFASTTRACK_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFTFASTTRACK_SECTION=net
GIFTFASTTRACK_PRIORITY=optional
GIFTFASTTRACK_DEPENDS=gift
GIFTFASTTRACK_DESCRIPTION=gIFt fasttrack plugin

#
# GIFTFASTTRACK_IPK_VERSION should be incremented when the ipk changes.
#
GIFTFASTTRACK_IPK_VERSION=1

#
# GIFTFASTTRACK_CONFFILES should be a list of user-editable files
GIFTFASTTRACK_CONFFILES=/opt/etc/giFT-FastTrack.conf /opt/etc/init.d/SXXgiFT-FastTrack

#
# GIFTFASTTRACK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFTFASTTRACK_PATCHES=$(GIFTFASTTRACK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFTFASTTRACK_CPPFLAGS=
GIFTFASTTRACK_LDFLAGS=

#
# GIFTFASTTRACK_BUILD_DIR is the directory in which the build is done.
# GIFTFASTTRACK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFTFASTTRACK_IPK_DIR is the directory in which the ipk is built.
# GIFTFASTTRACK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFTFASTTRACK_BUILD_DIR=$(BUILD_DIR)/gift-fasttrack
GIFTFASTTRACK_SOURCE_DIR=$(SOURCE_DIR)/gift-fasttrack
GIFTFASTTRACK_IPK_DIR=$(BUILD_DIR)/gift-fasttrack-$(GIFTFASTTRACK_VERSION)-ipk
GIFTFASTTRACK_IPK=$(BUILD_DIR)/gift-fasttrack_$(GIFTFASTTRACK_VERSION)-$(GIFTFASTTRACK_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFTFASTTRACK_SOURCE):
	$(WGET) -P $(DL_DIR) $(GIFTFASTTRACK_SITE)/$(GIFTFASTTRACK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-fasttrack-source: $(DL_DIR)/$(GIFTFASTTRACK_SOURCE) $(GIFTFASTTRACK_PATCHES)

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
$(GIFTFASTTRACK_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFTFASTTRACK_SOURCE) $(GIFTFASTTRACK_PATCHES)
	$(MAKE) gift-stage
	rm -rf $(BUILD_DIR)/$(GIFTFASTTRACK_DIR) $(GIFTFASTTRACK_BUILD_DIR)
	$(GIFTFASTTRACK_UNZIP) $(DL_DIR)/$(GIFTFASTTRACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFTFASTTRACK_PATCHES) | patch -d $(BUILD_DIR)/$(GIFTFASTTRACK_DIR) -p1
	mv $(BUILD_DIR)/$(GIFTFASTTRACK_DIR_REMOTE) $(GIFTFASTTRACK_BUILD_DIR)
	(cd $(GIFTFASTTRACK_BUILD_DIR); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFTFASTTRACK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFTFASTTRACK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFTFASTTRACK_BUILD_DIR)/.configured

gift-fasttrack-unpack: $(GIFTFASTTRACK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIFTFASTTRACK_BUILD_DIR)/.built: $(GIFTFASTTRACK_BUILD_DIR)/.configured
	rm -f $(GIFTFASTTRACK_BUILD_DIR)/.built
	$(MAKE) -C $(GIFTFASTTRACK_BUILD_DIR)
	touch $(GIFTFASTTRACK_BUILD_DIR)/.built

gift-fasttrack: $(GIFTFASTTRACK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgiFT-FastTrack.so.$(GIFTFASTTRACK_VERSION): $(GIFTFASTTRACK_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/giFT-FastTrack.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/libgiFT-FastTrack.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/libgiFT-FastTrack.so.$(GIFTFASTTRACK_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiFT-FastTrack.so.$(GIFTFASTTRACK_VERSION) libgiFT-FastTrack.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgiFT-FastTrack.so.$(GIFTFASTTRACK_VERSION) libgiFT-FastTrack.so

giFT-FastTrack-stage: $(STAGING_DIR)/opt/lib/libgiFT-FastTrack.so.$(GIFTFASTTRACK_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift-fasttrack
#
$(GIFTFASTTRACK_IPK_DIR)/CONTROL/control:
	@install -d $(GIFTFASTTRACK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gift-fasttrack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFTFASTTRACK_PRIORITY)" >>$@
	@echo "Section: $(GIFTFASTTRACK_SECTION)" >>$@
	@echo "Version: $(GIFTFASTTRACK_VERSION)-$(GIFTFASTTRACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFTFASTTRACK_MAINTAINER)" >>$@
	@echo "Source: $(GIFTFASTTRACK_SITE)/$(GIFTFASTTRACK_SOURCE)" >>$@
	@echo "Description: $(GIFTFASTTRACK_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFTFASTTRACK_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFTFASTTRACK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFTFASTTRACK_IPK_DIR)/opt/sbin or $(GIFTFASTTRACK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFTFASTTRACK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFTFASTTRACK_IPK_DIR)/opt/etc/giFT-FastTrack/...
# Documentation files should be installed in $(GIFTFASTTRACK_IPK_DIR)/opt/doc/giFT-FastTrack/...
# Daemon startup scripts should be installed in $(GIFTFASTTRACK_IPK_DIR)/opt/etc/init.d/S??giFT-FastTrack
#
# You may need to patch your application to make it use these locations.
#
$(GIFTFASTTRACK_IPK): $(GIFTFASTTRACK_BUILD_DIR)/.built
	rm -rf $(GIFTFASTTRACK_IPK_DIR) $(BUILD_DIR)/gift-fasttrack_*_$(TARGET_ARCH).ipk
	install -d $(GIFTFASTTRACK_IPK_DIR)/opt/lib/giFT
	$(STRIP_COMMAND) $(GIFTFASTTRACK_BUILD_DIR)/src/.libs/libFastTrack.so -o $(GIFTFASTTRACK_IPK_DIR)/opt/lib/giFT/libFastTrack.so
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/src/.libs/libFastTrack.la $(GIFTFASTTRACK_IPK_DIR)/opt/lib/giFT/libFastTrack.la
	install -d $(GIFTFASTTRACK_IPK_DIR)/opt/share/giFT/FastTrack
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/data/FastTrack.conf.template $(GIFTFASTTRACK_IPK_DIR)/opt/share/giFT/FastTrack/FastTrack.conf.template
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/data/banlist $(GIFTFASTTRACK_IPK_DIR)/opt/share/giFT/FastTrack/banlist
	install -m 644 $(GIFTFASTTRACK_BUILD_DIR)/data/nodes $(GIFTFASTTRACK_IPK_DIR)/opt/share/giFT/FastTrack/nodes
	install -d $(GIFTFASTTRACK_IPK_DIR)/CONTROL
	$(MAKE) $(GIFTFASTTRACK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFTFASTTRACK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-fasttrack-ipk: $(GIFTFASTTRACK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-fasttrack-clean:
	-$(MAKE) -C $(GIFTFASTTRACK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-fasttrack-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFTFASTTRACK_DIR) $(GIFTFASTTRACK_BUILD_DIR) $(GIFTFASTTRACK_IPK_DIR) $(GIFTFASTTRACK_IPK)
