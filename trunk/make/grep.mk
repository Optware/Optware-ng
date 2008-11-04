###########################################################
#
# grep
#
###########################################################

GREP_VERSION=2.5.3
GREP_IPK_VERSION=1
GREP_DEPENDS=pcre

GREP=grep-$(GREP_VERSION)
GREP_SITE=ftp://ftp.gnu.org/pub/gnu/grep
GREP_SOURCE=$(GREP).tar.gz
GREP_UNZIP=zcat
GREP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GREP_DESCRIPTION=Global regular expression parser
GREP_SECTION=util
GREP_PRIORITY=optional
GREP_CONFLICTS=

GREP_CPPFLAGS=
GREP_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
GREP_LDFLAGS=-lintl
endif

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
	$(WGET) -P $(@D) $(GREP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

grep-source: $(DL_DIR)/$(GREP_SOURCE)

$(GREP_BUILD_DIR)/.configured: $(DL_DIR)/$(GREP_SOURCE) make/grep.mk
	$(MAKE) pcre-stage
	rm -rf $(BUILD_DIR)/$(GREP_BUILD_DIR) $(GREP_BUILD_DIR)
	$(GREP_UNZIP) $(DL_DIR)/$(GREP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/grep-$(GREP_VERSION) $(@D)
#	cp -f $(SOURCE_DIR)/common/config.* $(@D)/
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GREP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GREP_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--prefix=/opt \
		$(GREP_CONFIGURE_ARGS) \
	);
	sed -i -e '/^LIBS/s|-L/usr/lib||' $(@D)/src/Makefile
	touch $@

grep-unpack: $(GREP_BUILD_DIR)/.configured

$(GREP_BUILD_DIR)/.built: $(GREP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD)
	touch $@

grep: $(GREP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/grep
#
$(GREP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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

$(GREP_IPK): $(GREP_BUILD_DIR)/.built
	rm -rf $(GREP_IPK_DIR) $(BUILD_DIR)/grep_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GREP_BUILD_DIR) install \
		top_distdir=$(GREP_IPK_DIR) \
		DESTDIR=$(GREP_IPK_DIR) \
		AM_MAKEFLAGS="DESTDIR=$(GREP_IPK_DIR)"
	rm -f $(GREP_IPK_DIR)/opt/info/dir $(GREP_IPK_DIR)/opt/info/dir.old
	$(STRIP_COMMAND) $(GREP_IPK_DIR)/opt/bin/grep
	$(STRIP_COMMAND) $(GREP_IPK_DIR)/opt/bin/egrep $(GREP_IPK_DIR)/opt/bin/fgrep
	$(MAKE) $(GREP_IPK_DIR)/CONTROL/control
	echo "#!/bin/sh" > $(GREP_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(GREP_IPK_DIR)/CONTROL/prerm
	cd $(GREP_IPK_DIR)/opt/bin; \
	for f in grep egrep fgrep; do \
	    mv $$f grep-$$f; \
	    echo "update-alternatives --install /opt/bin/$$f $$f /opt/bin/grep-$$f 80" \
		>> $(GREP_IPK_DIR)/CONTROL/postinst; \
	    echo "update-alternatives --remove $$f /opt/bin/grep-$$f" \
		>> $(GREP_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GREP_IPK_DIR)/CONTROL/postinst $(GREP_IPK_DIR)/CONTROL/prerm; \
	fi
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GREP_IPK_DIR)

grep-ipk: $(GREP_IPK)

grep-clean:
	-$(MAKE) -C $(GREP_BUILD_DIR) clean

grep-dirclean:
	rm -rf $(GREP_BUILD_DIR) $(GREP_IPK_DIR) $(GREP_IPK)

grep-check: $(GREP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GREP_IPK)
