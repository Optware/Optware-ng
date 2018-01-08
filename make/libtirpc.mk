###########################################################
#
# libtirpc
#
###########################################################
#
# LIBTIRPC_VERSION, LIBTIRPC_SITE and LIBTIRPC_SOURCE define
# the upstream location of the source code for the package.
# LIBTIRPC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTIRPC_UNZIP is the command used to unzip the source.
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
LIBTIRPC_URL=http://$(SOURCEFORGE_MIRROR)/sourceforge/libtirpc/$(LIBTIRPC_SOURCE)
LIBTIRPC_VERSION=1.0.2
LIBTIRPC_SOURCE=libtirpc-$(LIBTIRPC_VERSION).tar.bz2
LIBTIRPC_DIR=libtirpc-$(LIBTIRPC_VERSION)
LIBTIRPC_UNZIP=bzcat
LIBTIRPC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTIRPC_DESCRIPTION=The libtirpc package contains libraries that support programs that use the Remote Procedure Call (RPC) API.
LIBTIRPC_SECTION=libs
LIBTIRPC_PRIORITY=optional
LIBTIRPC_DEPENDS=
LIBTIRPC_SUGGESTS=
LIBTIRPC_CONFLICTS=

#
# LIBTIRPC_IPK_VERSION should be incremented when the ipk changes.
#
LIBTIRPC_IPK_VERSION=2

#
# LIBTIRPC_CONFFILES should be a list of user-editable files
LIBTIRPC_CONFFILES=$(TARGET_PREFIX)/etc/netconfig #$(TARGET_PREFIX)/etc/init.d/SXXlibtirpc

#
# LIBTIRPC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBTIRPC_PATCHES=\
$(LIBTIRPC_SOURCE_DIR)/bzero.patch \
$(LIBTIRPC_SOURCE_DIR)/netconfig-path.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTIRPC_CPPFLAGS=
LIBTIRPC_LDFLAGS=

#
# LIBTIRPC_BUILD_DIR is the directory in which the build is done.
# LIBTIRPC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTIRPC_IPK_DIR is the directory in which the ipk is built.
# LIBTIRPC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTIRPC_BUILD_DIR=$(BUILD_DIR)/libtirpc
LIBTIRPC_SOURCE_DIR=$(SOURCE_DIR)/libtirpc
LIBTIRPC_IPK_DIR=$(BUILD_DIR)/libtirpc-$(LIBTIRPC_VERSION)-ipk
LIBTIRPC_IPK=$(BUILD_DIR)/libtirpc_$(LIBTIRPC_VERSION)-$(LIBTIRPC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtirpc-source libtirpc-unpack libtirpc libtirpc-stage libtirpc-ipk libtirpc-clean libtirpc-dirclean libtirpc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBTIRPC_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBTIRPC_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBTIRPC_SOURCE).sha512
#
$(DL_DIR)/$(LIBTIRPC_SOURCE):
	$(WGET) -O $@ $(LIBTIRPC_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtirpc-source: $(DL_DIR)/$(LIBTIRPC_SOURCE) $(LIBTIRPC_PATCHES)

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
$(LIBTIRPC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTIRPC_SOURCE) $(LIBTIRPC_PATCHES) make/libtirpc.mk
	rm -rf $(BUILD_DIR)/$(LIBTIRPC_DIR) $(@D)
	$(LIBTIRPC_UNZIP) $(DL_DIR)/$(LIBTIRPC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTIRPC_PATCHES)" ; \
		then cat $(LIBTIRPC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBTIRPC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTIRPC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBTIRPC_DIR) $(@D) ; \
	fi
	sed -i -e '/stdlib.h/a#include <stdint.h>' $(@D)/src/xdr_sizeof.c
	sed -i -e '/key_secret_is/s/secret/secretkey/' $(@D)/src/libtirpc.map
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTIRPC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTIRPC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-gssapi \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtirpc-unpack: $(LIBTIRPC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTIRPC_BUILD_DIR)/.built: $(LIBTIRPC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libtirpc: $(LIBTIRPC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTIRPC_BUILD_DIR)/.staged: $(LIBTIRPC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libtirpc.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' \
		$(STAGING_LIB_DIR)/pkgconfig/libtirpc.pc
	touch $@

libtirpc-stage: $(LIBTIRPC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtirpc
#
$(LIBTIRPC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libtirpc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTIRPC_PRIORITY)" >>$@
	@echo "Section: $(LIBTIRPC_SECTION)" >>$@
	@echo "Version: $(LIBTIRPC_VERSION)-$(LIBTIRPC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTIRPC_MAINTAINER)" >>$@
	@echo "Source: $(LIBTIRPC_URL)" >>$@
	@echo "Description: $(LIBTIRPC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTIRPC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTIRPC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTIRPC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/libtirpc/...
# Documentation files should be installed in $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/doc/libtirpc/...
# Daemon startup scripts should be installed in $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libtirpc
#
# You may need to patch your application to make it use these locations.
#
$(LIBTIRPC_IPK): $(LIBTIRPC_BUILD_DIR)/.built
	rm -rf $(LIBTIRPC_IPK_DIR) $(BUILD_DIR)/libtirpc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTIRPC_BUILD_DIR) DESTDIR=$(LIBTIRPC_IPK_DIR) install-strip
	rm -f $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/lib/libtirpc.la
#	$(INSTALL) -d $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBTIRPC_SOURCE_DIR)/libtirpc.conf $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/libtirpc.conf
#	$(INSTALL) -d $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBTIRPC_SOURCE_DIR)/rc.libtirpc $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtirpc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTIRPC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtirpc
	$(MAKE) $(LIBTIRPC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBTIRPC_SOURCE_DIR)/postinst $(LIBTIRPC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTIRPC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBTIRPC_SOURCE_DIR)/prerm $(LIBTIRPC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTIRPC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBTIRPC_IPK_DIR)/CONTROL/postinst $(LIBTIRPC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBTIRPC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTIRPC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTIRPC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBTIRPC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtirpc-ipk: $(LIBTIRPC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtirpc-clean:
	rm -f $(LIBTIRPC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBTIRPC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtirpc-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTIRPC_DIR) $(LIBTIRPC_BUILD_DIR) $(LIBTIRPC_IPK_DIR) $(LIBTIRPC_IPK)
#
#
# Some sanity check for the package.
#
libtirpc-check: $(LIBTIRPC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
