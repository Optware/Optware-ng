#############################################################
#
# par2cmdline
#
#############################################################

PAR2_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/parchive
PAR2_VERSION:=0.4
PAR2_SOURCE=par2cmdline-$(PAR2_VERSION).tar.gz
PAR2_DIR=par2cmdline-$(PAR2_VERSION)
PAR2_UNZIP=gunzip
PAR2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PAR2_DESCRIPTION=tool to apply the data-recovery capability concepts of RAID-like systems to the posting & recovery of multi-part archives on Usenet
PAR2_SECTION=apps
PAR2_PRIORITY=optional
PAR2_DEPENDS=libstdc++
PAR2_SUGGESTS=
PAR2_CONFLICTS=

PAR2_IPK_VERSION=1

PAR2_CFLAGS=$(TARGET_CFLAGS)

PAR2_BUILD_DIR=$(BUILD_DIR)/par2cmdline
PAR2_SOURCE_DIR=$(SOURCE_DIR)/par2cmdline
PAR2_IPK_DIR=$(BUILD_DIR)/par2cmdline-$(PAR2_VERSION)-ipk
PAR2_IPK=$(BUILD_DIR)/par2cmdline_$(PAR2_VERSION)-$(PAR2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: par2cmdline-source par2cmdline-unpack par2cmdline par2cmdline-stage par2cmdline-ipk par2cmdline-clean par2cmdline-dirclean par2cmdline-check

$(DL_DIR)/$(PAR2_SOURCE):
	$(WGET) -P $(DL_DIR) $(PAR2_SITE)/$(PAR2_SOURCE)

par2cmdline-source: $(DL_DIR)/$(PAR2_SOURCE)

$(PAR2_BUILD_DIR)/.configured: $(DL_DIR)/$(PAR2_SOURCE)
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(PAR2_DIR) $(PAR2_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzvf $(DL_DIR)/$(PAR2_SOURCE)
	if test "$(BUILD_DIR)/$(PAR2_DIR)" != "$(PAR2_BUILD_DIR)" ; \
                then mv $(BUILD_DIR)/$(PAR2_DIR) $(PAR2_BUILD_DIR) ; \
        fi
	(cd $(PAR2_BUILD_DIR); \
                $(TARGET_CONFIGURE_OPTS) \
                CPPFLAGS="$(STAGING_CPPFLAGS) $(PAR2_CPPFLAGS)" \
                LDFLAGS="$(STAGING_LDFLAGS) $(PAR2_LDFLAGS)" \
                ./configure \
                --build=$(GNU_HOST_NAME) \
                --host=$(GNU_TARGET_NAME) \
                --target=$(GNU_TARGET_NAME) \
                --prefix=/opt \
                --disable-nls \
                --disable-static \
        )
	touch $(PAR2_BUILD_DIR)/.configured

par2cmdline-unpack: $(PAR2_BUILD_DIR)/.configured

#
## This builds the actual binary.
#
$(PAR2_BUILD_DIR)/.built: $(PAR2_BUILD_DIR)/.configured
	rm -f $(PAR2_BUILD_DIR)/.built
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(PAR2_CFLAGS)" CXXFLAGS="$(PAR2_CFLAGS)" \
		-C $(PAR2_BUILD_DIR) \
		LDFLAGS="$(STAGING_LDFLAGS)"
	touch $(PAR2_BUILD_DIR)/.built

#
## This is the build convenience target.
#
par2cmdline: $(PAR2_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/par2cmdline
#
$(PAR2_IPK_DIR)/CONTROL/control:
	@install -d $(PAR2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: par2cmdline" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PAR2_PRIORITY)" >>$@
	@echo "Section: $(PAR2_SECTION)" >>$@
	@echo "Version: $(PAR2_VERSION)-$(PAR2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PAR2_MAINTAINER)" >>$@
	@echo "Source: $(PAR2_SITE)/$(PAR2_SOURCE)" >>$@
	@echo "Description: $(PAR2_DESCRIPTION)" >>$@
	@echo "Depends: $(PAR2_DEPENDS)" >>$@
	@echo "Conflicts: $(PAR2_CONFLICTS)" >>$@

$(PAR2_IPK): $(PAR2_BUILD_DIR)/.built
	rm -rf $(PAR2_IPK_DIR) $(BUILD_DIR)/par2cmdline_*_$(TARGET_ARCH).ipk
	install -d $(PAR2_IPK_DIR)/opt/bin
	install -m 755 $(PAR2_BUILD_DIR)/par2 $(PAR2_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(PAR2_IPK_DIR)/opt/bin/par2
	cd $(PAR2_IPK_DIR)/opt/bin; ln -s par2 par2create; ln -s par2 par2repair; ln -s par2 par2verify
	$(MAKE) $(PAR2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PAR2_IPK_DIR)

par2cmdline-ipk: $(PAR2_IPK)

par2cmdline-clean:
	-$(MAKE) -C $(PAR2_BUILD_DIR) clean

par2cmdline-dirclean:
	rm -rf $(BUILD_DIR)/$(PAR2_DIR) $(PAR2_BUILD_DIR) $(PAR2_IPK_DIR) $(PAR2_IPK)

par2cmdline-check: $(PAR2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PAR2_IPK)
