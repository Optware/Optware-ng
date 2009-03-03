###########################################################
#
# ack
#
###########################################################

ACK_SITE=http://search.cpan.org/CPAN/authors/id/P/PE/PETDANCE
ACK_VERSION=1.88
ACK_SOURCE=ack-$(ACK_VERSION).tar.gz
ACK_DIR=ack-$(ACK_VERSION)
ACK_UNZIP=zcat
ACK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ACK_DESCRIPTION=grep-like text finder
ACK_SECTION=util
ACK_PRIORITY=optional
ACK_DEPENDS=perl-file-next
ACK_SUGGESTS=
ACK_CONFLICTS=

ACK_IPK_VERSION=1

ACK_CONFFILES=

ACK_BUILD_DIR=$(BUILD_DIR)/ack
ACK_SOURCE_DIR=$(SOURCE_DIR)/ack
ACK_IPK_DIR=$(BUILD_DIR)/ack-$(ACK_VERSION)-ipk
ACK_IPK=$(BUILD_DIR)/ack_$(ACK_VERSION)-$(ACK_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(ACK_SOURCE):
	$(WGET) -P $(@D) $(ACK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ack-source: $(DL_DIR)/$(ACK_SOURCE) $(ACK_PATCHES)

$(ACK_BUILD_DIR)/.configured: $(DL_DIR)/$(ACK_SOURCE) $(ACK_PATCHES)
	$(MAKE) perl-file-next-stage
	rm -rf $(BUILD_DIR)/$(ACK_DIR) $(@D)
	$(ACK_UNZIP) $(DL_DIR)/$(ACK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(ACK_PATCHES)"; then \
		cat $(ACK_PATCHES) | patch -d $(BUILD_DIR)/$(ACK_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(ACK_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $@

ack-unpack: $(ACK_BUILD_DIR)/.configured

$(ACK_BUILD_DIR)/.built: $(ACK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

ack: $(ACK_BUILD_DIR)/.built

$(ACK_BUILD_DIR)/.staged: $(ACK_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

ack-stage: $(ACK_BUILD_DIR)/.staged

$(ACK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ack" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ACK_PRIORITY)" >>$@
	@echo "Section: $(ACK_SECTION)" >>$@
	@echo "Version: $(ACK_VERSION)-$(ACK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ACK_MAINTAINER)" >>$@
	@echo "Source: $(ACK_SITE)/$(ACK_SOURCE)" >>$@
	@echo "Description: $(ACK_DESCRIPTION)" >>$@
	@echo "Depends: $(ACK_DEPENDS)" >>$@
	@echo "Suggests: $(ACK_SUGGESTS)" >>$@
	@echo "Conflicts: $(ACK_CONFLICTS)" >>$@

$(ACK_IPK): $(ACK_BUILD_DIR)/.built
	rm -rf $(ACK_IPK_DIR) $(BUILD_DIR)/ack_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ACK_BUILD_DIR) DESTDIR=$(ACK_IPK_DIR) install
	find $(ACK_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(ACK_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(ACK_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(ACK_IPK_DIR)/CONTROL/control
	echo $(ACK_CONFFILES) | sed -e 's/ /\n/g' > $(ACK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ACK_IPK_DIR)

ack-ipk: $(ACK_IPK)

ack-clean:
	-$(MAKE) -C $(ACK_BUILD_DIR) clean

ack-dirclean:
	rm -rf $(BUILD_DIR)/$(ACK_DIR) $(ACK_BUILD_DIR) $(ACK_IPK_DIR) $(ACK_IPK)

ack-check: $(ACK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ACK_IPK)
