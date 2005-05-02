###########################################################
#
# perl-mime-base64
#
###########################################################

PERL-MIME-BASE64_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-MIME-BASE64_VERSION=3.05
PERL-MIME-BASE64_SOURCE=MIME-Base64-$(PERL-MIME-BASE64_VERSION).tar.gz
PERL-MIME-BASE64_DIR=MIME-Base64-$(PERL-MIME-BASE64_VERSION)
PERL-MIME-BASE64_UNZIP=zcat
PERL-MIME-BASE64_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MIME-BASE64_DESCRIPTION=This package contains a base64 encoder/decoder and a quoted-printable encoder/decoder. These encoding methods are specified in RFC 2045 - MIME.
PERL-MIME-BASE64_SECTION=util
PERL-MIME-BASE64_PRIORITY=optional
PERL-MIME-BASE64_DEPENDS=perl
PERL-MIME-BASE64_SUGGESTS=
PERL-MIME-BASE64_CONFLICTS=

PERL-MIME-BASE64_IPK_VERSION=3

PERL-MIME-BASE64_CONFFILES=

PERL-MIME-BASE64_BUILD_DIR=$(BUILD_DIR)/perl-mime-base64
PERL-MIME-BASE64_SOURCE_DIR=$(SOURCE_DIR)/perl-mime-base64
PERL-MIME-BASE64_IPK_DIR=$(BUILD_DIR)/perl-mime-base64-$(PERL-MIME-BASE64_VERSION)-ipk
PERL-MIME-BASE64_IPK=$(BUILD_DIR)/perl-mime-base64_$(PERL-MIME-BASE64_VERSION)-$(PERL-MIME-BASE64_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-MIME-BASE64_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MIME-BASE64_SITE)/$(PERL-MIME-BASE64_SOURCE)

perl-mime-base64-source: $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) $(PERL-MIME-BASE64_PATCHES)

$(PERL-MIME-BASE64_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) $(PERL-MIME-BASE64_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR)
	$(PERL-MIME-BASE64_UNZIP) $(DL_DIR)/$(PERL-MIME-BASE64_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR)
	(cd $(PERL-MIME-BASE64_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.configured

perl-mime-base64-unpack: $(PERL-MIME-BASE64_BUILD_DIR)/.configured

$(PERL-MIME-BASE64_BUILD_DIR)/.built: $(PERL-MIME-BASE64_BUILD_DIR)/.configured
	rm -f $(PERL-MIME-BASE64_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.built

perl-mime-base64: $(PERL-MIME-BASE64_BUILD_DIR)/.built

$(PERL-MIME-BASE64_BUILD_DIR)/.staged: $(PERL-MIME-BASE64_BUILD_DIR)/.built
	rm -f $(PERL-MIME-BASE64_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MIME-BASE64_BUILD_DIR)/.staged

perl-mime-base64-stage: $(PERL-MIME-BASE64_BUILD_DIR)/.staged

$(PERL-MIME-BASE64_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-MIME-BASE64_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-mime-base64" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MIME-BASE64_PRIORITY)" >>$@
	@echo "Section: $(PERL-MIME-BASE64_SECTION)" >>$@
	@echo "Version: $(PERL-MIME-BASE64_VERSION)-$(PERL-MIME-BASE64_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MIME-BASE64_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MIME-BASE64_SITE)/$(PERL-MIME-BASE64_SOURCE)" >>$@
	@echo "Description: $(PERL-MIME-BASE64_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MIME-BASE64_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MIME-BASE64_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MIME-BASE64_CONFLICTS)" >>$@

$(PERL-MIME-BASE64_IPK): $(PERL-MIME-BASE64_BUILD_DIR)/.built
	rm -rf $(PERL-MIME-BASE64_IPK_DIR) $(BUILD_DIR)/perl-mime-base64_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) DESTDIR=$(PERL-MIME-BASE64_IPK_DIR) install
	find $(PERL-MIME-BASE64_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MIME-BASE64_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MIME-BASE64_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/control
	echo $(PERL-MIME-BASE64_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MIME-BASE64_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MIME-BASE64_IPK_DIR)

perl-mime-base64-ipk: $(PERL-MIME-BASE64_IPK)

perl-mime-base64-clean:
	-$(MAKE) -C $(PERL-MIME-BASE64_BUILD_DIR) clean

perl-mime-base64-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MIME-BASE64_DIR) $(PERL-MIME-BASE64_BUILD_DIR) $(PERL-MIME-BASE64_IPK_DIR) $(PERL-MIME-BASE64_IPK)
