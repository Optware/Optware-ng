#############################################################
#
# dropbear-android
#
#############################################################
#
# $Id$
#

DROPBEAR_ANDROID_SITE=http://matt.ucc.asn.au/dropbear/releases
include make/dropbear.mk
DROPBEAR_ANDROID_VERSION=$(DROPBEAR_VERSION)
DROPBEAR_ANDROID_SOURCE=dropbear-$(DROPBEAR_ANDROID_VERSION).tar.bz2
DROPBEAR_ANDROID_DIR=dropbear-$(DROPBEAR_ANDROID_VERSION)
DROPBEAR_ANDROID_UNZIP=bzcat
DROPBEAR_ANDROID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DROPBEAR_ANDROID_DESCRIPTION=Lightweight SSH client and server system. Patch to support Android Mode
DROPBEAR_ANDROID_SECTION=net
DROPBEAR_ANDROID_PRIORITY=optional
DROPBEAR_ANDROID_DEPENDS=psmisc
DROPBEAR_ANDROID_SUGGESTS=
DROPBEAR_ANDROID_CONFLICTS=dropbear


DROPBEAR_ANDROID_IPK_VERSION=1

DROPBEAR_ANDROID_PATCHES=$(DROPBEAR_ANDROID_SOURCE_DIR)/configure.patch \
		 $(DROPBEAR_ANDROID_SOURCE_DIR)/options.h.patch \
		 $(DROPBEAR_ANDROID_SOURCE_DIR)/auth_pubkey_path.patch \
		 $(DROPBEAR_ANDROID_SOURCE_DIR)/android.patch \

DROPBEAR_ANDROID_CONFFILES=$(TARGET_PREFIX)/etc/default/dropbear $(TARGET_PREFIX)/etc/init.d/S51dropbear

DROPBEAR_ANDROID_CPPFLAGS=
DROPBEAR_ANDROID_LDFLAGS=

DROPBEAR_ANDROID_BUILD_DIR=$(BUILD_DIR)/dropbear-android
DROPBEAR_ANDROID_SOURCE_DIR=$(SOURCE_DIR)/dropbear
DROPBEAR_ANDROID_IPK_DIR=$(BUILD_DIR)/dropbear-android-$(DROPBEAR_ANDROID_VERSION)-ipk
DROPBEAR_ANDROID_IPK=$(BUILD_DIR)/dropbear-android_$(DROPBEAR_ANDROID_VERSION)-$(DROPBEAR_ANDROID_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DROPBEAR_ANDROID_BUILD_DIR)/.configured: $(DL_DIR)/$(DROPBEAR_ANDROID_SOURCE) $(DROPBEAR_ANDROID_PATCHES) make/dropbear-android.mk
	$(MAKE) dropbear-source
	rm -rf $(BUILD_DIR)/$(DROPBEAR_ANDROID_DIR) $(@D)
	$(DROPBEAR_ANDROID_UNZIP) $(DL_DIR)/$(DROPBEAR_ANDROID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DROPBEAR_ANDROID_PATCHES)" ; \
		then cat $(DROPBEAR_ANDROID_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DROPBEAR_ANDROID_DIR) -p1 ; \
	fi
	mv $(BUILD_DIR)/$(DROPBEAR_ANDROID_DIR) $(@D)
	(cd $(@D) && \
		$(AUTORECONF1.10) && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" LD="" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DROPBEAR_ANDROID_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-zlib \
		--disable-lastlog --disable-utmp \
		--disable-utmpx --disable-wtmp \
		--disable-wtmpx --disable-libutil \
		--disable-loginfunc \
	)
	touch $@

dropbear-android-unpack: $(DROPBEAR_ANDROID_BUILD_DIR)/.configured

$(DROPBEAR_ANDROID_BUILD_DIR)/.built: $(DROPBEAR_ANDROID_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) MULTI=1 SCPPROGRESS=1 \
		PROGRAMS="dropbear dropbearkey dropbearconvert dbclient ssh scp"
	touch $@

dropbear-android: $(DROPBEAR_ANDROID_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dropbear
#
$(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: dropbear-android" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DROPBEAR_ANDROID_PRIORITY)" >>$@
	@echo "Section: $(DROPBEAR_ANDROID_SECTION)" >>$@
	@echo "Version: $(DROPBEAR_ANDROID_VERSION)-$(DROPBEAR_ANDROID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DROPBEAR_ANDROID_MAINTAINER)" >>$@
	@echo "Source: $(DROPBEAR_ANDROID_SITE)/$(DROPBEAR_ANDROID_SOURCE)" >>$@
	@echo "Description: $(DROPBEAR_ANDROID_DESCRIPTION)" >>$@
	@echo "Depends: $(DROPBEAR_ANDROID_DEPENDS)" >>$@
	@echo "Suggests: $(DROPBEAR_ANDROID_SUGGESTS)" >>$@
	@echo "Conflicts: $(DROPBEAR_ANDROID_CONFLICTS)" >>$@

$(DROPBEAR_ANDROID_IPK): $(DROPBEAR_ANDROID_BUILD_DIR)/.built
	rm -rf $(DROPBEAR_ANDROID_IPK_DIR) $(BUILD_DIR)/dropbear-android_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/sbin $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(DROPBEAR_ANDROID_BUILD_DIR)/dropbearmulti -o $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/sbin/dropbearmulti
	cd $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbear
	cd $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbearkey
	cd $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/sbin && ln -sf dropbearmulti dropbearconvert
	cd $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/bin && ln -sf ../sbin/dropbearmulti dbclient
	$(INSTALL) -d $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(DROPBEAR_ANDROID_SOURCE_DIR)/rc.dropbear-android $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S51dropbear
	$(INSTALL) -d $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/etc/default
	$(INSTALL) -m 755 $(DROPBEAR_ANDROID_SOURCE_DIR)/dropbear-android.default $(DROPBEAR_ANDROID_IPK_DIR)$(TARGET_PREFIX)/etc/default/dropbear
	$(MAKE) $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 644 $(DROPBEAR_ANDROID_SOURCE_DIR)/postinst $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 644 $(DROPBEAR_ANDROID_SOURCE_DIR)/prerm    $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
                sed -i -e '/^[  ]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
                        $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/postinst $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/prerm; \
        fi
	echo $(DROPBEAR_ANDROID_CONFFILES) | sed -e 's/ /\n/g' > $(DROPBEAR_ANDROID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DROPBEAR_ANDROID_IPK_DIR)

dropbear-android-ipk: $(DROPBEAR_ANDROID_IPK)

dropbear-android-clean:
	-make -C $(DROPBEAR_ANDROID_BUILD_DIR) clean

dropbear-android-dirclean:
	rm -rf $(BUILD_DIR)/$(DROPBEAR_ANDROID_DIR) $(DROPBEAR_ANDROID_BUILD_DIR) $(DROPBEAR_ANDROID_IPK_DIR) $(DROPBEAR_ANDROID_IPK)

#
# Some sanity check for the package.
#
dropbear-android-check: $(DROPBEAR_ANDROID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DROPBEAR_ANDROID_IPK)
