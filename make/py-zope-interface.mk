###########################################################
#
# py-zope-interface
#
###########################################################

#
# PY-ZOPE-INTERFACE_VERSION, PY-ZOPE-INTERFACE_SITE and PY-ZOPE-INTERFACE_SOURCE define
# the upstream location of the source code for the package.
# PY-ZOPE-INTERFACE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ZOPE-INTERFACE_UNZIP is the command used to unzip the source.
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
PY-ZOPE-INTERFACE_VERSION=4.1.2
PY-ZOPE-INTERFACE_VERSION_OLD=3.8.0
PY-ZOPE-INTERFACE_SITE=http://pypi.python.org/packages/source/z/zope.interface
PY-ZOPE-INTERFACE_SOURCE=zope.interface-$(PY-ZOPE-INTERFACE_VERSION).tar.gz
PY-ZOPE-INTERFACE_SOURCE_OLD=zope.interface-$(PY-ZOPE-INTERFACE_VERSION_OLD).tar.gz
PY-ZOPE-INTERFACE_DIR=zope.interface-$(PY-ZOPE-INTERFACE_VERSION)
PY-ZOPE-INTERFACE_DIR_OLD=zope.interface-$(PY-ZOPE-INTERFACE_VERSION_OLD)
PY-ZOPE-INTERFACE_UNZIP=zcat
PY-ZOPE-INTERFACE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ZOPE-INTERFACE_DESCRIPTION=A separate distribution of the zope.interface package used in Zope 3, along with the packages it depends on.
PY-ZOPE-INTERFACE_SECTION=misc
PY-ZOPE-INTERFACE_PRIORITY=optional
PY24-ZOPE-INTERFACE_DEPENDS=python24
PY25-ZOPE-INTERFACE_DEPENDS=python25
PY26-ZOPE-INTERFACE_DEPENDS=python26
PY27-ZOPE-INTERFACE_DEPENDS=python27
PY3-ZOPE-INTERFACE_DEPENDS=python3
PY-ZOPE-INTERFACE_CONFLICTS=

#
# PY-ZOPE-INTERFACE_IPK_VERSION should be incremented when the ipk changes.
#
PY-ZOPE-INTERFACE_IPK_VERSION=4

#
# PY-ZOPE-INTERFACE_CONFFILES should be a list of user-editable files
#PY-ZOPE-INTERFACE_CONFFILES=$(TARGET_PREFIX)/etc/py-zope-interface.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-zope-interface

#
# PY-ZOPE-INTERFACE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ZOPE-INTERFACE_PATCHES=$(PY-ZOPE-INTERFACE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ZOPE-INTERFACE_CPPFLAGS=
PY-ZOPE-INTERFACE_LDFLAGS=

#
# PY-ZOPE-INTERFACE_BUILD_DIR is the directory in which the build is done.
# PY-ZOPE-INTERFACE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ZOPE-INTERFACE_IPK_DIR is the directory in which the ipk is built.
# PY-ZOPE-INTERFACE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ZOPE-INTERFACE_BUILD_DIR=$(BUILD_DIR)/py-zope-interface
PY-ZOPE-INTERFACE_SOURCE_DIR=$(SOURCE_DIR)/py-zope-interface
PY-ZOPE-INTERFACE_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-zope-interface

PY24-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py24-zope-interface-$(PY-ZOPE-INTERFACE_VERSION_OLD)-ipk
PY24-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py24-zope-interface_$(PY-ZOPE-INTERFACE_VERSION_OLD)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py25-zope-interface-$(PY-ZOPE-INTERFACE_VERSION_OLD)-ipk
PY25-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py25-zope-interface_$(PY-ZOPE-INTERFACE_VERSION_OLD)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py26-zope-interface-$(PY-ZOPE-INTERFACE_VERSION)-ipk
PY26-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py26-zope-interface_$(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py27-zope-interface-$(PY-ZOPE-INTERFACE_VERSION)-ipk
PY27-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py27-zope-interface_$(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py3-zope-interface-$(PY-ZOPE-INTERFACE_VERSION)-ipk
PY3-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py3-zope-interface_$(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-zope-interface-source py-zope-interface-unpack py-zope-interface py-zope-interface-stage py-zope-interface-ipk py-zope-interface-clean py-zope-interface-dirclean py-zope-interface-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE):
	$(WGET) -P $(@D) $(PY-ZOPE-INTERFACE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-ZOPE-INTERFACE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-zope-interface-source: $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) $(PY-ZOPE-INTERFACE_PATCHES)

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
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) $(PY-ZOPE-INTERFACE_PATCHES) make/py-zope-interface.mk
	$(MAKE) py-setuptools-host-stage py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)
	mkdir -p $(PY-ZOPE-INTERFACE_BUILD_DIR)
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)/2.5
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
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/2.6
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
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/2.7
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
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/3
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

py-zope-interface-unpack: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.built: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-zope-interface: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-ZOPE-INTERFACE_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) make/py-zope-interface.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)/2.4
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(@D)/2.5
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/2.6
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/2.7
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(@D)/3
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

py-zope-interface-stage: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged

py-zope-interface-host-stage: $(PY-ZOPE-INTERFACE_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-zope-interface
#
$(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION_OLD)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

$(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION_OLD)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

$(PY26-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

$(PY27-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

$(PY3-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/etc/py-zope-interface/...
# Documentation files should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/doc/py-zope-interface/...
# Daemon startup scripts should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-zope-interface
#
# You may need to patch your application to make it use these locations.
#
$(PY24-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-zope-interface_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py24-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-ZOPE-INTERFACE_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY24-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib -name '*.so'`
	$(MAKE) $(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-ZOPE-INTERFACE_IPK_DIR)

$(PY25-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY25-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py25-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-ZOPE-INTERFACE_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY25-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib -name '*.so'`
	$(MAKE) $(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ZOPE-INTERFACE_IPK_DIR)

$(PY26-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY26-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py26-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-ZOPE-INTERFACE_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY26-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib -name '*.so'`
	$(MAKE) $(PY26-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-ZOPE-INTERFACE_IPK_DIR)

$(PY27-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY27-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py27-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-ZOPE-INTERFACE_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY27-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib -name '*.so'`
	$(MAKE) $(PY27-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-ZOPE-INTERFACE_IPK_DIR)

$(PY3-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY3-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py3-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-ZOPE-INTERFACE_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) `find $(PY3-ZOPE-INTERFACE_IPK_DIR)$(TARGET_PREFIX)/lib -name '*.so'`
	$(MAKE) $(PY3-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-ZOPE-INTERFACE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-zope-interface-ipk: $(PY24-ZOPE-INTERFACE_IPK) $(PY25-ZOPE-INTERFACE_IPK) $(PY26-ZOPE-INTERFACE_IPK) $(PY27-ZOPE-INTERFACE_IPK) $(PY3-ZOPE-INTERFACE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-zope-interface-clean:
	-$(MAKE) -C $(PY-ZOPE-INTERFACE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-zope-interface-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR_OLD) $(PY-ZOPE-INTERFACE_BUILD_DIR) \
	$(PY24-ZOPE-INTERFACE_IPK_DIR) $(PY24-ZOPE-INTERFACE_IPK) \
	$(PY25-ZOPE-INTERFACE_IPK_DIR) $(PY25-ZOPE-INTERFACE_IPK) \
	$(PY26-ZOPE-INTERFACE_IPK_DIR) $(PY26-ZOPE-INTERFACE_IPK) \
	$(PY27-ZOPE-INTERFACE_IPK_DIR) $(PY27-ZOPE-INTERFACE_IPK) \
	$(PY3-ZOPE-INTERFACE_IPK_DIR) $(PY3-ZOPE-INTERFACE_IPK) \

#
# Some sanity check for the package.
#
py-zope-interface-check: $(PY24-ZOPE-INTERFACE_IPK) $(PY25-ZOPE-INTERFACE_IPK) $(PY26-ZOPE-INTERFACE_IPK) $(PY27-ZOPE-INTERFACE_IPK) $(PY3-ZOPE-INTERFACE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
