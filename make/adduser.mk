###########################################################
#
# adduser
#
###########################################################

# You must replace "adduser" and "ADDUSER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ADDUSER_VERSION, ADDUSER_SITE and ADDUSER_SOURCE define
# the upstream location of the source code for the package.
# ADDUSER_DIR is the directory which is created when the source
# archive is unpacked.
# ADDUSER_UNZIP is the command used to unzip the source.
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
ADDUSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ADDUSER_DESCRIPTION=a multi-call binary for login and user account administration
ADDUSER_SECTION=core
ADDUSER_PRIORITY=optional
ADDUSER_DEPENDS=
ADDUSER_SUGGESTS=
ADDUSER_CONFLICTS=
# The defconfig will need to be reviewed after changes in version of busybox.
ADDUSER_VERSION:=$(shell sed -n -e 's/^BUSYBOX_VERSION *=\([0-9]\)/\1/p' make/busybox.mk)
#
# ADDUSER_IPK_VERSION should be incremented when the ipk changes.
#
ADDUSER_IPK_VERSION=1

#
# ADDUSER_CONFFILES should be a list of user-editable files
#ADDUSER_CONFFILES=/opt/etc/adduser.conf /opt/etc/init.d/SXXadduser

#
# ADDUSER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ADDUSER_PATCHES=$(ADDUSER_SOURCE_DIR)/install.sh.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ADDUSER_CPPFLAGS=
ADDUSER_LDFLAGS=

#
# ADDUSER_BUILD_DIR is the directory in which the build is done.
# ADDUSER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ADDUSER_IPK_DIR is the directory in which the ipk is built.
# ADDUSER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ADDUSER_BUILD_DIR=$(BUILD_DIR)/adduser
ADDUSER_SOURCE_DIR=$(SOURCE_DIR)/adduser
ADDUSER_IPK_DIR=$(BUILD_DIR)/adduser-$(ADDUSER_VERSION)-ipk
ADDUSER_IPK=$(BUILD_DIR)/adduser_$(ADDUSER_VERSION)-$(ADDUSER_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(ADDUSER_SOURCE):
#	$(WGET) -P $(DL_DIR) $(ADDUSER_SITE)/$(ADDUSER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
adduser-source: $(DL_DIR)/$(BUSYBOX_SOURCE)

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
$(ADDUSER_BUILD_DIR)/.configured:
	$(MAKE) $(DL_DIR)/$(BUSYBOX_SOURCE)
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(ADDUSER_BUILD_DIR)
	$(BUSYBOX_UNZIP) $(DL_DIR)/$(BUSYBOX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ADDUSER_PATCHES) | patch -d $(BUILD_DIR)/$(BUSYBOX_DIR) -p1
	mv $(BUILD_DIR)/$(BUSYBOX_DIR) $(ADDUSER_BUILD_DIR)
	cp $(ADDUSER_SOURCE_DIR)/defconfig $(ADDUSER_BUILD_DIR)/.config
ifeq (module-init-tools, $(filter module-init-tools, $(PACKAGES)))
ifneq ($(OPTWARE_TARGET), $(filter fsg3v4, $(OPTWARE_TARGET)))
# default off, turn on if linux 2.6
	sed -i -e "s/^.*CONFIG_MONOTONIC_SYSCALL.*/CONFIG_MONOTONIC_SYSCALL=y/" \
		$(ADDUSER_BUILD_DIR)/.config
endif
endif
	sed -i -e 's/-strip /-$$(STRIP) /' $(ADDUSER_BUILD_DIR)/scripts/Makefile.IMA
	$(MAKE) HOSTCC=$(HOSTCC) CC=$(TARGET_CC) CROSS=$(TARGET_CROSS) \
		-C $(ADDUSER_BUILD_DIR) oldconfig
	touch $(ADDUSER_BUILD_DIR)/.configured

adduser-unpack: $(ADDUSER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ADDUSER_BUILD_DIR)/.built: $(ADDUSER_BUILD_DIR)/.configured
	rm -f $(ADDUSER_BUILD_DIR)/.built
	CPPFLAGS="$(STAGING_CPPFLAGS) $(ADDUSER_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(ADDUSER_LDFLAGS)" \
	$(MAKE) CROSS="$(TARGET_CROSS)" PREFIX="/opt" \
		HOSTCC=$(HOSTCC) CC=$(TARGET_CC) STRIP=$(TARGET_STRIP) \
		EXTRA_CFLAGS="$(TARGET_CFLAGS) -fomit-frame-pointer" \
		-C $(ADDUSER_BUILD_DIR)
	touch $(ADDUSER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
adduser: $(ADDUSER_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/adduser
#
$(ADDUSER_IPK_DIR)/CONTROL/control:
	@install -d $(ADDUSER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: adduser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ADDUSER_PRIORITY)" >>$@
	@echo "Section: $(ADDUSER_SECTION)" >>$@
	@echo "Version: $(ADDUSER_VERSION)-$(ADDUSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ADDUSER_MAINTAINER)" >>$@
	@echo "Source: $(ADDUSER_SITE)/$(ADDUSER_SOURCE)" >>$@
	@echo "Description: $(ADDUSER_DESCRIPTION)" >>$@
	@echo "Depends: $(ADDUSER_DEPENDS)" >>$@
	@echo "Suggests: $(ADDUSER_SUGGESTS)" >>$@
	@echo "Conflicts: $(ADDUSER_CONFLICTS)" >>$@
#
# This builds the IPK file.
#
# Binaries should be installed into $(ADDUSER_IPK_DIR)/opt/sbin or $(ADDUSER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ADDUSER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ADDUSER_IPK_DIR)/opt/etc/adduser/...
# Documentation files should be installed in $(ADDUSER_IPK_DIR)/opt/doc/adduser/...
# Daemon startup scripts should be installed in $(ADDUSER_IPK_DIR)/opt/etc/init.d/S??adduser
#
# You may need to patch your application to make it use these locations.
#
$(ADDUSER_IPK): $(ADDUSER_BUILD_DIR)/.built
	rm -rf $(ADDUSER_IPK_DIR) $(BUILD_DIR)/adduser_*_$(TARGET_ARCH).ipk
	install -d $(ADDUSER_IPK_DIR)/opt/bin
	install -m 755 $(ADDUSER_BUILD_DIR)/busybox $(ADDUSER_IPK_DIR)/opt/bin/adduser
	cd $(ADDUSER_IPK_DIR)/opt/bin && ln -fs adduser addgroup
	cd $(ADDUSER_IPK_DIR)/opt/bin && ln -fs adduser delgroup
	cd $(ADDUSER_IPK_DIR)/opt/bin && ln -fs adduser deluser
	cd $(ADDUSER_IPK_DIR)/opt/bin && ln -fs adduser adduser-su
	$(MAKE) $(ADDUSER_IPK_DIR)/CONTROL/control
	install -m 644 $(ADDUSER_SOURCE_DIR)/postinst $(ADDUSER_IPK_DIR)/CONTROL/postinst
	install -m 644 $(ADDUSER_SOURCE_DIR)/prerm $(ADDUSER_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ADDUSER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
adduser-ipk: $(ADDUSER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
adduser-clean:
	-$(MAKE) -C $(ADDUSER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
adduser-dirclean:
	rm -rf $(BUILD_DIR)/$(BUSYBOX_DIR) $(ADDUSER_BUILD_DIR) $(ADDUSER_IPK_DIR) $(ADDUSER_IPK)

#
# Some sanity check for the package.
#
adduser-check: $(ADDUSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ADDUSER_IPK)
