#############################################################
#
# libevent
#
#############################################################

LIBEVENT_SITE=http://www.monkey.org/~provos/
LIBEVENT_VERSION=0.9
LIBEVENT_SOURCE=libevent-$(LIBEVENT_VERSION).tar.gz
LIBEVENT_DIR=libevent-$(LIBEVENT_VERSION)
LIBEVENT_UNZIP=zcat

LIBEVENT_IPK_VERSION=1

LIBEVENT_CPPFLAGS= -fPIC

LIBEVENT_BUILD_DIR=$(BUILD_DIR)/libevent
LIBEVENT_SOURCE_DIR=$(SOURCE_DIR)/libevent
LIBEVENT_IPK_DIR=$(BUILD_DIR)/libevent-$(LIBEVENT_VERSION)-ipk
LIBEVENT_IPK=$(BUILD_DIR)/libevent_$(LIBEVENT_VERSION)-$(LIBEVENT_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(LIBEVENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBEVENT_SITE)/$(LIBEVENT_SOURCE)

libevent-source: $(DL_DIR)/$(LIBEVENT_SOURCE)

$(LIBEVENT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBEVENT_SOURCE)
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(LIBEVENT_BUILD_DIR)
	$(LIBEVENT_UNZIP) $(DL_DIR)/$(LIBEVENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/libevent-$(LIBEVENT_VERSION) $(LIBEVENT_BUILD_DIR)
	(cd $(LIBEVENT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(LIBEVENT_CPPFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(LIBEVENT_BUILD_DIR)/.configured

libevent-unpack: $(LIBEVENT_BUILD_DIR)/.configured

$(LIBEVENT_BUILD_DIR)/libevent.a: $(LIBEVENT_BUILD_DIR)/.configured
	$(MAKE) -C $(LIBEVENT_BUILD_DIR)

libevent: $(LIBEVENT_BUILD_DIR)/libevent.a

$(STAGING_DIR)/opt/lib/libevent.a: $(LIBEVENT_BUILD_DIR)/libevent.a
	install -d $(STAGING_DIR)/opt/include
	install -m 644 $(LIBEVENT_BUILD_DIR)/event.h $(STAGING_DIR)/opt/include/event.h
	install -d $(STAGING_DIR)/opt/lib
	install -m 644 $(LIBEVENT_BUILD_DIR)/libevent.a $(STAGING_DIR)/opt/lib/libevent.a

libevent-stage: $(STAGING_DIR)/opt/lib/libevent.a

$(LIBEVENT_IPK): $(LIBEVENT_BUILD_DIR)/libevent.a
	install -d $(LIBEVENT_IPK_DIR)/opt/include
	install -m 644 $(LIBEVENT_BUILD_DIR)/event.h $(LIBEVENT_IPK_DIR)/opt/include
	install -d $(LIBEVENT_IPK_DIR)/opt/lib
	install -m 644 $(LIBEVENT_BUILD_DIR)/libevent.a $(LIBEVENT_IPK_DIR)/opt/lib
	install -d $(LIBEVENT_IPK_DIR)/CONTROL
	install -m 644 $(LIBEVENT_SOURCE_DIR)/control $(LIBEVENT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBEVENT_IPK_DIR)

libevent-ipk: $(LIBEVENT_IPK)

libevent-clean:
	-$(MAKE) -C $(LIBEVENT_BUILD_DIR) clean

libevent-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBEVENT_DIR) $(LIBEVENT_BUILD_DIR) $(LIBEVENT_IPK_DIR) $(LIBEVENT_IPK)
