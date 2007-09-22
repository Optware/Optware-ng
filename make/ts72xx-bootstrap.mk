###########################################################
#
# ts72xx-bootstrap
#
# Creates an ipk for bootstrapping the Freecom TS72XX. Also
# includes missing GLIBC libraries
#
###########################################################

TS72XX_GLIBC_VERSION=2.3.2
TS72XX_BOOTSTRAP_VERSION=0.1
TS72XX_BOOTSTRAP_DIR=ts72xx-bootstrap-$(TS72XX_BOOTSTRAP_VERSION)
TS72XX_BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TS72XX_BOOTSTRAP_DESCRIPTION=Bootstrap package for the Technologic TS-72xx (family)
TS72XX_BOOTSTRAP_SECTION=util
TS72XX_BOOTSTRAP_PRIORITY=optional
TS72XX_BOOTSTRAP_DEPENDS=
TS72XX_BOOTSTRAP_CONFLICTS=

TS72XX_BOOTSTRAP_IPK_VERSION=0

TS72XX_BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/ts72xx-bootstrap
TS72XX_BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/ts72xx-bootstrap
TS72XX_BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/ts72xx-bootstrap-$(TS72XX_BOOTSTRAP_VERSION)-ipk
TS72XX_BOOTSTRAP_IPK=$(BUILD_DIR)/ts72xx-bootstrap_$(TS72XX_BOOTSTRAP_VERSION)-$(TS72XX_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
TS72XX_BOOTSTRAP_XSH=$(BUILD_DIR)/ts72xx-bootstrap_$(TS72XX_BOOTSTRAP_VERSION)-$(TS72XX_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).xsh

$(TS72XX_BOOTSTRAP_BUILD_DIR)/.configured: $(TS72XX_BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(TS72XX_BOOTSTRAP_DIR) $(TS72XX_BOOTSTRAP_BUILD_DIR)
	mkdir -p $(TS72XX_BOOTSTRAP_BUILD_DIR)
	touch $@

ts72xx-bootstrap-unpack: $(TS72XX_BOOTSTRAP_BUILD_DIR)/.configured

$(TS72XX_BOOTSTRAP_BUILD_DIR)/.built: $(TS72XX_BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $(TS72XX_BOOTSTRAP_BUILD_DIR)/.built
	cp -R $(TARGET_LIBDIR)/* $(TS72XX_BOOTSTRAP_BUILD_DIR)/
	find $(TS72XX_BOOTSTRAP_BUILD_DIR)/ -type l |xargs rm
	rm $(TS72XX_BOOTSTRAP_BUILD_DIR)/libc.so
	cp $(TARGET_LIBDIR)/../sbin/ldconfig $(TS72XX_BOOTSTRAP_BUILD_DIR)/
	cp $(IPKG-OPT_SOURCE_DIR)/rc.optware $(TS72XX_BOOTSTRAP_BUILD_DIR)/
	touch $@

ts72xx-bootstrap: $(TS72XX_BOOTSTRAP_BUILD_DIR)/.built

$(TS72XX_BOOTSTRAP_BUILD_DIR)/.staged: $(TS72XX_BOOTSTRAP_BUILD_DIR)/.built
	rm -f $@
	install -d $(STAGING_DIR)/opt/lib
	install -d $(STAGING_DIR)/opt/sbin
	install -d $(STAGING_DIR)/opt/etc
	install -d $(STAGING_DIR)/writeable/lib
	install -d $(STAGING_DIR)/opt/lib/gconv
	install -d $(STAGING_DIR)/opt/lib/ldscripts
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/*crt* $(STAGING_DIR)/opt/lib
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/lib* $(STAGING_DIR)/opt/lib
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/gconv/* $(STAGING_DIR)/opt/lib/gconv
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(STAGING_DIR)/opt/lib/ldscripts	
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/ldconfig $(STAGING_DIR)/opt/sbin
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/rc.optware $(STAGING_DIR)/opt/etc
	touch $@

ts72xx-bootstrap-stage: $(TS72XX_BOOTSTRAP_BUILD_DIR)/.staged

$(TS72XX_BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ts72xx-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TS72XX_BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(TS72XX_BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(TS72XX_BOOTSTRAP_VERSION)-$(TS72XX_BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TS72XX_BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(TS72XX_BOOTSTRAP_SITE)/$(TS72XX_BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(TS72XX_BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(TS72XX_BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(TS72XX_BOOTSTRAP_CONFLICTS)" >>$@

$(TS72XX_BOOTSTRAP_IPK): $(TS72XX_BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(TS72XX_BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/ts72xx-bootstrap_*_$(TARGET_ARCH).ipk
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/sbin
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/etc
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/writeable/lib
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/gconv
	install -d $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/*crt* $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/lib* $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/
	rm -f $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/libpthread.so
	rm -f $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/lib*.a
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/gconv/* $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/gconv/
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts/
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/ldconfig $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/sbin
	install -m 755 $(TS72XX_BOOTSTRAP_BUILD_DIR)/rc.optware $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/etc

	$(STRIP_COMMAND) $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/*.so
	$(STRIP_COMMAND) $(TS72XX_BOOTSTRAP_IPK_DIR)/opt/lib/*.so.*
	$(MAKE) $(TS72XX_BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(TS72XX_BOOTSTRAP_SOURCE_DIR)/preinst $(TS72XX_BOOTSTRAP_IPK_DIR)/CONTROL/preinst
	install -m 644 $(TS72XX_BOOTSTRAP_SOURCE_DIR)/postinst $(TS72XX_BOOTSTRAP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TS72XX_BOOTSTRAP_IPK_DIR)

$(TS72XX_BOOTSTRAP_XSH): $(TS72XX_BOOTSTRAP_IPK) \
		$(BUILD_DIR)/ipkg-opt/.ipk $(BUILD_DIR)/openssl/.ipk $(BUILD_DIR)/wget-ssl/.ipk
	rm -rf $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap
	mkdir -p $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(TS72XX_BOOTSTRAP_IPK) $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.ipk
	# Additional ipk's we require
	cp $(IPKG-OPT_IPK) $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap/ipkg.ipk
	cp $(OPENSSL_IPK) $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap/openssl.ipk
	cp $(WGET-SSL_IPK) $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap/wget-ssl.ipk
	# bootstrap scripts
	cp $(TS72XX_BOOTSTRAP_SOURCE_DIR)/bootstrap.sh $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(TS72XX_BOOTSTRAP_SOURCE_DIR)/ipkg.sh $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap

	# If you should ever change the archive header (echo lines below), 
	# make sure to recalculate dd's bs= argument, otherwise the self-
	# extracting archive will break! Using tail+n would be much simpler
	# but the tail command available on the TS72XX doesn't support this.
	echo "#!/bin/sh" >$@
	echo 'echo "TS72XX Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=181 skip=1| tar xvz' >>$@
	echo "cd bootstrap && sh bootstrap.sh && cd .. && rm -r bootstrap" >>$@
	echo 'exec /bin/sh --login' >>$@
	tar -C $(TS72XX_BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@

ts72xx-bootstrap-ipk: $(TS72XX_BOOTSTRAP_IPK)

ts72xx-bootstrap-xsh: $(TS72XX_BOOTSTRAP_XSH)

ts72xx-bootstrap-clean:
	rm -rf $(TS72XX_BOOTSTRAP_BUILD_DIR)/*

ts72xx-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(TS72XX_BOOTSTRAP_DIR) $(TS72XX_BOOTSTRAP_BUILD_DIR) $(TS72XX_BOOTSTRAP_IPK_DIR) $(TS72XX_BOOTSTRAP_IPK) $(TS72XX_BOOTSTRAP_XSH)
	rm -rf $(TS72XX_BOOTSTRAP_BUILD_DIR)/bootstrap
