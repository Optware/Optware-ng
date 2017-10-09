###########################################################
#
# mktorrent
#
###########################################################
#
# MKTORRENT_VERSION, MKTORRENT_SITE and MKTORRENT_SOURCE define
# the upstream location of the source code for the package.
# MKTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# MKTORRENT_UNZIP is the command used to unzip the source.
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
MKTORRENT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mktorrent
MKTORRENT_VERSION=1.0
MKTORRENT_SOURCE=mktorrent-$(MKTORRENT_VERSION).tar.gz
MKTORRENT_DIR=mktorrent-$(MKTORRENT_VERSION)
MKTORRENT_UNZIP=zcat
MKTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MKTORRENT_DESCRIPTION=mktorrent is a simple command line utility to create BitTorrent metainfo files.
MKTORRENT_SECTION=net
MKTORRENT_PRIORITY=optional
MKTORRENT_DEPENDS=openssl
MKTORRENT_SUGGESTS=
MKTORRENT_CONFLICTS=

#
# MKTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
MKTORRENT_IPK_VERSION=3

#
# MKTORRENT_CONFFILES should be a list of user-editable files
#MKTORRENT_CONFFILES=$(TARGET_PREFIX)/etc/mktorrent.conf $(TARGET_PREFIX)/etc/init.d/SXXmktorrent

#
# MKTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MKTORRENT_PATCHES=$(MKTORRENT_SOURCE_DIR)/01-allow-no-announce.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MKTORRENT_CPPFLAGS=
MKTORRENT_LDFLAGS=

#
# MKTORRENT_BUILD_DIR is the directory in which the build is done.
# MKTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MKTORRENT_IPK_DIR is the directory in which the ipk is built.
# MKTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MKTORRENT_BUILD_DIR=$(BUILD_DIR)/mktorrent
MKTORRENT_SOURCE_DIR=$(SOURCE_DIR)/mktorrent
MKTORRENT_IPK_DIR=$(BUILD_DIR)/mktorrent-$(MKTORRENT_VERSION)-ipk
MKTORRENT_IPK=$(BUILD_DIR)/mktorrent_$(MKTORRENT_VERSION)-$(MKTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mktorrent-source mktorrent-unpack mktorrent mktorrent-stage mktorrent-ipk mktorrent-clean mktorrent-dirclean mktorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MKTORRENT_SOURCE):
	$(WGET) -P $(@D) $(MKTORRENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mktorrent-source: $(DL_DIR)/$(MKTORRENT_SOURCE) $(MKTORRENT_PATCHES)

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
$(MKTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(MKTORRENT_SOURCE) $(MKTORRENT_PATCHES) make/mktorrent.mk
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(MKTORRENT_DIR) $(@D)
	$(MKTORRENT_UNZIP) $(DL_DIR)/$(MKTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MKTORRENT_PATCHES)" ; \
		then cat $(MKTORRENT_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MKTORRENT_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MKTORRENT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MKTORRENT_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MKTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MKTORRENT_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mktorrent-unpack: $(MKTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MKTORRENT_BUILD_DIR)/.built: $(MKTORRENT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) prefix -C $(@D)
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MKTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MKTORRENT_LDFLAGS)" \
		PREFIX=$(TARGET_PREFIX) USE_PTHREADS=1 USE_OPENSSL=1 USE_LONG_OPTIONS=1 \
		USE_LARGE_FILES=1 DEBUG=0 INSTALL=install \
		-C $(@D)
	touch $@

#
# This is the build convenience target.
#
mktorrent: $(MKTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MKTORRENT_BUILD_DIR)/.staged: $(MKTORRENT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mktorrent-stage: $(MKTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mktorrent
#
$(MKTORRENT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mktorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MKTORRENT_PRIORITY)" >>$@
	@echo "Section: $(MKTORRENT_SECTION)" >>$@
	@echo "Version: $(MKTORRENT_VERSION)-$(MKTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MKTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(MKTORRENT_SITE)/$(MKTORRENT_SOURCE)" >>$@
	@echo "Description: $(MKTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: $(MKTORRENT_DEPENDS)" >>$@
	@echo "Suggests: $(MKTORRENT_SUGGESTS)" >>$@
	@echo "Conflicts: $(MKTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/mktorrent/...
# Documentation files should be installed in $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/doc/mktorrent/...
# Daemon startup scripts should be installed in $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mktorrent
#
# You may need to patch your application to make it use these locations.
#
$(MKTORRENT_IPK): $(MKTORRENT_BUILD_DIR)/.built
	rm -rf $(MKTORRENT_IPK_DIR) $(BUILD_DIR)/mktorrent_*_$(TARGET_ARCH).ipk
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MKTORRENT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MKTORRENT_LDFLAGS)" \
		PREFIX=$(TARGET_PREFIX) USE_PTHREADS=1 USE_OPENSSL=1 USE_LONG_OPTIONS=1 \
		USE_LARGE_FILES=1 DEBUG=0 INSTALL=install \
		-C $(MKTORRENT_BUILD_DIR) DESTDIR=$(MKTORRENT_IPK_DIR) install
	$(STRIP_COMMAND) $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/bin/mktorrent
#	$(INSTALL) -d $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(MKTORRENT_SOURCE_DIR)/mktorrent.conf $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/mktorrent.conf
#	$(INSTALL) -d $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(MKTORRENT_SOURCE_DIR)/rc.mktorrent $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmktorrent
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MKTORRENT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXmktorrent
	$(MAKE) $(MKTORRENT_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(MKTORRENT_SOURCE_DIR)/postinst $(MKTORRENT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MKTORRENT_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(MKTORRENT_SOURCE_DIR)/prerm $(MKTORRENT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MKTORRENT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MKTORRENT_IPK_DIR)/CONTROL/postinst $(MKTORRENT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MKTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(MKTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MKTORRENT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MKTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mktorrent-ipk: $(MKTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mktorrent-clean:
	rm -f $(MKTORRENT_BUILD_DIR)/.built
	-$(MAKE) -C $(MKTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mktorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(MKTORRENT_DIR) $(MKTORRENT_BUILD_DIR) $(MKTORRENT_IPK_DIR) $(MKTORRENT_IPK)
#
#
# Some sanity check for the package.
#
mktorrent-check: $(MKTORRENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
