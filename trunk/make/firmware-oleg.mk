###########################################################
#
# firmware-oleg
#
###########################################################
#
# FIRMWARE_OLEG_VERSION, FIRMWARE_OLEG_SITE and FIRMWARE_OLEG_SOURCE define
# the upstream location of the source code for the package.
# FIRMWARE_OLEG_DIR is the directory which is created when the source
# archive is unpacked.
# FIRMWARE_OLEG_UNZIP is the command used to unzip the source.
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
FIRMWARE_OLEG_SITE=http://wl500g.dyndns.org/$(FIRMWARE_OLEG_VERSION)
FIRMWARE_OLEG_VERSION=1.9.2.7-7f
FIRMWARE_OLEG_SOURCE=wl500g-$(FIRMWARE_OLEG_VERSION)-gcc4.tar.bz2
FIRMWARE_OLEG_DIR=broadcom
FIRMWARE_OLEG_UNZIP=bzcat
FIRMWARE_OLEG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FIRMWARE_OLEG_DESCRIPTION=Oleg custom firmwares for Asus wireless routers
FIRMWARE_OLEG_SECTION=kernel
FIRMWARE_OLEG_PRIORITY=optional
FIRMWARE_OLEG_DEPENDS=
FIRMWARE_OLEG_SUGGESTS=
FIRMWARE_OLEG_CONFLICTS=

#
# FIRMWARE_OLEG_IPK_VERSION should be incremented when the ipk changes.
#
FIRMWARE_OLEG_IPK_VERSION=4

#
# FIRMWARE_OLEG_CONFFILES should be a list of user-editable files
FIRMWARE_OLEG_CONFFILES=/opt/etc/firmware-oleg.conf /opt/etc/init.d/SXXfirmware-oleg

#
# FIRMWARE_OLEG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# FIRMWARE_OLEG_PATCHES=$(FIRMWARE_OLEG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FIRMWARE_OLEG_CPPFLAGS=
FIRMWARE_OLEG_LDFLAGS=

#
# FIRMWARE_OLEG_BUILD_DIR is the directory in which the build is done.
# FIRMWARE_OLEG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FIRMWARE_OLEG_IPK_DIR is the directory in which the ipk is built.
# FIRMWARE_OLEG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FIRMWARE_OLEG_BUILD_DIR=$(BUILD_DIR)/firmware-oleg
FIRMWARE_OLEG_SOURCE_DIR=$(SOURCE_DIR)/firmware-oleg
FIRMWARE_OLEG_IPK_DIR=$(BUILD_DIR)/firmware-oleg-$(FIRMWARE_OLEG_VERSION)-ipk
FIRMWARE_OLEG_IPK=$(BUILD_DIR)/firmware-oleg_$(FIRMWARE_OLEG_VERSION)-$(FIRMWARE_OLEG_IPK_VERSION)_$(TARGET_ARCH).ipk

FIRMWARE_OLEG_TOOLCHAIN=$(FIRMWARE_OLEG_BUILD_DIR)/toolchain/opt/brcm/hndtools-mipsel-uclibc
FIRMWARE_OLEG_TOOLPATH=$(FIRMWARE_OLEG_TOOLCHAIN)/bin:/opt/brcm/hndtools-mipsel-linux/bin:${PATH}

FIRMWARE_OLEG_KERNELDIR=$(FIRMWARE_OLEG_BUILD_DIR)/src/linux/linux

.PHONY: firmware-oleg-source firmware-oleg-unpack firmware-oleg firmware-oleg-stage firmware-oleg-ipk firmware-oleg-clean firmware-oleg-dirclean firmware-oleg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FIRMWARE_OLEG_SOURCE):
	$(WGET) -P $(DL_DIR) $(FIRMWARE_OLEG_SITE)/$(FIRMWARE_OLEG_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FIRMWARE_OLEG_SOURCE)

FIRMWARE_OLEG_GPL_SITE=ftp://ftp.asus.com/pub/ASUS/wireless/WL-500g-03
FIRMWARE_OLEG_GPL=GPL_1927.zip


$(DL_DIR)/$(FIRMWARE_OLEG_GPL):
	$(WGET) -P $(DL_DIR) $(FIRMWARE_OLEG_GPL_SITE)/$(FIRMWARE_OLEG_GPL) ||\
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FIRMWARE_OLEG_GPL)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
firmware-oleg-source: $(DL_DIR)/$(FIRMWARE_OLEG_SOURCE) $(DL_DIR)/$(FIRMWARE_OLEG_GPL) $(FIRMWARE_OLEG_PATCHES)

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
$(FIRMWARE_OLEG_BUILD_DIR)/.configured: $(DL_DIR)/$(FIRMWARE_OLEG_GPL) \
	$(DL_DIR)/$(FIRMWARE_OLEG_SOURCE) $(FIRMWARE_OLEG_PATCHES)  make/firmware-oleg.mk
	rm -rf $(BUILD_DIR)/$(FIRMWARE_OLEG_DIR) $(FIRMWARE_OLEG_BUILD_DIR)
ifeq ($(MAKE_VERSION), 3.81)
	$(error make version 3.81 not supported by uClibc 0.9.19. Use 3.80 instead)
endif
	zcat $(DL_DIR)/$(FIRMWARE_OLEG_GPL) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FIRMWARE_OLEG_PATCHES)" ; \
		then cat $(FIRMWARE_OLEG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FIRMWARE_OLEG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(FIRMWARE_OLEG_DIR)" != "$(FIRMWARE_OLEG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FIRMWARE_OLEG_DIR) $(FIRMWARE_OLEG_BUILD_DIR) ; \
	fi
	$(FIRMWARE_OLEG_UNZIP) $(DL_DIR)/$(FIRMWARE_OLEG_SOURCE) | \
		tar -C $(FIRMWARE_OLEG_BUILD_DIR)/src -xvf -
	sed -i  -e 's/# CONFIG_USB_SERIAL_FTDI_SIO is not set/CONFIG_USB_SERIAL_FTDI_SIO=m/'\
	  	-e 's/# CONFIG_EXT2_FS is not set/CONFIG_EXT2_FS=y/' \
		$(FIRMWARE_OLEG_BUILD_DIR)/src/wl500g-$(FIRMWARE_OLEG_VERSION)/kernel.config
	sed -i  -e 's|^DEVEL_PREFIX.*|DEVEL_PREFIX="$(FIRMWARE_OLEG_TOOLCHAIN)"|' \
		-e 's|^RUNTIME_PREFIX.*|RUNTIME_PREFIX="$(FIRMWARE_OLEG_TOOLCHAIN)"|' \
		$(FIRMWARE_OLEG_BUILD_DIR)/src/wl500g-$(FIRMWARE_OLEG_VERSION)/uClibc*.config
	if ! test -d /opt/brcm/hndtools-mipsel-uclibc/bin ; \
		then echo "Required wl500g toolchain missing!"; \
		echo "Use mv $(FIRMWARE_OLEG_BUILD_DIR)/opt/brcm /opt"; \
		exit 1; \
	fi
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/wl500g-$(FIRMWARE_OLEG_VERSION) \
		$(FIRMWARE_OLEG_BUILD_DIR)/src/uClibc
	install -d $(FIRMWARE_OLEG_BUILD_DIR)/toolchain
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/uClibc all install CROSS=mipsel-linux-
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/wl500g-$(FIRMWARE_OLEG_VERSION) kernel
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/wl500g-$(FIRMWARE_OLEG_VERSION) all
	touch $@

firmware-oleg-unpack: $(FIRMWARE_OLEG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FIRMWARE_OLEG_BUILD_DIR)/.built: $(FIRMWARE_OLEG_BUILD_DIR)/.configured
	rm -f $@
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway images
	touch $@

#
# This is the build convenience target.
#
firmware-oleg: $(FIRMWARE_OLEG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FIRMWARE_OLEG_BUILD_DIR)/.staged: $(FIRMWARE_OLEG_BUILD_DIR)/.built
	rm -f $@
	PATH=$(FIRMWARE_OLEG_TOOLPATH) \
	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway install
#	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

firmware-oleg-stage: $(FIRMWARE_OLEG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/firmware-oleg
#
$(FIRMWARE_OLEG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: firmware-oleg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FIRMWARE_OLEG_PRIORITY)" >>$@
	@echo "Section: $(FIRMWARE_OLEG_SECTION)" >>$@
	@echo "Version: $(FIRMWARE_OLEG_VERSION)-$(FIRMWARE_OLEG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FIRMWARE_OLEG_MAINTAINER)" >>$@
	@echo "Source: $(FIRMWARE_OLEG_SITE)/$(FIRMWARE_OLEG_SOURCE)" >>$@
	@echo "Description: $(FIRMWARE_OLEG_DESCRIPTION)" >>$@
	@echo "Depends: $(FIRMWARE_OLEG_DEPENDS)" >>$@
	@echo "Suggests: $(FIRMWARE_OLEG_SUGGESTS)" >>$@
	@echo "Conflicts: $(FIRMWARE_OLEG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FIRMWARE_OLEG_IPK_DIR)/opt/sbin or $(FIRMWARE_OLEG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FIRMWARE_OLEG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/firmware-oleg/...
# Documentation files should be installed in $(FIRMWARE_OLEG_IPK_DIR)/opt/doc/firmware-oleg/...
# Daemon startup scripts should be installed in $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/init.d/S??firmware-oleg
#
# You may need to patch your application to make it use these locations.
#
$(FIRMWARE_OLEG_IPK): $(FIRMWARE_OLEG_BUILD_DIR)/.built
	rm -rf $(FIRMWARE_OLEG_IPK_DIR) $(BUILD_DIR)/firmware-oleg_*_$(TARGET_ARCH).ipk
	install -d $(FIRMWARE_OLEG_IPK_DIR)/opt/share/firmware
	install -m 644 $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway/mipsel-uclibc/*.trx \
		$(FIRMWARE_OLEG_IPK_DIR)/opt/share/firmware
#	$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway DESTDIR=$(FIRMWARE_OLEG_IPK_DIR)
#	install -d $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/
#	install -m 644 $(FIRMWARE_OLEG_SOURCE_DIR)/firmware-oleg.conf $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/firmware-oleg.conf
#	install -d $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FIRMWARE_OLEG_SOURCE_DIR)/rc.firmware-oleg $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/init.d/SXXfirmware-oleg
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FIRMWARE_OLEG_IPK_DIR)/opt/etc/init.d/SXXfirmware-oleg
	$(MAKE) $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/control
#	install -m 755 $(FIRMWARE_OLEG_SOURCE_DIR)/postinst $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FIRMWARE_OLEG_SOURCE_DIR)/prerm $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/prerm
#	echo $(FIRMWARE_OLEG_CONFFILES) | sed -e 's/ /\n/g' > $(FIRMWARE_OLEG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FIRMWARE_OLEG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
firmware-oleg-ipk: $(FIRMWARE_OLEG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
firmware-oleg-clean:
	rm -f $(FIRMWARE_OLEG_BUILD_DIR)/.built
	-$(MAKE) -C $(FIRMWARE_OLEG_BUILD_DIR)/src/gateway clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
firmware-oleg-dirclean:
	rm -rf $(BUILD_DIR)/$(FIRMWARE_OLEG_DIR) $(FIRMWARE_OLEG_BUILD_DIR) $(FIRMWARE_OLEG_IPK_DIR) $(FIRMWARE_OLEG_IPK)
#
#
# Some sanity check for the package.
#
firmware-oleg-check: $(FIRMWARE_OLEG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FIRMWARE_OLEG_IPK)
