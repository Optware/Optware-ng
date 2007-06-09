###########################################################
#
# libmrss
#
###########################################################
#
# LIBMRSS_VERSION, LIBMRSS_SITE and LIBMRSS_SOURCE define
# the upstream location of the source code for the package.
# LIBMRSS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMRSS_UNZIP is the command used to unzip the source.
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
LIBMRSS_SITE=http://www2.autistici.org/bakunin/libmrss
LIBMRSS_VERSION=0.17.3
LIBMRSS_SOURCE=libmrss-$(LIBMRSS_VERSION).tar.gz
LIBMRSS_DIR=libmrss-$(LIBMRSS_VERSION)
LIBMRSS_UNZIP=zcat
LIBMRSS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMRSS_DESCRIPTION=A C library for parsing, writing and creating RSS (0.91, 0.92, 1.0, 2.0) files or streams.
LIBMRSS_SECTION=web
LIBMRSS_PRIORITY=optional
LIBMRSS_DEPENDS=libcurl, libnxml
LIBMRSS_SUGGESTS=
LIBMRSS_CONFLICTS=

#
# LIBMRSS_IPK_VERSION should be incremented when the ipk changes.
#
LIBMRSS_IPK_VERSION=1

#
# LIBMRSS_CONFFILES should be a list of user-editable files
#LIBMRSS_CONFFILES=/opt/etc/libmrss.conf /opt/etc/init.d/SXXlibmrss

#
# LIBMRSS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMRSS_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMRSS_CPPFLAGS=
LIBMRSS_LDFLAGS=

#
# LIBMRSS_BUILD_DIR is the directory in which the build is done.
# LIBMRSS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMRSS_IPK_DIR is the directory in which the ipk is built.
# LIBMRSS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMRSS_BUILD_DIR=$(BUILD_DIR)/libmrss
LIBMRSS_SOURCE_DIR=$(SOURCE_DIR)/libmrss
LIBMRSS_IPK_DIR=$(BUILD_DIR)/libmrss-$(LIBMRSS_VERSION)-ipk
LIBMRSS_IPK=$(BUILD_DIR)/libmrss_$(LIBMRSS_VERSION)-$(LIBMRSS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmrss-source libmrss-unpack libmrss libmrss-stage libmrss-ipk libmrss-clean libmrss-dirclean libmrss-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMRSS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBMRSS_SITE)/$(LIBMRSS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmrss-source: $(DL_DIR)/$(LIBMRSS_SOURCE) $(LIBMRSS_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(LIBMRSS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMRSS_SOURCE) $(LIBMRSS_PATCHES) make/libmrss.mk
	$(MAKE) libcurl-stage libnxml-stage
	rm -rf $(BUILD_DIR)/$(LIBMRSS_DIR) $(LIBMRSS_BUILD_DIR)
	$(LIBMRSS_UNZIP) $(DL_DIR)/$(LIBMRSS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMRSS_PATCHES)" ; \
		then cat $(LIBMRSS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBMRSS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMRSS_DIR)" != "$(LIBMRSS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBMRSS_DIR) $(LIBMRSS_BUILD_DIR) ; \
	fi
	(cd $(LIBMRSS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMRSS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMRSS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBMRSS_BUILD_DIR)/libtool
	touch $@

libmrss-unpack: $(LIBMRSS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMRSS_BUILD_DIR)/.built: $(LIBMRSS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBMRSS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libmrss: $(LIBMRSS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMRSS_BUILD_DIR)/.staged: $(LIBMRSS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBMRSS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

libmrss-stage: $(LIBMRSS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmrss
#
$(LIBMRSS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libmrss" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMRSS_PRIORITY)" >>$@
	@echo "Section: $(LIBMRSS_SECTION)" >>$@
	@echo "Version: $(LIBMRSS_VERSION)-$(LIBMRSS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMRSS_MAINTAINER)" >>$@
	@echo "Source: $(LIBMRSS_SITE)/$(LIBMRSS_SOURCE)" >>$@
	@echo "Description: $(LIBMRSS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMRSS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMRSS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMRSS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMRSS_IPK_DIR)/opt/sbin or $(LIBMRSS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMRSS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBMRSS_IPK_DIR)/opt/etc/libmrss/...
# Documentation files should be installed in $(LIBMRSS_IPK_DIR)/opt/doc/libmrss/...
# Daemon startup scripts should be installed in $(LIBMRSS_IPK_DIR)/opt/etc/init.d/S??libmrss
#
# You may need to patch your application to make it use these locations.
#
$(LIBMRSS_IPK): $(LIBMRSS_BUILD_DIR)/.built
	rm -rf $(LIBMRSS_IPK_DIR) $(BUILD_DIR)/libmrss_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMRSS_BUILD_DIR) DESTDIR=$(LIBMRSS_IPK_DIR) install-strip
	$(MAKE) $(LIBMRSS_IPK_DIR)/CONTROL/control
#	echo $(LIBMRSS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMRSS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMRSS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmrss-ipk: $(LIBMRSS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmrss-clean:
	rm -f $(LIBMRSS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMRSS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmrss-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMRSS_DIR) $(LIBMRSS_BUILD_DIR) $(LIBMRSS_IPK_DIR) $(LIBMRSS_IPK)
#
#
# Some sanity check for the package.
#
libmrss-check: $(LIBMRSS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBMRSS_IPK)
