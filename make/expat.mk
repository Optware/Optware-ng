###########################################################
#
# expat
#
###########################################################

#
# EXPAT_VERSION, EXPAT_REPOSITORY and EXPAT_SOURCE define
# the upstream location of the source code for the package.
# EXPAT_DIR is the directory which is created when the source
# archive is unpacked.
# EXPAT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
EXPAT_REPOSITORY=:pserver:anonymous@cvs.sf.net:/cvsroot/expat
EXPAT_VERSION=1.95.8
EXPAT_SOURCE=expat-$(EXPAT_VERSION).tar.gz
EXPAT_TAG=-r R_1_95_8
EXPAT_MODULE=expat
EXPAT_DIR=expat-$(EXPAT_VERSION)
EXPAT_UNZIP=zcat

#
# EXPAT_IPK_VERSION should be incremented when the ipk changes.
#
EXPAT_IPK_VERSION=1

#
# EXPAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#EXPAT_PATCHES=$(EXPAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EXPAT_CPPFLAGS=
EXPAT_LDFLAGS=

#
# EXPAT_BUILD_DIR is the directory in which the build is done.
# EXPAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EXPAT_IPK_DIR is the directory in which the ipk is built.
# EXPAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EXPAT_BUILD_DIR=$(BUILD_DIR)/expat
EXPAT_SOURCE_DIR=$(SOURCE_DIR)/expat
EXPAT_IPK_DIR=$(BUILD_DIR)/expat-$(EXPAT_VERSION)-ipk
EXPAT_IPK=$(BUILD_DIR)/expat_$(EXPAT_VERSION)-$(EXPAT_IPK_VERSION)_armeb.ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from cvs.
#
$(DL_DIR)/$(EXPAT_SOURCE):
	cd $(DL_DIR) ; $(CVS) -d $(EXPAT_REPOSITORY) co $(EXPAT_TAG) $(EXPAT_MODULE)
	mv $(DL_DIR)/$(EXPAT_MODULE) $(DL_DIR)/$(EXPAT_DIR)
	cd $(DL_DIR) ; tar zcvf $(EXPAT_SOURCE) $(EXPAT_DIR)
	rm -rf $(DL_DIR)/$(EXPAT_DIR)



#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
expat-source: $(DL_DIR)/$(EXPAT_SOURCE) $(EXPAT_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
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
$(EXPAT_BUILD_DIR)/.configured: $(DL_DIR)/$(EXPAT_SOURCE) $(EXPAT_PATCHES)
	rm -rf $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR)
	$(EXPAT_UNZIP) $(DL_DIR)/$(EXPAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(EXPAT_PATCHES) | patch -d $(BUILD_DIR)/$(EXPAT_DIR) -p1
	mv $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR)
	(cd $(EXPAT_BUILD_DIR); \
		./buildconf.sh; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EXPAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EXPAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-static \
		--enable-shared \
	)
	touch $(EXPAT_BUILD_DIR)/.configured

expat-unpack: $(EXPAT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(EXPAT_BUILD_DIR)/.built: $(EXPAT_BUILD_DIR)/.configured
	rm -f $(EXPAT_BUILD_DIR)/.built
	$(MAKE) -C $(EXPAT_BUILD_DIR)
	touch $(EXPAT_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
expat: $(EXPAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STAGING_DIR)/opt/lib/libexpat.so.$(EXPAT_VERSION): $(EXPAT_BUILD_DIR)/.built
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(EXPAT_BUILD_DIR)/expat.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(EXPAT_BUILD_DIR)/libexpat.a $(STAGING_DIR)/opt/lib
	install -m 644 $(EXPAT_BUILD_DIR)/libexpat.so.$(EXPAT_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libexpat.so.$(EXPAT_VERSION) libexpat.so.1
	cd $(STAGING_DIR)/opt/lib && ln -fs libexpat.so.$(EXPAT_VERSION) libexpat.so

expat-stage: $(STAGING_DIR)/opt/lib/libexpat.so.$(EXPAT_VERSION)

#
# This builds the IPK file.
#
# Binaries should be installed into $(EXPAT_IPK_DIR)/opt/sbin or $(EXPAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EXPAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EXPAT_IPK_DIR)/opt/etc/expat/...
# Documentation files should be installed in $(EXPAT_IPK_DIR)/opt/doc/expat/...
# Daemon startup scripts should be installed in $(EXPAT_IPK_DIR)/opt/etc/init.d/S??expat
#
# You may need to patch your application to make it use these locations.
#
$(EXPAT_IPK): $(EXPAT_BUILD_DIR)/.built
	rm -rf $(EXPAT_IPK_DIR) $(BUILD_DIR)/expat_*_armeb.ipk
	install -d $(EXPAT_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(EXPAT_BUILD_DIR)/expat -o $(EXPAT_IPK_DIR)/opt/bin/expat
	install -d $(EXPAT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(EXPAT_SOURCE_DIR)/rc.expat $(EXPAT_IPK_DIR)/opt/etc/init.d/SXXexpat
	install -d $(EXPAT_IPK_DIR)/CONTROL
	install -m 644 $(EXPAT_SOURCE_DIR)/control $(EXPAT_IPK_DIR)/CONTROL/control
	install -m 644 $(EXPAT_SOURCE_DIR)/postinst $(EXPAT_IPK_DIR)/CONTROL/postinst
	install -m 644 $(EXPAT_SOURCE_DIR)/prerm $(EXPAT_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EXPAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
expat-ipk: $(EXPAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
expat-clean:
	-$(MAKE) -C $(EXPAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
expat-dirclean:
	rm -rf $(BUILD_DIR)/$(EXPAT_DIR) $(EXPAT_BUILD_DIR) $(EXPAT_IPK_DIR) $(EXPAT_IPK)
