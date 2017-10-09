###########################################################
#
# ntpclient
#
###########################################################

NTPCLIENT_SITE=http://doolittle.icarus.com/ntpclient
NTPCLIENT_VERSION=2007_365
NTPCLIENT_SOURCE=ntpclient_$(NTPCLIENT_VERSION).tar.gz
NTPCLIENT_DIR=ntpclient-2007
NTPCLIENT_UNZIP=zcat
NTPCLIENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NTPCLIENT_DESCRIPTION=Using RFC1305 (NTP), retrieves a remote date and time
NTPCLIENT_SECTION=network
NTPCLIENT_PRIORITY=optional
NTPCLIENT_DEPENDS=
NTPCLIENT_CONFLICTS=

NTPCLIENT_IPK_VERSION=2

NTPCLIENT_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), ts101)
NTPCLIENT_CPPFLAGS+=-DUSE_OBSOLETE_GETTIMEOFDAY
endif
NTPCLIENT_LDFLAGS=-lrt
ifeq ($(OPTWARE_TARGET), $(filter vt4, $(OPTWARE_TARGET)))
NTPCLIENT_LDFLAGS+=-lpthread
endif
ifeq ($(LIBC_STYLE), uclibc)
NTPCLIENT_CPPFLAGS += -D__adjtimex=adjtimex
endif

NTPCLIENT_BUILD_DIR=$(BUILD_DIR)/ntpclient
NTPCLIENT_SOURCE_DIR=$(SOURCE_DIR)/ntpclient
NTPCLIENT_IPK_DIR=$(BUILD_DIR)/ntpclient-$(NTPCLIENT_VERSION)-ipk
NTPCLIENT_IPK=$(BUILD_DIR)/ntpclient_$(NTPCLIENT_VERSION)-$(NTPCLIENT_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(NTPCLIENT_SOURCE):
	$(WGET) -P $(@D) $(NTPCLIENT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ntpclient-source: $(DL_DIR)/$(NTPCLIENT_SOURCE)

$(NTPCLIENT_BUILD_DIR)/.configured: $(DL_DIR)/$(NTPCLIENT_SOURCE) make/ntpclient.mk
	rm -rf $(BUILD_DIR)/$(NTPCLIENT_DIR) $(@D)
	$(NTPCLIENT_UNZIP) $(DL_DIR)/$(NTPCLIENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(NTPCLIENT_DIR)" != "$(@D)" ; \
	then mv $(BUILD_DIR)/$(NTPCLIENT_DIR) $(@D) ; \
	fi
	touch $@

ntpclient-unpack: $(NTPCLIENT_BUILD_DIR)/.configured

$(NTPCLIENT_BUILD_DIR)/.built: $(NTPCLIENT_BUILD_DIR)/.configured make/ntpclient.mk
	rm -f $@
	$(MAKE) -C $(@D) ntpclient adjtimex \
		CC=$(TARGET_CC) \
		CPPFLAGS="$(NTPCLIENT_CPPFLAGS)" \
		RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) \
		LD=$(TARGET_LD) \
		LDFLAGS="$(STAGING_LDFLAGS) $(NTPCLIENT_LDFLAGS)"
	touch $@

ntpclient: $(NTPCLIENT_BUILD_DIR)/.built

$(NTPCLIENT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ntpclient" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTPCLIENT_PRIORITY)" >>$@
	@echo "Section: $(NTPCLIENT_SECTION)" >>$@
	@echo "Version: $(NTPCLIENT_VERSION)-$(NTPCLIENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTPCLIENT_MAINTAINER)" >>$@
	@echo "Source: $(NTPCLIENT_SITE)/$(NTPCLIENT_SOURCE)" >>$@
	@echo "Description: $(NTPCLIENT_DESCRIPTION)" >>$@
	@echo "Depends: $(NTPCLIENT_DEPENDS)" >>$@
	@echo "Conflicts: $(NTPCLIENT_CONFLICTS)" >>$@

$(NTPCLIENT_IPK): $(NTPCLIENT_BUILD_DIR)/.built
	rm -rf $(NTPCLIENT_IPK_DIR) $(BUILD_DIR)/ntpclient_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(NTPCLIENT_BUILD_DIR)/ntpclient -o $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/bin/ntpclient
	$(INSTALL) -d $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/sbin
	$(STRIP_COMMAND) $(NTPCLIENT_BUILD_DIR)/adjtimex -o $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/sbin/adjtimex
	$(INSTALL) -d $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) $(NTPCLIENT_BUILD_DIR)/ntpclient.1 $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) $(NTPCLIENT_BUILD_DIR)/adjtimex.1 $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) -d $(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/share/doc/ntpclient
	$(INSTALL) $(NTPCLIENT_BUILD_DIR)/[RH]* \
		$(NTPCLIENT_BUILD_DIR)/*.awk \
		$(NTPCLIENT_BUILD_DIR)/*.pl \
		$(NTPCLIENT_BUILD_DIR)/test.dat \
		$(NTPCLIENT_IPK_DIR)$(TARGET_PREFIX)/share/doc/ntpclient
	$(MAKE) $(NTPCLIENT_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(NTPCLIENT_SOURCE_DIR)/postinst $(NTPCLIENT_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(NTPCLIENT_SOURCE_DIR)/prerm $(NTPCLIENT_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTPCLIENT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(NTPCLIENT_IPK_DIR)

ntpclient-ipk: $(NTPCLIENT_IPK)

ntpclient-clean:
	-$(MAKE) -C $(NTPCLIENT_BUILD_DIR) clean

ntpclient-dirclean:
	rm -rf $(BUILD_DIR)/$(NTPCLIENT_DIR) $(NTPCLIENT_BUILD_DIR) $(NTPCLIENT_IPK_DIR) $(NTPCLIENT_IPK)

ntpclient-check: $(NTPCLIENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NTPCLIENT_IPK)
