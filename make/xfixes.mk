###########################################################
#
# xfixes
#
###########################################################

#
# XFIXES_VERSION, XFIXES_SITE and XFIXES_SOURCE define
# the upstream location of the source code for the package.
# XFIXES_DIR is the directory which is created when the source
# archive is unpacked.
#
XFIXES_SITE=http://freedesktop.org
XFIXES_SOURCE=# none - available from CVS only
XFIXES_VERSION=2.0.2+cvs20050130
XFIXES_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XFIXES_DIR=Xfixes
XFIXES_CVS_OPTS=-D20050130
XFIXES_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XFIXES_DESCRIPTION=X fixes extension library
XFIXES_SECTION=lib
XFIXES_PRIORITY=optional
XFIXES_DEPENDS=x11

#
# XFIXES_IPK_VERSION should be incremented when the ipk changes.
#
XFIXES_IPK_VERSION=1

#
# XFIXES_CONFFILES should be a list of user-editable files
XFIXES_CONFFILES=

#
# XFIXES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XFIXES_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XFIXES_CPPFLAGS=
XFIXES_LDFLAGS=

#
# XFIXES_BUILD_DIR is the directory in which the build is done.
# XFIXES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XFIXES_IPK_DIR is the directory in which the ipk is built.
# XFIXES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XFIXES_BUILD_DIR=$(BUILD_DIR)/xfixes
XFIXES_SOURCE_DIR=$(SOURCE_DIR)/xfixes
XFIXES_IPK_DIR=$(BUILD_DIR)/xfixes-$(XFIXES_VERSION)-ipk
XFIXES_IPK=$(BUILD_DIR)/xfixes_$(XFIXES_VERSION)-$(XFIXES_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(XFIXES_SOURCE_DIR)/control:
	@rm -f $@
	@mkdir -p $(XFIXES_SOURCE_DIR) || true
	@echo "Package: xfixes" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(XFIXES_PRIORITY)" >>$@
	@echo "Section: $(XFIXES_SECTION)" >>$@
	@echo "Version: $(XFIXES_VERSION)-$(XFIXES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XFIXES_MAINTAINER)" >>$@
	@echo "Source: $(XFIXES_SITE)/$(XFIXES_SOURCE)" >>$@
	@echo "Description: $(XFIXES_DESCRIPTION)" >>$@
	@echo "Depends: $(XFIXES_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(XFIXES_BUILD_DIR)/.fetched:
	rm -rf $(XFIXES_BUILD_DIR) $(BUILD_DIR)/$(XFIXES_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(XFIXES_REPOSITORY) -z3 co $(XFIXES_CVS_OPTS) $(XFIXES_DIR); \
	)
	mv $(BUILD_DIR)/$(XFIXES_DIR) $(XFIXES_BUILD_DIR)
	touch $@

xfixes-source: $(XFIXES_BUILD_DIR)/.fetched $(XFIXES_PATCHES)

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
$(XFIXES_BUILD_DIR)/.configured: $(XFIXES_BUILD_DIR)/.fetched $(XFIXES_PATCHES)
	$(MAKE) x11-stage fixesext-stage
	(cd $(XFIXES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XFIXES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XFIXES_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(XFIXES_BUILD_DIR)/.configured

xfixes-unpack: $(XFIXES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XFIXES_BUILD_DIR)/.built: $(XFIXES_BUILD_DIR)/.configured
	rm -f $(XFIXES_BUILD_DIR)/.built
	$(MAKE) -C $(XFIXES_BUILD_DIR)
	touch $(XFIXES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xfixes: $(XFIXES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XFIXES_BUILD_DIR)/.staged: $(XFIXES_BUILD_DIR)/.built
	rm -f $(XFIXES_BUILD_DIR)/.staged
	$(MAKE) -C $(XFIXES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libXfixes.la
	touch $(XFIXES_BUILD_DIR)/.staged

xfixes-stage: $(XFIXES_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XFIXES_IPK_DIR)/opt/sbin or $(XFIXES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XFIXES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XFIXES_IPK_DIR)/opt/etc/xfixes/...
# Documentation files should be installed in $(XFIXES_IPK_DIR)/opt/doc/xfixes/...
# Daemon startup scripts should be installed in $(XFIXES_IPK_DIR)/opt/etc/init.d/S??xfixes
#
# You may need to patch your application to make it use these locations.
#
$(XFIXES_IPK): $(XFIXES_BUILD_DIR)/.built
	rm -rf $(XFIXES_IPK_DIR) $(BUILD_DIR)/xfixes_*_armeb.ipk $(XFIXES_SOURCE_DIR)/control
	$(MAKE) $(XFIXES_SOURCE_DIR)/control
	$(MAKE) -C $(XFIXES_BUILD_DIR) DESTDIR=$(XFIXES_IPK_DIR) install-strip
	rm -f $(XFIXES_IPK_DIR)/opt/lib/*.la
	install -d $(XFIXES_IPK_DIR)/CONTROL
	install -m 644 $(XFIXES_SOURCE_DIR)/control $(XFIXES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XFIXES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xfixes-ipk: $(XFIXES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xfixes-clean:
	-$(MAKE) -C $(XFIXES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xfixes-dirclean:
	rm -rf $(BUILD_DIR)/$(XFIXES_DIR) $(XFIXES_BUILD_DIR) $(XFIXES_IPK_DIR) $(XFIXES_IPK) $(XFIXES_SOURCE_DIR)/control
