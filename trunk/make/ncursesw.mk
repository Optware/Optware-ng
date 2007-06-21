###########################################################
#
# ncurses
#
###########################################################

NCURSESW_DIR=$(BUILD_DIR)/ncursesw

NCURSESW_VERSION=5.6
NCURSESW_SHLIBVERSION=5
NCURSESW_SITE=ftp://invisible-island.net/ncurses
NCURSESW_SOURCE=ncurses-$(NCURSESW_VERSION).tar.gz
NCURSESW_UNZIP=zcat
NCURSESW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NCURSESW_DESCRIPTION=NCurses libraries with wide char support.
NCURSESW_SECTION=net
NCURSESW_PRIORITY=optional
NCURSESW_DEPENDS=ncurses
NCURSESW_CONFLICTS=

NCURSESW_IPK_VERSION=1

NCURSESW_IPK=$(BUILD_DIR)/ncursesw_$(NCURSESW_VERSION)-$(NCURSESW_IPK_VERSION)_$(TARGET_ARCH).ipk
NCURSESW_IPK_DIR=$(BUILD_DIR)/ncursesw-$(NCURSESW_VERSION)-ipk

.PHONY: ncursesw-source ncursesw-unpack ncursesw ncursesw-stage ncursesw-ipk ncursesw-clean ncursesw-dirclean ncursesw-check

ncursesw-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSESW_DIR)/.source: $(DL_DIR)/$(NCURSESW_SOURCE)
	$(NCURSESW_UNZIP) $(DL_DIR)/$(NCURSESW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NCURSES) $(NCURSESW_DIR)
	touch $(NCURSESW_DIR)/.source

$(NCURSESW_DIR)/.configured: $(NCURSESW_DIR)/.source
	$(MAKE) zlib-stage
	(cd $(NCURSESW_DIR); \
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
		--enable-widec		\
		--enable-safe-sprintf	\
	);
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -ie '/^CPPFLAGS/s| -I$$[{(]includedir[)}]||' $(NCURSESW_DIR)/*/Makefile
endif
	touch $(NCURSESW_DIR)/.configured

ncursesw-unpack: $(NCURSESW_DIR)/.configured

$(NCURSESW_DIR)/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION): $(NCURSESW_DIR)/.configured
	$(MAKE) -C $(NCURSESW_DIR)

ncursesw: $(NCURSESW_DIR)/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION)

$(STAGING_DIR)/opt/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION): $(NCURSESW_DIR)/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION)
	$(MAKE) -C $(NCURSESW_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs
	ln -sf ncurses/ncurses.h $(STAGING_INCLUDE_DIR)

ncursesw-stage: $(STAGING_DIR)/opt/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION)

$(NCURSESW_IPK_DIR)/CONTROL/control:
	@install -d $(NCURSESW_IPK_DIR)/CONTROL
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

$(NCURSESW_IPK): $(STAGING_DIR)/opt/lib/libncursesw.so.$(NCURSESW_SHLIBVERSION)
	rm -rf $(NCURSESW_IPK_DIR) $(BUILD_DIR)/ncursesw_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NCURSESW_DIR) DESTDIR=$(NCURSESW_IPK_DIR) \
		install.libs install.panel install.menu install.form
	rm -rf $(NCURSESW_IPK_DIR)/opt/include
	rm -f $(NCURSESW_IPK_DIR)/opt/lib/*.a
#	$(STRIP_COMMAND) $(NCURSESW_IPK_DIR)/opt/bin/*
	$(STRIP_COMMAND) $(NCURSESW_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(NCURSESW_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSESW_IPK_DIR)

ncursesw-ipk: $(NCURSESW_IPK)

ncursesw-clean:
	-$(MAKE) -C $(NCURSESW_DIR) clean

ncursesw-dirclean:
	rm -rf $(NCURSESW_DIR) $(NCURSESW_IPK_DIR) $(NCURSESW_IPK)

ncursesw-check: $(NCURSESW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NCURSESW_IPK)
