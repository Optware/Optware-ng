#
# Openssl build for Linksys nslu2
#

OPENSSL_SITE=http://www.openssl.org/source

OPENSSL_VERSION := 1.0.2n
# see crypto/opensslv.h's SHLIB_VERSION_NUMBER
OPENSSL_LIB_VERSION := 1.0.0
OPENSSL_IPK_VERSION := 1

OPENSSL_SOURCE=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_DIR=openssl-$(OPENSSL_VERSION)
OPENSSL_UNZIP=zcat
OPENSSL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENSSL_DESCRIPTION=Openssl provides the ssl implementation in libraries libcrypto and libssl, and is needed by many other applications and libraries.
OPENSSL_SECTION=libs
OPENSSL_PRIORITY=recommended
OPENSSL_DEPENDS=cacerts
OPENSSL_CONFLICTS=

OPENSSL_CONFFILES=$(TARGET_PREFIX)/etc/ssl/openssl.cnf

OPENSSL_SOURCE_DIR=$(SOURCE_DIR)/openssl
OPENSSL_BUILD_DIR=$(BUILD_DIR)/openssl
OPENSSL_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/openssl

OPENSSL_IPK_DIR=$(BUILD_DIR)/openssl-$(OPENSSL_VERSION)-ipk
OPENSSL_IPK=$(BUILD_DIR)/openssl_$(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENSSL_DEV_IPK_DIR=$(BUILD_DIR)/openssl-dev-$(OPENSSL_VERSION)-ipk
OPENSSL_DEV_IPK=$(BUILD_DIR)/openssl-dev_$(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq (,$(findstring 1.0.1, $(OPENSSL_VERSION)))
ifeq (1.0.1a,$(OPENSSL_VERSION))
OPENSSL_PATCHES=$(OPENSSL_SOURCE_DIR)/openssl-1.0.1a.patch
endif

else ifeq (,$(findstring 1.0.0, $(OPENSSL_VERSION)) )
OPENSSL_PATCHES=

else
OPENSSL_PATCHES=$(strip \
$(if $(filter 0.9.7, $(OPENSSL_LIB_VERSION)), $(OPENSSL_SOURCE_DIR)/Configure.patch, \
$(OPENSSL_SOURCE_DIR)/0.9.8-configure-targets.patch))
endif

ifeq ($(OPTWARE_TARGET), dns323)
OPENSSL_PATCHES+=$(OPENSSL_SOURCE_DIR)/Configure-O3-to-O2.patch
endif

OPENSSL_PATCHES+=$(OPENSSL_SOURCE_DIR)/openssl.cnf.patch

.PHONY: openssl-source openssl-unpack openssl openssl-stage openssl-ipk openssl-clean openssl-dirclean openssl-check

$(DL_DIR)/$(OPENSSL_SOURCE):
	$(WGET) -P $(@D) $(OPENSSL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

openssl-source: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES)

OPENSSL_ASFLAG=$(strip $(if $(filter powerpc, $(TARGET_ARCH)), ASFLAG="",))

ifeq (0.9.7,$(OPENSSL_LIB_VERSION))
OPENSSL_ARCH=linux-$(strip \
        $(if $(filter arm armeb, $(TARGET_ARCH)), elf-$(TARGET_ARCH), \
        $(if $(filter i386 i686, $(TARGET_ARCH)), pentium, \
	$(if $(filter powerpc ppc, $(TARGET_ARCH)), ppc, \
	$(TARGET_ARCH)))))
OPENSSL_HOST_ARCH=linux-$(strip \
        $(if $(filter arm armeb, $(HOST_MACHINE)), elf-$(HOST_MACHINE), \
        $(if $(filter i386 i686, $(HOST_MACHINE)), pentium, \
	$(if $(filter powerpc ppc, $(HOST_MACHINE)), ppc, \
	$(HOST_MACHINE)))))
else
OPENSSL_ARCH=linux-$(strip \
	$(if $(filter powerpc ppc, $(TARGET_ARCH)), ppc, \
	$(if $(filter x86_64, $(TARGET_ARCH)), $(TARGET_ARCH), \
	generic32)))
OPENSSL_HOST_ARCH=linux-$(strip \
	$(if $(filter powerpc ppc, $(HOST_MACHINE)), ppc, \
	$(if $(filter x86_64, $(HOST_MACHINE)), $(HOST_MACHINE), \
	generic32)))
endif

$(OPENSSL_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES) #make/openssl.mk
	rm -rf $(HOST_BUILD_DIR)/$(OPENSSL_DIR) $(@D)
	rm -f $(HOST_STAGING_LIB_DIR)/libssl.* $(HOST_STAGING_LIB_DIR)/libcrypto.*
	$(OPENSSL_UNZIP) $(DL_DIR)/$(OPENSSL_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf - 
	mv $(HOST_BUILD_DIR)/$(OPENSSL_DIR) $(@D)
	(cd $(@D) && \
		./Configure \
			shared no-zlib \
			--openssldir=/opt/share/openssl \
			--prefix=/opt \
			enable-md2 \
                        $(OPENSSL_HOST_ARCH) \
	)
	sed -i -e 's|LIBDEPS=.|&-Wl,-rpath,$(HOST_STAGING_LIB_DIR) |' $(@D)/Makefile
	$(MAKE) -C $(@D) EX_LIBS="-ldl"
	touch $@

$(OPENSSL_HOST_BUILD_DIR)/.staged: $(OPENSSL_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) \
		INSTALL_PREFIX=$(HOST_STAGING_DIR) install_sw
	touch $@

openssl-host: $(OPENSSL_HOST_BUILD_DIR)/.built
openssl-host-stage: $(OPENSSL_HOST_BUILD_DIR)/.staged

$(OPENSSL_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES) make/openssl.mk
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(@D)
	rm -f $(STAGING_LIB_DIR)/libssl.* $(STAGING_LIB_DIR)/libcrypto.*
	$(OPENSSL_UNZIP) $(DL_DIR)/$(OPENSSL_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	if test -n "$(OPENSSL_PATCHES)"; then \
		cat $(OPENSSL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(OPENSSL_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(OPENSSL_DIR) $(@D)
	(cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		./Configure \
			shared zlib-dynamic \
			enable-md2 enable-rfc3779 \
			$(STAGING_CPPFLAGS) \
			--openssldir=$(TARGET_PREFIX)/etc/ssl \
			--prefix=$(TARGET_PREFIX) \
			$(OPENSSL_ARCH) \
	)
	sed -i -e "s|LIBDEPS=['\"]|&$(STAGING_LDFLAGS) |" $(@D)/Makefile
	sed -i -e 's|$$(PERL) tools/c_rehash certs||' $(@D)/apps/Makefile
	touch $@

openssl-unpack: $(OPENSSL_BUILD_DIR)/.configured

$(OPENSSL_BUILD_DIR)/.built: $(OPENSSL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) zlib-stage
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		AR="${TARGET_AR} r" \
                $(if $(filter i686, $(TARGET_ARCH)),AS=$(TARGET_CC),) \
		$(OPENSSL_ASFLAG) \
		MANDIR=$(TARGET_PREFIX)/man \
		EX_LIBS="$(STAGING_LDFLAGS) -ldl" \
		DIRS="crypto ssl apps engines"
	touch $@

openssl: $(OPENSSL_BUILD_DIR)/.built

$(OPENSSL_BUILD_DIR)/.staged: $(OPENSSL_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_INCLUDE_DIR)/openssl
	$(INSTALL) -d $(STAGING_INCLUDE_DIR)/openssl
	$(INSTALL) -m 644 $(@D)/include/openssl/*.h $(STAGING_INCLUDE_DIR)/openssl
	$(INSTALL) -d $(STAGING_PREFIX)/bin
ifeq ($(HOSTCC), $(TARGET_CC))
	$(INSTALL) -m 755 $(@D)/apps/openssl $(STAGING_PREFIX)/bin/openssl
else
#	a fake $(TARGET_PREFIX)/bin/openssl in $STAGING_DIR)
	( \
		echo "#!/bin/sh"; \
		sed -n '/#define OPENSSL_VERSION_TEXT/s/^[^"]*"/echo "/p' \
			$(STAGING_INCLUDE_DIR)/openssl/opensslv.h; \
	) > $(STAGING_PREFIX)/bin/openssl
	chmod 755 $(STAGING_PREFIX)/bin/openssl
endif
	$(INSTALL) -d $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/libcrypto.a $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/libssl.a $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(STAGING_LIB_DIR)
	$(INSTALL) -m 644 $(@D)/libssl.so.$(OPENSSL_LIB_VERSION) $(STAGING_LIB_DIR)
	cd $(STAGING_LIB_DIR) && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(STAGING_LIB_DIR) && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(STAGING_LIB_DIR) && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(STAGING_LIB_DIR) && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	$(INSTALL) -m 644 $(@D)/{openssl,libcrypto,libssl}.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/{openssl,libcrypto,libssl}.pc
	touch $@

openssl-stage: $(OPENSSL_BUILD_DIR)/.staged

$(OPENSSL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openssl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSSL_PRIORITY)" >>$@
	@echo "Section: $(OPENSSL_SECTION)" >>$@
	@echo "Version: $(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSSL_MAINTAINER)" >>$@
	@echo "Source: $(OPENSSL_SITE)/$(OPENSSL_SOURCE)" >>$@
	@echo "Description: $(OPENSSL_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENSSL_DEPENDS)" >>$@
	@echo "Conflicts: $(OPENSSL_CONFLICTS)" >>$@

$(OPENSSL_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openssl-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENSSL_PRIORITY)" >>$@
	@echo "Section: $(OPENSSL_SECTION)" >>$@
	@echo "Version: $(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENSSL_MAINTAINER)" >>$@
	@echo "Source: $(OPENSSL_SITE)/$(OPENSSL_SOURCE)" >>$@
	@echo "Description: openssl native development files" >>$@
	@echo "Depends: openssl" >>$@
	@echo "Conflicts: $(OPENSSL_CONFLICTS)" >>$@

$(OPENSSL_IPK) $(OPENSSL_DEV_IPK): $(OPENSSL_BUILD_DIR)/.built
	rm -rf $(OPENSSL_IPK_DIR) $(BUILD_DIR)/openssl_*_$(TARGET_ARCH).ipk \
		$(OPENSSL_DEV_IPK_DIR) $(BUILD_DIR)/openssl-dev_*_$(TARGET_ARCH).ipk
	# openssl
	$(INSTALL) -d $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/bin/openssl
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/bin/openssl
	$(INSTALL) -d $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/etc/ssl
	$(INSTALL) -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl.cnf $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/etc/ssl/openssl.cnf
	$(INSTALL) -d $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib/engines
	$(INSTALL) -m 755 $(OPENSSL_BUILD_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib
	$(INSTALL) -m 755 $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib/libcrypto.so*
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib/libssl.so*
	cd $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so
	$(INSTALL) -m 755 $(OPENSSL_BUILD_DIR)/engines/lib*.so $(OPENSSL_BUILD_DIR)/engines/ccgost/libgost.so \
		$(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib/engines
	$(STRIP_COMMAND)  $(OPENSSL_IPK_DIR)$(TARGET_PREFIX)/lib/engines/lib*.so
	$(MAKE) $(OPENSSL_IPK_DIR)/CONTROL/control
	echo $(OPENSSL_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSSL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENSSL_IPK_DIR)
	# openssl-dev
	$(INSTALL) -d $(OPENSSL_DEV_IPK_DIR)$(TARGET_PREFIX)/include/openssl
	$(INSTALL) -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(OPENSSL_DEV_IPK_DIR)$(TARGET_PREFIX)/include/openssl
	$(INSTALL) -d $(OPENSSL_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	$(INSTALL) -m 644 $(OPENSSL_BUILD_DIR)/openssl.pc $(OPENSSL_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig
	sed -i '/^Libs:/s|-lcrypto .* -ldl|-lcrypto -ldl|' $(OPENSSL_DEV_IPK_DIR)$(TARGET_PREFIX)/lib/pkgconfig/openssl.pc
	$(MAKE) $(OPENSSL_DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENSSL_DEV_IPK_DIR)

$(OPENSSL_BUILD_DIR)/.ipk: $(OPENSSL_IPK) $(OPENSSL_DEV_IPK)
	touch $@

openssl-ipk: $(OPENSSL_BUILD_DIR)/.ipk

openssl-clean:
	-$(MAKE) -C $(OPENSSL_BUILD_DIR) clean

openssl-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR) $(OPENSSL_IPK_DIR)
	rm -rf $(OPENSSL_IPK) $(OPENSSL_DEV_IPK)

openssl-check: $(OPENSSL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
