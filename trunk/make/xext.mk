###########################################################
#
# xext
#
###########################################################

#
# XEXT_VERSION, XEXT_SITE and XEXT_SOURCE define
# the upstream location of the source code for the package.
# XEXT_DIR is the directory which is created when the source
# archive is unpacked.
#
XEXT_SITE=http://freedesktop.org
XEXT_SOURCE=# none - available from CVS only
XEXT_VERSION=6.4.3+cvs20050130
XEXT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XEXT_DIR=Xext
XEXT_CVS_OPTS=-D20050130
XEXT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XEXT_DESCRIPTION=X extensions library
XEXT_SECTION=lib
XEXT_PRIORITY=optional
XEXT_DEPENDS=x11

#
# XEXT_IPK_VERSION should be incremented when the ipk changes.
#
XEXT_IPK_VERSION=1

#
# XEXT_CONFFILES should be a list of user-editable files
XEXT_CONFFILES=

#
# XEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XEXT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XEXT_CPPFLAGS=
XEXT_LDFLAGS=

#
# XEXT_BUILD_DIR is the directory in which the build is done.
# XEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XEXT_IPK_DIR is the directory in which the ipk is built.
# XEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XEXT_BUILD_DIR=$(BUILD_DIR)/xext
XEXT_SOURCE_DIR=$(SOURCE_DIR)/xext
XEXT_IPK_DIR=$(BUILD_DIR)/xext-$(XEXT_VERSION)-ipk
XEXT_IPK=$(BUILD_DIR)/xext_$(XEXT_VERSION)-$(XEXT_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(XEXT_SOURCE_DIR)/control:
	@rm -f $@
	@mkdir -p $(XEXT_SOURCE_DIR) || true
	@echo "Package: xext" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(XEXT_PRIORITY)" >>$@
	@echo "Section: $(XEXT_SECTION)" >>$@
	@echo "Version: $(XEXT_VERSION)-$(XEXT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XEXT_MAINTAINER)" >>$@
	@echo "Source: $(XEXT_SITE)/$(XEXT_SOURCE)" >>$@
	@echo "Description: $(XEXT_DESCRIPTION)" >>$@
	@echo "Depends: $(XEXT_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(XEXT_BUILD_DIR)/.fetched:
	rm -rf $(XEXT_BUILD_DIR) $(BUILD_DIR)/$(XEXT_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(XEXT_REPOSITORY) -z3 co $(XEXT_CVS_OPTS) $(XEXT_DIR); \
	)
	mv $(BUILD_DIR)/$(XEXT_DIR) $(XEXT_BUILD_DIR)
	touch $@

xext-source: $(XEXT_BUILD_DIR)/.fetched $(XEXT_PATCHES)

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
$(XEXT_BUILD_DIR)/.configured: $(XEXT_BUILD_DIR)/.fetched $(XEXT_PATCHES)
	$(MAKE) x11-stage xextensions-stage
	(cd $(XEXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XEXT_LDFLAGS)" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(XEXT_BUILD_DIR)/.configured

xext-unpack: $(XEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XEXT_BUILD_DIR)/.built: $(XEXT_BUILD_DIR)/.configured
	rm -f $(XEXT_BUILD_DIR)/.built
	$(MAKE) -C $(XEXT_BUILD_DIR)
	touch $(XEXT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xext: $(XEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XEXT_BUILD_DIR)/.staged: $(XEXT_BUILD_DIR)/.built
	rm -f $(XEXT_BUILD_DIR)/.staged
	$(MAKE) -C $(XEXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libXext.la
	touch $(XEXT_BUILD_DIR)/.staged

xext-stage: $(XEXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XEXT_IPK_DIR)/opt/sbin or $(XEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XEXT_IPK_DIR)/opt/etc/xext/...
# Documentation files should be installed in $(XEXT_IPK_DIR)/opt/doc/xext/...
# Daemon startup scripts should be installed in $(XEXT_IPK_DIR)/opt/etc/init.d/S??xext
#
# You may need to patch your application to make it use these locations.
#
$(XEXT_IPK): $(XEXT_BUILD_DIR)/.built
	rm -rf $(XEXT_IPK_DIR) $(BUILD_DIR)/xext_*_armeb.ipk $(XEXT_SOURCE_DIR)/control
	$(MAKE) $(XEXT_SOURCE_DIR)/control
	$(MAKE) -C $(XEXT_BUILD_DIR) DESTDIR=$(XEXT_IPK_DIR) install-strip
	rm -f $(XEXT_IPK_DIR)/opt/lib/*.la
	install -d $(XEXT_IPK_DIR)/CONTROL
	install -m 644 $(XEXT_SOURCE_DIR)/control $(XEXT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xext-ipk: $(XEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xext-clean:
	-$(MAKE) -C $(XEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xext-dirclean:
	rm -rf $(BUILD_DIR)/$(XEXT_DIR) $(XEXT_BUILD_DIR) $(XEXT_IPK_DIR) $(XEXT_IPK) $(XEXT_SOURCE_DIR)/control
