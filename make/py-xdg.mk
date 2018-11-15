###########################################################
#
# py-xdg
#
###########################################################

#
# PY-XDG_VERSION, PY-XDG_SITE and PY-XDG_SOURCE define
# the upstream location of the source code for the package.
# PY-XDG_DIR is the directory which is created when the source
# archive is unpacked.
# PY-XDG_UNZIP is the command used to unzip the source.
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
PY-XDG_SITE=https://pypi.python.org/packages/source/p/pyxdg
PY-XDG_VERSION=0.25
PY-XDG_VERSION_OLD=0.19
PY-XDG_SOURCE=pyxdg-$(PY-XDG_VERSION).tar.gz
PY-XDG_SOURCE_OLD=pyxdg-$(PY-XDG_VERSION_OLD).tar.gz
PY-XDG_DIR=pyxdg-$(PY-XDG_VERSION)
PY-XDG_DIR_OLD=pyxdg-$(PY-XDG_VERSION_OLD)
PY-XDG_UNZIP=zcat
PY-XDG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-XDG_DESCRIPTION=PyXDG contains implementations of freedesktop.org standards in python.
PY-XDG_SECTION=misc
PY-XDG_PRIORITY=optional
PY24-XDG_DEPENDS=python24
PY25-XDG_DEPENDS=python25
PY26-XDG_DEPENDS=python26
PY27-XDG_DEPENDS=python27
PY3-XDG_DEPENDS=python3
PY-XDG_CONFLICTS=

#
# PY-XDG_IPK_VERSION should be incremented when the ipk changes.
#
PY-XDG_IPK_VERSION=4

#
# PY-XDG_CONFFILES should be a list of user-editable files
#PY-XDG_CONFFILES=$(TARGET_PREFIX)/etc/py-xdg.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-xdg

#
# PY-XDG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-XDG_PATCHES=$(PY-XDG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-XDG_CPPFLAGS=
PY-XDG_LDFLAGS=

#
# PY-XDG_BUILD_DIR is the directory in which the build is done.
# PY-XDG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-XDG_IPK_DIR is the directory in which the ipk is built.
# PY-XDG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-XDG_SOURCE_DIR=$(SOURCE_DIR)/py-xdg
PY-XDG_BUILD_DIR=$(BUILD_DIR)/py-xdg

PY24-XDG_IPK_DIR=$(BUILD_DIR)/py24-xdg-$(PY-XDG_VERSION_OLD)-ipk
PY24-XDG_IPK=$(BUILD_DIR)/py24-xdg_$(PY-XDG_VERSION_OLD)-$(PY-XDG_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-XDG_IPK_DIR=$(BUILD_DIR)/py25-xdg-$(PY-XDG_VERSION_OLD)-ipk
PY25-XDG_IPK=$(BUILD_DIR)/py25-xdg_$(PY-XDG_VERSION_OLD)-$(PY-XDG_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-XDG_IPK_DIR=$(BUILD_DIR)/py26-xdg-$(PY-XDG_VERSION)-ipk
PY26-XDG_IPK=$(BUILD_DIR)/py26-xdg_$(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-XDG_IPK_DIR=$(BUILD_DIR)/py27-xdg-$(PY-XDG_VERSION)-ipk
PY27-XDG_IPK=$(BUILD_DIR)/py27-xdg_$(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-XDG_IPK_DIR=$(BUILD_DIR)/py3-xdg-$(PY-XDG_VERSION)-ipk
PY3-XDG_IPK=$(BUILD_DIR)/py3-xdg_$(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-xdg-source py-xdg-unpack py-xdg py-xdg-stage py-xdg-ipk py-xdg-clean py-xdg-dirclean py-xdg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-XDG_SOURCE):
	$(WGET) -P $(@D) $(PY-XDG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-XDG_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-XDG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-xdg-source: $(DL_DIR)/$(PY-XDG_SOURCE) $(DL_DIR)/$(PY-XDG_SOURCE_OLD) $(PY-XDG_PATCHES)

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
$(PY-XDG_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-XDG_SOURCE) $(DL_DIR)/$(PY-XDG_SOURCE_OLD) $(PY-XDG_PATCHES) make/py-xdg.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python24-stage python25-stage python26-stage python27-stage python3-stage
	rm -rf $(BUILD_DIR)/$(PY-XDG_DIR) $(BUILD_DIR)/$(PY-XDG_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE_OLD)
	$(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XDG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-XDG_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-XDG_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE_OLD)
	$(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XDG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-XDG_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-XDG_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE)
	$(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XDG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-XDG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-XDG_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE)
	$(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XDG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-XDG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-XDG_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE)
	$(PY-XDG_UNZIP) $(DL_DIR)/$(PY-XDG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XDG_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-XDG_DIR) -p1
	mv $(BUILD_DIR)/$(PY-XDG_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
	touch $@

py-xdg-unpack: $(PY-XDG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-XDG_BUILD_DIR)/.built: $(PY-XDG_BUILD_DIR)/.configured
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
py-xdg: $(PY-XDG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-XDG_BUILD_DIR)/.staged: $(PY-XDG_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/xdg*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/xdg*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/xdg*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

py-xdg-stage: $(PY-XDG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-xdg
#
$(PY24-XDG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-xdg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XDG_PRIORITY)" >>$@
	@echo "Section: $(PY-XDG_SECTION)" >>$@
	@echo "Version: $(PY-XDG_VERSION_OLD)-$(PY-XDG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XDG_MAINTAINER)" >>$@
	@echo "Source: $(PY-XDG_SITE)/$(PY-XDG_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-XDG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-XDG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-XDG_CONFLICTS)" >>$@

$(PY25-XDG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-xdg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XDG_PRIORITY)" >>$@
	@echo "Section: $(PY-XDG_SECTION)" >>$@
	@echo "Version: $(PY-XDG_VERSION_OLD)-$(PY-XDG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XDG_MAINTAINER)" >>$@
	@echo "Source: $(PY-XDG_SITE)/$(PY-XDG_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-XDG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-XDG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-XDG_CONFLICTS)" >>$@

$(PY26-XDG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-xdg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XDG_PRIORITY)" >>$@
	@echo "Section: $(PY-XDG_SECTION)" >>$@
	@echo "Version: $(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XDG_MAINTAINER)" >>$@
	@echo "Source: $(PY-XDG_SITE)/$(PY-XDG_SOURCE)" >>$@
	@echo "Description: $(PY-XDG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-XDG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-XDG_CONFLICTS)" >>$@

$(PY27-XDG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-xdg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XDG_PRIORITY)" >>$@
	@echo "Section: $(PY-XDG_SECTION)" >>$@
	@echo "Version: $(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XDG_MAINTAINER)" >>$@
	@echo "Source: $(PY-XDG_SITE)/$(PY-XDG_SOURCE)" >>$@
	@echo "Description: $(PY-XDG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-XDG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-XDG_CONFLICTS)" >>$@

$(PY3-XDG_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-xdg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XDG_PRIORITY)" >>$@
	@echo "Section: $(PY-XDG_SECTION)" >>$@
	@echo "Version: $(PY-XDG_VERSION)-$(PY-XDG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XDG_MAINTAINER)" >>$@
	@echo "Source: $(PY-XDG_SITE)/$(PY-XDG_SOURCE)" >>$@
	@echo "Description: $(PY-XDG_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-XDG_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-XDG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/etc/py-xdg/...
# Documentation files should be installed in $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/doc/py-xdg/...
# Daemon startup scripts should be installed in $(PY-XDG_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-xdg
#
# You may need to patch your application to make it use these locations.
#
$(PY24-XDG_IPK): $(PY-XDG_BUILD_DIR)/.built
	$(MAKE) py-xdg-stage
	rm -rf $(PY24-XDG_IPK_DIR) $(BUILD_DIR)/py-xdg_*_$(TARGET_ARCH).ipk
	(cd $(PY-XDG_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-XDG_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-XDG_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-XDG_IPK_DIR)/CONTROL/control
	echo $(PY-XDG_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-XDG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-XDG_IPK_DIR)

$(PY25-XDG_IPK): $(PY-XDG_BUILD_DIR)/.built
	$(MAKE) py-xdg-stage
	rm -rf $(PY25-XDG_IPK_DIR) $(BUILD_DIR)/py25-xdg_*_$(TARGET_ARCH).ipk
	(cd $(PY-XDG_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-XDG_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-XDG_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-XDG_IPK_DIR)/CONTROL/control
	echo $(PY-XDG_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-XDG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-XDG_IPK_DIR)

$(PY26-XDG_IPK): $(PY-XDG_BUILD_DIR)/.built
	$(MAKE) py-xdg-stage
	rm -rf $(PY26-XDG_IPK_DIR) $(BUILD_DIR)/py26-xdg_*_$(TARGET_ARCH).ipk
	(cd $(PY-XDG_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-XDG_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-XDG_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-XDG_IPK_DIR)/CONTROL/control
	echo $(PY-XDG_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-XDG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-XDG_IPK_DIR)

$(PY27-XDG_IPK): $(PY-XDG_BUILD_DIR)/.built
	$(MAKE) py-xdg-stage
	rm -rf $(PY27-XDG_IPK_DIR) $(BUILD_DIR)/py27-xdg_*_$(TARGET_ARCH).ipk
	(cd $(PY-XDG_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-XDG_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-XDG_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-XDG_IPK_DIR)/CONTROL/control
	echo $(PY-XDG_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-XDG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-XDG_IPK_DIR)

$(PY3-XDG_IPK): $(PY-XDG_BUILD_DIR)/.built
	$(MAKE) py-xdg-stage
	rm -rf $(PY3-XDG_IPK_DIR) $(BUILD_DIR)/py3-xdg_*_$(TARGET_ARCH).ipk
	(cd $(PY-XDG_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-XDG_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-XDG_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-XDG_IPK_DIR)/CONTROL/control
	echo $(PY-XDG_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-XDG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-XDG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-xdg-ipk: $(PY24-XDG_IPK) $(PY25-XDG_IPK) $(PY26-XDG_IPK) $(PY27-XDG_IPK) $(PY3-XDG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-xdg-clean:
	-$(MAKE) -C $(PY-XDG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-xdg-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-XDG_DIR) $(BUILD_DIR)/$(PY-XDG_DIR_OLD) $(PY-XDG_BUILD_DIR) \
	$(PY24-XDG_IPK_DIR) $(PY24-XDG_IPK) \
	$(PY25-XDG_IPK_DIR) $(PY25-XDG_IPK) \
	$(PY26-XDG_IPK_DIR) $(PY26-XDG_IPK) \
	$(PY27-XDG_IPK_DIR) $(PY27-XDG_IPK) \
	$(PY3-XDG_IPK_DIR) $(PY3-XDG_IPK) \

#
# Some sanity check for the package.
#
py-xdg-check: $(PY24-XDG_IPK) $(PY25-XDG_IPK) $(PY26-XDG_IPK) $(PY27-XDG_IPK) $(PY3-XDG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
