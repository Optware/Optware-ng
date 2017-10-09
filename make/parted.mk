###########################################################
#
# parted
#
###########################################################

# You must replace "parted" and "PARTED" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PARTED_VERSION, PARTED_SITE and PARTED_SOURCE define
# the upstream location of the source code for the package.
# PARTED_DIR is the directory which is created when the source
# archive is unpacked.
# PARTED_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
PARTED_SITE=http://ftp.gnu.org/gnu/parted/
PARTED_VERSION=3.1
PARTED_SOURCE=parted-$(PARTED_VERSION).tar.xz
PARTED_DIR=parted-$(PARTED_VERSION)
PARTED_UNZIP=xzcat
PARTED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PARTED_DESCRIPTION=GNU partition editor
PARTED_SECTION=sys
PARTED_PRIORITY=optional
PARTED_DEPENDS=e2fslibs
PARTED_SUGGESTS=
PARTED_CONFLICTS=

#
# PARTED_IPK_VERSION should be incremented when the ipk changes.
#
PARTED_IPK_VERSION=2

#
# PARTED_CONFFILES should be a list of user-editable files
PARTED_CONFFILES=
# $(TARGET_PREFIX)/etc/parted.conf $(TARGET_PREFIX)/etc/init.d/SXXparted

#
# PARTED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PARTED_PATCHES=$(PARTED_SOURCE_DIR)/__user_define.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PARTED_CPPFLAGS=
PARTED_LDFLAGS=

#
# PARTED_BUILD_DIR is the directory in which the build is done.
# PARTED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PARTED_IPK_DIR is the directory in which the ipk is built.
# PARTED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PARTED_BUILD_DIR=$(BUILD_DIR)/parted
PARTED_SOURCE_DIR=$(SOURCE_DIR)/parted
PARTED_IPK_DIR=$(BUILD_DIR)/parted-$(PARTED_VERSION)-ipk
PARTED_IPK=$(BUILD_DIR)/parted_$(PARTED_VERSION)-$(PARTED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: parted-source parted-unpack parted parted-stage parted-ipk parted-clean parted-dirclean parted-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PARTED_SOURCE):
	$(WGET) -P $(@D) $(PARTED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
parted-source: $(DL_DIR)/$(PARTED_SOURCE) $(PARTED_PATCHES)

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
$(PARTED_BUILD_DIR)/.configured: $(DL_DIR)/$(PARTED_SOURCE) $(PARTED_PATCHES) make/parted.mk
	$(MAKE) e2fsprogs-stage
	rm -rf $(BUILD_DIR)/$(PARTED_DIR) $(@D)
	$(PARTED_UNZIP) $(DL_DIR)/$(PARTED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PARTED_PATCHES)" ; \
		then cat $(PARTED_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(PARTED_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(PARTED_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PARTED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PARTED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--without-readline \
		--disable-device-mapper \
		--disable-Werror \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

parted-unpack: $(PARTED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PARTED_BUILD_DIR)/.built: $(PARTED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
parted: $(PARTED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PARTED_BUILD_DIR)/.staged: $(PARTED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libparted.la $(STAGING_LIB_DIR)/libparted.a
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libparted.pc
	touch $@

parted-stage: $(PARTED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/parted
#
$(PARTED_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: parted" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PARTED_PRIORITY)" >>$@
	@echo "Section: $(PARTED_SECTION)" >>$@
	@echo "Version: $(PARTED_VERSION)-$(PARTED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PARTED_MAINTAINER)" >>$@
	@echo "Source: $(PARTED_SITE)/$(PARTED_SOURCE)" >>$@
	@echo "Description: $(PARTED_DESCRIPTION)" >>$@
	@echo "Depends: $(PARTED_DEPENDS)" >>$@
	@echo "Suggests: $(PARTED_SUGGESTS)" >>$@
	@echo "Conflicts: $(PARTED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PARTED_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PARTED_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PARTED_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PARTED_IPK_DIR)$(TARGET_PREFIX)/etc/parted/...
# Documentation files should be installed in $(PARTED_IPK_DIR)$(TARGET_PREFIX)/doc/parted/...
# Daemon startup scripts should be installed in $(PARTED_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??parted
#
# You may need to patch your application to make it use these locations.
#
$(PARTED_IPK): $(PARTED_BUILD_DIR)/.built
	rm -rf $(PARTED_IPK_DIR) $(BUILD_DIR)/parted_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PARTED_BUILD_DIR) DESTDIR=$(PARTED_IPK_DIR) install-strip
	rm -f $(PARTED_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	rm -f $(PARTED_IPK_DIR)$(TARGET_PREFIX)/lib/libparted.a
	$(MAKE) $(PARTED_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PARTED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
parted-ipk: $(PARTED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
parted-clean:
	rm -f $(PARTED_BUILD_DIR)/.built
	-$(MAKE) -C $(PARTED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
parted-dirclean:
	rm -rf $(BUILD_DIR)/$(PARTED_DIR) $(PARTED_BUILD_DIR) $(PARTED_IPK_DIR) $(PARTED_IPK)

#
#
# Some sanity check for the package.
#
parted-check: $(PARTED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
