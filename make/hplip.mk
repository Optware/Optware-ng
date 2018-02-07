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
HPLIP_VERSION=3.17.11
HPLIP_SOURCE=hplip-$(HPLIP_VERSION).tar.gz
HPLIP_DIR=hplip-$(HPLIP_VERSION)
HPLIP_UNZIP=zcat
HPLIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
HPLIP_DESCRIPTION=HP Linux Imaging and Printing
HPLIP_SECTION=misc
HPLIP_PRIORITY=optional
HPLIP_DEPENDS=sane-backends, python27, py27-dbus-python, libstdc++, libusb1, libcups, libcupsimage, libjbigkit, libidn
ifneq (, $(filter net-snmp, $(PACKAGES)))
HPLIP_DEPENDS +=, net-snmp
endif
HPLIP_SUGGESTS=cups
HPLIP_CONFLICTS=

#
# HPLIP_IPK_VERSION should be incremented when the ipk changes.
#
HPLIP_IPK_VERSION=4

#
# HPLIP_CONFFILES should be a list of user-editable files
HPLIP_CONFFILES=$(TARGET_PREFIX)/etc/hp/hplip.conf \
		$(TARGET_PREFIX)/etc/sane.d/dll.conf \
		$(TARGET_PREFIX)/etc/udev/rules.d/56-hpmud.rules
#$(TARGET_PREFIX)/etc/init.d/SXXhplip

#
# HPLIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
HPLIP_PATCHES=\
$(HPLIP_SOURCE_DIR)/configure.in.patch \
$(HPLIP_SOURCE_DIR)/state-dir.patch \
$(HPLIP_SOURCE_DIR)/cross-compile.patch \
$(HPLIP_SOURCE_DIR)/libhpdiscovery.patch \
$(HPLIP_SOURCE_DIR)/force_PYTHONINCLUDEDIR.patch \
$(HPLIP_SOURCE_DIR)/boolean.patch \
$(HPLIP_SOURCE_DIR)/models.dat-location.patch \
$(HPLIP_SOURCE_DIR)/optware-paths.patch \
$(HPLIP_SOURCE_DIR)/magic.py.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
HPLIP_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libusb-1.0 -I$(STAGING_INCLUDE_DIR)/python2.7
HPLIP_LDFLAGS=-lz -ljpeg -lusb-1.0 -lcups -lpng -ltiff

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
	$(WGET) -P $(@D) $(HPLIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

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
	$(MAKE) cups-stage dbus-stage python27-stage python27-host-stage \
		sane-backends-stage libusb1-stage libjbigkit-stage libidn-stage
ifneq (, $(filter net-snmp, $(PACKAGES)))
	$(MAKE) net-snmp-stage
endif
	rm -rf $(BUILD_DIR)/$(HPLIP_DIR) $(@D)
	$(HPLIP_UNZIP) $(DL_DIR)/$(HPLIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(HPLIP_PATCHES)" ; \
		then cat $(HPLIP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(HPLIP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(HPLIP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(HPLIP_DIR) $(@D) ; \
	fi

	cd $(@D); touch INSTALL NEWS README AUTHORS ChangeLog
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(HPLIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(HPLIP_LDFLAGS)" \
		PYTHON=$(HOST_STAGING_PREFIX)/bin/python2.7 \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		PYTHONINCLUDEDIR=$(STAGING_INCLUDE_DIR)/python2.7 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--sysconfdir=$(TARGET_PREFIX)/etc \
		--with-mimedir=$(TARGET_PREFIX)/etc \
		--disable-nls \
		--disable-static \
		$(HPLIP_CONFIG_ARGS) \
		--enable-scan-build \
		--enable-fax-build \
		--disable-dependency-tracking \
		--with-cupsbackenddir=$(TARGET_PREFIX)/lib/cups/backend \
		--with-icondir=$(TARGET_PREFIX)/share/applications \
		--with-systraydir=$(TARGET_PREFIX)/etc/xdg/autostart \
		--with-cupsfilterdir=$(TARGET_PREFIX)/lib/cups/filter \
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
	### use $(TARGET_PREFIX)/bin/python2.7
	sed -i -e 's|^#!.*|#!$(TARGET_PREFIX)/bin/python2.7|' `find $(@D) -type f -name "*.py"` \
		$(@D)/fax/filters/pstotiff $(@D)/prnt/filters/hpps
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
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install -j1
	touch $@

hplip-stage: $(HPLIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/hplip
#
$(HPLIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
# Binaries should be installed into $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/hplip/...
# Documentation files should be installed in $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/doc/hplip/...
# Daemon startup scripts should be installed in $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??hplip
#
# You may need to patch your application to make it use these locations.
#
$(HPLIP_IPK): $(HPLIP_BUILD_DIR)/.built
	rm -rf $(HPLIP_IPK_DIR) $(BUILD_DIR)/hplip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(HPLIP_BUILD_DIR) DESTDIR=$(HPLIP_IPK_DIR) install-strip -j1
	rm -rf $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/lib/*.la $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/lib/*/*.la
	chmod 755 $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/lib/cups/*
#	$(INSTALL) -d $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/
	mv -f $(HPLIP_IPK_DIR)/etc/* $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/
	rm -rf $(HPLIP_IPK_DIR)/etc
#	$(INSTALL) -m 644 $(HPLIP_SOURCE_DIR)/hplip.conf $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/hplip.conf
#	$(INSTALL) -d $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(HPLIP_SOURCE_DIR)/rc.hplip $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXhplip
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXhplip
	$(MAKE) $(HPLIP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(HPLIP_SOURCE_DIR)/postinst $(HPLIP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(HPLIP_SOURCE_DIR)/prerm $(HPLIP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(HPLIP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(HPLIP_IPK_DIR)/CONTROL/postinst $(HPLIP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(HPLIP_CONFFILES) | sed -e 's/ /\n/g' > $(HPLIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(HPLIP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(HPLIP_IPK_DIR)

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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
