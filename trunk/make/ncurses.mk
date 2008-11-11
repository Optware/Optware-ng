###########################################################
#
# ncurses
#
###########################################################

NCURSES_DIR=$(BUILD_DIR)/ncurses

NCURSES_VERSION=5.7
NCURSES=ncurses-$(NCURSES_VERSION)
NCURSES_SITE=ftp://invisible-island.net/ncurses
NCURSES_SOURCE=$(NCURSES).tar.gz
NCURSES_UNZIP=zcat
NCURSES_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
NCURSES_DESCRIPTION=NCurses libraries
NCURSES_SECTION=net
NCURSES_PRIORITY=optional
NCURSES_DEPENDS=
NCURSES_CONFLICTS=

ifneq ($(OPTWARE_TARGET), wl500g)
NCURSES_FOR_OPTWARE_TARGET=ncursesw
else
NCURSES_FOR_OPTWARE_TARGET=ncurses
endif

NCURSES_IPK_VERSION=1

NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSES_IPK_DIR=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

NCURSES_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/ncurses

.PHONY: ncurses-source ncurses-unpack ncurses ncurses-stage ncurses-ipk ncurses-clean ncurses-dirclean ncurses-check

$(DL_DIR)/$(NCURSES_SOURCE):
	$(WGET) -P $(@D) $(NCURSES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ncurses-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSES_HOST_BUILD_DIR)/.built: $(HOST_BUILD_DIR)/.configured $(DL_DIR)/$(NCURSES_SOURCE) make/ncurses.mk
	rm -rf $(HOST_BUILD_DIR)/$(NCURSES) $(@D)
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(NCURSES) $(@D)
	(cd $(@D); \
		./configure \
		--prefix=/opt	\
		--without-shared	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
	)
	$(MAKE) -C $(@D)/include
	$(MAKE) -C $(@D)/progs tic
	touch $@

ncurses-host: $(NCURSES_HOST_BUILD_DIR)/.built

$(NCURSES_DIR)/.configured: $(DL_DIR)/$(NCURSES_SOURCE) make/ncurses.mk
	$(MAKE) zlib-stage
ifneq ($(HOSTCC), $(TARGET_CC))
	$(MAKE) ncurses-host
endif
	rm -rf $(BUILD_DIR)/$(NCURSES) $(@D)
	rm -rf  $(STAGING_INCLUDE_DIR)/ncurses \
		$(STAGING_LIB_DIR)/libform.* \
		$(STAGING_LIB_DIR)/libmenu.* \
		$(STAGING_LIB_DIR)/libncurses.* \
		$(STAGING_LIB_DIR)/libpanel.*
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NCURSES) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt	\
		--with-shared		\
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
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs
	ln -sf ncurses/ncurses.h $(STAGING_INCLUDE_DIR)
	touch $@

ncurses-stage: $(NCURSES_DIR)/.staged

$(NCURSES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(NCURSES_IPK): $(NCURSES_DIR)/.built
	rm -rf $(NCURSES_IPK_DIR) $(BUILD_DIR)/ncurses_*_$(TARGET_ARCH).ipk
	$(if $(filter $(HOSTCC), $(TARGET_CC)),,PATH=$(NCURSES_HOST_BUILD_DIR)/progs:$$PATH) \
		$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(NCURSES_IPK_DIR) \
		install.libs install.progs install.data
	rm -rf $(NCURSES_IPK_DIR)/opt/include
	rm -f $(NCURSES_IPK_DIR)/opt/lib/*.a
	$(STRIP_COMMAND) $(NCURSES_IPK_DIR)/opt/bin/clear \
		$(NCURSES_IPK_DIR)/opt/bin/infocmp $(NCURSES_IPK_DIR)/opt/bin/t*
	$(STRIP_COMMAND) $(NCURSES_IPK_DIR)/opt/lib/*$(SO).5$(DYLIB)
ifeq (darwin, $(TARGET_OS))
	for dylib in $(NCURSES_IPK_DIR)/opt/lib/*$(SO).5$(DYLIB); do \
	$(TARGET_CROSS)install_name_tool -change $$dylib /opt/lib/`basename $$dylib` $$dylib; \
	done
endif
	$(MAKE) $(NCURSES_IPK_DIR)/CONTROL/control
	mv $(NCURSES_IPK_DIR)/opt/bin/clear $(NCURSES_IPK_DIR)/opt/bin/ncurses-clear
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --install /opt/bin/clear clear /opt/bin/ncurses-clear 80"; \
	) > $(NCURSES_IPK_DIR)/CONTROL/postinst
	(echo "#!/bin/sh"; \
	 echo "update-alternatives --remove clear /opt/bin/ncurses-clear"; \
	) > $(NCURSES_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(NCURSES_IPK_DIR)/CONTROL/postinst $(NCURSES_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK)

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean

ncurses-dirclean:
	rm -rf $(NCURSES_DIR) $(NCURSES_IPK_DIR) $(NCURSES_IPK)

ncurses-check: $(NCURSES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NCURSES_IPK)
