###########################################################
#
# hplip
#
###########################################################
#
# HPLIP_VERSION, HPLIP_SITE and HPLIP_SOURCE define
# the upstream location of the source code for the package.
# HPLIP_DIR is the directory which is created when the source
# archive is unpacked.
# HPLIP_UNZIP is the command used to unzip the source.
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
HPLIP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/hplip
HPLIP_VERSION=2.8.7
HPLIP_SOURCE=hplip-$(HPLIP_VERSION).tar.gz
HPLIP_DIR=hplip-$(HPLIP_VERSION)
HPLIP_UNZIP=zcat
HPLIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HPLIP_DESCRIPTION=HP Linux Imaging and Printing
HPLIP_SECTION=misc
HPLIP_PRIORITY=optional
HPLIP_DEPENDS=sane-backends, python25, libstdc++
HPLIP_SUGGESTS=cups, dbus
HPLIP_CONFLICTS=

#
# HPLIP_IPK_VERSION should be incremented when the ipk changes.
#
HPLIP_IPK_VERSION=1

#
# HPLIP_CONFFILES should be a list of user-editable files
HPLIP_CONFFILES=/opt/etc/hp/hplip.conf \
		/opt/etc/sane.d/dll.conf \
		opt/etc/udev/rules.d/55-hpmud.rules
#/opt/etc/init.d/SXXhplip

#
# HPLIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#HPLIP_PATCHES=$(HPLIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HPLIP_CPPFLAGS=
HPLIP_LDFLAGS=

ifeq (, $(filter net-snmp, $(PACKAGES)))
HPLIP_CONFIG_ARGS += --disable-network-build
endif

#
# HPLIP_BUILD_DIR is the directory in which the build is done.
# HPLIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# HPLIP_IPK_DIR is the directory in which the ipk is built.
# HPLIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
HPLIP_BUILD_DIR=$(BUILD_DIR)/hplip
HPLIP_SOURCE_DIR=$(SOURCE_DIR)/hplip
HPLIP_IPK_DIR=$(BUILD_DIR)/hplip-$(HPLIP_VERSION)-ipk
HPLIP_IPK=$(BUILD_DIR)/hplip_$(HPLIP_VERSION)-$(HPLIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: hplip-source hplip-unpack hplip hplip-stage hplip-ipk hplip-clean hplip-dirclean hplip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(HPLIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(HPLIP_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
hplip-source: $(DL_DIR)/$(HPLIP_SOURCE) $(HPLIP_PATCHES)

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
$(HPLIP_BUILD_DIR)/.configured: $(DL_DIR)/$(HPLIP_SOURCE) $(HPLIP_PATCHES) make/hplip.mk
	$(MAKE) cups-stage dbus-stage python25-stage sane-backends-stage
ifneq (, $(filter net-snmp, $(PACKAGES)))
	$(MAKE) net-snmp-stage
endif
	rm -rf $(BUILD_DIR)/$(HPLIP_DIR) $(@D)
	$(HPLIP_UNZIP) $(DL_DIR)/$(HPLIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HPLIP_PATCHES)" ; \
		then cat $(HPLIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(HPLIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(HPLIP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HPLIP_DIR) $(@D) ; \
	fi
	sed -i -e 's|/etc/|/opt&|' $(@D)/Makefile.am ; \
	autoreconf -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HPLIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HPLIP_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.5 \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--disable-nls \
		--disable-static \
		$(HPLIP_CONFIG_ARGS) \
		--disable-dependency-tracking \
		--with-cupsbackenddir=/opt/lib/cups/backend \
		--with-icondir=/opt/share/applications \
		--with-systraydir=/opt/etc/xdg/autostart \
		--with-cupsfilterdir=/opt/lib/cups/filter \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

hplip-unpack: $(HPLIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(HPLIP_BUILD_DIR)/.built: $(HPLIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
hplip: $(HPLIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(HPLIP_BUILD_DIR)/.staged: $(HPLIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

hplip-stage: $(HPLIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hplip
#
$(HPLIP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: hplip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(HPLIP_PRIORITY)" >>$@
	@echo "Section: $(HPLIP_SECTION)" >>$@
	@echo "Version: $(HPLIP_VERSION)-$(HPLIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(HPLIP_MAINTAINER)" >>$@
	@echo "Source: $(HPLIP_SITE)/$(HPLIP_SOURCE)" >>$@
	@echo "Description: $(HPLIP_DESCRIPTION)" >>$@
	@echo "Depends: $(HPLIP_DEPENDS)" >>$@
	@echo "Suggests: $(HPLIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(HPLIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(HPLIP_IPK_DIR)/opt/sbin or $(HPLIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HPLIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(HPLIP_IPK_DIR)/opt/etc/hplip/...
# Documentation files should be installed in $(HPLIP_IPK_DIR)/opt/doc/hplip/...
# Daemon startup scripts should be installed in $(HPLIP_IPK_DIR)/opt/etc/init.d/S??hplip
#
# You may need to patch your application to make it use these locations.
#
$(HPLIP_IPK): $(HPLIP_BUILD_DIR)/.built
	rm -rf $(HPLIP_IPK_DIR) $(BUILD_DIR)/hplip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HPLIP_BUILD_DIR) DESTDIR=$(HPLIP_IPK_DIR) install-strip
#	install -d $(HPLIP_IPK_DIR)/opt/etc/
#	install -m 644 $(HPLIP_SOURCE_DIR)/hplip.conf $(HPLIP_IPK_DIR)/opt/etc/hplip.conf
#	install -d $(HPLIP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(HPLIP_SOURCE_DIR)/rc.hplip $(HPLIP_IPK_DIR)/opt/etc/init.d/SXXhplip
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)/opt/etc/init.d/SXXhplip
	$(MAKE) $(HPLIP_IPK_DIR)/CONTROL/control
#	install -m 755 $(HPLIP_SOURCE_DIR)/postinst $(HPLIP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(HPLIP_SOURCE_DIR)/prerm $(HPLIP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HPLIP_IPK_DIR)/CONTROL/postinst $(HPLIP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HPLIP_CONFFILES) | sed -e 's/ /\n/g' > $(HPLIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HPLIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
hplip-ipk: $(HPLIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
hplip-clean:
	rm -f $(HPLIP_BUILD_DIR)/.built
	-$(MAKE) -C $(HPLIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
hplip-dirclean:
	rm -rf $(BUILD_DIR)/$(HPLIP_DIR) $(HPLIP_BUILD_DIR) $(HPLIP_IPK_DIR) $(HPLIP_IPK)
#
#
# Some sanity check for the package.
#
hplip-check: $(HPLIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(HPLIP_IPK)
