###########################################################
#
# libnl
#
###########################################################

# You must replace "libnl" and "LIBNL" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBNL_VERSION, LIBNL_SITE and LIBNL_SOURCE define
# the upstream location of the source code for the package.
# LIBNL_DIR is the directory which is created when the source
# archive is unpacked.
# LIBNL_UNZIP is the command used to unzip the source.
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
LIBNL_SITE=http://www.infradead.org/~tgr/libnl/files
LIBNL_VERSION=3.2.25
LIBNL_SOURCE=libnl-$(LIBNL_VERSION).tar.gz
LIBNL_DIR=libnl-$(LIBNL_VERSION)
LIBNL_UNZIP=zcat
LIBNL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBNL_DESCRIPTION=A collection of libraries providing APIs to netlink protocol based Linux kernel interfaces.
LIBNL_SECTION=lib
LIBNL_PRIORITY=optional
LIBNL_DEPENDS=
LIBNL_SUGGESTS=
LIBNL_CONFLICTS=

#
# LIBNL_IPK_VERSION should be incremented when the ipk changes.
#
LIBNL_IPK_VERSION=2

#
# LIBNL_CONFFILES should be a list of user-editable files
#LIBNL_CONFFILES=$(TARGET_PREFIX)/etc/libnl.conf $(TARGET_PREFIX)/etc/init.d/SXXlibnl

#
# LIBNL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBNL_PATCHES=$(LIBNL_SOURCE_DIR)/configure.patch

ifeq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
LIBNL_PATCHES += $(LIBNL_SOURCE_DIR)/old_kernel.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBNL_CPPFLAGS=
LIBNL_LDFLAGS=

#
# LIBNL_BUILD_DIR is the directory in which the build is done.
# LIBNL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBNL_IPK_DIR is the directory in which the ipk is built.
# LIBNL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBNL_BUILD_DIR=$(BUILD_DIR)/libnl
LIBNL_SOURCE_DIR=$(SOURCE_DIR)/libnl
LIBNL_IPK_DIR=$(BUILD_DIR)/libnl-$(LIBNL_VERSION)-ipk
LIBNL_IPK=$(BUILD_DIR)/libnl_$(LIBNL_VERSION)-$(LIBNL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libnl-source libnl-unpack libnl libnl-stage libnl-ipk libnl-clean libnl-dirclean libnl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBNL_SOURCE):
	$(WGET) -P $(@D) $(LIBNL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libnl-source: $(DL_DIR)/$(LIBNL_SOURCE) $(LIBNL_PATCHES)

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
$(LIBNL_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBNL_SOURCE) $(LIBNL_PATCHES) make/libnl.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBNL_DIR) $(@D)
	$(LIBNL_UNZIP) $(DL_DIR)/$(LIBNL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBNL_PATCHES)" ; \
		then cat $(LIBNL_PATCHES) | \
		$(PATCH) -bd $(BUILD_DIR)/$(LIBNL_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBNL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBNL_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBNL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBNL_LDFLAGS)" \
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

libnl-unpack: $(LIBNL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBNL_BUILD_DIR)/.built: $(LIBNL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libnl: $(LIBNL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBNL_BUILD_DIR)/.staged: $(LIBNL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libnl{,-gel,}-3.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libnl{,-genl}-3.0.pc
ifneq ($(OPTWARE_TARGET), $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)))
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libnl-{route,nf,cli}-3.0.pc
	rm -f $(STAGING_LIB_DIR)/libnl-{route,nf,cli,idiag}-3.la
endif
	touch $@

libnl-stage: $(LIBNL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libnl
#
$(LIBNL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libnl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBNL_PRIORITY)" >>$@
	@echo "Section: $(LIBNL_SECTION)" >>$@
	@echo "Version: $(LIBNL_VERSION)-$(LIBNL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBNL_MAINTAINER)" >>$@
	@echo "Source: $(LIBNL_SITE)/$(LIBNL_SOURCE)" >>$@
	@echo "Description: $(LIBNL_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBNL_DEPENDS)" >>$@
	@echo "Suggests: $(LIBNL_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBNL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/libnl/...
# Documentation files should be installed in $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/doc/libnl/...
# Daemon startup scripts should be installed in $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libnl
#
# You may need to patch your application to make it use these locations.
#
$(LIBNL_IPK): $(LIBNL_BUILD_DIR)/.built
	rm -rf $(LIBNL_IPK_DIR) $(BUILD_DIR)/libnl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBNL_BUILD_DIR) DESTDIR=$(LIBNL_IPK_DIR) install-strip
	find $(LIBNL_IPK_DIR) -type f -name '*.la' -exec rm -f {} \;
#	$(INSTALL) -d $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBNL_SOURCE_DIR)/libnl.conf $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/libnl.conf
#	$(INSTALL) -d $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBNL_SOURCE_DIR)/rc.libnl $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnl
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibnl
	$(MAKE) $(LIBNL_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBNL_SOURCE_DIR)/postinst $(LIBNL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNL_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBNL_SOURCE_DIR)/prerm $(LIBNL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBNL_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBNL_IPK_DIR)/CONTROL/postinst $(LIBNL_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBNL_CONFFILES) | sed -e 's/ /\n/g' > $(LIBNL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBNL_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBNL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libnl-ipk: $(LIBNL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libnl-clean:
	rm -f $(LIBNL_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBNL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libnl-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBNL_DIR) $(LIBNL_BUILD_DIR) $(LIBNL_IPK_DIR) $(LIBNL_IPK)
#
#
# Some sanity check for the package.
#
libnl-check: $(LIBNL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
