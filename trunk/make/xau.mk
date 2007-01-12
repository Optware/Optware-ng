###########################################################
#
# xau
#
###########################################################

#
# XAU_VERSION, XAU_SITE and XAU_SOURCE define
# the upstream location of the source code for the package.
# XAU_DIR is the directory which is created when the source
# archive is unpacked.
#
XAU_SITE=http://freedesktop.org
XAU_SOURCE=# none - available from CVS only
XAU_VERSION=0.1.1+cvs20050130
XAU_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XAU_DIR=Xau
XAU_CVS_OPTS=-D20050130
XAU_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XAU_DESCRIPTION=X authorization library
XAU_SECTION=lib
XAU_PRIORITY=optional

#
# XAU_IPK_VERSION should be incremented when the ipk changes.
#
XAU_IPK_VERSION=2

#
# XAU_CONFFILES should be a list of user-editable files
XAU_CONFFILES=

#
# XAU_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XAU_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XAU_CPPFLAGS=
XAU_LDFLAGS=

#
# XAU_BUILD_DIR is the directory in which the build is done.
# XAU_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XAU_IPK_DIR is the directory in which the ipk is built.
# XAU_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XAU_BUILD_DIR=$(BUILD_DIR)/xau
XAU_SOURCE_DIR=$(SOURCE_DIR)/xau
XAU_IPK_DIR=$(BUILD_DIR)/xau-$(XAU_VERSION)-ipk
XAU_IPK=$(BUILD_DIR)/xau_$(XAU_VERSION)-$(XAU_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XAU_IPK_DIR)/CONTROL/control:
	@install -d $(XAU_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xau" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XAU_PRIORITY)" >>$@
	@echo "Section: $(XAU_SECTION)" >>$@
	@echo "Version: $(XAU_VERSION)-$(XAU_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XAU_MAINTAINER)" >>$@
	@echo "Source: $(XAU_SITE)/$(XAU_SOURCE)" >>$@
	@echo "Description: $(XAU_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xau-$(XAU_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XAU_DIR) && \
		cvs -d $(XAU_REPOSITORY) -z3 co $(XAU_CVS_OPTS) $(XAU_DIR) && \
		tar -czf $@ $(XAU_DIR) && \
		rm -rf $(XAU_DIR) \
	)

xau-source: $(DL_DIR)/xau-$(XAU_VERSION).tar.gz $(XAU_PATCHES)

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
$(XAU_BUILD_DIR)/.configured: $(DL_DIR)/xau-$(XAU_VERSION).tar.gz \
		$(XAU_PATCHES)
	$(MAKE) xproto-stage
	rm -rf $(BUILD_DIR)/$(XAU_DIR) $(XAU_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xau-$(XAU_VERSION).tar.gz
	if test -n "$(XAU_PATCHES)" ; \
		then cat $(XAU_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XAU_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XAU_DIR)" != "$(XAU_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XAU_DIR) $(XAU_BUILD_DIR) ; \
	fi
	(cd $(XAU_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XAU_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XAU_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(XAU_BUILD_DIR)/.configured

xau-unpack: $(XAU_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XAU_BUILD_DIR)/.built: $(XAU_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XAU_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xau: $(XAU_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XAU_BUILD_DIR)/.staged: $(XAU_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XAU_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libXau.la
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xau.pc
	touch $@

xau-stage: $(XAU_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XAU_IPK_DIR)/opt/sbin or $(XAU_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XAU_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XAU_IPK_DIR)/opt/etc/xau/...
# Documentation files should be installed in $(XAU_IPK_DIR)/opt/doc/xau/...
# Daemon startup scripts should be installed in $(XAU_IPK_DIR)/opt/etc/init.d/S??xau
#
# You may need to patch your application to make it use these locations.
#
$(XAU_IPK): $(XAU_BUILD_DIR)/.built
	rm -rf $(XAU_IPK_DIR) $(BUILD_DIR)/xau_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XAU_BUILD_DIR) DESTDIR=$(XAU_IPK_DIR) install-strip
	$(MAKE) $(XAU_IPK_DIR)/CONTROL/control
	rm -f $(XAU_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XAU_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xau-ipk: $(XAU_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xau-clean:
	-$(MAKE) -C $(XAU_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xau-dirclean:
	rm -rf $(BUILD_DIR)/$(XAU_DIR) $(XAU_BUILD_DIR) $(XAU_IPK_DIR) $(XAU_IPK)
