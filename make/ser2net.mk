###########################################################
#
# ser2net
#
###########################################################
#
# SER2NET_VERSION, SER2NET_SITE and SER2NET_SOURCE define
# the upstream location of the source code for the package.
# SER2NET_DIR is the directory which is created when the source
# archive is unpacked.
# SER2NET_UNZIP is the command used to unzip the source.
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
SER2NET_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ser2net
SER2NET_VERSION=2.5
SER2NET_SOURCE=ser2net-$(SER2NET_VERSION).tar.gz
SER2NET_DIR=ser2net-$(SER2NET_VERSION)
SER2NET_UNZIP=zcat
SER2NET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SER2NET_DESCRIPTION=ser2net is a serial port to network proxy
SER2NET_SECTION=utils
SER2NET_PRIORITY=optional
SER2NET_DEPENDS=
SER2NET_SUGGESTS=
SER2NET_CONFLICTS=

#
# SER2NET_IPK_VERSION should be incremented when the ipk changes.
#
SER2NET_IPK_VERSION=1

#
# SER2NET_CONFFILES should be a list of user-editable files
SER2NET_CONFFILES=/opt/etc/ser2net.conf /opt/etc/init.d/S95ser2net

#
# SER2NET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SER2NET_PATCHES=$(SER2NET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SER2NET_CPPFLAGS=
SER2NET_LDFLAGS=

#
# SER2NET_BUILD_DIR is the directory in which the build is done.
# SER2NET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SER2NET_IPK_DIR is the directory in which the ipk is built.
# SER2NET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SER2NET_BUILD_DIR=$(BUILD_DIR)/ser2net
SER2NET_SOURCE_DIR=$(SOURCE_DIR)/ser2net
SER2NET_IPK_DIR=$(BUILD_DIR)/ser2net-$(SER2NET_VERSION)-ipk
SER2NET_IPK=$(BUILD_DIR)/ser2net_$(SER2NET_VERSION)-$(SER2NET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ser2net-source ser2net-unpack ser2net ser2net-stage ser2net-ipk ser2net-clean ser2net-dirclean ser2net-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SER2NET_SOURCE):
	$(WGET) -P $(DL_DIR) $(SER2NET_SITE)/$(SER2NET_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SER2NET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ser2net-source: $(DL_DIR)/$(SER2NET_SOURCE) $(SER2NET_PATCHES)

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
$(SER2NET_BUILD_DIR)/.configured: $(DL_DIR)/$(SER2NET_SOURCE) $(SER2NET_PATCHES) make/ser2net.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SER2NET_DIR) $(@D)
	$(SER2NET_UNZIP) $(DL_DIR)/$(SER2NET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SER2NET_PATCHES)" ; \
		then cat $(SER2NET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SER2NET_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SER2NET_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SER2NET_DIR) $(@D) ; \
	fi
	sed -i -e 's/\/etc\/ser2net\.conf/\/opt\/etc\/ser2net.conf/g' $(SER2NET_BUILD_DIR)/ser2net.8 $(SER2NET_BUILD_DIR)/ser2net.c
	sed -i -e 's/ttyS/usb\/tts\//g' $(SER2NET_BUILD_DIR)/ser2net.conf
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SER2NET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SER2NET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ser2net-unpack: $(SER2NET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SER2NET_BUILD_DIR)/.built: $(SER2NET_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ser2net: $(SER2NET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SER2NET_BUILD_DIR)/.staged: $(SER2NET_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ser2net-stage: $(SER2NET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ser2net
#
$(SER2NET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ser2net" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SER2NET_PRIORITY)" >>$@
	@echo "Section: $(SER2NET_SECTION)" >>$@
	@echo "Version: $(SER2NET_VERSION)-$(SER2NET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SER2NET_MAINTAINER)" >>$@
	@echo "Source: $(SER2NET_SITE)/$(SER2NET_SOURCE)" >>$@
	@echo "Description: $(SER2NET_DESCRIPTION)" >>$@
	@echo "Depends: $(SER2NET_DEPENDS)" >>$@
	@echo "Suggests: $(SER2NET_SUGGESTS)" >>$@
	@echo "Conflicts: $(SER2NET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SER2NET_IPK_DIR)/opt/sbin or $(SER2NET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SER2NET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SER2NET_IPK_DIR)/opt/etc/ser2net/...
# Documentation files should be installed in $(SER2NET_IPK_DIR)/opt/doc/ser2net/...
# Daemon startup scripts should be installed in $(SER2NET_IPK_DIR)/opt/etc/init.d/S??ser2net
#
# You may need to patch your application to make it use these locations.
#
$(SER2NET_IPK): $(SER2NET_BUILD_DIR)/.built
	rm -rf $(SER2NET_IPK_DIR) $(BUILD_DIR)/ser2net_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SER2NET_BUILD_DIR) DESTDIR=$(SER2NET_IPK_DIR) install-am
	$(STRIP_COMMAND) $(SER2NET_IPK_DIR)/opt/sbin/ser2net
	install -d $(SER2NET_IPK_DIR)/opt/etc/
	install -m 644 $(SER2NET_BUILD_DIR)/ser2net.conf $(SER2NET_IPK_DIR)/opt/etc/ser2net.conf
	install -d $(SER2NET_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SER2NET_BUILD_DIR)/ser2net.init $(SER2NET_IPK_DIR)/opt/etc/init.d/S95ser2net
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SER2NET_IPK_DIR)/opt/etc/init.d/SXXser2net
	$(MAKE) $(SER2NET_IPK_DIR)/CONTROL/control
#	install -m 755 $(SER2NET_SOURCE_DIR)/postinst $(SER2NET_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SER2NET_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SER2NET_SOURCE_DIR)/prerm $(SER2NET_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SER2NET_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(SER2NET_IPK_DIR)/CONTROL/postinst $(SER2NET_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(SER2NET_CONFFILES) | sed -e 's/ /\n/g' > $(SER2NET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SER2NET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ser2net-ipk: $(SER2NET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ser2net-clean:
	rm -f $(SER2NET_BUILD_DIR)/.built
	-$(MAKE) -C $(SER2NET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ser2net-dirclean:
	rm -rf $(BUILD_DIR)/$(SER2NET_DIR) $(SER2NET_BUILD_DIR) $(SER2NET_IPK_DIR) $(SER2NET_IPK)
#
#
# Some sanity check for the package.
#
ser2net-check: $(SER2NET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SER2NET_IPK)
