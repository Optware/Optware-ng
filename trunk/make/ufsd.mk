###########################################################
#
# ufsd
#
###########################################################

#
# UFSD_VERSION, UFSD_SITE and UFSD_SOURCE define
# the upstream location of the source code for the package.
# UFSD_DIR is the directory which is created when the source
# archive is unpacked.
# UFSD_UNZIP is the command used to unzip the source.
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
UFSD_VERSION=2.3R63
UFSD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UFSD_DESCRIPTION=NTFS read/write kernel module from Linksys V2.3R63 firmware.
UFSD_SECTION=kernel
UFSD_PRIORITY=optional
UFSD_DEPENDS=unzip, unslung-rootfs (>= 2.3r63-r0)
UFSD_SUGGESTS=
UFSD_CONFLICTS=

#
# UFSD_IPK_VERSION should be incremented when the ipk changes.
#
UFSD_IPK_VERSION=2

#
# <FOO>_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UFSD_IPK_DIR is the directory in which the ipk is built.
# UFSD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UFSD_SOURCE_DIR=$(SOURCE_DIR)/ufsd
UFSD_IPK_DIR=$(BUILD_DIR)/ufsd-$(UFSD_VERSION)-ipk
UFSD_IPK=$(BUILD_DIR)/ufsd_$(UFSD_VERSION)-$(UFSD_IPK_VERSION)_$(TARGET_ARCH).ipk

ufsd-source:
ufsd-unpack:
ufsd:

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ufsd
#
$(UFSD_IPK_DIR)/CONTROL/control:
	@install -d $(UFSD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ufsd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UFSD_PRIORITY)" >>$@
	@echo "Section: $(UFSD_SECTION)" >>$@
	@echo "Version: $(UFSD_VERSION)-$(UFSD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UFSD_MAINTAINER)" >>$@
	@echo "Source: www.linksys.com" >>$@
	@echo "Description: $(UFSD_DESCRIPTION)" >>$@
	@echo "Depends: $(UFSD_DEPENDS)" >>$@
	@echo "Suggests: $(UFSD_SUGGESTS)" >>$@
	@echo "Conflicts: $(UFSD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UFSD_IPK_DIR)/opt/sbin or $(UFSD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UFSD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UFSD_IPK_DIR)/opt/etc/ufsd/...
# Documentation files should be installed in $(UFSD_IPK_DIR)/opt/doc/ufsd/...
# Daemon startup scripts should be installed in $(UFSD_IPK_DIR)/opt/etc/init.d/S??ufsd
#
# You may need to patch your application to make it use these locations.
#
$(UFSD_IPK):
	rm -rf $(UFSD_IPK_DIR) $(BUILD_DIR)/ufsd_*_$(TARGET_ARCH).ipk
	$(MAKE) $(UFSD_IPK_DIR)/CONTROL/control
	install -m 755 $(UFSD_SOURCE_DIR)/postinst $(UFSD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(UFSD_SOURCE_DIR)/prerm $(UFSD_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UFSD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ufsd-ipk: $(UFSD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ufsd-clean:

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ufsd-dirclean:
	rm -rf $(UFSD_IPK_DIR) $(UFSD_IPK)
