###########################################################
#
# py-six
#
###########################################################

#
# PY-SIX_VERSION, PY-SIX_SITE and PY-SIX_SOURCE define
# the upstream location of the source code for the package.
# PY-SIX_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SIX_UNZIP is the command used to unzip the source.
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
PY-SIX_VERSION=1.9.0
PY-SIX_VERSION_OLD=1.8.0
PY-SIX_SITE=https://pypi.python.org/packages/source/s/six
PY-SIX_SOURCE=six-$(PY-SIX_VERSION).tar.gz
PY-SIX_SOURCE_OLD=six-$(PY-SIX_VERSION_OLD).tar.gz
PY-SIX_DIR=six-$(PY-SIX_VERSION)
PY-SIX_DIR_OLD=six-$(PY-SIX_VERSION_OLD)
PY-SIX_UNZIP=zcat
PY-SIX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SIX_DESCRIPTION=Six is a Python 2 and 3 compatibility library. It provides utility functions for smoothing over the differences between the Python versions with the goal of writing Python code that is compatible on both Python versions.
PY-SIX_SECTION=misc
PY-SIX_PRIORITY=optional
PY25-SIX_DEPENDS=python25
PY26-SIX_DEPENDS=python26
PY27-SIX_DEPENDS=python27
PY26-SIX_DEPENDS=python3
PY-SIX_CONFLICTS=

#
# PY-SIX_IPK_VERSION should be incremented when the ipk changes.
#
PY-SIX_IPK_VERSION=4

#
# PY-SIX_CONFFILES should be a list of user-editable files
#PY-SIX_CONFFILES=$(TARGET_PREFIX)/etc/py-six.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-six

#
# PY-SIX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SIX_PATCHES=$(PY-SIX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SIX_CPPFLAGS=
PY-SIX_LDFLAGS=

#
# PY-SIX_BUILD_DIR is the directory in which the build is done.
# PY-SIX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SIX_IPK_DIR is the directory in which the ipk is built.
# PY-SIX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SIX_BUILD_DIR=$(BUILD_DIR)/py-six
PY-SIX_SOURCE_DIR=$(SOURCE_DIR)/py-six
PY-SIX_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-six

PY25-SIX_IPK_DIR=$(BUILD_DIR)/py25-six-$(PY-SIX_VERSION_OLD)-ipk
PY25-SIX_IPK=$(BUILD_DIR)/py25-six_$(PY-SIX_VERSION_OLD)-$(PY-SIX_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-SIX_IPK_DIR=$(BUILD_DIR)/py26-six-$(PY-SIX_VERSION)-ipk
PY26-SIX_IPK=$(BUILD_DIR)/py26-six_$(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-SIX_IPK_DIR=$(BUILD_DIR)/py27-six-$(PY-SIX_VERSION)-ipk
PY27-SIX_IPK=$(BUILD_DIR)/py27-six_$(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-SIX_IPK_DIR=$(BUILD_DIR)/py3-six-$(PY-SIX_VERSION)-ipk
PY3-SIX_IPK=$(BUILD_DIR)/py3-six_$(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-six-source py-six-unpack py-six py-six-stage py-six-ipk py-six-clean py-six-dirclean py-six-check py-six-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SIX_SOURCE):
	$(WGET) -P $(@D) $(PY-SIX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-SIX_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-SIX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-six-source: $(DL_DIR)/$(PY-SIX_SOURCE) $(DL_DIR)/$(PY-SIX_SOURCE_OLD) $(PY-SIX_PATCHES)

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
$(PY-SIX_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SIX_SOURCE) $(DL_DIR)/$(PY-SIX_SOURCE_OLD) $(PY-SIX_PATCHES) make/py-six.mk
	$(MAKE) py-setuptools-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-SIX_DIR) $(BUILD_DIR)/$(PY-SIX_DIR_OLD) $(@D)
	mkdir -p $(PY-SIX_BUILD_DIR)
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIX_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SIX_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-SIX_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIX_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SIX_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIX_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIX_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SIX_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIX_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIX_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-SIX_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIX_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-six-unpack: $(PY-SIX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SIX_BUILD_DIR)/.built: $(PY-SIX_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/six
	(cd $(@D)/2.5; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.5/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/six
	(cd $(@D)/2.6; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.6/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/six
	(cd $(@D)/2.7; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.7/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/six
	(cd $(@D)/3; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-six: $(PY-SIX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SIX_BUILD_DIR)/.staged: $(PY-SIX_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.5; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-SIX_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-SIX_SOURCE) $(DL_DIR)/$(PY-SIX_SOURCE_OLD) make/py-six.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-SIX_DIR) $(HOST_BUILD_DIR)/$(PY-SIX_DIR_OLD) $(@D)
	$(MAKE) python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SIX_DIR_OLD) $(@D)/2.5
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SIX_DIR) $(@D)/2.6
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SIX_DIR) $(@D)/2.7
	$(PY-SIX_UNZIP) $(DL_DIR)/$(PY-SIX_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-SIX_DIR) $(@D)/3
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

py-six-stage: $(PY-SIX_BUILD_DIR)/.staged

py-six-host-stage: $(PY-SIX_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-six
#
$(PY25-SIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-six" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIX_PRIORITY)" >>$@
	@echo "Section: $(PY-SIX_SECTION)" >>$@
	@echo "Version: $(PY-SIX_VERSION_OLD)-$(PY-SIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIX_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIX_SITE_OLD)/$(PY-SIX_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-SIX_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SIX_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIX_CONFLICTS)" >>$@

$(PY26-SIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-six" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIX_PRIORITY)" >>$@
	@echo "Section: $(PY-SIX_SECTION)" >>$@
	@echo "Version: $(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIX_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIX_SITE)/$(PY-SIX_SOURCE)" >>$@
	@echo "Description: $(PY-SIX_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-SIX_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIX_CONFLICTS)" >>$@

$(PY27-SIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-six" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIX_PRIORITY)" >>$@
	@echo "Section: $(PY-SIX_SECTION)" >>$@
	@echo "Version: $(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIX_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIX_SITE)/$(PY-SIX_SOURCE)" >>$@
	@echo "Description: $(PY-SIX_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-SIX_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIX_CONFLICTS)" >>$@

$(PY3-SIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-six" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIX_PRIORITY)" >>$@
	@echo "Section: $(PY-SIX_SECTION)" >>$@
	@echo "Version: $(PY-SIX_VERSION)-$(PY-SIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIX_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIX_SITE)/$(PY-SIX_SOURCE)" >>$@
	@echo "Description: $(PY-SIX_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-SIX_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/etc/py-six/...
# Documentation files should be installed in $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/doc/py-six/...
# Daemon startup scripts should be installed in $(PY-SIX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-six
#
# You may need to patch your application to make it use these locations.
#
$(PY25-SIX_IPK): $(PY-SIX_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-six_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-SIX_IPK_DIR) $(BUILD_DIR)/py25-six_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIX_BUILD_DIR)/2.5; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-SIX_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY25-SIX_IPK_DIR)/CONTROL/control
	echo $(PY-SIX_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SIX_IPK_DIR)

$(PY26-SIX_IPK): $(PY-SIX_BUILD_DIR)/.built
	rm -rf $(PY26-SIX_IPK_DIR) $(BUILD_DIR)/py26-six_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIX_BUILD_DIR)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-SIX_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-SIX_IPK_DIR)/CONTROL/control
	echo $(PY-SIX_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-SIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-SIX_IPK_DIR)

$(PY27-SIX_IPK): $(PY-SIX_BUILD_DIR)/.built
	rm -rf $(PY27-SIX_IPK_DIR) $(BUILD_DIR)/py27-six_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIX_BUILD_DIR)/2.7; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-SIX_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-SIX_IPK_DIR)/CONTROL/control
	echo $(PY-SIX_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-SIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-SIX_IPK_DIR)

$(PY3-SIX_IPK): $(PY-SIX_BUILD_DIR)/.built
	rm -rf $(PY3-SIX_IPK_DIR) $(BUILD_DIR)/py3-six_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIX_BUILD_DIR)/3; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		PYTHONPATH="$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages" \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-SIX_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-SIX_IPK_DIR)/CONTROL/control
	echo $(PY-SIX_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-SIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-SIX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-six-ipk: $(PY25-SIX_IPK) $(PY26-SIX_IPK) $(PY27-SIX_IPK) $(PY3-SIX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-six-clean:
	-$(MAKE) -C $(PY-SIX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-six-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SIX_DIR) $(BUILD_DIR)/$(PY-SIX_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-SIX_DIR) $(HOST_BUILD_DIR)/$(PY-SIX_DIR_OLD) \
	$(PY-SIX_HOST_BUILD_DIR) $(PY-SIX_BUILD_DIR) \
	$(PY25-SIX_IPK_DIR) $(PY25-SIX_IPK) \
	$(PY26-SIX_IPK_DIR) $(PY26-SIX_IPK) \
	$(PY27-SIX_IPK_DIR) $(PY27-SIX_IPK) \
	$(PY3-SIX_IPK_DIR) $(PY3-SIX_IPK) \

#
# Some sanity check for the package.
#
py-six-check: $(PY25-SIX_IPK) $(PY26-SIX_IPK) $(PY27-SIX_IPK) $(PY3-SIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
