###########################################################
#
# py-setuptools
#
###########################################################

#
# PY-SETUPTOOLS_VERSION, PY-SETUPTOOLS_SITE and PY-SETUPTOOLS_SOURCE define
# the upstream location of the source code for the package.
# PY-SETUPTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SETUPTOOLS_UNZIP is the command used to unzip the source.
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
PY-SETUPTOOLS_URL=https://github.com/pypa/setuptools/archive/v$(PY-SETUPTOOLS_VERSION).tar.gz
PY-SETUPTOOLS_SITE=http://pypi.python.org/packages/source/s/setuptools
PY-SETUPTOOLS_VERSION=40.6.2
PY-SETUPTOOLS_VERSION_OLD=1.4.2
PY-SETUPTOOLS_SOURCE=setuptools-$(PY-SETUPTOOLS_VERSION).tar.gz
PY-SETUPTOOLS_SOURCE_OLD=setuptools-$(PY-SETUPTOOLS_VERSION_OLD).tar.gz
PY-SETUPTOOLS_DIR=setuptools-$(PY-SETUPTOOLS_VERSION)
PY-SETUPTOOLS_DIR_OLD=setuptools-$(PY-SETUPTOOLS_VERSION_OLD)
PY-SETUPTOOLS_UNZIP=zcat
PY-SETUPTOOLS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SETUPTOOLS_DESCRIPTION=Tool to build and distribute Python packages, enhancement to distutils.
PY-SETUPTOOLS_SECTION=misc
PY-SETUPTOOLS_PRIORITY=optional
PY24-SETUPTOOLS_DEPENDS=python24
PY25-SETUPTOOLS_DEPENDS=python25
PY26-SETUPTOOLS_DEPENDS=python26
PY27-SETUPTOOLS_DEPENDS=python27
PY3-SETUPTOOLS_DEPENDS=python3
PY-SETUPTOOLS_CONFLICTS=

#
# PY-SETUPTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
PY-SETUPTOOLS_IPK_VERSION=4
PY-SETUPTOOLS_IPK_VERSION_OLD=1

#
# PY-SETUPTOOLS_CONFFILES should be a list of user-editable files
#PY-SETUPTOOLS_CONFFILES=$(TARGET_PREFIX)/etc/py-setuptools.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-setuptools

#
# PY-SETUPTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SETUPTOOLS_PATCHES=$(PY-SETUPTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SETUPTOOLS_CPPFLAGS=
PY-SETUPTOOLS_LDFLAGS=

#
# PY-SETUPTOOLS_BUILD_DIR is the directory in which the build is done.
# PY-SETUPTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SETUPTOOLS_IPK_DIR is the directory in which the ipk is built.
# PY-SETUPTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SETUPTOOLS_SOURCE_DIR=$(SOURCE_DIR)/py-setuptools
PY-SETUPTOOLS_BUILD_DIR=$(BUILD_DIR)/py-setuptools
PY-SETUPTOOLS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-setuptools

PY24-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py24-setuptools-$(PY-SETUPTOOLS_VERSION_OLD)-ipk
PY24-SETUPTOOLS_IPK=$(BUILD_DIR)/py24-setuptools_$(PY-SETUPTOOLS_VERSION_OLD)-$(PY-SETUPTOOLS_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY25-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py25-setuptools-$(PY-SETUPTOOLS_VERSION_OLD)-ipk
PY25-SETUPTOOLS_IPK=$(BUILD_DIR)/py25-setuptools_$(PY-SETUPTOOLS_VERSION_OLD)-$(PY-SETUPTOOLS_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py26-setuptools-$(PY-SETUPTOOLS_VERSION)-ipk
PY26-SETUPTOOLS_IPK=$(BUILD_DIR)/py26-setuptools_$(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py27-setuptools-$(PY-SETUPTOOLS_VERSION)-ipk
PY27-SETUPTOOLS_IPK=$(BUILD_DIR)/py27-setuptools_$(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py3-setuptools-$(PY-SETUPTOOLS_VERSION)-ipk
PY3-SETUPTOOLS_IPK=$(BUILD_DIR)/py3-setuptools_$(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-setuptools-source py-setuptools-unpack py-setuptools py-setuptools-stage py-setuptools-ipk py-setuptools-clean py-setuptools-dirclean py-setuptools-check py-setuptools-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SETUPTOOLS_SOURCE):
	$(WGET) -O $@ $(PY-SETUPTOOLS_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-SETUPTOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-setuptools-source: $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) $(PY-SETUPTOOLS_PATCHES)

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
$(PY-SETUPTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) $(PY-SETUPTOOLS_PATCHES) make/py-setuptools.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python24-stage python25-stage python26-stage python27-stage python3-stage
	rm -rf $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg; \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 bootstrap.py; \
	)
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg; \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) bootstrap.py; \
	)
	touch $@

py-setuptools-unpack: $(PY-SETUPTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SETUPTOOLS_BUILD_DIR)/.built: $(PY-SETUPTOOLS_BUILD_DIR)/.configured
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
py-setuptools: $(PY-SETUPTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SETUPTOOLS_BUILD_DIR)/.staged: $(PY-SETUPTOOLS_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/setuptools*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/setuptools*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/setuptools*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/setuptools*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/setuptools*
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-SETUPTOOLS_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) make/py-setuptools.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.4
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.5
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) $(@D)/2.6
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(@D)/2.7
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(@D)/3
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 bootstrap.py)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) bootstrap.py)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-setuptools-stage: $(PY-SETUPTOOLS_BUILD_DIR)/.staged

py-setuptools-host-stage: $(PY-SETUPTOOLS_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-setuptools
#
$(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION_OLD)-$(PY-SETUPTOOLS_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

$(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION_OLD)-$(PY-SETUPTOOLS_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

$(PY26-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION_OLD)-$(PY-SETUPTOOLS_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

$(PY27-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_URL)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

$(PY3-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_URL)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/py-setuptools/...
# Documentation files should be installed in $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/doc/py-setuptools/...
# Daemon startup scripts should be installed in $(PY-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-setuptools
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY24-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-SETUPTOOLS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SETUPTOOLS_IPK_DIR)

$(PY25-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY25-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py25-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-SETUPTOOLS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SETUPTOOLS_IPK_DIR)

$(PY26-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY26-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py26-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-SETUPTOOLS_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-SETUPTOOLS_IPK_DIR)

$(PY27-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY27-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py27-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-SETUPTOOLS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-SETUPTOOLS_IPK_DIR)

$(PY3-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY3-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py3-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-SETUPTOOLS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-SETUPTOOLS_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-SETUPTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-setuptools-ipk: $(PY24-SETUPTOOLS_IPK) $(PY25-SETUPTOOLS_IPK) $(PY26-SETUPTOOLS_IPK) $(PY27-SETUPTOOLS_IPK) $(PY3-SETUPTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-setuptools-clean:
	-$(MAKE) -C $(PY-SETUPTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-setuptools-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(HOST_BUILD_DIR)/$(PY-SETUPTOOLS_DIR_OLD)\
	$(PY-SETUPTOOLS_HOST_BUILD_DIR) $(PY-SETUPTOOLS_BUILD_DIR) \
	$(PY24-SETUPTOOLS_IPK_DIR) $(PY24-SETUPTOOLS_IPK) \
	$(PY25-SETUPTOOLS_IPK_DIR) $(PY25-SETUPTOOLS_IPK) \
	$(PY26-SETUPTOOLS_IPK_DIR) $(PY26-SETUPTOOLS_IPK) \
	$(PY27-SETUPTOOLS_IPK_DIR) $(PY27-SETUPTOOLS_IPK) \
	$(PY3-SETUPTOOLS_IPK_DIR) $(PY3-SETUPTOOLS_IPK) \

#
# Some sanity check for the package.
#
py-setuptools-check: $(PY24-SETUPTOOLS_IPK) $(PY25-SETUPTOOLS_IPK) $(PY26-SETUPTOOLS_IPK) $(PY27-SETUPTOOLS_IPK) $(PY3-SETUPTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
