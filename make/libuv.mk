###########################################################
#
# libuv
#
###########################################################
#
# LIBUV_VERSION, LIBUV_SITE and LIBUV_SOURCE define
# the upstream location of the source code for the package.
# LIBUV_DIR is the directory which is created when the source
# archive is unpacked.
# LIBUV_UNZIP is the command used to unzip the source.
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
LIBUV_URL=http://dist.libuv.org/dist/v$(LIBUV_VERSION)/libuv-v$(LIBUV_VERSION).tar.gz
LIBUV_VERSION=1.9.1
LIBUV_SOURCE=libuv-v$(LIBUV_VERSION).tar.gz
LIBUV_DIR=libuv-v$(LIBUV_VERSION)
LIBUV_UNZIP=zcat
LIBUV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBUV_DESCRIPTION=Cross-platform asychronous I/O library.
LIBUV_SECTION=lib
LIBUV_PRIORITY=optional
LIBUV_DEPENDS=
LIBUV_SUGGESTS=
LIBUV_CONFLICTS=

#
# LIBUV_IPK_VERSION should be incremented when the ipk changes.
#
LIBUV_IPK_VERSION=2

#
# LIBUV_CONFFILES should be a list of user-editable files
#LIBUV_CONFFILES=$(TARGET_PREFIX)/etc/libuv.conf $(TARGET_PREFIX)/etc/init.d/SXXlibuv

#
# LIBUV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBUV_PATCHES=$(LIBUV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBUV_CPPFLAGS=
LIBUV_LDFLAGS=

#
# LIBUV_BUILD_DIR is the directory in which the build is done.
# LIBUV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBUV_IPK_DIR is the directory in which the ipk is built.
# LIBUV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBUV_BUILD_DIR=$(BUILD_DIR)/libuv
LIBUV_SOURCE_DIR=$(SOURCE_DIR)/libuv
LIBUV_IPK_DIR=$(BUILD_DIR)/libuv-$(LIBUV_VERSION)-ipk
LIBUV_IPK=$(BUILD_DIR)/libuv_$(LIBUV_VERSION)-$(LIBUV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libuv-source libuv-unpack libuv libuv-stage libuv-ipk libuv-clean libuv-dirclean libuv-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBUV_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBUV_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBUV_SOURCE).sha512
#
$(DL_DIR)/$(LIBUV_SOURCE):
	$(WGET) -O $@ $(LIBUV_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libuv-source: $(DL_DIR)/$(LIBUV_SOURCE) $(LIBUV_PATCHES)

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
$(LIBUV_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBUV_SOURCE) $(LIBUV_PATCHES) make/libuv.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBUV_DIR) $(@D)
	$(LIBUV_UNZIP) $(DL_DIR)/$(LIBUV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBUV_PATCHES)" ; \
		then cat $(LIBUV_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBUV_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBUV_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBUV_DIR) $(@D) ; \
	fi
	echo "m4_define([UV_EXTRA_AUTOMAKE_FLAGS], [serial-tests])" > $(@D)/m4/libuv-extra-automake-flags.m4
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBUV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBUV_LDFLAGS)" \
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

libuv-unpack: $(LIBUV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBUV_BUILD_DIR)/.built: $(LIBUV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libuv: $(LIBUV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBUV_BUILD_DIR)/.staged: $(LIBUV_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i '/^prefix=\|^exec_prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libuv.pc
	rm -f $(STAGING_LIB_DIR)/libuv.la
	touch $@

libuv-stage: $(LIBUV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libuv
#
$(LIBUV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libuv" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBUV_PRIORITY)" >>$@
	@echo "Section: $(LIBUV_SECTION)" >>$@
	@echo "Version: $(LIBUV_VERSION)-$(LIBUV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBUV_MAINTAINER)" >>$@
	@echo "Source: $(LIBUV_URL)" >>$@
	@echo "Description: $(LIBUV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBUV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBUV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBUV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/libuv/...
# Documentation files should be installed in $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/doc/libuv/...
# Daemon startup scripts should be installed in $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libuv
#
# You may need to patch your application to make it use these locations.
#
$(LIBUV_IPK): $(LIBUV_BUILD_DIR)/.built
	rm -rf $(LIBUV_IPK_DIR) $(BUILD_DIR)/libuv_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBUV_BUILD_DIR) DESTDIR=$(LIBUV_IPK_DIR) install-strip
	rm -f $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/lib/libuv.la
#	$(INSTALL) -d $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBUV_SOURCE_DIR)/libuv.conf $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/libuv.conf
#	$(INSTALL) -d $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBUV_SOURCE_DIR)/rc.libuv $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibuv
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUV_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibuv
	$(MAKE) $(LIBUV_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBUV_SOURCE_DIR)/postinst $(LIBUV_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUV_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBUV_SOURCE_DIR)/prerm $(LIBUV_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBUV_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBUV_IPK_DIR)/CONTROL/postinst $(LIBUV_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBUV_CONFFILES) | sed -e 's/ /\n/g' > $(LIBUV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBUV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBUV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libuv-ipk: $(LIBUV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libuv-clean:
	rm -f $(LIBUV_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBUV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libuv-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBUV_DIR) $(LIBUV_BUILD_DIR) $(LIBUV_IPK_DIR) $(LIBUV_IPK)
#
#
# Some sanity check for the package.
#
libuv-check: $(LIBUV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
