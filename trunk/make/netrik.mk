###########################################################
#
# netrik
#
###########################################################
#
# NETRIK_VERSION, NETRIK_SITE and NETRIK_SOURCE define
# the upstream location of the source code for the package.
# NETRIK_DIR is the directory which is created when the source
# archive is unpacked.
# NETRIK_UNZIP is the command used to unzip the source.
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
NETRIK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/netrik
NETRIK_VERSION=1.16
NETRIK_SOURCE=netrik-$(NETRIK_VERSION).tar.gz
NETRIK_DIR=netrik-$(NETRIK_VERSION)
NETRIK_UNZIP=zcat
NETRIK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NETRIK_DESCRIPTION=Netrik is an advanced text mode WWW browser.
NETRIK_SECTION=web
NETRIK_PRIORITY=optional
NETRIK_DEPENDS=ncurses, readline
NETRIK_SUGGESTS=
NETRIK_CONFLICTS=

#
# NETRIK_IPK_VERSION should be incremented when the ipk changes.
#
NETRIK_IPK_VERSION=1

#
# NETRIK_CONFFILES should be a list of user-editable files
#NETRIK_CONFFILES=/opt/etc/netrik.conf /opt/etc/init.d/SXXnetrik

#
# NETRIK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NETRIK_PATCHES=$(NETRIK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETRIK_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
NETRIK_LDFLAGS=

#
# NETRIK_BUILD_DIR is the directory in which the build is done.
# NETRIK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETRIK_IPK_DIR is the directory in which the ipk is built.
# NETRIK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETRIK_BUILD_DIR=$(BUILD_DIR)/netrik
NETRIK_SOURCE_DIR=$(SOURCE_DIR)/netrik
NETRIK_IPK_DIR=$(BUILD_DIR)/netrik-$(NETRIK_VERSION)-ipk
NETRIK_IPK=$(BUILD_DIR)/netrik_$(NETRIK_VERSION)-$(NETRIK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: netrik-source netrik-unpack netrik netrik-stage netrik-ipk netrik-clean netrik-dirclean netrik-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETRIK_SOURCE):
	$(WGET) -P $(@D) $(NETRIK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netrik-source: $(DL_DIR)/$(NETRIK_SOURCE) $(NETRIK_PATCHES)

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
$(NETRIK_BUILD_DIR)/.configured: $(DL_DIR)/$(NETRIK_SOURCE) $(NETRIK_PATCHES) make/netrik.mk
	$(MAKE) ncurses-stage readline-stage
	rm -rf $(BUILD_DIR)/$(NETRIK_DIR) $(@D)
	$(NETRIK_UNZIP) $(DL_DIR)/$(NETRIK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NETRIK_PATCHES)" ; \
		then cat $(NETRIK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NETRIK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NETRIK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NETRIK_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETRIK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETRIK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

netrik-unpack: $(NETRIK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETRIK_BUILD_DIR)/.built: $(NETRIK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
netrik: $(NETRIK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETRIK_BUILD_DIR)/.staged: $(NETRIK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

netrik-stage: $(NETRIK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netrik
#
$(NETRIK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: netrik" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETRIK_PRIORITY)" >>$@
	@echo "Section: $(NETRIK_SECTION)" >>$@
	@echo "Version: $(NETRIK_VERSION)-$(NETRIK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETRIK_MAINTAINER)" >>$@
	@echo "Source: $(NETRIK_SITE)/$(NETRIK_SOURCE)" >>$@
	@echo "Description: $(NETRIK_DESCRIPTION)" >>$@
	@echo "Depends: $(NETRIK_DEPENDS)" >>$@
	@echo "Suggests: $(NETRIK_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETRIK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETRIK_IPK_DIR)/opt/sbin or $(NETRIK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETRIK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETRIK_IPK_DIR)/opt/etc/netrik/...
# Documentation files should be installed in $(NETRIK_IPK_DIR)/opt/doc/netrik/...
# Daemon startup scripts should be installed in $(NETRIK_IPK_DIR)/opt/etc/init.d/S??netrik
#
# You may need to patch your application to make it use these locations.
#
$(NETRIK_IPK): $(NETRIK_BUILD_DIR)/.built
	rm -rf $(NETRIK_IPK_DIR) $(BUILD_DIR)/netrik_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NETRIK_BUILD_DIR) DESTDIR=$(NETRIK_IPK_DIR) install-strip
#	install -d $(NETRIK_IPK_DIR)/opt/etc/
#	install -m 644 $(NETRIK_SOURCE_DIR)/netrik.conf $(NETRIK_IPK_DIR)/opt/etc/netrik.conf
#	install -d $(NETRIK_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NETRIK_SOURCE_DIR)/rc.netrik $(NETRIK_IPK_DIR)/opt/etc/init.d/SXXnetrik
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETRIK_IPK_DIR)/opt/etc/init.d/SXXnetrik
	$(MAKE) $(NETRIK_IPK_DIR)/CONTROL/control
#	install -m 755 $(NETRIK_SOURCE_DIR)/postinst $(NETRIK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETRIK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NETRIK_SOURCE_DIR)/prerm $(NETRIK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NETRIK_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NETRIK_IPK_DIR)/CONTROL/postinst $(NETRIK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NETRIK_CONFFILES) | sed -e 's/ /\n/g' > $(NETRIK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETRIK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netrik-ipk: $(NETRIK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netrik-clean:
	rm -f $(NETRIK_BUILD_DIR)/.built
	-$(MAKE) -C $(NETRIK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netrik-dirclean:
	rm -rf $(BUILD_DIR)/$(NETRIK_DIR) $(NETRIK_BUILD_DIR) $(NETRIK_IPK_DIR) $(NETRIK_IPK)
#
#
# Some sanity check for the package.
#
netrik-check: $(NETRIK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NETRIK_IPK)
