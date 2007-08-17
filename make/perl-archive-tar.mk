###########################################################
#
# perl-archive-tar
#
###########################################################

PERL-ARCHIVE-TAR_SITE=http://search.cpan.org/CPAN/authors/id/K/KA/KANE
PERL-ARCHIVE-TAR_VERSION=1.34
PERL-ARCHIVE-TAR_SOURCE=Archive-Tar-$(PERL-ARCHIVE-TAR_VERSION).tar.gz
PERL-ARCHIVE-TAR_DIR=Archive-Tar-$(PERL-ARCHIVE-TAR_VERSION)
PERL-ARCHIVE-TAR_UNZIP=zcat
PERL-ARCHIVE-TAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-ARCHIVE-TAR_DESCRIPTION=Archive-Tar - The Perl Database Interface by Tim Bunce.
PERL-ARCHIVE-TAR_SECTION=util
PERL-ARCHIVE-TAR_PRIORITY=optional
PERL-ARCHIVE-TAR_DEPENDS=perl, perl-io-zlib, perl-io-string, perl-text-diff
PERL-ARCHIVE-TAR_SUGGESTS=
PERL-ARCHIVE-TAR_CONFLICTS=

PERL-ARCHIVE-TAR_IPK_VERSION=1

PERL-ARCHIVE-TAR_CONFFILES=

PERL-ARCHIVE-TAR_BUILD_DIR=$(BUILD_DIR)/perl-archive-tar
PERL-ARCHIVE-TAR_SOURCE_DIR=$(SOURCE_DIR)/perl-archive-tar
PERL-ARCHIVE-TAR_IPK_DIR=$(BUILD_DIR)/perl-archive-tar-$(PERL-ARCHIVE-TAR_VERSION)-ipk
PERL-ARCHIVE-TAR_IPK=$(BUILD_DIR)/perl-archive-tar_$(PERL-ARCHIVE-TAR_VERSION)-$(PERL-ARCHIVE-TAR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-ARCHIVE-TAR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-ARCHIVE-TAR_SITE)/$(PERL-ARCHIVE-TAR_SOURCE)

perl-archive-tar-source: $(DL_DIR)/$(PERL-ARCHIVE-TAR_SOURCE) $(PERL-ARCHIVE-TAR_PATCHES)

$(PERL-ARCHIVE-TAR_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-ARCHIVE-TAR_SOURCE) $(PERL-ARCHIVE-TAR_PATCHES)
	$(MAKE) perl-io-zlib-stage perl-io-string-stage perl-text-diff-stage
	rm -rf $(BUILD_DIR)/$(PERL-ARCHIVE-TAR_DIR) $(PERL-ARCHIVE-TAR_BUILD_DIR)
	$(PERL-ARCHIVE-TAR_UNZIP) $(DL_DIR)/$(PERL-ARCHIVE-TAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-ARCHIVE-TAR_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-ARCHIVE-TAR_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-ARCHIVE-TAR_DIR) $(PERL-ARCHIVE-TAR_BUILD_DIR)
	(cd $(PERL-ARCHIVE-TAR_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL -d\
		PREFIX=/opt \
	)
	touch $(PERL-ARCHIVE-TAR_BUILD_DIR)/.configured

perl-archive-tar-unpack: $(PERL-ARCHIVE-TAR_BUILD_DIR)/.configured

$(PERL-ARCHIVE-TAR_BUILD_DIR)/.built: $(PERL-ARCHIVE-TAR_BUILD_DIR)/.configured
	rm -f $(PERL-ARCHIVE-TAR_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-ARCHIVE-TAR_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-ARCHIVE-TAR_BUILD_DIR)/.built

perl-archive-tar: $(PERL-ARCHIVE-TAR_BUILD_DIR)/.built

$(PERL-ARCHIVE-TAR_BUILD_DIR)/.staged: $(PERL-ARCHIVE-TAR_BUILD_DIR)/.built
	rm -f $(PERL-ARCHIVE-TAR_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-ARCHIVE-TAR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-ARCHIVE-TAR_BUILD_DIR)/.staged

perl-archive-tar-stage: $(PERL-ARCHIVE-TAR_BUILD_DIR)/.staged

$(PERL-ARCHIVE-TAR_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-ARCHIVE-TAR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-archive-tar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-ARCHIVE-TAR_PRIORITY)" >>$@
	@echo "Section: $(PERL-ARCHIVE-TAR_SECTION)" >>$@
	@echo "Version: $(PERL-ARCHIVE-TAR_VERSION)-$(PERL-ARCHIVE-TAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-ARCHIVE-TAR_MAINTAINER)" >>$@
	@echo "Source: $(PERL-ARCHIVE-TAR_SITE)/$(PERL-ARCHIVE-TAR_SOURCE)" >>$@
	@echo "Description: $(PERL-ARCHIVE-TAR_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-ARCHIVE-TAR_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-ARCHIVE-TAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-ARCHIVE-TAR_CONFLICTS)" >>$@

$(PERL-ARCHIVE-TAR_IPK): $(PERL-ARCHIVE-TAR_BUILD_DIR)/.built
	rm -rf $(PERL-ARCHIVE-TAR_IPK_DIR) $(BUILD_DIR)/perl-archive-tar_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-ARCHIVE-TAR_BUILD_DIR) DESTDIR=$(PERL-ARCHIVE-TAR_IPK_DIR) install
	perl -pi -e 's|$(PERL_HOSTPERL)|/opt/bin/perl|g' $(PERL-ARCHIVE-TAR_IPK_DIR)/*
	find $(PERL-ARCHIVE-TAR_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-ARCHIVE-TAR_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-ARCHIVE-TAR_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-ARCHIVE-TAR_IPK_DIR)/CONTROL/control
	echo $(PERL-ARCHIVE-TAR_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-ARCHIVE-TAR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-ARCHIVE-TAR_IPK_DIR)

perl-archive-tar-ipk: $(PERL-ARCHIVE-TAR_IPK)

perl-archive-tar-clean:
	-$(MAKE) -C $(PERL-ARCHIVE-TAR_BUILD_DIR) clean

perl-archive-tar-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-ARCHIVE-TAR_DIR) $(PERL-ARCHIVE-TAR_BUILD_DIR) $(PERL-ARCHIVE-TAR_IPK_DIR) $(PERL-ARCHIVE-TAR_IPK)
