PLAN9PORT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/plan9port
PLAN9PORT_VERSION=20071209
PLAN9PORT_SOURCE=plan9port-$(PLAN9PORT_VERSION).tar.bz2
PLAN9PORT_DIR=plan9port-$(PLAN9PORT_VERSION)
PLAN9PORT_UNZIP=bzcat
PLAN9PORT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PLAN9PORT_DESCRIPTION=Plan 9 from User Space, a port of many Plan 9 programs.
PLAN9PORT_SECTION=misc
PLAN9PORT_PRIORITY=optional
PLAN9PORT_DEPENDS=
PLAN9PORT_SUGGESTS=
PLAN9PORT_CONFLICTS=

PLAN9PORT_IPK_VERSION=1

#PLAN9PORT_CONFFILES=/opt/etc/plan9port.conf /opt/etc/init.d/SXXplan9port

PLAN9PORT_HOST_BUILD_PATCHES=$(PLAN9PORT_SOURCE_DIR)/allow-toolchain-override.patch
PLAN9PORT_PATCHES=

PLAN9PORT_CPPFLAGS=
PLAN9PORT_LDFLAGS=

PLAN9PORT_SOURCE_DIR=$(SOURCE_DIR)/plan9port
PLAN9PORT_BUILD_DIR=$(BUILD_DIR)/plan9port
PLAN9PORT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/plan9port
PLAN9PORT_IPK_DIR=$(BUILD_DIR)/plan9port-$(PLAN9PORT_VERSION)-ipk
PLAN9PORT_IPK=$(BUILD_DIR)/plan9port_$(PLAN9PORT_VERSION)-$(PLAN9PORT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: plan9port-source plan9port-unpack plan9port plan9port-stage plan9port-ipk plan9port-clean plan9port-dirclean plan9port-check

$(DL_DIR)/$(PLAN9PORT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PLAN9PORT_SITE)/$(PLAN9PORT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PLAN9PORT_SOURCE)

plan9port-source: $(DL_DIR)/$(PLAN9PORT_SOURCE) $(PLAN9PORT_PATCHES)

$(PLAN9PORT_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PLAN9PORT_SOURCE) $(PLAN9PORT_HOST_BUILD_PATHES) # make/plan9port.mk
	rm -rf $(HOST_BUILD_DIR)/$(PLAN9PORT_DIR) $(@D)
	$(PLAN9PORT_UNZIP) $(DL_DIR)/$(PLAN9PORT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(PLAN9PORT_HOST_BUILD_PATCHES)" ; \
		then cat $(PLAN9PORT_HOST_BUILD_PATCHES) | \
		patch -bd $(HOST_BUILD_DIR)/$(PLAN9PORT_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(PLAN9PORT_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(PLAN9PORT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		echo WSYSTYPE=nowsys > LOCAL.config; \
		./INSTALL -b; \
	)
	rm -rf $(HOST_STAGING_PREFIX)/plan9
	cp -a $(@D) $(HOST_STAGING_PREFIX)/plan9/bin
	(cd $(HOST_STAGING_PREFIX)/plan9; \
		./INSTALL -c; \
		sed -i.orig -e '/^PLAN9=/s|=.*|=$(HOST_STAGING_PREFIX)/plan9|' bin/9; \
	)
	touch $@

plan9port-host: $(PLAN9PORT_HOST_BUILD_DIR)/.staged

$(PLAN9PORT_BUILD_DIR)/.configured: $(PLAN9PORT_HOST_BUILD_DIR)/.staged $(PLAN9PORT_PATCHES) # make/plan9port.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PLAN9PORT_DIR) $(@D)
	$(PLAN9PORT_UNZIP) $(DL_DIR)/$(PLAN9PORT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PLAN9PORT_PATCHES)" ; \
		then cat $(PLAN9PORT_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(PLAN9PORT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PLAN9PORT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PLAN9PORT_DIR) $(@D) ; \
	fi
	sed -i.orig -e '/^PATH=/s|$$PLAN9/bin|$(HOST_STAGING_PREFIX)/plan9/bin:&|' $(@D)/INSTALL
	(cd $(@D); \
		(echo WSYSTYPE=nowsys; \
		 echo SYSNAME=Linux; \
		 echo SYSVERSION=2.4.22; \
		 echo OBJTYPE=arm; \
		) > LOCAL.config; \
	)
	# rgbycc.c -> o.rgbycc -> ycbcr.h
	# rgbrgbv.c -> o.rgbv -> rgbv.h
	touch $@

plan9port-unpack: $(PLAN9PORT_BUILD_DIR)/.configured

$(PLAN9PORT_BUILD_DIR)/.built: $(PLAN9PORT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		OVERRIDE_AR=$(TARGET_AR) \
		OVERRIDE_AS=$(TARGET_AS) \
		OVERRIDE_CC=$(TARGET_CC) \
		OVERRIDE_NM=$(TARGET_NM) \
		./INSTALL; \
	)
	[ -x $(@D)/bin/sam ] && touch $@

plan9port: $(PLAN9PORT_BUILD_DIR)/.built

$(PLAN9PORT_BUILD_DIR)/.staged: $(PLAN9PORT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

plan9port-stage: $(PLAN9PORT_BUILD_DIR)/.staged

$(PLAN9PORT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: plan9port" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PLAN9PORT_PRIORITY)" >>$@
	@echo "Section: $(PLAN9PORT_SECTION)" >>$@
	@echo "Version: $(PLAN9PORT_VERSION)-$(PLAN9PORT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PLAN9PORT_MAINTAINER)" >>$@
	@echo "Source: $(PLAN9PORT_SITE)/$(PLAN9PORT_SOURCE)" >>$@
	@echo "Description: $(PLAN9PORT_DESCRIPTION)" >>$@
	@echo "Depends: $(PLAN9PORT_DEPENDS)" >>$@
	@echo "Suggests: $(PLAN9PORT_SUGGESTS)" >>$@
	@echo "Conflicts: $(PLAN9PORT_CONFLICTS)" >>$@

$(PLAN9PORT_IPK): $(PLAN9PORT_BUILD_DIR)/.built
	rm -rf $(PLAN9PORT_IPK_DIR) $(BUILD_DIR)/plan9port_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PLAN9PORT_BUILD_DIR) DESTDIR=$(PLAN9PORT_IPK_DIR) install-strip
	install -d $(PLAN9PORT_IPK_DIR)/opt
	cp -rp $(PLAN9PORT_BUILD_DIR) $(PLAN9PORT_IPK_DIR)/opt/plan9
	$(MAKE) $(PLAN9PORT_IPK_DIR)/CONTROL/control
	sed -e '/moveplan9.sh/s|$$| $(PLAN9PORT_BUILD_DIR)|' $(PLAN9PORT_SOURCE_DIR)/postinst \
		> $(PLAN9PORT_IPK_DIR)/CONTROL/postinst
	grep '^[ 	]*echo' $(PLAN9PORT_IPK_DIR)/opt/plan9/INSTALL | tail -4 \
		>> $(PLAN9PORT_IPK_DIR)/CONTROL/postinst
	echo $(PLAN9PORT_CONFFILES) | sed -e 's/ /\n/g' > $(PLAN9PORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PLAN9PORT_IPK_DIR)

plan9port-ipk: $(PLAN9PORT_IPK)

plan9port-clean:
	rm -f $(PLAN9PORT_BUILD_DIR)/.built
	-$(MAKE) -C $(PLAN9PORT_BUILD_DIR) clean

plan9port-dirclean:
	rm -rf $(BUILD_DIR)/$(PLAN9PORT_DIR) $(PLAN9PORT_BUILD_DIR) $(PLAN9PORT_IPK_DIR) $(PLAN9PORT_IPK)

plan9port-check: $(PLAN9PORT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PLAN9PORT_IPK)
