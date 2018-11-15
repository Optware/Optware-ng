###########################################################
#
# py-cparser
#
###########################################################

#
# PY-CPARSER_VERSION, PY-CPARSER_SITE and PY-CPARSER_SOURCE define
# the upstream location of the source code for the package.
# PY-CPARSER_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CPARSER_UNZIP is the command used to unzip the source.
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
PY-CPARSER_SITE=https://pypi.python.org/packages/source/p/pycparser
PY-CPARSER_VERSION=2.14
PY-CPARSER_SOURCE=pycparser-$(PY-CPARSER_VERSION).tar.gz
PY-CPARSER_DIR=pycparser-$(PY-CPARSER_VERSION)
PY-CPARSER_UNZIP=zcat
PY-CPARSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CPARSER_DESCRIPTION=Foreign Function Interface for Python calling C code.
PY-CPARSER_SECTION=misc
PY-CPARSER_PRIORITY=optional
PY26-CPARSER_DEPENDS=python26
PY27-CPARSER_DEPENDS=python27
PY3-CPARSER_DEPENDS=python3
PY-CPARSER_CONFLICTS=

#
# PY-CPARSER_IPK_VERSION should be incremented when the ipk changes.
#
PY-CPARSER_IPK_VERSION=4

#
# PY-CPARSER_CONFFILES should be a list of user-editable files
#PY-CPARSER_CONFFILES=$(TARGET_PREFIX)/etc/py-cparser.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cparser

#
# PY-CPARSER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CPARSER_PATCHES=$(PY-CPARSER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CPARSER_CPPFLAGS=
PY-CPARSER_LDFLAGS=

#
# PY-CPARSER_BUILD_DIR is the directory in which the build is done.
# PY-CPARSER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CPARSER_IPK_DIR is the directory in which the ipk is built.
# PY-CPARSER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CPARSER_SOURCE_DIR=$(SOURCE_DIR)/py-cparser
PY-CPARSER_BUILD_DIR=$(BUILD_DIR)/py-cparser
PY-CPARSER_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-cparser

PY26-CPARSER_IPK_DIR=$(BUILD_DIR)/py26-cparser-$(PY-CPARSER_VERSION)-ipk
PY26-CPARSER_IPK=$(BUILD_DIR)/py26-cparser_$(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CPARSER_IPK_DIR=$(BUILD_DIR)/py27-cparser-$(PY-CPARSER_VERSION)-ipk
PY27-CPARSER_IPK=$(BUILD_DIR)/py27-cparser_$(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CPARSER_IPK_DIR=$(BUILD_DIR)/py3-cparser-$(PY-CPARSER_VERSION)-ipk
PY3-CPARSER_IPK=$(BUILD_DIR)/py3-cparser_$(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-cparser-source py-cparser-unpack py-cparser py-cparser-stage py-cparser-ipk py-cparser-clean py-cparser-dirclean py-cparser-check py-cparser-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CPARSER_SOURCE):
	$(WGET) -P $(@D) $(PY-CPARSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cparser-source: $(DL_DIR)/$(PY-CPARSER_SOURCE) $(PY-CPARSER_PATCHES)

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
$(PY-CPARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CPARSER_SOURCE) $(PY-CPARSER_PATCHES) make/py-cparser.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python26-stage python27-stage python3-stage
	rm -rf $(BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE)
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CPARSER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE)
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CPARSER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE)
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CPARSER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
	touch $@

py-cparser-unpack: $(PY-CPARSER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CPARSER_BUILD_DIR)/.built: $(PY-CPARSER_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-cparser: $(PY-CPARSER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CPARSER_BUILD_DIR)/.staged: $(PY-CPARSER_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/pycparser*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/pycparser*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/pycparser*
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-CPARSER_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-CPARSER_SOURCE) make/py-cparser.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/2.6
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/2.7
	$(PY-CPARSER_UNZIP) $(DL_DIR)/$(PY-CPARSER_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CPARSER_DIR) $(@D)/3
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

py-cparser-stage: $(PY-CPARSER_BUILD_DIR)/.staged

py-cparser-host-stage: $(PY-CPARSER_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cparser
#
$(PY26-CPARSER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CPARSER_PRIORITY)" >>$@
	@echo "Section: $(PY-CPARSER_SECTION)" >>$@
	@echo "Version: $(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PY-CPARSER_SITE)/$(PY-CPARSER_SOURCE)" >>$@
	@echo "Description: $(PY-CPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CPARSER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CPARSER_CONFLICTS)" >>$@

$(PY27-CPARSER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CPARSER_PRIORITY)" >>$@
	@echo "Section: $(PY-CPARSER_SECTION)" >>$@
	@echo "Version: $(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PY-CPARSER_SITE)/$(PY-CPARSER_SOURCE)" >>$@
	@echo "Description: $(PY-CPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CPARSER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CPARSER_CONFLICTS)" >>$@

$(PY3-CPARSER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CPARSER_PRIORITY)" >>$@
	@echo "Section: $(PY-CPARSER_SECTION)" >>$@
	@echo "Version: $(PY-CPARSER_VERSION)-$(PY-CPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PY-CPARSER_SITE)/$(PY-CPARSER_SOURCE)" >>$@
	@echo "Description: $(PY-CPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CPARSER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CPARSER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/etc/py-cparser/...
# Documentation files should be installed in $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/doc/py-cparser/...
# Daemon startup scripts should be installed in $(PY-CPARSER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cparser
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CPARSER_IPK): $(PY-CPARSER_BUILD_DIR)/.built
	$(MAKE) py-cparser-stage
	rm -rf $(PY26-CPARSER_IPK_DIR) $(BUILD_DIR)/py26-cparser_*_$(TARGET_ARCH).ipk
	(cd $(PY-CPARSER_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-CPARSER_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-CPARSER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-CPARSER_IPK_DIR)/CONTROL/control
	echo $(PY-CPARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-CPARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CPARSER_IPK_DIR)

$(PY27-CPARSER_IPK): $(PY-CPARSER_BUILD_DIR)/.built
	$(MAKE) py-cparser-stage
	rm -rf $(PY27-CPARSER_IPK_DIR) $(BUILD_DIR)/py27-cparser_*_$(TARGET_ARCH).ipk
	(cd $(PY-CPARSER_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-CPARSER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-CPARSER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-CPARSER_IPK_DIR)/CONTROL/control
	echo $(PY-CPARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-CPARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CPARSER_IPK_DIR)

$(PY3-CPARSER_IPK): $(PY-CPARSER_BUILD_DIR)/.built
	$(MAKE) py-cparser-stage
	rm -rf $(PY3-CPARSER_IPK_DIR) $(BUILD_DIR)/py3-cparser_*_$(TARGET_ARCH).ipk
	(cd $(PY-CPARSER_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CPARSER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-CPARSER_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-CPARSER_IPK_DIR)/CONTROL/control
	echo $(PY-CPARSER_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-CPARSER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CPARSER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cparser-ipk: $(PY26-CPARSER_IPK) $(PY27-CPARSER_IPK) $(PY3-CPARSER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cparser-clean:
	-$(MAKE) -C $(PY-CPARSER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cparser-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CPARSER_DIR) $(HOST_BUILD_DIR)/$(PY-CPARSER_DIR) \
	$(PY-CPARSER_HOST_BUILD_DIR) $(PY-CPARSER_BUILD_DIR) \
	$(PY26-CPARSER_IPK_DIR) $(PY26-CPARSER_IPK) \
	$(PY27-CPARSER_IPK_DIR) $(PY27-CPARSER_IPK) \
	$(PY3-CPARSER_IPK_DIR) $(PY3-CPARSER_IPK) \

#
# Some sanity check for the package.
#
py-cparser-check: $(PY26-CPARSER_IPK) $(PY27-CPARSER_IPK) $(PY3-CPARSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
