###########################################################
#
# fixesext
#
###########################################################

#
# FIXESEXT_VERSION, FIXESEXT_SITE and FIXESEXT_SOURCE define
# the upstream location of the source code for the package.
# FIXESEXT_DIR is the directory which is created when the source
# archive is unpacked.
#
FIXESEXT_SITE=http://freedesktop.org/
FIXESEXT_SOURCE=# none - available from CVS only
FIXESEXT_VERSION=2.0.1+cvs20050130
FIXESEXT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
FIXESEXT_DIR=FixesExt
FIXESEXT_CVS_OPTS=-D20050130
FIXESEXT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
FIXESEXT_DESCRIPTION=X fixes extension headers
FIXESEXT_SECTION=lib
FIXESEXT_PRIORITY=optional

#
# FIXESEXT_IPK_VERSION should be incremented when the ipk changes.
#
FIXESEXT_IPK_VERSION=1

#
# FIXESEXT_CONFFILES should be a list of user-editable files
FIXESEXT_CONFFILES=

#
# FIXESEXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FIXESEXT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FIXESEXT_CPPFLAGS=
FIXESEXT_LDFLAGS=

#
# FIXESEXT_BUILD_DIR is the directory in which the build is done.
# FIXESEXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FIXESEXT_IPK_DIR is the directory in which the ipk is built.
# FIXESEXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FIXESEXT_BUILD_DIR=$(BUILD_DIR)/fixesext
FIXESEXT_SOURCE_DIR=$(SOURCE_DIR)/fixesext
FIXESEXT_IPK_DIR=$(BUILD_DIR)/fixesext-$(FIXESEXT_VERSION)-ipk
FIXESEXT_IPK=$(BUILD_DIR)/fixesext_$(FIXESEXT_VERSION)-$(FIXESEXT_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(FIXESEXT_SOURCE_DIR)/control:
	rm -f $@
	mkdir -p $(FIXESEXT_SOURCE_DIR) || true
	echo "Package: extensions" >>$@
	echo "Architecture: armeb" >>$@
	echo "Priority: $(FIXESEXT_PRIORITY)" >>$@
	echo "Section: $(FIXESEXT_SECTION)" >>$@
	echo "Version: $(FIXESEXT_VERSION)-$(FIXESEXT_IPK_VERSION)" >>$@
	echo "Maintainer: $(FIXESEXT_MAINTAINER)" >>$@
	echo "Source: $(FIXESEXT_SITE)/$(FIXESEXT_SOURCE)" >>$@
	echo "Description: $(FIXESEXT_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(FIXESEXT_BUILD_DIR)/.fetched:
	rm -rf $(FIXESEXT_BUILD_DIR) $(BUILD_DIR)/$(FIXESEXT_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(FIXESEXT_REPOSITORY) -z3 co $(FIXESEXT_CVS_OPTS) $(FIXESEXT_DIR); \
	)
	mv $(BUILD_DIR)/$(FIXESEXT_DIR) $(FIXESEXT_BUILD_DIR)
	touch $@

fixesext-source: $(FIXESEXT_BUILD_DIR)/.fetched $(FIXESEXT_PATCHES)

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
$(FIXESEXT_BUILD_DIR)/.configured: $(FIXESEXT_BUILD_DIR)/.fetched $(FIXESEXT_PATCHES)
	(cd $(FIXESEXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FIXESEXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FIXESEXT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(FIXESEXT_BUILD_DIR)/.configured

fixesext-unpack: $(FIXESEXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FIXESEXT_BUILD_DIR)/.built: $(FIXESEXT_BUILD_DIR)/.configured
	rm -f $(FIXESEXT_BUILD_DIR)/.built
	$(MAKE) -C $(FIXESEXT_BUILD_DIR)
	touch $(FIXESEXT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
fixesext: $(FIXESEXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FIXESEXT_BUILD_DIR)/.staged: $(FIXESEXT_BUILD_DIR)/.built
	$(MAKE) xproto-stage xextensions-stage
	rm -f $(FIXESEXT_BUILD_DIR)/.staged
	$(MAKE) -C $(FIXESEXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FIXESEXT_BUILD_DIR)/.staged

fixesext-stage: $(FIXESEXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(FIXESEXT_IPK_DIR)/opt/sbin or $(FIXESEXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FIXESEXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FIXESEXT_IPK_DIR)/opt/etc/fixesext/...
# Documentation files should be installed in $(FIXESEXT_IPK_DIR)/opt/doc/fixesext/...
# Daemon startup scripts should be installed in $(FIXESEXT_IPK_DIR)/opt/etc/init.d/S??fixesext
#
# You may need to patch your application to make it use these locations.
#
$(FIXESEXT_IPK): $(FIXESEXT_BUILD_DIR)/.built
	rm -rf $(FIXESEXT_IPK_DIR) $(BUILD_DIR)/fixesext_*_armeb.ipk $(FIXESEXT_SOURCE_DIR)/control
	$(MAKE) $(FIXESEXT_SOURCE_DIR)/control
	$(MAKE) -C $(FIXESEXT_BUILD_DIR) DESTDIR=$(FIXESEXT_IPK_DIR) install
	install -d $(FIXESEXT_IPK_DIR)/CONTROL
	install -m 644 $(FIXESEXT_SOURCE_DIR)/control $(FIXESEXT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FIXESEXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fixesext-ipk: $(FIXESEXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fixesext-clean:
	-$(MAKE) -C $(FIXESEXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fixesext-dirclean:
	rm -rf $(BUILD_DIR)/$(FIXESEXT_DIR) $(FIXESEXT_BUILD_DIR) $(FIXESEXT_IPK_DIR) $(FIXESEXT_IPK) $(FIXESEXT_SOURCE_DIR)/control
