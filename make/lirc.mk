###########################################################
#
# lirc
#
###########################################################
#
# LIRC_VERSION, LIRC_SITE and LIRC_SOURCE define
# the upstream location of the source code for the package.
# LIRC_DIR is the directory which is created when the source
# archive is unpacked.
# LIRC_UNZIP is the command used to unzip the source.
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
# Only one driver can be specified at a time! This means that there
# should be multiple lirc subpackages or maybe using libirman 
# http://lirc.sourceforge.net/software/snapshots/
#
LIRC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/lirc
LIRC_VERSION=0.8.1
LIRC_SOURCE=lirc-$(LIRC_VERSION).tar.bz2
LIRC_DIR=lirc-$(LIRC_VERSION)
LIRC_UNZIP=bzcat
LIRC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIRC_DESCRIPTION=Linux Infrared Remote Control ($(LIRC_DRIVER))
LIRC_SECTION=comm
LIRC_PRIORITY=optional
LIRC_DEPENDS=
LIRC_SUGGESTS=
LIRC_CONFLICTS=

#
# LIRC_IPK_VERSION should be incremented when the ipk changes.
#
LIRC_IPK_VERSION=2

#
# LIRC_CONFFILES should be a list of user-editable files
#LIRC_CONFFILES=/opt/etc/lirc.conf /opt/etc/init.d/SXXlirc

#
# LIRC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIRC_PATCHES=$(LIRC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIRC_CPPFLAGS=
LIRC_LDFLAGS=


# http://www.lirc.org/html/table.html
ifeq ($(OPTWARE_TARGET), oleg)
LIRC_KERNELDIR=$(FIRMWARE_OLEG_KERNELDIR)
LIRC_DRIVER=igorplugusb
else
LIRC_KERNELDIR=/nonexistent
LIRC_DRIVER=tira
endif




#
# LIRC_BUILD_DIR is the directory in which the build is done.
# LIRC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIRC_IPK_DIR is the directory in which the ipk is built.
# LIRC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIRC_BUILD_DIR=$(BUILD_DIR)/lirc
LIRC_SOURCE_DIR=$(SOURCE_DIR)/lirc
LIRC_IPK_DIR=$(BUILD_DIR)/lirc-$(LIRC_VERSION)-ipk
LIRC_IPK=$(BUILD_DIR)/lirc_$(LIRC_VERSION)-$(LIRC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lirc-source lirc-unpack lirc lirc-stage lirc-ipk lirc-clean lirc-dirclean lirc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIRC_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIRC_SITE)/$(LIRC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIRC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lirc-source: $(DL_DIR)/$(LIRC_SOURCE) $(LIRC_PATCHES)

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
$(LIRC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIRC_SOURCE) $(LIRC_PATCHES) make/lirc.mk
ifeq ($(OPTWARE_TARGET), oleg)
	$(MAKE) firmware-oleg-stage
endif
	rm -rf $(BUILD_DIR)/$(LIRC_DIR) $(LIRC_BUILD_DIR)
	$(LIRC_UNZIP) $(DL_DIR)/$(LIRC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIRC_PATCHES)" ; \
		then cat $(LIRC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIRC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIRC_DIR)" != "$(LIRC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIRC_DIR) $(LIRC_BUILD_DIR) ; \
	fi
	(cd $(LIRC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIRC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIRC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-kerneldir=$(LIRC_KERNELDIR) \
		--with-moduledir=/opt/lib/modules \
		--with-driver="$(LIRC_DRIVER)" \
		--without-x \
		--with-pic \
		--with-gnu-ld \
		--with-igor \
		--enable-sandboxed \
	)
#	add missing headers for module compilation
	sed -i -e '/#include <linux\/module.h>/a#include <linux/init.h>' \
		$(LIRC_BUILD_DIR)/drivers/lirc_igorplugusb/lirc_igorplugusb.c
	$(PATCH_LIBTOOL) $(LIRC_BUILD_DIR)/libtool
	touch $@

lirc-unpack: $(LIRC_BUILD_DIR)/.configured

#
# This builds the actual binary.
# kernel modules building requires .config file available
# for proper module building CFLAGS
# PATH should also contain path to appropriate compiler,
# while userspace driver is built with configure specified
# toolchain.
$(LIRC_BUILD_DIR)/.built: $(LIRC_BUILD_DIR)/.configured
	rm -f $@
	PATH=/opt/brcm/hndtools-mipsel-linux/bin:$$PATH \
	$(MAKE) -C $(LIRC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
lirc: $(LIRC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIRC_BUILD_DIR)/.staged: $(LIRC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIRC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

lirc-stage: $(LIRC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lirc
#
$(LIRC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lirc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIRC_PRIORITY)" >>$@
	@echo "Section: $(LIRC_SECTION)" >>$@
	@echo "Version: $(LIRC_VERSION)-$(LIRC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIRC_MAINTAINER)" >>$@
	@echo "Source: $(LIRC_SITE)/$(LIRC_SOURCE)" >>$@
	@echo "Description: $(LIRC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIRC_DEPENDS)" >>$@
	@echo "Suggests: $(LIRC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIRC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIRC_IPK_DIR)/opt/sbin or $(LIRC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIRC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIRC_IPK_DIR)/opt/etc/lirc/...
# Documentation files should be installed in $(LIRC_IPK_DIR)/opt/doc/lirc/...
# Daemon startup scripts should be installed in $(LIRC_IPK_DIR)/opt/etc/init.d/S??lirc
#
# You may need to patch your application to make it use these locations.
#
# /bin/mknod builds/lirc-0.8.1-ipk/dev/lirc c 61 0
$(LIRC_IPK): $(LIRC_BUILD_DIR)/.built
	rm -rf $(LIRC_IPK_DIR) $(BUILD_DIR)/lirc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIRC_BUILD_DIR) DESTDIR=$(LIRC_IPK_DIR) install-strip
	rm -rf $(LIRC_IPK_DIR)/dev
	$(STRIP_COMMAND) $(LIRC_IPK_DIR)/opt/lib/*.so.*
#	install -d $(LIRC_IPK_DIR)/opt/etc/
#	install -m 644 $(LIRC_SOURCE_DIR)/lirc.conf $(LIRC_IPK_DIR)/opt/etc/lirc.conf
#	install -d $(LIRC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIRC_SOURCE_DIR)/rc.lirc $(LIRC_IPK_DIR)/opt/etc/init.d/SXXlirc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIRC_IPK_DIR)/opt/etc/init.d/SXXlirc
	$(MAKE) $(LIRC_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIRC_SOURCE_DIR)/postinst $(LIRC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIRC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIRC_SOURCE_DIR)/prerm $(LIRC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIRC_IPK_DIR)/CONTROL/prerm
	echo $(LIRC_CONFFILES) | sed -e 's/ /\n/g' > $(LIRC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIRC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lirc-ipk: $(LIRC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lirc-clean:
	rm -f $(LIRC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIRC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lirc-dirclean:
	rm -rf $(BUILD_DIR)/$(LIRC_DIR) $(LIRC_BUILD_DIR) $(LIRC_IPK_DIR) $(LIRC_IPK)
#
#
# Some sanity check for the package.
#
lirc-check: $(LIRC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIRC_IPK)
