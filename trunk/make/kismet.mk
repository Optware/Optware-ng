###########################################################
#
# kismet
#
###########################################################
#
# KISMET_VERSION, KISMET_SITE and KISMET_SOURCE define
# the upstream location of the source code for the package.
# KISMET_DIR is the directory which is created when the source
# archive is unpacked.
# KISMET_UNZIP is the command used to unzip the source.
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
KISMET_SITE=http://www.kismetwireless.net/code
KISMET_VERSION=2007-01-R1b
KISMET_SOURCE=kismet-$(KISMET_VERSION).tar.gz
KISMET_DIR=kismet-$(KISMET_VERSION)
KISMET_UNZIP=zcat
KISMET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
KISMET_DESCRIPTION=An 802.11 layer2 wireless network detector, sniffer, and intrusion detection system.
KISMET_SECTION=net
KISMET_PRIORITY=optional
KISMET_DEPENDS=ncurses, libstdc++, libpcap
KISMET_SUGGESTS=
KISMET_CONFLICTS=

#
# KISMET_IPK_VERSION should be incremented when the ipk changes.
#
KISMET_IPK_VERSION=3

#
# KISMET_CONFFILES should be a list of user-editable files
KISMET_CONFFILES=/opt/etc/kismet/ap_manuf \
		/opt/etc/kismet/client_manuf \
		/opt//etc/kismet/kismet.conf \
		/opt/etc/kismet/kismet_ui.conf \
		/opt/etc/kismet/kismet_drone.conf

#/opt/etc/init.d/SXXkismet

#
# KISMET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
KISMET_PATCHES=$(KISMET_SOURCE_DIR)/Makefile.in.patch \
	$(KISMET_SOURCE_DIR)/100-200701r1b_iwfreq_24_kernel.diff

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KISMET_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
ifeq ($(OPTWARE_TARGET), $(filter openwrt-ixp4xx, $(OPTWARE_TARGET)))
KISMET_CPPFLAGS += -fno-builtin-rint
endif
KISMET_LDFLAGS=

#
# KISMET_BUILD_DIR is the directory in which the build is done.
# KISMET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KISMET_IPK_DIR is the directory in which the ipk is built.
# KISMET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KISMET_BUILD_DIR=$(BUILD_DIR)/kismet
KISMET_SOURCE_DIR=$(SOURCE_DIR)/kismet
KISMET_IPK_DIR=$(BUILD_DIR)/kismet-$(KISMET_VERSION)-ipk
KISMET_IPK=$(BUILD_DIR)/kismet_$(KISMET_VERSION)-$(KISMET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: kismet-source kismet-unpack kismet kismet-stage kismet-ipk kismet-clean kismet-dirclean kismet-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KISMET_SOURCE):
	$(WGET) -P $(DL_DIR) $(KISMET_SITE)/$(KISMET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
kismet-source: $(DL_DIR)/$(KISMET_SOURCE) $(KISMET_PATCHES)

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
$(KISMET_BUILD_DIR)/.configured: $(DL_DIR)/$(KISMET_SOURCE) $(KISMET_PATCHES) make/kismet.mk
	$(MAKE) libpcap-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(KISMET_DIR) $(KISMET_BUILD_DIR)
	$(KISMET_UNZIP) $(DL_DIR)/$(KISMET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(KISMET_PATCHES)" ; \
		then cat $(KISMET_PATCHES) | \
		patch -d $(BUILD_DIR)/$(KISMET_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(KISMET_DIR)" != "$(KISMET_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(KISMET_DIR) $(KISMET_BUILD_DIR) ; \
	fi
	(cd $(KISMET_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KISMET_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KISMET_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--sysconfdir=/opt/etc/kismet \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--enable-syspcap=yes \
		--disable-setuid \
		--disable-wsp100 \
		--disable-gpsmap \
	)
#	$(PATCH_LIBTOOL) $(KISMET_BUILD_DIR)/libtool
	touch $(KISMET_BUILD_DIR)/.configured

kismet-unpack: $(KISMET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KISMET_BUILD_DIR)/.built: $(KISMET_BUILD_DIR)/.configured
	rm -f $(KISMET_BUILD_DIR)/.built
	$(MAKE) -C $(KISMET_BUILD_DIR) LIBS=-lm
	touch $(KISMET_BUILD_DIR)/.built

#
# This is the build convenience target.
#
kismet: $(KISMET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KISMET_BUILD_DIR)/.staged: $(KISMET_BUILD_DIR)/.built
	rm -f $(KISMET_BUILD_DIR)/.staged
	$(MAKE) -C $(KISMET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(KISMET_BUILD_DIR)/.staged

kismet-stage: $(KISMET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/kismet
#
$(KISMET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: kismet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KISMET_PRIORITY)" >>$@
	@echo "Section: $(KISMET_SECTION)" >>$@
	@echo "Version: $(KISMET_VERSION)-$(KISMET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KISMET_MAINTAINER)" >>$@
	@echo "Source: $(KISMET_SITE)/$(KISMET_SOURCE)" >>$@
	@echo "Description: $(KISMET_DESCRIPTION)" >>$@
	@echo "Depends: $(KISMET_DEPENDS)" >>$@
	@echo "Suggests: $(KISMET_SUGGESTS)" >>$@
	@echo "Conflicts: $(KISMET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(KISMET_IPK_DIR)/opt/sbin or $(KISMET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KISMET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(KISMET_IPK_DIR)/opt/etc/kismet/...
# Documentation files should be installed in $(KISMET_IPK_DIR)/opt/doc/kismet/...
# Daemon startup scripts should be installed in $(KISMET_IPK_DIR)/opt/etc/init.d/S??kismet
#
# You may need to patch your application to make it use these locations.
#
$(KISMET_IPK): $(KISMET_BUILD_DIR)/.built
	rm -rf $(KISMET_IPK_DIR) $(BUILD_DIR)/kismet_*_$(TARGET_ARCH).ipk
	install -d $(KISMET_IPK_DIR)/opt/bin/
	install -d $(KISMET_IPK_DIR)/opt/man/
	$(MAKE) -C $(KISMET_BUILD_DIR) DESTDIR=$(KISMET_IPK_DIR) install
	$(STRIP_COMMAND) $(KISMET_IPK_DIR)/opt/bin/kismet_server
	$(STRIP_COMMAND) $(KISMET_IPK_DIR)/opt/bin/kismet_client
	$(STRIP_COMMAND) $(KISMET_IPK_DIR)/opt/bin/kismet_drone
	install -d $(KISMET_IPK_DIR)/opt/etc/kismet
	install -m 644 $(KISMET_SOURCE_DIR)/kismet.conf $(KISMET_IPK_DIR)/opt/etc/kismet/
	install -m 644 $(KISMET_SOURCE_DIR)/ap_manuf $(KISMET_IPK_DIR)/opt/etc/kismet/
	install -m 644 $(KISMET_SOURCE_DIR)/client_manuf $(KISMET_IPK_DIR)/opt/etc/kismet/
	install -m 644 $(KISMET_SOURCE_DIR)/kismet_ui.conf $(KISMET_IPK_DIR)/opt/etc/kismet/
	install -m 644 $(KISMET_SOURCE_DIR)/kismet_drone.conf $(KISMET_IPK_DIR)/opt/etc/kismet/
#	install -d $(KISMET_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(KISMET_SOURCE_DIR)/rc.kismet $(KISMET_IPK_DIR)/opt/etc/init.d/SXXkismet
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXkismet
	$(MAKE) $(KISMET_IPK_DIR)/CONTROL/control
#	install -m 755 $(KISMET_SOURCE_DIR)/postinst $(KISMET_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(KISMET_SOURCE_DIR)/prerm $(KISMET_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(KISMET_CONFFILES) | sed -e 's/ /\n/g' > $(KISMET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KISMET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
kismet-ipk: $(KISMET_IPK)
kismet-repack:
	touch $(KISMET_BUILD_DIR)/.configured $(KISMET_BUILD_DIR)/.built
	make $(KISMET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
kismet-clean:
	rm -f $(KISMET_BUILD_DIR)/.built
	-$(MAKE) -C $(KISMET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
kismet-dirclean:
	rm -rf $(BUILD_DIR)/$(KISMET_DIR) $(KISMET_BUILD_DIR) $(KISMET_IPK_DIR) $(KISMET_IPK)
#
#
# Some sanity check for the package.
#
kismet-check: $(KISMET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(KISMET_IPK)
