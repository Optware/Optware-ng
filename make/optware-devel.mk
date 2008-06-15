###########################################################
#
# optware-devel
#
###########################################################

OPTWARE-DEVEL_VERSION=6.8
OPTWARE-DEVEL_DIR=optware-devel-$(OPTWARE-DEVEL_VERSION)
OPTWARE-DEVEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPTWARE-DEVEL_DESCRIPTION=This is a meta package that bundles all the packages required for optware native development.
OPTWARE-DEVEL_SECTION=util
OPTWARE-DEVEL_PRIORITY=optional
OPTWARE-DEVEL_DEPENDS=autoconf \
, automake \
, bash \
, bison \
, bzip2 \
, coreutils \
, diffutils \
, file \
, findutils \
, flex \
, gawk \
, groff \
, libstdc++ \
, libtool \
, make \
, m4 \
, ncurses \
, openssl \
, patch \
, perl \
, pkgconfig \
, python \
, rsync \
, sed \
, svn \
, tar \
, wget-ssl

ifneq (, $(filter crosstool-native, $(PACKAGES)))
OPTWARE-DEVEL_DEPENDS+=, crosstool-native
endif

ifneq (, $(filter binutils, $(PACKAGES)))
OPTWARE-DEVEL_DEPENDS+=, binutils
endif
ifneq (, $(filter libc-dev, $(PACKAGES)))
OPTWARE-DEVEL_DEPENDS+=, libc-dev
endif
ifneq (, $(filter gcc, $(PACKAGES)))
OPTWARE-DEVEL_DEPENDS+=, gcc
endif

OPTWARE-DEVEL_SUGGESTS=
OPTWARE-DEVEL_CONFLICTS=

OPTWARE-DEVEL_IPK_VERSION=8

OPTWARE-DEVEL_IPK_DIR=$(BUILD_DIR)/optware-devel-$(OPTWARE-DEVEL_VERSION)-ipk
OPTWARE-DEVEL_IPK=$(BUILD_DIR)/optware-devel_$(OPTWARE-DEVEL_VERSION)-$(OPTWARE-DEVEL_IPK_VERSION)_$(TARGET_ARCH).ipk

optware-devel-unpack:

optware-devel:

$(OPTWARE-DEVEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: optware-devel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPTWARE-DEVEL_PRIORITY)" >>$@
	@echo "Section: $(OPTWARE-DEVEL_SECTION)" >>$@
	@echo "Version: $(OPTWARE-DEVEL_VERSION)-$(OPTWARE-DEVEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPTWARE-DEVEL_MAINTAINER)" >>$@
	@echo "Source: $(OPTWARE-DEVEL_SITE)/$(OPTWARE-DEVEL_SOURCE)" >>$@
	@echo "Description: $(OPTWARE-DEVEL_DESCRIPTION)" >>$@
	@echo "Depends: $(OPTWARE-DEVEL_DEPENDS)" >>$@
	@echo "Suggests: $(OPTWARE-DEVEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPTWARE-DEVEL_CONFLICTS)" >>$@

$(OPTWARE-DEVEL_IPK):
	rm -rf $(OPTWARE-DEVEL_IPK_DIR) $(BUILD_DIR)/optware-devel_*_$(TARGET_ARCH).ipk
	$(MAKE) $(OPTWARE-DEVEL_IPK_DIR)/CONTROL/control
#	install -m 755 $(OPTWARE-DEVEL_SOURCE_DIR)/postinst $(OPTWARE-DEVEL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OPTWARE-DEVEL_SOURCE_DIR)/prerm $(OPTWARE-DEVEL_IPK_DIR)/CONTROL/prerm
#	echo $(OPTWARE-DEVEL_CONFFILES) | sed -e 's/ /\n/g' > $(OPTWARE-DEVEL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPTWARE-DEVEL_IPK_DIR)

optware-devel-ipk: $(OPTWARE-DEVEL_IPK)

optware-devel-clean:

optware-devel-dirclean:
	rm -rf $(OPTWARE-DEVEL_IPK_DIR) $(OPTWARE-DEVEL_IPK)
