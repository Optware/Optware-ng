###########################################################
#
# py-pip
#
###########################################################

#
# PY-PIP_VERSION, PY-PIP_SITE and PY-PIP_SOURCE define
# the upstream location of the source code for the package.
# PY-PIP_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PIP_UNZIP is the command used to unzip the source.
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
PY-PIP_VERSION=10.0.0
PY-PIP_SITE=https://files.pythonhosted.org/packages/e0/69/983a8e47d3dfb51e1463c1e962b2ccd1d74ec4e236e232625e353d830ed2
PY-PIP_SOURCE=pip-$(PY-PIP_VERSION).tar.gz
PY-PIP_DIR=pip-$(PY-PIP_VERSION)
PY-PIP_UNZIP=zcat
PY-PIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PIP_DESCRIPTION=The PyPA recommended tool for installing Python packages
PY-PIP_SECTION=misc
PY-PIP_PRIORITY=optional
PY26-PIP_DEPENDS=python26, py26-setuptools
PY27-PIP_DEPENDS=python27, py27-setuptools
PY3-PIP_DEPENDS=python3, py3-setuptools
PY-PIP_CONFLICTS=

#
# PY-PIP_IPK_VERSION should be incremented when the ipk changes.
#
PY-PIP_IPK_VERSION=2

#
# PY-PIP_CONFFILES should be a list of user-editable files
#PY-PIP_CONFFILES=$(TARGET_PREFIX)/etc/py-pip.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-pip

#
# PY-PIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PIP_PATCHES=$(PY-PIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PIP_CPPFLAGS=
PY-PIP_LDFLAGS=

#
# PY-PIP_BUILD_DIR is the directory in which the build is done.
# PY-PIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PIP_IPK_DIR is the directory in which the ipk is built.
# PY-PIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PIP_BUILD_DIR=$(BUILD_DIR)/py-pip
PY-PIP_SOURCE_DIR=$(SOURCE_DIR)/py-pip

PY26-PIP_IPK_DIR=$(BUILD_DIR)/py26-pip-$(PY-PIP_VERSION)-ipk
PY26-PIP_IPK=$(BUILD_DIR)/py26-pip_$(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-PIP_IPK_DIR=$(BUILD_DIR)/py27-pip-$(PY-PIP_VERSION)-ipk
PY27-PIP_IPK=$(BUILD_DIR)/py27-pip_$(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-PIP_IPK_DIR=$(BUILD_DIR)/py3-pip-$(PY-PIP_VERSION)-ipk
PY3-PIP_IPK=$(BUILD_DIR)/py3-pip_$(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pip-source py-pip-unpack py-pip py-pip-stage py-pip-ipk py-pip-clean py-pip-dirclean py-pip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PIP_SOURCE):
	$(WGET) -P $(@D) $(PY-PIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pip-source: $(DL_DIR)/$(PY-PIP_SOURCE) $(PY-PIP_PATCHES)

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
$(PY-PIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PIP_SOURCE) $(PY-PIP_PATCHES) make/py-pip.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-PIP_DIR) $(BUILD_DIR)/$(PY-PIP_DIR) $(@D)
	mkdir -p $(PY-PIP_BUILD_DIR)
	$(PY-PIP_UNZIP) $(DL_DIR)/$(PY-PIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PIP_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-PIP_UNZIP) $(DL_DIR)/$(PY-PIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PIP_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-PIP_UNZIP) $(DL_DIR)/$(PY-PIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PIP_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-pip-unpack: $(PY-PIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PIP_BUILD_DIR)/.built: $(PY-PIP_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-pip: $(PY-PIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-PIP_BUILD_DIR)/.staged: $(PY-PIP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-PIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-pip-stage: $(PY-PIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pip
#
$(PY26-PIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-pip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIP_PRIORITY)" >>$@
	@echo "Section: $(PY-PIP_SECTION)" >>$@
	@echo "Version: $(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIP_SITE)/$(PY-PIP_SOURCE)" >>$@
	@echo "Description: $(PY-PIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIP_CONFLICTS)" >>$@

$(PY27-PIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-pip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIP_PRIORITY)" >>$@
	@echo "Section: $(PY-PIP_SECTION)" >>$@
	@echo "Version: $(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIP_SITE)/$(PY-PIP_SOURCE)" >>$@
	@echo "Description: $(PY-PIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-PIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIP_CONFLICTS)" >>$@

$(PY3-PIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-pip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIP_PRIORITY)" >>$@
	@echo "Section: $(PY-PIP_SECTION)" >>$@
	@echo "Version: $(PY-PIP_VERSION)-$(PY-PIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIP_SITE)/$(PY-PIP_SOURCE)" >>$@
	@echo "Description: $(PY-PIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-PIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/etc/py-pip/...
# Documentation files should be installed in $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/doc/py-pip/...
# Daemon startup scripts should be installed in $(PY-PIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-pip
#
# You may need to patch your application to make it use these locations.
#
$(PY26-PIP_IPK): $(PY-PIP_BUILD_DIR)/.built
	rm -rf $(PY26-PIP_IPK_DIR) $(BUILD_DIR)/py26-pip_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIP_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-PIP_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY26-PIP_IPK_DIR)$(TARGET_PREFIX)/bin/pip{,2}
	$(MAKE) $(PY26-PIP_IPK_DIR)/CONTROL/control
	echo $(PY-PIP_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-PIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PIP_IPK_DIR)

$(PY27-PIP_IPK): $(PY-PIP_BUILD_DIR)/.built
	rm -rf $(PY27-PIP_IPK_DIR) $(BUILD_DIR)/py27-pip_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIP_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-PIP_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-PIP_IPK_DIR)$(TARGET_PREFIX)/bin/pip{,2}
	$(MAKE) $(PY27-PIP_IPK_DIR)/CONTROL/control
	echo $(PY-PIP_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-PIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-PIP_IPK_DIR)

$(PY3-PIP_IPK): $(PY-PIP_BUILD_DIR)/.built
	rm -rf $(PY3-PIP_IPK_DIR) $(BUILD_DIR)/py3-pip_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIP_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-PIP_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-PIP_IPK_DIR)$(TARGET_PREFIX)/bin/pip
	$(MAKE) $(PY3-PIP_IPK_DIR)/CONTROL/control
	echo $(PY-PIP_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-PIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-PIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pip-ipk: $(PY26-PIP_IPK) $(PY27-PIP_IPK) $(PY3-PIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pip-clean:
	-$(MAKE) -C $(PY-PIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pip-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PIP_DIR) $(PY-PIP_BUILD_DIR) \
	$(PY26-PIP_IPK_DIR) $(PY26-PIP_IPK) \
	$(PY27-PIP_IPK_DIR) $(PY27-PIP_IPK) \
	$(PY3-PIP_IPK_DIR) $(PY3-PIP_IPK) \

#
# Some sanity check for the package.
#
py-pip-check: $(PY26-PIP_IPK) $(PY27-PIP_IPK) $(PY3-PIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
