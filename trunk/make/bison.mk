###########################################################
#
# bison
#
###########################################################

BISON_DIR=$(BUILD_DIR)/bison

BISON_VERSION=1.875
BISON=bison-$(BISON_VERSION)
BISON_SITE=ftp://ftp.gnu.org/gnu/bison
BISON_SOURCE=$(BISON).tar.gz
BISON_UNZIP=zcat

BISON_IPK=$(BUILD_DIR)/bison_$(BISON_VERSION)-1_armeb.ipk
BISON_IPK_DIR=$(BUILD_DIR)/bison-$(BISON_VERSION)-ipk

$(DL_DIR)/$(BISON_SOURCE):
	$(WGET) -P $(DL_DIR) $(BISON_SITE)/$(BISON_SOURCE)

bison-source: $(DL_DIR)/$(BISON_SOURCE)

$(BISON_DIR)/.source: $(DL_DIR)/$(BISON_SOURCE)
	$(BISON_UNZIP) $(DL_DIR)/$(BISON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/bison-$(BISON_VERSION) $(BISON_DIR)
	touch $(BISON_DIR)/.source

$(BISON_DIR)/.configured: $(BISON_DIR)/.source
	(cd $(BISON_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BISON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BISON_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	);
	touch $(BISON_DIR)/.configured

$(BISON_DIR)/src/bison: $(BISON_DIR)/.configured
	$(MAKE) -C $(BISON_DIR)

bison: $(BISON_DIR)/src/bison

$(BISON_IPK): $(BISON_DIR)/src/bison
	mkdir -p $(BISON_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/bison.control $(BISON_IPK_DIR)/CONTROL/control
	# for now ignore the locale files
	install -d $(BISON_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BISON_DIR)/src/bison -o $(BISON_IPK_DIR)/opt/bin/bison
	cp $(BISON_DIR)/src/yacc $(BISON_IPK_DIR)/opt/bin/yacc
	install -d $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_DIR)/data/README   $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_DIR)/data/c.m4     $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_DIR)/data/glr.c    $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_DIR)/data/lalr1.cc $(BISON_IPK_DIR)/opt/share/bison
	cp $(BISON_DIR)/data/yacc.c   $(BISON_IPK_DIR)/opt/share/bison
	install -d $(BISON_IPK_DIR)/opt/share/bison/m4sugar
	cp $(BISON_DIR)/data/m4sugar/m4sugar.m4 $(BISON_IPK_DIR)/opt/share/bison/m4sugar
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BISON_IPK_DIR)

bison-ipk: $(BISON_IPK)

bison-source: $(DL_DIR)/$(BISON_SOURCE)

bison-clean:
	-$(MAKE) -C $(BISON_DIR) uninstall
	-$(MAKE) -C $(BISON_DIR) clean

bison-distclean:
	-rm $(BISON_DIR)/.configured
	-$(MAKE) -C $(BISON_DIR) distclean

