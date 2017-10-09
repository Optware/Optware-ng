###########################################################
#
# shared-mime-info
#
###########################################################

# You must replace "shared-mime-info" and "SHARED-MIME-INFO" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SHARED-MIME-INFO_VERSION, SHARED-MIME-INFO_SITE and SHARED-MIME-INFO_SOURCE define
# the upstream location of the source code for the package.
# SHARED-MIME-INFO_DIR is the directory which is created when the source
# archive is unpacked.
# SHARED-MIME-INFO_UNZIP is the command used to unzip the source.
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
SHARED-MIME-INFO_SITE=http://freedesktop.org/~hadess
SHARED-MIME-INFO_VERSION=1.4
SHARED-MIME-INFO_SOURCE=shared-mime-info-$(SHARED-MIME-INFO_VERSION).tar.xz
SHARED-MIME-INFO_DIR=shared-mime-info-$(SHARED-MIME-INFO_VERSION)
SHARED-MIME-INFO_UNZIP=xzcat
SHARED-MIME-INFO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHARED-MIME-INFO_DESCRIPTION=The Shared Mime Info package contains a MIME database. \
	This allows central updates of MIME information for all supporting applications.
SHARED-MIME-INFO_SECTION=misc
SHARED-MIME-INFO_PRIORITY=optional
SHARED-MIME-INFO_DEPENDS=glib, libxml2
SHARED-MIME-INFO_SUGGESTS=
SHARED-MIME-INFO_CONFLICTS=

#
# SHARED-MIME-INFO_IPK_VERSION should be incremented when the ipk changes.
#
SHARED-MIME-INFO_IPK_VERSION=3

#
# SHARED-MIME-INFO_CONFFILES should be a list of user-editable files
#SHARED-MIME-INFO_CONFFILES=$(TARGET_PREFIX)/etc/shared-mime-info.conf $(TARGET_PREFIX)/etc/init.d/SXXshared-mime-info

#
# SHARED-MIME-INFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SHARED-MIME-INFO_PATCHES=$(SHARED-MIME-INFO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHARED-MIME-INFO_CPPFLAGS=
SHARED-MIME-INFO_LDFLAGS=

#
# SHARED-MIME-INFO_BUILD_DIR is the directory in which the build is done.
# SHARED-MIME-INFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHARED-MIME-INFO_IPK_DIR is the directory in which the ipk is built.
# SHARED-MIME-INFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHARED-MIME-INFO_BUILD_DIR=$(BUILD_DIR)/shared-mime-info
SHARED-MIME-INFO_SOURCE_DIR=$(SOURCE_DIR)/shared-mime-info
SHARED-MIME-INFO_IPK_DIR=$(BUILD_DIR)/shared-mime-info-$(SHARED-MIME-INFO_VERSION)-ipk
SHARED-MIME-INFO_IPK=$(BUILD_DIR)/shared-mime-info_$(SHARED-MIME-INFO_VERSION)-$(SHARED-MIME-INFO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: shared-mime-info-source shared-mime-info-unpack shared-mime-info shared-mime-info-stage shared-mime-info-ipk shared-mime-info-clean shared-mime-info-dirclean shared-mime-info-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SHARED-MIME-INFO_SOURCE):
	$(WGET) -P $(@D) $(SHARED-MIME-INFO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
shared-mime-info-source: $(DL_DIR)/$(SHARED-MIME-INFO_SOURCE) $(SHARED-MIME-INFO_PATCHES)

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
$(SHARED-MIME-INFO_BUILD_DIR)/.configured: $(DL_DIR)/$(SHARED-MIME-INFO_SOURCE) $(SHARED-MIME-INFO_PATCHES) make/shared-mime-info.mk
	$(MAKE) glib-stage libxml2-stage
	rm -rf $(BUILD_DIR)/$(SHARED-MIME-INFO_DIR) $(@D)
	$(SHARED-MIME-INFO_UNZIP) $(DL_DIR)/$(SHARED-MIME-INFO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SHARED-MIME-INFO_PATCHES)" ; \
		then cat $(SHARED-MIME-INFO_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SHARED-MIME-INFO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SHARED-MIME-INFO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SHARED-MIME-INFO_DIR) $(@D) ; \
	fi
#	tell update-mime-database that default datadirs value is "$(TARGET_PREFIX)/share/" -- NOT "/usr/local/share:/usr/share"
#		to suppress misleading warnings
	sed -i -e 's|env = ".*|env = "$(TARGET_PREFIX)/share/";|' $(@D)/update-mime-database.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SHARED-MIME-INFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SHARED-MIME-INFO_LDFLAGS)" \
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

shared-mime-info-unpack: $(SHARED-MIME-INFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SHARED-MIME-INFO_BUILD_DIR)/.built: $(SHARED-MIME-INFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) update_mime_database-update-mime-database.o
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
shared-mime-info: $(SHARED-MIME-INFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHARED-MIME-INFO_BUILD_DIR)/.staged: $(SHARED-MIME-INFO_BUILD_DIR)/.built
	rm -f $@
#	there's no real need to stage except for dependent packages
#	to varify that it's available when configuring,
#	so we just stage the .pc file
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	cp -f $(@D)/shared-mime-info.pc $(STAGING_LIB_DIR)/pkgconfig
	touch $@

shared-mime-info-stage: $(SHARED-MIME-INFO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/shared-mime-info
#
$(SHARED-MIME-INFO_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: shared-mime-info" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHARED-MIME-INFO_PRIORITY)" >>$@
	@echo "Section: $(SHARED-MIME-INFO_SECTION)" >>$@
	@echo "Version: $(SHARED-MIME-INFO_VERSION)-$(SHARED-MIME-INFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHARED-MIME-INFO_MAINTAINER)" >>$@
	@echo "Source: $(SHARED-MIME-INFO_SITE)/$(SHARED-MIME-INFO_SOURCE)" >>$@
	@echo "Description: $(SHARED-MIME-INFO_DESCRIPTION)" >>$@
	@echo "Depends: $(SHARED-MIME-INFO_DEPENDS)" >>$@
	@echo "Suggests: $(SHARED-MIME-INFO_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHARED-MIME-INFO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/shared-mime-info/...
# Documentation files should be installed in $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/doc/shared-mime-info/...
# Daemon startup scripts should be installed in $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??shared-mime-info
#
# You may need to patch your application to make it use these locations.
#
$(SHARED-MIME-INFO_IPK): $(SHARED-MIME-INFO_BUILD_DIR)/.built
	rm -rf $(SHARED-MIME-INFO_IPK_DIR) $(BUILD_DIR)/shared-mime-info_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SHARED-MIME-INFO_BUILD_DIR) DESTDIR=$(SHARED-MIME-INFO_IPK_DIR) install-strip
	rm -f $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/share/mime/mime.cache
	$(INSTALL) -d $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/share/pkgconfig $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/lib
#	$(INSTALL) -d $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SHARED-MIME-INFO_SOURCE_DIR)/shared-mime-info.conf $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/shared-mime-info.conf
#	$(INSTALL) -d $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SHARED-MIME-INFO_SOURCE_DIR)/rc.shared-mime-info $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshared-mime-info
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARED-MIME-INFO_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshared-mime-info
	$(MAKE) $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(SHARED-MIME-INFO_SOURCE_DIR)/postinst $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(SHARED-MIME-INFO_SOURCE_DIR)/prerm $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/prerm
#	$(INSTALL) -m 755 $(SHARED-MIME-INFO_SOURCE_DIR)/postinst $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SHARED-MIME-INFO_SOURCE_DIR)/prerm $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SHARED-MIME-INFO_IPK_DIR)/CONTROL/postinst $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SHARED-MIME-INFO_CONFFILES) | sed -e 's/ /\n/g' > $(SHARED-MIME-INFO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHARED-MIME-INFO_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(SHARED-MIME-INFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
shared-mime-info-ipk: $(SHARED-MIME-INFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
shared-mime-info-clean:
	rm -f $(SHARED-MIME-INFO_BUILD_DIR)/.built
	-$(MAKE) -C $(SHARED-MIME-INFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
shared-mime-info-dirclean:
	rm -rf $(BUILD_DIR)/$(SHARED-MIME-INFO_DIR) $(SHARED-MIME-INFO_BUILD_DIR) $(SHARED-MIME-INFO_IPK_DIR) $(SHARED-MIME-INFO_IPK)
#
#
# Some sanity check for the package.
#
shared-mime-info-check: $(SHARED-MIME-INFO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
