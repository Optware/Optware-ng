###########################################################
#
# optware-bootstrap
#
# Creates an ipk for optware-bootstrapping optware.
#
###########################################################

OPTWARE-BOOTSTRAP_VERSION=1.0
OPTWARE-BOOTSTRAP_DIR=optware-bootstrap-$(OPTWARE-BOOTSTRAP_VERSION)
OPTWARE-BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPTWARE-BOOTSTRAP_DESCRIPTION=Optware bootstrap package for $(OPTWARE_TARGET)
OPTWARE-BOOTSTRAP_SECTION=util
OPTWARE-BOOTSTRAP_PRIORITY=optional
OPTWARE-BOOTSTRAP_DEPENDS=
OPTWARE-BOOTSTRAP_CONFLICTS=

OPTWARE-BOOTSTRAP_IPK_VERSION=1

OPTWARE-BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/optware-bootstrap
OPTWARE-BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/optware-bootstrap
OPTWARE-BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/optware-bootstrap-$(OPTWARE-BOOTSTRAP_VERSION)-ipk
OPTWARE-BOOTSTRAP_IPK=$(BUILD_DIR)/optware-bootstrap_$(OPTWARE-BOOTSTRAP_VERSION)-$(OPTWARE-BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
OPTWARE-BOOTSTRAP_XSH=$(BUILD_DIR)/optware-bootstrap_$(OPTWARE-BOOTSTRAP_VERSION)-$(OPTWARE-BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).xsh

OPTWARE-BOOTSTRAP_REAL_OPT_DIR=$(strip \
	$(if $(filter ds101 ds101g, $(OPTWARE_TARGET)), /volume1/opt, \
	$(if $(filter fsg3 fsg3v4, $(OPTWARE_TARGET)), /home/.optware, \
	$(if $(filter mssii, $(OPTWARE_TARGET)), /share/opt, \
	))))


$(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured: $(OPTWARE-BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_DIR) $(OPTWARE-BOOTSTRAP_BUILD_DIR)
	mkdir -p $(OPTWARE-BOOTSTRAP_BUILD_DIR)
	touch $@

optware-bootstrap-unpack: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured

$(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $@
#	cp -a $(TARGET_LIBDIR)/* $(OPTWARE-BOOTSTRAP_BUILD_DIR)/
#	find $(OPTWARE-BOOTSTRAP_BUILD_DIR)/ -type l | xargs rm -f
#	rm $(OPTWARE-BOOTSTRAP_BUILD_DIR)/libc.so*
	touch $@

optware-bootstrap: $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built

optware-bootstrap-stage:

$(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: optware-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPTWARE-BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(OPTWARE-BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(OPTWARE-BOOTSTRAP_VERSION)-$(OPTWARE-BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPTWARE-BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(OPTWARE-BOOTSTRAP_SITE)/$(OPTWARE-BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(OPTWARE-BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(OPTWARE-BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(OPTWARE-BOOTSTRAP_CONFLICTS)" >>$@

$(OPTWARE-BOOTSTRAP_IPK): $(OPTWARE-BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(OPTWARE-BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/optware-bootstrap_*_$(TARGET_ARCH).ipk
	install -d -m 755 \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/lib \
		$(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/var
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/var/lib
	install -d $(OPTWARE-BOOTSTRAP_IPK_DIR)/etc/init.d
	install -d -m 1755 $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/tmp
	install -m 755 $(IPKG-OPT_SOURCE_DIR)/rc.optware $(OPTWARE-BOOTSTRAP_IPK_DIR)/opt/etc/
	install -m 755 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/optware $(OPTWARE-BOOTSTRAP_IPK_DIR)/etc/init.d/
	$(MAKE) $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/preinst $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/
ifneq (OPTWARE-BOOTSTRAP_REAL_OPT_DIR,)
	sed -i -e '/^REAL_OPT_DIR=$$/s|$$|$(OPTWARE-BOOTSTRAP_REAL_OPT_DIR)|' $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/preinst
endif
	install -m 644 $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/postinst $(OPTWARE-BOOTSTRAP_IPK_DIR)/CONTROL/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPTWARE-BOOTSTRAP_IPK_DIR)

$(OPTWARE-BOOTSTRAP_XSH): $(OPTWARE-BOOTSTRAP_IPK) \
	    $(BUILD_DIR)/ipkg-opt/.ipk $(BUILD_DIR)/openssl/.ipk $(BUILD_DIR)/wget-ssl/.ipk
	rm -rf $(BUILD_DIR)/optware-bootstrap_*_$(TARGET_ARCH).xsh
	rm -rf $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	install -d $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(OPTWARE-BOOTSTRAP_IPK) $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/optware-bootstrap.ipk
	# Additional ipk's we require
	cp $(IPKG-OPT_IPK) $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/ipkg.ipk
	cp $(OPENSSL_IPK) $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/openssl.ipk
	cp $(WGET-SSL_IPK) $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap/wget-ssl.ipk
	# optware-bootstrap scripts
	cp $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/$(OPTWARE_TARGET)/bootstrap.sh $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(OPTWARE-BOOTSTRAP_SOURCE_DIR)/ipkg.sh $(OPTWARE-BOOTSTRAP_BUILD_DIR)/bootstrap
	# NNN is the number of bytes to skip, assuming three digits
	echo "#!/bin/sh" >$@
	echo 'echo "Optware Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=NNN skip=1 | tar xzv' >>$@
	echo "cd bootstrap && sh bootstrap.sh && cd .. && rm -r bootstrap" >>$@
	echo 'exec /bin/sh --login' >>$@
	sed -i -e "s/NNN/`wc -c $@ | awk '{print $$1}'`/" $@
	tar -C $(OPTWARE-BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@

optware-bootstrap-ipk: $(OPTWARE-BOOTSTRAP_XSH)
optware-bootstrap-xsh: $(OPTWARE-BOOTSTRAP_XSH)

optware-bootstrap-clean:
	rm -rf $(OPTWARE-BOOTSTRAP_BUILD_DIR)/*

optware-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(OPTWARE-BOOTSTRAP_DIR) $(OPTWARE-BOOTSTRAP_BUILD_DIR) $(OPTWARE-BOOTSTRAP_IPK_DIR) $(OPTWARE-BOOTSTRAP_IPK) $(OPTWARE-BOOTSTRAP_XSH)
	rm -rf $(OPTWARE-BOOTSTRAP_BUILD_DIR)/optware-bootstrap
