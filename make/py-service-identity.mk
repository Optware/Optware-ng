###########################################################
#
# py-service-identity
#
###########################################################

#
# PY-SERVICE-IDENTITY_VERSION, PY-SERVICE-IDENTITY_SITE and PY-SERVICE-IDENTITY_SOURCE define
# the upstream location of the source code for the package.
# PY-SERVICE-IDENTITY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SERVICE-IDENTITY_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
PY-SERVICE-IDENTITY_SITE=https://pypi.python.org/packages/source/s/service_identity
PY-SERVICE-IDENTITY_VERSION=14.0.0
PY-SERVICE-IDENTITY_SOURCE=service_identity-$(PY-SERVICE-IDENTITY_VERSION).tar.gz
PY-SERVICE-IDENTITY_DIR=service_identity-$(PY-SERVICE-IDENTITY_VERSION)
PY-SERVICE-IDENTITY_UNZIP=zcat
PY-SERVICE-IDENTITY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SERVICE-IDENTITY_DESCRIPTION=Use this package if you use pyOpenSSL and don’t want to be MITMed. service_identity aspires to give you all the tools you need for verifying whether a certificate is valid for the intended purposes. In the simplest case, this means host name verification. However, service_identity implements RFC 6125 fully and plans to add other relevant RFCs too.
PY-SERVICE-IDENTITY_SECTION=misc
PY-SERVICE-IDENTITY_PRIORITY=optional
PY26-SERVICE-IDENTITY_DEPENDS=python26, py26-openssl, py26-asn1-modules, py26-characteristic
PY27-SERVICE-IDENTITY_DEPENDS=python27, py27-openssl, py27-asn1-modules, py27-characteristic
PY3-SERVICE-IDENTITY_DEPENDS=python3, py3-openssl, py3-asn1-modules, py3-characteristic
PY-SERVICE-IDENTITY_CONFLICTS=

#
# PY-SERVICE-IDENTITY_IPK_VERSION should be incremented when the ipk changes.
#
PY-SERVICE-IDENTITY_IPK_VERSION=4

#
# PY-SERVICE-IDENTITY_CONFFILES should be a list of user-editable files
#PY-SERVICE-IDENTITY_CONFFILES=$(TARGET_PREFIX)/etc/py-service-identity.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-service-identity

#
# PY-SERVICE-IDENTITY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SERVICE-IDENTITY_PATCHES=$(PY-SERVICE-IDENTITY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SERVICE-IDENTITY_CPPFLAGS=
PY-SERVICE-IDENTITY_LDFLAGS=

#
# PY-SERVICE-IDENTITY_BUILD_DIR is the directory in which the build is done.
# PY-SERVICE-IDENTITY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SERVICE-IDENTITY_IPK_DIR is the directory in which the ipk is built.
# PY-SERVICE-IDENTITY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SERVICE-IDENTITY_SOURCE_DIR=$(SOURCE_DIR)/py-service-identity
PY-SERVICE-IDENTITY_BUILD_DIR=$(BUILD_DIR)/py-service-identity
PY-SERVICE-IDENTITY_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-service-identity

PY26-SERVICE-IDENTITY_IPK_DIR=$(BUILD_DIR)/py26-service-identity-$(PY-SERVICE-IDENTITY_VERSION)-ipk
PY26-SERVICE-IDENTITY_IPK=$(BUILD_DIR)/py26-service-identity_$(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-SERVICE-IDENTITY_IPK_DIR=$(BUILD_DIR)/py27-service-identity-$(PY-SERVICE-IDENTITY_VERSION)-ipk
PY27-SERVICE-IDENTITY_IPK=$(BUILD_DIR)/py27-service-identity_$(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-SERVICE-IDENTITY_IPK_DIR=$(BUILD_DIR)/py3-service-identity-$(PY-SERVICE-IDENTITY_VERSION)-ipk
PY3-SERVICE-IDENTITY_IPK=$(BUILD_DIR)/py3-service-identity_$(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-service-identity-source py-service-identity-unpack py-service-identity py-service-identity-stage py-service-identity-ipk py-service-identity-clean py-service-identity-dirclean py-service-identity-check py-service-identity-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE):
	$(WGET) -P $(@D) $(PY-SERVICE-IDENTITY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-service-identity-source: $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) $(PY-SERVICE-IDENTITY_PATCHES)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
$(PY-SERVICE-IDENTITY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) $(PY-SERVICE-IDENTITY_PATCHES) make/py-service-identity.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python26-stage python27-stage python3-stage
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE)
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SERVICE-IDENTITY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE)
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SERVICE-IDENTITY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE)
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SERVICE-IDENTITY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
	touch $@

py-service-identity-unpack: $(PY-SERVICE-IDENTITY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SERVICE-IDENTITY_BUILD_DIR)/.built: $(PY-SERVICE-IDENTITY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-service-identity: $(PY-SERVICE-IDENTITY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SERVICE-IDENTITY_BUILD_DIR)/.staged: $(PY-SERVICE-IDENTITY_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/service-identity*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/service-identity*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/service-identity*
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-SERVICE-IDENTITY_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) make/py-service-identity.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/2.6
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/2.7
	$(PY-SERVICE-IDENTITY_UNZIP) $(DL_DIR)/$(PY-SERVICE-IDENTITY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(@D)/3
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-service-identity-stage: $(PY-SERVICE-IDENTITY_BUILD_DIR)/.staged

py-service-identity-host-stage: $(PY-SERVICE-IDENTITY_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-service-identity
#
$(PY26-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-service-identity" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SERVICE-IDENTITY_PRIORITY)" >>$@
	@echo "Section: $(PY-SERVICE-IDENTITY_SECTION)" >>$@
	@echo "Version: $(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SERVICE-IDENTITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SERVICE-IDENTITY_SITE)/$(PY-SERVICE-IDENTITY_SOURCE)" >>$@
	@echo "Description: $(PY-SERVICE-IDENTITY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-SERVICE-IDENTITY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SERVICE-IDENTITY_CONFLICTS)" >>$@

$(PY27-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-service-identity" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SERVICE-IDENTITY_PRIORITY)" >>$@
	@echo "Section: $(PY-SERVICE-IDENTITY_SECTION)" >>$@
	@echo "Version: $(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SERVICE-IDENTITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SERVICE-IDENTITY_SITE)/$(PY-SERVICE-IDENTITY_SOURCE)" >>$@
	@echo "Description: $(PY-SERVICE-IDENTITY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-SERVICE-IDENTITY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SERVICE-IDENTITY_CONFLICTS)" >>$@

$(PY3-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-service-identity" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SERVICE-IDENTITY_PRIORITY)" >>$@
	@echo "Section: $(PY-SERVICE-IDENTITY_SECTION)" >>$@
	@echo "Version: $(PY-SERVICE-IDENTITY_VERSION)-$(PY-SERVICE-IDENTITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SERVICE-IDENTITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SERVICE-IDENTITY_SITE)/$(PY-SERVICE-IDENTITY_SOURCE)" >>$@
	@echo "Description: $(PY-SERVICE-IDENTITY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-SERVICE-IDENTITY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SERVICE-IDENTITY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/etc/py-service-identity/...
# Documentation files should be installed in $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/doc/py-service-identity/...
# Daemon startup scripts should be installed in $(PY-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-service-identity
#
# You may need to patch your application to make it use these locations.
#
$(PY26-SERVICE-IDENTITY_IPK): $(PY-SERVICE-IDENTITY_BUILD_DIR)/.built
	$(MAKE) py-service-identity-stage
	rm -rf $(PY26-SERVICE-IDENTITY_IPK_DIR) $(BUILD_DIR)/py26-service-identity_*_$(TARGET_ARCH).ipk
	(cd $(PY-SERVICE-IDENTITY_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-SERVICE-IDENTITY_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control
	echo $(PY-SERVICE-IDENTITY_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-SERVICE-IDENTITY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-SERVICE-IDENTITY_IPK_DIR)

$(PY27-SERVICE-IDENTITY_IPK): $(PY-SERVICE-IDENTITY_BUILD_DIR)/.built
	$(MAKE) py-service-identity-stage
	rm -rf $(PY27-SERVICE-IDENTITY_IPK_DIR) $(BUILD_DIR)/py27-service-identity_*_$(TARGET_ARCH).ipk
	(cd $(PY-SERVICE-IDENTITY_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-SERVICE-IDENTITY_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control
	echo $(PY-SERVICE-IDENTITY_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-SERVICE-IDENTITY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-SERVICE-IDENTITY_IPK_DIR)

$(PY3-SERVICE-IDENTITY_IPK): $(PY-SERVICE-IDENTITY_BUILD_DIR)/.built
	$(MAKE) py-service-identity-stage
	rm -rf $(PY3-SERVICE-IDENTITY_IPK_DIR) $(BUILD_DIR)/py3-service-identity_*_$(TARGET_ARCH).ipk
	(cd $(PY-SERVICE-IDENTITY_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-SERVICE-IDENTITY_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-SERVICE-IDENTITY_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-SERVICE-IDENTITY_IPK_DIR)/CONTROL/control
	echo $(PY-SERVICE-IDENTITY_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-SERVICE-IDENTITY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-SERVICE-IDENTITY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-service-identity-ipk: $(PY26-SERVICE-IDENTITY_IPK) $(PY27-SERVICE-IDENTITY_IPK) $(PY3-SERVICE-IDENTITY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-service-identity-clean:
	-$(MAKE) -C $(PY-SERVICE-IDENTITY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-service-identity-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) $(HOST_BUILD_DIR)/$(PY-SERVICE-IDENTITY_DIR) \
	$(PY-SERVICE-IDENTITY_HOST_BUILD_DIR) $(PY-SERVICE-IDENTITY_BUILD_DIR) \
	$(PY26-SERVICE-IDENTITY_IPK_DIR) $(PY26-SERVICE-IDENTITY_IPK) \
	$(PY27-SERVICE-IDENTITY_IPK_DIR) $(PY27-SERVICE-IDENTITY_IPK) \
	$(PY3-SERVICE-IDENTITY_IPK_DIR) $(PY3-SERVICE-IDENTITY_IPK) \

#
# Some sanity check for the package.
#
py-service-identity-check: $(PY26-SERVICE-IDENTITY_IPK) $(PY27-SERVICE-IDENTITY_IPK) $(PY3-SERVICE-IDENTITY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
