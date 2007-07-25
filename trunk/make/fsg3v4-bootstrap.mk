###########################################################
#
# fsg3-bootstrap
#
# Creates an ipk for bootstrapping the Freecom FSG-3. Also
# includes missing GLIBC libraries
#
###########################################################

FSG3V4_GLIBC_VERSION=2.3.5
FSG3V4_BOOTSTRAP_VERSION=2.0
FSG3V4_BOOTSTRAP_DIR=fsg3v4-bootstrap-$(FSG3V4_BOOTSTRAP_VERSION)
FSG3V4_BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FSG3V4_BOOTSTRAP_DESCRIPTION=Bootstrap package for the Freecom FSG-3 with V4 firmware
FSG3V4_BOOTSTRAP_SECTION=util
FSG3V4_BOOTSTRAP_PRIORITY=optional
FSG3V4_BOOTSTRAP_DEPENDS=
FSG3V4_BOOTSTRAP_CONFLICTS=

FSG3V4_BOOTSTRAP_IPK_VERSION=2

FSG3V4_BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/fsg3v4-bootstrap
FSG3V4_BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/fsg3v4-bootstrap
FSG3V4_BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/fsg3v4-bootstrap-$(FSG3V4_BOOTSTRAP_VERSION)-ipk
FSG3V4_BOOTSTRAP_IPK=$(BUILD_DIR)/fsg3v4-bootstrap_$(FSG3V4_BOOTSTRAP_VERSION)-$(FSG3V4_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
FSG3V4_BOOTSTRAP_XSH=$(BUILD_DIR)/fsg3v4-bootstrap_$(FSG3V4_BOOTSTRAP_VERSION)-$(FSG3V4_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).xsh

$(FSG3V4_BOOTSTRAP_BUILD_DIR)/.configured: $(FSG3V4_BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(FSG3V4_BOOTSTRAP_DIR) $(FSG3V4_BOOTSTRAP_BUILD_DIR)
	mkdir -p $(FSG3V4_BOOTSTRAP_BUILD_DIR)
	touch $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.configured

fsg3v4-bootstrap-unpack: $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.configured

$(FSG3V4_BOOTSTRAP_BUILD_DIR)/.built: $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.built
#	cp -a $(TARGET_LIBDIR)/* $(FSG3V4_BOOTSTRAP_BUILD_DIR)/
#	find $(FSG3V4_BOOTSTRAP_BUILD_DIR)/ -type l | xargs rm -f
#	rm $(FSG3V4_BOOTSTRAP_BUILD_DIR)/libc.so*
	touch $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.built

fsg3v4-bootstrap: $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.built

fsg3v4-bootstrap-stage:

$(FSG3V4_BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: fsg3v4-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FSG3V4_BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(FSG3V4_BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(FSG3V4_BOOTSTRAP_VERSION)-$(FSG3V4_BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FSG3V4_BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(FSG3V4_BOOTSTRAP_SITE)/$(FSG3V4_BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(FSG3V4_BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(FSG3V4_BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(FSG3V4_BOOTSTRAP_CONFLICTS)" >>$@

$(FSG3V4_BOOTSTRAP_IPK): $(FSG3V4_BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(FSG3V4_BOOTSTRAP_IPK_DIR)
	rm -f $(BUILD_DIR)/fsg3v4-bootstrap_*_$(TARGET_ARCH).ipk
	rm -f $(BUILD_DIR)/fsg3v4-bootstrap_*_$(TARGET_ARCH).xsh
#	install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib
#	install -m 755 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/*.so* $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/
#	install -m 644 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/*.a $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/
#	install -m 644 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/*.o $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/
#	install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/gconv
#	install -m 755 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/gconv/*.so $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/gconv/
#	install -m 644 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/gconv/gconv-modules $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/gconv/
#	install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts
#	install -m 644 $(FSG3V4_BOOTSTRAP_BUILD_DIR)/ldscripts/* $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/ldscripts/
#	cd $(FSG3V4_BOOTSTRAP_BUILD_DIR) ; cp -P `find . -type l -print` $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/
#	$(STRIP_COMMAND) $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/lib/*.so

	install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/etc
	install -m 755 $(IPKG-OPT_SOURCE_DIR)/rc.optware $(FSG3V4_BOOTSTRAP_IPK_DIR)/opt/etc
	install -d $(FSG3V4_BOOTSTRAP_IPK_DIR)/etc/init.d
	install -m 755 $(FSG3V4_BOOTSTRAP_SOURCE_DIR)/optware $(FSG3V4_BOOTSTRAP_IPK_DIR)/etc/init.d/optware

	$(MAKE) $(FSG3V4_BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(FSG3V4_BOOTSTRAP_SOURCE_DIR)/preinst $(FSG3V4_BOOTSTRAP_IPK_DIR)/CONTROL/preinst
	install -m 644 $(FSG3V4_BOOTSTRAP_SOURCE_DIR)/postinst $(FSG3V4_BOOTSTRAP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FSG3V4_BOOTSTRAP_IPK_DIR)

$(FSG3V4_BOOTSTRAP_XSH): $(FSG3V4_BOOTSTRAP_IPK)
	rm -rf $(FSG3V4_BOOTSTRAP_BUILD_DIR)/bootstrap
	mkdir -p $(FSG3V4_BOOTSTRAP_BUILD_DIR)/bootstrap
	cp $(FSG3V4_BOOTSTRAP_IPK) $(FSG3V4_BOOTSTRAP_BUILD_DIR)/bootstrap/bootstrap.ipk
	cp $(FSG3V4_BOOTSTRAP_SOURCE_DIR)/bootstrap.sh $(FSG3V4_BOOTSTRAP_BUILD_DIR)/bootstrap

	# If you should ever change the archive header (echo lines below), 
	# make sure to recalculate dd's bs= argument, otherwise the self-
	# extracting archive will break! Using tail+n would be much simpler
	# but the tail command available on the FSG-3 doesn't support this.
	echo "#!/bin/sh" >$@
	echo 'echo "FSG-3 Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=180 skip=1| tar xvz' >>$@
	echo "cd bootstrap && sh bootstrap.sh && cd .. && rm -r bootstrap" >>$@
	echo 'exec /bin/sh --login' >>$@
	tar -C $(FSG3V4_BOOTSTRAP_BUILD_DIR) -czf - bootstrap >>$@
	chmod 755 $@

fsg3v4-bootstrap-ipk: $(FSG3V4_BOOTSTRAP_XSH)
fsg3v4-bootstrap-xsh: $(FSG3V4_BOOTSTRAP_XSH)

fsg3v4-bootstrap-clean:
	rm -rf $(FSG3V4_BOOTSTRAP_BUILD_DIR)/*

fsg3v4-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(FSG3V4_BOOTSTRAP_DIR) $(FSG3V4_BOOTSTRAP_BUILD_DIR) $(FSG3V4_BOOTSTRAP_IPK_DIR) $(FSG3V4_BOOTSTRAP_IPK) $(FSG3V4_BOOTSTRAP_XSH)
	rm -rf $(FSG3V4_BOOTSTRAP_BUILD_DIR)/bootstrap
