###########################################################
#
# fsg3-bootstrap
#
# Creates an ipk for bootstrapping the Freecom FSG-3. Also
# includes missing GLIBC libraries
#
###########################################################

FSG3_GLIBC_VERSION=2.2.5
FSG3_BOOTSTRAP_VERSION=1.0
FSG3_BOOTSTRAP_DIR=fsg3-bootstrap-$(FSG3_BOOTSTRAP_VERSION)
FSG3_BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FSG3_BOOTSTRAP_DESCRIPTION=Bootstrap package for the Freecom FSG-3
FSG3_BOOTSTRAP_SECTION=util
FSG3_BOOTSTRAP_PRIORITY=optional
FSG3_BOOTSTRAP_DEPENDS=
FSG3_BOOTSTRAP_CONFLICTS=

FSG3_BOOTSTRAP_IPK_VERSION=6

FSG3_BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/fsg3-bootstrap
FSG3_BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/fsg3-bootstrap
FSG3_BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/fsg3-bootstrap-$(FSG3_BOOTSTRAP_VERSION)-ipk
FSG3_BOOTSTRAP_IPK=$(BUILD_DIR)/fsg3-bootstrap_$(FSG3_BOOTSTRAP_VERSION)-$(FSG3_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
FSG3_BOOTSTRAP_XSH=$(BUILD_DIR)/fsg3-bootstrap_$(FSG3_BOOTSTRAP_VERSION)-$(FSG3_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).xsh

# Additional ipk's we require
FSG3_IPKG_IPK=$(IPKG-OPT_IPK)
FSG3_OPENSSL_IPK=openssl_0.9.7?-?_$(TARGET_ARCH).ipk
FSG3_WGET_SSL_IPK=wget-ssl_1.10.2-?_$(TARGET_ARCH).ipk


$(FSG3_BOOTSTRAP_BUILD_DIR)/.configured: $(FSG3_BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(FSG3_BOOTSTRAP_DIR) $(FSG3_BOOTSTRAP_BUILD_DIR)
	mkdir -p $(FSG3_BOOTSTRAP_BUILD_DIR)
	touch $@

fsg3-bootstrap-unpack: $(FSG3_BOOTSTRAP_BUILD_DIR)/.configured

$(FSG3_BOOTSTRAP_BUILD_DIR)/.built: $(FSG3_BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $@
	cp -a $(TARGET_LIBDIR)/* $(FSG3_BOOTSTRAP_BUILD_DIR)/
#	find $(FSG3_BOOTSTRAP_BUILD_DIR)/ -type l | xargs rm -f
	rm $(FSG3_BOOTSTRAP_BUILD_DIR)/libc.so*
	touch $@

fsg3-bootstrap: $(FSG3_BOOTSTRAP_BUILD_DIR)/.built

fsg3-bootstrap-stage:

$(FSG3_BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fsg3-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FSG3_BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(FSG3_BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(FSG3_BOOTSTRAP_VERSION)-$(FSG3_BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FSG3_BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(FSG3_BOOTSTRAP_SITE)/$(FSG3_BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(FSG3_BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(FSG3_BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(FSG3_BOOTSTRAP_CONFLICTS)" >>$@

$(FSG3_BOOTSTRAP_IPK): $(FSG3_BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(FSG3_BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/fsg3-bootstrap_*_$(TARGET_ARCH).ipk
	install -d $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib
	install -m 755 $(FSG3_BOOTSTRAP_BUILD_DIR)/*.so* $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/
	install -m 644 $(FSG3_BOOTSTRAP_BUILD_DIR)/*.a $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/
	install -m 644 $(FSG3_BOOTSTRAP_BUILD_DIR)/*.o $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/
	install -d $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/gconv
	install -m 755 $(FSG3_BOOTSTRAP_BUILD_DIR)/gconv/*.so $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/gconv/
	install -m 644 $(FSG3_BOOTSTRAP_BUILD_DIR)/gconv/gconv-modules $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/gconv/
	install -d $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts
	install -m 644 $(FSG3_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts/
	cd $(FSG3_BOOTSTRAP_BUILD_DIR) ; cp -P `find . -type l -print` $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/

	install -d $(FSG3_BOOTSTRAP_IPK_DIR)/opt/etc
	install -m 755 $(IPKG-OPT_SOURCE_DIR)/rc.optware $(FSG3_BOOTSTRAP_IPK_DIR)/opt/etc
	install -d $(FSG3_BOOTSTRAP_IPK_DIR)/etc/init.d
	install -m 755 $(FSG3_BOOTSTRAP_SOURCE_DIR)/optware $(FSG3_BOOTSTRAP_IPK_DIR)/etc/init.d/optware

#	$(STRIP_COMMAND) $(FSG3_BOOTSTRAP_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(FSG3_BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(FSG3_BOOTSTRAP_SOURCE_DIR)/preinst $(FSG3_BOOTSTRAP_IPK_DIR)/CONTROL/preinst
	install -m 644 $(FSG3_BOOTSTRAP_SOURCE_DIR)/postinst $(FSG3_BOOTSTRAP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3_BOOTSTRAP_IPK_DIR)

$(FSG3_BOOTSTRAP_XSH): $(FSG3_BOOTSTRAP_IPK) \
	    $(BUILD_DIR)/ipkg-opt/.ipk $(BUILD_DIR)/openssl/.ipk $(BUILD_DIR)/wget-ssl/.ipk
	rm -rf $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap
	mkdir -p $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(FSG3_BOOTSTRAP_IPK) $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.ipk
	cp $(FSG3_IPKG_IPK) $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap/ipkg.ipk
	cp $(BUILD_DIR)/$(FSG3_OPENSSL_IPK) $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap/openssl.ipk
	cp $(BUILD_DIR)/$(FSG3_WGET_SSL_IPK) $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap/wget-ssl.ipk
	cp $(FSG3_BOOTSTRAP_SOURCE_DIR)/bootstrap.sh $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(FSG3_BOOTSTRAP_SOURCE_DIR)/ipkg.sh $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap

	# If you should ever change the archive header (echo lines below), 
	# make sure to recalculate dd's bs= argument, otherwise the self-
	# extracting archive will break! Using tail+n would be much simpler
	# but the tail command available on the FSG-3 doesn't support this.
	echo "#!/bin/sh" >$@
	echo 'echo "FSG-3 Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=180 skip=1| tar xvz' >>$@
	echo "cd bootstrap && sh bootstrap.sh && cd .. && rm -r bootstrap" >>$@
	echo 'exec /bin/sh --login' >>$@
	tar -C $(FSG3_BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@

fsg3-bootstrap-ipk: $(FSG3_BOOTSTRAP_XSH)
fsg3-bootstrap-xsh: $(FSG3_BOOTSTRAP_XSH)

fsg3-bootstrap-clean:
	rm -rf $(FSG3_BOOTSTRAP_BUILD_DIR)/*

fsg3-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(FSG3_BOOTSTRAP_DIR) $(FSG3_BOOTSTRAP_BUILD_DIR) $(FSG3_BOOTSTRAP_IPK_DIR) $(FSG3_BOOTSTRAP_IPK) $(FSG3_BOOTSTRAP_XSH)
	rm -rf $(FSG3_BOOTSTRAP_BUILD_DIR)/bootstrap
