###########################################################
#
# postfix
#
###########################################################

POSTFIX_SITE=ftp://netmirror.org/postfix.org/official
POSTFIX_VERSION=2.1.5
POSTFIX_SOURCE=postfix-$(POSTFIX_VERSION).tar.gz
POSTFIX_DIR=postfix-$(POSTFIX_VERSION)
POSTFIX_UNZIP=zcat

POSTFIX_IPK_VERSION=1

#POSTFIX_CONFFILES=/opt/etc/postfix.conf /opt/etc/init.d/SXXpostfix
POSTFIX_CONFFILES=

POSTFIX_PATCHES=$(POSTFIX_SOURCE_DIR)/postfix.patch

POSTFIX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/sasl
POSTFIX_LDFLAGS=-lpcre -lnsl -lsasl2

POSTFIX_BUILD_DIR=$(BUILD_DIR)/postfix
POSTFIX_SOURCE_DIR=$(SOURCE_DIR)/postfix
POSTFIX_IPK_DIR=$(BUILD_DIR)/postfix-$(POSTFIX_VERSION)-ipk
POSTFIX_IPK=$(BUILD_DIR)/postfix_$(POSTFIX_VERSION)-$(POSTFIX_IPK_VERSION)_armeb.ipk

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
	echo "The makefile target 'postfix-stage' is not available."
	touch $(POSTFIX_BUILD_DIR)/.staged

postfix-stage: $(POSTFIX_BUILD_DIR)/.staged

$(POSTFIX_IPK): $(POSTFIX_BUILD_DIR)/.built
	rm -rf $(POSTFIX_IPK_DIR) $(BUILD_DIR)/postfix_*_armeb.ipk
	$(MAKE) -C $(POSTFIX_BUILD_DIR) install_root=$(POSTFIX_IPK_DIR) mail_owner=mail setgid_group=maildrop upgrade
	/bin/sed -i 's/\(\bPATH=\)/\1\/opt\/bin:\/opt\/sbin:/g' $(POSTFIX_IPK_DIR)/opt/etc/postfix/post-install
	install -m 600 $(POSTFIX_SOURCE_DIR)/aliases $(POSTFIX_IPK_DIR)/opt/etc/aliases
	install -m 644 $(POSTFIX_SOURCE_DIR)/main.cf $(POSTFIX_IPK_DIR)/opt/etc/postfix/main.cf
	install -m 644 $(POSTFIX_SOURCE_DIR)/master.cf $(POSTFIX_IPK_DIR)/opt/etc/postfix/master.cf
	install -d $(POSTFIX_IPK_DIR)/opt/lib/sasl2
	install -m 644 $(POSTFIX_SOURCE_DIR)/smtpd.conf $(POSTFIX_IPK_DIR)/opt/lib/sasl2/smtpd.conf
	install -d $(POSTFIX_IPK_DIR)/opt/etc/init.d
	install -m 755 $(POSTFIX_SOURCE_DIR)/rc.postfix $(POSTFIX_IPK_DIR)/opt/etc/init.d/S69postfix

# Split into the different packages
	rm -rf $(POSTFIX_IPK_DIR)-doc
	install -d $(POSTFIX_IPK_DIR)-doc/opt
	mv $(POSTFIX_IPK_DIR)/opt/man $(POSTFIX_IPK_DIR)-doc/opt
	mv $(POSTFIX_IPK_DIR)/opt/share $(POSTFIX_IPK_DIR)-doc/opt
	install -d $(POSTFIX_IPK_DIR)-doc/CONTROL
	install -m 644 $(POSTFIX_SOURCE_DIR)/control-doc $(POSTFIX_IPK_DIR)-doc/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_IPK_DIR)-doc

	install -d $(POSTFIX_IPK_DIR)/CONTROL
	install -m 644 $(POSTFIX_SOURCE_DIR)/control $(POSTFIX_IPK_DIR)/CONTROL/control
	install -m 644 $(POSTFIX_SOURCE_DIR)/postinst $(POSTFIX_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(POSTFIX_SOURCE_DIR)/prerm $(POSTFIX_IPK_DIR)/CONTROL/prerm
	echo $(POSTFIX_CONFFILES) | sed -e 's/ /\n/g' > $(POSTFIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(POSTFIX_IPK_DIR)

postfix-ipk: $(POSTFIX_IPK)

postfix-clean:
	-$(MAKE) -C $(POSTFIX_BUILD_DIR) tidy

postfix-dirclean:
	rm -rf $(BUILD_DIR)/$(POSTFIX_DIR) $(POSTFIX_BUILD_DIR) $(POSTFIX_IPK_DIR) $(POSTFIX_IPK)
