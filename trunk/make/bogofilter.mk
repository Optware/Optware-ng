###########################################################
#
# bogofilter
#
###########################################################

BOGOFILTER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bogofilter
BOGOFILTER_VERSION=1.2.2
BOGOFILTER_IPK_VERSION=1
BOGOFILTER_SOURCE=bogofilter-$(BOGOFILTER_VERSION).tar.bz2
BOGOFILTER_DIR=bogofilter-$(BOGOFILTER_VERSION)
BOGOFILTER_UNZIP=bzcat

BOGOFILTER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BOGOFILTER_DESCRIPTION=A fast Bayesian spam filter
BOGOFILTER_SECTION=net
BOGOFILTER_PRIORITY=optional
BOGOFILTER_DEPENDS=libdb
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BOGOFILTER_DEPENDS+=, libiconv
endif


BOGOFILTER_CONFFILES=/opt/etc/bogofilter.conf

ifeq ($(HOSTCC), $(TARGET_CC))
BOGOFILTER_PATCHES=
BOGOFILTER_CONFIGURE_OPTIONS=
else
BOGOFILTER_PATCHES=$(BOGOFILTER_SOURCE_DIR)/configure.ac.patch
BOGOFILTER_CONFIGURE_OPTIONS=--enable-rpath=no
endif

BOGOFILTER_CPPFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BOGOFILTER_LDFLAGS=-liconv
else
BOGOFILTER_LDFLAGS=
endif

BOGOFILTER_BUILD_DIR=$(BUILD_DIR)/bogofilter
BOGOFILTER_SOURCE_DIR=$(SOURCE_DIR)/bogofilter
BOGOFILTER_IPK_DIR=$(BUILD_DIR)/bogofilter-$(BOGOFILTER_VERSION)-ipk
BOGOFILTER_IPK=$(BUILD_DIR)/bogofilter_$(BOGOFILTER_VERSION)-$(BOGOFILTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bogofilter-source bogofilter-unpack bogofilter bogofilter-stage bogofilter-ipk bogofilter-clean bogofilter-dirclean bogofilter-check

$(BOGOFILTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bogofilter" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BOGOFILTER_PRIORITY)" >>$@
	@echo "Section: $(BOGOFILTER_SECTION)" >>$@
	@echo "Version: $(BOGOFILTER_VERSION)-$(BOGOFILTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BOGOFILTER_MAINTAINER)" >>$@
	@echo "Source: $(BOGOFILTER_SITE)/$(BOGOFILTER_SOURCE)" >>$@
	@echo "Description: $(BOGOFILTER_DESCRIPTION)" >>$@
	@echo "Depends: $(BOGOFILTER_DEPENDS)" >>$@

$(DL_DIR)/$(BOGOFILTER_SOURCE):
	$(WGET) -P $(@D) $(BOGOFILTER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

bogofilter-source: $(DL_DIR)/$(BOGOFILTER_SOURCE) $(BOGOFILTER_PATCHES)

$(BOGOFILTER_BUILD_DIR)/.configured: $(DL_DIR)/$(BOGOFILTER_SOURCE) $(BOGOFILTER_PATCHES) make/bogofilter.mk
	$(MAKE) libdb-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(BOGOFILTER_DIR) $(@D)
	$(BOGOFILTER_UNZIP) $(DL_DIR)/$(BOGOFILTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BOGOFILTER_PATCHES)"; \
		then cat $(BOGOFILTER_PATCHES) | patch -d $(BUILD_DIR)/$(BOGOFILTER_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(BOGOFILTER_DIR) $(@D)
ifneq ($(HOSTCC), $(TARGET_CC))
	autoreconf -vif $(@D)
endif
	sed -i -e '/names_next_round=/s/db /db-$(LIBDB_LIB_VERSION) /' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BOGOFILTER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BOGOFILTER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libdb-prefix=$(STAGING_PREFIX) \
		--program-prefix= \
		$(BOGOFILTER_CONFIGURE_OPTIONS) \
		--disable-nls \
	)
	touch $@

bogofilter-unpack: $(BOGOFILTER_BUILD_DIR)/.configured

$(BOGOFILTER_BUILD_DIR)/.built: $(BOGOFILTER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

bogofilter: $(BOGOFILTER_BUILD_DIR)/.built

#$(BOGOFILTER_BUILD_DIR)/.staged: $(BOGOFILTER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(BOGOFILTER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bogofilter-stage: $(BOGOFILTER_BUILD_DIR)/.staged

$(BOGOFILTER_IPK): $(BOGOFILTER_BUILD_DIR)/.built
	rm -rf $(BOGOFILTER_IPK_DIR) $(BUILD_DIR)/bogofilter_*_$(TARGET_ARCH).ipk
	install -d $(BOGOFILTER_IPK_DIR)/opt/bin/
	install -d $(BOGOFILTER_IPK_DIR)/opt/sbin/
	install -d $(BOGOFILTER_IPK_DIR)/opt/doc/bogofilter/
	install -d $(BOGOFILTER_IPK_DIR)/opt/etc/
	install -d $(BOGOFILTER_IPK_DIR)/opt/man/man1/
	install -d $(BOGOFILTER_IPK_DIR)/opt/var/spool/bogofilter
	$(MAKE) -C $(BOGOFILTER_BUILD_DIR) DESTDIR=$(BOGOFILTER_IPK_DIR) install
	$(STRIP_COMMAND) $(BOGOFILTER_IPK_DIR)/opt/bin/bogofilter
	$(STRIP_COMMAND) $(BOGOFILTER_IPK_DIR)/opt/bin/bogolexer
	$(STRIP_COMMAND) $(BOGOFILTER_IPK_DIR)/opt/bin/bogotune
	$(STRIP_COMMAND) $(BOGOFILTER_IPK_DIR)/opt/bin/bogoutil
	for i in "README.db" "README.sqlite" "README.tdb" "README.validation" \
		 "bogofilter-faq.html" "bogofilter-tuning.HOWTO.html" \
		 "bogofilter.html" "bogolexer.html" "bogotune-faq.html" \
		 "bogotune.html" "bogoupgrade.html" "bogoutil.html" \
		 "integrating-with-postfix" "integrating-with-qmail" ; do \
	    install -m 644 $(BOGOFILTER_BUILD_DIR)/doc/$$i $(BOGOFILTER_IPK_DIR)/opt/doc/bogofilter/$$i ; \
	done
	install -m 644 $(BOGOFILTER_SOURCE_DIR)/master.cf.patch $(BOGOFILTER_IPK_DIR)/opt/doc/bogofilter/master.cf.patch
	mv $(BOGOFILTER_IPK_DIR)/opt/etc/bogofilter.cf.example $(BOGOFILTER_IPK_DIR)/opt/doc/bogofilter/bogofilter.cf.example
	install -m 644 $(BOGOFILTER_SOURCE_DIR)/bogofilter.conf $(BOGOFILTER_IPK_DIR)/opt/etc/bogofilter.conf
	install -m 755 $(BOGOFILTER_SOURCE_DIR)/postfix-bogofilter.sh $(BOGOFILTER_IPK_DIR)/opt/sbin/postfix-bogofilter.sh

	$(MAKE) $(BOGOFILTER_IPK_DIR)/CONTROL/control
	install -m 755 $(BOGOFILTER_SOURCE_DIR)/postinst $(BOGOFILTER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BOGOFILTER_SOURCE_DIR)/prerm $(BOGOFILTER_IPK_DIR)/CONTROL/prerm
	echo $(BOGOFILTER_CONFFILES) | sed -e 's/ /\n/g' > $(BOGOFILTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BOGOFILTER_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BOGOFILTER_IPK_DIR)

bogofilter-ipk: $(BOGOFILTER_IPK)

bogofilter-clean:
	-$(MAKE) -C $(BOGOFILTER_BUILD_DIR) clean

bogofilter-dirclean:
	rm -rf $(BUILD_DIR)/$(BOGOFILTER_DIR) $(BOGOFILTER_BUILD_DIR) $(BOGOFILTER_IPK_DIR) $(BOGOFILTER_IPK)

#
# Some sanity check for the package.
#
bogofilter-check: $(BOGOFILTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
