###########################################################
#
# xpm
#
###########################################################

#
# XPM_VERSION, XPM_SITE and XPM_SOURCE define
# the upstream location of the source code for the package.
# XPM_DIR is the directory which is created when the source
# archive is unpacked.
#
XPM_SITE=http://freedesktop.org
XPM_SOURCE=# none - available from CVS only
XPM_VERSION=3.5.2+cvs20050130
XPM_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XPM_DIR=Xpm
XPM_CVS_OPTS=-D20050130
XPM_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XPM_DESCRIPTION=X11 pixmap library
XPM_SECTION=lib
XPM_PRIORITY=optional
XPM_DEPENDS=x11

#
# XPM_IPK_VERSION should be incremented when the ipk changes.
#
XPM_IPK_VERSION=2

#
# XPM_CONFFILES should be a list of user-editable files
XPM_CONFFILES=

#
# XPM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XPM_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XPM_CPPFLAGS=
XPM_LDFLAGS=
#
# XPM_BUILD_DIR is the directory in which the build is done.
# XPM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XPM_IPK_DIR is the directory in which the ipk is built.
# XPM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XPM_BUILD_DIR=$(BUILD_DIR)/xpm
XPM_SOURCE_DIR=$(SOURCE_DIR)/xpm
XPM_IPK_DIR=$(BUILD_DIR)/xpm-$(XPM_VERSION)-ipk
XPM_IPK=$(BUILD_DIR)/xpm_$(XPM_VERSION)-$(XPM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XPM_IPK_DIR)/CONTROL/control:
	@install -d $(XPM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xpm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XPM_PRIORITY)" >>$@
	@echo "Section: $(XPM_SECTION)" >>$@
	@echo "Version: $(XPM_VERSION)-$(XPM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XPM_MAINTAINER)" >>$@
	@echo "Source: $(XPM_SITE)/$(XPM_SOURCE)" >>$@
	@echo "Description: $(XPM_DESCRIPTION)" >>$@
	@echo "Depends: $(XPM_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xpm-$(XPM_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XPM_DIR) && \
		cvs -d $(XPM_REPOSITORY) -z3 co $(XPM_CVS_OPTS) $(XPM_DIR) && \
		tar -czf $@ $(XPM_DIR) && \
		rm -rf $(XPM_DIR) \
	)

xpm-source: $(DL_DIR)/xpm-$(XPM_VERSION).tar.gz $(XPM_PATCHES)

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
$(XPM_BUILD_DIR)/.configured: $(DL_DIR)/xpm-$(XPM_VERSION).tar.gz \
		$(STAGING_LIB_DIR)/libX11.so \
		$(XPM_PATCHES)
	rm -rf $(BUILD_DIR)/$(XPM_DIR) $(XPM_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xpm-$(XPM_VERSION).tar.gz
	if test -n "$(XPM_PATCHES)" ; \
		then cat $(XPM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XPM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(XPM_DIR)" != "$(XPM_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XPM_DIR) $(XPM_BUILD_DIR) ; \
	fi
	(cd $(XPM_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XPM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XPM_LDFLAGS)" \
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
	touch $(XPM_BUILD_DIR)/.configured

xpm-unpack: $(XPM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XPM_BUILD_DIR)/.built: $(XPM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XPM_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xpm: $(XPM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XPM_BUILD_DIR)/.staged:  $(XPM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XPM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xpm.pc
	rm -f $(STAGING_LIB_DIR)/libXpm.la
	touch $@

xpm-stage: $(XPM_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XPM_IPK_DIR)/opt/sbin or $(XPM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XPM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XPM_IPK_DIR)/opt/etc/xpm/...
# Documentation files should be installed in $(XPM_IPK_DIR)/opt/doc/xpm/...
# Daemon startup scripts should be installed in $(XPM_IPK_DIR)/opt/etc/init.d/S??xpm
#
# You may need to patch your application to make it use these locations.
#
$(XPM_IPK): $(XPM_BUILD_DIR)/.built
	rm -rf $(XPM_IPK_DIR) $(BUILD_DIR)/xpm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XPM_BUILD_DIR) DESTDIR=$(XPM_IPK_DIR) install-strip
	$(MAKE) $(XPM_IPK_DIR)/CONTROL/control
	rm -f $(XPM_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XPM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xpm-ipk: $(XPM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xpm-clean:
	-$(MAKE) -C $(XPM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xpm-dirclean:
	rm -rf $(BUILD_DIR)/$(XPM_DIR) $(XPM_BUILD_DIR) $(XPM_IPK_DIR) $(XPM_IPK)
