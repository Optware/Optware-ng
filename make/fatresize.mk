###########################################################
#
# fatresize
#
###########################################################
#
# FATRESIZE_VERSION, FATRESIZE_SITE and FATRESIZE_SOURCE define
# the upstream location of the source code for the package.
# FATRESIZE_DIR is the directory which is created when the source
# archive is unpacked.
# FATRESIZE_UNZIP is the command used to unzip the source.
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
FATRESIZE_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/fatresize
FATRESIZE_VERSION=1.0.2
FATRESIZE_SOURCE=fatresize-$(FATRESIZE_VERSION).tar.bz2
FATRESIZE_DIR=fatresize-$(FATRESIZE_VERSION)
FATRESIZE_UNZIP=bzcat
FATRESIZE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FATRESIZE_DESCRIPTION=Describe fatresize here.
FATRESIZE_SECTION=utils
FATRESIZE_PRIORITY=optional
FATRESIZE_DEPENDS=parted
FATRESIZE_SUGGESTS=
FATRESIZE_CONFLICTS=

#
# FATRESIZE_IPK_VERSION should be incremented when the ipk changes.
#
FATRESIZE_IPK_VERSION=3

#
# FATRESIZE_CONFFILES should be a list of user-editable files
#FATRESIZE_CONFFILES=$(TARGET_PREFIX)/etc/fatresize.conf $(TARGET_PREFIX)/etc/init.d/SXXfatresize

#
# FATRESIZE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
FATRESIZE_PATCHES=\
$(FATRESIZE_SOURCE_DIR)/ped_free.patch \
$(FATRESIZE_SOURCE_DIR)/pkg-config.patch \
$(FATRESIZE_SOURCE_DIR)/libparted-3.1.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FATRESIZE_CPPFLAGS=
FATRESIZE_LDFLAGS=

#
# FATRESIZE_BUILD_DIR is the directory in which the build is done.
# FATRESIZE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FATRESIZE_IPK_DIR is the directory in which the ipk is built.
# FATRESIZE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FATRESIZE_BUILD_DIR=$(BUILD_DIR)/fatresize
FATRESIZE_SOURCE_DIR=$(SOURCE_DIR)/fatresize
FATRESIZE_IPK_DIR=$(BUILD_DIR)/fatresize-$(FATRESIZE_VERSION)-ipk
FATRESIZE_IPK=$(BUILD_DIR)/fatresize_$(FATRESIZE_VERSION)-$(FATRESIZE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fatresize-source fatresize-unpack fatresize fatresize-stage fatresize-ipk fatresize-clean fatresize-dirclean fatresize-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FATRESIZE_SOURCE):
	$(WGET) -P $(@D) $(FATRESIZE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fatresize-source: $(DL_DIR)/$(FATRESIZE_SOURCE) $(FATRESIZE_PATCHES)

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
$(FATRESIZE_BUILD_DIR)/.configured: $(DL_DIR)/$(FATRESIZE_SOURCE) $(FATRESIZE_PATCHES) make/fatresize.mk
	$(MAKE) parted-stage
	rm -rf $(BUILD_DIR)/$(FATRESIZE_DIR) $(@D)
	$(FATRESIZE_UNZIP) $(DL_DIR)/$(FATRESIZE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FATRESIZE_PATCHES)" ; \
		then cat $(FATRESIZE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(FATRESIZE_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FATRESIZE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FATRESIZE_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FATRESIZE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FATRESIZE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

fatresize-unpack: $(FATRESIZE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FATRESIZE_BUILD_DIR)/.built: $(FATRESIZE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
fatresize: $(FATRESIZE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FATRESIZE_BUILD_DIR)/.staged: $(FATRESIZE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

fatresize-stage: $(FATRESIZE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fatresize
#
$(FATRESIZE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: fatresize" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FATRESIZE_PRIORITY)" >>$@
	@echo "Section: $(FATRESIZE_SECTION)" >>$@
	@echo "Version: $(FATRESIZE_VERSION)-$(FATRESIZE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FATRESIZE_MAINTAINER)" >>$@
	@echo "Source: $(FATRESIZE_SITE)/$(FATRESIZE_SOURCE)" >>$@
	@echo "Description: $(FATRESIZE_DESCRIPTION)" >>$@
	@echo "Depends: $(FATRESIZE_DEPENDS)" >>$@
	@echo "Suggests: $(FATRESIZE_SUGGESTS)" >>$@
	@echo "Conflicts: $(FATRESIZE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/fatresize/...
# Documentation files should be installed in $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/doc/fatresize/...
# Daemon startup scripts should be installed in $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??fatresize
#
# You may need to patch your application to make it use these locations.
#
$(FATRESIZE_IPK): $(FATRESIZE_BUILD_DIR)/.built
	rm -rf $(FATRESIZE_IPK_DIR) $(BUILD_DIR)/fatresize_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FATRESIZE_BUILD_DIR) DESTDIR=$(FATRESIZE_IPK_DIR) install-strip
#	$(INSTALL) -d $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(FATRESIZE_SOURCE_DIR)/fatresize.conf $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/fatresize.conf
#	$(INSTALL) -d $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(FATRESIZE_SOURCE_DIR)/rc.fatresize $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfatresize
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FATRESIZE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXfatresize
	$(MAKE) $(FATRESIZE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(FATRESIZE_SOURCE_DIR)/postinst $(FATRESIZE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FATRESIZE_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(FATRESIZE_SOURCE_DIR)/prerm $(FATRESIZE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FATRESIZE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FATRESIZE_IPK_DIR)/CONTROL/postinst $(FATRESIZE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FATRESIZE_CONFFILES) | sed -e 's/ /\n/g' > $(FATRESIZE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FATRESIZE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fatresize-ipk: $(FATRESIZE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fatresize-clean:
	rm -f $(FATRESIZE_BUILD_DIR)/.built
	-$(MAKE) -C $(FATRESIZE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fatresize-dirclean:
	rm -rf $(BUILD_DIR)/$(FATRESIZE_DIR) $(FATRESIZE_BUILD_DIR) $(FATRESIZE_IPK_DIR) $(FATRESIZE_IPK)
#
#
# Some sanity check for the package.
#
fatresize-check: $(FATRESIZE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
