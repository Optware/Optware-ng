#############################################################
#
# dropbear
#
#############################################################
#
# $Id$
#

DROPBEAR_SITE=http://matt.ucc.asn.au/dropbear/releases
DROPBEAR_VERSION=0.52
DROPBEAR_SOURCE=dropbear-$(DROPBEAR_VERSION).tar.bz2
DROPBEAR_DIR=dropbear-$(DROPBEAR_VERSION)
DROPBEAR_UNZIP=bzcat
DROPBEAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DROPBEAR_DESCRIPTION=Lightweight SSH client and server system
DROPBEAR_SECTION=net
DROPBEAR_PRIORITY=optional
DROPBEAR_DEPENDS=
DROPBEAR_SUGGESTS=
DROPBEAR_CONFLICTS=


DROPBEAR_IPK_VERSION=2

DROPBEAR_PATCHES=$(DROPBEAR_SOURCE_DIR)/configure.patch \
		 $(DROPBEAR_SOURCE_DIR)/options.h.patch \

DROPBEAR_CONFFILES=/opt/etc/default/dropbear /opt/etc/init.d/S51dropbear

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

$(DROPBEAR_BUILD_DIR)/.configured: $(DL_DIR)/$(DROPBEAR_SOURCE) $(DROPBEAR_PATCHES)
	rm -rf $(BUILD_DIR)/$(DROPBEAR_DIR) $(DROPBEAR_BUILD_DIR)
	$(DROPBEAR_UNZIP) $(DL_DIR)/$(DROPBEAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(DROPBEAR_PATCHES) | patch -d $(BUILD_DIR)/$(DROPBEAR_DIR) -p1
	mv $(BUILD_DIR)/$(DROPBEAR_DIR) $(DROPBEAR_BUILD_DIR)
	(cd $(DROPBEAR_BUILD_DIR) && \
		autoreconf && \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" LD="" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DROPBEAR_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
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
	@install -d $(@D)
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
	install -d $(DROPBEAR_IPK_DIR)/opt/sbin $(DROPBEAR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(DROPBEAR_BUILD_DIR)/dropbearmulti -o $(DROPBEAR_IPK_DIR)/opt/sbin/dropbearmulti
	cd $(DROPBEAR_IPK_DIR)/opt/sbin && ln -sf dropbearmulti dropbear
	cd $(DROPBEAR_IPK_DIR)/opt/sbin && ln -sf dropbearmulti dropbearkey
	cd $(DROPBEAR_IPK_DIR)/opt/sbin && ln -sf dropbearmulti dropbearconvert
	cd $(DROPBEAR_IPK_DIR)/opt/bin && ln -sf ../sbin/dropbearmulti dbclient
#	cd $(DROPBEAR_IPK_DIR)/opt/bin && ln -sf ../sbin/dropbearmulti ssh
#	cd $(DROPBEAR_IPK_DIR)/opt/bin && ln -sf ../sbin/dropbearmulti scp
	install -d $(DROPBEAR_IPK_DIR)/opt/etc/init.d
	install -m 755 $(DROPBEAR_SOURCE_DIR)/rc.dropbear $(DROPBEAR_IPK_DIR)/opt/etc/init.d/S51dropbear
	install -d $(DROPBEAR_IPK_DIR)/opt/etc/default
	install -m 755 $(DROPBEAR_SOURCE_DIR)/dropbear.default $(DROPBEAR_IPK_DIR)/opt/etc/default/dropbear
	$(MAKE) $(DROPBEAR_IPK_DIR)/CONTROL/control
	install -m 644 $(DROPBEAR_SOURCE_DIR)/postinst $(DROPBEAR_IPK_DIR)/CONTROL/postinst
	install -m 644 $(DROPBEAR_SOURCE_DIR)/prerm    $(DROPBEAR_IPK_DIR)/CONTROL/prerm
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
