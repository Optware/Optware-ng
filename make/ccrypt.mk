###########################################################
#
# ccrypt
#
###########################################################
#
# CCRYPT_VERSION, CCRYPT_SITE and CCRYPT_SOURCE define
# the upstream location of the source code for the package.
# CCRYPT_DIR is the directory which is created when the source
# archive is unpacked.
# CCRYPT_UNZIP is the command used to unzip the source.
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
CCRYPT_SITE=http://ccrypt.sourceforge.net/download
CCRYPT_VERSION=1.9
CCRYPT_SOURCE=ccrypt-$(CCRYPT_VERSION).tar.gz
CCRYPT_DIR=ccrypt-$(CCRYPT_VERSION)
CCRYPT_UNZIP=zcat
CCRYPT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CCRYPT_DESCRIPTION=Secure encryption and decryption of files and streams
CCRYPT_SECTION=utils
CCRYPT_PRIORITY=optional
CCRYPT_DEPENDS=
CCRYPT_SUGGESTS=
CCRYPT_CONFLICTS=

#
# CCRYPT_IPK_VERSION should be incremented when the ipk changes.
#
CCRYPT_IPK_VERSION=2

#
# CCRYPT_CONFFILES should be a list of user-editable files
#CCRYPT_CONFFILES=$(TARGET_PREFIX)/etc/ccrypt.conf $(TARGET_PREFIX)/etc/init.d/SXXccrypt

#
# CCRYPT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CCRYPT_PATCHES=$(CCRYPT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CCRYPT_CPPFLAGS=
CCRYPT_LDFLAGS=

#
# CCRYPT_BUILD_DIR is the directory in which the build is done.
# CCRYPT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CCRYPT_IPK_DIR is the directory in which the ipk is built.
# CCRYPT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CCRYPT_BUILD_DIR=$(BUILD_DIR)/ccrypt
CCRYPT_SOURCE_DIR=$(SOURCE_DIR)/ccrypt
CCRYPT_IPK_DIR=$(BUILD_DIR)/ccrypt-$(CCRYPT_VERSION)-ipk
CCRYPT_IPK=$(BUILD_DIR)/ccrypt_$(CCRYPT_VERSION)-$(CCRYPT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ccrypt-source ccrypt-unpack ccrypt ccrypt-stage ccrypt-ipk ccrypt-clean ccrypt-dirclean ccrypt-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CCRYPT_SOURCE):
	$(WGET) -P $(@D) $(CCRYPT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ccrypt-source: $(DL_DIR)/$(CCRYPT_SOURCE) $(CCRYPT_PATCHES)

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
$(CCRYPT_BUILD_DIR)/.configured: $(DL_DIR)/$(CCRYPT_SOURCE) $(CCRYPT_PATCHES) make/ccrypt.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CCRYPT_DIR) $(@D)
	$(CCRYPT_UNZIP) $(DL_DIR)/$(CCRYPT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CCRYPT_PATCHES)" ; \
		then cat $(CCRYPT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(CCRYPT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CCRYPT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CCRYPT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CCRYPT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CCRYPT_LDFLAGS)" \
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

ccrypt-unpack: $(CCRYPT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CCRYPT_BUILD_DIR)/.built: $(CCRYPT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ccrypt: $(CCRYPT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CCRYPT_BUILD_DIR)/.staged: $(CCRYPT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ccrypt-stage: $(CCRYPT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ccrypt
#
$(CCRYPT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ccrypt" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CCRYPT_PRIORITY)" >>$@
	@echo "Section: $(CCRYPT_SECTION)" >>$@
	@echo "Version: $(CCRYPT_VERSION)-$(CCRYPT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CCRYPT_MAINTAINER)" >>$@
	@echo "Source: $(CCRYPT_SITE)/$(CCRYPT_SOURCE)" >>$@
	@echo "Description: $(CCRYPT_DESCRIPTION)" >>$@
	@echo "Depends: $(CCRYPT_DEPENDS)" >>$@
	@echo "Suggests: $(CCRYPT_SUGGESTS)" >>$@
	@echo "Conflicts: $(CCRYPT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/ccrypt/...
# Documentation files should be installed in $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/doc/ccrypt/...
# Daemon startup scripts should be installed in $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ccrypt
#
# You may need to patch your application to make it use these locations.
#
$(CCRYPT_IPK): $(CCRYPT_BUILD_DIR)/.built
	rm -rf $(CCRYPT_IPK_DIR) $(BUILD_DIR)/ccrypt_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CCRYPT_BUILD_DIR) DESTDIR=$(CCRYPT_IPK_DIR) install-strip
	$(INSTALL) -d $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/share/doc/ccrypt
	$(INSTALL) $(CCRYPT_BUILD_DIR)/[ACNR]* $(CCRYPT_IPK_DIR)$(TARGET_PREFIX)/share/doc/ccrypt
	$(MAKE) $(CCRYPT_IPK_DIR)/CONTROL/control
	echo $(CCRYPT_CONFFILES) | sed -e 's/ /\n/g' > $(CCRYPT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CCRYPT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ccrypt-ipk: $(CCRYPT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ccrypt-clean:
	rm -f $(CCRYPT_BUILD_DIR)/.built
	-$(MAKE) -C $(CCRYPT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ccrypt-dirclean:
	rm -rf $(BUILD_DIR)/$(CCRYPT_DIR) $(CCRYPT_BUILD_DIR) $(CCRYPT_IPK_DIR) $(CCRYPT_IPK)
#
#
# Some sanity check for the package.
#
ccrypt-check: $(CCRYPT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
