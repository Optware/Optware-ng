###########################################################
#
# py-chardet
#
###########################################################

#
# PY-CHARDET_VERSION, PY-CHARDET_SITE and PY-CHARDET_SOURCE define
# the upstream location of the source code for the package.
# PY-CHARDET_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CHARDET_UNZIP is the command used to unzip the source.
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
PY-CHARDET_SITE=https://pypi.python.org/packages/source/c/chardet
PY-CHARDET_VERSION=2.3.0
PY-CHARDET_SOURCE=chardet-$(PY-CHARDET_VERSION).tar.gz
PY-CHARDET_DIR=chardet-$(PY-CHARDET_VERSION)
PY-CHARDET_UNZIP=zcat
PY-CHARDET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CHARDET_DESCRIPTION=Universal encoding detector for Python 2 and 3.
PY-CHARDET_SECTION=misc
PY-CHARDET_PRIORITY=optional
PY26-CHARDET_DEPENDS=python26
PY27-CHARDET_DEPENDS=python27
PY3-CHARDET_DEPENDS=python3
PY-CHARDET_CONFLICTS=

#
# PY-CHARDET_IPK_VERSION should be incremented when the ipk changes.
#
PY-CHARDET_IPK_VERSION=4

#
# PY-CHARDET_CONFFILES should be a list of user-editable files
#PY-CHARDET_CONFFILES=$(TARGET_PREFIX)/etc/py-chardet.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-chardet

#
# PY-CHARDET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CHARDET_PATCHES=$(PY-CHARDET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CHARDET_CPPFLAGS=
PY-CHARDET_LDFLAGS=

#
# PY-CHARDET_BUILD_DIR is the directory in which the build is done.
# PY-CHARDET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CHARDET_IPK_DIR is the directory in which the ipk is built.
# PY-CHARDET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CHARDET_SOURCE_DIR=$(SOURCE_DIR)/py-chardet
PY-CHARDET_BUILD_DIR=$(BUILD_DIR)/py-chardet

PY26-CHARDET_IPK_DIR=$(BUILD_DIR)/py26-chardet-$(PY-CHARDET_VERSION)-ipk
PY26-CHARDET_IPK=$(BUILD_DIR)/py26-chardet_$(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CHARDET_IPK_DIR=$(BUILD_DIR)/py27-chardet-$(PY-CHARDET_VERSION)-ipk
PY27-CHARDET_IPK=$(BUILD_DIR)/py27-chardet_$(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CHARDET_IPK_DIR=$(BUILD_DIR)/py3-chardet-$(PY-CHARDET_VERSION)-ipk
PY3-CHARDET_IPK=$(BUILD_DIR)/py3-chardet_$(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-chardet-source py-chardet-unpack py-chardet py-chardet-stage py-chardet-ipk py-chardet-clean py-chardet-dirclean py-chardet-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CHARDET_SOURCE):
	$(WGET) -P $(@D) $(PY-CHARDET_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-chardet-source: $(DL_DIR)/$(PY-CHARDET_SOURCE) $(PY-CHARDET_PATCHES)

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
$(PY-CHARDET_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CHARDET_SOURCE) $(PY-CHARDET_PATCHES) make/py-chardet.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage py-setuptools-host-stage
	$(MAKE) python26-stage python27-stage python3-stage py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CHARDET_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE)
	$(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHARDET_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CHARDET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHARDET_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE)
	$(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHARDET_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CHARDET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHARDET_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE)
	$(PY-CHARDET_UNZIP) $(DL_DIR)/$(PY-CHARDET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHARDET_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CHARDET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHARDET_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python3"; \
	    ) >> setup.cfg \
	)
	touch $@

py-chardet-unpack: $(PY-CHARDET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CHARDET_BUILD_DIR)/.built: $(PY-CHARDET_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-chardet: $(PY-CHARDET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CHARDET_BUILD_DIR)/.staged: $(PY-CHARDET_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/chardet*
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

py-chardet-stage: $(PY-CHARDET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-chardet
#
$(PY26-CHARDET_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-chardet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHARDET_PRIORITY)" >>$@
	@echo "Section: $(PY-CHARDET_SECTION)" >>$@
	@echo "Version: $(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHARDET_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHARDET_SITE)/$(PY-CHARDET_SOURCE)" >>$@
	@echo "Description: $(PY-CHARDET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CHARDET_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHARDET_CONFLICTS)" >>$@

$(PY27-CHARDET_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-chardet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHARDET_PRIORITY)" >>$@
	@echo "Section: $(PY-CHARDET_SECTION)" >>$@
	@echo "Version: $(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHARDET_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHARDET_SITE)/$(PY-CHARDET_SOURCE)" >>$@
	@echo "Description: $(PY-CHARDET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CHARDET_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHARDET_CONFLICTS)" >>$@

$(PY3-CHARDET_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-chardet" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHARDET_PRIORITY)" >>$@
	@echo "Section: $(PY-CHARDET_SECTION)" >>$@
	@echo "Version: $(PY-CHARDET_VERSION)-$(PY-CHARDET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHARDET_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHARDET_SITE)/$(PY-CHARDET_SOURCE)" >>$@
	@echo "Description: $(PY-CHARDET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CHARDET_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHARDET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/etc/py-chardet/...
# Documentation files should be installed in $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/doc/py-chardet/...
# Daemon startup scripts should be installed in $(PY-CHARDET_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-chardet
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CHARDET_IPK): $(PY-CHARDET_BUILD_DIR)/.built
	$(MAKE) py-chardet-stage
	rm -rf $(PY26-CHARDET_IPK_DIR) $(BUILD_DIR)/py26-chardet_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHARDET_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-CHARDET_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-CHARDET_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-CHARDET_IPK_DIR)/CONTROL/control
	echo $(PY-CHARDET_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-CHARDET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CHARDET_IPK_DIR)

$(PY27-CHARDET_IPK): $(PY-CHARDET_BUILD_DIR)/.built
	$(MAKE) py-chardet-stage
	rm -rf $(PY27-CHARDET_IPK_DIR) $(BUILD_DIR)/py27-chardet_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHARDET_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-CHARDET_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-CHARDET_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-CHARDET_IPK_DIR)/CONTROL/control
	echo $(PY-CHARDET_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-CHARDET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CHARDET_IPK_DIR)

$(PY3-CHARDET_IPK): $(PY-CHARDET_BUILD_DIR)/.built
	$(MAKE) py-chardet-stage
	rm -rf $(PY3-CHARDET_IPK_DIR) $(BUILD_DIR)/py3-chardet_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHARDET_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CHARDET_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-CHARDET_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-CHARDET_IPK_DIR)/CONTROL/control
	echo $(PY-CHARDET_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-CHARDET_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CHARDET_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-chardet-ipk: $(PY24-CHARDET_IPK) $(PY25-CHARDET_IPK) $(PY26-CHARDET_IPK) $(PY27-CHARDET_IPK) $(PY3-CHARDET_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-chardet-clean:
	-$(MAKE) -C $(PY-CHARDET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-chardet-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CHARDET_DIR) $(PY-CHARDET_BUILD_DIR) \
	$(PY26-CHARDET_IPK_DIR) $(PY26-CHARDET_IPK) \
	$(PY27-CHARDET_IPK_DIR) $(PY27-CHARDET_IPK) \
	$(PY3-CHARDET_IPK_DIR) $(PY3-CHARDET_IPK) \

#
# Some sanity check for the package.
#
py-chardet-check: $(PY26-CHARDET_IPK) $(PY27-CHARDET_IPK) $(PY3-CHARDET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
