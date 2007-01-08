###########################################################
#
# lynx
#
###########################################################

LYNX_SITE=http://lynx.isc.org/release
LYNX_VERSION=2.8.6
LYNX_SOURCE=lynx$(LYNX_VERSION).tar.bz2
LYNX_DIR=lynx2-8-6
LYNX_UNZIP=bzcat
LYNX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LYNX_DESCRIPTION=A text browser for the World Wide Web
LYNX_SECTION=util
LYNX_PRIORITY=optional
LYNX_DEPENDS=bzip2, openssl, ncurses, zlib
LYNX_CONFLICTS=

LYNX_IPK_VERSION=1

LYNX_CONFFILES=/opt/etc/lynx.cfg

LYNX_BUILD_DIR=$(BUILD_DIR)/lynx
LYNX_SOURCE_DIR=$(SOURCE_DIR)/lynx
LYNX_IPK_DIR=$(BUILD_DIR)/lynx-$(LYNX_VERSION)-ipk
LYNX_IPK=$(BUILD_DIR)/lynx_$(LYNX_VERSION)-$(LYNX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lynx-source lynx-unpack lynx lynx-stage lynx-ipk lynx-clean lynx-dirclean lynx-check

#
# LYNX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LYNX_PATCHES=$(LYNX_SOURCE_DIR)/LYCurses.h.patch

$(DL_DIR)/$(LYNX_SOURCE):
	$(WGET) -P $(DL_DIR) $(LYNX_SITE)/$(LYNX_SOURCE)

lynx-source: $(DL_DIR)/$(LYNX_SOURCE) $(LYNX_PATCHES)

$(LYNX_BUILD_DIR)/.configured: $(DL_DIR)/$(LYNX_SOURCE) $(LYNX_PATCHES)
	$(MAKE) ncurses-stage openssl-stage bzip2-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR)
	$(LYNX_UNZIP) $(DL_DIR)/$(LYNX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(LYNX_PATCHES) | patch -d $(BUILD_DIR)/$(LYNX_DIR) -p1
	mv $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR)
	(cd $(LYNX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I$(LYNX_BUILD_DIR)/src/chrtrans $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--libdir=/opt/etc \
		--without-libiconv-prefix \
		--with-ssl=$(STAGING_PREFIX) \
		--with-screen=ncurses \
		--with-curses-dir=$(STAGING_DIR) \
		--with-bzlib \
		--with-zlib \
		--disable-nls \
	)
	touch $(LYNX_BUILD_DIR)/.configured

lynx-unpack: $(LYNX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
# Entities header from libgd may clash so it is moved temporarily.
#
$(LYNX_BUILD_DIR)/.built: $(LYNX_BUILD_DIR)/.configured
	rm -f $(LYNX_BUILD_DIR)/.built
	if test -f $(STAGING_INCLUDE_DIR)/entities.h ; then \
	  	mv $(STAGING_INCLUDE_DIR)/entities.h \
		 $(STAGING_INCLUDE_DIR)/entities-gd.h; \
	fi
	$(MAKE) -C $(LYNX_BUILD_DIR)/src/chrtrans makeuctb CC=$(HOSTCC) LIBS=""
	$(MAKE) -C $(LYNX_BUILD_DIR)
	if test -f $(STAGING_INCLUDE_DIR)/entities-gd.h ; then \
	 	mv $(STAGING_INCLUDE_DIR)/entities-gd.h \
		 $(STAGING_INCLUDE_DIR)/entities.h; \
	fi
	touch $(LYNX_BUILD_DIR)/.built

lynx: $(LYNX_BUILD_DIR)/.built

$(LYNX_IPK_DIR)/CONTROL/control:
	@install -d $(LYNX_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: lynx" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LYNX_PRIORITY)" >>$@
	@echo "Section: $(LYNX_SECTION)" >>$@
	@echo "Version: $(LYNX_VERSION)-$(LYNX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LYNX_MAINTAINER)" >>$@
	@echo "Source: $(LYNX_SITE)/$(LYNX_SOURCE)" >>$@
	@echo "Description: $(LYNX_DESCRIPTION)" >>$@
	@echo "Depends: $(LYNX_DEPENDS)" >>$@
	@echo "Conflicts: $(LYNX_CONFLICTS)" >>$@

$(LYNX_IPK): $(LYNX_BUILD_DIR)/.built
	rm -rf $(LYNX_IPK_DIR) $(BUILD_DIR)/lynx_*_$(TARGET_ARCH).ipk
	$(MAKE) -j1 -C $(LYNX_BUILD_DIR) DESTDIR=$(LYNX_IPK_DIR) install
	$(STRIP_COMMAND) $(LYNX_IPK_DIR)/opt/bin/*
	$(MAKE) $(LYNX_IPK_DIR)/CONTROL/control
	echo $(LYNX_CONFFILES) | sed -e 's/ /\n/g' > $(LYNX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LYNX_IPK_DIR)

lynx-ipk: $(LYNX_IPK)

lynx-clean:
	-$(MAKE) -C $(LYNX_BUILD_DIR) clean

lynx-dirclean:
	rm -rf $(BUILD_DIR)/$(LYNX_DIR) $(LYNX_BUILD_DIR) $(LYNX_IPK_DIR) $(LYNX_IPK)

#
#
# Some sanity check for the package.
#
lynx-check: $(LYNX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LYNX_IPK)
