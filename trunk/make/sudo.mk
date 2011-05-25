#
# Make file for sudo
#
# $Id$

SUDO_SITE=http://www.gratisoft.us/sudo/dist
SUDO_UPSTREAM_VERSION?=1.8.1p2
SUDO_VERSION?=1.8.1.2
SUDO_SOURCE=sudo-$(SUDO_UPSTREAM_VERSION).tar.gz
SUDO_DIR=sudo-$(SUDO_UPSTREAM_VERSION)
SUDO_UNZIP=zcat
SUDO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SUDO_DESCRIPTION=System utility to execute commands as the superuser
SUDO_SECTION=sysutil
SUDO_PRIORITY=optional
SUDO_DEPENDS=
SUDO_SUGGESTS=
SUDO_CONFLICTS=

SUDO_IPK_VERSION?=1

SUDO_CONFFILES=/opt/etc/sudoers

#SUDO_PATCHES=

ifneq ($(TARGET_CC), $(HOSTCC))
SUDO_CONFIGURE_ENV=sudo_cv_uid_t_len=10 sudo_cv_func_unsetenv_void=no
endif
ifeq ($(OPTWARE_TARGET), wl500g)
SUDO_CONFIGURE_ENV+=ac_cv_header_err_h=no
endif

SUDO_BUILD_DIR:=$(BUILD_DIR)/sudo
SUDO_SOURCE_DIR=$(SOURCE_DIR)/sudo
SUDO_IPK_DIR=$(BUILD_DIR)/sudo-$(SUDO_VERSION)-ipk
SUDO_IPK=$(BUILD_DIR)/sudo_$(SUDO_VERSION)-$(SUDO_IPK_VERSION)_$(TARGET_ARCH).ipk


$(DL_DIR)/$(SUDO_SOURCE):
	$(WGET) -P $(@D) $(SUDO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

sudo-source: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCHES)


$(SUDO_BUILD_DIR)/.configured: $(DL_DIR)/$(SUDO_SOURCE) $(SUDO_PATCHES) make/sudo.mk
	rm -rf $(BUILD_DIR)/$(SUDO_DIR) $(@D)
	$(SUDO_UNZIP) $(DL_DIR)/$(SUDO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SUDO_PATCHES)"; then \
		cat $(SUDO_PATCHES) | patch -d $(BUILD_DIR)/$(SUDO_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(SUDO_DIR) $(@D)
	sed -i -e '/$$(INSTALL) /s| -s||' $(@D)/Makefile.in
	cd $(@D) && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SUDO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SUDO_LDFLAGS)" \
		$(SUDO_CONFIGURE_ENV) \
		./configure \
			--host=$(GNU_TARGET_NAME) \
			--target=$(GNU_TARGET_NAME) \
			--build=$(GNU_HOST_NAME) \
			--prefix=/opt \
			--enable-authentication \
			--without-pam \
			--without-insults \
			--with-editor=/bin/vi \
			--with-env-editor \
			--sysconfdir=/opt/etc
	touch $@

sudo-unpack: $(SUDO_BUILD_DIR)/.configured

$(SUDO_BUILD_DIR)/.built: $(SUDO_BUILD_DIR)/.configured
	rm -f $@
	make -C $(@D)
	touch $@

sudo: $(SUDO_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sudo
#
$(SUDO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sudo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUDO_PRIORITY)" >>$@
	@echo "Section: $(SUDO_SECTION)" >>$@
	@echo "Version: $(SUDO_VERSION)-$(SUDO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUDO_MAINTAINER)" >>$@
	@echo "Source: $(SUDO_SITE)/$(SUDO_SOURCE)" >>$@
	@echo "Description: $(SUDO_DESCRIPTION)" >>$@
	@echo "Depends: $(SUDO_DEPENDS)" >>$@
	@echo "Suggests: $(SUDO_SUGGESTS)" >>$@
	@echo "Conflicts: $(SUDO_CONFLICTS)" >>$@

$(SUDO_IPK): $(SUDO_BUILD_DIR)/.built
	rm -rf $(SUDO_IPK_DIR) $(BUILD_DIR)/sudo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SUDO_BUILD_DIR) DESTDIR=$(SUDO_IPK_DIR) install
	$(STRIP_COMMAND) \
	    $(SUDO_IPK_DIR)/opt/bin/sudo \
	    $(SUDO_IPK_DIR)/opt/bin/sudoreplay \
	    $(SUDO_IPK_DIR)/opt/libexec/sudo_noexec.so \
	    $(SUDO_IPK_DIR)/opt/sbin/visudo
	install -d $(SUDO_IPK_DIR)/opt/share/doc/sudo
ifeq ($(SUDO_VERSION),1.7.4.6)
	install -m 644 $(<D)/sample.sudoers $(SUDO_IPK_DIR)/opt/share/doc/sudo/sample.sudoers
else
	$(STRIP_COMMAND) $(SUDO_IPK_DIR)/opt/libexec/sudoers.so
	install -m 644 $(<D)/doc/sample.sudoers $(SUDO_IPK_DIR)/opt/share/doc/sudo/sample.sudoers
endif
	$(MAKE) $(SUDO_IPK_DIR)/CONTROL/control
	install -m 644 $(SUDO_SOURCE_DIR)/postinst $(SUDO_IPK_DIR)/CONTROL/postinst
	echo $(SUDO_CONFFILES) | sed -e 's/ /\n/g' > $(SUDO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR) && $(IPKG_BUILD) $(SUDO_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SUDO_IPK_DIR)

sudo-ipk: $(SUDO_IPK)

sudo-clean:
	-make -C $(SUDO_BUILD_DIR) clean

sudo-dirclean:
	rm -rf $(BUILD_DIR)/$(SUDO_DIR) $(SUDO_BUILD_DIR) $(SUDO_IPK_DIR) $(SUDO_IPK)

sudo-check: $(SUDO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
