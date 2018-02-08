#############################################################
#
# dropbear
#
#############################################################
#
# $Id$
#

ifndef DROPBEAR_SITE
DROPBEAR_SITE=http://matt.ucc.asn.au/dropbear/releases
DROPBEAR_VERSION=2017.75
DROPBEAR_SOURCE=dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_DIR=dropbear-$(DROPBEAR_VERSION)
DROPBEAR_UNZIP=bzcat
DROPBEAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DROPBEAR_DESCRIPTION=Lightweight SSH client and server system
DROPBEAR_SECTION=net
DROPBEAR_PRIORITY=optional
DROPBEAR_DEPENDS=psmisc
DROPBEAR_SUGGESTS=
DROPBEAR_CONFLICTS=dropbear-android


DROPBEAR_IPK_VERSION=1

DROPBEAR_PATCHES=$(DROPBEAR_SOURCE_DIR)/configure.patch \
		 $(DROPBEAR_SOURCE_DIR)/options.h.patch \
		 $(DROPBEAR_SOURCE_DIR)/auth_pubkey_path.patch \

DROPBEAR_CONFFILES=$(TARGET_PREFIX)/etc/default/dropbear $(TARGET_PREFIX)/etc/init.d/S51dropbear

DROPBEAR_CPPFLAGS=
DROPBEAR_LDFLAGS=

DROPBEAR_BUILD_DIR=$(BUILD_DIR)/dropbear
DROPBEAR_SOURCE_DIR=$(SOURCE_DIR)/dropbear
DROPBEAR_IPK_DIR=$(BUILD_DIR)/dropbear-$(DROPBEAR_VERSION)-ipk
DROPBEAR_IPK=$(BUILD_DIR)/dropbear_$(DROPBEAR_VERSION)-$(DROPBEAR_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(DROPBEAR_SOURCE):
	$(WGET) -P $(@D) $(DROPBEAR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

dropbear-source: $(DL_DIR)/$(DROPBEAR_SOURCE) $(DROPBEAR_PATCHES)

$(DROPBEAR_BUILD_DIR)/.configured: $(DL_DIR)/$(DROPBEAR_SOURCE) $(DROPBEAR_PATCHES) make/dropbear.mk
	rm -rf $(BUILD_DIR)/$(DROPBEAR_DIR) $(@D)
	$(DROPBEAR_UNZIP) $(DL_DIR)/$(DROPBEAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DROPBEAR_PATCHES)" ; \
		then cat $(DROPBEAR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DROPBEAR_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(DROPBEAR_DIR) $(@D)
	(cd $(@D) && \
		$(AUTORECONF1.10) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" LD="" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DROPBEAR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-zlib \
		--disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp \
		--disable-wtmpx --disable-libutil \
	)
	touch $@

dropbear-unpack: $(DROPBEAR_BUILD_DIR)/.configured

$(DROPBEAR_BUILD_DIR)/.built: $(DROPBEAR_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) MULTI=1 SCPPROGRESS=1 \
		PROGRAMS="dropbear dropbearkey dropbearconvert dbclient ssh scp"
	touch $@

dropbear: $(DROPBEAR_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dropbear
#
$(DROPBEAR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dropbear" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DROPBEAR_PRIORITY)" >>$@
	@echo "Section: $(DROPBEAR_SECTION)" >>$@
	@echo "Version: $(DROPBEAR_VERSION)-$(DROPBEAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DROPBEAR_MAINTAINER)" >>$@
	@echo "Source: $(DROPBEAR_SITE)/$(DROPBEAR_SOURCE)" >>$@
	@echo "Description: $(DROPBEAR_DESCRIPTION)" >>$@
	@echo "Depends: $(DROPBEAR_DEPENDS)" >>$@
	@echo "Suggests: $(DROPBEAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(DROPBEAR_CONFLICTS)" >>$@

$(DROPBEAR_IPK): $(DROPBEAR_BUILD_DIR)/.built
	rm -rf $(DROPBEAR_IPK_DIR) $(BUILD_DIR)/dropbear_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/sbin $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(DROPBEAR_BUILD_DIR)/dropbearmulti -o $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/sbin/dropbearmulti
	cd $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbear
	cd $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbearkey
	cd $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbearconvert
	cd $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/bin && ln -sf ../sbin/dropbearmulti dbclient
	$(INSTALL) -d $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DROPBEAR_SOURCE_DIR)/rc.dropbear $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S51dropbear
	$(INSTALL) -d $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/etc/default
	$(INSTALL) -m 755 $(DROPBEAR_SOURCE_DIR)/dropbear.default $(DROPBEAR_IPK_DIR)$(TARGET_PREFIX)/etc/default/dropbear
	$(MAKE) $(DROPBEAR_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(DROPBEAR_SOURCE_DIR)/postinst $(DROPBEAR_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 644 $(DROPBEAR_SOURCE_DIR)/prerm    $(DROPBEAR_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
                sed -i -e '/^[  ]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
                        $(DROPBEAR_IPK_DIR)/CONTROL/postinst $(DROPBEAR_IPK_DIR)/CONTROL/prerm; \
        fi
	echo $(DROPBEAR_CONFFILES) | sed -e 's/ /\n/g' > $(DROPBEAR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DROPBEAR_IPK_DIR)

dropbear-ipk: $(DROPBEAR_IPK)

dropbear-clean:
	-make -C $(DROPBEAR_BUILD_DIR) clean

dropbear-dirclean:
	rm -rf $(BUILD_DIR)/$(DROPBEAR_DIR) $(DROPBEAR_BUILD_DIR) $(DROPBEAR_IPK_DIR) $(DROPBEAR_IPK)

#
# Some sanity check for the package.
#
dropbear-check: $(DROPBEAR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DROPBEAR_IPK)
endif
