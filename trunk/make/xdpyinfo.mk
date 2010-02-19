###########################################################
#
# xdpyinfo
#
###########################################################

#
# XDPYINFO_VERSION, XDPYINFO_SITE and XDPYINFO_SOURCE define
# the upstream location of the source code for the package.
# XDPYINFO_DIR is the directory which is created when the source
# archive is unpacked.
#
XDPYINFO_SITE=http://freedesktop.org
XDPYINFO_SOURCE=# none - available from CVS only
XDPYINFO_VERSION=0.0cvs20050130
XDPYINFO_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xapps
XDPYINFO_DIR=xdpyinfo
XDPYINFO_CVS_OPTS=-D20050130
XDPYINFO_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XDPYINFO_DESCRIPTION=X display information utility
XDPYINFO_SECTION=utility
XDPYINFO_PRIORITY=optional
XDPYINFO_DEPENDS=x11, xext, xtst

#
# XDPYINFO_IPK_VERSION should be incremented when the ipk changes.
#
XDPYINFO_IPK_VERSION=1

#
# XDPYINFO_CONFFILES should be a list of user-editable files
XDPYINFO_CONFFILES=

#
# XDPYINFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XDPYINFO_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XDPYINFO_CPPFLAGS=
XDPYINFO_LDFLAGS=-Wl,-rpath-link $(STAGING_LIB_DIR)

#
# XDPYINFO_BUILD_DIR is the directory in which the build is done.
# XDPYINFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XDPYINFO_IPK_DIR is the directory in which the ipk is built.
# XDPYINFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XDPYINFO_BUILD_DIR=$(BUILD_DIR)/xdpyinfo
XDPYINFO_SOURCE_DIR=$(SOURCE_DIR)/xdpyinfo
XDPYINFO_IPK_DIR=$(BUILD_DIR)/xdpyinfo-$(XDPYINFO_VERSION)-ipk
XDPYINFO_IPK=$(BUILD_DIR)/xdpyinfo_$(XDPYINFO_VERSION)-$(XDPYINFO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XDPYINFO_IPK_DIR)/CONTROL/control:
	@install -d $(XDPYINFO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xdpyinfo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XDPYINFO_PRIORITY)" >>$@
	@echo "Section: $(XDPYINFO_SECTION)" >>$@
	@echo "Version: $(XDPYINFO_VERSION)-$(XDPYINFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XDPYINFO_MAINTAINER)" >>$@
	@echo "Source: $(XDPYINFO_SITE)/$(XDPYINFO_SOURCE)" >>$@
	@echo "Description: $(XDPYINFO_DESCRIPTION)" >>$@
	@echo "Depends: $(XDPYINFO_DEPENDS)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xdpyinfo-$(XDPYINFO_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XDPYINFO_DIR) && \
		cvs -d $(XDPYINFO_REPOSITORY) -z3 co $(XDPYINFO_CVS_OPTS) $(XDPYINFO_DIR) && \
		tar -czf $@ $(XDPYINFO_DIR) && \
		rm -rf $(XDPYINFO_DIR) \
	)

xdpyinfo-source: $(DL_DIR)/xdpyinfo-$(XDPYINFO_VERSION).tar.gz $(XDPYINFO_PATCHES)

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
$(XDPYINFO_BUILD_DIR)/.configured: $(DL_DIR)/xdpyinfo-$(XDPYINFO_VERSION).tar.gz  \
		$(XDPYINFO_PATCHES) make/xdpyinfo.mk
	$(MAKE) x11-stage
	$(MAKE) xext-stage
	$(MAKE) xtst-stage
	rm -rf $(BUILD_DIR)/$(XDPYINFO_DIR) $(XDPYINFO_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xdpyinfo-$(XDPYINFO_VERSION).tar.gz
	if test -n "$(XDPYINFO_PATCHES)" ; \
		then cat $(XDPYINFO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XDPYINFO_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XDPYINFO_DIR)" != "$(XDPYINFO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XDPYINFO_DIR) $(XDPYINFO_BUILD_DIR) ; \
	fi
	(cd $(XDPYINFO_BUILD_DIR); \
		autoreconf -v --install; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XDPYINFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XDPYINFO_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $@

xdpyinfo-unpack: $(XDPYINFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XDPYINFO_BUILD_DIR)/.built: $(XDPYINFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XDPYINFO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xdpyinfo: $(XDPYINFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XDPYINFO_BUILD_DIR)/.staged: $(XDPYINFO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XDPYINFO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

xdpyinfo-stage: $(XDPYINFO_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XDPYINFO_IPK_DIR)/opt/sbin or $(XDPYINFO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XDPYINFO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XDPYINFO_IPK_DIR)/opt/etc/xdpyinfo/...
# Documentation files should be installed in $(XDPYINFO_IPK_DIR)/opt/doc/xdpyinfo/...
# Daemon startup scripts should be installed in $(XDPYINFO_IPK_DIR)/opt/etc/init.d/S??xdpyinfo
#
# You may need to patch your application to make it use these locations.
#
$(XDPYINFO_IPK): $(XDPYINFO_BUILD_DIR)/.built
	rm -rf $(XDPYINFO_IPK_DIR) $(BUILD_DIR)/xdpyinfo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XDPYINFO_BUILD_DIR) DESTDIR=$(XDPYINFO_IPK_DIR) install-strip
	$(MAKE) $(XDPYINFO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XDPYINFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xdpyinfo-ipk: $(XDPYINFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xdpyinfo-clean:
	-$(MAKE) -C $(XDPYINFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xdpyinfo-dirclean:
	rm -rf $(BUILD_DIR)/$(XDPYINFO_DIR) $(XDPYINFO_BUILD_DIR) $(XDPYINFO_IPK_DIR) $(XDPYINFO_IPK)
