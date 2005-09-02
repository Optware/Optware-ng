###########################################################
#
# ds101-bootstrap
#
# Creates an ipk for bootstrapping the DS-101. Also
# includes missing GLIBC libraries
#
###########################################################

ifeq ($(OPTWARE_TARGET),ds101)
DS101_GLIBC_VERSION=2.2.5
endif
ifeq ($(OPTWARE_TARGET),ds101g)
DS101_GLIBC_VERSION=2.3.3
endif
DS101_BOOTSTRAP_VERSION=0.1
DS101_BOOTSTRAP_DIR=ds101-bootstrap-$(DS101_BOOTSTRAP_VERSION)
DS101_BOOTSTRAP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DS101_BOOTSTRAP_DESCRIPTION=Bootstrap package for the DS-101(g)
DS101_BOOTSTRAP_SECTION=util
DS101_BOOTSTRAP_PRIORITY=optional
DS101_BOOTSTRAP_DEPENDS=
DS101_BOOTSTRAP_CONFLICTS=

DS101_BOOTSTRAP_IPK_VERSION=1

DS101_BOOTSTRAP_BUILD_DIR=$(BUILD_DIR)/ds101-bootstrap
DS101_BOOTSTRAP_SOURCE_DIR=$(SOURCE_DIR)/ds101-bootstrap
DS101_BOOTSTRAP_IPK_DIR=$(BUILD_DIR)/ds101-bootstrap-$(DS101_BOOTSTRAP_VERSION)-ipk
DS101_BOOTSTRAP_IPK=$(BUILD_DIR)/ds101-bootstrap_$(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk
DS101_BOOTSTRAP_XTAR=$(BUILD_DIR)/ds101-bootstrap_$(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).sh

$(DS101_BOOTSTRAP_BUILD_DIR)/.configured: $(DS101_BOOTSTRAP_PATCHES)
	rm -rf $(BUILD_DIR)/$(DS101_BOOTSTRAP_DIR) $(DS101_BOOTSTRAP_BUILD_DIR)
	mkdir -p $(DS101_BOOTSTRAP_BUILD_DIR)
	touch $(DS101_BOOTSTRAP_BUILD_DIR)/.configured

ds101-bootstrap-unpack: $(DS101_BOOTSTRAP_BUILD_DIR)/.configured

$(DS101_BOOTSTRAP_BUILD_DIR)/.built: $(DS101_BOOTSTRAP_BUILD_DIR)/.configured
	rm -f $(DS101_BOOTSTRAP_BUILD_DIR)/.built
	cp $(TARGET_LIBDIR)/libpthread-0.*.so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/librt-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/libutil-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/libgcc_s.so.1 $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(TARGET_LIBDIR)/../sbin/ldconfig $(DS101_BOOTSTRAP_BUILD_DIR)/
	cp $(SOURCE_DIR)/ipkg/rc.optware $(DS101_BOOTSTRAP_BUILD_DIR)/
	touch $(DS101_BOOTSTRAP_BUILD_DIR)/.built

ds101-bootstrap: $(DS101_BOOTSTRAP_BUILD_DIR)/.built

$(DS101_BOOTSTRAP_BUILD_DIR)/.staged: $(DS101_BOOTSTRAP_BUILD_DIR)/.built
	rm -f $(DS101_BOOTSTRAP_BUILD_DIR)/.staged
	install -d $(STAGING_DIR)/opt/lib
	install -d $(STAGING_DIR)/opt/sbin
	install -d $(STAGING_DIR)/opt/etc
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libpthread-0.*.so $(STAGING_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/librt-$(DS101_GLIBC_VERSION).so $(STAGING_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libutil-$(DS101_GLIBC_VERSION).so $(STAGING_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libgcc_s.so.1 $(STAGING_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldconfig $(STAGING_DIR)/opt/sbin
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/rc.optware $(STAGING_DIR)/opt/etc
	touch $(DS101_BOOTSTRAP_BUILD_DIR)/.staged

ds101-bootstrap-stage: $(DS101_BOOTSTRAP_BUILD_DIR)/.staged

$(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/control:
	@install -d $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ds101-bootstrap" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DS101_BOOTSTRAP_PRIORITY)" >>$@
	@echo "Section: $(DS101_BOOTSTRAP_SECTION)" >>$@
	@echo "Version: $(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DS101_BOOTSTRAP_MAINTAINER)" >>$@
	@echo "Source: $(DS101_BOOTSTRAP_SITE)/$(DS101_BOOTSTRAP_SOURCE)" >>$@
	@echo "Description: $(DS101_BOOTSTRAP_DESCRIPTION)" >>$@
	@echo "Depends: $(DS101_BOOTSTRAP_DEPENDS)" >>$@
	@echo "Conflicts: $(DS101_BOOTSTRAP_CONFLICTS)" >>$@

$(DS101_BOOTSTRAP_IPK): $(DS101_BOOTSTRAP_BUILD_DIR)/.built
	rm -rf $(DS101_BOOTSTRAP_IPK_DIR) $(BUILD_DIR)/ds101-bootstrap_*_$(TARGET_ARCH).ipk
	install -d $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib
	install -d $(DS101_BOOTSTRAP_IPK_DIR)/opt/sbin
	install -d $(DS101_BOOTSTRAP_IPK_DIR)/opt/etc
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libpthread-0.*.so $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/librt-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libutil-$(DS101_GLIBC_VERSION).so $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/libgcc_s.so.1 $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/ldconfig $(DS101_BOOTSTRAP_IPK_DIR)/opt/sbin
	install -m 755 $(DS101_BOOTSTRAP_BUILD_DIR)/rc.optware $(DS101_BOOTSTRAP_IPK_DIR)/opt/etc

	$(STRIP_COMMAND) $(DS101_BOOTSTRAP_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/control
	install -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/preinst $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/preinst
	install -m 644 $(DS101_BOOTSTRAP_SOURCE_DIR)/postinst $(DS101_BOOTSTRAP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DS101_BOOTSTRAP_IPK_DIR)

$(DS101_BOOTSTRAP_XTAR): $(DS101_BOOTSTRAP_IPK)
	cp $(DS101_BOOTSTRAP_IPK) $(DS101_BOOTSTRAP_BUILD_DIR)
	cp $(BUILD_DIR)/ipkg_0.99-148-1_powerpc.ipk $(DS101_BOOTSTRAP_BUILD_DIR)
	cp $(DS101_BOOTSTRAP_SOURCE_DIR)/bootstrap.sh $(DS101_BOOTSTRAP_BUILD_DIR)
	cp $(DS101_BOOTSTRAP_SOURCE_DIR)/ipkg.sh $(DS101_BOOTSTRAP_BUILD_DIR)
	
	# If you should ever change the archive header (echo lines below), 
	# make sure to recalculate dd's skip= argument, otherwise the self-
	# extracting archive will break!
	echo "#!/bin/sh" >$@
	echo 'echo "DS-101 Bootstrap extracting archive... please wait"' >>$@
	echo 'dd if=$$0 bs=1 skip=124| tar xvz' >>$@
	echo "sh bootstrap.sh" >>$@
	echo 'exit $$?' >>$@
	tar -C $(DS101_BOOTSTRAP_BUILD_DIR) -czf - \
		ipkg_0.99-148-1_powerpc.ipk \
		ipkg.sh \
		ds101-bootstrap_$(DS101_BOOTSTRAP_VERSION)-$(DS101_BOOTSTRAP_IPK_VERSION)_$(TARGET_ARCH).ipk \
		bootstrap.sh >>$@
	chmod 755 $@

ds101-bootstrap-ipk: $(DS101_BOOTSTRAP_IPK)

ds101-bootstrap-xtar: $(DS101_BOOTSTRAP_XTAR)

ds101-bootstrap-clean:
	rm -rf $(DS101_BOOTSTRAP_BUILD_DIR)/*

ds101-bootstrap-dirclean:
	rm -rf $(BUILD_DIR)/$(DS101_BOOTSTRAP_DIR) $(DS101_BOOTSTRAP_BUILD_DIR) $(DS101_BOOTSTRAP_IPK_DIR) $(DS101_BOOTSTRAP_IPK) $(DS101_BOOTSTRAP_XTAR)
