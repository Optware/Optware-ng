###########################################################
#
# bubbleupnpserver-installer
#
###########################################################
#
# BUBBLEUPNPSERVER_INSTALLER_VERSION, BUBBLEUPNPSERVER_INSTALLER_SITE and BUBBLEUPNPSERVER_INSTALLER_SOURCE define
# the upstream location of the source code for the package.
# BUBBLEUPNPSERVER_INSTALLER_DIR is the directory which is created when the source
# archive is unpacked.
# BUBBLEUPNPSERVER_INSTALLER_UNZIP is the command used to unzip the source.
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
BUBBLEUPNPSERVER_INSTALLER_URL=http://www.bubblesoftapps.com/bubbleupnpserver
BUBBLEUPNPSERVER_INSTALLER_VERSION=20160421
BUBBLEUPNPSERVER_INSTALLER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BUBBLEUPNPSERVER_INSTALLER_DESCRIPTION=BubbleUPnP Server installer and rc script
BUBBLEUPNPSERVER_INSTALLER_SECTION=net
BUBBLEUPNPSERVER_INSTALLER_PRIORITY=optional
BUBBLEUPNPSERVER_INSTALLER_DEPENDS=openjdk7-jre-headless, ffmpeg, unzip, start-stop-daemon
BUBBLEUPNPSERVER_INSTALLER_SUGGESTS=
BUBBLEUPNPSERVER_INSTALLER_CONFLICTS=

#
# BUBBLEUPNPSERVER_INSTALLER_IPK_VERSION should be incremented when the ipk changes.
#
BUBBLEUPNPSERVER_INSTALLER_IPK_VERSION=1

#
# BUBBLEUPNPSERVER_INSTALLER_CONFFILES should be a list of user-editable files
BUBBLEUPNPSERVER_INSTALLER_CONFFILES=$(TARGET_PREFIX)/bin/bubbleupnpserver

#
# BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR is the directory in which the build is done.
# BUBBLEUPNPSERVER_INSTALLER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BUBBLEUPNPSERVER_INSTALLER_IPK_DIR is the directory in which the ipk is built.
# BUBBLEUPNPSERVER_INSTALLER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR=$(BUILD_DIR)/bubbleupnpserver-installer
BUBBLEUPNPSERVER_INSTALLER_SOURCE_DIR=$(SOURCE_DIR)/bubbleupnpserver-installer

BUBBLEUPNPSERVER_INSTALLER_IPK_DIR=$(BUILD_DIR)/bubbleupnpserver-installer-$(BUBBLEUPNPSERVER_INSTALLER_VERSION)-ipk
BUBBLEUPNPSERVER_INSTALLER_IPK=$(BUILD_DIR)/bubbleupnpserver-installer_$(BUBBLEUPNPSERVER_INSTALLER_VERSION)-$(BUBBLEUPNPSERVER_INSTALLER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bubbleupnpserver-installer-source bubbleupnpserver-installer-unpack bubbleupnpserver-installer bubbleupnpserver-installer-ipk bubbleupnpserver-installer-clean bubbleupnpserver-installer-dirclean bubbleupnpserver-installer-check

bubbleupnpserver-installer-source:

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
$(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.configured: make/bubbleupnpserver-installer.mk
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	touch $@

bubbleupnpserver-installer-unpack: $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.built: $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.configured
	rm -f $@
	touch $@

#
# This is the build convenience target.
#
bubbleupnpserver-installer: $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bubbleupnpserver-installer
#
$(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: bubbleupnpserver-installer" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUBBLEUPNPSERVER_INSTALLER_PRIORITY)" >>$@
	@echo "Section: $(BUBBLEUPNPSERVER_INSTALLER_SECTION)" >>$@
	@echo "Version: $(BUBBLEUPNPSERVER_INSTALLER_VERSION)-$(BUBBLEUPNPSERVER_INSTALLER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUBBLEUPNPSERVER_INSTALLER_MAINTAINER)" >>$@
	@echo "Source: $(BUBBLEUPNPSERVER_INSTALLER_URL)" >>$@
	@echo "Description: $(BUBBLEUPNPSERVER_INSTALLER_DESCRIPTION)" >>$@
	@echo "Depends: $(BUBBLEUPNPSERVER_INSTALLER_DEPENDS)" >>$@
	@echo "Suggests: $(BUBBLEUPNPSERVER_INSTALLER_SUGGESTS)" >>$@
	@echo "Conflicts: $(BUBBLEUPNPSERVER_INSTALLER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/etc/bubbleupnpserver-installer/...
# Documentation files should be installed in $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/doc/bubbleupnpserver-installer/...
# Daemon startup scripts should be installed in $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??bubbleupnpserver-installer
#
# You may need to patch your application to make it use these locations.
#
$(BUBBLEUPNPSERVER_INSTALLER_IPK): $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.built
	rm -rf $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR) $(BUILD_DIR)/bubbleupnpserver-installer_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(BUBBLEUPNPSERVER_INSTALLER_SOURCE_DIR)/rc.bubbleupnpserver $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/bin/bubbleupnpserver
	ln -s $(TARGET_PREFIX)/bin/bubbleupnpserver $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S99bubbleupnpserver
	ln -s $(TARGET_PREFIX)/bin/bubbleupnpserver $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/K15bubbleupnpserver
	$(MAKE) $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(BUBBLEUPNPSERVER_INSTALLER_SOURCE_DIR)/postinst $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)/CONTROL/postinst
	echo $(BUBBLEUPNPSERVER_INSTALLER_CONFFILES) | sed -e 's/ /\n/g' > $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bubbleupnpserver-installer-ipk: $(BUBBLEUPNPSERVER_INSTALLER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bubbleupnpserver-installer-clean:
	rm -f $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bubbleupnpserver-installer-dirclean:
	rm -rf $(BUBBLEUPNPSERVER_INSTALLER_BUILD_DIR) $(BUBBLEUPNPSERVER_INSTALLER_IPK_DIR) $(BUBBLEUPNPSERVER_INSTALLER_IPK)
#
#
# Some sanity check for the package.
#
bubbleupnpserver-installer-check: $(BUBBLEUPNPSERVER_INSTALLER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
