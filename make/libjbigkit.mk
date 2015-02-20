#############################################################
#
# libjbigkit
#
#############################################################

LIBJBIGKIT_SITE=http://www.cl.cam.ac.uk/~mgk25/jbigkit/download
LIBJBIGKIT_VERSION:=2.1
LIBJBIGKIT_SOURCE=jbigkit-$(LIBJBIGKIT_VERSION).tar.gz
LIBJBIGKIT_DIR=jbigkit-$(LIBJBIGKIT_VERSION)
LIBJBIGKIT_UNZIP=zcat
LIBJBIGKIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBJBIGKIT_DESCRIPTION=JBIG-KIT implements a highly effective data compression algorithm for bi-level high-resolution images such as fax pages or scanned documents. This package provides JBIG-KIT C libraries of compression and decompression functions.
LIBJBIGKIT_SECTION=libs
LIBJBIGKIT_PRIORITY=optional
LIBJBIGKIT_DEPENDS=
LIBJBIGKIT_CONFLICTS=

LIBJBIGKIT_IPK_VERSION=1

LIBJBIGKIT_CFLAGS= 

LIBJBIGKIT_BUILD_DIR=$(BUILD_DIR)/libjbigkit
LIBJBIGKIT_SOURCE_DIR=$(SOURCE_DIR)/libjbigkit

LIBJBIGKIT_IPK_DIR=$(BUILD_DIR)/libjbigkit-$(LIBJBIGKIT_VERSION)-ipk
LIBJBIGKIT_IPK=$(BUILD_DIR)/libjbigkit_$(LIBJBIGKIT_VERSION)-$(LIBJBIGKIT_IPK_VERSION)_$(TARGET_ARCH).ipk


.PHONY: libjbigkit-source libjbigkit-unpack libjbigkit libjbigkit-stage libjbigkit-ipk libjbigkit-clean \
libjbigkit-dirclean libjbigkit-check libjbigkit-host libjbigkit-unstage


$(DL_DIR)/$(LIBJBIGKIT_SOURCE):
	$(WGET) -P $(@D) $(LIBJBIGKIT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

libjbigkit-source: $(DL_DIR)/$(LIBJBIGKIT_SOURCE)

$(LIBJBIGKIT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBJBIGKIT_SOURCE) make/libjbigkit.mk
	rm -rf $(BUILD_DIR)/$(LIBJBIGKIT_DIR) $(LIBJBIGKIT_BUILD_DIR)
	$(LIBJBIGKIT_UNZIP) $(DL_DIR)/$(LIBJBIGKIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(LIBJBIGKIT_DIR) $(LIBJBIGKIT_BUILD_DIR)
	touch $@

libjbigkit-unpack: $(LIBJBIGKIT_BUILD_DIR)/.configured

$(LIBJBIGKIT_BUILD_DIR)/.built: $(LIBJBIGKIT_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/libjbig; $(TARGET_CC) -fPIC -g -c $(TARGET_CFLAGS) -ansi -pedantic jbig.c
	cd $(@D)/libjbig; $(TARGET_CC) -fPIC -g -c $(TARGET_CFLAGS) -ansi -pedantic jbig85.c
	cd $(@D)/libjbig; $(TARGET_CC) -fPIC -g -c $(TARGET_CFLAGS) -ansi -pedantic jbig_ar.c
	cd $(@D)/libjbig; $(TARGET_CC) -shared -o libjbig.so jbig.o jbig_ar.o $(STAGING_LDFLAGS)
	cd $(@D)/libjbig; $(TARGET_CC) -shared -o libjbig85.so jbig85.o jbig_ar.o $(STAGING_LDFLAGS)
	touch $@

libjbigkit: $(LIBJBIGKIT_BUILD_DIR)/.built

$(LIBJBIGKIT_BUILD_DIR)/.staged: $(LIBJBIGKIT_BUILD_DIR)/.built
	install -d $(STAGING_INCLUDE_DIR)
	cp $(LIBJBIGKIT_BUILD_DIR)/libjbig/*.h $(STAGING_INCLUDE_DIR)
	install -d $(STAGING_LIB_DIR)
	cp $(LIBJBIGKIT_BUILD_DIR)/libjbig/*.so $(STAGING_LIB_DIR)
	touch $@

libjbigkit-stage: $(LIBJBIGKIT_BUILD_DIR)/.staged


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(LIBJBIGKIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libjbigkit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBJBIGKIT_PRIORITY)" >>$@
	@echo "Section: $(LIBJBIGKIT_SECTION)" >>$@
	@echo "Version: $(LIBJBIGKIT_VERSION)-$(LIBJBIGKIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBJBIGKIT_MAINTAINER)" >>$@
	@echo "Source: $(LIBJBIGKIT_SITE)/$(LIBJBIGKIT_SOURCE)" >>$@
	@echo "Description: $(LIBJBIGKIT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBJBIGKIT_DEPENDS)" >>$@
	@echo "Conflicts: $(LIBJBIGKIT_CONFLICTS)" >>$@

$(LIBJBIGKIT_IPK): $(LIBJBIGKIT_BUILD_DIR)/.built
	rm -rf $(LIBJBIGKIT_IPK_DIR) $(BUILD_DIR)/libjbigkit_*_$(TARGET_ARCH).ipk
	install -d $(LIBJBIGKIT_IPK_DIR)/opt/include
	cp $(LIBJBIGKIT_BUILD_DIR)/libjbig/*.h $(LIBJBIGKIT_IPK_DIR)/opt/include
	install -d $(LIBJBIGKIT_IPK_DIR)/opt/lib
	cp $(LIBJBIGKIT_BUILD_DIR)/libjbig/*.so $(LIBJBIGKIT_IPK_DIR)/opt/lib
	$(STRIP_COMMAND) $(LIBJBIGKIT_IPK_DIR)/opt/lib/*.so
	$(MAKE) $(LIBJBIGKIT_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBJBIGKIT_IPK_DIR)

libjbigkit-ipk: $(LIBJBIGKIT_IPK)

libjbigkit-clean: libjbigkit-unstage
	rm -f $(LIBJBIGKIT_BUILD_DIR)/.built
	rm -f $(LIBJBIGKIT_HOST_BUILD_DIR)/.staged
	rm -f $(LIBJBIGKIT_BUILD_DIR)/*.so

libjbigkit-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBJBIGKIT_DIR) $(LIBJBIGKIT_BUILD_DIR) $(LIBJBIGKIT_IPK_DIR) $(LIBJBIGKIT_IPK)

#
# Some sanity check for the package.
#
libjbigkit-check: $(LIBJBIGKIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
