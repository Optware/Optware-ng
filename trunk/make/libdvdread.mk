###########################################################
#
# libdvdread
#
###########################################################

# You must replace "libdvdread" and "LIBDVDREAD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBDVDREAD_VERSION, LIBDVDREAD_SITE and LIBDVDREAD_SOURCE define
# the upstream location of the source code for the package.
# LIBDVDREAD_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDVDREAD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
LIBDVDREAD_SITE=http://www.dtek.chalmers.se/groups/dvd/dist
LIBDVDREAD_VERSION=0.9.7
LIBDVDREAD_SOURCE=libdvdread-$(LIBDVDREAD_VERSION).tar.gz
LIBDVDREAD_DIR=libdvdread-$(LIBDVDREAD_VERSION)
LIBDVDREAD_UNZIP=zcat
LIBDVDREAD_MAINTAINER=Keith Garry Boyce <nslu2-linux@yahoogroups.com>
LIBDVDREAD_DESCRIPTION=library for reading dvd
LIBDVDREAD_SECTION=lib
LIBDVDREAD_PRIORITY=optional
LIBDVDREAD_DEPENDS=
LIBDVDREAD_SUGGESTS=
LIBDVDREAD_CONFLICTS=

#
# LIBDVDREAD_IPK_VERSION should be incremented when the ipk changes.
#
LIBDVDREAD_IPK_VERSION=1

#
# LIBDVDREAD_CONFFILES should be a list of user-editable files
LIBDVDREAD_CONFFILES=/opt/etc/libdvdread.conf /opt/etc/init.d/SXXlibdvdread

#
## LIBDVDREAD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBDVDREAD_PATCHES=$(LIBDVDREAD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDVDREAD_CPPFLAGS=
LIBDVDREAD_LDFLAGS=

#
# LIBDVDREAD_BUILD_DIR is the directory in which the build is done.
# LIBDVDREAD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDVDREAD_IPK_DIR is the directory in which the ipk is built.
# LIBDVDREAD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDVDREAD_BUILD_DIR=$(BUILD_DIR)/libdvdread
LIBDVDREAD_SOURCE_DIR=$(SOURCE_DIR)/libdvdread
LIBDVDREAD_IPK_DIR=$(BUILD_DIR)/libdvdread-$(LIBDVDREAD_VERSION)-ipk
LIBDVDREAD_IPK=$(BUILD_DIR)/libdvdread_$(LIBDVDREAD_VERSION)-$(LIBDVDREAD_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDVDREAD_SOURCE):
	$(WGET) -P $(@D) $(LIBDVDREAD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#libdvdread-source: $(DL_DIR)/$(LIBDVDREAD_SOURCE) $(LIBDVDREAD_PATCHES)

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
## first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(LIBDVDREAD_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDVDREAD_SOURCE) $(LIBDVDREAD_PATCHES) make/libdvdread.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBDVDREAD_DIR) $(@D)
	$(LIBDVDREAD_UNZIP) $(DL_DIR)/$(LIBDVDREAD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(LIBDVDREAD_PATCHES) | patch -d $(BUILD_DIR)/$(LIBDVDREAD_DIR) -p1
	mv $(BUILD_DIR)/$(LIBDVDREAD_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDVDREAD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDVDREAD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

libdvdread-unpack: $(LIBDVDREAD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDVDREAD_BUILD_DIR)/.built: $(LIBDVDREAD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libdvdread: $(LIBDVDREAD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDVDREAD_BUILD_DIR)/.staged: $(LIBDVDREAD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

libdvdread-stage: $(LIBDVDREAD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdvdread
#
$(LIBDVDREAD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libdvdread" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDVDREAD_PRIORITY)" >>$@
	@echo "Section: $(LIBDVDREAD_SECTION)" >>$@
	@echo "Version: $(LIBDVDREAD_VERSION)-$(LIBDVDREAD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDVDREAD_MAINTAINER)" >>$@
	@echo "Source: $(LIBDVDREAD_SITE)/$(LIBDVDREAD_SOURCE)" >>$@
	@echo "Description: $(LIBDVDREAD_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDVDREAD_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDVDREAD_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDVDREAD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDVDREAD_IPK_DIR)/opt/sbin or $(LIBDVDREAD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDVDREAD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBDVDREAD_IPK_DIR)/opt/etc/libdvdread/...
# Documentation files should be installed in $(LIBDVDREAD_IPK_DIR)/opt/doc/libdvdread/...
# Daemon startup scripts should be installed in $(LIBDVDREAD_IPK_DIR)/opt/etc/init.d/S??libdvdread
#
# You may need to patch your application to make it use these locations.
#
$(LIBDVDREAD_IPK): $(LIBDVDREAD_BUILD_DIR)/.built
	rm -rf $(LIBDVDREAD_IPK_DIR) $(BUILD_DIR)/libdvdread_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDVDREAD_BUILD_DIR) DESTDIR=$(LIBDVDREAD_IPK_DIR) install
	$(MAKE) $(LIBDVDREAD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDVDREAD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdvdread-ipk: $(LIBDVDREAD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdvdread-clean:
	-$(MAKE) -C $(LIBDVDREAD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdvdread-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDVDREAD_DIR) $(LIBDVDREAD_BUILD_DIR) $(LIBDVDREAD_IPK_DIR) $(LIBDVDREAD_IPK)
