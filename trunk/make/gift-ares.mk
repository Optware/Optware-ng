###########################################################
#
# gift-ares
#
###########################################################

# You must replace "gift-ares" and "GIFTARES" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GIFTARES_VERSION, GIFTARES_SITE and GIFTARES_SOURCE define
# the upstream location of the source code for the package.
# GIFTARES_DIR is the directory which is created when the source
# archive is unpacked.
# GIFTARES_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GIFTARES_REPOSITORY=:pserver:anonymous@cvs.gift-ares.berlios.de:/cvsroot/gift-ares
GIFTARES_VERSION=20060130
GIFTARES_SOURCE=gift-ares-$(GIFTARES_VERSION).tar.gz
GIFTARES_DIR=gift-ares-$(GIFTARES_VERSION)
GIFTARES_TAG=-D 2006-01-30
GIFTARES_MODULE=gift-ares
GIFTARES_DIR=gift-ares-${GIFTARES_VERSION}
GIFTARES_UNZIP=zcat
GIFTARES_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
GIFTARES_SECTION=net
GIFTARES_PRIORITY=optional
GIFTARES_DEPENDS=gift
GIFTARES_DESCRIPTION=giFT ares plugin

#
# GIFTARES_IPK_VERSION should be incremented when the ipk changes.
#
GIFTARES_IPK_VERSION=1

#
# GIFTARES_CONFFILES should be a list of user-editable files
GIFTARES_CONFFILES=/opt/etc/gift-ares.conf /opt/etc/init.d/SXXgift-ares

#
# GIFTARES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GIFTARES_PATCHES=$(GIFTARES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GIFTARES_CPPFLAGS=
GIFTARES_LDFLAGS=

#
# GIFTARES_BUILD_DIR is the directory in which the build is done.
# GIFTARES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GIFTARES_IPK_DIR is the directory in which the ipk is built.
# GIFTARES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GIFTARES_BUILD_DIR=$(BUILD_DIR)/gift-ares
GIFTARES_SOURCE_DIR=$(SOURCE_DIR)/gift-ares
GIFTARES_IPK_DIR=$(BUILD_DIR)/gift-ares-$(GIFTARES_VERSION)-ipk
GIFTARES_IPK=$(BUILD_DIR)/gift-ares_$(GIFTARES_VERSION)-$(GIFTARES_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from cvs.
#
$(DL_DIR)/$(GIFTARES_SOURCE):
	cd $(DL_DIR) ; $(CVS) -z3 -d $(GIFTARES_REPOSITORY) co $(GIFTARES_TAG) $(GIFTARES_MODULE)
	mv $(DL_DIR)/$(GIFTARES_MODULE) $(DL_DIR)/$(GIFTARES_DIR)
	cd $(DL_DIR) ; tar zcvf $(GIFTARES_SOURCE) $(GIFTARES_DIR)
	rm -rf $(DL_DIR)/$(GIFTARES_DIR)

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(GIFTARES_SOURCE):
#	$(WGET) -P $(DL_DIR) $(GIFTARES_SITE)/$(GIFTARES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gift-ares-source: $(DL_DIR)/$(GIFTARES_SOURCE) $(GIFTARES_PATCHES)

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
$(GIFTARES_BUILD_DIR)/.configured: $(DL_DIR)/$(GIFTARES_SOURCE) $(GIFTARES_PATCHES)
	$(MAKE) gift-stage
	rm -rf $(BUILD_DIR)/$(GIFTARES_DIR) $(GIFTARES_BUILD_DIR)
	$(GIFTARES_UNZIP) $(DL_DIR)/$(GIFTARES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GIFTARES_PATCHES) | patch -d $(BUILD_DIR)/$(GIFTARES_DIR) -p1
	mv $(BUILD_DIR)/$(GIFTARES_DIR) $(GIFTARES_BUILD_DIR)
	(cd $(GIFTARES_BUILD_DIR); \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig";export PKG_CONFIG_PATH; \
		ACLOCAL="aclocal-1.4 -I m4" AUTOMAKE=automake-1.4 autoreconf -i -v; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GIFTARES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GIFTARES_LDFLAGS)" \
		./configure \
		--with-zlib=$(STAGING_DIR)/opt \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(GIFTARES_BUILD_DIR)/.configured

gift-ares-unpack: $(GIFTARES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GIFTARES_BUILD_DIR)/.built: $(GIFTARES_BUILD_DIR)/.configured
	rm -f $(GIFTARES_BUILD_DIR)/.built
	$(MAKE) -C $(GIFTARES_BUILD_DIR)
	touch $(GIFTARES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
gift-ares: $(GIFTARES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libgift-ares.so.$(GIFTARES_VERSION): $(GIFTARES_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(GIFTARES_BUILD_DIR)/gift-ares.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTARES_BUILD_DIR)/libgift-ares.a $(STAGING_DIR)/opt/lib
	install -m 644 $(GIFTARES_BUILD_DIR)/libgift-ares.so.$(GIFTARES_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-ares.so.$(GIFTARES_VERSION) libgift-ares.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libgift-ares.so.$(GIFTARES_VERSION) libgift-ares.so

gift-ares-stage: $(STAGING_DIR)/opt/lib/libgift-ares.so.$(GIFTARES_VERSION)

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gift-ares
#
$(GIFTARES_IPK_DIR)/CONTROL/control:
	@install -d $(GIFTARES_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: gift-ares" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GIFTARES_PRIORITY)" >>$@
	@echo "Section: $(GIFTARES_SECTION)" >>$@
	@echo "Version: $(GIFTARES_VERSION)-$(GIFTARES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GIFTARES_MAINTAINER)" >>$@
	@echo "Source: $(GIFTARES_SITE)/$(GIFTARES_SOURCE)" >>$@
	@echo "Description: $(GIFTARES_DESCRIPTION)" >>$@
	@echo "Depends: $(GIFTARES_DEPENDS)" >>$@
	@echo "Conflicts: $(GIFTARES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GIFTARES_IPK_DIR)/opt/sbin or $(GIFTARES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GIFTARES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GIFTARES_IPK_DIR)/opt/etc/gift-ares/...
# Documentation files should be installed in $(GIFTARES_IPK_DIR)/opt/doc/gift-ares/...
# Daemon startup scripts should be installed in $(GIFTARES_IPK_DIR)/opt/etc/init.d/S??gift-ares
#
# You may need to patch your application to make it use these locations.
#
$(GIFTARES_IPK): $(GIFTARES_BUILD_DIR)/.built
	rm -rf $(GIFTARES_IPK_DIR) $(BUILD_DIR)/gift-ares_*_$(TARGET_ARCH).ipk
	install -d $(GIFTARES_IPK_DIR)/opt/lib/giFT
	$(STRIP_COMMAND) $(GIFTARES_BUILD_DIR)/gift/.libs/libAres.so -o $(GIFTARES_IPK_DIR)/opt/lib/giFT/libAres.so
	install -m 644 $(GIFTARES_BUILD_DIR)/gift/.libs/libAres.la $(GIFTARES_IPK_DIR)/opt/lib/giFT/libAres.la
	install -d $(GIFTARES_IPK_DIR)/opt/share/giFT/Ares
	install -m 644 $(GIFTARES_BUILD_DIR)/data/Ares.conf.template $(GIFTARES_IPK_DIR)/opt/share/giFT/Ares/Ares.conf.template
	install -m 644 $(GIFTARES_BUILD_DIR)/data/nodes $(GIFTARES_IPK_DIR)/opt/share/giFT/Ares/nodes
	install -d $(GIFTARES_IPK_DIR)/CONTROL
	$(MAKE) $(GIFTARES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GIFTARES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gift-ares-ipk: $(GIFTARES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gift-ares-clean:
	-$(MAKE) -C $(GIFTARES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gift-ares-dirclean:
	rm -rf $(BUILD_DIR)/$(GIFTARES_DIR) $(GIFTARES_BUILD_DIR) $(GIFTARES_IPK_DIR) $(GIFTARES_IPK)
