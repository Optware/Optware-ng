#############################################################
#
# unrar
#
#############################################################

UNRAR_SITE=http://www.rarlab.com/rar
UNRAR_VERSION:=3.6.8
UNRAR_SOURCE=unrarsrc-$(UNRAR_VERSION).tar.gz
UNRAR_DIR=unrarsrc-$(UNRAR_VERSION)
UNRAR_UNZIP=gunzip
UNRAR_MAINTAINER=stripwax <stripwax@sourceforge.net>
UNRAR_DESCRIPTION=unrar is an application that can decompress files and archives created using the RAR compression scheme
UNRAR_SECTION=apps
UNRAR_PRIORITY=optional
UNRAR_DEPENDS=libstdc++
UNRAR_CONFLICTS=

UNRAR_IPK_VERSION=2

UNRAR_CFLAGS=$(TARGET_CFLAGS)

UNRAR_BUILD_DIR=$(BUILD_DIR)/unrar
UNRAR_SOURCE_DIR=$(SOURCE_DIR)/unrar
UNRAR_IPK_DIR=$(BUILD_DIR)/unrar-$(UNRAR_VERSION)-ipk
UNRAR_IPK=$(BUILD_DIR)/unrar_$(UNRAR_VERSION)-$(UNRAR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unrar-source unrar-unpack unrar unrar-stage unrar-ipk unrar-clean unrar-dirclean unrar-check

$(DL_DIR)/$(UNRAR_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNRAR_SITE)/$(UNRAR_SOURCE)

unrar-source: $(DL_DIR)/$(UNRAR_SOURCE)

$(UNRAR_BUILD_DIR)/.configured: $(DL_DIR)/$(UNRAR_SOURCE)
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(UNRAR_DIR) $(UNRAR_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzvf $(DL_DIR)/$(UNRAR_SOURCE)
	ln $(UNRAR_BUILD_DIR)/makefile.unix $(UNRAR_BUILD_DIR)/Makefile
	touch $(UNRAR_BUILD_DIR)/.configured

unrar-unpack: $(UNRAR_BUILD_DIR)/.configured

$(UNRAR_BUILD_DIR)/unrar: $(UNRAR_BUILD_DIR)/.configured
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(UNRAR_CFLAGS)" CXXFLAGS="$(UNRAR_CFLAGS)" \
		-C $(UNRAR_BUILD_DIR) \
		LDFLAGS="$(STAGING_LDFLAGS)"

unrar: $(UNRAR_BUILD_DIR)/unrar

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(UNRAR_IPK_DIR)/CONTROL/control:
	@install -d $(UNRAR_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: unrar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNRAR_PRIORITY)" >>$@
	@echo "Section: $(UNRAR_SECTION)" >>$@
	@echo "Version: $(UNRAR_VERSION)-$(UNRAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNRAR_MAINTAINER)" >>$@
	@echo "Source: $(UNRAR_SITE)/$(UNRAR_SOURCE)" >>$@
	@echo "Description: $(UNRAR_DESCRIPTION)" >>$@
	@echo "Depends: $(UNRAR_DEPENDS)" >>$@
	@echo "Conflicts: $(UNRAR_CONFLICTS)" >>$@

$(UNRAR_IPK): $(UNRAR_BUILD_DIR)/unrar
	rm -rf $(UNRAR_IPK_DIR) $(BUILD_DIR)/unrar_*_$(TARGET_ARCH).ipk
	install -d $(UNRAR_IPK_DIR)/opt/bin
	install -m 755 $(UNRAR_BUILD_DIR)/unrar $(UNRAR_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(UNRAR_IPK_DIR)/opt/bin/unrar
	$(MAKE) $(UNRAR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNRAR_IPK_DIR)

unrar-ipk: $(UNRAR_IPK)

unrar-clean:
	-$(MAKE) -C $(UNRAR_BUILD_DIR) clean

unrar-dirclean:
	rm -rf $(BUILD_DIR)/$(UNRAR_DIR) $(UNRAR_BUILD_DIR) $(UNRAR_IPK_DIR) $(UNRAR_IPK)

unrar-check: $(UNRAR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UNRAR_IPK)
