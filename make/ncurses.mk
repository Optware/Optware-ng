#############################################################
#
# ncurses server
#
#############################################################

NCURSES_DIR:=$(BUILD_DIR)/ncurses

NCURSES_VERSION=5.4
NCURSES=ncurses-$(NCURSES_VERSION)
NCURSES_SITE=ftp://ftp.gnu.org/gnu/ncurses/
NCURSES_SOURCE:=$(NCURSES).tar.gz
NCURSES_UNZIP=zcat
NCURSES_IPK=$(BUILD_DIR)/ncurses_$(NCURSES_VERSION)-1_armeb.ipk
NCURSES_IPK_DIR:=$(BUILD_DIR)/ncurses-$(NCURSES_VERSION)-ipk

CFLAGS:=""
LDFLAGS:="-L$(NCURSES_DIR)/lib -lncurses -lform -lpanel -lmenu -lncurses_g" 
TARGET_CXX="armv5b-softfloat-linux-g++"
TARGET_CC="armv5b-softfloat-linux-gcc"

$(DL_DIR)/$(NCURSES_SOURCE):
	$(WGET) -P $(DL_DIR) $(NCURSES_SITE)/$(NCURSES_SOURCE)

ncurses-source: $(DL_DIR)/$(NCURSES_SOURCE) $(NCURSES_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(NCURSES_DIR)/.configured: $(DL_DIR)/$(NCURSES_SOURCE)
	@rm -rf $(BUILD_DIR)/$(NCURSES) $(NCURSES_DIR)
	$(NCURSES_UNZIP) $(DL_DIR)/$(NCURSES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(NCURSES) $(NCURSES_DIR)
	CC=armv5b-softfloat-linux-gcc
	(cd $(NCURSES_DIR) && \
   CC=$(TARGET_CC) && \
	 CXX=$(TARGET_CXX) && \
	 CFLAGS=$(CFLAGS) && \
   LDFLAGS=$(LDFLAGS) && \
   ./configure --without-progs --without-ada)
	touch $(NCURSES_DIR)/.configured

ncurses-unpack: $(NCURSES_DIR)/.configured

$(NCURSES_DIR)/ncurses: $(NCURSES_DIR)/.configured 
	make -C $(NCURSES_DIR) BUILD_CC=gcc CXX=$(TARGET_CXX) CC=$(TARGET_CC) AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB) CFLAGS=$(CFLAGS) LDFLAGS=$(LDFLAGS)

ncurses: $(NCURSES_DIR)/ncurses

$(NCURSES_IPK): ncurses
	install -d $(NCURSES_IPK_DIR)/CONTROL
	mkdir -p $(NCURSES_IPK_DIR)/opt/libs
	cp $(NCURSES_DIR)/lib/* $(NCURSES_IPK_DIR)/opt/libs
	install -m 644 $(SOURCE_DIR)/ncurses.control  $(NCURSES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCURSES_IPK_DIR)

ncurses-ipk: $(NCURSES_IPK)

ncurses-clean:
	-make -C $(NCURSES_DIR) clean

ncurses-dirclean:
	rm -rf $(NCURSES_DIR) $(NCURSES_IPK_DIR) $(NCURSES_IPK)
