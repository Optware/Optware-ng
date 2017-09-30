###########################################################
#
# postfix
#
###########################################################

# If you want to cross compile postfix you have to install
# some additional software. E.g. for Debian testing this 
# is libdb4.2, libdb4.2-dev, libpcre3, libpcre3-dev

POSTFIX_SITE=http://de.postfix.org/ftpmirror/official/
POSTFIX_VERSION=2.3.19
POSTFIX_SOURCE=postfix-$(POSTFIX_VERSION).tar.gz
POSTFIX_DIR=postfix-$(POSTFIX_VERSION)
POSTFIX_UNZIP=zcat
POSTFIX_MAINTAINER=Matthias Appel <private_tweety@gmx.net>
POSTFIX_DESCRIPTION=The Postfix mail system is an alternative to sendmail.
POSTFIX_SECTION=util
POSTFIX_PRIORITY=optional
POSTFIX_DEPENDS=libdb, pcre, cyrus-sasl, findutils, openssl
ifneq ($(NO_LIBNSL), true)
POSTFIX_DEPENDS += , libnsl
endif
POSTFIX_SUGGESTS=cyrus-imapd
POSTFIX_CONFLICTS=xmail

POSTFIX_IPK_VERSION=5

POSTFIX_CONFFILES=$(TARGET_PREFIX)/etc/aliases \
		  $(TARGET_PREFIX)/etc/postfix/main.cf \
		  $(TARGET_PREFIX)/etc/postfix/master.cf \
		  $(TARGET_PREFIX)/lib/sasl2/smtpd.conf \
		  $(TARGET_PREFIX)/etc/init.d/S69postfix

POSTFIX_PATCHES=$(POSTFIX_SOURCE_DIR)/postfix.patch \
		$(POSTFIX_SOURCE_DIR)/postfix-install.patch \
		$(POSTFIX_SOURCE_DIR)/postfix-script.patch \
		$(POSTFIX_SOURCE_DIR)/sys_defs.h.patch

POSTFIX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/sasl
POSTFIX_LDFLAGS=-lpcre -lnsl -lsasl2 -ldl -lssl -lpthread -lcrypto -lresolv

POSTFIX_BUILD_DIR=$(BUILD_DIR)/postfix
POSTFIX_SOURCE_DIR=$(SOURCE_DIR)/postfix
POSTFIX_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk
POSTFIX_IPK=$(BUILD_DIR)/postfix_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_$(TARGET_ARCH).ipk
POSTFIX_DOC_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk-doc
POSTFIX_DOC_IPK=$(BUILD_DIR)/postfix-doc_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: postfix-source postfix-unpack postfix postfix-stage postfix-ipk postfix-clean postfix-dirclean postfix-check

$(DL_DIR)/$(POSTFIX_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTFIX_SITE)/$(POSTFIX_SOURCE)||\
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(POSTFIX_SOURCE)

postfix-source: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES)

$(POSTFIX_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES) make/postfix.mk
	$(MAKE) libdb-stage pcre-stage cyrus-sasl-stage openssl-stage
ifneq ($(NO_LIBNSL), true)
	$(MAKE) libnsl-stage
endif
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(@D)
	$(POSTFIX_UNZIP) $(DL_DIR)/$(POSTFIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(POSTFIX_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(POSTFIX_DIR) -p1
	mv $(BUILD_DIR)/$(POSTFIX_DIR) $(@D)
	sed -i -e 's/SYSLIBS="-ldb"/SYSLIBS="-ldb-$(LIBDB_LIB_VERSION)"/' $(@D)/makedefs
	sed -i -e '/^#if (DB_VERSION_MAJOR == 4/s/$$/ || (DB_VERSION_MAJOR > 4)/' $(@D)/src/util/dict_db.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) makefiles \
		CCARGS=' \
			-DDEF_COMMAND_DIR=\"$(TARGET_PREFIX)/sbin\" \
			-DDEF_CONFIG_DIR=\"$(TARGET_PREFIX)/etc/postfix\" \
			-DDEF_DAEMON_DIR=\"$(TARGET_PREFIX)/libexec/postfix\" \
			-DDEF_MAILQ_PATH=\"$(TARGET_PREFIX)/bin/mailq\" \
			-DDEF_HTML_DIR=\"$(TARGET_PREFIX)/share/doc/postfix/html\" \
			-DDEF_MANPAGE_DIR=\"$(TARGET_PREFIX)/man\" \
			-DDEF_NEWALIAS_PATH=\"$(TARGET_PREFIX)/bin/newaliases\" \
			-DDEF_QUEUE_DIR=\"$(TARGET_PREFIX)/var/spool/postfix\" \
			-DDEF_README_DIR=\"$(TARGET_PREFIX)/share/doc/postfix/readme\" \
			-DDEF_SENDMAIL_PATH=\"$(TARGET_PREFIX)/sbin/sendmail\" \
			-DHAS_PCRE \
			-DUSE_CYRUS_SASL \
			-DUSE_SASL_AUTH \
			-DUSE_TLS \
			$(STAGING_CPPFLAGS) $(POSTFIX_CPPFLAGS) \
			' \
		AUXLIBS="$(STAGING_LDFLAGS) $(POSTFIX_LDFLAGS)" \
	)
	touch $@

postfix-unpack: $(POSTFIX_BUILD_DIR)/.configured

$(POSTFIX_BUILD_DIR)/.built: $(POSTFIX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	(cd $(@D); \
		sed -i 's|fmt|$(TARGET_PREFIX)/bin/fmt|g' postfix-install; \
		sed -i 's|cmp|$(TARGET_PREFIX)/bin/cmp|g' postfix-install; \
		rm -f conf/LICENSE; \
		cp LICENSE conf/; \
		rm -f README_FILES/RELEASE_NOTES; \
		cp RELEASE_NOTES README_FILES/; \
		cd html; \
		rm -f defer.8.html; \
		cp bounce.8.html defer.8.html; \
		rm -f mailq.1.html; \
		cp sendmail.1.html mailq.1.html; \
		rm -f newaliases.1.html; \
		cp sendmail.1.html newaliases.1.html; \
		rm -f trace.8.html; \
		cp bounce.8.html trace.8.html; \
	)
	touch $@

postfix: $(POSTFIX_BUILD_DIR)/.built

$(POSTFIX_BUILD_DIR)/.staged: $(POSTFIX_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	echo "Warning: the makefile target 'postfix-stage' is not available."
	touch $@

postfix-stage: $(POSTFIX_BUILD_DIR)/.staged

$(POSTFIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: postfix" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POSTFIX_PRIORITY)" >>$@
	@echo "Section: $(POSTFIX_SECTION)" >>$@
	@echo "Version: $(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POSTFIX_MAINTAINER)" >>$@
	@echo "Source: $(POSTFIX_SITE)/$(POSTFIX_SOURCE)" >>$@
	@echo "Description: $(POSTFIX_DESCRIPTION)" >>$@
	@echo "Depends: $(POSTFIX_DEPENDS)" >>$@
	@echo "Suggests: postfix-doc, $(POSTFIX_SUGGESTS)" >>$@
	@echo "Conflicts: $(POSTFIX_CONFLICTS)" >>$@

$(POSTFIX_DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: postfix-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(POSTFIX_PRIORITY)" >>$@
	@echo "Section: $(POSTFIX_SECTION)" >>$@
	@echo "Version: $(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(POSTFIX_MAINTAINER)" >>$@
	@echo "Source: $(POSTFIX_SITE)/$(POSTFIX_SOURCE)" >>$@
	@echo "Description: $(POSTFIX_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: man" >>$@
	@echo "Conflicts: " >>$@

$(POSTFIX_IPK): $(POSTFIX_BUILD_DIR)/.built
	rm -rf $(POSTFIX_IPK_DIR) $(BUILD_DIR)/postfix_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(POSTFIX_BUILD_DIR) install_root=$(POSTFIX_IPK_DIR) \
					daemon_directory=$(TARGET_PREFIX)/libexec/postfix \
					command_directory=$(TARGET_PREFIX)/sbin \
					queue_directory=$(TARGET_PREFIX)/var/spool/postfix \
					mail_owner=mail \
					setgid_group=maildrop \
					sendmail_path=$(TARGET_PREFIX)/sbin/sendmail \
					mailq_path=$(TARGET_PREFIX)/bin/mailq \
					newaliases_path=$(TARGET_PREFIX)/bin/newaliases \
					html_directory=$(TARGET_PREFIX)/share/doc/postfix/html \
					manpage_directory=$(TARGET_PREFIX)/man \
					sample_directory= \
					readme_directory=$(TARGET_PREFIX)/share/doc/postfix/readme \
					upgrade
	/bin/sed -i 's|\(\bPATH=\)|\1$(TARGET_PREFIX)/bin:$(TARGET_PREFIX)/sbin:|g' $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/postfix/post-install
	$(INSTALL) -m 600 $(POSTFIX_SOURCE_DIR)/aliases $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/aliases
	$(INSTALL) -m 644 $(POSTFIX_SOURCE_DIR)/main.cf $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/postfix/main.cf
ifeq (${OPTWARE_TARGET}, vt4)
	sed -i -e 's/mail_owner = mail/mail_owner = admin/' $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/postfix/main.cf
endif
	$(INSTALL) -m 644 $(POSTFIX_SOURCE_DIR)/master.cf $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/postfix/master.cf
	$(INSTALL) -d $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/lib/sasl2
	$(INSTALL) -m 644 $(POSTFIX_SOURCE_DIR)/smtpd.conf $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/lib/sasl2/smtpd.conf
	$(INSTALL) -d $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(POSTFIX_SOURCE_DIR)/rc.postfix $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S69postfix
	(cd $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d; \
		ln -s S69postfix K31postfix \
	)
	$(STRIP_COMMAND) $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/sbin/*
	$(STRIP_COMMAND) $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/libexec/postfix/*

	# Split into the different packages
	rm -rf $(POSTFIX_DOC_IPK_DIR)
	$(INSTALL) -d $(POSTFIX_DOC_IPK_DIR)$(TARGET_PREFIX)
	mv $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/man $(POSTFIX_DOC_IPK_DIR)$(TARGET_PREFIX)
	mv $(POSTFIX_IPK_DIR)$(TARGET_PREFIX)/share $(POSTFIX_DOC_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(POSTFIX_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_DOC_IPK_DIR)

	$(MAKE) $(POSTFIX_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(POSTFIX_SOURCE_DIR)/postinst $(POSTFIX_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(POSTFIX_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 644 $(POSTFIX_SOURCE_DIR)/prerm $(POSTFIX_IPK_DIR)/CONTROL/prerm
	echo $(POSTFIX_CONFFILES) | sed -e 's/ /\n/g' > $(POSTFIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(POSTFIX_IPK_DIR)

postfix-ipk: $(POSTFIX_IPK)

postfix-clean:
	-$(MAKE) -C $(POSTFIX_BUILD_DIR) tidy

postfix-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR) $(POSTFIX_IPK_DIR) $(POSTFIX_IPK)
	rm -rf $(POSTFIX_DOC_IPK_DIR) $(POSTFIX_DOC_IPK)

postfix-check: $(POSTFIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POSTFIX_IPK)
