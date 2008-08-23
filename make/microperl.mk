###########################################################
#
# microperl
#
###########################################################

ifeq (5.10, $(PERL_MAJOR_VER))
MICROPERL_VERSION=5.10.0
MICROPERL_IPK_VERSION=1
else
MICROPERL_VERSION=5.8.8
MICROPERL_IPK_VERSION=11
endif

MICROPERL_DESCRIPTION=Microperl.
MICROPERL_SOURCE=perl-$(MICROPERL_VERSION).tar.gz


MICROPERL_BUILD_DIR=$(BUILD_DIR)/microperl
MICROPERL_SOURCE_DIR=$(SOURCE_DIR)/microperl
MICROPERL_IPK_DIR=$(BUILD_DIR)/microperl-$(MICROPERL_VERSION)-ipk
MICROPERL_IPK=$(BUILD_DIR)/microperl_$(MICROPERL_VERSION)-$(MICROPERL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: microperl-unpack microperl microperl-ipk microperl-clean microperl-dirclean microperl-check

$(MICROPERL_BUILD_DIR)/.configured: $(DL_DIR)/$(MICROPERL_SOURCE) $(MICROPERL_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(@D)
	$(PERL_UNZIP) $(DL_DIR)/$(PERL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MICROPERL_PATCHES)"; then \
		cat $(MICROPERL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MICROPERL_DIR) -p0 ; \
	fi
	mv $(BUILD_DIR)/$(PERL_DIR) $(@D)
	touch $@

microperl-unpack: $(MICROPERL_BUILD_DIR)/.configured

$(MICROPERL_BUILD_DIR)/.built: $(MICROPERL_BUILD_DIR)/.configured
	rm -f $@
ifeq (5.10, $(PERL_MAJOR_VER))
	$(MAKE) -C $(@D) -f Makefile.micro generate_uudmap \
		CC=$(HOSTCC) \
		;
endif
	$(MAKE) -C $(@D) -f Makefile.micro \
		CC=$(TARGET_CC) OPTIMIZE="$(TARGET_CFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
microperl: $(MICROPERL_BUILD_DIR)/.built

$(MICROPERL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: microperl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_PRIORITY)" >>$@
	@echo "Section: $(PERL_SECTION)" >>$@
	@echo "Version: $(MICROPERL_VERSION)-$(MICROPERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MAINTAINER)" >>$@
	@echo "Source: $(PERL_SITE)/$(PERL_SOURCE)" >>$@
	@echo "Description: $(MICROPERL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_DEPENDS)" >>$@
	@echo "Conflicts: $(PERL_CONFLICTS)" >>$@

$(MICROPERL_IPK): $(MICROPERL_BUILD_DIR)/.built
	rm -rf $(MICROPERL_IPK_DIR) $(BUILD_DIR)/microperl_*_$(TARGET_ARCH).ipk
	install -d $(MICROPERL_IPK_DIR)/opt/bin
	install -m 755 $(MICROPERL_BUILD_DIR)/microperl $(MICROPERL_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(MICROPERL_IPK_DIR)/opt/bin/*
	$(MAKE) $(MICROPERL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MICROPERL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
microperl-ipk: $(MICROPERL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
microperl-clean:
	rm -f $(MICROPERL_BUILD_DIR)/.built
	-$(MAKE) -C $(MICROPERL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
microperl-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL_DIR) $(MICROPERL_BUILD_DIR) $(MICROPERL_IPK_DIR) $(MICROPERL_IPK)

#
#
# Some sanity check for the package.
#
microperl-check: $(MICROPERL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MICROPERL_IPK)
