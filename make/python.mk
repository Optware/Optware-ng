###########################################################
#
# python
#
###########################################################

PYTHON_VERSION=2.7
PYTHON_DIR=python-$(PYTHON_VERSION)
PYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYTHON_DESCRIPTION=This is a package that sets up the default python.
PYTHON_SECTION=devel
PYTHON_PRIORITY=optional
PYTHON_DEPENDS=python27
PYTHON_SUGGESTS=
PYTHON_CONFLICTS=

PYTHON_IPK_VERSION=2

PYTHON_IPK_DIR=$(BUILD_DIR)/python-$(PYTHON_VERSION)-ipk
PYTHON_IPK=$(BUILD_DIR)/python_$(PYTHON_VERSION)-$(PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

python-unpack:

python:

python-stage:
	$(MAKE) python24-stage python24-host-stage
	$(MAKE) python25-stage python25-host-stage
	$(MAKE) python26-stage python26-host-stage
	$(MAKE) python27-stage python27-host-stage
	$(MAKE) python3-stage python3-host-stage

$(PYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PYTHON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: python" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON_PRIORITY)" >>$@
	@echo "Section: $(PYTHON_SECTION)" >>$@
	@echo "Version: $(PYTHON_VERSION)-$(PYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON_SITE)/$(PYTHON_SOURCE)" >>$@
	@echo "Description: $(PYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON_DEPENDS)" >>$@
	@echo "Suggests: $(PYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(PYTHON_CONFLICTS)" >>$@

$(PYTHON_IPK): make/python.mk
	rm -rf $(PYTHON_IPK_DIR) $(BUILD_DIR)/python_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PYTHON_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PYTHON_IPK_DIR)$(TARGET_PREFIX)/bin
	(cd $(PYTHON_IPK_DIR)$(TARGET_PREFIX)/bin; \
		ln -s python2.7 python; \
		ln -s idle-2.7 idle; \
		ln -s pydoc-2.7 pydoc; \
		ln -s smtpd-2.7.py smtpd.py; \
	)
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	$(INSTALL) -d $(PYTHON_IPK_DIR)/usr/bin
	ln -s $(TARGET_PREFIX)/bin/python $(PYTHON_IPK_DIR)/usr/bin/python
endif   
#	$(INSTALL) -m 755 $(PYTHON_SOURCE_DIR)/postinst $(PYTHON_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(PYTHON_SOURCE_DIR)/prerm $(PYTHON_IPK_DIR)/CONTROL/prerm
#	echo $(PYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(PYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON_IPK_DIR)

python-ipk: $(PYTHON_IPK)

python-clean:

python-dirclean:
	rm -rf $(PYTHON_IPK_DIR) $(PYTHON_IPK)
