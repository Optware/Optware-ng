###########################################################
#
# qemu-gnemul
#
###########################################################
#
# QEMU_VERSION, QEMU_SITE and QEMU_SOURCE define
# the upstream location of the source code for the package.
# QEMU_DIR is the directory which is created when the source
# archive is unpacked.
# QEMU_UNZIP is the command used to unzip the source.
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
QEMU_GNEMUL_SITE=http://fabrice.bellard.free.fr/qemu
QEMU_GNEMUL_VERSION=0.5.1
QEMU_GNEMUL_SOURCE=qemu-gnemul-$(QEMU_GNEMUL_VERSION).tar.gz
QEMU_GNEMUL_DIR=usr
QEMU_GNEMUL_UNZIP=zcat
QEMU_GNEMUL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QEMU_GNEMUL_DESCRIPTION=System libraries for the various machines that qemu can emulate.
QEMU_GNEMUL_SECTION=misc
QEMU_GNEMUL_PRIORITY=optional
QEMU_GNEMUL_DEPENDS=zlib
QEMU_GNEMUL_SUGGESTS=
QEMU_GNEMUL_CONFLICTS=

#
# QEMU_IPK_VERSION should be incremented when the ipk changes.
#
QEMU_GNEMUL_IPK_VERSION=1

#
# You should not change any of these variables.
#
QEMU_GNEMUL_BUILD_DIR=$(BUILD_DIR)/qemu-gnemul
QEMU_GNEMUL_SOURCE_DIR=$(SOURCE_DIR)/qemu-gnemul
QEMU_GNEMUL_IPK_DIR=$(BUILD_DIR)/qemu-gnemul-$(QEMU_GNEMUL_VERSION)-ipk
QEMU_GNEMUL_IPK=$(BUILD_DIR)/qemu-gnemul_$(QEMU_GNEMUL_VERSION)-$(QEMU_GNEMUL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QEMU_GNEMUL_SOURCE):
	$(WGET) -P $(DL_DIR) $(QEMU_GNEMUL_SITE)/$(QEMU_GNEMUL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qemu-gnemul-source: $(DL_DIR)/$(QEMU_GNEMUL_SOURCE)

#
# This target unpacks the source code in the build directory.
#
$(QEMU_GNEMUL_BUILD_DIR)/.configured: $(DL_DIR)/$(QEMU_GNEMUL_SOURCE)
	rm -rf $(BUILD_DIR)/$(QEMU_GNEMUL_DIR) $(QEMU_GNEMUL_BUILD_DIR)
	mkdir $(QEMU_GNEMUL_BUILD_DIR)
	touch $(QEMU_GNEMUL_BUILD_DIR)/.configured

qemu-gnemul-unpack: $(QEMU_GNEMUL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QEMU_GNEMUL_BUILD_DIR)/.built: $(QEMU_GNEMUL_BUILD_DIR)/.configured
	rm -f $(QEMU_GNEMUL_BUILD_DIR)/.built
	touch $(QEMU_GNEMUL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
qemu-gnemul: $(QEMU_GNEMUL_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qemu
#
$(QEMU_GNEMUL_IPK_DIR)/CONTROL/control:
	@install -d $(QEMU_GNEMUL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: qemu-gnemul" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QEMU_GNEMUL_PRIORITY)" >>$@
	@echo "Section: $(QEMU_GNEMUL_SECTION)" >>$@
	@echo "Version: $(QEMU_GNEMUL_VERSION)-$(QEMU_GNEMUL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QEMU_GNEMUL_MAINTAINER)" >>$@
	@echo "Source: $(QEMU_GNEMUL_SITE)/$(QEMU_GNEMUL_SOURCE)" >>$@
	@echo "Description: $(QEMU_GNEMUL_DESCRIPTION)" >>$@
	@echo "Depends: $(QEMU_GNEMUL_DEPENDS)" >>$@
	@echo "Suggests: $(QEMU_GNEMUL_SUGGESTS)" >>$@
	@echo "Conflicts: $(QEMU_GNEMUL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
#
$(QEMU_GNEMUL_IPK): $(DL_DIR)/$(QEMU_GNEMUL_SOURCE)
	rm -rf $(QEMU_GNEMUL_IPK_DIR) $(BUILD_DIR)/qemu-gnemul_*_$(TARGET_ARCH).ipk
	$(MAKE) $(QEMU_GNEMUL_IPK_DIR)/CONTROL/control
	mkdir -p $(QEMU_GNEMUL_IPK_DIR)/opt
	mkdir -p $(QEMU_GNEMUL_IPK_DIR)/opt/lib
	( cd $(QEMU_GNEMUL_IPK_DIR)/opt/lib ; \
		$(QEMU_GNEMUL_UNZIP) $(DL_DIR)/$(QEMU_GNEMUL_SOURCE) | \
			tar xf - ; \
		mv usr/gnemul . ; \
		rmdir usr ; \
	)
	rm -f $(QEMU_GNEMUL_IPK_DIR)/opt/lib/gnemul/qemu-*/etc/*~
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMU_GNEMUL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qemu-gnemul-ipk: $(QEMU_GNEMUL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qemu-gneuml-clean:
	rm $(QEMU_GNEMUL_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qemu-gnemul-dirclean:
	rm -rf $(BUILD_DIR)/$(QEMU_GNEMUL_DIR) $(QEMU_GNEMUL_BUILD_DIR) $(QEMU_GNEMUL_IPK_DIR) $(QEMU_GNEMUL_IPK)
