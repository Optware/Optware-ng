###########################################################
#
# ipcalc
#
###########################################################

IPCALC_SITE=http://jodies.de/ipcalc-archive
IPCALC_VERSION=0.41
IPCALC_SOURCE=ipcalc-$(IPCALC_VERSION).tar.gz
IPCALC_DIR=ipcalc-$(IPCALC_VERSION)
IPCALC_UNZIP=zcat
IPCALC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPCALC_DESCRIPTION=Calculator for IPv4 addresses.
IPCALC_SECTION=util
IPCALC_PRIORITY=optional
IPCALC_DEPENDS=perl
IPCALC_SUGGESTS=
IPCALC_CONFLICTS=

IPCALC_IPK_VERSION=1

IPCALC_CONFFILES=

IPCALC_BUILD_DIR=$(BUILD_DIR)/ipcalc
IPCALC_SOURCE_DIR=$(SOURCE_DIR)/ipcalc
IPCALC_IPK_DIR=$(BUILD_DIR)/ipcalc-$(IPCALC_VERSION)-ipk
IPCALC_IPK=$(BUILD_DIR)/ipcalc_$(IPCALC_VERSION)-$(IPCALC_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(IPCALC_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPCALC_SITE)/$(IPCALC_SOURCE)

ipcalc-source: $(DL_DIR)/$(IPCALC_SOURCE) $(IPCALC_PATCHES)

$(IPCALC_BUILD_DIR)/.configured: $(DL_DIR)/$(IPCALC_SOURCE) $(IPCALC_PATCHES)
	make perl-stage
	rm -rf $(BUILD_DIR)/$(IPCALC_DIR) $(IPCALC_BUILD_DIR)
	$(IPCALC_UNZIP) $(DL_DIR)/$(IPCALC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(IPCALC_DIR) $(IPCALC_BUILD_DIR)
	sed -i -e 's|^#!/usr/bin/perl|#!/opt/bin/perl|' \
		$(IPCALC_BUILD_DIR)/ipcalc $(IPCALC_BUILD_DIR)/ipcalc.cgi
#	(cd $(IPCALC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

ipcalc-unpack: $(IPCALC_BUILD_DIR)/.configured

$(IPCALC_BUILD_DIR)/.built: $(IPCALC_BUILD_DIR)/.configured
	rm -f $@
	touch $@

ipcalc: $(IPCALC_BUILD_DIR)/.built

$(IPCALC_BUILD_DIR)/.staged: $(IPCALC_BUILD_DIR)/.built
	rm -f $@
	touch $@

ipcalc-stage: $(IPCALC_BUILD_DIR)/.staged

$(IPCALC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ipcalc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPCALC_PRIORITY)" >>$@
	@echo "Section: $(IPCALC_SECTION)" >>$@
	@echo "Version: $(IPCALC_VERSION)-$(IPCALC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPCALC_MAINTAINER)" >>$@
	@echo "Source: $(IPCALC_SITE)/$(IPCALC_SOURCE)" >>$@
	@echo "Description: $(IPCALC_DESCRIPTION)" >>$@
	@echo "Depends: $(IPCALC_DEPENDS)" >>$@
	@echo "Suggests: $(IPCALC_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPCALC_CONFLICTS)" >>$@

$(IPCALC_IPK): $(IPCALC_BUILD_DIR)/.built
	rm -rf $(IPCALC_IPK_DIR) $(BUILD_DIR)/ipcalc_*_$(TARGET_ARCH).ipk
	install -d $(IPCALC_IPK_DIR)/opt/bin \
		$(IPCALC_IPK_DIR)/opt/lib/cgi-bin \
		$(IPCALC_IPK_DIR)/opt/share/doc/ipcalc
	install $(IPCALC_BUILD_DIR)/ipcalc $(IPCALC_IPK_DIR)/opt/bin
	install $(IPCALC_BUILD_DIR)/ipcalc.cgi $(IPCALC_IPK_DIR)/opt/lib/cgi-bin
	install $(IPCALC_BUILD_DIR)/contributors \
		$(IPCALC_BUILD_DIR)/changelog \
		$(IPCALC_BUILD_DIR)/license \
		$(IPCALC_IPK_DIR)/opt/share/doc/ipcalc
	$(MAKE) $(IPCALC_IPK_DIR)/CONTROL/control
	echo $(IPCALC_CONFFILES) | sed -e 's/ /\n/g' > $(IPCALC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPCALC_IPK_DIR)

ipcalc-ipk: $(IPCALC_IPK)

ipcalc-clean:
	-$(MAKE) -C $(IPCALC_BUILD_DIR) clean

ipcalc-dirclean:
	rm -rf $(BUILD_DIR)/$(IPCALC_DIR) $(IPCALC_BUILD_DIR) $(IPCALC_IPK_DIR) $(IPCALC_IPK)
