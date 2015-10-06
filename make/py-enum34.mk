###########################################################
#
# py-enum34
#
###########################################################

#
# PY-ENUM34_VERSION, PY-ENUM34_SITE and PY-ENUM34_SOURCE define
# the upstream location of the source code for the package.
# PY-ENUM34_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ENUM34_UNZIP is the command used to unzip the source.
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
PY-ENUM34_SITE=https://pypi.python.org/packages/source/e/enum34
PY-ENUM34_VERSION=1.0.4
PY-ENUM34_VERSION_OLD=1.0.4
PY-ENUM34_SOURCE=enum34-$(PY-ENUM34_VERSION).tar.gz
PY-ENUM34_SOURCE_OLD=enum34-$(PY-ENUM34_VERSION_OLD).tar.gz
PY-ENUM34_DIR=enum34-$(PY-ENUM34_VERSION)
PY-ENUM34_DIR_OLD=enum34-$(PY-ENUM34_VERSION_OLD)
PY-ENUM34_UNZIP=zcat
PY-ENUM34_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ENUM34_DESCRIPTION=Python 3.4 Enum backported.
PY-ENUM34_SECTION=misc
PY-ENUM34_PRIORITY=optional
PY24-ENUM34_DEPENDS=python24, py24-ordereddict
PY25-ENUM34_DEPENDS=python25, py25-ordereddict
PY26-ENUM34_DEPENDS=python26, py26-ordereddict
PY27-ENUM34_DEPENDS=python27
PY-ENUM34_CONFLICTS=

#
# PY-ENUM34_IPK_VERSION should be incremented when the ipk changes.
#
PY-ENUM34_IPK_VERSION=1

#
# PY-ENUM34_CONFFILES should be a list of user-editable files
#PY-ENUM34_CONFFILES=$(TARGET_PREFIX)/etc/py-enum34.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-enum34

#
# PY-ENUM34_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ENUM34_PATCHES=$(PY-ENUM34_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ENUM34_CPPFLAGS=
PY-ENUM34_LDFLAGS=

#
# PY-ENUM34_BUILD_DIR is the directory in which the build is done.
# PY-ENUM34_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ENUM34_IPK_DIR is the directory in which the ipk is built.
# PY-ENUM34_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ENUM34_SOURCE_DIR=$(SOURCE_DIR)/py-enum34
PY-ENUM34_BUILD_DIR=$(BUILD_DIR)/py-enum34
PY-ENUM34_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-enum34

PY24-ENUM34_IPK_DIR=$(BUILD_DIR)/py24-enum34-$(PY-ENUM34_VERSION_OLD)-ipk
PY24-ENUM34_IPK=$(BUILD_DIR)/py24-enum34_$(PY-ENUM34_VERSION_OLD)-$(PY-ENUM34_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY25-ENUM34_IPK_DIR=$(BUILD_DIR)/py25-enum34-$(PY-ENUM34_VERSION_OLD)-ipk
PY25-ENUM34_IPK=$(BUILD_DIR)/py25-enum34_$(PY-ENUM34_VERSION_OLD)-$(PY-ENUM34_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26-ENUM34_IPK_DIR=$(BUILD_DIR)/py26-enum34-$(PY-ENUM34_VERSION)-ipk
PY26-ENUM34_IPK=$(BUILD_DIR)/py26-enum34_$(PY-ENUM34_VERSION)-$(PY-ENUM34_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-ENUM34_IPK_DIR=$(BUILD_DIR)/py27-enum34-$(PY-ENUM34_VERSION)-ipk
PY27-ENUM34_IPK=$(BUILD_DIR)/py27-enum34_$(PY-ENUM34_VERSION)-$(PY-ENUM34_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-enum34-source py-enum34-unpack py-enum34 py-enum34-stage py-enum34-ipk py-enum34-clean py-enum34-dirclean py-enum34-check py-enum34-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ENUM34_SOURCE):
	$(WGET) -P $(@D) $(PY-ENUM34_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(PY-ENUM34_VERSION),$(PY-ENUM34_VERSION_OLD))
$(DL_DIR)/$(PY-ENUM34_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-ENUM34_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-enum34-source: $(DL_DIR)/$(PY-ENUM34_SOURCE) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) $(PY-ENUM34_PATCHES)

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
$(PY-ENUM34_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ENUM34_SOURCE) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) $(PY-ENUM34_PATCHES) make/py-enum34.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage
	$(MAKE) python24-stage python25-stage python26-stage python27-stage
	rm -rf $(BUILD_DIR)/$(PY-ENUM34_DIR) $(BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE)
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ENUM34_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ENUM34_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE)
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ENUM34_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ENUM34_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE)
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ENUM34_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ENUM34_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ENUM34_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE)
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ENUM34_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ENUM34_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ENUM34_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
	touch $@

py-enum34-unpack: $(PY-ENUM34_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ENUM34_BUILD_DIR)/.built: $(PY-ENUM34_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-enum34: $(PY-ENUM34_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ENUM34_BUILD_DIR)/.staged: $(PY-ENUM34_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) py-ordereddict-stage
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/enum*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/enum*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/enum*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/enum*
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-ENUM34_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-ENUM34_SOURCE) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) make/py-enum34.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR) $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage
	$(MAKE) py-ordereddict-host-stage
	mkdir -p $(@D)/
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)/2.4
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR_OLD) $(@D)/2.5
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR) $(@D)/2.6
	$(PY-ENUM34_UNZIP) $(DL_DIR)/$(PY-ENUM34_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR) $(@D)/2.7
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
	touch $@

py-enum34-stage: $(PY-ENUM34_BUILD_DIR)/.staged

py-enum34-host-stage: $(PY-ENUM34_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-enum34
#
$(PY24-ENUM34_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-enum34" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ENUM34_PRIORITY)" >>$@
	@echo "Section: $(PY-ENUM34_SECTION)" >>$@
	@echo "Version: $(PY-ENUM34_VERSION_OLD)-$(PY-ENUM34_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ENUM34_MAINTAINER)" >>$@
	@echo "Source: $(PY-ENUM34_SITE)/$(PY-ENUM34_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ENUM34_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-ENUM34_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ENUM34_CONFLICTS)" >>$@

$(PY25-ENUM34_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-enum34" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ENUM34_PRIORITY)" >>$@
	@echo "Section: $(PY-ENUM34_SECTION)" >>$@
	@echo "Version: $(PY-ENUM34_VERSION_OLD)-$(PY-ENUM34_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ENUM34_MAINTAINER)" >>$@
	@echo "Source: $(PY-ENUM34_SITE)/$(PY-ENUM34_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ENUM34_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ENUM34_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ENUM34_CONFLICTS)" >>$@

$(PY26-ENUM34_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-enum34" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ENUM34_PRIORITY)" >>$@
	@echo "Section: $(PY-ENUM34_SECTION)" >>$@
	@echo "Version: $(PY-ENUM34_VERSION)-$(PY-ENUM34_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ENUM34_MAINTAINER)" >>$@
	@echo "Source: $(PY-ENUM34_SITE)/$(PY-ENUM34_SOURCE)" >>$@
	@echo "Description: $(PY-ENUM34_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-ENUM34_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ENUM34_CONFLICTS)" >>$@

$(PY27-ENUM34_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-enum34" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ENUM34_PRIORITY)" >>$@
	@echo "Section: $(PY-ENUM34_SECTION)" >>$@
	@echo "Version: $(PY-ENUM34_VERSION)-$(PY-ENUM34_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ENUM34_MAINTAINER)" >>$@
	@echo "Source: $(PY-ENUM34_SITE)/$(PY-ENUM34_SOURCE)" >>$@
	@echo "Description: $(PY-ENUM34_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-ENUM34_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ENUM34_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/etc/py-enum34/...
# Documentation files should be installed in $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/doc/py-enum34/...
# Daemon startup scripts should be installed in $(PY-ENUM34_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-enum34
#
# You may need to patch your application to make it use these locations.
#
$(PY24-ENUM34_IPK): $(PY-ENUM34_BUILD_DIR)/.built
	$(MAKE) py-enum34-stage
	rm -rf $(PY24-ENUM34_IPK_DIR) $(BUILD_DIR)/py-enum34_*_$(TARGET_ARCH).ipk
	(cd $(PY-ENUM34_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-ENUM34_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-ENUM34_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-ENUM34_IPK_DIR)/CONTROL/control
	echo $(PY-ENUM34_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-ENUM34_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-ENUM34_IPK_DIR)

$(PY25-ENUM34_IPK): $(PY-ENUM34_BUILD_DIR)/.built
	$(MAKE) py-enum34-stage
	rm -rf $(PY25-ENUM34_IPK_DIR) $(BUILD_DIR)/py25-enum34_*_$(TARGET_ARCH).ipk
	(cd $(PY-ENUM34_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-ENUM34_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-ENUM34_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-ENUM34_IPK_DIR)/CONTROL/control
	echo $(PY-ENUM34_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ENUM34_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ENUM34_IPK_DIR)

$(PY26-ENUM34_IPK): $(PY-ENUM34_BUILD_DIR)/.built
	$(MAKE) py-enum34-stage
	rm -rf $(PY26-ENUM34_IPK_DIR) $(BUILD_DIR)/py26-enum34_*_$(TARGET_ARCH).ipk
	(cd $(PY-ENUM34_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-ENUM34_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-ENUM34_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-ENUM34_IPK_DIR)/CONTROL/control
	echo $(PY-ENUM34_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-ENUM34_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-ENUM34_IPK_DIR)

$(PY27-ENUM34_IPK): $(PY-ENUM34_BUILD_DIR)/.built
	$(MAKE) py-enum34-stage
	rm -rf $(PY27-ENUM34_IPK_DIR) $(BUILD_DIR)/py27-enum34_*_$(TARGET_ARCH).ipk
	(cd $(PY-ENUM34_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-ENUM34_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-ENUM34_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-ENUM34_IPK_DIR)/CONTROL/control
	echo $(PY-ENUM34_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-ENUM34_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-ENUM34_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-enum34-ipk: $(PY24-ENUM34_IPK) $(PY25-ENUM34_IPK) $(PY26-ENUM34_IPK) $(PY27-ENUM34_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-enum34-clean:
	-$(MAKE) -C $(PY-ENUM34_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-enum34-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ENUM34_DIR) $(BUILD_DIR)/$(PY-ENUM34_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-ENUM34_DIR) $(HOST_BUILD_DIR)/$(PY-ENUM34_DIR_OLD) \
	$(PY-ENUM34_HOST_BUILD_DIR) $(PY-ENUM34_BUILD_DIR) \
	$(PY24-ENUM34_IPK_DIR) $(PY24-ENUM34_IPK) \
	$(PY25-ENUM34_IPK_DIR) $(PY25-ENUM34_IPK) \
	$(PY26-ENUM34_IPK_DIR) $(PY26-ENUM34_IPK) \
	$(PY27-ENUM34_IPK_DIR) $(PY27-ENUM34_IPK) \

#
# Some sanity check for the package.
#
py-enum34-check: $(PY24-ENUM34_IPK) $(PY25-ENUM34_IPK) $(PY26-ENUM34_IPK) $(PY27-ENUM34_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
