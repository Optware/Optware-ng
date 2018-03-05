###########################################################
#
# rsync
#
###########################################################

RSYNC_SITE=http://www.samba.org/ftp/rsync/src/
RSYNC_VERSION=3.1.3
RSYNC_SOURCE=rsync-$(RSYNC_VERSION).tar.gz
RSYNC_DIR=rsync-$(RSYNC_VERSION)
RSYNC_UNZIP=zcat
RSYNC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RSYNC_DESCRIPTION=fast remote file copy program (like rcp)
RSYNC_SECTION=net
RSYNC_PRIORITY=optional
RSYNC_DEPENDS=libacl
ifneq (, $(filter libiconv, $(PACKAGES)))
RSYNC_DEPENDS += libiconv
endif
RSYNC_CONFLICTS=

RSYNC_IPK_VERSION=1

RSYNC_CONFFILES= \
	$(TARGET_PREFIX)/etc/rsyncd.conf \
	$(TARGET_PREFIX)/etc/init.d/S57rsyncd \
	$(TARGET_PREFIX)/etc/rsyncd.secrets \
	$(TARGET_PREFIX)/etc/default/rsync

RSYNC_PATCHES=$(RSYNC_SOURCE_DIR)/rsync.patch

RSYNC_CPPFLAGS=
RSYNC_LDFLAGS=

ifeq ($(HOSTCC), $(TARGET_CC))
RSYNC_CROSS_ENV=
else
RSYNC_CROSS_ENV=\
	rsync_cv_can_hardlink_special=yes \
	rsync_cv_can_hardlink_symlink=yes \
	rsync_cv_HAVE_C99_VSNPRINTF=yes \
	rsync_cv_HAVE_SECURE_MKSTEMP=yes \
	rsync_cv_HAVE_SOCKETPAIR=yes \
	ac_cv_func_utime_null=yes \
	rsync_cv_MKNOD_CREATES_FIFOS=yes \
	rsync_cv_MKNOD_CREATES_SOCKETS=yes \
	ac_cv_func_lchmod=no \
	ac_cv_func_lutimes=no
endif

RSYNC_BUILD_DIR=$(BUILD_DIR)/rsync
RSYNC_SOURCE_DIR=$(SOURCE_DIR)/rsync
RSYNC_IPK_DIR=$(BUILD_DIR)/rsync-$(RSYNC_VERSION)-ipk
RSYNC_IPK=$(BUILD_DIR)/rsync_$(RSYNC_VERSION)-$(RSYNC_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(RSYNC_SOURCE):
	$(WGET) -P $(@D) $(RSYNC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

rsync-source: $(DL_DIR)/$(RSYNC_SOURCE) $(RSYNC_PATCHES)

.PHONY: rsync-source rsync-unpack rsync rsync-stage rsync-ipk rsync-clean rsync-dirclean rsync-check

$(RSYNC_BUILD_DIR)/.configured: $(DL_DIR)/$(RSYNC_SOURCE) $(RSYNC_PATCHES) make/rsync.mk
	$(MAKE) libacl-stage
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(RSYNC_DIR) $(@D)
	$(RSYNC_UNZIP) $(DL_DIR)/$(RSYNC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(RSYNC_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(RSYNC_DIR) -p1
	mv $(BUILD_DIR)/$(RSYNC_DIR) $(@D)
	sed -i -e '/-o rounding/s|$$(CFLAGS) |&$$(CPPFLAGS) |' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSYNC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSYNC_LDFLAGS)" \
		$(RSYNC_CROSS_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-included-popt \
		--with-rsyncd-conf=$(TARGET_PREFIX)/etc/rsyncd.conf \
		--disable-nls \
	)
	touch $@

rsync-unpack: $(RSYNC_BUILD_DIR)/.configured

$(RSYNC_BUILD_DIR)/.built: $(RSYNC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

rsync: $(RSYNC_BUILD_DIR)/.built

$(RSYNC_BUILD_DIR)/.staged: $(RSYNC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	$(STRIP_COMMAND) $(STAGING_PREFIX)/bin/rsync
	touch $@

rsync-stage: $(RSYNC_BUILD_DIR)/.staged

$(RSYNC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: rsync" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RSYNC_PRIORITY)" >>$@
	@echo "Section: $(RSYNC_SECTION)" >>$@
	@echo "Version: $(RSYNC_VERSION)-$(RSYNC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RSYNC_MAINTAINER)" >>$@
	@echo "Source: $(RSYNC_SITE)/$(RSYNC_SOURCE)" >>$@
	@echo "Description: $(RSYNC_DESCRIPTION)" >>$@
	@echo "Depends: $(RSYNC_DEPENDS)" >>$@
	@echo "Conflicts: $(RSYNC_CONFLICTS)" >>$@

$(RSYNC_IPK): $(RSYNC_BUILD_DIR)/.built
	rm -rf $(RSYNC_IPK_DIR) $(BUILD_DIR)/rsync_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RSYNC_BUILD_DIR) DESTDIR=$(RSYNC_IPK_DIR) install
	$(STRIP_COMMAND) $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/bin/rsync
	find $(RSYNC_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(INSTALL) -d $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc
	$(INSTALL) -m 644 $(RSYNC_SOURCE_DIR)/rsyncd.conf $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/rsyncd.conf
	$(INSTALL) -d $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/default
	$(INSTALL) -m 644 $(RSYNC_SOURCE_DIR)/rsync.default $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/default/rsync
	touch $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/rsyncd.secrets
	chmod 600 $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/rsyncd.secrets
	$(INSTALL) -d $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(RSYNC_SOURCE_DIR)/rc.rsyncd $(RSYNC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S57rsyncd
	$(MAKE) $(RSYNC_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(RSYNC_SOURCE_DIR)/postinst $(RSYNC_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(RSYNC_SOURCE_DIR)/prerm $(RSYNC_IPK_DIR)/CONTROL/prerm
	echo $(RSYNC_CONFFILES) | sed -e 's/ /\n/g' > $(RSYNC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSYNC_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RSYNC_IPK_DIR)

rsync-ipk: $(RSYNC_IPK)

rsync-clean:
	-$(MAKE) -C $(RSYNC_BUILD_DIR) clean

rsync-dirclean:
	rm -rf $(BUILD_DIR)/$(RSYNC_DIR) $(RSYNC_BUILD_DIR) $(RSYNC_IPK_DIR) $(RSYNC_IPK)

rsync-check: $(RSYNC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
