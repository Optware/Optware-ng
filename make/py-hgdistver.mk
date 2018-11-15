###########################################################
#
# py-hgdistver
#
###########################################################

#
# PY-HGDISTVER_VERSION, PY-HGDISTVER_SITE and PY-HGDISTVER_SOURCE define
# the upstream location of the source code for the package.
# PY-HGDISTVER_DIR is the directory which is created when the source
# archive is unpacked.
# PY-HGDISTVER_UNZIP is the command used to unzip the source.
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
PY-HGDISTVER_SITE=https://pypi.python.org/packages/source/h/hgdistver
PY-HGDISTVER_VERSION=0.23
PY-HGDISTVER_VERSION_OLD=0.17
PY-HGDISTVER_SOURCE=hgdistver-$(PY-HGDISTVER_VERSION).tar.gz
PY-HGDISTVER_SOURCE_OLD=hgdistver-$(PY-HGDISTVER_VERSION_OLD).tar.gz
PY-HGDISTVER_DIR=hgdistver-$(PY-HGDISTVER_VERSION)
PY-HGDISTVER_DIR_OLD=hgdistver-$(PY-HGDISTVER_VERSION_OLD)
PY-HGDISTVER_UNZIP=zcat
PY-HGDISTVER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-HGDISTVER_DESCRIPTION=Foreign Function Interface for Python calling C code.
PY-HGDISTVER_SECTION=misc
PY-HGDISTVER_PRIORITY=optional
PY24-HGDISTVER_DEPENDS=python24
PY25-HGDISTVER_DEPENDS=python25
PY26-HGDISTVER_DEPENDS=python26
PY27-HGDISTVER_DEPENDS=python27
PY3-HGDISTVER_DEPENDS=python3
PY-HGDISTVER_CONFLICTS=

#
# PY-HGDISTVER_IPK_VERSION should be incremented when the ipk changes.
#
PY-HGDISTVER_IPK_VERSION=4

#
# PY-HGDISTVER_CONFFILES should be a list of user-editable files
#PY-HGDISTVER_CONFFILES=$(TARGET_PREFIX)/etc/py-hgdistver.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-hgdistver

#
# PY-HGDISTVER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-HGDISTVER_PATCHES=$(PY-HGDISTVER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-HGDISTVER_CPPFLAGS=
PY-HGDISTVER_LDFLAGS=

#
# PY-HGDISTVER_BUILD_DIR is the directory in which the build is done.
# PY-HGDISTVER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-HGDISTVER_IPK_DIR is the directory in which the ipk is built.
# PY-HGDISTVER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-HGDISTVER_SOURCE_DIR=$(SOURCE_DIR)/py-hgdistver
PY-HGDISTVER_BUILD_DIR=$(BUILD_DIR)/py-hgdistver
PY-HGDISTVER_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-hgdistver

PY24-HGDISTVER_IPK_DIR=$(BUILD_DIR)/py24-hgdistver-$(PY-HGDISTVER_VERSION_OLD)-ipk
PY24-HGDISTVER_IPK=$(BUILD_DIR)/py24-hgdistver_$(PY-HGDISTVER_VERSION_OLD)-$(PY-HGDISTVER_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY25-HGDISTVER_IPK_DIR=$(BUILD_DIR)/py25-hgdistver-$(PY-HGDISTVER_VERSION_OLD)-ipk
PY25-HGDISTVER_IPK=$(BUILD_DIR)/py25-hgdistver_$(PY-HGDISTVER_VERSION_OLD)-$(PY-HGDISTVER_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26-HGDISTVER_IPK_DIR=$(BUILD_DIR)/py26-hgdistver-$(PY-HGDISTVER_VERSION)-ipk
PY26-HGDISTVER_IPK=$(BUILD_DIR)/py26-hgdistver_$(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-HGDISTVER_IPK_DIR=$(BUILD_DIR)/py27-hgdistver-$(PY-HGDISTVER_VERSION)-ipk
PY27-HGDISTVER_IPK=$(BUILD_DIR)/py27-hgdistver_$(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-HGDISTVER_IPK_DIR=$(BUILD_DIR)/py3-hgdistver-$(PY-HGDISTVER_VERSION)-ipk
PY3-HGDISTVER_IPK=$(BUILD_DIR)/py3-hgdistver_$(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-hgdistver-source py-hgdistver-unpack py-hgdistver py-hgdistver-stage py-hgdistver-ipk py-hgdistver-clean py-hgdistver-dirclean py-hgdistver-check py-hgdistver-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-HGDISTVER_SOURCE):
	$(WGET) -P $(@D) $(PY-HGDISTVER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(PY-HGDISTVER_VERSION),$(PY-HGDISTVER_VERSION_OLD))
$(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-HGDISTVER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-hgdistver-source: $(DL_DIR)/$(PY-HGDISTVER_SOURCE) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) $(PY-HGDISTVER_PATCHES)

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
$(PY-HGDISTVER_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-HGDISTVER_SOURCE) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) $(PY-HGDISTVER_PATCHES) make/py-hgdistver.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python24-stage python25-stage python26-stage python27-stage python3-stage
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-HGDISTVER_DIR) $(BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE)
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGDISTVER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-HGDISTVER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE)
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGDISTVER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-HGDISTVER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE)
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGDISTVER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-HGDISTVER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE)
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGDISTVER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-HGDISTVER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE)
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGDISTVER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-HGDISTVER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
	touch $@

py-hgdistver-unpack: $(PY-HGDISTVER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-HGDISTVER_BUILD_DIR)/.built: $(PY-HGDISTVER_BUILD_DIR)/.configured
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
py-hgdistver: $(PY-HGDISTVER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-HGDISTVER_BUILD_DIR)/.staged: $(PY-HGDISTVER_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/pyhgdistver*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/pyhgdistver*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/pyhgdistver*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/pyhgdistver*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/pyhgdistver*
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-HGDISTVER_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-HGDISTVER_SOURCE) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) make/py-hgdistver.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR) $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) py-setuptools-host-stage
	mkdir -p $(@D)/
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)/2.4
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) $(@D)/2.5
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/2.6
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/2.7
	$(PY-HGDISTVER_UNZIP) $(DL_DIR)/$(PY-HGDISTVER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR) $(@D)/3
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

py-hgdistver-stage: $(PY-HGDISTVER_BUILD_DIR)/.staged

py-hgdistver-host-stage: $(PY-HGDISTVER_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-hgdistver
#
$(PY24-HGDISTVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-hgdistver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGDISTVER_PRIORITY)" >>$@
	@echo "Section: $(PY-HGDISTVER_SECTION)" >>$@
	@echo "Version: $(PY-HGDISTVER_VERSION_OLD)-$(PY-HGDISTVER_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-HGDISTVER_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGDISTVER_SITE)/$(PY-HGDISTVER_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-HGDISTVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-HGDISTVER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGDISTVER_CONFLICTS)" >>$@

$(PY25-HGDISTVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-hgdistver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGDISTVER_PRIORITY)" >>$@
	@echo "Section: $(PY-HGDISTVER_SECTION)" >>$@
	@echo "Version: $(PY-HGDISTVER_VERSION_OLD)-$(PY-HGDISTVER_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-HGDISTVER_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGDISTVER_SITE)/$(PY-HGDISTVER_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-HGDISTVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-HGDISTVER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGDISTVER_CONFLICTS)" >>$@

$(PY26-HGDISTVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-hgdistver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGDISTVER_PRIORITY)" >>$@
	@echo "Section: $(PY-HGDISTVER_SECTION)" >>$@
	@echo "Version: $(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGDISTVER_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGDISTVER_SITE)/$(PY-HGDISTVER_SOURCE)" >>$@
	@echo "Description: $(PY-HGDISTVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-HGDISTVER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGDISTVER_CONFLICTS)" >>$@

$(PY27-HGDISTVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-hgdistver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGDISTVER_PRIORITY)" >>$@
	@echo "Section: $(PY-HGDISTVER_SECTION)" >>$@
	@echo "Version: $(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGDISTVER_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGDISTVER_SITE)/$(PY-HGDISTVER_SOURCE)" >>$@
	@echo "Description: $(PY-HGDISTVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-HGDISTVER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGDISTVER_CONFLICTS)" >>$@

$(PY3-HGDISTVER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-hgdistver" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGDISTVER_PRIORITY)" >>$@
	@echo "Section: $(PY-HGDISTVER_SECTION)" >>$@
	@echo "Version: $(PY-HGDISTVER_VERSION)-$(PY-HGDISTVER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGDISTVER_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGDISTVER_SITE)/$(PY-HGDISTVER_SOURCE)" >>$@
	@echo "Description: $(PY-HGDISTVER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-HGDISTVER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGDISTVER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/etc/py-hgdistver/...
# Documentation files should be installed in $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/doc/py-hgdistver/...
# Daemon startup scripts should be installed in $(PY-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-hgdistver
#
# You may need to patch your application to make it use these locations.
#
$(PY24-HGDISTVER_IPK): $(PY-HGDISTVER_BUILD_DIR)/.built
	$(MAKE) py-hgdistver-stage
	rm -rf $(PY24-HGDISTVER_IPK_DIR) $(BUILD_DIR)/py-hgdistver_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGDISTVER_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-HGDISTVER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-HGDISTVER_IPK_DIR)/CONTROL/control
	echo $(PY-HGDISTVER_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-HGDISTVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-HGDISTVER_IPK_DIR)

$(PY25-HGDISTVER_IPK): $(PY-HGDISTVER_BUILD_DIR)/.built
	$(MAKE) py-hgdistver-stage
	rm -rf $(PY25-HGDISTVER_IPK_DIR) $(BUILD_DIR)/py25-hgdistver_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGDISTVER_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-HGDISTVER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-HGDISTVER_IPK_DIR)/CONTROL/control
	echo $(PY-HGDISTVER_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-HGDISTVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-HGDISTVER_IPK_DIR)

$(PY26-HGDISTVER_IPK): $(PY-HGDISTVER_BUILD_DIR)/.built
	$(MAKE) py-hgdistver-stage
	rm -rf $(PY26-HGDISTVER_IPK_DIR) $(BUILD_DIR)/py26-hgdistver_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGDISTVER_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-HGDISTVER_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-HGDISTVER_IPK_DIR)/CONTROL/control
	echo $(PY-HGDISTVER_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-HGDISTVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-HGDISTVER_IPK_DIR)

$(PY27-HGDISTVER_IPK): $(PY-HGDISTVER_BUILD_DIR)/.built
	$(MAKE) py-hgdistver-stage
	rm -rf $(PY27-HGDISTVER_IPK_DIR) $(BUILD_DIR)/py27-hgdistver_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGDISTVER_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-HGDISTVER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-HGDISTVER_IPK_DIR)/CONTROL/control
	echo $(PY-HGDISTVER_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-HGDISTVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-HGDISTVER_IPK_DIR)

$(PY3-HGDISTVER_IPK): $(PY-HGDISTVER_BUILD_DIR)/.built
	$(MAKE) py-hgdistver-stage
	rm -rf $(PY3-HGDISTVER_IPK_DIR) $(BUILD_DIR)/py3-hgdistver_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGDISTVER_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-HGDISTVER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-HGDISTVER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-HGDISTVER_IPK_DIR)/CONTROL/control
	echo $(PY-HGDISTVER_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-HGDISTVER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-HGDISTVER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-hgdistver-ipk: $(PY24-HGDISTVER_IPK) $(PY25-HGDISTVER_IPK) $(PY26-HGDISTVER_IPK) $(PY27-HGDISTVER_IPK) $(PY3-HGDISTVER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-hgdistver-clean:
	-$(MAKE) -C $(PY-HGDISTVER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-hgdistver-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-HGDISTVER_DIR) $(BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR) $(HOST_BUILD_DIR)/$(PY-HGDISTVER_DIR_OLD) \
	$(PY-HGDISTVER_HOST_BUILD_DIR) $(PY-HGDISTVER_BUILD_DIR) \
	$(PY24-HGDISTVER_IPK_DIR) $(PY24-HGDISTVER_IPK) \
	$(PY25-HGDISTVER_IPK_DIR) $(PY25-HGDISTVER_IPK) \
	$(PY26-HGDISTVER_IPK_DIR) $(PY26-HGDISTVER_IPK) \
	$(PY27-HGDISTVER_IPK_DIR) $(PY27-HGDISTVER_IPK) \
	$(PY3-HGDISTVER_IPK_DIR) $(PY3-HGDISTVER_IPK) \

#
# Some sanity check for the package.
#
py-hgdistver-check: $(PY24-HGDISTVER_IPK) $(PY25-HGDISTVER_IPK) $(PY26-HGDISTVER_IPK) $(PY27-HGDISTVER_IPK) $(PY3-HGDISTVER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
