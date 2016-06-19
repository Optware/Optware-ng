###########################################################
#
# locale-archive
#
###########################################################
#
# LOCALE_ARCHIVE_VERSION, LOCALE_ARCHIVE_SITE and LOCALE_ARCHIVE_SOURCE define
# the upstream location of the source code for the package.
# LOCALE_ARCHIVE_DIR is the directory which is created when the source
# archive is unpacked.
# LOCALE_ARCHIVE_UNZIP is the command used to unzip the source.
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
LOCALE_ARCHIVE_URL=https://github.com/Optware/Optware-ng/tree/master/make/locale-archive.mk
LOCALE_ARCHIVE_VERSION=20160619
LOCALE_ARCHIVE_DIR=locale-archive
LOCALE_ARCHIVE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LOCALE_ARCHIVE_DESCRIPTION=Pre-built locale-archive with default locales
LOCALE_ARCHIVE_SECTION=misc
LOCALE_ARCHIVE_PRIORITY=optional
LOCALE_ARCHIVE_DEPENDS=gconv-modules
LOCALE_ARCHIVE_SUGGESTS=
LOCALE_ARCHIVE_CONFLICTS=

#
# LOCALE_ARCHIVE_IPK_VERSION should be incremented when the ipk changes.
#
LOCALE_ARCHIVE_IPK_VERSION=1

#
# LOCALE_ARCHIVE_CONFFILES should be a list of user-editable files
#LOCALE_ARCHIVE_CONFFILES=$(TARGET_PREFIX)/etc/locale-archive.conf $(TARGET_PREFIX)/etc/init.d/SXXlocale-archive

#
# LOCALE_ARCHIVE_BUILD_DIR is the directory in which the build is done.
# LOCALE_ARCHIVE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LOCALE_ARCHIVE_IPK_DIR is the directory in which the ipk is built.
# LOCALE_ARCHIVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LOCALE_ARCHIVE_BUILD_DIR=$(HOST_BUILD_DIR)/locale-archive
LOCALE_ARCHIVE_SOURCE_DIR=$(SOURCE_DIR)/locale-archive
LOCALE_ARCHIVE_IPK_DIR=$(BUILD_DIR)/locale-archive-$(LOCALE_ARCHIVE_VERSION)-ipk
LOCALE_ARCHIVE_IPK=$(BUILD_DIR)/locale-archive_$(LOCALE_ARCHIVE_VERSION)-$(LOCALE_ARCHIVE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: locale-archive locale-archive-ipk locale-archive-clean locale-archive-dirclean

#
# This builds the actual binary.
#
$(LOCALE_ARCHIVE_BUILD_DIR)/.built: make/locale-archive.mk
	rm -rf $(@D)
	$(INSTALL) -d $(@D)/chroot/{bin,lib,lib32,lib64,usr/lib/locale,usr/share}
	cp -f `readlink -f /bin/sh` $(@D)/chroot/bin/sh
	cp -f `which localedef` $(@D)/chroot/bin/
	-cp -f /lib/*.so* $(@D)/chroot/lib/
	-cp -f /lib32/*.so* $(@D)/chroot/lib32/
	-cp -f /lib64/*.so* $(@D)/chroot/lib64/
	cp -rf /usr/share/i18n $(@D)/chroot/usr/share/
	fakechroot fakeroot chroot $(@D)/chroot /bin/sh -c "\
		localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8; \
		localedef -i de_DE -f ISO-8859-1 de_DE; \
		localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro; \
		localedef -i de_DE -f UTF-8 de_DE.UTF-8; \
		localedef -i en_GB -f UTF-8 en_GB.UTF-8; \
		localedef -i en_HK -f ISO-8859-1 en_HK; \
		localedef -i en_PH -f ISO-8859-1 en_PH; \
		localedef -i en_US -f ISO-8859-1 en_US; \
		localedef -i en_US -f UTF-8 en_US.UTF-8; \
		localedef -i es_MX -f ISO-8859-1 es_MX; \
		localedef -i fa_IR -f UTF-8 fa_IR; \
		localedef -i fr_FR -f ISO-8859-1 fr_FR; \
		localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro; \
		localedef -i fr_FR -f UTF-8 fr_FR.UTF-8; \
		localedef -i it_IT -f ISO-8859-1 it_IT; \
		localedef -i it_IT -f UTF-8 it_IT.UTF-8; \
		localedef -i ja_JP -f EUC-JP ja_JP; \
		localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R; \
		localedef -i ru_RU -f UTF-8 ru_RU.UTF-8; \
		localedef -i tr_TR -f UTF-8 tr_TR.UTF-8; \
		localedef -i zh_CN -f GB18030 zh_CN.GB18030; \
	"
	touch $@

#
# This is the build convenience target.
#
locale-archive: $(LOCALE_ARCHIVE_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/locale-archive
#
$(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: locale-archive" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LOCALE_ARCHIVE_PRIORITY)" >>$@
	@echo "Section: $(LOCALE_ARCHIVE_SECTION)" >>$@
	@echo "Version: $(LOCALE_ARCHIVE_VERSION)-$(LOCALE_ARCHIVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LOCALE_ARCHIVE_MAINTAINER)" >>$@
	@echo "Source: $(LOCALE_ARCHIVE_URL)" >>$@
	@echo "Description: $(LOCALE_ARCHIVE_DESCRIPTION)" >>$@
	@echo "Depends: $(LOCALE_ARCHIVE_DEPENDS)" >>$@
	@echo "Suggests: $(LOCALE_ARCHIVE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LOCALE_ARCHIVE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/etc/locale-archive/...
# Documentation files should be installed in $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/doc/locale-archive/...
# Daemon startup scripts should be installed in $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??locale-archive
#
# You may need to patch your application to make it use these locations.
#
$(LOCALE_ARCHIVE_IPK): $(LOCALE_ARCHIVE_BUILD_DIR)/.built
	rm -rf $(LOCALE_ARCHIVE_IPK_DIR) $(BUILD_DIR)/locale-archive_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/lib/locale
	cp -af $(LOCALE_ARCHIVE_BUILD_DIR)/chroot/usr/lib/locale/locale-archive $(LOCALE_ARCHIVE_IPK_DIR)$(TARGET_PREFIX)/lib/locale/
	$(MAKE) $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/postinst
	echo touch "$(TARGET_PREFIX)/lib/locale/.locale_generated" >> $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/prerm
	echo "rm -f $(TARGET_PREFIX)/lib/locale/.locale_generated" >> $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/prerm
	chmod 755 $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/{postinst,prerm}
	echo $(LOCALE_ARCHIVE_CONFFILES) | sed -e 's/ /\n/g' > $(LOCALE_ARCHIVE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LOCALE_ARCHIVE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LOCALE_ARCHIVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
locale-archive-ipk: $(LOCALE_ARCHIVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
locale-archive-clean:
	rm -f $(LOCALE_ARCHIVE_BUILD_DIR)/.built
	-$(MAKE) -C $(LOCALE_ARCHIVE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
locale-archive-dirclean:
	rm -rf $(BUILD_DIR)/$(LOCALE_ARCHIVE_DIR) $(LOCALE_ARCHIVE_BUILD_DIR) $(LOCALE_ARCHIVE_IPK_DIR) $(LOCALE_ARCHIVE_IPK)
#
#
# Some sanity check for the package.
#
locale-archive-check: $(LOCALE_ARCHIVE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
