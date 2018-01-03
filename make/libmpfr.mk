###########################################################
#
# libmpfr
#
###########################################################

#
# LIBMPFR_VERSION, LIBMPFR_SITE and LIBMPFR_SOURCE define
# the upstream location of the source code for the package.
# LIBMPFR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMPFR_UNZIP is the command used to unzip the source.
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
LIBMPFR_SITE=http://www.mpfr.org/mpfr-$(LIBMPFR_VERSION)
LIBMPFR_VERSION=3.1.3
LIBMPFR_SOURCE=mpfr-$(LIBMPFR_VERSION).tar.xz
LIBMPFR_DIR=mpfr-$(LIBMPFR_VERSION)
LIBMPFR_UNZIP=xzcat
LIBMPFR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMPFR_DESCRIPTION=The MPFR library is a C library for multiple-precision floating-point computations with correct rounding.
LIBMPFR_SECTION=misc
LIBMPFR_PRIORITY=optional
LIBMPFR_DEPENDS=libgmp
LIBMPFR_SUGGESTS=
LIBMPFR_CONFLICTS=

#
# LIBMPFR_IPK_VERSION should be incremented when the ipk changes.
#
LIBMPFR_IPK_VERSION=1

#
# LIBMPFR_CONFFILES should be a list of user-editable files
#LIBMPFR_CONFFILES=$(TARGET_PREFIX)/etc/libmpfr.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmpfr

#
# LIBMPFR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBMPFR_PATCHES=$(LIBMPFR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMPFR_CPPFLAGS=
LIBMPFR_LDFLAGS=

#
# LIBMPFR_BUILD_DIR is the directory in which the build is done.
# LIBMPFR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMPFR_IPK_DIR is the directory in which the ipk is built.
# LIBMPFR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMPFR_BUILD_DIR=$(BUILD_DIR)/libmpfr
LIBMPFR_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/libmpfr
LIBMPFR_SOURCE_DIR=$(SOURCE_DIR)/libmpfr
LIBMPFR_IPK_DIR=$(BUILD_DIR)/libmpfr-$(LIBMPFR_VERSION)-ipk
LIBMPFR_IPK=$(BUILD_DIR)/libmpfr_$(LIBMPFR_VERSION)-$(LIBMPFR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmpfr-source libmpfr-unpack libmpfr libmpfr-stage libmpfr-ipk libmpfr-clean libmpfr-dirclean libmpfr-check libmpfr-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMPFR_SOURCE):
	$(WGET) -P $(@D) $(LIBMPFR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmpfr-source: $(DL_DIR)/$(LIBMPFR_SOURCE) $(LIBMPFR_PATCHES)

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
$(LIBMPFR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMPFR_SOURCE) $(LIBMPFR_PATCHES) make/libmpfr.mk
	$(MAKE) libgmp-stage
	rm -rf $(BUILD_DIR)/$(LIBMPFR_DIR) $(@D)
	$(LIBMPFR_UNZIP) $(DL_DIR)/$(LIBMPFR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMPFR_PATCHES)" ; \
		then cat $(LIBMPFR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMPFR_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMPFR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMPFR_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMPFR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMPFR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmpfr-unpack: $(LIBMPFR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMPFR_BUILD_DIR)/.built: $(LIBMPFR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmpfr: $(LIBMPFR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMPFR_BUILD_DIR)/.staged: $(LIBMPFR_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_LIB_DIR)/libmpfr.*
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libmpfr.la
	touch $@

libmpfr-stage: $(LIBMPFR_BUILD_DIR)/.staged

$(LIBMPFR_HOST_BUILD_DIR)/.staged: $(DL_DIR)/$(LIBMPFR_SOURCE) $(LIBMPFR_PATCHES) make/libmpfr.mk
	$(MAKE) libgmp-host-stage
	rm -rf $(HOST_BUILD_DIR)/$(LIBMPFR_DIR) $(@D)
	$(LIBMPFR_UNZIP) $(DL_DIR)/$(LIBMPFR_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(LIBMPFR_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(LIBMPFR_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		CFLAGS="-fPIC" \
		./configure \
		--disable-shared \
		--enable-static\
		--prefix=$(HOST_STAGING_PREFIX) \
		--with-gmp=$(HOST_STAGING_PREFIX) \
	)
	$(MAKE) -C $(@D)
	$(MAKE) install -C $(@D)
	touch $@

libmpfr-host-stage: $(LIBMPFR_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmpfr
#
$(LIBMPFR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmpfr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPFR_PRIORITY)" >>$@
	@echo "Section: $(LIBMPFR_SECTION)" >>$@
	@echo "Version: $(LIBMPFR_VERSION)-$(LIBMPFR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPFR_MAINTAINER)" >>$@
	@echo "Source: $(LIBMPFR_SITE)/$(LIBMPFR_SOURCE)" >>$@
	@echo "Description: $(LIBMPFR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMPFR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPFR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPFR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/libmpfr/...
# Documentation files should be installed in $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/doc/libmpfr/...
# Daemon startup scripts should be installed in $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmpfr
#
# You may need to patch your application to make it use these locations.
#
$(LIBMPFR_IPK): $(LIBMPFR_BUILD_DIR)/.built
	rm -rf $(LIBMPFR_IPK_DIR) $(BUILD_DIR)/libmpfr_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMPFR_BUILD_DIR) DESTDIR=$(LIBMPFR_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/lib/libmpfr.so.*
#	$(INSTALL) -d $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBMPFR_SOURCE_DIR)/libmpfr.conf $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/libmpfr.conf
#	$(INSTALL) -d $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBMPFR_SOURCE_DIR)/rc.libmpfr $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmpfr
	rm -f $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/share/info/dir $(LIBMPFR_IPK_DIR)$(TARGET_PREFIX)/lib/libmpfr.la
	$(MAKE) $(LIBMPFR_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMPFR_SOURCE_DIR)/postinst $(LIBMPFR_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMPFR_SOURCE_DIR)/prerm $(LIBMPFR_IPK_DIR)/CONTROL/prerm
	echo $(LIBMPFR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMPFR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMPFR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmpfr-ipk: $(LIBMPFR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmpfr-clean:
	rm -f $(LIBMPFR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMPFR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmpfr-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMPFR_DIR) $(LIBMPFR_BUILD_DIR) $(LIBMPFR_IPK_DIR) $(LIBMPFR_IPK)

#
# Some sanity check for the package.
#
libmpfr-check: $(LIBMPFR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
