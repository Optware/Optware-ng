###########################################################
#
# dnscrypt-proxy
#
###########################################################
#
# DNSCRYPT_PROXY_VERSION, DNSCRYPT_PROXY_SITE and DNSCRYPT_PROXY_SOURCE define
# the upstream location of the source code for the package.
# DNSCRYPT_PROXY_DIR is the directory which is created when the source
# archive is unpacked.
# DNSCRYPT_PROXY_UNZIP is the command used to unzip the source.
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
DNSCRYPT_PROXY_URL=https://github.com/jedisct1/dnscrypt-proxy/releases/download/$(DNSCRYPT_PROXY_VERSION)/dnscrypt-proxy-$(DNSCRYPT_PROXY_VERSION).tar.bz2
DNSCRYPT_PROXY_VERSION=1.6.0
DNSCRYPT_PROXY_SOURCE=dnscrypt-proxy-$(DNSCRYPT_PROXY_VERSION).tar.gz
DNSCRYPT_PROXY_DIR=dnscrypt-proxy-$(DNSCRYPT_PROXY_VERSION)
DNSCRYPT_PROXY_UNZIP=bzcat
DNSCRYPT_PROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DNSCRYPT_PROXY_DESCRIPTION=A tool for securing communications between a client and a DNS resolver.
DNSCRYPT_PROXY_SECTION=net
DNSCRYPT_PROXY_PRIORITY=optional
DNSCRYPT_PROXY_DEPENDS=libsodium
DNSCRYPT_PROXY_SUGGESTS=
DNSCRYPT_PROXY_CONFLICTS=

#
# DNSCRYPT_PROXY_IPK_VERSION should be incremented when the ipk changes.
#
DNSCRYPT_PROXY_IPK_VERSION=2

#
# DNSCRYPT_PROXY_CONFFILES should be a list of user-editable files
#DNSCRYPT_PROXY_CONFFILES=$(TARGET_PREFIX)/etc/dnscrypt-proxy.conf $(TARGET_PREFIX)/etc/init.d/SXXdnscrypt-proxy

#
# DNSCRYPT_PROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DNSCRYPT_PROXY_PATCHES=$(DNSCRYPT_PROXY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DNSCRYPT_PROXY_CPPFLAGS=
DNSCRYPT_PROXY_LDFLAGS=

#
# DNSCRYPT_PROXY_BUILD_DIR is the directory in which the build is done.
# DNSCRYPT_PROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DNSCRYPT_PROXY_IPK_DIR is the directory in which the ipk is built.
# DNSCRYPT_PROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DNSCRYPT_PROXY_BUILD_DIR=$(BUILD_DIR)/dnscrypt-proxy
DNSCRYPT_PROXY_SOURCE_DIR=$(SOURCE_DIR)/dnscrypt-proxy
DNSCRYPT_PROXY_IPK_DIR=$(BUILD_DIR)/dnscrypt-proxy-$(DNSCRYPT_PROXY_VERSION)-ipk
DNSCRYPT_PROXY_IPK=$(BUILD_DIR)/dnscrypt-proxy_$(DNSCRYPT_PROXY_VERSION)-$(DNSCRYPT_PROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dnscrypt-proxy-source dnscrypt-proxy-unpack dnscrypt-proxy dnscrypt-proxy-stage dnscrypt-proxy-ipk dnscrypt-proxy-clean dnscrypt-proxy-dirclean dnscrypt-proxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(DNSCRYPT_PROXY_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(DNSCRYPT_PROXY_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(DNSCRYPT_PROXY_SOURCE).sha512
#
$(DL_DIR)/$(DNSCRYPT_PROXY_SOURCE):
	$(WGET) -O $@ $(DNSCRYPT_PROXY_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dnscrypt-proxy-source: $(DL_DIR)/$(DNSCRYPT_PROXY_SOURCE) $(DNSCRYPT_PROXY_PATCHES)

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
$(DNSCRYPT_PROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(DNSCRYPT_PROXY_SOURCE) $(DNSCRYPT_PROXY_PATCHES) make/dnscrypt-proxy.mk
	$(MAKE) libsodium-stage
	rm -rf $(BUILD_DIR)/$(DNSCRYPT_PROXY_DIR) $(@D)
	$(DNSCRYPT_PROXY_UNZIP) $(DL_DIR)/$(DNSCRYPT_PROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DNSCRYPT_PROXY_PATCHES)" ; \
		then cat $(DNSCRYPT_PROXY_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DNSCRYPT_PROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DNSCRYPT_PROXY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DNSCRYPT_PROXY_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DNSCRYPT_PROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DNSCRYPT_PROXY_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
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

dnscrypt-proxy-unpack: $(DNSCRYPT_PROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DNSCRYPT_PROXY_BUILD_DIR)/.built: $(DNSCRYPT_PROXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
dnscrypt-proxy: $(DNSCRYPT_PROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DNSCRYPT_PROXY_BUILD_DIR)/.staged: $(DNSCRYPT_PROXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

dnscrypt-proxy-stage: $(DNSCRYPT_PROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dnscrypt-proxy
#
$(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dnscrypt-proxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DNSCRYPT_PROXY_PRIORITY)" >>$@
	@echo "Section: $(DNSCRYPT_PROXY_SECTION)" >>$@
	@echo "Version: $(DNSCRYPT_PROXY_VERSION)-$(DNSCRYPT_PROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DNSCRYPT_PROXY_MAINTAINER)" >>$@
	@echo "Source: $(DNSCRYPT_PROXY_URL)" >>$@
	@echo "Description: $(DNSCRYPT_PROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(DNSCRYPT_PROXY_DEPENDS)" >>$@
	@echo "Suggests: $(DNSCRYPT_PROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(DNSCRYPT_PROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/dnscrypt-proxy/...
# Documentation files should be installed in $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/doc/dnscrypt-proxy/...
# Daemon startup scripts should be installed in $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??dnscrypt-proxy
#
# You may need to patch your application to make it use these locations.
#
$(DNSCRYPT_PROXY_IPK): $(DNSCRYPT_PROXY_BUILD_DIR)/.built
	rm -rf $(DNSCRYPT_PROXY_IPK_DIR) $(BUILD_DIR)/dnscrypt-proxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DNSCRYPT_PROXY_BUILD_DIR) DESTDIR=$(DNSCRYPT_PROXY_IPK_DIR) install-strip
#	$(INSTALL) -d $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(DNSCRYPT_PROXY_SOURCE_DIR)/dnscrypt-proxy.conf $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/dnscrypt-proxy.conf
#	$(INSTALL) -d $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(DNSCRYPT_PROXY_SOURCE_DIR)/rc.dnscrypt-proxy $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXdnscrypt-proxy
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSCRYPT_PROXY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXdnscrypt-proxy
	$(MAKE) $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(DNSCRYPT_PROXY_SOURCE_DIR)/postinst $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(DNSCRYPT_PROXY_SOURCE_DIR)/prerm $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/postinst $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(DNSCRYPT_PROXY_CONFFILES) | sed -e 's/ /\n/g' > $(DNSCRYPT_PROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DNSCRYPT_PROXY_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DNSCRYPT_PROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dnscrypt-proxy-ipk: $(DNSCRYPT_PROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dnscrypt-proxy-clean:
	rm -f $(DNSCRYPT_PROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(DNSCRYPT_PROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dnscrypt-proxy-dirclean:
	rm -rf $(BUILD_DIR)/$(DNSCRYPT_PROXY_DIR) $(DNSCRYPT_PROXY_BUILD_DIR) $(DNSCRYPT_PROXY_IPK_DIR) $(DNSCRYPT_PROXY_IPK)
#
#
# Some sanity check for the package.
#
dnscrypt-proxy-check: $(DNSCRYPT_PROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
