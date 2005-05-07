###########################################################
#
# unslung-devel
#
###########################################################

UNSLUNG-DEVEL_VERSION=3.18
UNSLUNG-DEVEL_DIR=unslung-devel-$(UNSLUNG-DEVEL_VERSION)
UNSLUNG-DEVEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNSLUNG-DEVEL_DESCRIPTION=This is a meta package that bundles all the packages required for unslung development.
UNSLUNG-DEVEL_SECTION=util
UNSLUNG-DEVEL_PRIORITY=optional
UNSLUNG-DEVEL_DEPENDS=autoconf, automake, bash, bison, bzip2, coreutils, crosstool-native, cvs, diffutils, findutils, flex, gawk, libstdc++, groff, libtool, make, m4, ncurses, openssl, patch, perl, pkgconfig, sed, tar, wget-ssl
UNSLUNG-DEVEL_SUGGESTS=
UNSLUNG-DEVEL_CONFLICTS=

UNSLUNG-DEVEL_IPK_VERSION=2

UNSLUNG-DEVEL_IPK_DIR=$(BUILD_DIR)/unslung-devel-$(UNSLUNG-DEVEL_VERSION)-ipk
UNSLUNG-DEVEL_IPK=$(BUILD_DIR)/unslung-devel_$(UNSLUNG-DEVEL_VERSION)-$(UNSLUNG-DEVEL_IPK_VERSION)_$(TARGET_ARCH).ipk

unslung-devel-unpack:

unslung-devel:

$(UNSLUNG-DEVEL_IPK_DIR)/CONTROL/control:
	@install -d $(UNSLUNG-DEVEL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: unslung-devel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNSLUNG-DEVEL_PRIORITY)" >>$@
	@echo "Section: $(UNSLUNG-DEVEL_SECTION)" >>$@
	@echo "Version: $(UNSLUNG-DEVEL_VERSION)-$(UNSLUNG-DEVEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNSLUNG-DEVEL_MAINTAINER)" >>$@
	@echo "Source: $(UNSLUNG-DEVEL_SITE)/$(UNSLUNG-DEVEL_SOURCE)" >>$@
	@echo "Description: $(UNSLUNG-DEVEL_DESCRIPTION)" >>$@
	@echo "Depends: $(UNSLUNG-DEVEL_DEPENDS)" >>$@
	@echo "Suggests: $(UNSLUNG-DEVEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNSLUNG-DEVEL_CONFLICTS)" >>$@

$(UNSLUNG-DEVEL_IPK):
	rm -rf $(UNSLUNG-DEVEL_IPK_DIR) $(BUILD_DIR)/unslung-devel_*_$(TARGET_ARCH).ipk
	$(MAKE) $(UNSLUNG-DEVEL_IPK_DIR)/CONTROL/control
#	install -m 755 $(UNSLUNG-DEVEL_SOURCE_DIR)/postinst $(UNSLUNG-DEVEL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UNSLUNG-DEVEL_SOURCE_DIR)/prerm $(UNSLUNG-DEVEL_IPK_DIR)/CONTROL/prerm
#	echo $(UNSLUNG-DEVEL_CONFFILES) | sed -e 's/ /\n/g' > $(UNSLUNG-DEVEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNSLUNG-DEVEL_IPK_DIR)

unslung-devel-ipk: $(UNSLUNG-DEVEL_IPK)

unslung-devel-clean:

unslung-devel-dirclean:
	rm -rf $(UNSLUNG-DEVEL_IPK_DIR) $(UNSLUNG-DEVEL_IPK)
