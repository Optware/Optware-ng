###########################################################
#
# stow
#
###########################################################

STOW_SITE=http://ftp.gnu.org/gnu/stow
STOW_VERSION=1.3.3
STOW_SOURCE=stow-$(STOW_VERSION).tar.gz
STOW_DIR=stow-$(STOW_VERSION)
STOW_UNZIP=zcat
STOW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STOW_DESCRIPTION=This is GNU Stow, a program for managing the installation of software packages, keeping them separate while making them appear to be installed in the same place (/opt/local).
STOW_SECTION=util
STOW_PRIORITY=optional
STOW_DEPENDS=perl
STOW_CONFLICTS=

STOW_IPK_VERSION=1

STOW_BUILD_DIR=$(BUILD_DIR)/stow
STOW_SOURCE_DIR=$(SOURCE_DIR)/stow
STOW_IPK_DIR=$(BUILD_DIR)/stow-$(STOW_VERSION)-ipk
STOW_IPK=$(BUILD_DIR)/stow_$(STOW_VERSION)-$(STOW_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(STOW_SOURCE):
	$(WGET) -P $(DL_DIR) $(STOW_SITE)/$(STOW_SOURCE)

stow-source: $(DL_DIR)/$(STOW_SOURCE) $(STOW_PATCHES)

$(STOW_BUILD_DIR)/.configured: $(DL_DIR)/$(STOW_SOURCE) $(STOW_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(STOW_DIR) $(STOW_BUILD_DIR)
	$(STOW_UNZIP) $(DL_DIR)/$(STOW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(STOW_PATCHES) | patch -d $(BUILD_DIR)/$(STOW_DIR) -p1
	mv $(BUILD_DIR)/$(STOW_DIR) $(STOW_BUILD_DIR)
	(cd $(STOW_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STOW_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STOW_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(STOW_BUILD_DIR)/.configured

stow-unpack: $(STOW_BUILD_DIR)/.configured

$(STOW_BUILD_DIR)/.built: $(STOW_BUILD_DIR)/.configured
	rm -f $(STOW_BUILD_DIR)/.built
	$(MAKE) -C $(STOW_BUILD_DIR)
	touch $(STOW_BUILD_DIR)/.built

stow: $(STOW_BUILD_DIR)/.built

$(STOW_BUILD_DIR)/.staged: $(STOW_BUILD_DIR)/.built
	rm -f $(STOW_BUILD_DIR)/.staged
	$(MAKE) -C $(STOW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(STOW_BUILD_DIR)/.staged

stow-stage: $(STOW_BUILD_DIR)/.staged

$(STOW_IPK_DIR)/CONTROL/control:
	@install -d $(STOW_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: stow" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STOW_PRIORITY)" >>$@
	@echo "Section: $(STOW_SECTION)" >>$@
	@echo "Version: $(STOW_VERSION)-$(STOW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STOW_MAINTAINER)" >>$@
	@echo "Source: $(STOW_SITE)/$(STOW_SOURCE)" >>$@
	@echo "Description: $(STOW_DESCRIPTION)" >>$@
	@echo "Depends: $(STOW_DEPENDS)" >>$@
	@echo "Conflicts: $(STOW_CONFLICTS)" >>$@

$(STOW_IPK): $(STOW_BUILD_DIR)/.built
	rm -rf $(STOW_IPK_DIR) $(BUILD_DIR)/stow_*_$(TARGET_ARCH).ipk
	install -d $(STOW_IPK_DIR)/opt/bin
	install -d $(STOW_IPK_DIR)/opt/info
	install -d $(STOW_IPK_DIR)/opt/man/man8
	install -d $(STOW_IPK_DIR)/opt/local/stow
	$(MAKE) -C $(STOW_BUILD_DIR) DESTDIR=$(STOW_IPK_DIR) install
	$(MAKE) $(STOW_IPK_DIR)/CONTROL/control
#	install -m 755 $(STOW_SOURCE_DIR)/postinst $(STOW_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(STOW_SOURCE_DIR)/prerm $(STOW_IPK_DIR)/CONTROL/prerm
#	echo $(STOW_CONFFILES) | sed -e 's/ /\n/g' > $(STOW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STOW_IPK_DIR)

stow-ipk: $(STOW_IPK)

stow-clean:
	-$(MAKE) -C $(STOW_BUILD_DIR) clean

stow-dirclean:
	rm -rf $(BUILD_DIR)/$(STOW_DIR) $(STOW_BUILD_DIR) $(STOW_IPK_DIR) $(STOW_IPK)
