###########################################################
#
# ncurses
#
###########################################################

NCURSES_DIR=$(BUILD_DIR)/ncurses
NCURSES_SOURCE_DIR=$(SOURCE_DIR)/ncurses

NCURSES_VERSION=5.7
NCURSES=ncurses-$(NCURSES_VERSION)
NCURSES_SITE=ftp://ftp.invisible-island.net/ncurses
NCURSES_SOURCE=$(NCURSES).tar.gz
NCURSES_UNZIP=zcat
NCURSES_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
NCURSES_DESCRIPTION=NCurses libraries
NCURSES_BASE_DESCRIPTION=Basic terminal type definitions
NCURSES_SECTION=net
NCURSES_BASE_SECTION=misc
NCURSES_PRIORITY=optional
NCURSES_BASE_PRIORITY=optional
NCURSES_DEPENDS=ncurses-base
NCURSES_BASE_DEPENDS=
NCURSES_CONFLICTS=

ifneq ($(OPTWARE_TARGET), wl500g)
NCURSES_FOR_OPTWARE_TARGET=ncursesw
else
NCURSES_FOR_OPTWARE_TARGET=ncurses
endif

NCURSES_IPK_VERSION=7

NCURSES_PATCHES=$(NCURSES_SOURCE_DIR)/MKlib_gen_sh.patch

NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSES_IPK_DIR=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

NCURSES_BASE_IPK=$(BUILD_DIR)/ncurses-base_$(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSES_BASE_IPK_DIR=$(BUILD_DIR)/ncurses-base-$(NCURSES_VERSION)-ipk

NCURSES_DEV_IPK=$(BUILD_DIR)/ncurses-dev_$(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSES_DEV_IPK_DIR=$(BUILD_DIR)/ncurses-dev-$(NCURSES_VERSION)-ipk

NCURSES_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/ncurses

.PHONY: ncurses-source ncurses-unpack ncurses ncurses-stage ncurses-ipk ncurses-clean \
ncurses-dirclean ncurses-check ncurses-host

$(DL_DIR)/$(NCURSES_SOURCE):
	$(WGET) -P $(@D) $(NCURSES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ncurses-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSES_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(NCURSES_SOURCE) make/ncurses.mk
	rm -rf $(HOST_BUILD_DIR)/$(NCURSES) $(@D)
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(NCURSES) $(@D)
	(cd $(@D); \
		CPPFLAGS="-fPIC" \
		./configure \
		--prefix=$(HOST_STAGING_PREFIX)	\
		--without-shared	\
		--enable-symlinks	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
	)
	$(MAKE) -C $(@D)/include
	$(MAKE) -C $(@D)/progs tic
	touch $@

ncurses-host: $(NCURSES_HOST_BUILD_DIR)/.built

$(NCURSES_HOST_BUILD_DIR)/.staged: $(NCURSES_HOST_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) install -j 1
	ln -sf ncurses/ncurses.h $(HOST_STAGING_INCLUDE_DIR)
	ln -sf ncurses/curses.h $(HOST_STAGING_INCLUDE_DIR)
	touch $@

ncurses-host-stage: $(NCURSES_HOST_BUILD_DIR)/.staged

$(NCURSES_DIR)/.configured: $(DL_DIR)/$(NCURSES_SOURCE) $(NCURSES_PATCHES) make/ncurses.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(NCURSES) $(@D)
	rm -rf  $(STAGING_INCLUDE_DIR)/ncurses \
		$(STAGING_LIB_DIR)/libform.* \
		$(STAGING_LIB_DIR)/libmenu.* \
		$(STAGING_LIB_DIR)/libncurses.* \
		$(STAGING_LIB_DIR)/libpanel.* \
		$(STAGING_LIB_DIR)/libtinfo.*
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NCURSES_PATCHES)" ; \
		then cat $(NCURSES_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(NCURSES) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(NCURSES) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=$(TARGET_PREFIX)	\
		--with-shared		\
		--enable-symlinks	\
		--disable-big-core	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
	);
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -i -e '/^CPPFLAGS/s| -I$$[{(]includedir[)}]||' $(@D)/*/Makefile
endif
	touch $@

ncurses-unpack: $(NCURSES_DIR)/.configured

$(NCURSES_DIR)/.built: $(NCURSES_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NCURSES_DIR)
	touch $@

ncurses: $(NCURSES_DIR)/.built

$(NCURSES_DIR)/.staged: $(NCURSES_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs  -j 1
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_PREFIX)/bin/ncurses[0-9]*-config
	ln -sf ncurses/ncurses.h $(STAGING_INCLUDE_DIR)
	ln -sf ncurses/curses.h $(STAGING_INCLUDE_DIR)
	$(INSTALL) -d $(STAGING_LIB_DIR)/pkgconfig
	$(INSTALL) -m 644 $(NCURSES_SOURCE_DIR)/ncurses.pc $(STAGING_LIB_DIR)/pkgconfig
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/ncurses.pc
	touch $@

ncurses-stage: $(NCURSES_DIR)/.staged

$(NCURSES_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ncurses" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCURSES_PRIORITY)" >>$@
	@echo "Section: $(NCURSES_SECTION)" >>$@
	@echo "Version: $(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCURSES_MAINTAINER)" >>$@
	@echo "Source: $(NCURSES_SITE)/$(NCURSES_SOURCE)" >>$@
	@echo "Description: $(NCURSES_DESCRIPTION)" >>$@
	@echo "Depends: $(NCURSES_DEPENDS)" >>$@
	@echo "Conflicts: $(NCURSES_CONFLICTS)" >>$@

$(NCURSES_BASE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ncurses-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCURSES_BASE_PRIORITY)" >>$@
	@echo "Section: $(NCURSES_BASE_SECTION)" >>$@
	@echo "Version: $(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCURSES_MAINTAINER)" >>$@
	@echo "Source: $(NCURSES_SITE)/$(NCURSES_SOURCE)" >>$@
	@echo "Description: $(NCURSES_BASE_DESCRIPTION)" >>$@
	@echo "Depends: $(NCURSES_BASE_DEPENDS)" >>$@
	@echo "Conflicts: $(NCURSES_CONFLICTS)" >>$@

$(NCURSES_DEV_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ncurses-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCURSES_PRIORITY)" >>$@
	@echo "Section: $(NCURSES_SECTION)" >>$@
	@echo "Version: $(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCURSES_MAINTAINER)" >>$@
	@echo "Source: $(NCURSES_SITE)/$(NCURSES_SOURCE)" >>$@
	@echo "Description: $(NCURSES_DESCRIPTION), header files" >>$@
	@echo "Depends: ncurses" >>$@
	@echo "Conflicts: " >>$@

$(NCURSES_IPK) $(NCURSES_BASE_IPK) $(NCURSES_DEV_IPK): $(NCURSES_DIR)/.built
	rm -rf 	$(NCURSES_IPK_DIR) $(BUILD_DIR)/ncurses_*_$(TARGET_ARCH).ipk \
		$(NCURSES_BASE_IPK_DIR) $(BUILD_DIR)/ncurses-base_*_$(TARGET_ARCH).ipk \
		$(NCURSES_DEV_IPK_DIR) $(BUILD_DIR)/ncurses-dev_*_$(TARGET_ARCH).ipk
	$(if $(filter $(HOSTCC), $(TARGET_CC)),,PATH=$(NCURSES_HOST_BUILD_DIR)/progs:$$PATH) \
		$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(NCURSES_IPK_DIR) \
		install.libs install.progs install.data  -j 1
	rm -rf $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/include
	rm -f $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(STRIP_COMMAND) $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/bin/clear \
		$(NCURSES_IPK_DIR)$(TARGET_PREFIX)/bin/infocmp $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/bin/t*
	$(STRIP_COMMAND) $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/lib/*$(SO).5$(DYLIB)
ifeq (darwin, $(TARGET_OS))
	for dylib in $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/lib/*$(SO).5$(DYLIB); do \
	$(TARGET_CROSS)install_name_tool -change $$dylib $(TARGET_PREFIX)/lib/`basename $$dylib` $$dylib; \
	done
endif
	$(MAKE) $(NCURSES_IPK_DIR)/CONTROL/control
	mv $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/bin/clear $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/bin/ncurses-clear
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install $(TARGET_PREFIX)/bin/clear clear $(TARGET_PREFIX)/bin/ncurses-clear 80"; \
	) > $(NCURSES_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove clear $(TARGET_PREFIX)/bin/ncurses-clear"; \
	) > $(NCURSES_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NCURSES_IPK_DIR)/CONTROL/postinst $(NCURSES_IPK_DIR)/CONTROL/prerm; \
	fi
	# ncurses-base
	$(INSTALL) -d $(NCURSES_BASE_IPK_DIR)$(TARGET_PREFIX)
	mv -f $(NCURSES_IPK_DIR)$(TARGET_PREFIX)/share $(NCURSES_BASE_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) $(NCURSES_BASE_IPK_DIR)/CONTROL/control
	# ncurses-dev
	$(INSTALL) -d $(NCURSES_DEV_IPK_DIR)$(TARGET_PREFIX)/include/ncurses
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(NCURSES_DEV_IPK_DIR) install.includes  -j 1
	ln -sf ncurses/ncurses.h $(NCURSES_DEV_IPK_DIR)$(TARGET_PREFIX)/include/
	ln -sf ncurses/curses.h $(NCURSES_DEV_IPK_DIR)$(TARGET_PREFIX)/include/
	$(MAKE) $(NCURSES_DEV_IPK_DIR)/CONTROL/control
	# building ipk's
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_DEV_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_BASE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NCURSES_IPK_DIR) $(NCURSES_DEV_IPK_DIR) $(NCURSES_BASE_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK) $(NCURSES_BASE_IPK) $(NCURSES_DEV_IPK)

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean
	-$(MAKE) -C $(NCURSES_HOST_BUILD_DIR) clean

ncurses-dirclean:
	rm -rf $(NCURSES_DIR) $(NCURSES_HOST_BUILD_DIR) \
	$(NCURSES_IPK_DIR) $(NCURSES_IPK) \
	$(NCURSES_BASE_IPK_DIR) $(NCURSES_BASE_IPK) \
	$(NCURSES_DEV_IPK_DIR) $(NCURSES_DEV_IPK) \

ncurses-check: $(NCURSES_IPK) $(NCURSES_BASE_IPK) $(NCURSES_DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
