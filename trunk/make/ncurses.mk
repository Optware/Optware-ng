###########################################################
#
# ncurses
#
###########################################################

#
# TODO: Prevent generation and installation of man pages
#

NCURSES_DIR=$(BUILD_DIR)/ncurses

NCURSES_VERSION=5.4
NCURSES_SHLIBVERSION=5
NCURSES=ncurses-$(NCURSES_VERSION)
NCURSES_SITE=ftp://invisible-island.net/ncurses
NCURSES_SOURCE=$(NCURSES).tar.gz
NCURSES_UNZIP=zcat

NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-1_armeb.ipk
NCURSES_IPK_DIR=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

$(DL_DIR)/$(NCURSES_SOURCE):
	$(WGET) -P $(DL_DIR) $(NCURSES_SITE)/$(NCURSES_SOURCE)

ncurses-source: $(DL_DIR)/$(NCURSES_SOURCE)

$(NCURSES_DIR)/.source: $(DL_DIR)/$(NCURSES_SOURCE)
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NCURSES) $(NCURSES_DIR)
	touch $(NCURSES_DIR)/.source

$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.source
	(cd $(NCURSES_DIR); \
	export CC=$(TARGET_CC) ; \
	export CPPFLAGS="$(STAGING_CPPFLAGS)"; \
	export LDFLAGS="$(STAGING_LDFLAGS)"; \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt	\
		--with-shared		\
		--without-progs		\
		--disable-big-core	\
		--with-build-cc=gcc	\
		--without-cxx-binding	\
		--without-ada		\
	);
	touch $(NCURSES_DIR)/.configured

$(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION): $(NCURSES_DIR)/.configured
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) install

ncurses-stage: $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

ncurses-headers: $(STAGING_DIR)/opt/lib/libncurses.a

ncurses: zlib $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

$(NCURSES_IPK): $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	mkdir -p $(NCURSES_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/ncurses.control $(NCURSES_IPK_DIR)/CONTROL/control
	mkdir -p $(NCURSES_IPK_DIR)/opt/include
	mkdir -p $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/curses.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/eti.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/form.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/menu.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/ncurses_dll.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/ncurses.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/panel.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/termcap.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/term.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	cp -dpf $(STAGING_DIR)/opt/include/ncurses/unctrl.h $(NCURSES_IPK_DIR)/opt/include/ncurses
	mkdir -p $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libform.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libform_g.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libform.so* $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libmenu.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libmenu_g.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libmenu.so* $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libncurses.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libncurses_g.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libncurses.so* $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libpanel.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libpanel_g.a $(NCURSES_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/opt/lib/libpanel.so* $(NCURSES_IPK_DIR)/opt/lib
	-$(STRIP) --strip-unneeded $(NCURSES_IPK_DIR)/opt/lib/libform.so*
	-$(STRIP) --strip-unneeded $(NCURSES_IPK_DIR)/opt/lib/libmenu.so*
	-$(STRIP) --strip-unneeded $(NCURSES_IPK_DIR)/opt/lib/libncurses.so*
	-$(STRIP) --strip-unneeded $(NCURSES_IPK_DIR)/opt/lib/libpanel.so*
	touch -c $(NCURSES_IPK_DIR)/opt/lib/libform.so.$(NCURSES_SHLIBVERSION)
	touch -c $(NCURSES_IPK_DIR)/opt/lib/libmenu.so.$(NCURSES_SHLIBVERSION)
	touch -c $(NCURSES_IPK_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	touch -c $(NCURSES_IPK_DIR)/opt/lib/libpanel.so.$(NCURSES_SHLIBVERSION)
	mkdir -p $(NCURSES_IPK_DIR)/opt/share
	mkdir -p $(NCURSES_IPK_DIR)/opt/share/tabset
	mkdir -p $(NCURSES_IPK_DIR)/opt/share/terminfo
	cp -dpf $(STAGING_DIR)/opt/share/tabset/* $(NCURSES_IPK_DIR)/opt/share/tabset
	cp -dpfr $(STAGING_DIR)/opt/share/terminfo/* $(NCURSES_IPK_DIR)/opt/share/terminfo
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK)

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) uninstall
	-$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) clean

ncurses-dirclean: ncurses-clean
	rm -rf $(NCURSES_DIR) $(NCURSES_IPK_DIR) $(NCURSES_IPK)

ncurses-distclean:
	-rm $(NCURSES_DIR)/.configured
	-$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) distclean
