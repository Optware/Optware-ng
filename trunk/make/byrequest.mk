###########################################################
#
# byrequest
#
###########################################################

BYREQUEST_VERSION=2005-11-15
BYREQUEST_SITE=http://sourceforge.net/project/byrequest
BYREQUEST_SOURCE=#none, available by CVS
BYREQUEST_REPOSITORY=:pserver:anonymous@byrequest.cvs.sourceforge.net:/cvsroot/byrequest

BYREQUEST_PRIORITY=optional
BYREQUEST_SECTION=net
BYREQUEST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BYREQUEST_DESCRIPTION=TiVo HMO server
BYREQUEST_DEPENDS=imagemagick, psmisc

#
# BYREQUEST_BUILD_DIR is the directory in which the build is done.
# BYREQUEST_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BYREQUEST_IPK_DIR is the directory in which the ipk is built.
# BYREQUEST_IPK is the name of the resulting ipk files.
#
BYREQUEST_BUILD_DIR=$(BUILD_DIR)/byrequest
BYREQUEST_SOURCE_DIR=$(SOURCE_DIR)/byrequest
BYREQUEST_IPK_DIR=$(BUILD_DIR)/byrequest-ipk
BYREQUEST_IPK=$(BUILD_DIR)/byrequest_cvs-$(BYREQUEST_VERSION)-$(BYREQUEST_IPK_VERSION)_$(TARGET_ARCH).ipk
BYREQUEST_IPK_VERSION=2

.PHONY: byrequest-source byrequest-unpack byrequest byrequest-stage byrequest-ipk byrequest-clean byrequest-dirclean byrequest-check

# Fetch source code
byrequest-source: $(DL_DIR)/byrequest-$(BYREQUEST_VERSION).tar.gz

$(DL_DIR)/byrequest-$(BYREQUEST_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf byRequest && \
		cvs -d$(BYREQUEST_REPOSITORY) co \
			-D "$(BYREQUEST_VERSION)" \
			byRequest && \
		tar -czf $(DL_DIR)/byrequest-$(BYREQUEST_VERSION).tar.gz \
			byRequest && \
		rm -rf byRequest \
	)

# Configure
$(BYREQUEST_BUILD_DIR)/.configured: \
		$(DL_DIR)/byrequest-$(BYREQUEST_VERSION).tar.gz
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/byRequest $(BUILD_DIR)/byrequest
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/byrequest-$(BYREQUEST_VERSION).tar.gz
	mv $(BUILD_DIR)/byRequest $(BUILD_DIR)/byrequest
	touch $(BYREQUEST_BUILD_DIR)/.configured

byrequest-unpack: $(BYREQUEST_BUILD_DIR)/.configured

# Compile
$(BYREQUEST_BUILD_DIR)/.built: $(BYREQUEST_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(BYREQUEST_BUILD_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD)
	touch $@ 

byrequest: $(BYREQUEST_BUILD_DIR)/.built

# Build ipk file
$(BYREQUEST_IPK): $(BYREQUEST_BUILD_DIR)/.built
	rm -rf $(BYREQUEST_IPK_DIR) $(BUILD_DIR)/byrequest_*_$(TARGET_ARCH).ipk
	# Bin file
	install -d $(BYREQUEST_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BYREQUEST_BUILD_DIR)/byRequest -o $(BYREQUEST_IPK_DIR)/opt/bin/byRequest
	# Docs file
	install -d $(BYREQUEST_IPK_DIR)/opt/usr/doc/byRequest
	install -m 644 $(BYREQUEST_BUILD_DIR)/byRequest.conf $(BYREQUEST_IPK_DIR)/opt/usr/doc/byRequest
	install -m 644 $(BYREQUEST_BUILD_DIR)/README* $(BYREQUEST_IPK_DIR)/opt/usr/doc/byRequest
	install -m 644 $(BYREQUEST_BUILD_DIR)/ANNOUNCE $(BYREQUEST_IPK_DIR)/opt/usr/doc/byRequest
	# Init file
	install -d $(BYREQUEST_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BYREQUEST_SOURCE_DIR)/S99byRequest $(BYREQUEST_IPK_DIR)/opt/etc/init.d/S99byRequest
	# Control files
	install -d $(BYREQUEST_IPK_DIR)/CONTROL
	$(MAKE) $(BYREQUEST_IPK_DIR)/CONTROL/control
	install -m 644 $(BYREQUEST_SOURCE_DIR)/postinst $(BYREQUEST_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BYREQUEST_IPK_DIR)

byrequest-ipk: $(BYREQUEST_IPK)

# Make Control file
$(BYREQUEST_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: byrequest" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BYREQUEST_PRIORITY)" >>$@
	@echo "Section: $(BYREQUEST_SECTION)" >>$@
	@echo "Version: cvs-$(BYREQUEST_VERSION)-$(BYREQUEST_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BYREQUEST_MAINTAINER)" >>$@
	@echo "Source: $(BYREQUEST_SITE)/$(BYREQUEST_SOURCE)" >>$@
	@echo "Description: $(BYREQUEST_DESCRIPTION)" >>$@
	@echo "Depends: $(BYREQUEST_DEPENDS)" >>$@

# Clean
byrequest-clean:
	-$(MAKE) -C $(BYREQUEST_BUILD_DIR) clean

byrequest-dirclean:
	rm -rf $(BYREQUEST_BUILD_DIR) $(BYREQUEST_IPK_DIR) $(BYREQUEST_IPK)

# Some sanity check for the package.
#
byrequest-check: $(BYREQUEST_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^

