#############################################################
#
# libtermcap
#
#############################################################

TERMCAP_DIR:=$(BUILD_DIR)/termcap

TERMCAP_VERSION=1.3.1
TERMCAP=termcap-$(TERMCAP_VERSION)
TERMCAP_SITE=ftp://ftp.gnu.org/gnu/termcap/
TERMCAP_SOURCE:=$(TERMCAP).tar.gz
TERMCAP_UNZIP=zcat
TERMCAP_IPK=$(BUILD_DIR)/termcap_$(TERMCAP_VERSION)-1_armeb.ipk
TERMCAP_IPK_DIR:=$(BUILD_DIR)/termcap-$(TERMCAP_VERSION)-ipk

$(DL_DIR)/$(TERMCAP_SOURCE):
	$(WGET) -P $(DL_DIR) $(TERMCAP_SITE)/$(TERMCAP_SOURCE)

termcap-source: $(DL_DIR)/$(TERMCAP_SOURCE) $(TERMCAP_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(TERMCAP_DIR)/.configured: $(DL_DIR)/$(TERMCAP_SOURCE)
	@rm -rf $(BUILD_DIR)/$(TERMCAP) $(TERMCAP_DIR)
	$(TERMCAP_UNZIP) $(DL_DIR)/$(TERMCAP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TERMCAP) $(TERMCAP_DIR)
	(cd $(TERMCAP_DIR) && \
   ./configure --disable-tv --without-tv)
	touch $(TERMCAP_DIR)/.configured

termcap-unpack: $(TERMCAP_DIR)/.configured

$(TERMCAP_DIR)/termcap: $(TERMCAP_DIR)/.configured
	make -C $(TERMCAP_DIR) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) 

termcap: $(TERMCAP_DIR)/termcap

$(TERMCAP_IPK): $(TERMCAP_DIR)/termcap
	install -d $(TERMCAP_IPK_DIR)/CONTROL
	mkdir -p $(TERMCAP_IPK_DIR)/opt/lib 
	cp $(TERMCAP_DIR)/libtermcap.a $(TERMCAP_IPK_DIR)/opt/lib 
	install -m 644 $(SOURCE_DIR)/termcap.control  $(TERMCAP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TERMCAP_IPK_DIR)

$(STAGING_DIR)/lib/libtermcap.a: $(TERMCAP_DIR)/termcap
	cp -dfp $(TERMCAP_DIR)/libtermcap.a $(STAGING_DIR)/lib

termcap-ipk: $(TERMCAP_IPK) $(STAGING_DIR)/lib/libtermcap.a

termcap-clean:
	-make -C $(TERMCAP_DIR) clean

termcap-dirclean:
	rm -rf $(TERMCAP_DIR) $(TERMCAP_IPK_DIR) $(TERMCAP_IPK)
