###########################################################
#
# python
#
###########################################################

PYTHON_VERSION=2.5
PYTHON_DIR=python-$(PYTHON_VERSION)
PYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PYTHON_DESCRIPTION=This is a package that sets up the default python.
PYTHON_SECTION=devel
PYTHON_PRIORITY=optional
PYTHON_DEPENDS=python25
PYTHON_SUGGESTS=
PYTHON_CONFLICTS=

PYTHON_IPK_VERSION=1

PYTHON_IPK_DIR=$(BUILD_DIR)/python-$(PYTHON_VERSION)-ipk
PYTHON_IPK=$(BUILD_DIR)/python_$(PYTHON_VERSION)-$(PYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

python-unpack:

python:

python-stage:
	$(MAKE) python24-stage python24-host-stage
	$(MAKE) python25-stage python25-host-stage
	$(MAKE) python26-stage python26-host-stage

$(PYTHON_IPK_DIR)/CONTROL/control:
	@install -d $(PYTHON_IPK_DIR)/CONTROL
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

$(PYTHON_IPK):
	rm -rf $(PYTHON_IPK_DIR) $(BUILD_DIR)/python_*_$(TARGET_ARCH).ipk
	$(MAKE) $(PYTHON_IPK_DIR)/CONTROL/control
	install -d $(PYTHON_IPK_DIR)/opt/bin
	(cd $(PYTHON_IPK_DIR)/opt/bin; \
		ln -s python2.5 python; \
		ln -s idle2.5 idle; \
		ln -s pydoc2.5 pydoc; \
		ln -s smtpd2.5.py smtpd.py; \
	)
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	install -d $(PYTHON_IPK_DIR)/usr/bin
	ln -s /opt/bin/python $(PYTHON_IPK_DIR)/usr/bin/python
endif   
#	install -m 755 $(PYTHON_SOURCE_DIR)/postinst $(PYTHON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON_SOURCE_DIR)/prerm $(PYTHON_IPK_DIR)/CONTROL/prerm
#	echo $(PYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(PYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON_IPK_DIR)

python-ipk: $(PYTHON_IPK)

python-clean:

python-dirclean:
	rm -rf $(PYTHON_IPK_DIR) $(PYTHON_IPK)
