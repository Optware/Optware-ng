#############################################################
#
# libtermcap
#
#############################################################

TERMCAP_SITE=ftp://ftp.gnu.org/gnu/termcap/
TERMCAP_VERSION=1.3.1
TERMCAP_SOURCE:=termcap-$(TERMCAP_VERSION).tar.gz
TERMCAP_DIR=termcap-$(TERMCAP_VERSION)
TERMCAP_UNZIP=zcat

TERMCAP_IPK_VERSION=1

TERMCAP_CPPFLAGS=
TERMCAP_LDFLAGS=

TERMCAP_BUILD_DIR:=$(BUILD_DIR)/termcap
TERMCAP_SOURCE_DIR:=$(SOURCE_DIR)/termcap
TERMCAP_IPK_DIR:=$(BUILD_DIR)/termcap-$(TERMCAP_VERSION)-ipk
TERMCAP_IPK=$(BUILD_DIR)/termcap_$(TERMCAP_VERSION)-$(TERMCAP_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(TERMCAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(TERMCAP_SITE)/$(TERMCAP_SOURCE)

termcap-source: $(DL_DIR)/$(TERMCAP_SOURCE)

$(TERMCAP_BUILD_DIR)/.configured: $(DL_DIR)/$(TERMCAP_SOURCE)
	rm -rf $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR)
	$(TERMCAP_UNZIP) $(DL_DIR)/$(TERMCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR)
	(cd $(TERMCAP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TERMCAP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TERMCAP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-install-termcap \
		--with-termcap=/opt/etc/termcap \
	)
	touch $(TERMCAP_BUILD_DIR)/.configured

termcap-unpack: $(TERMCAP_BUILD_DIR)/.configured

$(TERMCAP_BUILD_DIR)/libtermcap.a: $(TERMCAP_BUILD_DIR)/.configured
	make -C $(TERMCAP_BUILD_DIR) AR=$(TARGET_AR)

termcap: $(TERMCAP_BUILD_DIR)/libtermcap.a

$(STAGING_DIR)/opt/lib/libtermcap.a: $(TERMCAP_BUILD_DIR)/libtermcap.a
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(TERMCAP_BUILD_DIR)/termcap.h $(STAGING_DIR)/opt/include
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(TERMCAP_BUILD_DIR)/libtermcap.a $(STAGING_DIR)/opt/lib

termcap-stage: $(STAGING_DIR)/opt/lib/libtermcap.a

$(TERMCAP_IPK): $(TERMCAP_BUILD_DIR)/libtermcap.a
	install -d $(TERMCAP_IPK_DIR)/opt/include
	install -m 644 $(TERMCAP_BUILD_DIR)/termcap.h $(TERMCAP_IPK_DIR)/opt/include/termcap.h
	install -d $(TERMCAP_IPK_DIR)/opt/lib
	install -m 644 $(TERMCAP_BUILD_DIR)/libtermcap.a $(TERMCAP_IPK_DIR)/opt/lib/libtermcap.a
	install -d $(TERMCAP_IPK_DIR)/opt/etc
	install -m 644 $(TERMCAP_BUILD_DIR)/termcap.src $(TERMCAP_IPK_DIR)/opt/etc/termcap
	install -d $(TERMCAP_IPK_DIR)/CONTROL
	install -m 644 $(TERMCAP_SOURCE_DIR)/control  $(TERMCAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TERMCAP_IPK_DIR)

termcap-ipk: $(TERMCAP_IPK)

termcap-clean:
	-make -C $(TERMCAP_BUILD_DIR) clean

termcap-dirclean:
	rm -rf $(BUILD_DIR)/$(TERMCAP_DIR) $(TERMCAP_BUILD_DIR) $(TERMCAP_IPK_DIR) $(TERMCAP_IPK)
