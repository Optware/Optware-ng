###########################################################
#
# ncurses
#
###########################################################

NCURSES_DIR=$(BUILD_DIR)/ncurses

NCURSES_VERSION=5.6
NCURSES_SHLIBVERSION=5
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

NCURSES_IPK_VERSION=2

NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-$(NCURSES_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSES_IPK_DIR=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

.PHONY: ncurses-source ncurses-unpack ncurses ncurses-stage ncurses-ipk ncurses-clean ncurses-dirclean ncurses-check

$(DL_DIR)/$(NCURSES_SOURCE):
	$(WGET) -P $(DL_DIR) $(NCURSES_SITE)/$(NCURSES_SOURCE)

ncurses-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSES_DIR)/.source: $(DL_DIR)/$(NCURSES_SOURCE)
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NCURSES) $(NCURSES_DIR)
	touch $(NCURSES_DIR)/.source

$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.source
	$(MAKE) zlib-stage
	(cd $(NCURSES_DIR); \
	export CC=$(TARGET_CC) ; \
	export CXX=$(TARGET_CXX) ; \
	export CPPFLAGS="$(STAGING_CPPFLAGS)"; \
	export LDFLAGS="$(STAGING_LDFLAGS)"; \
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
	sed -i -e '/^CPPFLAGS/s| -I$$[{(]includedir[)}]||' $(NCURSES_DIR)/*/Makefile
endif
	touch $(NCURSES_DIR)/.configured

ncurses-unpack: $(NCURSES_DIR)/.configured

$(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION): $(NCURSES_DIR)/.configured
	$(MAKE) -C $(NCURSES_DIR)

ncurses: $(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

$(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION): $(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs
	ln -sf ncurses/ncurses.h $(STAGING_INCLUDE_DIR)

ncurses-stage: $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

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

$(NCURSES_IPK): $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	rm -rf $(NCURSES_IPK_DIR) $(BUILD_DIR)/ncurses_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(NCURSES_IPK_DIR) \
		install.libs install.progs install.data install.panel install.menu install.form
	rm -rf $(NCURSES_IPK_DIR)/opt/include
	rm -f $(NCURSES_IPK_DIR)/opt/lib/*.a
	$(STRIP_COMMAND) $(NCURSES_IPK_DIR)/opt/bin/*
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
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK)

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean

ncurses-dirclean:
	rm -rf $(NCURSES_DIR) $(NCURSES_IPK_DIR) $(NCURSES_IPK)

ncurses-check: $(NCURSES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NCURSES_IPK)
