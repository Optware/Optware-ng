###########################################################
#
# byrequest
#
###########################################################

BYREQUEST_VERSION=2005-04-23
BYREQUEST_SITE=http://sourceforge.net/project/byRequest
BYREQUEST_SOURCE=#none, available by CVS
BYREQUEST_REPOSITORY=:pserver:anonymous@cvs.sourceforge.net:/cvsroot/byrequest

BYREQUEST_PRIORITY=optional
BYREQUEST_SECTION=net
BYREQUEST_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BYREQUEST_DESCRIPTION=TiVo HMO server
BYREQUEST_DEPENDS=imagemagick

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
BYREQUEST_IPK=$(BUILD_DIR)/byrequest_CVS-$(BYREQUEST_IPK_VERSION)_$(TARGET_ARCH).ipk
BYREQUEST_IPK_VERSION=1

# Fetch source code
byrequest-source: 

$(BYREQUEST_BUILD_DIR)/README:
	(cd $(BUILD_DIR); cvs -d$(BYREQUEST_REPOSITORY) co -D "$(BYREQUEST_VERSION)" byRequest;)
	mv $(BUILD_DIR)/byRequest $(BUILD_DIR)/byrequest

# Configure
$(BYREQUEST_BUILD_DIR)/.configured: $(BYREQUEST_BUILD_DIR)/README
	$(MAKE) ncurses-stage
	touch $(BYREQUEST_BUILD_DIR)/.configured

byrequest-unpack: $(BYREQUEST_BUILD_DIR)/.configured

# Compile
$(BYREQUEST_BUILD_DIR)/byRequest: $(BYREQUEST_BUILD_DIR)/.configured
	$(MAKE) -C $(BYREQUEST_BUILD_DIR) CC=$(TARGET_CC) \
	RANLIB=$(TARGET_RANLIB) AR=$(TARGET_AR) LD=$(TARGET_LD) 

byrequest: $(BYREQUEST_BUILD_DIR)/byRequest

# Build ipk file
$(BYREQUEST_IPK): $(BYREQUEST_BUILD_DIR)/byRequest
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
	@install -d $(BYREQUEST_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: byrequest" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BYREQUEST_PRIORITY)" >>$@
	@echo "Section: $(BYREQUEST_SECTION)" >>$@
	@echo "Version: $(BYREQUEST_VERSION)" >>$@
	@echo "Maintainer: $(BYREQUEST_MAINTAINER)" >>$@
	@echo "Source: $(BYREQUEST_SITE)/$(BYREQUEST_SOURCE)" >>$@
	@echo "Description: $(BYREQUEST_DESCRIPTION)" >>$@
	@echo "Depends: $(BYREQUEST_DEPENDS)" >>$@

# Clean
byrequest-clean:
	-$(MAKE) -C $(BYREQUEST_BUILD_DIR) clean

byrequest-dirclean:
	rm -rf $(BYREQUEST_BUILD_DIR) $(BYREQUEST_IPK_DIR) $(BYREQUEST_IPK)
