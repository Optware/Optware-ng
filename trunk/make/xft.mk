###########################################################
#
# xft
#
###########################################################

#
# XFT_VERSION, XFT_SITE and XFT_SOURCE define
# the upstream location of the source code for the package.
# XFT_DIR is the directory which is created when the source
# archive is unpacked.
#
XFT_SITE=http://freedesktop.org
XFT_SOURCE=# none - available from CVS only
XFT_VERSION=2.1.6+cvs20050130
XFT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XFT_DIR=Xft
XFT_CVS_OPTS=-D20050130
XFT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XFT_DESCRIPTION=X11 client-side font library
XFT_SECTION=lib
XFT_PRIORITY=optional
XFT_DEPENDS=x11, xrender, freetype, fontconfig

#
# XFT_IPK_VERSION should be incremented when the ipk changes.
#
XFT_IPK_VERSION=1

#
# XFT_CONFFILES should be a list of user-editable files
XFT_CONFFILES=

#
# XFT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XFT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XFT_CPPFLAGS=
XFT_LDFLAGS=

#
# XFT_BUILD_DIR is the directory in which the build is done.
# XFT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XFT_IPK_DIR is the directory in which the ipk is built.
# XFT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XFT_BUILD_DIR=$(BUILD_DIR)/xft
XFT_SOURCE_DIR=$(SOURCE_DIR)/xft
XFT_IPK_DIR=$(BUILD_DIR)/xft-$(XFT_VERSION)-ipk
XFT_IPK=$(BUILD_DIR)/xft_$(XFT_VERSION)-$(XFT_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(XFT_SOURCE_DIR)/control:
	@rm -f $@
	@mkdir -p $(XFT_SOURCE_DIR) || true
	@echo "Package: xft" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(XFT_PRIORITY)" >>$@
	@echo "Section: $(XFT_SECTION)" >>$@
	@echo "Version: $(XFT_VERSION)-$(XFT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XFT_MAINTAINER)" >>$@
	@echo "Source: $(XFT_SITE)/$(XFT_SOURCE)" >>$@
	@echo "Description: $(XFT_DESCRIPTION)" >>$@
	@echo "Depends: $(XFT_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(XFT_BUILD_DIR)/.fetched:
	rm -rf $(XFT_BUILD_DIR) $(BUILD_DIR)/$(XFT_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(XFT_REPOSITORY) -z3 co $(XFT_CVS_OPTS) $(XFT_DIR); \
	)
	mv $(BUILD_DIR)/$(XFT_DIR) $(XFT_BUILD_DIR)
	touch $@

xft-source: $(XFT_BUILD_DIR)/.fetched $(XFT_PATCHES)

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
$(XFT_BUILD_DIR)/.configured: $(XFT_BUILD_DIR)/.fetched $(XFT_PATCHES)
	$(MAKE) x11-stage xrender-stage freetype-stage fontconfig-stage
	(cd $(XFT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XFT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XFT_LDFLAGS)" \
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
	touch $(XFT_BUILD_DIR)/.configured

xft-unpack: $(XFT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XFT_BUILD_DIR)/.built: $(XFT_BUILD_DIR)/.configured
	rm -f $(XFT_BUILD_DIR)/.built
	$(MAKE) -C $(XFT_BUILD_DIR)
	touch $(XFT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xft: $(XFT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XFT_BUILD_DIR)/.staged: $(XFT_BUILD_DIR)/.built
	rm -f $(XFT_BUILD_DIR)/.staged
	$(MAKE) -C $(XFT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libXft.la
	touch $(XFT_BUILD_DIR)/.staged

xft-stage: $(XFT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XFT_IPK_DIR)/opt/sbin or $(XFT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XFT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XFT_IPK_DIR)/opt/etc/xft/...
# Documentation files should be installed in $(XFT_IPK_DIR)/opt/doc/xft/...
# Daemon startup scripts should be installed in $(XFT_IPK_DIR)/opt/etc/init.d/S??xft
#
# You may need to patch your application to make it use these locations.
#
$(XFT_IPK): $(XFT_BUILD_DIR)/.built
	rm -rf $(XFT_IPK_DIR) $(BUILD_DIR)/xft_*_armeb.ipk $(XFT_SOURCE_DIR)/control
	$(MAKE) $(XFT_SOURCE_DIR)/control
	$(MAKE) -C $(XFT_BUILD_DIR) DESTDIR=$(XFT_IPK_DIR) install-strip
	rm -f $(XFT_IPK_DIR)/opt/lib/*.la
	install -d $(XFT_IPK_DIR)/CONTROL
	install -m 644 $(XFT_SOURCE_DIR)/control $(XFT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XFT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xft-ipk: $(XFT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xft-clean:
	-$(MAKE) -C $(XFT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xft-dirclean:
	rm -rf $(BUILD_DIR)/$(XFT_DIR) $(XFT_BUILD_DIR) $(XFT_IPK_DIR) $(XFT_IPK) $(XFT_SOURCE_DIR)/control
