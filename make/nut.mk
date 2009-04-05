###########################################################
#
# nut
#
###########################################################
#
# NUT_VERSION, NUT_SITE and NUT_SOURCE define
# the upstream location of the source code for the package.
# NUT_DIR is the directory which is created when the source
# archive is unpacked.
# NUT_UNZIP is the command used to unzip the source.
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
NUT_SITE=http://eu1.networkupstools.org/source/2.4
NUT_VERSION=2.4.1
NUT_SOURCE=nut-$(NUT_VERSION).tar.gz
NUT_DIR=nut-$(NUT_VERSION)
NUT_UNZIP=zcat
NUT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NUT_DESCRIPTION=Network UPS tools.
NUT_SECTION=admin
NUT_PRIORITY=optional
NUT_DEPENDS=libusb, openssl, neon, libgd
ifneq (, $(filter libiconv, $(PACKAGES)))
NUT_DEPENDS+=, libiconv
endif
ifneq (, $(filter net-snmp, $(PACKAGES)))
NUT_DEPENDS+=, net-snmp
endif
NUT_SUGGESTS=
NUT_CONFLICTS=

#
# NUT_IPK_VERSION should be incremented when the ipk changes.
#
NUT_IPK_VERSION=1

#
# NUT_CONFFILES should be a list of user-editable files
#NUT_CONFFILES=/opt/etc/nut.conf /opt/etc/init.d/SXXnut

#
# NUT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NUT_PATCHES=$(NUT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NUT_CPPFLAGS=
NUT_LDFLAGS=$(strip $(if $(filter uclibc, $(LIBC_STYLE)), -lm, ))
NUT_GD_LIBS=-L$(STAGING_LIB_DIR) -lgd -lfreetype -lfontconfig -ljpeg -lpng12 -lz -lexpat $(if $(filter libiconv, $(PACKAGES)), -liconv,)

#
# NUT_BUILD_DIR is the directory in which the build is done.
# NUT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NUT_IPK_DIR is the directory in which the ipk is built.
# NUT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NUT_BUILD_DIR=$(BUILD_DIR)/nut
NUT_SOURCE_DIR=$(SOURCE_DIR)/nut
NUT_IPK_DIR=$(BUILD_DIR)/nut-$(NUT_VERSION)-ipk
NUT_IPK=$(BUILD_DIR)/nut_$(NUT_VERSION)-$(NUT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nut-source nut-unpack nut nut-stage nut-ipk nut-clean nut-dirclean nut-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NUT_SOURCE):
	$(WGET) -P $(@D) $(NUT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nut-source: $(DL_DIR)/$(NUT_SOURCE) $(NUT_PATCHES)

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
$(NUT_BUILD_DIR)/.configured: $(DL_DIR)/$(NUT_SOURCE) $(NUT_PATCHES) make/nut.mk
	$(MAKE) libusb-stage openssl-stage neon-stage libgd-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifneq (, $(filter net-snmp, $(PACKAGES)))
	$(MAKE) net-snmp-stage
endif
	rm -rf $(BUILD_DIR)/$(NUT_DIR) $(@D)
	$(NUT_UNZIP) $(DL_DIR)/$(NUT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NUT_PATCHES)" ; \
		then cat $(NUT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NUT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NUT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NUT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NUT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NUT_LDFLAGS)" \
		PATH="$(STAGING_PREFIX)/bin:$$PATH" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-hotplug-dir=/opt/etc/hotplug \
		--with-udev-dir=/opt/etc/udev \
		--with-htmlpath=/opt/share/nut/html \
		--with-statepath=/opt/var/state/ups \
		--with-pidpath=/opt/var/run \
		--with-cgi \
		--with-gd-includes=-I$(STAGING_INCLUDE_DIR) \
		--with-gd-libs="$(NUT_GD_LIBS)" \
		--disable-nls \
		--disable-static \
	)
	sed -i -e 's| -I/opt/include||g' $(@D)/*/Makefile
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nut-unpack: $(NUT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NUT_BUILD_DIR)/.built: $(NUT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nut: $(NUT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NUT_BUILD_DIR)/.staged: $(NUT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nut-stage: $(NUT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nut
#
$(NUT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nut" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NUT_PRIORITY)" >>$@
	@echo "Section: $(NUT_SECTION)" >>$@
	@echo "Version: $(NUT_VERSION)-$(NUT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NUT_MAINTAINER)" >>$@
	@echo "Source: $(NUT_SITE)/$(NUT_SOURCE)" >>$@
	@echo "Description: $(NUT_DESCRIPTION)" >>$@
	@echo "Depends: $(NUT_DEPENDS)" >>$@
	@echo "Suggests: $(NUT_SUGGESTS)" >>$@
	@echo "Conflicts: $(NUT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NUT_IPK_DIR)/opt/sbin or $(NUT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NUT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NUT_IPK_DIR)/opt/etc/nut/...
# Documentation files should be installed in $(NUT_IPK_DIR)/opt/doc/nut/...
# Daemon startup scripts should be installed in $(NUT_IPK_DIR)/opt/etc/init.d/S??nut
#
# You may need to patch your application to make it use these locations.
#
$(NUT_IPK): $(NUT_BUILD_DIR)/.built
	rm -rf $(NUT_IPK_DIR) $(BUILD_DIR)/nut_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NUT_BUILD_DIR) install-strip \
		DESTDIR=$(NUT_IPK_DIR) transform=''
#	install -d $(NUT_IPK_DIR)/opt/etc/
#	install -m 644 $(NUT_SOURCE_DIR)/nut.conf $(NUT_IPK_DIR)/opt/etc/nut.conf
#	install -d $(NUT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NUT_SOURCE_DIR)/rc.nut $(NUT_IPK_DIR)/opt/etc/init.d/SXXnut
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUT_IPK_DIR)/opt/etc/init.d/SXXnut
	$(MAKE) $(NUT_IPK_DIR)/CONTROL/control
#	install -m 755 $(NUT_SOURCE_DIR)/postinst $(NUT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NUT_SOURCE_DIR)/prerm $(NUT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NUT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NUT_IPK_DIR)/CONTROL/postinst $(NUT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(NUT_CONFFILES) | sed -e 's/ /\n/g' > $(NUT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NUT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nut-ipk: $(NUT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nut-clean:
	rm -f $(NUT_BUILD_DIR)/.built
	-$(MAKE) -C $(NUT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nut-dirclean:
	rm -rf $(BUILD_DIR)/$(NUT_DIR) $(NUT_BUILD_DIR) $(NUT_IPK_DIR) $(NUT_IPK)
#
#
# Some sanity check for the package.
#
nut-check: $(NUT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NUT_IPK)
