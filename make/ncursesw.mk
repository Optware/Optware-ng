###########################################################
#
# ncursesw
#
###########################################################

NCURSESW_DIR=$(BUILD_DIR)/ncursesw
NCURSESW_SOURCE_DIR=$(SOURCE_DIR)/ncurses

NCURSESW_VERSION=5.7
NCURSESW_SITE=ftp://invisible-island.net/ncurses
NCURSESW_SOURCE=ncurses-$(NCURSESW_VERSION).tar.gz
NCURSESW_UNZIP=zcat
NCURSESW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NCURSESW_DESCRIPTION=NCurses libraries with wide char support
NCURSESW_SECTION=net
NCURSESW_PRIORITY=optional
NCURSESW_DEPENDS=ncurses
NCURSESW_CONFLICTS=

NCURSESW_IPK_VERSION=3

NCURSESW_PATCHES=$(NCURSESW_SOURCE_DIR)/MKlib_gen_sh.patch

NCURSESW_IPK=$(BUILD_DIR)/ncursesw_$(NCURSESW_VERSION)-$(NCURSESW_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSESW-DEV_IPK=$(BUILD_DIR)/ncursesw-dev_$(NCURSESW_VERSION)-$(NCURSESW_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSESW_IPK_DIR=$(BUILD_DIR)/ncursesw-$(NCURSESW_VERSION)-ipk
NCURSESW-DEV_IPK_DIR=$(BUILD_DIR)/ncursesw-dev-$(NCURSESW_VERSION)-ipk

.PHONY: ncursesw-source ncursesw-unpack ncursesw ncursesw-stage ncursesw-ipk ncursesw-clean ncursesw-dirclean ncursesw-check

ncursesw-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSESW_DIR)/.configured: $(DL_DIR)/$(NCURSESW_SOURCE) make/ncursesw.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(NCURSES) $(@D)
	rm -rf  $(STAGING_INCLUDE_DIR)/ncursesw \
		$(STAGING_LIB_DIR)/libformw.* \
		$(STAGING_LIB_DIR)/libmenuw.* \
		$(STAGING_LIB_DIR)/libncursesw.* \
		$(STAGING_LIB_DIR)/libpanelw.*
	$(NCURSESW_UNZIP) $(DL_DIR)/$(NCURSESW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NCURSESW_PATCHES)" ; \
		then cat $(NCURSESW_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NCURSES) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(NCURSES) $(NCURSESW_DIR)
ifneq ($(HOSTCC), $(TARGET_CC))
	# configure without wide char just to make two build tools
	(cd $(@D); \
		./configure \
		--prefix=$(TARGET_PREFIX)	\
		--with-shared		\
		--disable-big-core	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
		--disable-widec		\
		--enable-safe-sprintf	\
	);
	$(MAKE) -C $(@D)/ncurses make_hash make_keys -j1
endif
	# configure again, this time for real
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(TARGET_PREFIX)	\
		--with-shared		\
		--disable-big-core	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
		--enable-widec		\
		--enable-safe-sprintf	\
	);
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e '/^CPPFLAGS/s| -I$$[{(]includedir[)}]||' $(@D)/*/Makefile
endif
	touch $@

ncursesw-unpack: $(NCURSESW_DIR)/.configured

$(NCURSESW_DIR)/.built: $(NCURSESW_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NCURSESW_DIR)
	touch $@

ncursesw: $(NCURSESW_DIR)/.built

$(NCURSESW_DIR)/.staged: $(NCURSESW_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NCURSESW_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs  -j 1
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/ncursesw[0-9]*-config
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	$(INSTALL) -m 644 $(NCURSESW_SOURCE_DIR)/ncursesw.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/ncursesw.pc
	touch $@

ncursesw-stage: $(NCURSESW_DIR)/.staged

$(NCURSESW_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ncursesw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCURSESW_PRIORITY)" >>$@
	@echo "Section: $(NCURSESW_SECTION)" >>$@
	@echo "Version: $(NCURSESW_VERSION)-$(NCURSESW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCURSESW_MAINTAINER)" >>$@
	@echo "Source: $(NCURSESW_SITE)/$(NCURSESW_SOURCE)" >>$@
	@echo "Description: $(NCURSESW_DESCRIPTION)" >>$@
	@echo "Depends: $(NCURSESW_DEPENDS)" >>$@
	@echo "Conflicts: $(NCURSESW_CONFLICTS)" >>$@

$(NCURSESW-DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ncursesw-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCURSESW_PRIORITY)" >>$@
	@echo "Section: $(NCURSESW_SECTION)" >>$@
	@echo "Version: $(NCURSESW_VERSION)-$(NCURSESW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCURSESW_MAINTAINER)" >>$@
	@echo "Source: $(NCURSESW_SITE)/$(NCURSESW_SOURCE)" >>$@
	@echo "Description: $(NCURSESW_DESCRIPTION), header files" >>$@
	@echo "Depends: ncursesw" >>$@
	@echo "Conflicts: " >>$@

$(NCURSESW_IPK) $(NCURSESW-DEV_IPK): $(NCURSESW_DIR)/.built
	rm -rf $(NCURSESW_IPK_DIR) $(BUILD_DIR)/ncursesw_*_$(TARGET_ARCH).ipk
	rm -rf $(NCURSESW-DEV_IPK_DIR) $(BUILD_DIR)/ncursesw-dev_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NCURSESW_DIR) DESTDIR=$(NCURSESW_IPK_DIR) install.libs  -j 1
	rm -rf $(NCURSESW_IPK_DIR)$(TARGET_PREFIX)/include
	rm -f $(NCURSESW_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
#	$(STRIP_COMMAND) $(NCURSESW_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(STRIP_COMMAND) $(NCURSESW_IPK_DIR)$(TARGET_PREFIX)/lib/*.so
	$(MAKE) $(NCURSESW_IPK_DIR)/CONTROL/control
	# ncursesw-dev
	$(INSTALL) -d $(NCURSESW-DEV_IPK_DIR)$(TARGET_PREFIX)/include/ncursesw
	$(MAKE) -C $(NCURSESW_DIR) DESTDIR=$(NCURSESW-DEV_IPK_DIR) install.includes  -j 1
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSESW_IPK_DIR)
	$(MAKE) $(NCURSESW-DEV_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSESW-DEV_IPK_DIR)

ncursesw-ipk: $(NCURSESW_IPK) $(NCURSESW-DEV_IPK)

ncursesw-clean:
	-$(MAKE) -C $(NCURSESW_DIR) clean

ncursesw-dirclean:
	rm -rf $(NCURSESW_DIR) \
	$(NCURSESW_IPK_DIR) $(NCURSESW_IPK) \
	$(NCURSESW-DEV_IPK_DIR) $(NCURSESW-DEV_IPK)

ncursesw-check: $(NCURSESW_IPK) $(NCURSESW-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
