#
# Openssl build for Linksys nslu2
#

OPENSSL_SITE=http://www.openssl.org/source
OPENSSL_VERSION=0.9.7m
OPENSSL_LIB_VERSION=0.9.7
OPENSSL_SOURCE=openssl-$(OPENSSL_VERSION).tar.gz
OPENSSL_DIR=openssl-$(OPENSSL_VERSION)
OPENSSL_UNZIP=zcat
OPENSSL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENSSL_DESCRIPTION=Openssl provides the ssl implementation in libraries libcrypto and libssl, and is needed by many other applications and libraries.
OPENSSL_SECTION=libs
OPENSSL_PRIORITY=recommended
OPENSSL_DEPENDS=
OPENSSL_CONFLICTS=

OPENSSL_IPK_VERSION=1

OPENSSL_BUILD_DIR=$(BUILD_DIR)/openssl
OPENSSL_SOURCE_DIR=$(SOURCE_DIR)/openssl
OPENSSL_IPK_DIR=$(BUILD_DIR)/openssl-$(OPENSSL_VERSION)-ipk
OPENSSL_IPK=$(BUILD_DIR)/openssl_$(OPENSSL_VERSION)-$(OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENSSL_PATCHES=$(OPENSSL_SOURCE_DIR)/Configure.patch

.PHONY: openssl-source openssl-unpack openssl openssl-stage openssl-ipk openssl-clean openssl-dirclean openssl-check

$(DL_DIR)/$(OPENSSL_SOURCE):
	cd $(DL_DIR) && $(WGET) $(OPENSSL_SITE)/$(OPENSSL_SOURCE)

openssl-source: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES)

ifeq ($(TARGET_ARCH),mipsel)
OPENSSL_ARCH=linux-$(TARGET_ARCH)
else
ifeq ($(TARGET_ARCH),powerpc)
OPENSSL_ARCH=linux-ppc
OPENSSL_ASFLAG=ASFLAG=""
else
OPENSSL_ARCH=linux-elf-$(TARGET_ARCH)
endif
endif

$(OPENSSL_BUILD_DIR)/.configured: $(DL_DIR)/$(OPENSSL_SOURCE) $(OPENSSL_PATCHES) make/openssl.mk
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR)
	$(OPENSSL_UNZIP) $(DL_DIR)/$(OPENSSL_SOURCE) | tar -C $(BUILD_DIR) -xvf - 
	cat $(OPENSSL_PATCHES) | patch -d $(BUILD_DIR)/$(OPENSSL_DIR) -p1
	mv $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR)
	(cd $(OPENSSL_BUILD_DIR) && \
		$(TARGET_CONFIGURE_OPTS) \
		./Configure \
			shared zlib-dynamic \
			$(STAGING_CPPFLAGS) \
			--openssldir=/opt/share/openssl \
			--prefix=/opt \
			$(OPENSSL_ARCH) \
	)
	sed -ie 's|$$(PERL) tools/c_rehash certs||' $(OPENSSL_BUILD_DIR)/apps/Makefile
	touch $(OPENSSL_BUILD_DIR)/.configured

openssl-unpack: $(OPENSSL_BUILD_DIR)/.configured

$(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/.configured
	$(MAKE) zlib-stage
	$(MAKE) -C $(OPENSSL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		AR="${TARGET_AR} r" \
		$(OPENSSL_ASFLAG) \
		MANDIR=/opt/man \
		EX_LIBS="$(STAGING_LDFLAGS) -ldl" \
		DIRS="crypto ssl apps"

openssl: $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)

$(STAGING_DIR)/opt/lib/libssl.so.$(OPENSSL_LIB_VERSION): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	rm -rf $(STAGING_DIR)/opt/include/openssl
	install -d $(STAGING_DIR)/opt/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(STAGING_DIR)/opt/include/openssl
	install -d $(STAGING_PREFIX)/bin
ifeq ($(HOSTCC), $(TARGET_CC))
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl $(STAGING_PREFIX)/bin/openssl
else
#	a fake /opt/bin/openssl in $STAGING_DIR)
	( \
		echo "#!/bin/sh"; \
		sed -n '/#define OPENSSL_VERSION_TEXT/s/^[^"]*"/echo "/p' \
			$(STAGING_INCLUDE_DIR)/openssl/opensslv.h; \
	) > $(STAGING_PREFIX)/bin/openssl
	chmod 755 $(STAGING_PREFIX)/bin/openssl
endif
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.a $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.a $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(STAGING_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION) $(STAGING_DIR)/opt/lib
	cd $(STAGING_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(STAGING_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(STAGING_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so
	install -d $(STAGING_DIR)/opt/lib/pkgconfig
	install -m 644 $(OPENSSL_BUILD_DIR)/openssl.pc $(STAGING_DIR)/opt/lib/pkgconfig
	sed -ie 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/openssl.pc

openssl-stage: $(STAGING_DIR)/opt/lib/libssl.so.$(OPENSSL_LIB_VERSION)

$(OPENSSL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(OPENSSL_IPK): $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION)
	rm -rf $(OPENSSL_IPK_DIR) $(BUILD_DIR)/openssl_*_$(TARGET_ARCH).ipk
	install -d $(OPENSSL_IPK_DIR)/opt/bin
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl $(OPENSSL_IPK_DIR)/opt/bin/openssl
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/bin/openssl
	install -d $(OPENSSL_IPK_DIR)/opt/share/openssl
	install -m 755 $(OPENSSL_BUILD_DIR)/apps/openssl.cnf $(OPENSSL_IPK_DIR)/opt/share/openssl/openssl.cnf
	install -d $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -m 644 $(OPENSSL_BUILD_DIR)/include/openssl/*.h $(OPENSSL_IPK_DIR)/opt/include/openssl
	install -d $(OPENSSL_IPK_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libcrypto.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)/opt/lib
	install -m 644 $(OPENSSL_BUILD_DIR)/libssl.so.$(OPENSSL_LIB_VERSION) $(OPENSSL_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/lib/libcrypto.so*
	$(STRIP_COMMAND) $(OPENSSL_IPK_DIR)/opt/lib/libssl.so*
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so.0
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libcrypto.so.$(OPENSSL_LIB_VERSION) libcrypto.so
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so.0
	cd $(OPENSSL_IPK_DIR)/opt/lib && ln -fs libssl.so.$(OPENSSL_LIB_VERSION) libssl.so
	$(MAKE) $(OPENSSL_IPK_DIR)/CONTROL/control
	echo $(OPENSSL_CONFFILES) | sed -e 's/ /\n/g' > $(OPENSSL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENSSL_IPK_DIR)

openssl-ipk: $(OPENSSL_IPK)

openssl-clean:
	-$(MAKE) -C $(OPENSSL_BUILD_DIR) clean

openssl-dirclean:
	rm -rf $(BUILD_DIR)/$(OPENSSL_DIR) $(OPENSSL_BUILD_DIR) $(OPENSSL_IPK_DIR) $(OPENSSL_IPK)

openssl-check: $(OPENSSL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OPENSSL_IPK)
