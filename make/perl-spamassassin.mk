###########################################################
#
# perl-spamassassin
#
###########################################################

PERL-SPAMASSASSIN_SITE=http://www.apache.de/dist/spamassassin/source
PERL-SPAMASSASSIN_VERSION=3.0.2
PERL-SPAMASSASSIN_SOURCE=Mail-SpamAssassin-$(PERL-SPAMASSASSIN_VERSION).tar.bz2
PERL-SPAMASSASSIN_DIR=Mail-SpamAssassin-$(PERL-SPAMASSASSIN_VERSION)
PERL-SPAMASSASSIN_UNZIP=bzcat

PERL-SPAMASSASSIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-SPAMASSASSIN_DESCRIPTION=A mail filter which attempts to identify spam using a variety of mechanisms including text analysis, Bayesian filtering, DNS blocklists, and collaborative filtering databases.
PERL-SPAMASSASSIN_SECTION=util
PERL-SPAMASSASSIN_PRIORITY=optional
PERL-SPAMASSASSIN_DEPENDS=perl, perl-digest-sha1, perl-html-parser, perl-net-dns, perl-db-file

PERL-SPAMASSASSIN_IPK_VERSION=1

#PERL-SPAMASSASSIN_CONFFILES=/opt/etc/perl-spamassassin.conf /opt/etc/init.d/SXXperl-spamassassin
PERL-SPAMASSASSIN_CONFFILES=/opt/etc/spamassassin/init.pre /opt/etc/spamassassin/local.cf /opt/etc/init.d/S62spamd

PERL-SPAMASSASSIN_PATCHES=$(PERL-SPAMASSASSIN_SOURCE_DIR)/Makefile.PL.patch

PERL-SPAMASSASSIN_BUILD_DIR=$(BUILD_DIR)/perl-spamassassin
PERL-SPAMASSASSIN_SOURCE_DIR=$(SOURCE_DIR)/perl-spamassassin
PERL-SPAMASSASSIN_IPK_DIR=$(BUILD_DIR)/perl-spamassassin-$(PERL-SPAMASSASSIN_VERSION)-ipk
PERL-SPAMASSASSIN_IPK=$(BUILD_DIR)/perl-spamassassin_$(PERL-SPAMASSASSIN_VERSION)-$(PERL-SPAMASSASSIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-SPAMASSASSIN_BUILD_DIR=$(BUILD_DIR)/perl-spamassassin
PERL-SPAMASSASSIN_SOURCE_DIR=$(SOURCE_DIR)/perl-spamassassin
PERL-SPAMASSASSIN_IPK_DIR=$(BUILD_DIR)/perl-spamassassin-$(PERL-SPAMASSASSIN_VERSION)-ipk
PERL-SPAMASSASSIN_IPK=$(BUILD_DIR)/perl-spamassassin_$(PERL-SPAMASSASSIN_VERSION)-$(PERL-SPAMASSASSIN_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-SPAMASSASSIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-SPAMASSASSIN_SITE)/$(PERL-SPAMASSASSIN_SOURCE)

perl-spamassassin-source: $(DL_DIR)/$(PERL-SPAMASSASSIN_SOURCE) $(PERL-SPAMASSASSIN_PATCHES)

$(PERL-SPAMASSASSIN_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-SPAMASSASSIN_SOURCE) $(PERL-SPAMASSASSIN_PATCHES)
	$(MAKE) perl-digest-sha1-stage perl-html-parser-stage perl-net-dns-stage
	rm -rf $(BUILD_DIR)/$(PERL-SPAMASSASSIN_DIR) $(PERL-SPAMASSASSIN_BUILD_DIR)
	$(PERL-SPAMASSASSIN_UNZIP) $(DL_DIR)/$(PERL-SPAMASSASSIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PERL-SPAMASSASSIN_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-SPAMASSASSIN_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-SPAMASSASSIN_DIR) $(PERL-SPAMASSASSIN_BUILD_DIR)
	(cd $(PERL-SPAMASSASSIN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
		SYSCONFDIR=/opt/etc \
		CONFDIR=/opt/etc/spamassassin \
		CONTACT_ADDRESS="postmaster@local.domain" \
		RUN_NET_TESTS=no \
	)
	touch $(PERL-SPAMASSASSIN_BUILD_DIR)/.configured

perl-spamassassin-unpack: $(PERL-SPAMASSASSIN_BUILD_DIR)/.configured

$(PERL-SPAMASSASSIN_BUILD_DIR)/.built: $(PERL-SPAMASSASSIN_BUILD_DIR)/.configured
	rm -f $(PERL-SPAMASSASSIN_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-SPAMASSASSIN_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-SPAMASSASSIN_BUILD_DIR)/.built

perl-spamassassin: $(PERL-SPAMASSASSIN_BUILD_DIR)/.built

$(PERL-SPAMASSASSIN_BUILD_DIR)/.staged: $(PERL-SPAMASSASSIN_BUILD_DIR)/.built
	rm -f $(PERL-SPAMASSASSIN_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-SPAMASSASSIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-SPAMASSASSIN_BUILD_DIR)/.staged

perl-spamassassin-stage: $(PERL-SPAMASSASSIN_BUILD_DIR)/.staged

$(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-spamassassin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-SPAMASSASSIN_PRIORITY)" >>$@
	@echo "Section: $(PERL-SPAMASSASSIN_SECTION)" >>$@
	@echo "Version: $(PERL-SPAMASSASSIN_VERSION)-$(PERL-SPAMASSASSIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-SPAMASSASSIN_MAINTAINER)" >>$@
	@echo "Source: $(PERL-SPAMASSASSIN_SITE)/$(PERL-SPAMASSASSIN_SOURCE)" >>$@
	@echo "Description: $(PERL-SPAMASSASSIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-SPAMASSASSIN_DEPENDS)" >>$@

$(PERL-SPAMASSASSIN_IPK): $(PERL-SPAMASSASSIN_BUILD_DIR)/.built
	rm -rf $(PERL-SPAMASSASSIN_IPK_DIR) $(BUILD_DIR)/perl-spamassassin_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-SPAMASSASSIN_BUILD_DIR) DESTDIR=$(PERL-SPAMASSASSIN_IPK_DIR) install
	find $(PERL-SPAMASSASSIN_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-SPAMASSASSIN_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-SPAMASSASSIN_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	chmod go+r $(PERL-SPAMASSASSIN_IPK_DIR)/opt/etc/*
	install -d $(PERL-SPAMASSASSIN_IPK_DIR)/opt/var/run
	install -d $(PERL-SPAMASSASSIN_IPK_DIR)/opt/etc/init.d
	install -m 755 $(PERL-SPAMASSASSIN_SOURCE_DIR)/rc.perl-spamassassin $(PERL-SPAMASSASSIN_IPK_DIR)/opt/etc/init.d/S62spamd
	(cd $(PERL-SPAMASSASSIN_IPK_DIR)/opt/etc/init.d; \
		ln -s S62spamd K38spamd \
	)
	install -d $(PERL-SPAMASSASSIN_IPK_DIR)/opt/doc/perl-spamassassin
	install -m 644 $(PERL-SPAMASSASSIN_SOURCE_DIR)/README $(PERL-SPAMASSASSIN_IPK_DIR)/opt/doc/perl-spamassassin/README
	install -m 644 $(PERL-SPAMASSASSIN_SOURCE_DIR)/master.cf.patch $(PERL-SPAMASSASSIN_IPK_DIR)/opt/doc/perl-spamassassin/master.cf.patch
	$(MAKE) $(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL/control
	install -m 755 $(PERL-SPAMASSASSIN_SOURCE_DIR)/postinst $(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PERL-SPAMASSASSIN_SOURCE_DIR)/prerm $(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL/prerm
	echo $(PERL-SPAMASSASSIN_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-SPAMASSASSIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-SPAMASSASSIN_IPK_DIR)

perl-spamassassin-ipk: $(PERL-SPAMASSASSIN_IPK)

perl-spamassassin-clean:
	-$(MAKE) -C $(PERL-SPAMASSASSIN_BUILD_DIR) clean

perl-spamassassin-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-SPAMASSASSIN_DIR) $(PERL-SPAMASSASSIN_BUILD_DIR) $(PERL-SPAMASSASSIN_IPK_DIR) $(PERL-SPAMASSASSIN_IPK)
