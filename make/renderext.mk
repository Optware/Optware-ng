###########################################################
#
# renderext
#
###########################################################

#
# RENDEREXT_VERSION, RENDEREXT_SITE and RENDEREXT_SOURCE define
# the upstream location of the source code for the package.
# RENDEREXT_DIR is the directory which is created when the source
# archive is unpacked.
#
RENDEREXT_SITE=http://freedesktop.org/
RENDEREXT_SOURCE=# none - available from CVS only
RENDEREXT_VERSION=0.8+cvs20050130
RENDEREXT_REPOSITORY=:pserver:anoncvs@freedesktop.org:/cvs/xlibs
RENDEREXT_DIR=Render
RENDEREXT_CVS_OPTS=-D20050130
RENDEREXT_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
RENDEREXT_DESCRIPTION=X render extension headers
RENDEREXT_SECTION=lib
RENDEREXT_PRIORITY=optional

#
# RENDEREXT_IPK_VERSION should be incremented when the ipk changes.
#
RENDEREXT_IPK_VERSION=1

#
# RENDEREXT_CONFFILES should be a list of user-editable files
RENDEREXT_CONFFILES=

#
# RENDEREXT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RENDEREXT_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RENDEREXT_CPPFLAGS=
RENDEREXT_LDFLAGS=

#
# RENDEREXT_BUILD_DIR is the directory in which the build is done.
# RENDEREXT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RENDEREXT_IPK_DIR is the directory in which the ipk is built.
# RENDEREXT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RENDEREXT_BUILD_DIR=$(BUILD_DIR)/renderext
RENDEREXT_SOURCE_DIR=$(SOURCE_DIR)/renderext
RENDEREXT_IPK_DIR=$(BUILD_DIR)/renderext-$(RENDEREXT_VERSION)-ipk
RENDEREXT_IPK=$(BUILD_DIR)/renderext_$(RENDEREXT_VERSION)-$(RENDEREXT_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(RENDEREXT_SOURCE_DIR)/control:
	rm -f $@
	mkdir -p $(RENDEREXT_SOURCE_DIR) || true
	echo "Package: extensions" >>$@
	echo "Architecture: armeb" >>$@
	echo "Priority: $(RENDEREXT_PRIORITY)" >>$@
	echo "Section: $(RENDEREXT_SECTION)" >>$@
	echo "Version: $(RENDEREXT_VERSION)-$(RENDEREXT_IPK_VERSION)" >>$@
	echo "Maintainer: $(RENDEREXT_MAINTAINER)" >>$@
	echo "Source: $(RENDEREXT_SITE)/$(RENDEREXT_SOURCE)" >>$@
	echo "Description: $(RENDEREXT_DESCRIPTION)" >>$@

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(RENDEREXT_BUILD_DIR)/.fetched:
	rm -rf $(RENDEREXT_BUILD_DIR) $(BUILD_DIR)/$(RENDEREXT_DIR)
	( cd $(BUILD_DIR); \
		cvs -d $(RENDEREXT_REPOSITORY) -z3 co $(RENDEREXT_CVS_OPTS) $(RENDEREXT_DIR); \
	)
	mv $(BUILD_DIR)/$(RENDEREXT_DIR) $(RENDEREXT_BUILD_DIR)
	touch $@

renderext-source: $(RENDEREXT_BUILD_DIR)/.fetched $(RENDEREXT_PATCHES)

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
$(RENDEREXT_BUILD_DIR)/.configured: $(RENDEREXT_BUILD_DIR)/.fetched $(RENDEREXT_PATCHES)
	(cd $(RENDEREXT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RENDEREXT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RENDEREXT_LDFLAGS)" \
		./autogen.sh \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
	)
	touch $(RENDEREXT_BUILD_DIR)/.configured

renderext-unpack: $(RENDEREXT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RENDEREXT_BUILD_DIR)/.built: $(RENDEREXT_BUILD_DIR)/.configured
	rm -f $(RENDEREXT_BUILD_DIR)/.built
	$(MAKE) -C $(RENDEREXT_BUILD_DIR)
	touch $(RENDEREXT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
renderext: $(RENDEREXT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RENDEREXT_BUILD_DIR)/.staged: $(RENDEREXT_BUILD_DIR)/.built
	$(MAKE) xproto-stage
	rm -f $(RENDEREXT_BUILD_DIR)/.staged
	$(MAKE) -C $(RENDEREXT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RENDEREXT_BUILD_DIR)/.staged

renderext-stage: $(RENDEREXT_BUILD_DIR)/.staged

#
# This builds the IPK file.
#
# Binaries should be installed into $(RENDEREXT_IPK_DIR)/opt/sbin or $(RENDEREXT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RENDEREXT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RENDEREXT_IPK_DIR)/opt/etc/renderext/...
# Documentation files should be installed in $(RENDEREXT_IPK_DIR)/opt/doc/renderext/...
# Daemon startup scripts should be installed in $(RENDEREXT_IPK_DIR)/opt/etc/init.d/S??renderext
#
# You may need to patch your application to make it use these locations.
#
$(RENDEREXT_IPK): $(RENDEREXT_BUILD_DIR)/.built
	rm -rf $(RENDEREXT_IPK_DIR) $(BUILD_DIR)/renderext_*_armeb.ipk $(RENDEREXT_SOURCE_DIR)/control
	$(MAKE) $(RENDEREXT_SOURCE_DIR)/control
	$(MAKE) -C $(RENDEREXT_BUILD_DIR) DESTDIR=$(RENDEREXT_IPK_DIR) install
	install -d $(RENDEREXT_IPK_DIR)/CONTROL
	install -m 644 $(RENDEREXT_SOURCE_DIR)/control $(RENDEREXT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RENDEREXT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
renderext-ipk: $(RENDEREXT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
renderext-clean:
	-$(MAKE) -C $(RENDEREXT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
renderext-dirclean:
	rm -rf $(BUILD_DIR)/$(RENDEREXT_DIR) $(RENDEREXT_BUILD_DIR) $(RENDEREXT_IPK_DIR) $(RENDEREXT_IPK) $(RENDEREXT_SOURCE_DIR)/control
