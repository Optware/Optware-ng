###########################################################
#
# libdrm
#
###########################################################

# You must replace "libdrm" and "LIBDRM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBDRM_VERSION, LIBDRM_SITE and LIBDRM_SOURCE define
# the upstream location of the source code for the package.
# LIBDRM_DIR is the directory which is created when the source
# archive is unpacked.
# LIBDRM_UNZIP is the command used to unzip the source.
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
LIBDRM_SITE=http://dri.freedesktop.org/libdrm
LIBDRM_VERSION=2.4.67
LIBDRM_SOURCE=libdrm-$(LIBDRM_VERSION).tar.bz2
LIBDRM_DIR=libdrm-$(LIBDRM_VERSION)
LIBDRM_UNZIP=bzcat
LIBDRM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBDRM_DESCRIPTION=Userspace interface to intel-specific kernel DRM services.
LIBDRM_SECTION=lib
LIBDRM_PRIORITY=optional
LIBDRM_DEPENDS=pciaccess
LIBDRM_SUGGESTS=
LIBDRM_CONFLICTS=

#
# LIBDRM_IPK_VERSION should be incremented when the ipk changes.
#
LIBDRM_IPK_VERSION=2

#
# LIBDRM_CONFFILES should be a list of user-editable files
#LIBDRM_CONFFILES=$(TARGET_PREFIX)/etc/libdrm.conf $(TARGET_PREFIX)/etc/init.d/SXXlibdrm

#
# LIBDRM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBDRM_PATCHES=$(LIBDRM_SOURCE_DIR)/undef__STRICT_ANSI__.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBDRM_CPPFLAGS=
LIBDRM_LDFLAGS=

#
# LIBDRM_BUILD_DIR is the directory in which the build is done.
# LIBDRM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBDRM_IPK_DIR is the directory in which the ipk is built.
# LIBDRM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBDRM_BUILD_DIR=$(BUILD_DIR)/libdrm
LIBDRM_SOURCE_DIR=$(SOURCE_DIR)/libdrm
LIBDRM_IPK_DIR=$(BUILD_DIR)/libdrm-$(LIBDRM_VERSION)-ipk
LIBDRM_IPK=$(BUILD_DIR)/libdrm_$(LIBDRM_VERSION)-$(LIBDRM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libdrm-source libdrm-unpack libdrm libdrm-stage libdrm-ipk libdrm-clean libdrm-dirclean libdrm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBDRM_SOURCE):
	$(WGET) -P $(@D) $(LIBDRM_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libdrm-source: $(DL_DIR)/$(LIBDRM_SOURCE) $(LIBDRM_PATCHES)

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
$(LIBDRM_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBDRM_SOURCE) $(LIBDRM_PATCHES) make/libdrm.mk
	$(MAKE) pciaccess-stage
	rm -rf $(BUILD_DIR)/$(LIBDRM_DIR) $(@D)
	$(LIBDRM_UNZIP) $(DL_DIR)/$(LIBDRM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBDRM_PATCHES)" ; \
		then cat $(LIBDRM_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBDRM_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBDRM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBDRM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBDRM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBDRM_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--enable-intel \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libdrm-unpack: $(LIBDRM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBDRM_BUILD_DIR)/.built: $(LIBDRM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libdrm: $(LIBDRM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBDRM_BUILD_DIR)/.staged: $(LIBDRM_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(addprefix $(STAGING_LIB_DIR)/, libdrm.la libdrm_*.la libkms.la)
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(addprefix \
		$(STAGING_LIB_DIR)/pkgconfig/, libdrm.pc libdrm_*.pc libkms.pc)
	touch $@

libdrm-stage: $(LIBDRM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libdrm
#
$(LIBDRM_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libdrm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBDRM_PRIORITY)" >>$@
	@echo "Section: $(LIBDRM_SECTION)" >>$@
	@echo "Version: $(LIBDRM_VERSION)-$(LIBDRM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBDRM_MAINTAINER)" >>$@
	@echo "Source: $(LIBDRM_SITE)/$(LIBDRM_SOURCE)" >>$@
	@echo "Description: $(LIBDRM_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBDRM_DEPENDS)" >>$@
	@echo "Suggests: $(LIBDRM_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBDRM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/libdrm/...
# Documentation files should be installed in $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/doc/libdrm/...
# Daemon startup scripts should be installed in $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libdrm
#
# You may need to patch your application to make it use these locations.
#
$(LIBDRM_IPK): $(LIBDRM_BUILD_DIR)/.built
	rm -rf $(LIBDRM_IPK_DIR) $(BUILD_DIR)/libdrm_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBDRM_BUILD_DIR) DESTDIR=$(LIBDRM_IPK_DIR) install-strip
	rm -f $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
#	$(INSTALL) -d $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBDRM_SOURCE_DIR)/libdrm.conf $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/libdrm.conf
#	$(INSTALL) -d $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBDRM_SOURCE_DIR)/rc.libdrm $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibdrm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDRM_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibdrm
	$(MAKE) $(LIBDRM_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBDRM_SOURCE_DIR)/postinst $(LIBDRM_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDRM_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBDRM_SOURCE_DIR)/prerm $(LIBDRM_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBDRM_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBDRM_IPK_DIR)/CONTROL/postinst $(LIBDRM_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBDRM_CONFFILES) | sed -e 's/ /\n/g' > $(LIBDRM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBDRM_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBDRM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libdrm-ipk: $(LIBDRM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libdrm-clean:
	rm -f $(LIBDRM_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBDRM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libdrm-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBDRM_DIR) $(LIBDRM_BUILD_DIR) $(LIBDRM_IPK_DIR) $(LIBDRM_IPK)
#
#
# Some sanity check for the package.
#
libdrm-check: $(LIBDRM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
