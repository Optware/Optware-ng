###########################################################
#
# ncurses
#
###########################################################

NCURSES_DIR=$(BUILD_DIR)/ncurses

NCURSES_VERSION=5.4
NCURSES_SHLIBVERSION=5
NCURSES=ncurses-$(NCURSES_VERSION)
NCURSES_SITE=ftp://invisible-island.net/ncurses
NCURSES_SOURCE=$(NCURSES).tar.gz
NCURSES_UNZIP=zcat

NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-2_armeb.ipk
NCURSES_IPK_DIR=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

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
	touch $(NCURSES_DIR)/.configured

ncurses-unpack: $(NCURSES_DIR)/.configured

$(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION): $(NCURSES_DIR)/.configured
	$(MAKE) -C $(NCURSES_DIR)

ncurses: $(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

$(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION): $(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(STAGING_DIR) install.includes install.libs

ncurses-stage: $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)

$(NCURSES_IPK): $(STAGING_DIR)/opt/lib/libncurses.so.$(NCURSES_SHLIBVERSION)
	rm -rf $(NCURSES_IPK_DIR) $(BUILD_DIR)/ncurses_*_armeb.ipk
	mkdir -p $(NCURSES_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/ncurses.control $(NCURSES_IPK_DIR)/CONTROL/control
	$(MAKE) -C $(NCURSES_DIR) DESTDIR=$(NCURSES_IPK_DIR) \
		install.libs install.progs install.data install.panel install.menu install.form
	rm -rf $(NCURSES_IPK_DIR)/opt/include
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK)

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean

ncurses-dirclean:
	rm -rf $(NCURSES_DIR) $(NCURSES_IPK_DIR) $(NCURSES_IPK)
