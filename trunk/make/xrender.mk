###########################################################
#
# xrender
#
###########################################################

#
# XRENDER_VERSION, XRENDER_SITE and XRENDER_SOURCE define
# the upstream location of the source code for the package.
# XRENDER_DIR is the directory which is created when the source
# archive is unpacked.
#
XRENDER_SITE=http://freedesktop.org
XRENDER_SOURCE=# none - available from CVS only
XRENDER_VERSION=0.8.4+cvs20050130
XRENDER_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XRENDER_DIR=Xrender
XRENDER_CVS_OPTS=-D20050130
XRENDER_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XRENDER_DESCRIPTION=X render extension library
XRENDER_SECTION=lib
XRENDER_PRIORITY=optional
XRENDER_DEPENDS=x11

#
# XRENDER_IPK_VERSION should be incremented when the ipk changes.
#
XRENDER_IPK_VERSION=4

#
# XRENDER_CONFFILES should be a list of user-editable files
XRENDER_CONFFILES=

#
# XRENDER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XRENDER_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XRENDER_CPPFLAGS=
XRENDER_LDFLAGS=

#
# XRENDER_BUILD_DIR is the directory in which the build is done.
# XRENDER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XRENDER_IPK_DIR is the directory in which the ipk is built.
# XRENDER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XRENDER_BUILD_DIR=$(BUILD_DIR)/xrender
XRENDER_SOURCE_DIR=$(SOURCE_DIR)/xrender
XRENDER_IPK_DIR=$(BUILD_DIR)/xrender-$(XRENDER_VERSION)-ipk
XRENDER_IPK=$(BUILD_DIR)/xrender_$(XRENDER_VERSION)-$(XRENDER_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XRENDER_IPK_DIR)/CONTROL/control:
	@install -d $(XRENDER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xrender" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XRENDER_PRIORITY)" >>$@
	@echo "Section: $(XRENDER_SECTION)" >>$@
	@echo "Version: $(XRENDER_VERSION)-$(XRENDER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XRENDER_MAINTAINER)" >>$@
	@echo "Source: $(XRENDER_SITE)/$(XRENDER_SOURCE)" >>$@
	@echo "Description: $(XRENDER_DESCRIPTION)" >>$@
	@echo "Depends: $(XRENDER_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xrender-$(XRENDER_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XRENDER_DIR) && \
		cvs -d $(XRENDER_REPOSITORY) -z3 co $(XRENDER_CVS_OPTS) $(XRENDER_DIR) && \
		tar -czf $@ $(XRENDER_DIR) && \
		rm -rf $(XRENDER_DIR) \
	)

xrender-source: $(DL_DIR)/xrender-$(XRENDER_VERSION).tar.gz $(XRENDER_PATCHES)

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
$(XRENDER_BUILD_DIR)/.configured: $(DL_DIR)/xrender-$(XRENDER_VERSION).tar.gz \
		$(STAGING_INCLUDE_DIR)/X11/extensions/renderproto.h \
		$(STAGING_LIB_DIR)/libX11.so \
		$(XRENDER_PATCHES) make/xrender.mk
	$(MAKE) renderext-stage
	rm -rf $(BUILD_DIR)/$(XRENDER_DIR) $(XRENDER_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xrender-$(XRENDER_VERSION).tar.gz
	if test -n "$(XRENDER_PATCHES)" ; \
		then cat $(XRENDER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XRENDER_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XRENDER_DIR)" != "$(XRENDER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XRENDER_DIR) $(XRENDER_BUILD_DIR) ; \
	fi
	(cd $(XRENDER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XRENDER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XRENDER_LDFLAGS)" \
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
	touch $(XRENDER_BUILD_DIR)/.configured

xrender-unpack: $(XRENDER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XRENDER_BUILD_DIR)/.built: $(XRENDER_BUILD_DIR)/.configured
	rm -f $(XRENDER_BUILD_DIR)/.built
	$(MAKE) -C $(XRENDER_BUILD_DIR)
	touch $(XRENDER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
xrender: $(XRENDER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XRENDER_BUILD_DIR)/.staged: $(XRENDER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XRENDER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xrender.pc
	rm -f $(STAGING_LIB_DIR)/libXrender.la
	touch $@

xrender-stage: $(XRENDER_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XRENDER_IPK_DIR)/opt/sbin or $(XRENDER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XRENDER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XRENDER_IPK_DIR)/opt/etc/xrender/...
# Documentation files should be installed in $(XRENDER_IPK_DIR)/opt/doc/xrender/...
# Daemon startup scripts should be installed in $(XRENDER_IPK_DIR)/opt/etc/init.d/S??xrender
#
# You may need to patch your application to make it use these locations.
#
$(XRENDER_IPK): $(XRENDER_BUILD_DIR)/.built
	rm -rf $(XRENDER_IPK_DIR) $(BUILD_DIR)/xrender_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XRENDER_BUILD_DIR) DESTDIR=$(XRENDER_IPK_DIR) install-strip
	rm -f $(XRENDER_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(XRENDER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XRENDER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xrender-ipk: $(XRENDER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xrender-clean:
	-$(MAKE) -C $(XRENDER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xrender-dirclean:
	rm -rf $(BUILD_DIR)/$(XRENDER_DIR) $(XRENDER_BUILD_DIR) $(XRENDER_IPK_DIR) $(XRENDER_IPK)
