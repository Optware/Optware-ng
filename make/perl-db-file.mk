###########################################################
#
# perl-db-file
#
###########################################################

PERL-DB-FILE_SITE=http://search.cpan.org/CPAN/authors/id/P/PM/PMQS
PERL-DB-FILE_VERSION=1.810
PERL-DB-FILE_SOURCE=DB_File-$(PERL-DB-FILE_VERSION).tar.gz
PERL-DB-FILE_DIR=DB_File-$(PERL-DB-FILE_VERSION)
PERL-DB-FILE_UNZIP=zcat

PERL-DB-FILE_IPK_VERSION=1

PERL-DB-FILE_CONFFILES=

PERL-DB-FILE_PATCHES=$(PERL-DB-FILE_SOURCE_DIR)/config.in.patch

PERL-DB-FILE_BUILD_DIR=$(BUILD_DIR)/perl-db-file
PERL-DB-FILE_SOURCE_DIR=$(SOURCE_DIR)/perl-db-file
PERL-DB-FILE_IPK_DIR=$(BUILD_DIR)/perl-db-file-$(PERL-DB-FILE_VERSION)-ipk
PERL-DB-FILE_IPK=$(BUILD_DIR)/perl-db-file_$(PERL-DB-FILE_VERSION)-$(PERL-DB-FILE_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-DB-FILE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DB-FILE_SITE)/$(PERL-DB-FILE_SOURCE)

perl-db-file-source: $(DL_DIR)/$(PERL-DB-FILE_SOURCE) $(PERL-DB-FILE_PATCHES)

$(PERL-DB-FILE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DB-FILE_SOURCE) $(PERL-DB-FILE_PATCHES)
	$(MAKE) libdb-stage
	rm -rf $(BUILD_DIR)/$(PERL-DB-FILE_DIR) $(PERL-DB-FILE_BUILD_DIR)
	$(PERL-DB-FILE_UNZIP) $(DL_DIR)/$(PERL-DB-FILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PERL-DB-FILE_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-DB-FILE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-DB-FILE_DIR) $(PERL-DB-FILE_BUILD_DIR)
	(cd $(PERL-DB-FILE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DB-FILE_BUILD_DIR)/.configured

perl-db-file-unpack: $(PERL-DB-FILE_BUILD_DIR)/.configured

$(PERL-DB-FILE_BUILD_DIR)/.built: $(PERL-DB-FILE_BUILD_DIR)/.configured
	rm -f $(PERL-DB-FILE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DB-FILE_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-DB-FILE_BUILD_DIR)/.built

perl-db-file: $(PERL-DB-FILE_BUILD_DIR)/.built

$(PERL-DB-FILE_BUILD_DIR)/.staged: $(PERL-DB-FILE_BUILD_DIR)/.built
	rm -f $(PERL-DB-FILE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DB-FILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DB-FILE_BUILD_DIR)/.staged

perl-db-file-stage: $(PERL-DB-FILE_BUILD_DIR)/.staged

$(PERL-DB-FILE_IPK): $(PERL-DB-FILE_BUILD_DIR)/.built
	rm -rf $(PERL-DB-FILE_IPK_DIR) $(BUILD_DIR)/perl-db-file_*_armeb.ipk
	$(MAKE) -C $(PERL-DB-FILE_BUILD_DIR) DESTDIR=$(PERL-DB-FILE_IPK_DIR) install
	find $(PERL-DB-FILE_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-DB-FILE_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-DB-FILE_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	install -d $(PERL-DB-FILE_IPK_DIR)/CONTROL
	install -m 644 $(PERL-DB-FILE_SOURCE_DIR)/control $(PERL-DB-FILE_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-DB-FILE_SOURCE_DIR)/postinst $(PERL-DB-FILE_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-DB-FILE_SOURCE_DIR)/prerm $(PERL-DB-FILE_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DB-FILE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DB-FILE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DB-FILE_IPK_DIR)

perl-db-file-ipk: $(PERL-DB-FILE_IPK)

perl-db-file-clean:
	-$(MAKE) -C $(PERL-DB-FILE_BUILD_DIR) clean

perl-db-file-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DB-FILE_DIR) $(PERL-DB-FILE_BUILD_DIR) $(PERL-DB-FILE_IPK_DIR) $(PERL-DB-FILE_IPK)
