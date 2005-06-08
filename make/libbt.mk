###########################################################
#
# libbt
#
###########################################################

#
# LIBBT_VERSION, LIBBT_SITE and LIBBT_SOURCE define
# the upstream location of the source code for the package.
# LIBBT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBBT_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBBT_SITE=http://aleron.dl.sourceforge.net/sourceforge/libbt
LIBBT_VERSION=1.03
LIBBT_SOURCE=libbt-$(LIBBT_VERSION).tar.gz
LIBBT_DIR=libbt-$(LIBBT_VERSION)
LIBBT_UNZIP=zcat
LIBBT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBBT_DESCRIPTION=a C library implementing the core BitTorrent protocol
LIBBT_SECTION=net
LIBBT_PRIORITY=optional
LIBBT_DEPENDS=libcurl, openssl, zlib
LIBBT_SUGGESTS=
LIBBT_CONFLICTS=

#
# LIBBT_IPK_VERSION should be incremented when the ipk changes.
#
LIBBT_IPK_VERSION=7

#
# LIBBT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(UNSLUNG_TARGET),wl500g)
LIBBT_PATCHES=$(LIBBT_SOURCE_DIR)/configure.patch \
	$(LIBBT_SOURCE_DIR)/libbt-headerfix.patch \
	$(LIBBT_SOURCE_DIR)/Makefile.in.patch \
	$(LIBBT_SOURCE_DIR)/benc.c.patch 
else
LIBBT_PATCHES=$(LIBBT_SOURCE_DIR)/configure.patch \
	$(LIBBT_SOURCE_DIR)/libbt-headerfix.patch \
	$(LIBBT_SOURCE_DIR)/Makefile.in.patch \
	$(LIBBT_SOURCE_DIR)/benc.c.patch \
	$(LIBBT_SOURCE_DIR)/random.c.patch 
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBBT_CFLAGS=
LIBBT_CPPFLAGS=
LIBBT_LDFLAGS=

#
# LIBBT_BUILD_DIR is the directory in which the build is done.
# LIBBT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBBT_IPK_DIR is the directory in which the ipk is built.
# LIBBT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBBT_BUILD_DIR=$(BUILD_DIR)/libbt
LIBBT_SOURCE_DIR=$(SOURCE_DIR)/libbt
LIBBT_IPK_DIR=$(BUILD_DIR)/libbt-$(LIBBT_VERSION)-ipk
LIBBT_IPK=$(BUILD_DIR)/libbt_$(LIBBT_VERSION)-$(LIBBT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBBT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBBT_SITE)/$(LIBBT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libbt-source: $(DL_DIR)/$(LIBBT_SOURCE) $(LIBBT_PATCHES)

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
$(LIBBT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBBT_SOURCE) $(LIBBT_PATCHES)
	$(MAKE) openssl-stage libcurl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LIBBT_DIR) $(LIBBT_BUILD_DIR)
	$(LIBBT_UNZIP) $(DL_DIR)/$(LIBBT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(LIBBT_PATCHES) | patch -d $(BUILD_DIR)/$(LIBBT_DIR) -p0
	mv $(BUILD_DIR)/$(LIBBT_DIR) $(LIBBT_BUILD_DIR)
	(cd $(LIBBT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CFLAGS) $(LIBBT_CFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBBT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBBT_LDFLAGS)" \
		LIBS="-lssl -lm -lcrypto" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	)
	touch $(LIBBT_BUILD_DIR)/.configured

libbt-unpack: $(LIBBT_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(LIBBT_BUILD_DIR)/.built: $(LIBBT_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBBT_BUILD_DIR) compile PATH=$(STAGING_DIR)/bin:$(PATH) 
	touch $(LIBBT_BUILD_DIR)/.built

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
libbt: $(LIBBT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libbt
#
$(LIBBT_IPK_DIR)/CONTROL/control:
	@install -d $(LIBBT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libbt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBBT_PRIORITY)" >>$@
	@echo "Section: $(LIBBT_SECTION)" >>$@
	@echo "Version: $(LIBBT_VERSION)-$(LIBBT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBBT_MAINTAINER)" >>$@
	@echo "Source: $(LIBBT_SITE)/$(LIBBT_SOURCE)" >>$@
	@echo "Description: $(LIBBT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBBT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBBT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBBT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBBT_IPK_DIR)/opt/sbin or $(LIBBT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBBT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBBT_IPK_DIR)/opt/etc/libbt/...
# Documentation files should be installed in $(LIBBT_IPK_DIR)/opt/doc/libbt/...
# Daemon startup scripts should be installed in $(LIBBT_IPK_DIR)/opt/etc/init.d/S??libbt
#
# You may need to patch your application to make it use these locations.
#
$(LIBBT_IPK): $(LIBBT_BUILD_DIR)/.built
	rm -rf $(LIBBT_IPK_DIR) $(BUILD_DIR)/libbt_*_$(TARGET_ARCH).ipk
	$(MAKE) $(LIBBT_IPK_DIR)/CONTROL/control
	install -d $(LIBBT_IPK_DIR)/opt/bin
	install -m 755 $(LIBBT_BUILD_DIR)/src/btget $(LIBBT_IPK_DIR)/opt/bin
	install -m 755 $(LIBBT_BUILD_DIR)/src/btcheck $(LIBBT_IPK_DIR)/opt/bin
	install -m 755 $(LIBBT_BUILD_DIR)/src/btlist $(LIBBT_IPK_DIR)/opt/bin
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBBT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libbt-ipk: $(LIBBT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libbt-clean:
	-$(MAKE) -C $(LIBBT_BUILD_DIR) clean

libbt-distclean:
	-$(MAKE) -C $(LIBBT_BUILD_DIR) distclean
#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libbt-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBBT_DIR) $(LIBBT_BUILD_DIR) $(LIBBT_IPK_DIR) $(LIBBT_IPK)
