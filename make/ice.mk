###########################################################
#
# ice
#
###########################################################

#
# ICE_VERSION, ICE_SITE and ICE_SOURCE define
# the upstream location of the source code for the package.
# ICE_DIR is the directory which is created when the source
# archive is unpacked.
#
ICE_SITE=http://freedesktop.org
ICE_SOURCE=# none - available from CVS only
ICE_VERSION=6.3.5cvs20050130
ICE_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
ICE_DIR=ICE
ICE_CVS_OPTS=-D20050130
ICE_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
ICE_DESCRIPTION=X inter-client library
ICE_SECTION=lib
ICE_PRIORITY=optional
ICE_DEPENDS=

#
# ICE_IPK_VERSION should be incremented when the ipk changes.
#
ICE_IPK_VERSION=1

#
# ICE_CONFFILES should be a list of user-editable files
ICE_CONFFILES=

#
# ICE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ICE_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ICE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/X11/Xtrans
ICE_LDFLAGS=

#
# ICE_BUILD_DIR is the directory in which the build is done.
# ICE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ICE_IPK_DIR is the directory in which the ipk is built.
# ICE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ICE_BUILD_DIR=$(BUILD_DIR)/ice
ICE_SOURCE_DIR=$(SOURCE_DIR)/ice
ICE_IPK_DIR=$(BUILD_DIR)/ice-$(ICE_VERSION)-ipk
ICE_IPK=$(BUILD_DIR)/ice_$(ICE_VERSION)-$(ICE_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(ICE_IPK_DIR)/CONTROL/control:
	@install -d $(ICE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ice" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(ICE_PRIORITY)" >>$@
	@echo "Section: $(ICE_SECTION)" >>$@
	@echo "Version: $(ICE_VERSION)-$(ICE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ICE_MAINTAINER)" >>$@
	@echo "Source: $(ICE_SITE)/$(ICE_SOURCE)" >>$@
	@echo "Description: $(ICE_DESCRIPTION)" >>$@
	@echo "Depends: $(ICE_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(ICE_BUILD_DIR)/.fetched:
	rm -rf $(ICE_BUILD_DIR) $(BUILD_DIR)/$(ICE_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(ICE_REPOSITORY) -z3 co $(ICE_CVS_OPTS) $(ICE_DIR); \
	)
	mv $(BUILD_DIR)/$(ICE_DIR) $(ICE_BUILD_DIR)
	#cat $(ICE_PATCHES) | patch -d $(ICE_BUILD_DIR) -p0
	touch $@

ice-source: $(ICE_BUILD_DIR)/.fetched $(ICE_PATCHES)

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
$(ICE_BUILD_DIR)/.configured: $(ICE_BUILD_DIR)/.fetched $(ICE_PATCHES)
	$(MAKE) xproto-stage
	$(MAKE) xtrans-stage
	(cd $(ICE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ICE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ICE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		ACLOCAL=aclocal-1.9 \
		AUTOMAKE=automake-1.9 \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(ICE_BUILD_DIR)/.configured

ice-unpack: $(ICE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ICE_BUILD_DIR)/.built: $(ICE_BUILD_DIR)/.configured
	rm -f $(ICE_BUILD_DIR)/.built
	$(MAKE) -C $(ICE_BUILD_DIR)
	touch $(ICE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ice: $(ICE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ICE_BUILD_DIR)/.staged: $(ICE_BUILD_DIR)/.built
	rm -f $(ICE_BUILD_DIR)/.staged
	$(MAKE) -C $(ICE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libICE.la
	touch $(ICE_BUILD_DIR)/.staged

ice-stage: $(ICE_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(ICE_IPK_DIR)/opt/sbin or $(ICE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ICE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ICE_IPK_DIR)/opt/etc/ice/...
# Documentation files should be installed in $(ICE_IPK_DIR)/opt/doc/ice/...
# Daemon startup scripts should be installed in $(ICE_IPK_DIR)/opt/etc/init.d/S??ice
#
# You may need to patch your application to make it use these locations.
#
$(ICE_IPK): $(ICE_BUILD_DIR)/.built
	rm -rf $(ICE_IPK_DIR) $(BUILD_DIR)/ice_*_armeb.ipk
	$(MAKE) -C $(ICE_BUILD_DIR) DESTDIR=$(ICE_IPK_DIR) install-strip
	$(MAKE) $(ICE_IPK_DIR)/CONTROL/control
	rm -f $(ICE_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ICE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ice-ipk: $(ICE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ice-clean:
	-$(MAKE) -C $(ICE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ice-dirclean:
	rm -rf $(BUILD_DIR)/$(ICE_DIR) $(ICE_BUILD_DIR) $(ICE_IPK_DIR) $(ICE_IPK)
