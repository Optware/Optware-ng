###########################################################
#
# webmin
#
###########################################################

WEBMIN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/webadmin
WEBMIN_VERSION=1.300
WEBMIN_SOURCE=webmin-$(WEBMIN_VERSION).tar.gz
WEBMIN_DIR=webmin-$(WEBMIN_VERSION)
WEBMIN_UNZIP=zcat
WEBMIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WEBMIN_DESCRIPTION=A web-based interface for Unix system administration.
WEBMIN_SECTION=util
WEBMIN_PRIORITY=optional
WEBMIN_DEPENDS=perl
WEBMIN_SUGGESTS=
WEBMIN_CONFLICTS=

WEBMIN_IPK_VERSION=1

WEBMIN_CONFFILES=

WEBMIN_BUILD_DIR=$(BUILD_DIR)/webmin
WEBMIN_SOURCE_DIR=$(SOURCE_DIR)/webmin
WEBMIN_IPK_DIR=$(BUILD_DIR)/webmin-$(WEBMIN_VERSION)-ipk
WEBMIN_IPK=$(BUILD_DIR)/webmin_$(WEBMIN_VERSION)-$(WEBMIN_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(WEBMIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(WEBMIN_SITE)/$(WEBMIN_SOURCE)

webmin-source: $(DL_DIR)/$(WEBMIN_SOURCE) $(WEBMIN_PATCHES)

$(WEBMIN_BUILD_DIR)/.configured: $(DL_DIR)/$(WEBMIN_SOURCE) $(WEBMIN_PATCHES)
#	make perl-stage
	rm -rf $(BUILD_DIR)/$(WEBMIN_DIR) $(WEBMIN_BUILD_DIR)
	$(WEBMIN_UNZIP) $(DL_DIR)/$(WEBMIN_SOURCE) | tar -C $(BUILD_DIR) -xf -
	mv $(BUILD_DIR)/$(WEBMIN_DIR) $(WEBMIN_BUILD_DIR)
	(cd $(WEBMIN_BUILD_DIR); \
	find . -name '*.cgi' -o -name '*.pl' | \
		xargs sed -i -e 's|^#! */.*/bin/perl$$|#!/opt/bin/perl|'; \
	rm -rf bsdexports caldera hpuxexports sgiexports; \
	rm -f mount/freebsd-mounts* mount/openbsd-mounts* mount/macos-mounts*; \
	rm -f webmin-gentoo-init webmin-caldera-init; \
	for l in aix cobalt-linux coherent corel-linux debian freebsd \
		gentoo-linux hpux irix lfs-linux macos \
		mandrake-linux msc-linux netbsd openbsd open-linux \
		openserver osf1 osf redhat-linux slackware \
		slackware-linux sol-linux solaris suse-linux \
		trustix turbo-linux united-linux unixware windows; \
	do \
		find . -name "config-$$l*" -o -name "*$$l*-lib.pl" | xargs rm -f || true; \
	done; \
	)
	touch $(WEBMIN_BUILD_DIR)/.configured

webmin-unpack: $(WEBMIN_BUILD_DIR)/.configured

$(WEBMIN_BUILD_DIR)/.built: $(WEBMIN_BUILD_DIR)/.configured
	rm -f $(WEBMIN_BUILD_DIR)/.built
#	$(MAKE) -C $(WEBMIN_BUILD_DIR) $(PERL_INC) all
	touch $(WEBMIN_BUILD_DIR)/.built

webmin: $(WEBMIN_BUILD_DIR)/.built

$(WEBMIN_BUILD_DIR)/.staged: $(WEBMIN_BUILD_DIR)/.built
	rm -f $(WEBMIN_BUILD_DIR)/.staged
#	$(MAKE) -C $(WEBMIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WEBMIN_BUILD_DIR)/.staged

webmin-stage: $(WEBMIN_BUILD_DIR)/.staged

$(WEBMIN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: webmin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WEBMIN_PRIORITY)" >>$@
	@echo "Section: $(WEBMIN_SECTION)" >>$@
	@echo "Version: $(WEBMIN_VERSION)-$(WEBMIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WEBMIN_MAINTAINER)" >>$@
	@echo "Source: $(WEBMIN_SITE)/$(WEBMIN_SOURCE)" >>$@
	@echo "Description: $(WEBMIN_DESCRIPTION)" >>$@
	@echo "Depends: $(WEBMIN_DEPENDS)" >>$@
	@echo "Suggests: $(WEBMIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(WEBMIN_CONFLICTS)" >>$@

$(WEBMIN_IPK): $(WEBMIN_BUILD_DIR)/.built
	rm -rf $(WEBMIN_IPK_DIR) $(BUILD_DIR)/webmin_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(WEBMIN_BUILD_DIR) DESTDIR=$(WEBMIN_IPK_DIR) install
	install -d $(WEBMIN_IPK_DIR)/opt/etc/webmin
	install -d $(WEBMIN_IPK_DIR)/opt/libexec/webmin
	install -d $(WEBMIN_IPK_DIR)/opt/etc/init.d
	install -d $(WEBMIN_IPK_DIR)/opt/etc/pam.d
	for d in acl servers webmin webminlog; \
	do \
		cp -rp $(WEBMIN_BUILD_DIR)/$$d $(WEBMIN_IPK_DIR)/opt/libexec/webmin/; \
	done
	cd $(WEBMIN_IPK_DIR)/opt; \
	for d in \
		at backup-config custom cron fdisk init inittab man mount \
		net pam passwd proc raid shell syslog time useradmin; \
	do \
		cp -rp $(WEBMIN_BUILD_DIR)/$$d libexec/webmin/; \
		for c in libexec/webmin/$$d/config libexec/webmin/$$d/'config-*-linux'; \
		do \
			install -d etc/webmin/$$d/; \
			if test -f $$c; \
				then mv $$c etc/webmin/$$d/config; touch etc/webmin/$$d/admin.acl; fi; \
		done; \
	done
#	install $(WEBMIN_SOURCE_DIR)/webmin.rc $(WEBMIN_IPK_DIR)/opt/etc/init.d/webmin
#	install $(WEBMIN_SOURCE_DIR)/webmin.pam $(WEBMIN_IPK_DIR)/opt/etc/pam.d/webmin
	$(MAKE) $(WEBMIN_IPK_DIR)/CONTROL/control
#	install -m 755 $(WEBMIN_SOURCE_DIR)/postinst $(WEBMIN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=$(OPTWARE_TARGET)' $(WEBMIN_IPK_DIR)/CONTROL/postinst
	echo $(WEBMIN_CONFFILES) | sed -e 's/ /\n/g' > $(WEBMIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WEBMIN_IPK_DIR)

webmin-ipk: $(WEBMIN_IPK)

webmin-clean:
	-$(MAKE) -C $(WEBMIN_BUILD_DIR) clean

webmin-dirclean:
	rm -rf $(BUILD_DIR)/$(WEBMIN_DIR) $(WEBMIN_BUILD_DIR) $(WEBMIN_IPK_DIR) $(WEBMIN_IPK)

webmin-check: $(WEBMIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WEBMIN_IPK)
