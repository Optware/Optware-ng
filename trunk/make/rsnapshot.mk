###########################################################
#
# rsnapshot
#
###########################################################

RSNAPSHOT_SITE=http://www.rsnapshot.org/downloads
RSNAPSHOT_VERSION=1.2.0
RSNAPSHOT_SOURCE=rsnapshot-$(RSNAPSHOT_VERSION).tar.gz
RSNAPSHOT_DIR=rsnapshot-$(RSNAPSHOT_VERSION)
RSNAPSHOT_UNZIP=zcat

RSNAPSHOT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RSNAPSHOT_DESCRIPTION=A filesystem snapshot utility based on rsync.
RSNAPSHOT_SECTION=util
RSNAPSHOT_PRIORITY=optional
RSNAPSHOT_DEPENDS=coreutils, perl, rsync, openssh

RSNAPSHOT_IPK_VERSION=1

RSNAPSHOT_CONFFILES=/opt/etc/rsnapshot.conf

RSNAPSHOT_PATCHES=

RSNAPSHOT_CPPFLAGS=
RSNAPSHOT_LDFLAGS=

RSNAPSHOT_BUILD_DIR=$(BUILD_DIR)/rsnapshot
RSNAPSHOT_SOURCE_DIR=$(SOURCE_DIR)/rsnapshot
RSNAPSHOT_IPK_DIR=$(BUILD_DIR)/rsnapshot-$(RSNAPSHOT_VERSION)-ipk
RSNAPSHOT_IPK=$(BUILD_DIR)/rsnapshot_$(RSNAPSHOT_VERSION)-$(RSNAPSHOT_IPK_VERSION)_armeb.ipk

$(RSNAPSHOT_IPK_DIR)/CONTROL/control:
	@install -d $(RSNAPSHOT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: rsnapshot" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(RSNAPSHOT_PRIORITY)" >>$@
	@echo "Section: $(RSNAPSHOT_SECTION)" >>$@
	@echo "Version: $(RSNAPSHOT_VERSION)-$(RSNAPSHOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RSNAPSHOT_MAINTAINER)" >>$@
	@echo "Source: $(RSNAPSHOT_SITE)/$(RSNAPSHOT_SOURCE)" >>$@
	@echo "Description: $(RSNAPSHOT_DESCRIPTION)" >>$@
	@echo "Depends: $(RSNAPSHOT_DEPENDS)" >>$@

$(DL_DIR)/$(RSNAPSHOT_SOURCE):
	$(WGET) -P $(DL_DIR) $(RSNAPSHOT_SITE)/$(RSNAPSHOT_SOURCE)

rsnapshot-source: $(DL_DIR)/$(RSNAPSHOT_SOURCE) $(RSNAPSHOT_PATCHES)

$(RSNAPSHOT_BUILD_DIR)/.configured: $(DL_DIR)/$(RSNAPSHOT_SOURCE) $(RSNAPSHOT_PATCHES)
	$(MAKE) rsync-stage
	rm -rf $(BUILD_DIR)/$(RSNAPSHOT_DIR) $(RSNAPSHOT_BUILD_DIR)
	$(RSNAPSHOT_UNZIP) $(DL_DIR)/$(RSNAPSHOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(RSNAPSHOT_PATCHES) | patch -d $(BUILD_DIR)/$(RSNAPSHOT_DIR) -p1
	mv $(BUILD_DIR)/$(RSNAPSHOT_DIR) $(RSNAPSHOT_BUILD_DIR)
	(cd $(RSNAPSHOT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSNAPSHOT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSNAPSHOT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-perl=/opt/bin/perl \
		--with-rsync=$(STAGING_DIR)/opt/bin/rsync \
		--with-ssh=/opt/bin/ssh \
		--with-cp=/opt/bin/cp \
		--with-rm=/opt/bin/rm \
		--with-du=/opt/bin/du \
		--without-logger \
	)
	touch $(RSNAPSHOT_BUILD_DIR)/.configured

rsnapshot-unpack: $(RSNAPSHOT_BUILD_DIR)/.configured

$(RSNAPSHOT_BUILD_DIR)/.built: $(RSNAPSHOT_BUILD_DIR)/.configured
	rm -f $(RSNAPSHOT_BUILD_DIR)/.built
#	$(MAKE) -C $(RSNAPSHOT_BUILD_DIR)
	echo "Nothing to do for target 'rsnapshot'."
	touch $(RSNAPSHOT_BUILD_DIR)/.built

rsnapshot: $(RSNAPSHOT_BUILD_DIR)/.built

$(RSNAPSHOT_BUILD_DIR)/.staged: $(RSNAPSHOT_BUILD_DIR)/.built
	rm -f $(RSNAPSHOT_BUILD_DIR)/.staged
#	$(MAKE) -C $(RSNAPSHOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	echo "Warning: the makefile target 'rsnapshot-stage' is not available."
	touch $(RSNAPSHOT_BUILD_DIR)/.staged

rsnapshot-stage: $(RSNAPSHOT_BUILD_DIR)/.staged

$(RSNAPSHOT_IPK): $(RSNAPSHOT_BUILD_DIR)/.built
	rm -rf $(RSNAPSHOT_IPK_DIR) $(BUILD_DIR)/rsnapshot_*_armeb.ipk
	$(MAKE) -C $(RSNAPSHOT_BUILD_DIR) DESTDIR=$(RSNAPSHOT_IPK_DIR) install
	find $(RSNAPSHOT_IPK_DIR)/opt -type d -exec chmod go+rx {} \;
	rm -rf $(RSNAPSHOT_IPK_DIR)/opt/etc/rsnapshot.conf.default
	install -m 644 $(RSNAPSHOT_SOURCE_DIR)/rsnapshot.conf $(RSNAPSHOT_IPK_DIR)/opt/etc/rsnapshot.conf
	install -d $(RSNAPSHOT_IPK_DIR)/opt/var/rsnapshot/
	install -d $(RSNAPSHOT_IPK_DIR)/opt/var/run/
	install -d $(RSNAPSHOT_IPK_DIR)/opt/var/log/

	$(MAKE) $(RSNAPSHOT_IPK_DIR)/CONTROL/control
#	install -m 755 $(RSNAPSHOT_SOURCE_DIR)/postinst $(RSNAPSHOT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RSNAPSHOT_SOURCE_DIR)/prerm $(RSNAPSHOT_IPK_DIR)/CONTROL/prerm
	echo $(RSNAPSHOT_CONFFILES) | sed -e 's/ /\n/g' > $(RSNAPSHOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSNAPSHOT_IPK_DIR)

rsnapshot-ipk: $(RSNAPSHOT_IPK)

rsnapshot-clean:
	-$(MAKE) -C $(RSNAPSHOT_BUILD_DIR) clean

rsnapshot-dirclean:
	rm -rf $(BUILD_DIR)/$(RSNAPSHOT_DIR) $(RSNAPSHOT_BUILD_DIR) $(RSNAPSHOT_IPK_DIR) $(RSNAPSHOT_IPK)
