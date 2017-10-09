#/#########################################################l
#
# cyrus-imapd
#
###########################################################

CYRUS-IMAPD_SITE=http://cyrusimap.org/releases
CYRUS-IMAPD_VERSION=2.4.17-caldav-beta10
CYRUS-IMAPD_SOURCE=cyrus-imapd-$(CYRUS-IMAPD_VERSION).tar.gz
CYRUS-IMAPD_DIR=cyrus-imapd-$(CYRUS-IMAPD_VERSION)
CYRUS-IMAPD_UNZIP=zcat
CYRUS-IMAPD_MAINTAINER=Matthias Appel <private_tweety@gmx.net>
CYRUS-IMAPD_DESCRIPTION=The Carnegie Mellon University Cyrus IMAP Server
CYRUS-IMAPD_SECTION=util
CYRUS-IMAPD_PRIORITY=optional
CYRUS-IMAPD_DEPENDS=openssl, libdb, cyrus-sasl, e2fsprogs, perl
CYRUS-IMAPD_SUGGESTS=
CYRUS-IMAPD_CONFLICTS=

CYRUS-IMAPD_IPK_VERSION=3

CYRUS-IMAPD_CONFFILES=$(TARGET_PREFIX)/etc/cyrus.conf $(TARGET_PREFIX)/etc/imapd.conf $(TARGET_PREFIX)/etc/init.d/S59cyrus-imapd

CYRUS-IMAPD_PATCHES= \
 $(CYRUS-IMAPD_SOURCE_DIR)/perl.Makefile.in.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/perl.Makefile.PL.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/03-fix_docs.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/05-fix_programnames.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/06-disable_runpath.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/07-add-warnings-are-errors-mode.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/08-clean_socket_closes.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/09-kerberos-ipv4-ipv6-kludge-removal.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/10-fix_potential_overflows.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/11-fix_syslog_prefix.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/12-fix_timeout_handling.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/13a-uid_t-cleanups \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/13b-MAXFD-cleanups \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/13c-master-reload \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/13e-master-janitor-delay \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/14-xmalloc.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/16-fix_mib.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/19-fix_tls_ssl.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/21-fix_config-parsing.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/30-update_perlcalling.sh.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/35-masssievec_remove_unused_variable.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/40-rehash_fix_pathes.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/50-fix-imclient-manpage.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/65-sieveshell-enhancements.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/75-update-imapd.conf-documentation.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/77-change-missing-sieve-notice.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/80-kbsd-no-psstrings.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/81-dont-test-for-long-names.dpatch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/82-fix_manpage_errors.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/cyrus-imapd-2.4.2-902-accept-invalid-from-header.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/cyrus-imapd-2.4.2-903-normalize-authorization-id.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/86-fix_PATH_MAX_on_hurd.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/cyrus-tls-1.2.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/91-fix-extra-libpci.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/parse-GUID-for-binary-appends-as-well.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/use-system-unicodedata.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/TLS-configuration.patch \
 $(CYRUS-IMAPD_SOURCE_DIR)/debian-2.4.17-caldav-beta10/fix-caldav-virtdomain-users.patch

#$(CYRUS-IMAPD_SOURCE_DIR)/cyrus.cross.patch

# $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.3.16-autosieve-0.6.0.diff \
 $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.3.16-autocreate-0.10-0.diff \

# $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.2.12-autosievefolder-0.6.diff \
 $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.2.12-autocreate-0.9.4.diff \
 $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.2.12-rmquota+deletemailbox-0.2-1.diff \
 $(CYRUS-IMAPD_SOURCE_DIR)/cyrus-imapd-2.2.12-imapopts.h.patch \

CYRUS-IMAPD_CPPFLAGS=-fPIC -DLOCK_GIVEUP_TIMER_DEFAULT=100
CYRUS-IMAPD_LDFLAGS=-lpthread

CYRUS-IMAPD_BUILD_DIR=$(BUILD_DIR)/cyrus-imapd
CYRUS-IMAPD_SOURCE_DIR=$(SOURCE_DIR)/cyrus-imapd

CYRUS-IMAPD_IPK_DIR=$(BUILD_DIR)/cyrus-imapd-$(CYRUS-IMAPD_VERSION)-ipk
CYRUS-IMAPD_IPK=$(BUILD_DIR)/cyrus-imapd_$(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)_$(TARGET_ARCH).ipk
CYRUS-IMAPD-DOC_IPK=$(BUILD_DIR)/cyrus-imapd-doc_$(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)_$(TARGET_ARCH).ipk
CYRUS-IMAPD-DEVEL_IPK=$(BUILD_DIR)/cyrus-imapd-devel_$(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cyrus-imapd-source cyrus-imapd-unpack cyrus-imapd cyrus-imapd-stage cyrus-imapd-ipk cyrus-imapd-clean cyrus-imapd-dirclean cyrus-imapd-check

$(DL_DIR)/$(CYRUS-IMAPD_SOURCE):
	$(WGET) -P $(DL_DIR) $(CYRUS-IMAPD_SITE)/$(CYRUS-IMAPD_SOURCE)

cyrus-imapd-source: $(DL_DIR)/$(CYRUS-IMAPD_SOURCE) $(CYRUS-IMAPD_PATCHES)

$(CYRUS-IMAPD_BUILD_DIR)/.configured: $(DL_DIR)/$(CYRUS-IMAPD_SOURCE) $(CYRUS-IMAPD_PATCHES) make/cyrus-imapd.mk
	$(MAKE) libdb-stage openssl-stage
	$(MAKE) cyrus-sasl-stage
	$(MAKE) e2fsprogs-stage # for libcom_err.a and friends
ifneq (,$(filter perl, $(PACKAGES)))
	$(MAKE) perl-stage
endif
	rm -rf $(BUILD_DIR)/$(CYRUS-IMAPD_DIR) $(@D)
	$(CYRUS-IMAPD_UNZIP) $(DL_DIR)/$(CYRUS-IMAPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(CYRUS-IMAPD_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(CYRUS-IMAPD_DIR) -p1
	mv $(BUILD_DIR)/$(CYRUS-IMAPD_DIR) $(@D)
	find $(@D) -type f -name Makefile.in -exec sed -i -e 's/-s -m/-m/' {} \;
	$(INSTALL) -m 755 $(CYRUS-IMAPD_SOURCE_DIR)/config.* $(CYRUS-IMAPD_BUILD_DIR)
	(cd $(@D); \
		autoconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CC_FOR_BUILD=$(HOSTCC) \
		BUILD_CFLAGS="$(CYRUS-IMAPD_CPPFLAGS) -I.. -I../et" \
		BUILD_LDFLAGS="$(CYRUS-IMAPD_LDFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CYRUS-IMAPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CYRUS-IMAPD_LDFLAGS)" \
		PERL=false \
		cyrus_cv_func_mmap_shared=yes \
		andrew_runpath_switch=none \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--mandir=$(TARGET_PREFIX)/man \
		--sysconfdir=$(TARGET_PREFIX)/etc \
		--with-cyrus-prefix=$(TARGET_PREFIX)/libexec/cyrus \
		--with-statedir=$(TARGET_PREFIX)/var \
		--with-pidfile=$(TARGET_PREFIX)/var/run \
		--with-openssl=$(STAGING_PREFIX) \
		--with-sasl=$(STAGING_PREFIX) \
		--with-bdb=$(STAGING_PREFIX) \
		--with-auth=unix \
		--without-krb \
		--with-cyrus-user=mail \
		--with-cyrus-group=mail \
		--with-checkapop \
		--disable-nls \
		--with-com_err \
		--without-perl \
	)
ifneq (,$(filter perl, $(PACKAGES)))
	for i in perl/imap perl/sieve/managesieve; do \
	(cd $(CYRUS-IMAPD_BUILD_DIR)/$$i; \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		BDB_LIB=-ldb-$(LIBDB_LIB_VERSION) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		$(TARGET_CONFIGURE_OPTS) \
		PREFIX=$(TARGET_PREFIX) \
	) \
	done
endif
	touch $@

cyrus-imapd-unpack: $(CYRUS-IMAPD_BUILD_DIR)/.configured

$(CYRUS-IMAPD_BUILD_DIR)/.built: $(CYRUS-IMAPD_BUILD_DIR)/.configured
	rm -f $@
	PATH="`dirname $(TARGET_CC)`:$$PATH" \
	$(MAKE) -C $(@D)/com_err/et compile_et && \
	$(MAKE) -C $(@D)/sieve sieve_err.h && \
	$(MAKE) -C $(@D)
ifneq (,$(filter perl, $(PACKAGES)))
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR)/perl/imap \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS)" \
		LD=$(TARGET_CC)
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR)/perl/sieve \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS)" \
		LD=$(TARGET_CC) 
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR)/perl/sieve \
		$(PERL_INC) \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		LD_RUN_PATH=$(TARGET_PREFIX)/lib \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		LDDLFLAGS="-shared $(STAGING_LDFLAGS)" \
		LD=$(TARGET_CC) 
endif
	touch $@

cyrus-imapd: $(CYRUS-IMAPD_BUILD_DIR)/.built

$(CYRUS-IMAPD_BUILD_DIR)/.staged: $(CYRUS-IMAPD_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	echo "Warning: the makefile target 'cyrus-imapd-stage' is not available."
	touch $@

cyrus-imapd-stage: $(CYRUS-IMAPD_BUILD_DIR)/.staged

$(CYRUS-IMAPD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: cyrus-imapd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-IMAPD_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-IMAPD_SECTION)" >>$@
	@echo "Version: $(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-IMAPD_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-IMAPD_SITE)/$(CYRUS-IMAPD_SOURCE)" >>$@
	@echo "Description: $(CYRUS-IMAPD_DESCRIPTION)" >>$@
	@echo "Depends: $(CYRUS-IMAPD_DEPENDS)" >>$@
	@echo "Suggests: cyrus-imapd-doc, $(CYRUS-IMAPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(CYRUS-IMAPD_CONFLICTS)" >>$@

$(CYRUS-IMAPD_IPK_DIR)-doc/CONTROL/control:
	@$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)-doc/CONTROL
	@rm -f $@
	@echo "Package: cyrus-imapd-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-IMAPD_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-IMAPD_SECTION)" >>$@
	@echo "Version: $(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-IMAPD_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-IMAPD_SITE)/$(CYRUS-IMAPD_SOURCE)" >>$@
	@echo "Description: $(CYRUS-IMAPD_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: man" >>$@
	@echo "Conflicts: " >>$@

$(CYRUS-IMAPD_IPK_DIR)-devel/CONTROL/control:
	@$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)-devel/CONTROL
	@rm -f $@
	@echo "Package: cyrus-imapd-devel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CYRUS-IMAPD_PRIORITY)" >>$@
	@echo "Section: $(CYRUS-IMAPD_SECTION)" >>$@
	@echo "Version: $(CYRUS-IMAPD_VERSION)-$(CYRUS-IMAPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CYRUS-IMAPD_MAINTAINER)" >>$@
	@echo "Source: $(CYRUS-IMAPD_SITE)/$(CYRUS-IMAPD_SOURCE)" >>$@
	@echo "Description: $(CYRUS-IMAPD_DESCRIPTION)" >>$@
	@echo "Depends: $(CYRUS-IMAPD_DEPENDS)" >>$@
	@echo "Suggests: $(CYRUS-IMAPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(CYRUS-IMAPD_CONFLICTS)" >>$@

$(CYRUS-IMAPD_IPK) $(CYRUS-IMAPD-DOC_IPK) $(CYRUS-IMAPD-DEVEL_IPK): $(CYRUS-IMAPD_BUILD_DIR)/.built
	rm -rf $(CYRUS-IMAPD_IPK_DIR)* $(BUILD_DIR)/cyrus-imapd_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -m 644 $(CYRUS-IMAPD_SOURCE_DIR)/imapd.conf $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc/imapd.conf
	$(INSTALL) -m 644 $(CYRUS-IMAPD_SOURCE_DIR)/cyrus.conf $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc/cyrus.conf
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/include/cyrus
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/libexec/cyrus/bin
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/run
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib
	$(INSTALL) -d -m 750 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/db
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/log
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/msg
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/proc
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/ptclient
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/quota
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/sieve
	$(INSTALL) -d -m 750 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/ssl/certs
	$(INSTALL) -d -m 750 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/ssl/CA
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/socket
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/user
	(cd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/quota ; \
		for i in a b c d e f g h i j k l m n o p q r s t u v w x y z ; do install -d -m 755 $$i ; done \
	)
	(cd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/sieve ; \
		for i in a b c d e f g h i j k l m n o p q r s t u v w x y z ; do install -d -m 755 $$i ; done \
	)
	(cd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/lib/imap/user ; \
		for i in a b c d e f g h i j k l m n o p q r s t u v w x y z ; do install -d -m 755 $$i ; done \
	)
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/spool/imap
	$(INSTALL) -d -m 750 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/spool/imap/mail
	$(INSTALL) -d -m 750 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/spool/imap/news
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/spool/imap/stage.
	$(INSTALL) -d -m 755 $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/var/spool/imap/user
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR) DESTDIR=$(CYRUS-IMAPD_IPK_DIR) install
	$(STRIP_COMMAND) $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/libexec/cyrus/bin/*
	$(STRIP_COMMAND) $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(STRIP_COMMAND) $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/bin/imtest
ifneq (,$(filter perl, $(PACKAGES)))
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR)/perl/imap DESTDIR=$(CYRUS-IMAPD_IPK_DIR) install
	$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR)/perl/sieve DESTDIR=$(CYRUS-IMAPD_IPK_DIR) install
	(cd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/site_perl/$(PERL_VERSION)/$(PERL_ARCH)/auto/Cyrus ; \
		chmod +w IMAP/IMAP.so; \
		chmod +w SIEVE/managesieve/managesieve.so; \
		$(STRIP_COMMAND) IMAP/IMAP.so; \
		$(STRIP_COMMAND) SIEVE/managesieve/managesieve.so; \
		chmod -w IMAP/IMAP.so; \
		chmod -w SIEVE/managesieve/managesieve.so; \
	)
	rm -rf $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/lib/perl5/$(PERL_VERSION)
endif
	find $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/lib -type d -exec chmod go+rx {} \;
	find $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/man -type d -exec chmod go+rx {} \;
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(CYRUS-IMAPD_SOURCE_DIR)/rc.cyrus-imapd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S59cyrus-imapd
	(cd $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d; \
		ln -s S59cyrus-imapd K41cyrus-imapd \
	)

# Split into the different packages
	rm -rf $(CYRUS-IMAPD_IPK_DIR)-doc
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cyrus/html
	$(INSTALL) -m 644 $(CYRUS-IMAPD_BUILD_DIR)/README $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cyrus/README
	$(INSTALL) -m 644 $(CYRUS-IMAPD_BUILD_DIR)/doc/*.html $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cyrus/html/
	$(INSTALL) -m 644 $(CYRUS-IMAPD_BUILD_DIR)/doc/murder.* $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/share/doc/cyrus/html/
	$(INSTALL) -d install -d $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man
	mv $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/man/* $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man/
	mv $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man/man8/idled.8 $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man/man8/cyrus_idled.8
	mv $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man/man8/master.8 $(CYRUS-IMAPD_IPK_DIR)-doc$(TARGET_PREFIX)/man/man8/cyrus_master.8
	$(MAKE) $(CYRUS-IMAPD_IPK_DIR)-doc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-IMAPD_IPK_DIR)-doc

	rm -rf $(CYRUS-IMAPD_IPK_DIR)-devel
	$(INSTALL) -d $(CYRUS-IMAPD_IPK_DIR)-devel$(TARGET_PREFIX)/lib
	mv $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/lib/*.a $(CYRUS-IMAPD_IPK_DIR)-devel$(TARGET_PREFIX)/lib
	mv $(CYRUS-IMAPD_IPK_DIR)$(TARGET_PREFIX)/include $(CYRUS-IMAPD_IPK_DIR)-devel$(TARGET_PREFIX)/include
	$(MAKE) $(CYRUS-IMAPD_IPK_DIR)-devel/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-IMAPD_IPK_DIR)-devel

	$(MAKE) $(CYRUS-IMAPD_IPK_DIR)/CONTROL/control
ifeq ($(OPTWARE_TARGET),ds101g)
	$(INSTALL) -m 644 $(CYRUS-IMAPD_SOURCE_DIR)/postinst.ds101g $(CYRUS-IMAPD_IPK_DIR)/CONTROL/postinst
else
	$(INSTALL) -m 644 $(CYRUS-IMAPD_SOURCE_DIR)/postinst $(CYRUS-IMAPD_IPK_DIR)/CONTROL/postinst
endif
#	$(INSTALL) -m 644 $(CYRUS-IMAPD_SOURCE_DIR)/prerm $(CYRUS-IMAPD_IPK_DIR)/CONTROL/prerm
	echo $(CYRUS-IMAPD_CONFFILES) | sed -e 's/ /\n/g' > $(CYRUS-IMAPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CYRUS-IMAPD_IPK_DIR)

cyrus-imapd-ipk: $(CYRUS-IMAPD_IPK) $(CYRUS-IMAPD-DOC_IPK) $(CYRUS-IMAPD-DEVEL_IPK)

cyrus-imapd-clean:
	-$(MAKE) -C $(CYRUS-IMAPD_BUILD_DIR) clean

cyrus-imapd-dirclean:
	rm -rf $(BUILD_DIR)/$(CYRUS-IMAPD_DIR) $(CYRUS-IMAPD_BUILD_DIR) \
	$(CYRUS-IMAPD_IPK_DIR) $(CYRUS-IMAPD_IPK_DIR)-doc $(CYRUS-IMAPD_IPK_DIR)-devel \
	$(CYRUS-IMAPD_IPK) $(CYRUS-IMAPD-DOC_IPK) $(CYRUS-IMAPD-DEVEL_IPK)

#
# Some sanity check for the package.
#
cyrus-imapd-check: $(CYRUS-IMAPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CYRUS-IMAPD_IPK) $(CYRUS-IMAPD-DOC_IPK) $(CYRUS-IMAPD-DEVEL_IPK)
