###########################################################
#
# shellinabox
#
###########################################################
#
# SHELLINABOX_VERSION, SHELLINABOX_SITE and SHELLINABOX_SOURCE define
# the upstream location of the source code for the package.
# SHELLINABOX_DIR is the directory which is created when the source
# archive is unpacked.
# SHELLINABOX_UNZIP is the command used to unzip the source.
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
SHELLINABOX_SITE=https://github.com/shellinabox/shellinabox/archive
SHELLINABOX_VERSION=2.18
SHELLINABOX_SOURCE=v$(SHELLINABOX_VERSION).tar.gz
SHELLINABOX_SOURCE_SAVE=shellinabox-$(SHELLINABOX_VERSION).tar.gz
SHELLINABOX_DIR=shellinabox-$(SHELLINABOX_VERSION)
SHELLINABOX_UNZIP=zcat
SHELLINABOX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SHELLINABOX_DESCRIPTION=A web server that can export arbitrary command line tools to a web based terminal emulator.
SHELLINABOX_SECTION=tool
SHELLINABOX_PRIORITY=optional
SHELLINABOX_DEPENDS=libpam, openssl, zlib
SHELLINABOX_SUGGESTS=
SHELLINABOX_CONFLICTS=

#
# SHELLINABOX_IPK_VERSION should be incremented when the ipk changes.
#
SHELLINABOX_IPK_VERSION=2

#
# SHELLINABOX_CONFFILES should be a list of user-editable files
#SHELLINABOX_CONFFILES=$(TARGET_PREFIX)/etc/shellinabox.conf $(TARGET_PREFIX)/etc/init.d/SXXshellinabox

#
# SHELLINABOX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SHELLINABOX_PATCHES=$(SHELLINABOX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SHELLINABOX_CPPFLAGS=
SHELLINABOX_LDFLAGS=

#
# SHELLINABOX_BUILD_DIR is the directory in which the build is done.
# SHELLINABOX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SHELLINABOX_IPK_DIR is the directory in which the ipk is built.
# SHELLINABOX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SHELLINABOX_BUILD_DIR=$(BUILD_DIR)/shellinabox
SHELLINABOX_SOURCE_DIR=$(SOURCE_DIR)/shellinabox
SHELLINABOX_IPK_DIR=$(BUILD_DIR)/shellinabox-$(SHELLINABOX_VERSION)-ipk
SHELLINABOX_IPK=$(BUILD_DIR)/shellinabox_$(SHELLINABOX_VERSION)-$(SHELLINABOX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: shellinabox-source shellinabox-unpack shellinabox shellinabox-stage shellinabox-ipk shellinabox-clean shellinabox-dirclean shellinabox-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SHELLINABOX_SOURCE_SAVE):
	$(WGET) -O $@ $(SHELLINABOX_SITE)/$(SHELLINABOX_SOURCE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
shellinabox-source: $(DL_DIR)/$(SHELLINABOX_SOURCE_SAVE) $(SHELLINABOX_PATCHES)

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
$(SHELLINABOX_BUILD_DIR)/.configured: $(DL_DIR)/$(SHELLINABOX_SOURCE_SAVE) $(SHELLINABOX_PATCHES) make/shellinabox.mk
	$(MAKE) libpam-stage openssl-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(SHELLINABOX_DIR) $(@D)
	$(SHELLINABOX_UNZIP) $(DL_DIR)/$(SHELLINABOX_SOURCE_SAVE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SHELLINABOX_PATCHES)" ; \
		then cat $(SHELLINABOX_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SHELLINABOX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SHELLINABOX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SHELLINABOX_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SHELLINABOX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SHELLINABOX_LDFLAGS)" \
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

shellinabox-unpack: $(SHELLINABOX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SHELLINABOX_BUILD_DIR)/.built: $(SHELLINABOX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
shellinabox: $(SHELLINABOX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SHELLINABOX_BUILD_DIR)/.staged: $(SHELLINABOX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

shellinabox-stage: $(SHELLINABOX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/shellinabox
#
$(SHELLINABOX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: shellinabox" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SHELLINABOX_PRIORITY)" >>$@
	@echo "Section: $(SHELLINABOX_SECTION)" >>$@
	@echo "Version: $(SHELLINABOX_VERSION)-$(SHELLINABOX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SHELLINABOX_MAINTAINER)" >>$@
	@echo "Source: $(SHELLINABOX_SITE)/$(SHELLINABOX_SOURCE)" >>$@
	@echo "Description: $(SHELLINABOX_DESCRIPTION)" >>$@
	@echo "Depends: $(SHELLINABOX_DEPENDS)" >>$@
	@echo "Suggests: $(SHELLINABOX_SUGGESTS)" >>$@
	@echo "Conflicts: $(SHELLINABOX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/shellinabox/...
# Documentation files should be installed in $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/doc/shellinabox/...
# Daemon startup scripts should be installed in $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??shellinabox
#
# You may need to patch your application to make it use these locations.
#
$(SHELLINABOX_IPK): $(SHELLINABOX_BUILD_DIR)/.built
	rm -rf $(SHELLINABOX_IPK_DIR) $(BUILD_DIR)/shellinabox_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SHELLINABOX_BUILD_DIR) DESTDIR=$(SHELLINABOX_IPK_DIR) install
	$(STRIP_COMMAND) $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/bin/*
#	$(INSTALL) -d $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SHELLINABOX_SOURCE_DIR)/shellinabox.conf $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/shellinabox.conf
#	$(INSTALL) -d $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SHELLINABOX_SOURCE_DIR)/rc.shellinabox $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshellinabox
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELLINABOX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXshellinabox
	$(MAKE) $(SHELLINABOX_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SHELLINABOX_SOURCE_DIR)/postinst $(SHELLINABOX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELLINABOX_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SHELLINABOX_SOURCE_DIR)/prerm $(SHELLINABOX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SHELLINABOX_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SHELLINABOX_IPK_DIR)/CONTROL/postinst $(SHELLINABOX_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SHELLINABOX_CONFFILES) | sed -e 's/ /\n/g' > $(SHELLINABOX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SHELLINABOX_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SHELLINABOX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
shellinabox-ipk: $(SHELLINABOX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
shellinabox-clean:
	rm -f $(SHELLINABOX_BUILD_DIR)/.built
	-$(MAKE) -C $(SHELLINABOX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
shellinabox-dirclean:
	rm -rf $(BUILD_DIR)/$(SHELLINABOX_DIR) $(SHELLINABOX_BUILD_DIR) $(SHELLINABOX_IPK_DIR) $(SHELLINABOX_IPK)
#
#
# Some sanity check for the package.
#
shellinabox-check: $(SHELLINABOX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
