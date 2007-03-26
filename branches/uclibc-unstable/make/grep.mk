###########################################################
#
# grep
#
###########################################################

GREP_DIR=$(BUILD_DIR)/grep

ifeq ($(LIBC_STYLE),uclibc)
GREP_VERSION=2.4.2
GREP_IPK_VERSION=6
GREP_DEPENDS=
else
GREP_VERSION=2.5.1a
GREP_IPK_VERSION=2
GREP_DEPENDS=pcre
endif

GREP=grep-$(GREP_VERSION)
GREP_SITE=ftp://ftp.gnu.org/pub/gnu/grep
GREP_SOURCE=$(GREP).tar.gz
GREP_UNZIP=zcat
GREP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GREP_DESCRIPTION=Global regular expression parser
GREP_SECTION=util
GREP_PRIORITY=optional
GREP_CONFLICTS=busybox-links

#ifeq ($(OPTWARE_TARGET), wl500g)
#GREP_CPPFLAGS=-DMB_CUR_MAX=1
GREP_CPPFLAGS=
GREP_LDFLAGS=
#endif

GREP_BUILD_DIR=$(BUILD_DIR)/grep

GREP_IPK=$(BUILD_DIR)/grep_$(GREP_VERSION)-$(GREP_IPK_VERSION)_$(TARGET_ARCH).ipk
GREP_IPK_DIR=$(BUILD_DIR)/grep-$(GREP_VERSION)-ipk

ifeq ($(LIBC_STYLE),uclibc)
GREP_CONFIGURE_ARGS=--disable-nls
else
GREP_CONFIGURE_ARGS=
endif

.PHONY: grep-source grep-unpack grep grep-stage grep-ipk grep-clean grep-dirclean grep-check

$(DL_DIR)/$(GREP_SOURCE):
	$(WGET) -P $(DL_DIR) $(GREP_SITE)/$(GREP_SOURCE)

grep-source: $(DL_DIR)/$(GREP_SOURCE)

$(GREP_DIR)/.configured: $(DL_DIR)/$(GREP_SOURCE)
ifneq ($(GREP_VERSION), 2.4.2)
	$(MAKE) pcre-stage
endif
	rm -rf $(BUILD_DIR)/$(GREP_DIR) $(GREP_BUILD_DIR)
	$(GREP_UNZIP) $(DL_DIR)/$(GREP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/grep-$(GREP_VERSION) $(GREP_DIR)
	(cd $(GREP_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GREP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GREP_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt \
		$(GREP_CONFIGURE_ARGS) \
	);
	sed -i -e '/^LIBS/s|-L/usr/lib||' $(GREP_DIR)/src/Makefile
	touch $(GREP_DIR)/.configured

grep-unpack: $(GREP_DIR)/.configured

$(GREP_DIR)/src/grep: $(GREP_DIR)/.configured
	$(MAKE) -C $(GREP_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD)

grep: $(GREP_DIR)/src/grep

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/grep
#
$(GREP_IPK_DIR)/CONTROL/control:
	@install -d $(GREP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: grep" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GREP_PRIORITY)" >>$@
	@echo "Section: $(GREP_SECTION)" >>$@
	@echo "Version: $(GREP_VERSION)-$(GREP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GREP_MAINTAINER)" >>$@
	@echo "Source: $(GREP_SITE)/$(GREP_SOURCE)" >>$@
	@echo "Description: $(GREP_DESCRIPTION)" >>$@
	@echo "Depends: $(GREP_DEPENDS)" >>$@
	@echo "Conflicts: $(GREP_CONFLICTS)" >>$@

$(GREP_IPK): $(GREP_DIR)/src/grep
	rm -rf $(GREP_IPK_DIR) $(BUILD_DIR)/grep_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GREP_BUILD_DIR) install \
		top_distdir=$(GREP_IPK_DIR) \
		DESTDIR=$(GREP_IPK_DIR) \
		AM_MAKEFLAGS="DESTDIR=$(GREP_IPK_DIR)"
	rm -f $(GREP_IPK_DIR)/opt/info/dir $(GREP_IPK_DIR)/opt/info/dir.old
	$(STRIP_COMMAND) $(GREP_IPK_DIR)/opt/bin/grep
ifeq ($(GREP_VERSION), 2.4.2)
	$(STRIP_COMMAND) $(GREP_IPK_DIR)/opt/bin/egrep $(GREP_IPK_DIR)/opt/bin/fgrep
endif
	$(MAKE) $(GREP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GREP_IPK_DIR)

grep-ipk: $(GREP_IPK)

grep-clean:
	-$(MAKE) -C $(GREP_DIR) clean

grep-dirclean:
	rm -rf $(GREP_DIR) $(GREP_IPK_DIR) $(GREP_IPK)

grep-check: $(GREP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GREP_IPK)
