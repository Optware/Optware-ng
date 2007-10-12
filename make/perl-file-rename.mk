###########################################################
#
# perl-file-rename
#
###########################################################

PERL-FILE-RENAME_SITE=http://www.cpan.org/pub/CPAN/modules/by-authors/id/R/RM/RMBARKER
PERL-FILE-RENAME_VERSION=0.02
PERL-FILE-RENAME_SOURCE=File-Rename-$(PERL-FILE-RENAME_VERSION).tar.gz
PERL-FILE-RENAME_DIR=File-Rename-$(PERL-FILE-RENAME_VERSION)
PERL-FILE-RENAME_UNZIP=zcat
PERL-FILE-RENAME_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-FILE-RENAME_DESCRIPTION=renames multiple files.
PERL-FILE-RENAME_SECTION=util
PERL-FILE-RENAME_PRIORITY=optional
PERL-FILE-RENAME_DEPENDS=perl
PERL-FILE-RENAME_SUGGESTS=
PERL-FILE-RENAME_CONFLICTS=

PERL-FILE-RENAME_IPK_VERSION=2

PERL-FILE-RENAME_CONFFILES=

PERL-FILE-RENAME_BUILD_DIR=$(BUILD_DIR)/perl-file-rename
PERL-FILE-RENAME_SOURCE_DIR=$(SOURCE_DIR)/perl-file-rename
PERL-FILE-RENAME_IPK_DIR=$(BUILD_DIR)/perl-file-rename-$(PERL-FILE-RENAME_VERSION)-ipk
PERL-FILE-RENAME_IPK=$(BUILD_DIR)/perl-file-rename_$(PERL-FILE-RENAME_VERSION)-$(PERL-FILE-RENAME_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-FILE-RENAME_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-FILE-RENAME_SITE)/$(PERL-FILE-RENAME_SOURCE)

perl-file-rename-source: $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) $(PERL-FILE-RENAME_PATCHES)

$(PERL-FILE-RENAME_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) $(PERL-FILE-RENAME_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(PERL-FILE-RENAME_BUILD_DIR)
	$(PERL-FILE-RENAME_UNZIP) $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-FILE-RENAME_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(PERL-FILE-RENAME_BUILD_DIR)
	(cd $(PERL-FILE-RENAME_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-FILE-RENAME_BUILD_DIR)/.configured

perl-file-rename-unpack: $(PERL-FILE-RENAME_BUILD_DIR)/.configured

$(PERL-FILE-RENAME_BUILD_DIR)/.built: $(PERL-FILE-RENAME_BUILD_DIR)/.configured
	rm -f $(PERL-FILE-RENAME_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-FILE-RENAME_BUILD_DIR) \
	PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl"
	touch $(PERL-FILE-RENAME_BUILD_DIR)/.built

perl-file-rename: $(PERL-FILE-RENAME_BUILD_DIR)/.built

$(PERL-FILE-RENAME_BUILD_DIR)/.staged: $(PERL-FILE-RENAME_BUILD_DIR)/.built
	rm -f $(PERL-FILE-RENAME_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-FILE-RENAME_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-FILE-RENAME_BUILD_DIR)/.staged

perl-file-rename-stage: $(PERL-FILE-RENAME_BUILD_DIR)/.staged

$(PERL-FILE-RENAME_IPK_DIR)/CONTROL/control:
	@install -d $(PERL-FILE-RENAME_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-file-rename" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-FILE-RENAME_PRIORITY)" >>$@
	@echo "Section: $(PERL-FILE-RENAME_SECTION)" >>$@
	@echo "Version: $(PERL-FILE-RENAME_VERSION)-$(PERL-FILE-RENAME_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-FILE-RENAME_MAINTAINER)" >>$@
	@echo "Source: $(PERL-FILE-RENAME_SITE)/$(PERL-FILE-RENAME_SOURCE)" >>$@
	@echo "Description: $(PERL-FILE-RENAME_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-FILE-RENAME_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-FILE-RENAME_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-FILE-RENAME_CONFLICTS)" >>$@

$(PERL-FILE-RENAME_IPK): $(PERL-FILE-RENAME_BUILD_DIR)/.built
	rm -rf $(PERL-FILE-RENAME_IPK_DIR) $(BUILD_DIR)/perl-file-rename_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-FILE-RENAME_BUILD_DIR) DESTDIR=$(PERL-FILE-RENAME_IPK_DIR) install
	find $(PERL-FILE-RENAME_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-FILE-RENAME_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-FILE-RENAME_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/control
	mv $(PERL-FILE-RENAME_IPK_DIR)/opt/bin/rename $(PERL-FILE-RENAME_IPK_DIR)/opt/bin/perl-file-rename
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/rename rename /opt/bin/perl-file-rename 85"; \
	) > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove rename /opt/bin/perl-file-rename"; \
	) > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/prerm
	echo $(PERL-FILE-RENAME_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-FILE-RENAME_IPK_DIR)

perl-file-rename-ipk: $(PERL-FILE-RENAME_IPK)

perl-file-rename-clean:
	-$(MAKE) -C $(PERL-FILE-RENAME_BUILD_DIR) clean

perl-file-rename-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(PERL-FILE-RENAME_BUILD_DIR) $(PERL-FILE-RENAME_IPK_DIR) $(PERL-FILE-RENAME_IPK)
