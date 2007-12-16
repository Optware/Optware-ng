###########################################################
#
# perl-file-rsyncp
#
###########################################################

PERL-FILE-RSYNCP_SITE=http://search.cpan.org/CPAN/authors/id/C/CB/CBARRATT
PERL-FILE-RSYNCP_VERSION=0.68
PERL-FILE-RSYNCP_SOURCE=File-RsyncP-$(PERL-FILE-RSYNCP_VERSION).tar.gz
PERL-FILE-RSYNCP_DIR=File-RsyncP-$(PERL-FILE-RSYNCP_VERSION)
PERL-FILE-RSYNCP_UNZIP=zcat
PERL-FILE-RSYNCP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-FILE-RSYNCP_DESCRIPTION=File::RsyncP is a perl implementation of an Rsync client.
PERL-FILE-RSYNCP_SECTION=util
PERL-FILE-RSYNCP_PRIORITY=optional
PERL-FILE-RSYNCP_DEPENDS=perl
PERL-FILE-RSYNCP_SUGGESTS=
PERL-FILE-RSYNCP_CONFLICTS=

PERL-FILE-RSYNCP_IPK_VERSION=1

PERL-FILE-RSYNCP_CONFFILES=

PERL-FILE-RSYNCP_BUILD_DIR=$(BUILD_DIR)/perl-file-rsyncp
PERL-FILE-RSYNCP_SOURCE_DIR=$(SOURCE_DIR)/perl-file-rsyncp
PERL-FILE-RSYNCP_IPK_DIR=$(BUILD_DIR)/perl-file-rsyncp-$(PERL-FILE-RSYNCP_VERSION)-ipk
PERL-FILE-RSYNCP_IPK=$(BUILD_DIR)/perl-file-rsyncp_$(PERL-FILE-RSYNCP_VERSION)-$(PERL-FILE-RSYNCP_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(PERL-FILE-RSYNCP_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-FILE-RSYNCP_SITE)/$(PERL-FILE-RSYNCP_SOURCE)

perl-file-rsyncp-source: $(DL_DIR)/$(PERL-FILE-RSYNCP_SOURCE) $(PERL-FILE-RSYNCP_PATCHES)

$(PERL-FILE-RSYNCP_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-FILE-RSYNCP_SOURCE) $(PERL-FILE-RSYNCP_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RSYNCP_DIR) $(@D)
	$(PERL-FILE-RSYNCP_UNZIP) $(DL_DIR)/$(PERL-FILE-RSYNCP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PERL-FILE-RSYNCP_PATCHES) | patch -d $(BUILD_DIR)/$(PERL-FILE-RSYNCP_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-FILE-RSYNCP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=/opt \
	)
	(cd $(@D)/FileList; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		rsync_cv_HAVE_SOCKETPAIR=yes \
		rsync_cv_HAVE_LONGLONG=yes \
		rsync_cv_HAVE_OFF64_T=no \
		rsync_cv_HAVE_SHORT_INO_T=no \
		rsync_cv_HAVE_UNSIGNED_CHAR=yes \
		rsync_cv_HAVE_BROKEN_READDIR=no \
		rsync_cv_HAVE_UTIMBUF=yes \
		rsync_cv_HAVE_GETTIMEOFDAY_TZ=yes \
		rsync_cv_HAVE_C99_VSNPRINTF=yes \
		rsync_cv_HAVE_SECURE_MKSTEMP=yes \
		rsync_cv_REPLACE_INET_NTOA=no \
		rsync_cv_REPLACE_INET_ATON=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		prefix=/opt \
	)
	touch $@

perl-file-rsyncp-unpack: $(PERL-FILE-RSYNCP_BUILD_DIR)/.configured

$(PERL-FILE-RSYNCP_BUILD_DIR)/.built: $(PERL-FILE-RSYNCP_BUILD_DIR)/.configured
	rm -f $@
	( \
	if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
	then BYTEORDER="4321"; \
	else BYTEORDER="1234"; fi; \
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_DIR)/opt/lib/perl5/site_perl" \
		BYTEORDER=$$BYTEORDER \
		; \
	)
	touch $@

perl-file-rsyncp: $(PERL-FILE-RSYNCP_BUILD_DIR)/.built

$(PERL-FILE-RSYNCP_BUILD_DIR)/.staged: $(PERL-FILE-RSYNCP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

perl-file-rsyncp-stage: $(PERL-FILE-RSYNCP_BUILD_DIR)/.staged

$(PERL-FILE-RSYNCP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: perl-file-rsyncp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-FILE-RSYNCP_PRIORITY)" >>$@
	@echo "Section: $(PERL-FILE-RSYNCP_SECTION)" >>$@
	@echo "Version: $(PERL-FILE-RSYNCP_VERSION)-$(PERL-FILE-RSYNCP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-FILE-RSYNCP_MAINTAINER)" >>$@
	@echo "Source: $(PERL-FILE-RSYNCP_SITE)/$(PERL-FILE-RSYNCP_SOURCE)" >>$@
	@echo "Description: $(PERL-FILE-RSYNCP_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-FILE-RSYNCP_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-FILE-RSYNCP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-FILE-RSYNCP_CONFLICTS)" >>$@

$(PERL-FILE-RSYNCP_IPK): $(PERL-FILE-RSYNCP_BUILD_DIR)/.built
	rm -rf $(PERL-FILE-RSYNCP_IPK_DIR) $(BUILD_DIR)/perl-file-rsyncp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-FILE-RSYNCP_BUILD_DIR) DESTDIR=$(PERL-FILE-RSYNCP_IPK_DIR) install
	find $(PERL-FILE-RSYNCP_IPK_DIR)/opt -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-FILE-RSYNCP_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-FILE-RSYNCP_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-FILE-RSYNCP_IPK_DIR)/CONTROL/control
	echo $(PERL-FILE-RSYNCP_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-FILE-RSYNCP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-FILE-RSYNCP_IPK_DIR)

perl-file-rsyncp-ipk: $(PERL-FILE-RSYNCP_IPK)

perl-file-rsyncp-clean:
	-$(MAKE) -C $(PERL-FILE-RSYNCP_BUILD_DIR) clean

perl-file-rsyncp-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-FILE-RSYNCP_DIR) $(PERL-FILE-RSYNCP_BUILD_DIR) $(PERL-FILE-RSYNCP_IPK_DIR) $(PERL-FILE-RSYNCP_IPK)

perl-file-rsyncp-check: $(PERL-FILE-RSYNCP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PERL-FILE-RSYNCP_IPK)
