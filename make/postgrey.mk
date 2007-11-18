###########################################################
#
# postgrey
#
###########################################################

POSTGREY_SITE=http://postgrey.schweikert.ch/pub
POSTGREY_VERSION=1.31
POSTGREY_SOURCE=postgrey-$(POSTGREY_VERSION).tar.gz
POSTGREY_DIR=postgrey-$(POSTGREY_VERSION)
POSTGREY_UNZIP=zcat
POSTGREY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
POSTGREY_DESCRIPTION=a Postfix policy server implementing greylisting.
POSTGREY_SECTION=mail
POSTGREY_PRIORITY=optional
POSTGREY_DEPENDS=perl-net-server, perl-io-multiplex, perl-berkeleydb
POSTGREY_SUGGESTS=
POSTGREY_CONFLICTS=

POSTGREY_IPK_VERSION=1

POSTGREY_CONFFILES=

POSTGREY_BUILD_DIR=$(BUILD_DIR)/postgrey
POSTGREY_SOURCE_DIR=$(SOURCE_DIR)/postgrey
POSTGREY_IPK_DIR=$(BUILD_DIR)/postgrey-$(POSTGREY_VERSION)-ipk
POSTGREY_IPK=$(BUILD_DIR)/postgrey_$(POSTGREY_VERSION)-$(POSTGREY_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(POSTGREY_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTGREY_SITE)/$(POSTGREY_SOURCE)

postgrey-source: $(DL_DIR)/$(POSTGREY_SOURCE) $(POSTGREY_PATCHES)

$(POSTGREY_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTGREY_SOURCE) $(POSTGREY_PATCHES) make/postgrey.mk
	rm -rf $(BUILD_DIR)/$(POSTGREY_DIR) $(POSTGREY_BUILD_DIR)
	$(POSTGREY_UNZIP) $(DL_DIR)/$(POSTGREY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(POSTGREY_PATCHES) | patch -d $(BUILD_DIR)/$(POSTGREY_DIR) -p1
	mv $(BUILD_DIR)/$(POSTGREY_DIR) $(@D)
	sed -i	-e '1s|#! */usr/bin/perl|#!/opt/bin/perl|' \
		-e "s|/etc/postfix|/opt&|" \
		-e "s|/var/spool|/opt&|" \
		$(@D)/postgrey $(@D)/contrib/postgreyreport
#	(cd $(POSTGREY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

postgrey-unpack: $(POSTGREY_BUILD_DIR)/.configured

$(POSTGREY_BUILD_DIR)/.built: $(POSTGREY_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

postgrey: $(POSTGREY_BUILD_DIR)/.built

$(POSTGREY_BUILD_DIR)/.staged: $(POSTGREY_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

postgrey-stage: $(POSTGREY_BUILD_DIR)/.staged

$(POSTGREY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: postgrey" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POSTGREY_PRIORITY)" >>$@
	@echo "Section: $(POSTGREY_SECTION)" >>$@
	@echo "Version: $(POSTGREY_VERSION)-$(POSTGREY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POSTGREY_MAINTAINER)" >>$@
	@echo "Source: $(POSTGREY_SITE)/$(POSTGREY_SOURCE)" >>$@
	@echo "Description: $(POSTGREY_DESCRIPTION)" >>$@
	@echo "Depends: $(POSTGREY_DEPENDS)" >>$@
	@echo "Suggests: $(POSTGREY_SUGGESTS)" >>$@
	@echo "Conflicts: $(POSTGREY_CONFLICTS)" >>$@

$(POSTGREY_IPK): $(POSTGREY_BUILD_DIR)/.built
	rm -rf $(POSTGREY_IPK_DIR) $(BUILD_DIR)/postgrey_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(POSTGREY_BUILD_DIR) DESTDIR=$(POSTGREY_IPK_DIR) install
	install -d $(POSTGREY_IPK_DIR)/opt/sbin $(POSTGREY_IPK_DIR)/opt/bin
	install -m 755 $(POSTGREY_BUILD_DIR)/postgrey $(POSTGREY_IPK_DIR)/opt/sbin
	install -m 755 $(POSTGREY_BUILD_DIR)/contrib/postgreyreport $(POSTGREY_IPK_DIR)/opt/bin
	install -d $(POSTGREY_IPK_DIR)/opt/share/postgrey
	install $(POSTGREY_BUILD_DIR)/README* \
		$(POSTGREY_BUILD_DIR)/COPYING \
		$(POSTGREY_BUILD_DIR)/Changes \
		$(POSTGREY_BUILD_DIR)/policy-test \
		$(POSTGREY_BUILD_DIR)/postgrey_whitelist_* \
		$(POSTGREY_IPK_DIR)/opt/share/postgrey/
	install -d $(POSTGREY_IPK_DIR)/opt/var/spool/postfix/postgrey
	$(MAKE) $(POSTGREY_IPK_DIR)/CONTROL/control
	echo $(POSTGREY_CONFFILES) | sed -e 's/ /\n/g' > $(POSTGREY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTGREY_IPK_DIR)

postgrey-ipk: $(POSTGREY_IPK)

postgrey-clean:
	-$(MAKE) -C $(POSTGREY_BUILD_DIR) clean

postgrey-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTGREY_DIR) $(POSTGREY_BUILD_DIR) $(POSTGREY_IPK_DIR) $(POSTGREY_IPK)
