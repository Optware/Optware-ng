###########################################################
#
# librpc-uclibc
#
###########################################################
#
# LIBRPC_UCLIBC_VERSION, LIBRPC_UCLIBC_SITE and LIBRPC_UCLIBC_SOURCE define
# the upstream location of the source code for the package.
# LIBRPC_UCLIBC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBRPC_UCLIBC_UNZIP is the command used to unzip the source.
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
LIBRPC_UCLIBC_URL=https://git.openwrt.org/project/librpc-uclibc.git
LIBRPC_UCLIBC_VERSION=20151104
LIBRPC_UCLIBC_TREEISH=a921e3ded051746f9f7cd5e5a312fb6771716aac
LIBRPC_UCLIBC_SOURCE=librpc-uclibc-$(LIBRPC_UCLIBC_VERSION).tar.gz
LIBRPC_UCLIBC_DIR=librpc-uclibc-$(LIBRPC_UCLIBC_VERSION)
LIBRPC_UCLIBC_UNZIP=zcat
LIBRPC_UCLIBC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBRPC_UCLIBC_DESCRIPTION=uClibc RPC library
LIBRPC_UCLIBC_SECTION=libs
LIBRPC_UCLIBC_PRIORITY=optional
LIBRPC_UCLIBC_DEPENDS=
LIBRPC_UCLIBC_SUGGESTS=
LIBRPC_UCLIBC_CONFLICTS=

#
# LIBRPC_UCLIBC_IPK_VERSION should be incremented when the ipk changes.
#
LIBRPC_UCLIBC_IPK_VERSION=2

#
# LIBRPC_UCLIBC_CONFFILES should be a list of user-editable files
#LIBRPC_UCLIBC_CONFFILES=$(TARGET_PREFIX)/etc/librpc-uclibc.conf $(TARGET_PREFIX)/etc/init.d/SXXlibrpc-uclibc

#
# LIBRPC_UCLIBC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBRPC_UCLIBC_PATCHES=\
$(LIBRPC_UCLIBC_SOURCE_DIR)/Makefile.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBRPC_UCLIBC_CPPFLAGS=
LIBRPC_UCLIBC_LDFLAGS=

#
# LIBRPC_UCLIBC_BUILD_DIR is the directory in which the build is done.
# LIBRPC_UCLIBC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBRPC_UCLIBC_IPK_DIR is the directory in which the ipk is built.
# LIBRPC_UCLIBC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBRPC_UCLIBC_BUILD_DIR=$(BUILD_DIR)/librpc-uclibc
LIBRPC_UCLIBC_SOURCE_DIR=$(SOURCE_DIR)/librpc-uclibc
LIBRPC_UCLIBC_IPK_DIR=$(BUILD_DIR)/librpc-uclibc-$(LIBRPC_UCLIBC_VERSION)-ipk
LIBRPC_UCLIBC_IPK=$(BUILD_DIR)/librpc-uclibc_$(LIBRPC_UCLIBC_VERSION)-$(LIBRPC_UCLIBC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: librpc-uclibc-source librpc-uclibc-unpack librpc-uclibc librpc-uclibc-stage librpc-uclibc-ipk librpc-uclibc-clean librpc-uclibc-dirclean librpc-uclibc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBRPC_UCLIBC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBRPC_UCLIBC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBRPC_UCLIBC_SOURCE).sha512
#
$(DL_DIR)/$(LIBRPC_UCLIBC_SOURCE):
	(cd $(BUILD_DIR) ; \
		rm -rf librpc-uclibc && \
		git clone --bare $(LIBRPC_UCLIBC_URL) librpc-uclibc && \
		(cd librpc-uclibc && \
		git archive --format=tar --prefix=$(LIBRPC_UCLIBC_DIR)/ $(LIBRPC_UCLIBC_TREEISH) | gzip > $@) && \
		rm -rf librpc-uclibc ; \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
librpc-uclibc-source: $(DL_DIR)/$(LIBRPC_UCLIBC_SOURCE) $(LIBRPC_UCLIBC_PATCHES)

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
$(LIBRPC_UCLIBC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBRPC_UCLIBC_SOURCE) $(LIBRPC_UCLIBC_PATCHES) make/librpc-uclibc.mk
	rm -rf $(BUILD_DIR)/$(LIBRPC_UCLIBC_DIR) $(@D)
	$(LIBRPC_UCLIBC_UNZIP) $(DL_DIR)/$(LIBRPC_UCLIBC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBRPC_UCLIBC_PATCHES)" ; \
		then cat $(LIBRPC_UCLIBC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBRPC_UCLIBC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBRPC_UCLIBC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBRPC_UCLIBC_DIR) $(@D) ; \
	fi
	touch $@

librpc-uclibc-unpack: $(LIBRPC_UCLIBC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBRPC_UCLIBC_BUILD_DIR)/.built: $(LIBRPC_UCLIBC_BUILD_DIR)/.configured
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBRPC_UCLIBC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBRPC_UCLIBC_LDFLAGS)" \
		$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
librpc-uclibc: $(LIBRPC_UCLIBC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBRPC_UCLIBC_BUILD_DIR)/.staged: $(LIBRPC_UCLIBC_BUILD_DIR)/.built
	rm -f $@
	mkdir -p $(STAGING_LIB_DIR) $(STAGING_INCLUDE_DIR)/rpc-uclibc
	cp -af $(@D)/rpc $(STAGING_INCLUDE_DIR)/rpc-uclibc
	cp -af $(@D)/librpc-uclibc.so* $(STAGING_LIB_DIR)
	touch $@

librpc-uclibc-stage: $(LIBRPC_UCLIBC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/librpc-uclibc
#
$(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: librpc-uclibc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBRPC_UCLIBC_PRIORITY)" >>$@
	@echo "Section: $(LIBRPC_UCLIBC_SECTION)" >>$@
	@echo "Version: $(LIBRPC_UCLIBC_VERSION)-$(LIBRPC_UCLIBC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBRPC_UCLIBC_MAINTAINER)" >>$@
	@echo "Source: $(LIBRPC_UCLIBC_URL)" >>$@
	@echo "Description: $(LIBRPC_UCLIBC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBRPC_UCLIBC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBRPC_UCLIBC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBRPC_UCLIBC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/librpc-uclibc/...
# Documentation files should be installed in $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/doc/librpc-uclibc/...
# Daemon startup scripts should be installed in $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??librpc-uclibc
#
# You may need to patch your application to make it use these locations.
#
$(LIBRPC_UCLIBC_IPK): $(LIBRPC_UCLIBC_BUILD_DIR)/.built
	rm -rf $(LIBRPC_UCLIBC_IPK_DIR) $(BUILD_DIR)/librpc-uclibc_*_$(TARGET_ARCH).ipk
	mkdir -p $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/{lib,include/rpc-uclibc}
	cp -af $(LIBRPC_UCLIBC_BUILD_DIR)/rpc $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/include/rpc-uclibc
	cp -af $(LIBRPC_UCLIBC_BUILD_DIR)/librpc-uclibc.so* $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/lib/librpc-uclibc.so
#	$(INSTALL) -d $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBRPC_UCLIBC_SOURCE_DIR)/librpc-uclibc.conf $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/librpc-uclibc.conf
#	$(INSTALL) -d $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBRPC_UCLIBC_SOURCE_DIR)/rc.librpc-uclibc $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibrpc-uclibc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRPC_UCLIBC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibrpc-uclibc
	$(MAKE) $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBRPC_UCLIBC_SOURCE_DIR)/postinst $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBRPC_UCLIBC_SOURCE_DIR)/prerm $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/postinst $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBRPC_UCLIBC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBRPC_UCLIBC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBRPC_UCLIBC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBRPC_UCLIBC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
librpc-uclibc-ipk: $(LIBRPC_UCLIBC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
librpc-uclibc-clean:
	rm -f $(LIBRPC_UCLIBC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBRPC_UCLIBC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
librpc-uclibc-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBRPC_UCLIBC_DIR) $(LIBRPC_UCLIBC_BUILD_DIR) $(LIBRPC_UCLIBC_IPK_DIR) $(LIBRPC_UCLIBC_IPK)
#
#
# Some sanity check for the package.
#
librpc-uclibc-check: $(LIBRPC_UCLIBC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
