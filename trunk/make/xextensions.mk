###########################################################
#
# xextensions
#
###########################################################

#
# XEXTENSIONS_VERSION, XEXTENSIONS_SITE and XEXTENSIONS_SOURCE define
# the upstream location of the source code for the package.
# XEXTENSIONS_DIR is the directory which is created when the source
# archive is unpacked.
#
XEXTENSIONS_SITE=http://freedesktop.org/
XEXTENSIONS_SOURCE=# none - available from CVS only
XEXTENSIONS_VERSION=1.0.2
XEXTENSIONS_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
XEXTENSIONS_DIR=XExtensions
XEXTENSIONS_CVS_OPTS=-r XEXTENSIONS-1_0_2-RELEASE
XEXTENSIONS_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
XEXTENSIONS_DESCRIPTION=Headers for standard extensions to the X protocol
XEXTENSIONS_SECTION=lib
XEXTENSIONS_PRIORITY=optional

#
# XEXTENSIONS_IPK_VERSION should be incremented when the ipk changes.
#
XEXTENSIONS_IPK_VERSION=2

#
# XEXTENSIONS_CONFFILES should be a list of user-editable files
XEXTENSIONS_CONFFILES=

#
# XEXTENSIONS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
XEXTENSIONS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
XEXTENSIONS_CPPFLAGS=
XEXTENSIONS_LDFLAGS=

#
# XEXTENSIONS_BUILD_DIR is the directory in which the build is done.
# XEXTENSIONS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# XEXTENSIONS_IPK_DIR is the directory in which the ipk is built.
# XEXTENSIONS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
XEXTENSIONS_BUILD_DIR=$(BUILD_DIR)/xextensions
XEXTENSIONS_SOURCE_DIR=$(SOURCE_DIR)/xextensions
XEXTENSIONS_IPK_DIR=$(BUILD_DIR)/xextensions-$(XEXTENSIONS_VERSION)-ipk
XEXTENSIONS_IPK=$(BUILD_DIR)/xextensions_$(XEXTENSIONS_VERSION)-$(XEXTENSIONS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# Automatically create a ipkg control file
#
$(XEXTENSIONS_IPK_DIR)/CONTROL/control:
	@install -d $(XEXTENSIONS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: xextensions" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(XEXTENSIONS_PRIORITY)" >>$@
	@echo "Section: $(XEXTENSIONS_SECTION)" >>$@
	@echo "Version: $(XEXTENSIONS_VERSION)-$(XEXTENSIONS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(XEXTENSIONS_MAINTAINER)" >>$@
	@echo "Source: $(XEXTENSIONS_SITE)/$(XEXTENSIONS_SOURCE)" >>$@
	@echo "Description: $(XEXTENSIONS_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/xextensions-$(XEXTENSIONS_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(XEXTENSIONS_DIR) && \
		cvs -d $(XEXTENSIONS_REPOSITORY) -z3 co $(XEXTENSIONS_CVS_OPTS) $(XEXTENSIONS_DIR) && \
		tar -czf $@ $(XEXTENSIONS_DIR) && \
		rm -rf $(XEXTENSIONS_DIR) \
	)

xextensions-source: $(DL_DIR)/xextensions-$(XEXTENSIONS_VERSION).tar.gz $(XEXTENSIONS_PATCHES)

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
$(XEXTENSIONS_BUILD_DIR)/.configured: $(DL_DIR)/xextensions-$(XEXTENSIONS_VERSION).tar.gz \
		$(XEXTENSIONS_PATCHES)
	$(MAKE) xproto-stage
	rm -rf $(BUILD_DIR)/$(XEXTENSIONS_DIR) $(XEXTENSIONS_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/xextensions-$(XEXTENSIONS_VERSION).tar.gz
	if test -n "$(XEXTENSIONS_PATCHES)" ; \
		then cat $(XEXTENSIONS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(XEXTENSIONS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(XEXTENSIONS_DIR)" != "$(XEXTENSIONS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(XEXTENSIONS_DIR) $(XEXTENSIONS_BUILD_DIR) ; \
	fi
	(cd $(XEXTENSIONS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(XEXTENSIONS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(XEXTENSIONS_LDFLAGS)" \
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
	touch $(XEXTENSIONS_BUILD_DIR)/.configured

xextensions-unpack: $(XEXTENSIONS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(XEXTENSIONS_BUILD_DIR)/.built: $(XEXTENSIONS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(XEXTENSIONS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
xextensions: $(XEXTENSIONS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(XEXTENSIONS_BUILD_DIR)/.staged: $(XEXTENSIONS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(XEXTENSIONS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/xextensions.pc
	touch $@

xextensions-stage: $(XEXTENSIONS_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(XEXTENSIONS_IPK_DIR)/opt/sbin or $(XEXTENSIONS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(XEXTENSIONS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(XEXTENSIONS_IPK_DIR)/opt/etc/xextensions/...
# Documentation files should be installed in $(XEXTENSIONS_IPK_DIR)/opt/doc/xextensions/...
# Daemon startup scripts should be installed in $(XEXTENSIONS_IPK_DIR)/opt/etc/init.d/S??xextensions
#
# You may need to patch your application to make it use these locations.
#
$(XEXTENSIONS_IPK): $(XEXTENSIONS_BUILD_DIR)/.built
	rm -rf $(XEXTENSIONS_IPK_DIR) $(BUILD_DIR)/xextensions_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(XEXTENSIONS_BUILD_DIR) DESTDIR=$(XEXTENSIONS_IPK_DIR) install
	$(MAKE) $(XEXTENSIONS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(XEXTENSIONS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
xextensions-ipk: $(XEXTENSIONS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
xextensions-clean:
	-$(MAKE) -C $(XEXTENSIONS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
xextensions-dirclean:
	rm -rf $(BUILD_DIR)/$(XEXTENSIONS_DIR) $(XEXTENSIONS_BUILD_DIR) $(XEXTENSIONS_IPK_DIR) $(XEXTENSIONS_IPK)
