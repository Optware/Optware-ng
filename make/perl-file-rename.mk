###########################################################
#
# perl-file-rename
#
###########################################################

PERL-FILE-RENAME_SITE=http://$(PERL_CPAN_SITE)/pub/CPAN/modules/by-authors/id/R/RM/RMBARKER
PERL-FILE-RENAME_VERSION=0.05
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

PERL-FILE-RENAME_IPK_VERSION=3

PERL-FILE-RENAME_CONFFILES=

PERL-FILE-RENAME_BUILD_DIR=$(BUILD_DIR)/perl-file-rename
PERL-FILE-RENAME_SOURCE_DIR=$(SOURCE_DIR)/perl-file-rename
PERL-FILE-RENAME_IPK_DIR=$(BUILD_DIR)/perl-file-rename-$(PERL-FILE-RENAME_VERSION)-ipk
PERL-FILE-RENAME_IPK=$(BUILD_DIR)/perl-file-rename_$(PERL-FILE-RENAME_VERSION)-$(PERL-FILE-RENAME_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-FILE-RENAME_SOURCE):
	$(WGET) -P $(@D) $(PERL-FILE-RENAME_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(FREEBSD_DISTFILES)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-file-rename-source: $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) $(PERL-FILE-RENAME_PATCHES)

$(PERL-FILE-RENAME_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) $(PERL-FILE-RENAME_PATCHES) make/perl-file-rename.mk
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(@D)
	$(PERL-FILE-RENAME_UNZIP) $(DL_DIR)/$(PERL-FILE-RENAME_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-FILE-RENAME_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $@

perl-file-rename-unpack: $(PERL-FILE-RENAME_BUILD_DIR)/.configured

$(PERL-FILE-RENAME_BUILD_DIR)/.built: $(PERL-FILE-RENAME_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $@

perl-file-rename: $(PERL-FILE-RENAME_BUILD_DIR)/.built

$(PERL-FILE-RENAME_BUILD_DIR)/.staged: $(PERL-FILE-RENAME_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-file-rename-stage: $(PERL-FILE-RENAME_BUILD_DIR)/.staged

$(PERL-FILE-RENAME_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
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
	find $(PERL-FILE-RENAME_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-FILE-RENAME_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-FILE-RENAME_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/control
	mv $(PERL-FILE-RENAME_IPK_DIR)$(TARGET_PREFIX)/bin/rename $(PERL-FILE-RENAME_IPK_DIR)$(TARGET_PREFIX)/bin/perl-file-rename
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install $(TARGET_PREFIX)/bin/rename rename $(TARGET_PREFIX)/bin/perl-file-rename 85"; \
	) > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove rename $(TARGET_PREFIX)/bin/perl-file-rename"; \
	) > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PERL-FILE-RENAME_IPK_DIR)/CONTROL/postinst $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PERL-FILE-RENAME_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-FILE-RENAME_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-FILE-RENAME_IPK_DIR)

perl-file-rename-ipk: $(PERL-FILE-RENAME_IPK)

perl-file-rename-clean:
	-$(MAKE) -C $(PERL-FILE-RENAME_BUILD_DIR) clean

perl-file-rename-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RENAME_DIR) $(PERL-FILE-RENAME_BUILD_DIR) $(PERL-FILE-RENAME_IPK_DIR) $(PERL-FILE-RENAME_IPK)
