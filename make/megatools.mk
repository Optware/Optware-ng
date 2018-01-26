###########################################################
#
# megatools
#
###########################################################
#
# MEGATOOLS_VERSION, MEGATOOLS_SITE and MEGATOOLS_SOURCE define
# the upstream location of the source code for the package.
# MEGATOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# MEGATOOLS_UNZIP is the command used to unzip the source.
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
MEGATOOLS_URL=http://megatools.megous.com/builds/$(MEGATOOLS_SOURCE)
MEGATOOLS_VERSION=1.9.95
MEGATOOLS_SOURCE=megatools-$(MEGATOOLS_VERSION).tar.gz
MEGATOOLS_DIR=megatools-$(MEGATOOLS_VERSION)
MEGATOOLS_UNZIP=zcat
MEGATOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEGATOOLS_DESCRIPTION=Collection of programs for accessing Mega service from a command line of your desktop or server.
MEGATOOLS_SECTION=web
MEGATOOLS_PRIORITY=optional
MEGATOOLS_DEPENDS=glib, glib-networking, openssl, libcurl
MEGATOOLS_SUGGESTS=
MEGATOOLS_CONFLICTS=

#
# MEGATOOLS_IPK_VERSION should be incremented when the ipk changes.
#
MEGATOOLS_IPK_VERSION=5

#
# MEGATOOLS_CONFFILES should be a list of user-editable files
#MEGATOOLS_CONFFILES=$(TARGET_PREFIX)/etc/megatools.conf $(TARGET_PREFIX)/etc/init.d/SXXmegatools

#
# MEGATOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MEGATOOLS_PATCHES=$(MEGATOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEGATOOLS_CPPFLAGS=
MEGATOOLS_LDFLAGS=

#
# MEGATOOLS_BUILD_DIR is the directory in which the build is done.
# MEGATOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEGATOOLS_IPK_DIR is the directory in which the ipk is built.
# MEGATOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEGATOOLS_BUILD_DIR=$(BUILD_DIR)/megatools
MEGATOOLS_SOURCE_DIR=$(SOURCE_DIR)/megatools
MEGATOOLS_IPK_DIR=$(BUILD_DIR)/megatools-$(MEGATOOLS_VERSION)-ipk
MEGATOOLS_IPK=$(BUILD_DIR)/megatools_$(MEGATOOLS_VERSION)-$(MEGATOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: megatools-source megatools-unpack megatools megatools-stage megatools-ipk megatools-clean megatools-dirclean megatools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(MEGATOOLS_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(MEGATOOLS_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(MEGATOOLS_SOURCE).sha512
#
$(DL_DIR)/$(MEGATOOLS_SOURCE):
	$(WGET) -O $@ $(MEGATOOLS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
megatools-source: $(DL_DIR)/$(MEGATOOLS_SOURCE) $(MEGATOOLS_PATCHES)

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
$(MEGATOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(MEGATOOLS_SOURCE) $(MEGATOOLS_PATCHES) make/megatools.mk
	$(MAKE) glib-stage openssl-stage libcurl-stage
	rm -rf $(BUILD_DIR)/$(MEGATOOLS_DIR) $(@D)
	$(MEGATOOLS_UNZIP) $(DL_DIR)/$(MEGATOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEGATOOLS_PATCHES)" ; \
		then cat $(MEGATOOLS_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MEGATOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEGATOOLS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MEGATOOLS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MEGATOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MEGATOOLS_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig/" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-introspection \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

megatools-unpack: $(MEGATOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEGATOOLS_BUILD_DIR)/.built: $(MEGATOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
megatools: $(MEGATOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEGATOOLS_BUILD_DIR)/.staged: $(MEGATOOLS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

megatools-stage: $(MEGATOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/megatools
#
$(MEGATOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: megatools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEGATOOLS_PRIORITY)" >>$@
	@echo "Section: $(MEGATOOLS_SECTION)" >>$@
	@echo "Version: $(MEGATOOLS_VERSION)-$(MEGATOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEGATOOLS_MAINTAINER)" >>$@
	@echo "Source: $(MEGATOOLS_URL)" >>$@
	@echo "Description: $(MEGATOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(MEGATOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(MEGATOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEGATOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/megatools/...
# Documentation files should be installed in $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/doc/megatools/...
# Daemon startup scripts should be installed in $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??megatools
#
# You may need to patch your application to make it use these locations.
#
$(MEGATOOLS_IPK): $(MEGATOOLS_BUILD_DIR)/.built
	rm -rf $(MEGATOOLS_IPK_DIR) $(BUILD_DIR)/megatools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEGATOOLS_BUILD_DIR) DESTDIR=$(MEGATOOLS_IPK_DIR) install-strip
#	$(INSTALL) -d $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MEGATOOLS_SOURCE_DIR)/megatools.conf $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/megatools.conf
#	$(INSTALL) -d $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MEGATOOLS_SOURCE_DIR)/rc.megatools $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmegatools
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGATOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmegatools
	$(MAKE) $(MEGATOOLS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MEGATOOLS_SOURCE_DIR)/postinst $(MEGATOOLS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGATOOLS_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MEGATOOLS_SOURCE_DIR)/prerm $(MEGATOOLS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEGATOOLS_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MEGATOOLS_IPK_DIR)/CONTROL/postinst $(MEGATOOLS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MEGATOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(MEGATOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEGATOOLS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MEGATOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
megatools-ipk: $(MEGATOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
megatools-clean:
	rm -f $(MEGATOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(MEGATOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
megatools-dirclean:
	rm -rf $(BUILD_DIR)/$(MEGATOOLS_DIR) $(MEGATOOLS_BUILD_DIR) $(MEGATOOLS_IPK_DIR) $(MEGATOOLS_IPK)
#
#
# Some sanity check for the package.
#
megatools-check: $(MEGATOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
