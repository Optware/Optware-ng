###########################################################
#
# xcursor
#
###########################################################

#
# XCURSOR_VERSION, XCURSOR_SITE and XCURSOR_SOURCE define
# the upstream location of the source code for the package.
# XCURSOR_DIR is the directory which is created when the source
# archive is unpacked.
#
XCURSOR_SITE=http://freedesktop.org
XCURSOR_SOURCE=# none - available from CVS only
XCURSOR_VERSION=1.1.3
XCURSOR_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XCURSOR_DIR=Xcursor
XCURSOR_CVS_OPTS=-r XCURSOR-1_1_3-RELEASE
XCURSOR_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XCURSOR_DESCRIPTION=X cursor library
XCURSOR_SECTION=lib
XCURSOR_PRIORITY=optional
XCURSOR_DEPENDS=x11, xrender, xfixes

#
# XCURSOR_IPK_VERSION should be incremented when the ipk changes.
#
XCURSOR_IPK_VERSION=2

#
# XCURSOR_CONFFILES should be a list of user-editable files
XCURSOR_CONFFILES=

#
# XCURSOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XCURSOR_PATCHES=$(XCURSOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XCURSOR_CPPFLAGS=
XCURSOR_LDFLAGS=

#
# XCURSOR_BUILD_DIR is the directory in which the build is done.
# XCURSOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XCURSOR_IPK_DIR is the directory in which the ipk is built.
# XCURSOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XCURSOR_BUILD_DIR=$(BUILD_DIR)/xcursor
XCURSOR_SOURCE_DIR=$(SOURCE_DIR)/xcursor
XCURSOR_IPK_DIR=$(BUILD_DIR)/xcursor-$(XCURSOR_VERSION)-ipk
XCURSOR_IPK=$(BUILD_DIR)/xcursor_$(XCURSOR_VERSION)-$(XCURSOR_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XCURSOR_IPK_DIR)/CONTROL/control:
	@install -d $(XCURSOR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xcursor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XCURSOR_PRIORITY)" >>$@
	@echo "Section: $(XCURSOR_SECTION)" >>$@
	@echo "Version: $(XCURSOR_VERSION)-$(XCURSOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XCURSOR_MAINTAINER)" >>$@
	@echo "Source: $(XCURSOR_SITE)/$(XCURSOR_SOURCE)" >>$@
	@echo "Description: $(XCURSOR_DESCRIPTION)" >>$@
	@echo "Depends: $(XCURSOR_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xcursor-$(XCURSOR_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XCURSOR_DIR) && \
		cvs -d $(XCURSOR_REPOSITORY) -z3 co $(XCURSOR_CVS_OPTS) $(XCURSOR_DIR) && \
		tar -czf $@ $(XCURSOR_DIR) && \
		rm -rf $(XCURSOR_DIR) \
	)

xcursor-source: $(DL_DIR)/xcursor-$(XCURSOR_VERSION).tar.gz $(XCURSOR_PATCHES)

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
$(XCURSOR_BUILD_DIR)/.configured: $(DL_DIR)/xcursor-$(XCURSOR_VERSION).tar.gz \
		$(STAGING_LIB_DIR)/libX11.so \
		$(STAGING_LIB_DIR)/libXrender.so \
		$(STAGING_LIB_DIR)/libXfixes.so \
		$(XCURSOR_PATCHES)
	rm -rf $(BUILD_DIR)/$(XCURSOR_DIR) $(XCURSOR_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xcursor-$(XCURSOR_VERSION).tar.gz
	if test -n "$(XCURSOR_PATCHES)" ; \
		then cat $(XCURSOR_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XCURSOR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XCURSOR_DIR)" != "$(XCURSOR_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XCURSOR_DIR) $(XCURSOR_BUILD_DIR) ; \
	fi
	(cd $(XCURSOR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XCURSOR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XCURSOR_LDFLAGS)" \
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
	touch $(XCURSOR_BUILD_DIR)/.configured

xcursor-unpack: $(XCURSOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XCURSOR_BUILD_DIR)/.built: $(XCURSOR_BUILD_DIR)/.configured
	rm -f $(XCURSOR_BUILD_DIR)/.built
	$(MAKE) -C $(XCURSOR_BUILD_DIR)
	touch $(XCURSOR_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xcursor: $(XCURSOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XCURSOR_BUILD_DIR)/.staged: $(XCURSOR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XCURSOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xcursor.pc
	rm -f $(STAGING_LIB_DIR)/libXcursor.la
	touch $@

xcursor-stage: $(XCURSOR_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XCURSOR_IPK_DIR)/opt/sbin or $(XCURSOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XCURSOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XCURSOR_IPK_DIR)/opt/etc/xcursor/...
# Documentation files should be installed in $(XCURSOR_IPK_DIR)/opt/doc/xcursor/...
# Daemon startup scripts should be installed in $(XCURSOR_IPK_DIR)/opt/etc/init.d/S??xcursor
#
# You may need to patch your application to make it use these locations.
#
$(XCURSOR_IPK): $(XCURSOR_BUILD_DIR)/.built
	rm -rf $(XCURSOR_IPK_DIR) $(BUILD_DIR)/xcursor_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XCURSOR_BUILD_DIR) DESTDIR=$(XCURSOR_IPK_DIR) install-strip
	$(MAKE) $(XCURSOR_IPK_DIR)/CONTROL/control
	rm -f $(XCURSOR_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XCURSOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xcursor-ipk: $(XCURSOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xcursor-clean:
	-$(MAKE) -C $(XCURSOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xcursor-dirclean:
	rm -rf $(BUILD_DIR)/$(XCURSOR_DIR) $(XCURSOR_BUILD_DIR) $(XCURSOR_IPK_DIR) $(XCURSOR_IPK)
