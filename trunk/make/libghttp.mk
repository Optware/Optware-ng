###########################################################
#
# libghttp
#
###########################################################

# You must replace "libghttp" and "LIBGHTTP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBGHTTP_VERSION, LIBGHTTP_SITE and LIBGHTTP_SOURCE define
# the upstream location of the source code for the package.
# LIBGHTTP_DIR is the directory which is created when the source
# archive is unpacked.
# LIBGHTTP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
LIBGHTTP_SITE=ftp://ftp.gnome.org/pub/GNOME/sources/libghttp/1.0/
LIBGHTTP_VERSION=1.0.9
LIBGHTTP_SOURCE=libghttp-$(LIBGHTTP_VERSION).tar.gz
LIBGHTTP_DIR=libghttp-$(LIBGHTTP_VERSION)
LIBGHTTP_UNZIP=zcat
LIBGHTTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBGHTTP_DESCRIPTION=libghttp is a light-weight http fetching library.
LIBGHTTP_SECTION=lib
LIBGHTTP_PRIORITY=optional
LIBGHTTP_DEPENDS=
LIBGHTTP_SUGGESTS=
LIBGHTTP_CONFLICTS=

#
# LIBGHTTP_IPK_VERSION should be incremented when the ipk changes.
#
LIBGHTTP_IPK_VERSION=1

#
# LIBGHTTP_CONFFILES should be a list of user-editable files
#LIBGHTTP_CONFFILES=/opt/etc/libghttp.conf /opt/etc/init.d/SXXlibghttp

#
# LIBGHTTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBGHTTP_PATCHES=$(LIBGHTTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBGHTTP_CPPFLAGS=
LIBGHTTP_LDFLAGS=

#
# LIBGHTTP_BUILD_DIR is the directory in which the build is done.
# LIBGHTTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBGHTTP_IPK_DIR is the directory in which the ipk is built.
# LIBGHTTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBGHTTP_BUILD_DIR=$(BUILD_DIR)/libghttp
LIBGHTTP_SOURCE_DIR=$(SOURCE_DIR)/libghttp
LIBGHTTP_IPK_DIR=$(BUILD_DIR)/libghttp-$(LIBGHTTP_VERSION)-ipk
LIBGHTTP_IPK=$(BUILD_DIR)/libghttp_$(LIBGHTTP_VERSION)-$(LIBGHTTP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBGHTTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBGHTTP_SITE)/$(LIBGHTTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libghttp-source: $(DL_DIR)/$(LIBGHTTP_SOURCE) $(LIBGHTTP_PATCHES)

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
$(LIBGHTTP_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBGHTTP_SOURCE) $(LIBGHTTP_PATCHES)
	rm -rf $(BUILD_DIR)/$(LIBGHTTP_DIR) $(LIBGHTTP_BUILD_DIR)
	$(LIBGHTTP_UNZIP) $(DL_DIR)/$(LIBGHTTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBGHTTP_DIR) $(LIBGHTTP_BUILD_DIR)
	(cd $(LIBGHTTP_BUILD_DIR); \
		sed -i -e 's/AC_DIVERT_/dnl AC_DIVERT_/g' configure.in; \
		ACLOCAL=aclocal-1.4 AUTOMAKE=automake-1.4 autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBGHTTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBGHTTP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--enable-shared \
		--disable-static \
	)
	touch $(LIBGHTTP_BUILD_DIR)/.configured

libghttp-unpack: $(LIBGHTTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBGHTTP_BUILD_DIR)/.built: $(LIBGHTTP_BUILD_DIR)/.configured
	rm -f $(LIBGHTTP_BUILD_DIR)/.built
	$(MAKE) -C $(LIBGHTTP_BUILD_DIR)
	touch $(LIBGHTTP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
libghttp: $(LIBGHTTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBGHTTP_BUILD_DIR)/.staged: $(LIBGHTTP_BUILD_DIR)/.built
	rm -f $(LIBGHTTP_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBGHTTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install-strip
	install -d $(STAGING_INCLUDE_DIR)
	install -m 644 $(LIBGHTTP_BUILD_DIR)/ghttp.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	install -m 644 $(LIBGHTTP_BUILD_DIR)/libghttp.la $(STAGING_LIB_DIR)
	touch $(LIBGHTTP_BUILD_DIR)/.staged

libghttp-stage: $(LIBGHTTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libghttp
#
$(LIBGHTTP_IPK_DIR)/CONTROL/control:
	@install -d $(LIBGHTTP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: libghttp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBGHTTP_PRIORITY)" >>$@
	@echo "Section: $(LIBGHTTP_SECTION)" >>$@
	@echo "Version: $(LIBGHTTP_VERSION)-$(LIBGHTTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBGHTTP_MAINTAINER)" >>$@
	@echo "Source: $(LIBGHTTP_SITE)/$(LIBGHTTP_SOURCE)" >>$@
	@echo "Description: $(LIBGHTTP_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBGHTTP_DEPENDS)" >>$@
	@echo "Suggests: $(LIBGHTTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBGHTTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBGHTTP_IPK_DIR)/opt/sbin or $(LIBGHTTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBGHTTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBGHTTP_IPK_DIR)/opt/etc/libghttp/...
# Documentation files should be installed in $(LIBGHTTP_IPK_DIR)/opt/doc/libghttp/...
# Daemon startup scripts should be installed in $(LIBGHTTP_IPK_DIR)/opt/etc/init.d/S??libghttp
#
# You may need to patch your application to make it use these locations.
#
$(LIBGHTTP_IPK): $(LIBGHTTP_BUILD_DIR)/.built
	rm -rf $(LIBGHTTP_IPK_DIR) $(BUILD_DIR)/LIBGHTTP_*_$(TARGET_ARCH).ipk
	install -d $(LIBGHTTP_IPK_DIR)/opt/include
	install -m 644 $(LIBGHTTP_BUILD_DIR)/ghttp.h $(LIBGHTTP_IPK_DIR)/opt/include
	install -d $(LIBGHTTP_IPK_DIR)/opt/lib
	install -m 644 $(LIBGHTTP_BUILD_DIR)/libghttp.la $(LIBGHTTP_IPK_DIR)/opt/lib
	$(MAKE) $(LIBGHTTP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBGHTTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libghttp-ipk: $(LIBGHTTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libghttp-clean:
	-$(MAKE) -C $(LIBGHTTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libghttp-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBGHTTP_DIR) $(LIBGHTTP_BUILD_DIR) $(LIBGHTTP_IPK_DIR) $(LIBGHTTP_IPK)
