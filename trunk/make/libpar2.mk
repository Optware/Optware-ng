###########################################################
#
# libpar2
#
###########################################################

# You must replace "libpar2" and "LIBPAR2" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBPAR2_VERSION, LIBPAR2_SITE and LIBPAR2_SOURCE define
# the upstream location of the source code for the package.
# LIBPAR2_DIR is the directory which is created when the source
# archive is unpacked.
# LIBPAR2_UNZIP is the command used to unzip the source.
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
LIBPAR2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/parchive
LIBPAR2_VERSION=0.2
LIBPAR2_SOURCE=libpar2-$(LIBPAR2_VERSION).tar.gz
LIBPAR2_DIR=libpar2-$(LIBPAR2_VERSION)
LIBPAR2_UNZIP=zcat
LIBPAR2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBPAR2_DESCRIPTION=A library for performing common tasks related to PAR recovery sets
LIBPAR2_SECTION=libs
LIBPAR2_PRIORITY=optional
LIBPAR2_DEPENDS=libsigc++
LIBPAR2_SUGGESTS=
LIBPAR2_CONFLICTS=

#
# LIBPAR2_IPK_VERSION should be incremented when the ipk changes.
#
LIBPAR2_IPK_VERSION=4

#
# LIBPAR2_CONFFILES should be a list of user-editable files
#LIBPAR2_CONFFILES=

#
# LIBPAR2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBPAR2_PATCHES=$(LIBPAR2_SOURCE_DIR)/main-packet-fix.patch \
    $(LIBPAR2_SOURCE_DIR)/unofficial-bugfixes.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBPAR2_CPPFLAGS=
LIBPAR2_LDFLAGS=
LIBPAR2_CONFIGURE=
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
LIBPAR2_CONFIGURE += CXX=$(TARGET_GXX)
endif
endif


#
# LIBPAR2_BUILD_DIR is the directory in which the build is done.
# LIBPAR2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBPAR2_IPK_DIR is the directory in which the ipk is built.
# LIBPAR2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBPAR2_BUILD_DIR=$(BUILD_DIR)/libpar2
LIBPAR2_SOURCE_DIR=$(SOURCE_DIR)/libpar2
LIBPAR2_IPK_DIR=$(BUILD_DIR)/libpar2-$(LIBPAR2_VERSION)-ipk
LIBPAR2_IPK=$(BUILD_DIR)/libpar2_$(LIBPAR2_VERSION)-$(LIBPAR2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libpar2-source libpar2-unpack libpar2 libpar2-stage libpar2-ipk libpar2-clean libpar2-dirclean libpar2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBPAR2_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBPAR2_SITE)/$(LIBPAR2_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBPAR2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libpar2-source: $(DL_DIR)/$(LIBPAR2_SOURCE) $(LIBPAR2_PATCHES)

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
$(LIBPAR2_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBPAR2_SOURCE) $(LIBPAR2_PATCHES) make/libpar2.mk
	$(MAKE) libsigc++-stage
	rm -rf $(BUILD_DIR)/$(LIBPAR2_DIR) $(@D)
	$(LIBPAR2_UNZIP) $(DL_DIR)/$(LIBPAR2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBPAR2_PATCHES)" ; \
		then cat $(LIBPAR2_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBPAR2_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBPAR2_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBPAR2_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBPAR2_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBPAR2_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(LIBPAR2_CONFIGURE) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libpar2-unpack: $(LIBPAR2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBPAR2_BUILD_DIR)/.built: $(LIBPAR2_BUILD_DIR)/.configured
	rm -f $@
	PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
	$(MAKE) -C $(LIBPAR2_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libpar2: $(LIBPAR2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBPAR2_BUILD_DIR)/.staged: $(LIBPAR2_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBPAR2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f -R $(STAGING_LIB_DIR)/libpar2
	touch $@

libpar2-stage: $(LIBPAR2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libpar2
#
$(LIBPAR2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libpar2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBPAR2_PRIORITY)" >>$@
	@echo "Section: $(LIBPAR2_SECTION)" >>$@
	@echo "Version: $(LIBPAR2_VERSION)-$(LIBPAR2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBPAR2_MAINTAINER)" >>$@
	@echo "Source: $(LIBPAR2_SITE)/$(LIBPAR2_SOURCE)" >>$@
	@echo "Description: $(LIBPAR2_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBPAR2_DEPENDS)" >>$@
	@echo "Suggests: $(LIBPAR2_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBPAR2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBPAR2_IPK_DIR)/opt/sbin or $(LIBPAR2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBPAR2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBPAR2_IPK_DIR)/opt/etc/libpar2/...
# Documentation files should be installed in $(LIBPAR2_IPK_DIR)/opt/doc/libpar2/...
# Daemon startup scripts should be installed in $(LIBPAR2_IPK_DIR)/opt/etc/init.d/S??libpar2
#
# You may need to patch your application to make it use these locations.
#
$(LIBPAR2_IPK): $(LIBPAR2_BUILD_DIR)/.built
	rm -rf $(LIBPAR2_IPK_DIR) $(BUILD_DIR)/libpar2_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBPAR2_BUILD_DIR) DESTDIR=$(LIBPAR2_IPK_DIR) install-strip
	rm -f $(LIBPAR2_IPK_DIR)/opt/lib/libpar2.la
	rm -f -R $(LIBPAR2_IPK_DIR)/opt/lib/libpar2
	$(MAKE) $(LIBPAR2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBPAR2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libpar2-ipk: $(LIBPAR2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libpar2-clean:
	rm -f $(LIBPAR2_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBPAR2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libpar2-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBPAR2_DIR) $(LIBPAR2_BUILD_DIR) $(LIBPAR2_IPK_DIR) $(LIBPAR2_IPK)
#
#
# Some sanity check for the package.
#
libpar2-check: $(LIBPAR2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBPAR2_IPK)
