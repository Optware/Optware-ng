###########################################################
#
# x11
#
###########################################################

#
# X11_VERSION, X11_SITE and X11_SOURCE define
# the upstream location of the source code for the package.
# X11_DIR is the directory which is created when the source
# archive is unpacked.
#
X11_SITE=http://freedesktop.org
X11_SOURCE=# none - available from CVS only
X11_VERSION=6.2.1+cvs20050209
X11_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
X11_DIR=X11
X11_CVS_OPTS=-D20050209
X11_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
X11_DESCRIPTION=X protocol library
X11_SECTION=lib
X11_PRIORITY=optional
X11_DEPENDS=xau, xdmcp

#
# X11_IPK_VERSION should be incremented when the ipk changes.
#
X11_IPK_VERSION=3

#
# X11_CONFFILES should be a list of user-editable files
X11_CONFFILES=

#
# X11_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
X11_PATCHES=$(X11_SOURCE_DIR)/localedir.patch $(X11_SOURCE_DIR)/find-keysymdef.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifneq ($(OPTWARE_TARGET), wl500g)
X11_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/X11/Xtrans
else
X11_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/X11/Xtrans -DMB_CUR_MAX=1
endif
X11_LDFLAGS=

#
# X11_BUILD_DIR is the directory in which the build is done.
# X11_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# X11_IPK_DIR is the directory in which the ipk is built.
# X11_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
X11_BUILD_DIR=$(BUILD_DIR)/x11
X11_SOURCE_DIR=$(SOURCE_DIR)/x11
X11_IPK_DIR=$(BUILD_DIR)/x11-$(X11_VERSION)-ipk
X11_IPK=$(BUILD_DIR)/x11_$(X11_VERSION)-$(X11_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(X11_IPK_DIR)/CONTROL/control:
	@install -d $(X11_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: x11" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(X11_PRIORITY)" >>$@
	@echo "Section: $(X11_SECTION)" >>$@
	@echo "Version: $(X11_VERSION)-$(X11_IPK_VERSION)" >>$@
	@echo "Maintainer: $(X11_MAINTAINER)" >>$@
	@echo "Source: $(X11_SITE)/$(X11_SOURCE)" >>$@
	@echo "Description: $(X11_DESCRIPTION)" >>$@
	@echo "Depends: $(X11_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/x11-$(X11_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(X11_DIR) && \
		cvs -d $(X11_REPOSITORY) -z3 co $(X11_CVS_OPTS) $(X11_DIR) && \
		tar -czf $@ $(X11_DIR) && \
		rm -rf $(X11_DIR) \
	)

x11-source: $(DL_DIR)/x11-$(X11_VERSION).tar.gz $(X11_PATCHES)

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
$(X11_BUILD_DIR)/.configured: $(DL_DIR)/x11-$(X11_VERSION).tar.gz $(X11_PATCHES) make/x11.mk
	$(MAKE) xproto-stage
	$(MAKE) xau-stage
	$(MAKE) xextensions-stage
	$(MAKE) xdmcp-stage
	$(MAKE) xtrans-stage
	rm -rf $(BUILD_DIR)/$(X11_DIR) $(X11_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/x11-$(X11_VERSION).tar.gz
	if test -n "$(X11_PATCHES)" ; \
		then cat $(X11_PATCHES) | \
		patch -d $(BUILD_DIR)/$(X11_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(X11_DIR)" != "$(X11_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(X11_DIR) $(X11_BUILD_DIR) ; \
	fi
	(cd $(X11_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(X11_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(X11_LDFLAGS)" \
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
	touch $(X11_BUILD_DIR)/.configured

x11-unpack: $(X11_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(X11_BUILD_DIR)/.built: $(X11_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(X11_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
x11: $(X11_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(X11_BUILD_DIR)/.staged: $(X11_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(X11_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/x11.pc
	rm -f $(STAGING_LIB_DIR)/libX11.la
	touch $@

x11-stage: $(X11_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(X11_IPK_DIR)/opt/sbin or $(X11_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(X11_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(X11_IPK_DIR)/opt/etc/x11/...
# Documentation files should be installed in $(X11_IPK_DIR)/opt/doc/x11/...
# Daemon startup scripts should be installed in $(X11_IPK_DIR)/opt/etc/init.d/S??x11
#
# You may need to patch your application to make it use these locations.
#
$(X11_IPK): $(X11_BUILD_DIR)/.built
	rm -rf $(X11_IPK_DIR) $(BUILD_DIR)/x11_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(X11_BUILD_DIR) DESTDIR=$(X11_IPK_DIR) install-strip
	$(MAKE) $(X11_IPK_DIR)/CONTROL/control
	install -m 644 $(X11_SOURCE_DIR)/postinst $(X11_IPK_DIR)/CONTROL/postinst
	rm -f $(X11_IPK_DIR)/opt/lib/*.la
	cd $(BUILD_DIR); $(IPKG_BUILD) $(X11_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
x11-ipk: $(X11_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
x11-clean:
	-$(MAKE) -C $(X11_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
x11-dirclean:
	rm -rf $(BUILD_DIR)/$(X11_DIR) $(X11_BUILD_DIR) $(X11_IPK_DIR) $(X11_IPK)
