###########################################################
#
# libmemcached
#
###########################################################
#
# LIBMEMCACHED_VERSION, LIBMEMCACHED_SITE and LIBMEMCACHED_SOURCE define
# the upstream location of the source code for the package.
# LIBMEMCACHED_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMEMCACHED_UNZIP is the command used to unzip the source.
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
LIBMEMCACHED_URL=https://launchpad.net/libmemcached/1.0/$(LIBMEMCACHED_VERSION)/+download/libmemcached-$(LIBMEMCACHED_VERSION).tar.gz
LIBMEMCACHED_VERSION=1.0.18
LIBMEMCACHED_SOURCE=libmemcached-$(LIBMEMCACHED_VERSION).tar.gz
LIBMEMCACHED_DIR=libmemcached-$(LIBMEMCACHED_VERSION)
LIBMEMCACHED_UNZIP=zcat
LIBMEMCACHED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMEMCACHED_DESCRIPTION=libMemcached is designed to provide the greatest number of options to use Memcached.
LIBMEMCACHED_CLIENTS_DESCRIPTION=libMemcached clients binaries
LIBMEMCACHED_SECTION=libs
LIBMEMCACHED_CLIENTS_SECTION=misc
LIBMEMCACHED_PRIORITY=optional
LIBMEMCACHED_DEPENDS=cyrus-sasl-libs, libstdc++
LIBMEMCACHED_CLIENTS_DEPENDS=libmemcached
LIBMEMCACHED_SUGGESTS=
LIBMEMCACHED_CONFLICTS=

#
# LIBMEMCACHED_IPK_VERSION should be incremented when the ipk changes.
#
LIBMEMCACHED_IPK_VERSION=4

#
# LIBMEMCACHED_CONFFILES should be a list of user-editable files
#LIBMEMCACHED_CONFFILES=$(TARGET_PREFIX)/etc/libmemcached.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmemcached

#
# LIBMEMCACHED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMEMCACHED_PATCHES=\
$(LIBMEMCACHED_SOURCE_DIR)/disable_tests.patch \
$(LIBMEMCACHED_SOURCE_DIR)/va_list-not-declared.patch \
$(LIBMEMCACHED_SOURCE_DIR)/comparison_between_pointer_and_integer_error_fix.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMEMCACHED_CPPFLAGS=
LIBMEMCACHED_LDFLAGS=

#
# LIBMEMCACHED_BUILD_DIR is the directory in which the build is done.
# LIBMEMCACHED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMEMCACHED_IPK_DIR is the directory in which the ipk is built.
# LIBMEMCACHED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMEMCACHED_BUILD_DIR=$(BUILD_DIR)/libmemcached
LIBMEMCACHED_SOURCE_DIR=$(SOURCE_DIR)/libmemcached

LIBMEMCACHED_IPK_DIR=$(BUILD_DIR)/libmemcached-$(LIBMEMCACHED_VERSION)-ipk
LIBMEMCACHED_IPK=$(BUILD_DIR)/libmemcached_$(LIBMEMCACHED_VERSION)-$(LIBMEMCACHED_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBMEMCACHED_CLIENTS_IPK_DIR=$(BUILD_DIR)/libmemcached-clients-$(LIBMEMCACHED_VERSION)-ipk
LIBMEMCACHED_CLIENTS_IPK=$(BUILD_DIR)/libmemcached-clients_$(LIBMEMCACHED_VERSION)-$(LIBMEMCACHED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmemcached-source libmemcached-unpack libmemcached libmemcached-stage libmemcached-ipk libmemcached-clean libmemcached-dirclean libmemcached-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(LIBMEMCACHED_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(LIBMEMCACHED_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(LIBMEMCACHED_SOURCE).sha512
#
$(DL_DIR)/$(LIBMEMCACHED_SOURCE):
	$(WGET) -O $@ $(LIBMEMCACHED_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmemcached-source: $(DL_DIR)/$(LIBMEMCACHED_SOURCE) $(LIBMEMCACHED_PATCHES)

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
$(LIBMEMCACHED_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMEMCACHED_SOURCE) $(LIBMEMCACHED_PATCHES) make/libmemcached.mk
	$(MAKE) cyrus-sasl-stage
	rm -rf $(BUILD_DIR)/$(LIBMEMCACHED_DIR) $(@D)
	$(LIBMEMCACHED_UNZIP) $(DL_DIR)/$(LIBMEMCACHED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMEMCACHED_PATCHES)" ; \
		then cat $(LIBMEMCACHED_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMEMCACHED_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMEMCACHED_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMEMCACHED_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMEMCACHED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMEMCACHED_LDFLAGS)" \
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

libmemcached-unpack: $(LIBMEMCACHED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMEMCACHED_BUILD_DIR)/.built: $(LIBMEMCACHED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libmemcached: $(LIBMEMCACHED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMEMCACHED_BUILD_DIR)/.staged: $(LIBMEMCACHED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install_sh=$(@D)/build-aux/install-sh install
	rm -f $(STAGING_LIB_DIR)/{libhashkit.la,libmemcached.la,libmemcachedutil.la}
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libmemcached.pc
	touch $@

libmemcached-stage: $(LIBMEMCACHED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmemcached
#
$(LIBMEMCACHED_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmemcached" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMEMCACHED_PRIORITY)" >>$@
	@echo "Section: $(LIBMEMCACHED_SECTION)" >>$@
	@echo "Version: $(LIBMEMCACHED_VERSION)-$(LIBMEMCACHED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMEMCACHED_MAINTAINER)" >>$@
	@echo "Source: $(LIBMEMCACHED_URL)" >>$@
	@echo "Description: $(LIBMEMCACHED_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMEMCACHED_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMEMCACHED_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMEMCACHED_CONFLICTS)" >>$@

$(LIBMEMCACHED_CLIENTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmemcached-clients" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMEMCACHED_PRIORITY)" >>$@
	@echo "Section: $(LIBMEMCACHED_SECTION)" >>$@
	@echo "Version: $(LIBMEMCACHED_VERSION)-$(LIBMEMCACHED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMEMCACHED_MAINTAINER)" >>$@
	@echo "Source: $(LIBMEMCACHED_URL)" >>$@
	@echo "Description: $(LIBMEMCACHED_CLIENTS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMEMCACHED_CLIENTS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMEMCACHED_CLIENTS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMEMCACHED_CLIENTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/libmemcached/...
# Documentation files should be installed in $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/doc/libmemcached/...
# Daemon startup scripts should be installed in $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmemcached
#
# You may need to patch your application to make it use these locations.
#
$(LIBMEMCACHED_IPK) $(LIBMEMCACHED_CLIENTS_IPK): $(LIBMEMCACHED_BUILD_DIR)/.built
	rm -rf $(LIBMEMCACHED_IPK_DIR) $(BUILD_DIR)/libmemcached_*_$(TARGET_ARCH).ipk \
		$(LIBMEMCACHED_CLIENTS_IPK_DIR) $(BUILD_DIR)/libmemcached-clients_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMEMCACHED_BUILD_DIR) DESTDIR=$(LIBMEMCACHED_IPK_DIR) install_sh=$(LIBMEMCACHED_BUILD_DIR)/build-aux/install-sh install-strip
	rm -f $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/lib/*.la
	$(INSTALL) -d $(LIBMEMCACHED_CLIENTS_IPK_DIR)$(TARGET_PREFIX)/share/man
	mv -f $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/bin $(LIBMEMCACHED_CLIENTS_IPK_DIR)$(TARGET_PREFIX)
	mv -f $(LIBMEMCACHED_IPK_DIR)$(TARGET_PREFIX)/share/man/man1 $(LIBMEMCACHED_CLIENTS_IPK_DIR)$(TARGET_PREFIX)/share/man
	$(MAKE) $(LIBMEMCACHED_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMEMCACHED_SOURCE_DIR)/postinst $(LIBMEMCACHED_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMEMCACHED_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMEMCACHED_SOURCE_DIR)/prerm $(LIBMEMCACHED_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMEMCACHED_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBMEMCACHED_IPK_DIR)/CONTROL/postinst $(LIBMEMCACHED_IPK_DIR)/CONTROL/prerm; \
	fi
	$(MAKE) $(LIBMEMCACHED_IPK_DIR)/CONTROL/control
	echo $(LIBMEMCACHED_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMEMCACHED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMEMCACHED_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBMEMCACHED_IPK_DIR)
	$(MAKE) $(LIBMEMCACHED_CLIENTS_IPK_DIR)/CONTROL/control
	echo $(LIBMEMCACHED_CLIENTS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMEMCACHED_CLIENTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMEMCACHED_CLIENTS_IPK_DIR)
#	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBMEMCACHED_CLIENTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmemcached-ipk: $(LIBMEMCACHED_IPK) $(LIBMEMCACHED_CLIENTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmemcached-clean:
	rm -f $(LIBMEMCACHED_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMEMCACHED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmemcached-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMEMCACHED_DIR) $(LIBMEMCACHED_BUILD_DIR) \
		$(LIBMEMCACHED_IPK_DIR) $(LIBMEMCACHED_IPK) \
		$(LIBMEMCACHED_CLIENTS_IPK_DIR) $(LIBMEMCACHED_CLIENTS_IPK)
#
#
# Some sanity check for the package.
#
libmemcached-check: $(LIBMEMCACHED_IPK) $(LIBMEMCACHED_CLIENTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
