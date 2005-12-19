###########################################################
#
# groff
#
###########################################################

GROFF_SITE=http://ftp.gnu.org/gnu/groff
GROFF_VERSION=1.19.1
GROFF_SOURCE=groff-$(GROFF_VERSION).tar.gz
GROFF_DIR=groff-$(GROFF_VERSION)
GROFF_UNZIP=zcat
GROFF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GROFF_DESCRIPTION=front-end for the groff document formatting system
GROFF_SECTION=util
GROFF_PRIORITY=optional
GROFF_DEPENDS=libstdc++
GROFF_CONFLICTS=

GROFF_IPK_VERSION=4

GROFF_PATCHES=$(GROFF_SOURCE_DIR)/groff.patch

GROFF_BUILD_DIR=$(BUILD_DIR)/groff
GROFF_SOURCE_DIR=$(SOURCE_DIR)/groff
GROFF_IPK_DIR=$(BUILD_DIR)/groff-$(GROFF_VERSION)-ipk
GROFF_IPK=$(BUILD_DIR)/groff_$(GROFF_VERSION)-$(GROFF_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(GROFF_SOURCE):
	$(WGET) -P $(DL_DIR) $(GROFF_SITE)/$(GROFF_SOURCE)

groff-source: $(DL_DIR)/$(GROFF_SOURCE) $(GROFF_PATCHES)

$(GROFF_BUILD_DIR)/.configured: $(DL_DIR)/$(GROFF_SOURCE) $(GROFF_PATCHES)
	rm -rf $(BUILD_DIR)/$(GROFF_DIR) $(GROFF_BUILD_DIR)
	$(GROFF_UNZIP) $(DL_DIR)/$(GROFF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(GROFF_PATCHES) | patch -d $(BUILD_DIR)/$(GROFF_DIR) -p1
	mv $(BUILD_DIR)/$(GROFF_DIR) $(GROFF_BUILD_DIR)
	(cd $(GROFF_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GROFF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GROFF_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=\$$\(DESTDIR\)/opt \
		--disable-nls \
	)
	touch $(GROFF_BUILD_DIR)/.configured

groff-unpack: $(GROFF_BUILD_DIR)/.configured

$(GROFF_BUILD_DIR)/.built: $(GROFF_BUILD_DIR)/.configured
	rm -f $(GROFF_BUILD_DIR)/.built
	$(MAKE) -C $(GROFF_BUILD_DIR)
	touch $(GROFF_BUILD_DIR)/.built

groff: $(GROFF_BUILD_DIR)/.built

$(GROFF_IPK_DIR)/CONTROL/control:
	@install -d $(GROFF_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: groff" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GROFF_PRIORITY)" >>$@
	@echo "Section: $(GROFF_SECTION)" >>$@
	@echo "Version: $(GROFF_VERSION)-$(GROFF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GROFF_MAINTAINER)" >>$@
	@echo "Source: $(GROFF_SITE)/$(GROFF_SOURCE)" >>$@
	@echo "Description: $(GROFF_DESCRIPTION)" >>$@
	@echo "Depends: $(GROFF_DEPENDS)" >>$@
	@echo "Conflicts: $(GROFF_CONFLICTS)" >>$@

$(GROFF_IPK): $(GROFF_BUILD_DIR)/.built
	rm -rf $(GROFF_IPK_DIR) $(BUILD_DIR)/groff_*_$(TARGET_ARCH).ipk
	install -d $(GROFF_IPK_DIR)/opt/bin
	install -d $(GROFF_IPK_DIR)/opt/info
	install -d $(GROFF_IPK_DIR)/opt/lib/groff/site-tmac
	install -d $(GROFF_IPK_DIR)/opt/man/man1
	install -d $(GROFF_IPK_DIR)/opt/man/man5
	install -d $(GROFF_IPK_DIR)/opt/man/man7
	install -d $(GROFF_IPK_DIR)/opt/share/groff/1.19.1
	install -d $(GROFF_IPK_DIR)/opt/share/doc/groff/1.19.1
	$(MAKE) -C $(GROFF_BUILD_DIR) DESTDIR=$(GROFF_IPK_DIR) install
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/addftinfo
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/eqn
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grn
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grodvi
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/groff
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grolbp
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grolj4
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grops
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/grotty
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/hpftodit
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/indxbib
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/lkbib
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/lookbib
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/pfbtops
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/pic
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/post-grohtml
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/pre-grohtml
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/refer
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/soelim
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/tbl
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/tfmtodit
	$(STRIP_COMMAND) $(GROFF_IPK_DIR)/opt/bin/troff
	$(MAKE) $(GROFF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GROFF_IPK_DIR)

groff-ipk: $(GROFF_IPK)

groff-clean:
	-$(MAKE) -C $(GROFF_BUILD_DIR) clean

groff-dirclean:
	rm -rf $(BUILD_DIR)/$(GROFF_DIR) $(GROFF_BUILD_DIR) $(GROFF_IPK_DIR) $(GROFF_IPK)
