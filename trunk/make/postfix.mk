###########################################################
#
# postfix
#
###########################################################

# If you want to cross compile postfix you have to install
# some additional software. E.g. for Debian testing this 
# is libdb4.2, libdb4.2-dev, libpcre3, libpcre3-dev

POSTFIX_SITE=ftp://netmirror.org/postfix.org/official
POSTFIX_VERSION=2.3.6
POSTFIX_SOURCE=postfix-$(POSTFIX_VERSION).tar.gz
POSTFIX_DIR=postfix-$(POSTFIX_VERSION)
POSTFIX_UNZIP=zcat
POSTFIX_MAINTAINER=Matthias Appel <private_tweety@gmx.net>
POSTFIX_DESCRIPTION=The Postfix mail system is an alternative to sendmail.
POSTFIX_SECTION=util
POSTFIX_PRIORITY=optional
POSTFIX_DEPENDS=libdb, libnsl, pcre, cyrus-sasl, findutils
POSTFIX_SUGGESTS=cyrus-imapd
POSTFIX_CONFLICTS=xmail

POSTFIX_IPK_VERSION=1

POSTFIX_CONFFILES=/opt/etc/aliases \
		  /opt/etc/postfix/main.cf \
		  /opt/etc/postfix/master.cf \
		  /opt/lib/sasl2/smtpd.conf \
		  /opt/etc/init.d/S69postfix

POSTFIX_PATCHES=$(POSTFIX_SOURCE_DIR)/postfix.patch \
		$(POSTFIX_SOURCE_DIR)/postfix-install.patch \
		$(POSTFIX_SOURCE_DIR)/postfix-script.patch \
		$(POSTFIX_SOURCE_DIR)/sys_defs.h.patch

POSTFIX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/sasl
POSTFIX_LDFLAGS=-lpcre -lnsl -lsasl2 -ldl

POSTFIX_BUILD_DIR=$(BUILD_DIR)/postfix
POSTFIX_SOURCE_DIR=$(SOURCE_DIR)/postfix
POSTFIX_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk
POSTFIX_IPK=$(BUILD_DIR)/postfix_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_$(TARGET_ARCH).ipk
POSTFIX_DOC_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk-doc
POSTFIX_DOC_IPK=$(BUILD_DIR)/postfix-doc_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: postfix-source postfix-unpack postfix postfix-stage postfix-ipk postfix-clean postfix-dirclean postfix-check

$(DL_DIR)/$(POSTFIX_SOURCE):
	$(WGET) -P $(DL_DIR) $(POSTFIX_SITE)/$(POSTFIX_SOURCE)

postfix-source: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES)

$(POSTFIX_BUILD_DIR)/.configured: $(DL_DIR)/$(POSTFIX_SOURCE) $(POSTFIX_PATCHES)
	$(MAKE) libdb-stage libnsl-stage pcre-stage cyrus-sasl-stage
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR)
	$(POSTFIX_UNZIP) $(DL_DIR)/$(POSTFIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(POSTFIX_PATCHES) | patch -d $(BUILD_DIR)/$(POSTFIX_DIR) -p1
	mv $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR)
	(cd $(POSTFIX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		$(MAKE) makefiles \
		CCARGS=' \
			-DDEF_COMMAND_DIR=\"/opt/sbin\" \
			-DDEF_CONFIG_DIR=\"/opt/etc/postfix\" \
			-DDEF_DAEMON_DIR=\"/opt/libexec/postfix\" \
			-DDEF_MAILQ_PATH=\"/opt/bin/mailq\" \
			-DDEF_HTML_DIR=\"/opt/share/doc/postfix/html\" \
			-DDEF_MANPAGE_DIR=\"/opt/man\" \
			-DDEF_NEWALIAS_PATH=\"/opt/bin/newaliases\" \
			-DDEF_QUEUE_DIR=\"/opt/var/spool/postfix\" \
			-DDEF_README_DIR=\"/opt/share/doc/postfix/readme\" \
			-DDEF_SENDMAIL_PATH=\"/opt/sbin/sendmail\" \
			-DHAS_PCRE \
			-DUSE_CYRUS_SASL \
			-DUSE_SASL_AUTH \
			$(STAGING_CPPFLAGS) $(POSTFIX_CPPFLAGS) \
			' \
		AUXLIBS="$(STAGING_LDFLAGS) $(POSTFIX_LDFLAGS)" \
	)
	touch $(POSTFIX_BUILD_DIR)/.configured

postfix-unpack: $(POSTFIX_BUILD_DIR)/.configured

$(POSTFIX_BUILD_DIR)/.built: $(POSTFIX_BUILD_DIR)/.configured
	rm -f $(POSTFIX_BUILD_DIR)/.built
	$(MAKE) -C $(POSTFIX_BUILD_DIR)
	(cd $(POSTFIX_BUILD_DIR); \
		sed -i 's/fmt/\/opt\/bin\/fmt/g' postfix-install; \
		sed -i 's/cmp/\/opt\/bin\/cmp/g' postfix-install; \
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
	touch $(POSTFIX_BUILD_DIR)/.built

postfix: $(POSTFIX_BUILD_DIR)/.built

$(POSTFIX_BUILD_DIR)/.staged: $(POSTFIX_BUILD_DIR)/.built
	rm -f $(POSTFIX_BUILD_DIR)/.staged
#	$(MAKE) -C $(POSTFIX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	echo "Warning: the makefile target 'postfix-stage' is not available."
	touch $(POSTFIX_BUILD_DIR)/.staged

postfix-stage: $(POSTFIX_BUILD_DIR)/.staged

$(POSTFIX_IPK_DIR)/CONTROL/control:
	@install -d $(POSTFIX_IPK_DIR)/CONTROL
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
	@install -d $(POSTFIX_DOC_IPK_DIR)/CONTROL
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
					daemon_directory=/opt/libexec/postfix \
					command_directory=/opt/sbin \
					queue_directory=/opt/var/spool/postfix \
					mail_owner=mail \
					setgid_group=maildrop \
					sendmail_path=/opt/sbin/sendmail \
					mailq_path=/opt/bin/mailq \
					newaliases_path=/opt/bin/newaliases \
					html_directory=/opt/share/doc/postfix/html \
					manpage_directory=/opt/man \
					sample_directory= \
					readme_directory=/opt/share/doc/postfix/readme \
					upgrade
	/bin/sed -i 's/\(\bPATH=\)/\1\/opt\/bin:\/opt\/sbin:/g' $(POSTFIX_IPK_DIR)/opt/etc/postfix/post-install
	install -m 600 $(POSTFIX_SOURCE_DIR)/aliases $(POSTFIX_IPK_DIR)/opt/etc/aliases
	install -m 644 $(POSTFIX_SOURCE_DIR)/main.cf $(POSTFIX_IPK_DIR)/opt/etc/postfix/main.cf
	install -m 644 $(POSTFIX_SOURCE_DIR)/master.cf $(POSTFIX_IPK_DIR)/opt/etc/postfix/master.cf
	install -d $(POSTFIX_IPK_DIR)/opt/lib/sasl2
	install -m 644 $(POSTFIX_SOURCE_DIR)/smtpd.conf $(POSTFIX_IPK_DIR)/opt/lib/sasl2/smtpd.conf
	install -d $(POSTFIX_IPK_DIR)/opt/etc/init.d
	install -m 755 $(POSTFIX_SOURCE_DIR)/rc.postfix $(POSTFIX_IPK_DIR)/opt/etc/init.d/S69postfix
	(cd $(POSTFIX_IPK_DIR)/opt/etc/init.d; \
		ln -s S69postfix K31postfix \
	)
	$(STRIP_COMMAND) $(POSTFIX_IPK_DIR)/opt/sbin/*
	$(STRIP_COMMAND) $(POSTFIX_IPK_DIR)/opt/libexec/postfix/*

	# Split into the different packages
	rm -rf $(POSTFIX_DOC_IPK_DIR)
	install -d $(POSTFIX_DOC_IPK_DIR)/opt
	mv $(POSTFIX_IPK_DIR)/opt/man $(POSTFIX_DOC_IPK_DIR)/opt
	mv $(POSTFIX_IPK_DIR)/opt/share $(POSTFIX_DOC_IPK_DIR)/opt
	$(MAKE) $(POSTFIX_DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_DOC_IPK_DIR)

	$(MAKE) $(POSTFIX_IPK_DIR)/CONTROL/control
	install -m 644 $(POSTFIX_SOURCE_DIR)/postinst $(POSTFIX_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(POSTFIX_SOURCE_DIR)/prerm $(POSTFIX_IPK_DIR)/CONTROL/prerm
	echo $(POSTFIX_CONFFILES) | sed -e 's/ /\n/g' > $(POSTFIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_IPK_DIR)

postfix-ipk: $(POSTFIX_IPK)

postfix-clean:
	-$(MAKE) -C $(POSTFIX_BUILD_DIR) tidy

postfix-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR) $(POSTFIX_IPK_DIR) $(POSTFIX_IPK)
	rm -rf $(POSTFIX_DOC_IPK_DIR) $(POSTFIX_DOC_IPK)
#
#
# Some sanity check for the package.
#
#
postfix-check: $(POSTFIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(POSTFIX_IPK)
