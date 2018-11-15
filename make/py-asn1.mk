###########################################################
#
# py-asn1
#
###########################################################

#
# PY-ASN1_VERSION, PY-ASN1_SITE and PY-ASN1_SOURCE define
# the upstream location of the source code for the package.
# PY-ASN1_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ASN1_UNZIP is the command used to unzip the source.
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
PY-ASN1_SITE=https://pypi.python.org/packages/source/p/pyasn1
PY-ASN1_VERSION=0.1.8
PY-ASN1_VERSION_OLD=0.1.8
PY-ASN1_SOURCE=pyasn1-$(PY-ASN1_VERSION).tar.gz
PY-ASN1_SOURCE_OLD=pyasn1-$(PY-ASN1_VERSION_OLD).tar.gz
PY-ASN1_DIR=pyasn1-$(PY-ASN1_VERSION)
PY-ASN1_DIR_OLD=pyasn1-$(PY-ASN1_VERSION_OLD)
PY-ASN1_UNZIP=zcat
PY-ASN1_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ASN1_DESCRIPTION=This is an implementation of ASN.1 types and codecs in Python programming language. It has been first written to support particular protocol (SNMP) but then generalized to be suitable for a wide range of protocols based on ASN.1 specification.
PY-ASN1_SECTION=misc
PY-ASN1_PRIORITY=optional
PY24-ASN1_DEPENDS=python24
PY25-ASN1_DEPENDS=python25
PY26-ASN1_DEPENDS=python26
PY27-ASN1_DEPENDS=python27
PY3-ASN1_DEPENDS=python3
PY-ASN1_CONFLICTS=

#
# PY-ASN1_IPK_VERSION should be incremented when the ipk changes.
#
PY-ASN1_IPK_VERSION=4

#
# PY-ASN1_CONFFILES should be a list of user-editable files
#PY-ASN1_CONFFILES=$(TARGET_PREFIX)/etc/py-asn1.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-asn1

#
# PY-ASN1_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ASN1_PATCHES=$(PY-ASN1_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ASN1_CPPFLAGS=
PY-ASN1_LDFLAGS=

#
# PY-ASN1_BUILD_DIR is the directory in which the build is done.
# PY-ASN1_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ASN1_IPK_DIR is the directory in which the ipk is built.
# PY-ASN1_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ASN1_SOURCE_DIR=$(SOURCE_DIR)/py-asn1
PY-ASN1_BUILD_DIR=$(BUILD_DIR)/py-asn1
PY-ASN1_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-asn1

PY24-ASN1_IPK_DIR=$(BUILD_DIR)/py24-asn1-$(PY-ASN1_VERSION_OLD)-ipk
PY24-ASN1_IPK=$(BUILD_DIR)/py24-asn1_$(PY-ASN1_VERSION_OLD)-$(PY-ASN1_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY25-ASN1_IPK_DIR=$(BUILD_DIR)/py25-asn1-$(PY-ASN1_VERSION_OLD)-ipk
PY25-ASN1_IPK=$(BUILD_DIR)/py25-asn1_$(PY-ASN1_VERSION_OLD)-$(PY-ASN1_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26-ASN1_IPK_DIR=$(BUILD_DIR)/py26-asn1-$(PY-ASN1_VERSION)-ipk
PY26-ASN1_IPK=$(BUILD_DIR)/py26-asn1_$(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-ASN1_IPK_DIR=$(BUILD_DIR)/py27-asn1-$(PY-ASN1_VERSION)-ipk
PY27-ASN1_IPK=$(BUILD_DIR)/py27-asn1_$(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-ASN1_IPK_DIR=$(BUILD_DIR)/py3-asn1-$(PY-ASN1_VERSION)-ipk
PY3-ASN1_IPK=$(BUILD_DIR)/py3-asn1_$(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-asn1-source py-asn1-unpack py-asn1 py-asn1-stage py-asn1-ipk py-asn1-clean py-asn1-dirclean py-asn1-check py-asn1-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ASN1_SOURCE):
	$(WGET) -P $(@D) $(PY-ASN1_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(PY-ASN1_VERSION),$(PY-ASN1_VERSION_OLD))
$(DL_DIR)/$(PY-ASN1_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-ASN1_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-asn1-source: $(DL_DIR)/$(PY-ASN1_SOURCE) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) $(PY-ASN1_PATCHES)

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
$(PY-ASN1_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ASN1_SOURCE) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) $(PY-ASN1_PATCHES) make/py-asn1.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python24-stage python25-stage python26-stage python27-stage python3-stage
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-ASN1_DIR) $(BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE)
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ASN1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ASN1_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE)
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ASN1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ASN1_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE)
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ASN1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ASN1_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE)
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ASN1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ASN1_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE)
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ASN1_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ASN1_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
	touch $@

py-asn1-unpack: $(PY-ASN1_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ASN1_BUILD_DIR)/.built: $(PY-ASN1_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-asn1: $(PY-ASN1_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ASN1_BUILD_DIR)/.staged: $(PY-ASN1_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/asn1*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/pyasn1*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/pyasn1*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/pyasn1*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/pyasn1*
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-ASN1_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-ASN1_SOURCE) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) make/py-asn1.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-ASN1_DIR) $(HOST_BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)/2.4
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ASN1_DIR_OLD) $(@D)/2.5
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/2.6
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/2.7
	$(PY-ASN1_UNZIP) $(DL_DIR)/$(PY-ASN1_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ASN1_DIR) $(@D)/3
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
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

py-asn1-stage: $(PY-ASN1_BUILD_DIR)/.staged

py-asn1-host-stage: $(PY-ASN1_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-asn1
#
$(PY24-ASN1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-asn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ASN1_PRIORITY)" >>$@
	@echo "Section: $(PY-ASN1_SECTION)" >>$@
	@echo "Version: $(PY-ASN1_VERSION_OLD)-$(PY-ASN1_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ASN1_MAINTAINER)" >>$@
	@echo "Source: $(PY-ASN1_SITE)/$(PY-ASN1_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-ASN1_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ASN1_CONFLICTS)" >>$@

$(PY25-ASN1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-asn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ASN1_PRIORITY)" >>$@
	@echo "Section: $(PY-ASN1_SECTION)" >>$@
	@echo "Version: $(PY-ASN1_VERSION_OLD)-$(PY-ASN1_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ASN1_MAINTAINER)" >>$@
	@echo "Source: $(PY-ASN1_SITE)/$(PY-ASN1_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ASN1_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ASN1_CONFLICTS)" >>$@

$(PY26-ASN1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-asn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ASN1_PRIORITY)" >>$@
	@echo "Section: $(PY-ASN1_SECTION)" >>$@
	@echo "Version: $(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ASN1_MAINTAINER)" >>$@
	@echo "Source: $(PY-ASN1_SITE)/$(PY-ASN1_SOURCE)" >>$@
	@echo "Description: $(PY-ASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-ASN1_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ASN1_CONFLICTS)" >>$@

$(PY27-ASN1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-asn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ASN1_PRIORITY)" >>$@
	@echo "Section: $(PY-ASN1_SECTION)" >>$@
	@echo "Version: $(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ASN1_MAINTAINER)" >>$@
	@echo "Source: $(PY-ASN1_SITE)/$(PY-ASN1_SOURCE)" >>$@
	@echo "Description: $(PY-ASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-ASN1_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ASN1_CONFLICTS)" >>$@

$(PY3-ASN1_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-asn1" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ASN1_PRIORITY)" >>$@
	@echo "Section: $(PY-ASN1_SECTION)" >>$@
	@echo "Version: $(PY-ASN1_VERSION)-$(PY-ASN1_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ASN1_MAINTAINER)" >>$@
	@echo "Source: $(PY-ASN1_SITE)/$(PY-ASN1_SOURCE)" >>$@
	@echo "Description: $(PY-ASN1_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-ASN1_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ASN1_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/etc/py-asn1/...
# Documentation files should be installed in $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/doc/py-asn1/...
# Daemon startup scripts should be installed in $(PY-ASN1_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-asn1
#
# You may need to patch your application to make it use these locations.
#
$(PY24-ASN1_IPK): $(PY-ASN1_BUILD_DIR)/.built
	$(MAKE) py-asn1-stage
	rm -rf $(PY24-ASN1_IPK_DIR) $(BUILD_DIR)/py-asn1_*_$(TARGET_ARCH).ipk
	(cd $(PY-ASN1_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-ASN1_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-ASN1_IPK_DIR)/CONTROL/control
	echo $(PY-ASN1_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-ASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-ASN1_IPK_DIR)

$(PY25-ASN1_IPK): $(PY-ASN1_BUILD_DIR)/.built
	$(MAKE) py-asn1-stage
	rm -rf $(PY25-ASN1_IPK_DIR) $(BUILD_DIR)/py25-asn1_*_$(TARGET_ARCH).ipk
	(cd $(PY-ASN1_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-ASN1_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-ASN1_IPK_DIR)/CONTROL/control
	echo $(PY-ASN1_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ASN1_IPK_DIR)

$(PY26-ASN1_IPK): $(PY-ASN1_BUILD_DIR)/.built
	$(MAKE) py-asn1-stage
	rm -rf $(PY26-ASN1_IPK_DIR) $(BUILD_DIR)/py26-asn1_*_$(TARGET_ARCH).ipk
	(cd $(PY-ASN1_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-ASN1_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-ASN1_IPK_DIR)/CONTROL/control
	echo $(PY-ASN1_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-ASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-ASN1_IPK_DIR)

$(PY27-ASN1_IPK): $(PY-ASN1_BUILD_DIR)/.built
	$(MAKE) py-asn1-stage
	rm -rf $(PY27-ASN1_IPK_DIR) $(BUILD_DIR)/py27-asn1_*_$(TARGET_ARCH).ipk
	(cd $(PY-ASN1_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-ASN1_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-ASN1_IPK_DIR)/CONTROL/control
	echo $(PY-ASN1_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-ASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-ASN1_IPK_DIR)

$(PY3-ASN1_IPK): $(PY-ASN1_BUILD_DIR)/.built
	$(MAKE) py-asn1-stage
	rm -rf $(PY3-ASN1_IPK_DIR) $(BUILD_DIR)/py3-asn1_*_$(TARGET_ARCH).ipk
	(cd $(PY-ASN1_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-ASN1_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-ASN1_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-ASN1_IPK_DIR)/CONTROL/control
	echo $(PY-ASN1_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-ASN1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-ASN1_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-asn1-ipk: $(PY24-ASN1_IPK) $(PY25-ASN1_IPK) $(PY26-ASN1_IPK) $(PY27-ASN1_IPK) $(PY3-ASN1_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-asn1-clean:
	-$(MAKE) -C $(PY-ASN1_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-asn1-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ASN1_DIR) $(BUILD_DIR)/$(PY-ASN1_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-ASN1_DIR) $(HOST_BUILD_DIR)/$(PY-ASN1_DIR_OLD) \
	$(PY-ASN1_HOST_BUILD_DIR) $(PY-ASN1_BUILD_DIR) \
	$(PY24-ASN1_IPK_DIR) $(PY24-ASN1_IPK) \
	$(PY25-ASN1_IPK_DIR) $(PY25-ASN1_IPK) \
	$(PY26-ASN1_IPK_DIR) $(PY26-ASN1_IPK) \
	$(PY27-ASN1_IPK_DIR) $(PY27-ASN1_IPK) \
	$(PY3-ASN1_IPK_DIR) $(PY3-ASN1_IPK) \

#
# Some sanity check for the package.
#
py-asn1-check: $(PY24-ASN1_IPK) $(PY25-ASN1_IPK) $(PY26-ASN1_IPK) $(PY27-ASN1_IPK) $(PY3-ASN1_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
