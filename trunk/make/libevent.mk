#############################################################
#
# libevent
#
#############################################################

LIBEVENT_DIR=$(BUILD_DIR)/libevent

LIBEVENT_VERSION:=0.9
LIBEVENT_SITE=http://www.monkey.org/~provos/
LIBEVENT_SOURCE=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_CFLAGS= $(TARGET_CFLAGS) -fPIC

LIBEVENT_IPK_DIR=$(BUILD_DIR)/libevent-$(LIBEVENT_VERSION)-ipk
LIBEVENT_IPK=$(BUILD_DIR)/libevent_$(LIBEVENT_VERSION)-1_armeb.ipk

$(DL_DIR)/$(LIBEVENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)

$(LIBEVENT_DIR)/.source: $(DL_DIR)/$(LIBEVENT_SOURCE)
	zcat $(DL_DIR)/$(LIBEVENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/libevent-$(LIBEVENT_VERSION) $(LIBEVENT_DIR)
	touch $(LIBEVENT_DIR)/.source

$(LIBEVENT_DIR)/.configured: $(LIBEVENT_DIR)/.source
	(cd $(LIBEVENT_DIR); \
		./configure \
		--prefix=/opt \
		--exec-prefix=$(STAGING_DIR)/usr/bin \
		--libdir=$(STAGING_DIR)/lib \
		--includedir=$(STAGING_DIR)/include \
		--host=$(GNU_TARGET_NAME) \
	);
	touch $(LIBEVENT_DIR)/.configured;

$(LIBEVENT_DIR)/libevent.a: $(LIBEVENT_DIR)/.configured
	$(MAKE) -C $(LIBEVENT_DIR) RANLIB="$(TARGET_RANLIB)" AR="$(TARGET_AR)"

$(STAGING_DIR)/lib/libevent.a: $(LIBEVENT_DIR)/libevent.a
	cp -dpf $(LIBEVENT_DIR)/libevent.a $(STAGING_DIR)/lib/libevent.a
	cp -dpf $(LIBEVENT_DIR)/event.h $(STAGING_DIR)/include/event.h
	cp -dpf $(LIBEVENT_DIR)/event.3 $(STAGING_DIR)/man/man3/

libevent-headers: $(STAGING_DIR)/lib/libevent.so.$(LIBEVENT_VERSION)

libevent: $(STAGING_DIR)/lib/libevent.so.$(LIBEVENT_VERSION)

$(LIBEVENT_IPK): $(STAGING_DIR)/lib/libevent.a
	mkdir -p $(LIBEVENT_IPK_DIR)/CONTROL
	cp $(SOURCE_DIR)/libevent.control $(LIBEVENT_IPK_DIR)/CONTROL/control
	mkdir -p $(LIBEVENT_IPK_DIR)/opt/include
	cp -dpf $(STAGING_DIR)/include/event.h $(LIBEVENT_IPK_DIR)/opt/include
	mkdir -p $(LIBEVENT_IPK_DIR)/opt/lib
	cp -dpf $(STAGING_DIR)/lib/libevent.a $(LIBEVENT_IPK_DIR)/opt/lib
	mkdir -p $(LIBEVENT_IPK_DIR)/opt/man/man3
	cp -dpf $(STAGING_DIR)/man/man3/event.3 $(LIBEVENT_IPK_DIR)/opt/man/man3
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEVENT_IPK_DIR)

libevent-ipk: $(LIBEVENT_IPK)

libevent-source: $(DL_DIR)/$(LIBEVENT_SOURCE)

libevent-clean:
	rm -f $(STAGING_DIR)/lib/libevent.*
	rm -f $(STAGING_DIR)/include/event.h
	-$(MAKE) -C $(LIBEVENT_DIR) clean

libevent-dirclean:
	rm -rf $(LIBEVENT_DIR) $(LIBEVENT_IPK_DIR) $(LIBEVENT_IPK)
