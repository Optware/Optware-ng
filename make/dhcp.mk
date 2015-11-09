#############################################################
#
# dhcp server
#
#############################################################

DHCP_BUILD_DIR:=$(BUILD_DIR)/dhcp

DHCP_VERSION=4.1-ESV-R2
DHCP_DIR=dhcp-$(DHCP_VERSION)
DHCP_SITE=ftp://ftp.isc.org/isc/dhcp/
DHCP_SOURCE:=$(DHCP_DIR).tar.gz
DHCP_UNZIP=zcat
DHCP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DHCP_DESCRIPTION=A DHCP Server
DHCP_SECTION=net
DHCP_PRIORITY=optional
DHCP_DEPENDS=openssl, psmisc
DHCP_SUGGESTS=
DHCP_CONFLICTS=

DHCP_IPK_VERSION=1

DHCP_CONFFILES=$(TARGET_PREFIX)/etc/dhcpd.conf

#DHCP_PATCHES=$(DHCP_SOURCE_DIR)/linux_ipv6_discover.patch

DHCP_CPPFLAGS=
DHCP_LDFLAGS=
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
DHCP_CPPFLAGS+= -DPATH_MAX=4096
endif
DHCP_CONFIG_ARGS ?=

DHCP_IPK=$(BUILD_DIR)/dhcp_$(DHCP_VERSION)-$(DHCP_IPK_VERSION)_$(TARGET_ARCH).ipk
DHCP_IPK_DIR:=$(BUILD_DIR)/dhcp-$(DHCP_VERSION)-ipk

DHCP_SOURCE_DIR=$(SOURCE_DIR)/dhcp

$(DL_DIR)/$(DHCP_SOURCE):
	$(WGET) -P $(@D) $(DHCP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

.PHONY: dhcp-source dhcp-unpack dhcp dhcp-stage dhcp-ipk dhcp-clean dhcp-dirclean dhcp-check

dhcp-source: $(DL_DIR)/$(DHCP_SOURCE) $(DHCP_PATCH)


# make changes to the BUILD options below.  If you are using TCP Wrappers, 
# set --libwrap-directory=pathname 

$(DHCP_BUILD_DIR)/.configured: $(DL_DIR)/$(DHCP_SOURCE) make/dhcp.mk
	$(MAKE) openssl-stage
	@rm -rf $(BUILD_DIR)/$(DHCP_DIR) $(@D)
	$(DHCP_UNZIP) $(DL_DIR)/$(DHCP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DHCP_PATCHES)" ; \
		then cat $(DHCP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DHCP_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(DHCP_DIR) $(@D)
	sed -i -e 's|/\* #define _PATH_DHCPD_PID.*|#define _PATH_DHCPD_PID      "$(TARGET_PREFIX)/var/run/dhcpd.pid"|' $(@D)/includes/site.h
	sed -i -e 's|/\* #define _PATH_DHCPD_DB.*|#define _PATH_DHCPD_DB      "$(TARGET_PREFIX)/etc/dhcpd.leases"|' $(@D)/includes/site.h
	sed -i -e 's|/\* #define _PATH_DHCPD_CONF.*|#define _PATH_DHCPD_CONF      "$(TARGET_PREFIX)/etc/dhcpd.conf"|' $(@D)/includes/site.h
	sed -i -e '/STD_CWARNINGS=/s/ -Werror//' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DHCP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DHCP_LDFLAGS)" \
		ac_cv_file__dev_random=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		$(DHCP_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
	)
	touch $@

dhcp-unpack: $(DHCP_BUILD_DIR)/.configured

$(DHCP_BUILD_DIR)/.built: $(DHCP_BUILD_DIR)/.configured
	rm -f $@
	make -C $(@D)
	touch $@

dhcp: $(DHCP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dhcp
#
$(DHCP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dhcp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DHCP_PRIORITY)" >>$@
	@echo "Section: $(DHCP_SECTION)" >>$@
	@echo "Version: $(DHCP_VERSION)-$(DHCP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DHCP_MAINTAINER)" >>$@
	@echo "Source: $(DHCP_SITE)/$(DHCP_SOURCE)" >>$@
	@echo "Description: $(DHCP_DESCRIPTION)" >>$@
	@echo "Depends: $(DHCP_DEPENDS)" >>$@
	@echo "Suggests: $(DHCP_SUGGESTS)" >>$@
	@echo "Conflicts: $(DHCP_CONFLICTS)" >>$@

$(DHCP_IPK): $(DHCP_BUILD_DIR)/.built
	rm -rf $(DHCP_IPK_DIR) $(BUILD_DIR)/dhcp_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DHCP_IPK_DIR)/CONTROL
	$(INSTALL) -d $(DHCP_IPK_DIR)$(TARGET_PREFIX)/sbin $(DHCP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(STRIP_COMMAND) $(DHCP_BUILD_DIR)/`find  builds/dhcp -name work* | cut -d/ -f3`/server/dhcpd -o $(DHCP_IPK_DIR)$(TARGET_PREFIX)/sbin/dhcpd
	$(INSTALL) -m 755 $(SOURCE_DIR)/dhcp.rc $(DHCP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S56dhcp
	touch $(DHCP_IPK_DIR)$(TARGET_PREFIX)/etc/dhcpd.leases
	cp $(DHCP_BUILD_DIR)/server/dhcpd.conf $(DHCP_IPK_DIR)$(TARGET_PREFIX)/etc/
	echo $(DHCP_CONFFILES) | sed -e 's/ /\n/g' > $(DHCP_IPK_DIR)/CONTROL/conffiles
	$(MAKE) $(DHCP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DHCP_IPK_DIR)

dhcp-ipk: $(DHCP_IPK)

dhcp-clean:
	-make -C $(DHCP_BUILD_DIR) clean

dhcp-dirclean:
	rm -rf $(DHCP_BUILD_DIR) $(DHCP_IPK_DIR) $(DHCP_IPK)

dhcp-check: $(DHCP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
