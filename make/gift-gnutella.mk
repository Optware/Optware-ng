###########################################################
#
# gift-gnutella
#
###########################################################

# You must replace "gift-gnutella" and "GIFTGNUTELLA" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFTGNUTELLA_VERSION, GIFTGNUTELLA_SITE and GIFTGNUTELLA_SOURCE define
# the upstream location of the source code for the package.
# GIFTGNUTELLA_DIR is the directory which is created when the source
# archive is unpacked.
# GIFTGNUTELLA_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFTGNUTELLA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/gift
GIFTGNUTELLA_VERSION=0.0.11
GIFTGNUTELLA_SOURCE=gift-gnutella-$(GIFTGNUTELLA_VERSION).tar.bz2
GIFTGNUTELLA_DIR=gift-gnutella-$(GIFTGNUTELLA_VERSION)
GIFTGNUTELLA_UNZIP=bzcat
GIFTGNUTELLA_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFTGNUTELLA_SECTION=net
GIFTGNUTELLA_PRIORITY=optional
GIFTGNUTELLA_DEPENDS=gift, zlib
GIFTGNUTELLA_DESCRIPTION=gIFt Gnutella plugin

#
# GIFTGNUTELLA_IPK_VERSION should be incremented when the ipk changes.
#
GIFTGNUTELLA_IPK_VERSION=1

#
# GIFTGNUTELLA_CONFFILES should be a list of user-editable files
GIFTGNUTELLA_CONFFILES=/opt/etc/gift-gnutella.conf /opt/etc/init.d/SXXgift-gnutella

#
# GIFTGNUTELLA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFTGNUTELLA_PATCHES=$(GIFTGNUTELLA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFTGNUTELLA_CPPFLAGS=
GIFTGNUTELLA_LDFLAGS=

#
# GIFTGNUTELLA_BUILD_DIR is the directory in which the build is done.
# GIFTGNUTELLA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFTGNUTELLA_IPK_DIR is the directory in which the ipk is built.
# GIFTGNUTELLA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFTGNUTELLA_BUILD_DIR=$(BUILD_DIR)/gift-gnutella
GIFTGNUTELLA_SOURCE_DIR=$(SOURCE_DIR)/gift-gnutella
GIFTGNUTELLA_IPK_DIR=$(BUILD_DIR)/gift-gnutella-$(GIFTGNUTELLA_VERSION)-ipk
GIFTGNUTELLA_IPK=$(BUILD_DIR)/gift-gnutella_$(GIFTGNUTELLA_VERSION)-$(GIFTGNUTELLA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GIFTGNUTELLA_SOURCE):
	$(WGET) -P $(@D) $(GIFTGNUTELLA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-gnutella-source: $(DL_DIR)/$(GIFTGNUTELLA_SOURCE) $(GIFTGNUTELLA_PATCHES)

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
$(GIFTGNUTELLA_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFTGNUTELLA_SOURCE) $(GIFTGNUTELLA_PATCHES)
	$(MAKE) gift-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(GIFTGNUTELLA_DIR) $(@D)
	$(GIFTGNUTELLA_UNZIP) $(DL_DIR)/$(GIFTGNUTELLA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFTGNUTELLA_PATCHES) | patch -d $(BUILD_DIR)/$(GIFTGNUTELLA_DIR) -p1
	mv $(BUILD_DIR)/$(GIFTGNUTELLA_DIR) $(@D)
	(cd $(@D); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFTGNUTELLA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFTGNUTELLA_LDFLAGS)" \
		./configure \
		--with-zlib=$(STAGING_DIR)/opt \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

gift-gnutella-unpack: $(GIFTGNUTELLA_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(GIFTGNUTELLA_BUILD_DIR)/.built: $(GIFTGNUTELLA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
gift-gnutella: $(GIFTGNUTELLA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GIFTGNUTELLA_BUILD_DIR).staged: $(GIFTGNUTELLA_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/gift-gnutella.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/libgift-gnutella.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/libgift-gnutella.so.$(GIFTGNUTELLA_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-gnutella.so.$(GIFTGNUTELLA_VERSION) libgift-gnutella.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-gnutella.so.$(GIFTGNUTELLA_VERSION) libgift-gnutella.so
	touch $@

gift-gnutella-stage: $(GIFTGNUTELLA_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift-gnutella
#
$(GIFTGNUTELLA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gift-gnutella" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFTGNUTELLA_PRIORITY)" >>$@
	@echo "Section: $(GIFTGNUTELLA_SECTION)" >>$@
	@echo "Version: $(GIFTGNUTELLA_VERSION)-$(GIFTGNUTELLA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFTGNUTELLA_MAINTAINER)" >>$@
	@echo "Source: $(GIFTGNUTELLA_SITE)/$(GIFTGNUTELLA_SOURCE)" >>$@
	@echo "Description: $(GIFTGNUTELLA_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFTGNUTELLA_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFTGNUTELLA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFTGNUTELLA_IPK_DIR)/opt/sbin or $(GIFTGNUTELLA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFTGNUTELLA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFTGNUTELLA_IPK_DIR)/opt/etc/gift-gnutella/...
# Documentation files should be installed in $(GIFTGNUTELLA_IPK_DIR)/opt/doc/gift-gnutella/...
# Daemon startup scripts should be installed in $(GIFTGNUTELLA_IPK_DIR)/opt/etc/init.d/S??gift-gnutella
#
# You may need to patch your application to make it use these locations.
#
$(GIFTGNUTELLA_IPK): $(GIFTGNUTELLA_BUILD_DIR)/.built
	rm -rf $(GIFTGNUTELLA_IPK_DIR) $(BUILD_DIR)/gift-gnutella_*_$(TARGET_ARCH).ipk
	install -d $(GIFTGNUTELLA_IPK_DIR)/opt/lib/giFT
	$(STRIP_COMMAND) $(GIFTGNUTELLA_BUILD_DIR)/src/.libs/libGnutella.so -o $(GIFTGNUTELLA_IPK_DIR)/opt/lib/giFT/libGnutella.so
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/src/.libs/libGnutella.la $(GIFTGNUTELLA_IPK_DIR)/opt/lib/giFT/libGnutella.la
	install -d $(GIFTGNUTELLA_IPK_DIR)/opt/share/giFT/Gnutella
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/data/Gnutella.conf.template $(GIFTGNUTELLA_IPK_DIR)/opt/share/giFT/Gnutella/Gnutella.conf.template
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/data/hostiles.txt $(GIFTGNUTELLA_IPK_DIR)/opt/share/giFT/Gnutella/hostiles.txt
	install -m 644 $(GIFTGNUTELLA_BUILD_DIR)/data/gwebcaches $(GIFTGNUTELLA_IPK_DIR)/opt/share/giFT/Gnutella/gwebcaches
	install -d $(GIFTGNUTELLA_IPK_DIR)/CONTROL
	$(MAKE) $(GIFTGNUTELLA_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFTGNUTELLA_IPK_DIR)
# This is called from the top level makefile to create the IPK file.
#

gift-gnutella-ipk: $(GIFTGNUTELLA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-gnutella-clean:
	-$(MAKE) -C $(GIFTGNUTELLA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-gnutella-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFTGNUTELLA_DIR) $(GIFTGNUTELLA_BUILD_DIR) $(GIFTGNUTELLA_IPK_DIR) $(GIFTGNUTELLA_IPK)

#
# Some sanity check for the package.
#
gift-gnutella-check: $(GIFTGNUTELLA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GIFTGNUTELLA_IPK)
