###########################################################
#
# squeezecenter
#
###########################################################

SQUEEZECENTER_VERSION=7.0.1
SQUEEZECENTER_SITE=http://www.slimdevices.com/downloads/SqueezeCenter_v7.0.1
SQUEEZECENTER_DIR=squeezecenter-$(SQUEEZECENTER_VERSION)-noCPAN
SQUEEZECENTER_SOURCE=$(SQUEEZECENTER_DIR).tgz
SQUEEZECENTER_UNZIP=zcat
SQUEEZECENTER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SQUEEZECENTER_DESCRIPTION=Streaming Audio Server
SQUEEZECENTER_SECTION=audio
SQUEEZECENTER_PRIORITY=optional

SQUEEZECENTER_DEPENDS=adduser \
, perl-compress-zlib \
, perl-dbd-mysql \
, perl-digest-sha1 \
, perl-encode-detect \
, perl-gd \
, perl-html-parser \
, perl-template-toolkit \
, perl-xml-parser \
, perl-yaml-syck \

SQUEEZECENTER_SUGGESTS=flac
SQUEEZECENTER_CONFLICTS=slimserver

SQUEEZECENTER_IPK_VERSION=1

#SQUEEZECENTER_CONFFILES=/opt/etc/squeezecenter.conf /opt/etc/init.d/S99squeezecenter \
	/opt/share/squeezecenter/MySQL/my.tt

SQUEEZECENTER_PATCHES=\
	$(SQUEEZECENTER_SOURCE_DIR)/build-perl-modules.pl.patch \


#SQUEEZECENTER_CPPFLAGS=
#SQUEEZECENTER_LDFLAGS=

SQUEEZECENTER_BUILD_DIR=$(BUILD_DIR)/squeezecenter
SQUEEZECENTER_SOURCE_DIR=$(SOURCE_DIR)/squeezecenter
SQUEEZECENTER_IPK_DIR=$(BUILD_DIR)/squeezecenter-$(SQUEEZECENTER_VERSION)-ipk
SQUEEZECENTER_IPK=$(BUILD_DIR)/squeezecenter_$(SQUEEZECENTER_VERSION)-$(SQUEEZECENTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: squeezecenter-source squeezecenter-unpack squeezecenter squeezecenter-stage squeezecenter-ipk squeezecenter-clean squeezecenter-dirclean squeezecenter-check

$(DL_DIR)/$(SQUEEZECENTER_SOURCE):
	$(WGET) -P $(@D) $(SQUEEZECENTER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

squeezecenter-source: $(DL_DIR)/$(SQUEEZECENTER_SOURCE)

$(SQUEEZECENTER_BUILD_DIR)/.configured: $(DL_DIR)/$(SQUEEZECENTER_SOURCE) $(SQUEEZECENTER_PATCHES) make/squeezecenter.mk
	$(MAKE) perl-stage
	rm -rf $(BUILD_DIR)/$(SQUEEZECENTER_DIR) $(@D)
	$(SQUEEZECENTER_UNZIP) $(DL_DIR)/$(SQUEEZECENTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SQUEEZECENTER_PATCHES)" ; \
		then cat $(SQUEEZECENTER_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(SQUEEZECENTER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SQUEEZECENTER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SQUEEZECENTER_DIR) $(@D) ; \
	fi
#	cp $(SQUEEZECENTER_SOURCE_DIR)/DBD-mysql-Makefile.PL $(@D)/
#	sed -i  -e "s|^DBI_INSTARCH_DIR=.*|DBI_INSTARCH_DIR=$(@D)/temp/DBI-1.50/blib/arch/auto/DBI|" \
		-e "s|^DBI_DRIVER_XST=.*|DBI_DRIVER_XST=$(@D)/temp/DBI-1.50/blib/arch/auto/DBI/Driver.xst|" \
		$(@D)/DBD-mysql-Makefile.PL
#	cp $(SQUEEZECENTER_SOURCE_DIR)/Time-HiRes-Makefile.PL $(@D)/
#	sed -i -e "s|\$$Config{'ccflags'}|'$(STAGING_CPPFLAGS)'|" \
		-e "s|\$$Config{'cc'}|$(TARGET_CC)|" \
		$(@D)/Time-HiRes-Makefile.PL
	sed -i.bak \
		-e "s|perlBinary = <STDIN>|perlBinary = \"$(PERL_HOSTPERL)\"|" \
		-e "s|squeezeCenterPath = <STDIN>|squeezeCenterPath = \"$(@D)\"|" \
		-e "s|downloadPath = <STDIN>|downloadPath = \"$(@D)\/temp\"|" \
		$(@D)/Bin/build-perl-modules.pl
	rm -rf \
		$(@D)/CPAN/Compress \
		$(@D)/CPAN/DBD \
		$(@D)/CPAN/DBI \
		$(@D)/CPAN/Digest \
		$(@D)/CPAN/Encode \
		$(@D)/CPAN/GD* \
		$(@D)/CPAN/HTML \
		$(@D)/CPAN/Template.pm \
		$(@D)/CPAN/Time/HiRes.pm \
		$(@D)/CPAN/XML/Parser* \
		$(@D)/CPAN/YAML \
		;
	sed -i -e '1s|/usr/bin/perl|/opt/bin/perl|' \
		$(@D)/slimserver.pl \
		$(@D)/scanner.pl \
		;
	sed -i -e '/^innodb/s/^/#/' $(@D)/MySQL/my.tt
	touch $@

squeezecenter-unpack: $(SQUEEZECENTER_BUILD_DIR)/.configured

$(SQUEEZECENTER_BUILD_DIR)/.built: $(SQUEEZECENTER_BUILD_DIR)/.configured
	rm -f $@
	( mkdir $(@D)/temp; cd $(@D)/Bin; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_INC) \
		STAGING_PREFIX="$(STAGING_PREFIX)" \
		PERL_ARCH_NAME=$(GNU_TARGET_NAME) \
		$(PERL_HOSTPERL) build-perl-modules.pl \
		PREFIX=/opt \
	)
	touch $@

.PHONY: squeezecenter
squeezecenter: $(SQUEEZECENTER_BUILD_DIR)/.built

#$(SQUEEZECENTER_BUILD_DIR)/.staged: $(SQUEEZECENTER_BUILD_DIR)/.built
#	rm -f $(SQUEEZECENTER_BUILD_DIR)/.staged
#	$(MAKE) -C $(SQUEEZECENTER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(SQUEEZECENTER_BUILD_DIR)/.staged
#
#squeezecenter-stage: $(SQUEEZECENTER_BUILD_DIR)/.staged

$(SQUEEZECENTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: squeezecenter" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SQUEEZECENTER_PRIORITY)" >>$@
	@echo "Section: $(SQUEEZECENTER_SECTION)" >>$@
	@echo "Version: $(SQUEEZECENTER_VERSION)-$(SQUEEZECENTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SQUEEZECENTER_MAINTAINER)" >>$@
	@echo "Source: $(SQUEEZECENTER_SITE)/$(SQUEEZECENTER_SOURCE)" >>$@
	@echo "Description: $(SQUEEZECENTER_DESCRIPTION)" >>$@
	@echo "Depends: $(SQUEEZECENTER_DEPENDS)" >>$@
	@echo "Suggests: $(SQUEEZECENTER_SUGGESTS)" >>$@
	@echo "Conflicts: $(SQUEEZECENTER_CONFLICTS)" >>$@

$(SQUEEZECENTER_IPK): $(SQUEEZECENTER_BUILD_DIR)/.built
	rm -rf $(SQUEEZECENTER_IPK_DIR) $(BUILD_DIR)/squeezecenter_*_$(TARGET_ARCH).ipk
	install -d $(SQUEEZECENTER_IPK_DIR)/opt/etc/ $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter
	cp -rp $(SQUEEZECENTER_BUILD_DIR)/ $(SQUEEZECENTER_IPK_DIR)/opt/share
	rm -rf	$(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/.configured \
		$(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/.built
	rm -rf $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/temp
	rm -rf $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/Bin/i386-linux
	rm -rf $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/*-Makefile.PL
ifeq (7.0.1, $(SQUEEZECENTER_VERSION))
	rm -rf $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/Slim/Plugin/PreventStandby
endif
# To comply with Licence - only Logitech/Slimdevices can include the firmware bin files
# in distribution. Slimserver will download bin files at startup.
	rm -f $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/Firmware/*.bin
	(cd  $(SQUEEZECENTER_IPK_DIR)/opt/share/squeezecenter/CPAN ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/squeezecenter.conf $(SQUEEZECENTER_IPK_DIR)/opt/etc/squeezecenter.conf
	install -d $(SQUEEZECENTER_IPK_DIR)/opt/etc/init.d
#ifeq ($(OPTWARE_TARGET),fsg3)
#	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/rc.squeezecenter.fsg3 $(SQUEEZECENTER_IPK_DIR)/opt/etc/init.d/S99squeezecenter
#else
	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/rc.squeezecenter $(SQUEEZECENTER_IPK_DIR)/opt/etc/init.d/S99squeezecenter
#endif
	$(MAKE) $(SQUEEZECENTER_IPK_DIR)/CONTROL/control
	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/postinst $(SQUEEZECENTER_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/prerm $(SQUEEZECENTER_IPK_DIR)/CONTROL/prerm
	install -m 755 $(SQUEEZECENTER_SOURCE_DIR)/postrm $(SQUEEZECENTER_IPK_DIR)/CONTROL/postrm
	echo $(SQUEEZECENTER_CONFFILES) | sed -e 's/ /\n/g' > $(SQUEEZECENTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SQUEEZECENTER_IPK_DIR)

squeezecenter-ipk: $(SQUEEZECENTER_IPK)

squeezecenter-clean:
	rm -f $(SQUEEZECENTER_BUILD_DIR)/.built
#	-$(MAKE) -C $(SQUEEZECENTER_BUILD_DIR) clean

squeezecenter-dirclean:
	rm -rf $(BUILD_DIR)/$(SQUEEZECENTER_DIR) $(SQUEEZECENTER_BUILD_DIR) $(SQUEEZECENTER_IPK_DIR) $(SQUEEZECENTER_IPK)

squeezecenter-check: $(SQUEEZECENTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SQUEEZECENTER_IPK)
