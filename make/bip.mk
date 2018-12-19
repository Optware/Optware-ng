###########################################################
#
# bip
#
###########################################################

# You must replace "bip" and "BIP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BIP_VERSION, BIP_SITE and BIP_SOURCE define
# the upstream location of the source code for the package.
# BIP_DIR is the directory which is created when the source
# archive is unpacked.
# BIP_UNZIP is the command used to unzip the source.
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
BIP_SITE=https://projects.duckcorp.org/attachments/download/61
BIP_VERSION=0.8.9
BIP_SOURCE=bip-$(BIP_VERSION).tar.gz
BIP_DIR=bip-$(BIP_VERSION)
BIP_UNZIP=zcat
BIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BIP_DESCRIPTION=multi user irc proxy
BIP_SECTION=net
BIP_PRIORITY=optional
BIP_DEPENDS=openssl, psmisc
BIP_SUGGESTS=
BIP_CONFLICTS=

#
# BIP_IPK_VERSION should be incremented when the ipk changes.
#
BIP_IPK_VERSION=2

#
# BIP_CONFFILES should be a list of user-editable files
BIP_CONFFILES=$(TARGET_PREFIX)/etc/bip.conf $(TARGET_PREFIX)/etc/init.d/S99bip $(TARGET_PREFIX)/etc/default/bip

#
# BIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BIP_PATCHES=$(BIP_SOURCE_DIR)/log.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BIP_CPPFLAGS=
BIP_LDFLAGS=

#
# BIP_BUILD_DIR is the directory in which the build is done.
# BIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BIP_IPK_DIR is the directory in which the ipk is built.
# BIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BIP_BUILD_DIR=$(BUILD_DIR)/bip
BIP_SOURCE_DIR=$(SOURCE_DIR)/bip
BIP_IPK_DIR=$(BUILD_DIR)/bip-$(BIP_VERSION)-ipk
BIP_IPK=$(BUILD_DIR)/bip_$(BIP_VERSION)-$(BIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BIP_SOURCE):
	$(WGET) -P $(@D) $(BIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bip-source: $(DL_DIR)/$(BIP_SOURCE) $(BIP_PATCHES)

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
$(BIP_BUILD_DIR)/.configured: $(DL_DIR)/$(BIP_SOURCE) $(BIP_PATCHES) make/bip.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(BIP_DIR) $(@D)
	$(BIP_UNZIP) $(DL_DIR)/$(BIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BIP_PATCHES)" ; \
		then cat $(BIP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(BIP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(BIP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BIP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BIP_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		ac_cv_lib_crypto_CRYPTO_new_ex_data=yes \
		ac_cv_lib_ssl_SSL_read=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
	    sed -i -e 's/ -fPIE//' $(@D)/Makefile; \
	fi
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bip-unpack: $(BIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BIP_BUILD_DIR)/.built: $(BIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(BIP_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
bip: $(BIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BIP_BUILD_DIR)/.staged: $(BIP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(BIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bip-stage: $(BIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bip
#
$(BIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: bip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BIP_PRIORITY)" >>$@
	@echo "Section: $(BIP_SECTION)" >>$@
	@echo "Version: $(BIP_VERSION)-$(BIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BIP_MAINTAINER)" >>$@
	@echo "Source: $(BIP_SITE)/$(BIP_SOURCE)" >>$@
	@echo "Description: $(BIP_DESCRIPTION)" >>$@
	@echo "Depends: $(BIP_DEPENDS)" >>$@
	@echo "Suggests: $(BIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(BIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BIP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BIP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BIP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/bip/...
# Documentation files should be installed in $(BIP_IPK_DIR)$(TARGET_PREFIX)/doc/bip/...
# Daemon startup scripts should be installed in $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??bip
#
# You may need to patch your application to make it use these locations.
#
$(BIP_IPK): $(BIP_BUILD_DIR)/.built
	rm -rf $(BIP_IPK_DIR) $(BUILD_DIR)/bip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BIP_BUILD_DIR) DESTDIR=$(BIP_IPK_DIR) install-strip
	$(INSTALL) -d $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/default
	$(INSTALL) -m 644 $(BIP_BUILD_DIR)/samples/bip.conf $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 644 $(BIP_SOURCE_DIR)/default.bip $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/default/bip
	$(INSTALL) -d $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(BIP_SOURCE_DIR)/rc.bip $(BIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S99bip
	$(MAKE) $(BIP_IPK_DIR)/CONTROL/control
	echo $(BIP_CONFFILES) | sed -e 's/ /\n/g' > $(BIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BIP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bip-ipk: $(BIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bip-clean:
	rm -f $(BIP_BUILD_DIR)/.built
	-$(MAKE) -C $(BIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bip-dirclean:
	rm -rf $(BUILD_DIR)/$(BIP_DIR) $(BIP_BUILD_DIR) $(BIP_IPK_DIR) $(BIP_IPK)

#
# Some sanity check for the package.
#
bip-check: $(BIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
