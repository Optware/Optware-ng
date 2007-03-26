###########################################################
#
# keychain
#
###########################################################
#
# KEYCHAIN_VERSION, KEYCHAIN_SITE and KEYCHAIN_SOURCE define
# the upstream location of the source code for the package.
# KEYCHAIN_DIR is the directory which is created when the source
# archive is unpacked.
# KEYCHAIN_UNZIP is the command used to unzip the source.
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
KEYCHAIN_SITE=http://dev.gentoo.org/~agriffis/keychain
KEYCHAIN_VERSION=2.6.8
KEYCHAIN_SOURCE=keychain-$(KEYCHAIN_VERSION).tar.bz2
KEYCHAIN_DIR=keychain-$(KEYCHAIN_VERSION)
KEYCHAIN_UNZIP=bzcat
KEYCHAIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
KEYCHAIN_DESCRIPTION=Key manager for OpenSSH.
KEYCHAIN_SECTION=misc
KEYCHAIN_PRIORITY=optional
KEYCHAIN_DEPENDS=openssh
KEYCHAIN_SUGGESTS=
KEYCHAIN_CONFLICTS=

#
# KEYCHAIN_IPK_VERSION should be incremented when the ipk changes.
#
KEYCHAIN_IPK_VERSION=1

#
# KEYCHAIN_CONFFILES should be a list of user-editable files
#KEYCHAIN_CONFFILES=/opt/etc/keychain.conf /opt/etc/init.d/SXXkeychain

#
# KEYCHAIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#KEYCHAIN_PATCHES=$(KEYCHAIN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KEYCHAIN_CPPFLAGS=
KEYCHAIN_LDFLAGS=

#
# KEYCHAIN_BUILD_DIR is the directory in which the build is done.
# KEYCHAIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KEYCHAIN_IPK_DIR is the directory in which the ipk is built.
# KEYCHAIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KEYCHAIN_BUILD_DIR=$(BUILD_DIR)/keychain
KEYCHAIN_SOURCE_DIR=$(SOURCE_DIR)/keychain
KEYCHAIN_IPK_DIR=$(BUILD_DIR)/keychain-$(KEYCHAIN_VERSION)-ipk
KEYCHAIN_IPK=$(BUILD_DIR)/keychain_$(KEYCHAIN_VERSION)-$(KEYCHAIN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: keychain-source keychain-unpack keychain keychain-stage keychain-ipk keychain-clean keychain-dirclean keychain-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KEYCHAIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(KEYCHAIN_SITE)/$(KEYCHAIN_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(KEYCHAIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
keychain-source: $(DL_DIR)/$(KEYCHAIN_SOURCE) $(KEYCHAIN_PATCHES)

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
$(KEYCHAIN_BUILD_DIR)/.configured: $(DL_DIR)/$(KEYCHAIN_SOURCE) $(KEYCHAIN_PATCHES) make/keychain.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(KEYCHAIN_DIR) $(KEYCHAIN_BUILD_DIR)
	$(KEYCHAIN_UNZIP) $(DL_DIR)/$(KEYCHAIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(KEYCHAIN_PATCHES)" ; \
		then cat $(KEYCHAIN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(KEYCHAIN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(KEYCHAIN_DIR)" != "$(KEYCHAIN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KEYCHAIN_DIR) $(KEYCHAIN_BUILD_DIR) ; \
	fi
	sed -i -e 's|PATH="|PATH="/opt/bin:|' $(KEYCHAIN_BUILD_DIR)/keychain
#	(cd $(KEYCHAIN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KEYCHAIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KEYCHAIN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(KEYCHAIN_BUILD_DIR)/libtool
	touch $@

keychain-unpack: $(KEYCHAIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KEYCHAIN_BUILD_DIR)/.built: $(KEYCHAIN_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(KEYCHAIN_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
keychain: $(KEYCHAIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KEYCHAIN_BUILD_DIR)/.staged: $(KEYCHAIN_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(KEYCHAIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

keychain-stage: $(KEYCHAIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/keychain
#
$(KEYCHAIN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: keychain" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KEYCHAIN_PRIORITY)" >>$@
	@echo "Section: $(KEYCHAIN_SECTION)" >>$@
	@echo "Version: $(KEYCHAIN_VERSION)-$(KEYCHAIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KEYCHAIN_MAINTAINER)" >>$@
	@echo "Source: $(KEYCHAIN_SITE)/$(KEYCHAIN_SOURCE)" >>$@
	@echo "Description: $(KEYCHAIN_DESCRIPTION)" >>$@
	@echo "Depends: $(KEYCHAIN_DEPENDS)" >>$@
	@echo "Suggests: $(KEYCHAIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(KEYCHAIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(KEYCHAIN_IPK_DIR)/opt/sbin or $(KEYCHAIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KEYCHAIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(KEYCHAIN_IPK_DIR)/opt/etc/keychain/...
# Documentation files should be installed in $(KEYCHAIN_IPK_DIR)/opt/doc/keychain/...
# Daemon startup scripts should be installed in $(KEYCHAIN_IPK_DIR)/opt/etc/init.d/S??keychain
#
# You may need to patch your application to make it use these locations.
#
$(KEYCHAIN_IPK): $(KEYCHAIN_BUILD_DIR)/.built
	rm -rf $(KEYCHAIN_IPK_DIR) $(BUILD_DIR)/keychain_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(KEYCHAIN_BUILD_DIR) DESTDIR=$(KEYCHAIN_IPK_DIR) install-strip
	install -d $(KEYCHAIN_IPK_DIR)/opt/bin/
	install $(KEYCHAIN_BUILD_DIR)/keychain $(KEYCHAIN_IPK_DIR)/opt/bin/
	install -d $(KEYCHAIN_IPK_DIR)/opt/man/man1/
	install $(KEYCHAIN_BUILD_DIR)/keychain.1 $(KEYCHAIN_IPK_DIR)/opt/man/man1/
	$(MAKE) $(KEYCHAIN_IPK_DIR)/CONTROL/control
	echo $(KEYCHAIN_CONFFILES) | sed -e 's/ /\n/g' > $(KEYCHAIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KEYCHAIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
keychain-ipk: $(KEYCHAIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
keychain-clean:
	rm -f $(KEYCHAIN_BUILD_DIR)/.built
	-$(MAKE) -C $(KEYCHAIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
keychain-dirclean:
	rm -rf $(BUILD_DIR)/$(KEYCHAIN_DIR) $(KEYCHAIN_BUILD_DIR) $(KEYCHAIN_IPK_DIR) $(KEYCHAIN_IPK)
#
#
# Some sanity check for the package.
#
keychain-check: $(KEYCHAIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(KEYCHAIN_IPK)
