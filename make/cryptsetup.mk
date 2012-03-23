###########################################################
#
# cryptsetup
#
###########################################################

# You must replace "cryptsetup" and "CRYPTSETUP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CRYPTSETUP_VERSION, CRYPTSETUP_SITE and CRYPTSETUP_SOURCE define
# the upstream location of the source code for the package.
# CRYPTSETUP_DIR is the directory which is created when the source
# archive is unpacked.
# CRYPTSETUP_UNZIP is the command used to unzip the source.
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
CRYPTSETUP_SITE=http://cryptsetup.googlecode.com/files
CRYPTSETUP_VERSION=1.4.1
CRYPTSETUP_SOURCE=cryptsetup-$(CRYPTSETUP_VERSION).tar.bz2
CRYPTSETUP_DIR=cryptsetup-$(CRYPTSETUP_VERSION)
CRYPTSETUP_UNZIP=bzcat
CRYPTSETUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CRYPTSETUP_DESCRIPTION=a tool to setup dm-crypt encrypted devices.
CRYPTSETUP_SECTION=utils
CRYPTSETUP_PRIORITY=optional
CRYPTSETUP_DEPENDS=dmsetup, popt, libgcrypt
CRYPTSETUP_SUGGESTS=
CRYPTSETUP_CONFLICTS=

#
# CRYPTSETUP_IPK_VERSION should be incremented when the ipk changes.
#
CRYPTSETUP_IPK_VERSION=1

#
# CRYPTSETUP_CONFFILES should be a list of user-editable files
#CRYPTSETUP_CONFFILES=/opt/etc/cryptsetup.conf /opt/etc/init.d/SXXcryptsetup

#
# CRYPTSETUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CRYPTSETUP_PATCHES=$(CRYPTSETUP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CRYPTSETUP_CPPFLAGS=
CRYPTSETUP_LDFLAGS=

#
# CRYPTSETUP_BUILD_DIR is the directory in which the build is done.
# CRYPTSETUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CRYPTSETUP_IPK_DIR is the directory in which the ipk is built.
# CRYPTSETUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CRYPTSETUP_BUILD_DIR=$(BUILD_DIR)/cryptsetup
CRYPTSETUP_SOURCE_DIR=$(SOURCE_DIR)/cryptsetup
CRYPTSETUP_IPK_DIR=$(BUILD_DIR)/cryptsetup-$(CRYPTSETUP_VERSION)-ipk
CRYPTSETUP_IPK=$(BUILD_DIR)/cryptsetup_$(CRYPTSETUP_VERSION)-$(CRYPTSETUP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cryptsetup-source cryptsetup-unpack cryptsetup cryptsetup-stage cryptsetup-ipk cryptsetup-clean cryptsetup-dirclean cryptsetup-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CRYPTSETUP_SOURCE):
	$(WGET) -P $(@D) $(CRYPTSETUP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cryptsetup-source: $(DL_DIR)/$(CRYPTSETUP_SOURCE) $(CRYPTSETUP_PATCHES)

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
$(CRYPTSETUP_BUILD_DIR)/.configured: $(DL_DIR)/$(CRYPTSETUP_SOURCE) $(CRYPTSETUP_PATCHES) make/cryptsetup.mk
	$(MAKE) dmsetup-stage libgcrypt-stage popt-stage util-linux-ng-stage
	rm -rf $(BUILD_DIR)/$(CRYPTSETUP_DIR) $(@D)
	$(CRYPTSETUP_UNZIP) $(DL_DIR)/$(CRYPTSETUP_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	if test -n "$(CRYPTSETUP_PATCHES)" ; \
		then cat $(CRYPTSETUP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CRYPTSETUP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CRYPTSETUP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CRYPTSETUP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CRYPTSETUP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CRYPTSETUP_LDFLAGS)" \
                PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
                --with-libgcrypt-prefix=$(STAGING_PREFIX) \
		--prefix=/opt \
		--mandir=/opt/man \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

cryptsetup-unpack: $(CRYPTSETUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CRYPTSETUP_BUILD_DIR)/.built: $(CRYPTSETUP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cryptsetup: $(CRYPTSETUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CRYPTSETUP_BUILD_DIR)/.staged: $(CRYPTSETUP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

cryptsetup-stage: $(CRYPTSETUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cryptsetup
#
$(CRYPTSETUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cryptsetup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CRYPTSETUP_PRIORITY)" >>$@
	@echo "Section: $(CRYPTSETUP_SECTION)" >>$@
	@echo "Version: $(CRYPTSETUP_VERSION)-$(CRYPTSETUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CRYPTSETUP_MAINTAINER)" >>$@
	@echo "Source: $(CRYPTSETUP_SITE)/$(CRYPTSETUP_SOURCE)" >>$@
	@echo "Description: $(CRYPTSETUP_DESCRIPTION)" >>$@
	@echo "Depends: $(CRYPTSETUP_DEPENDS)" >>$@
	@echo "Suggests: $(CRYPTSETUP_SUGGESTS)" >>$@
	@echo "Conflicts: $(CRYPTSETUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CRYPTSETUP_IPK_DIR)/opt/sbin or $(CRYPTSETUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CRYPTSETUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CRYPTSETUP_IPK_DIR)/opt/etc/cryptsetup/...
# Documentation files should be installed in $(CRYPTSETUP_IPK_DIR)/opt/doc/cryptsetup/...
# Daemon startup scripts should be installed in $(CRYPTSETUP_IPK_DIR)/opt/etc/init.d/S??cryptsetup
#
# You may need to patch your application to make it use these locations.
#
$(CRYPTSETUP_IPK): $(CRYPTSETUP_BUILD_DIR)/.built
	rm -rf $(CRYPTSETUP_IPK_DIR) $(BUILD_DIR)/cryptsetup_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CRYPTSETUP_BUILD_DIR) DESTDIR=$(CRYPTSETUP_IPK_DIR) install-strip
	$(MAKE) $(CRYPTSETUP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CRYPTSETUP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(CRYPTSETUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cryptsetup-ipk: $(CRYPTSETUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cryptsetup-clean:
	rm -f $(CRYPTSETUP_BUILD_DIR)/.built
	-$(MAKE) -C $(CRYPTSETUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cryptsetup-dirclean:
	rm -rf $(BUILD_DIR)/$(CRYPTSETUP_DIR) $(CRYPTSETUP_BUILD_DIR) $(CRYPTSETUP_IPK_DIR) $(CRYPTSETUP_IPK)
#
#
# Some sanity check for the package.
#
cryptsetup-check: $(CRYPTSETUP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
