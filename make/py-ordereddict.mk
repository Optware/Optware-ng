###########################################################
#
# py-ordereddict
#
###########################################################

#
# PY-ORDEREDDICT_VERSION, PY-ORDEREDDICT_SITE and PY-ORDEREDDICT_SOURCE define
# the upstream location of the source code for the package.
# PY-ORDEREDDICT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ORDEREDDICT_UNZIP is the command used to unzip the source.
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
PY-ORDEREDDICT_SITE=https://pypi.python.org/packages/source/o/ordereddict
PY-ORDEREDDICT_VERSION=1.1
PY-ORDEREDDICT_VERSION_OLD=1.1
PY-ORDEREDDICT_SOURCE=ordereddict-$(PY-ORDEREDDICT_VERSION).tar.gz
PY-ORDEREDDICT_SOURCE_OLD=ordereddict-$(PY-ORDEREDDICT_VERSION_OLD).tar.gz
PY-ORDEREDDICT_DIR=ordereddict-$(PY-ORDEREDDICT_VERSION)
PY-ORDEREDDICT_DIR_OLD=ordereddict-$(PY-ORDEREDDICT_VERSION_OLD)
PY-ORDEREDDICT_UNZIP=zcat
PY-ORDEREDDICT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ORDEREDDICT_DESCRIPTION=A drop-in substitute for Py2.7's new collections.OrderedDict that works in Python 2.4-2.6.
PY-ORDEREDDICT_SECTION=misc
PY-ORDEREDDICT_PRIORITY=optional
PY24-ORDEREDDICT_DEPENDS=python24
PY25-ORDEREDDICT_DEPENDS=python25
PY26-ORDEREDDICT_DEPENDS=python26
PY-ORDEREDDICT_CONFLICTS=

#
# PY-ORDEREDDICT_IPK_VERSION should be incremented when the ipk changes.
#
PY-ORDEREDDICT_IPK_VERSION=1

#
# PY-ORDEREDDICT_CONFFILES should be a list of user-editable files
#PY-ORDEREDDICT_CONFFILES=$(TARGET_PREFIX)/etc/py-ordereddict.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-ordereddict

#
# PY-ORDEREDDICT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ORDEREDDICT_PATCHES=$(PY-ORDEREDDICT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ORDEREDDICT_CPPFLAGS=
PY-ORDEREDDICT_LDFLAGS=

#
# PY-ORDEREDDICT_BUILD_DIR is the directory in which the build is done.
# PY-ORDEREDDICT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ORDEREDDICT_IPK_DIR is the directory in which the ipk is built.
# PY-ORDEREDDICT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ORDEREDDICT_SOURCE_DIR=$(SOURCE_DIR)/py-ordereddict
PY-ORDEREDDICT_BUILD_DIR=$(BUILD_DIR)/py-ordereddict
PY-ORDEREDDICT_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-ordereddict

PY24-ORDEREDDICT_IPK_DIR=$(BUILD_DIR)/py24-ordereddict-$(PY-ORDEREDDICT_VERSION_OLD)-ipk
PY24-ORDEREDDICT_IPK=$(BUILD_DIR)/py24-ordereddict_$(PY-ORDEREDDICT_VERSION_OLD)-$(PY-ORDEREDDICT_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY25-ORDEREDDICT_IPK_DIR=$(BUILD_DIR)/py25-ordereddict-$(PY-ORDEREDDICT_VERSION_OLD)-ipk
PY25-ORDEREDDICT_IPK=$(BUILD_DIR)/py25-ordereddict_$(PY-ORDEREDDICT_VERSION_OLD)-$(PY-ORDEREDDICT_IPK_VERSION_OLD)_$(TARGET_ARCH).ipk

PY26-ORDEREDDICT_IPK_DIR=$(BUILD_DIR)/py26-ordereddict-$(PY-ORDEREDDICT_VERSION)-ipk
PY26-ORDEREDDICT_IPK=$(BUILD_DIR)/py26-ordereddict_$(PY-ORDEREDDICT_VERSION)-$(PY-ORDEREDDICT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-ordereddict-source py-ordereddict-unpack py-ordereddict py-ordereddict-stage py-ordereddict-ipk py-ordereddict-clean py-ordereddict-dirclean py-ordereddict-check py-ordereddict-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ORDEREDDICT_SOURCE):
	$(WGET) -P $(@D) $(PY-ORDEREDDICT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(PY-ORDEREDDICT_VERSION),$(PY-ORDEREDDICT_VERSION_OLD))
$(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-ORDEREDDICT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-ordereddict-source: $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) $(PY-ORDEREDDICT_PATCHES)

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
$(PY-ORDEREDDICT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) $(PY-ORDEREDDICT_PATCHES) make/py-ordereddict.mk
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage
	$(MAKE) python24-stage python25-stage python26-stage
	rm -rf $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE)
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ORDEREDDICT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE)
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ORDEREDDICT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE)
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ORDEREDDICT_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
	touch $@

py-ordereddict-unpack: $(PY-ORDEREDDICT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ORDEREDDICT_BUILD_DIR)/.built: $(PY-ORDEREDDICT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-ordereddict: $(PY-ORDEREDDICT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ORDEREDDICT_BUILD_DIR)/.staged: $(PY-ORDEREDDICT_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/ordereddict*
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/ordereddict*
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/ordereddict*
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-ORDEREDDICT_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) make/py-ordereddict.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage
	mkdir -p $(@D)/
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)/2.4
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE_OLD) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) $(@D)/2.5
	$(PY-ORDEREDDICT_UNZIP) $(DL_DIR)/$(PY-ORDEREDDICT_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(@D)/2.6
	(cd $(@D)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(HOST_STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(HOST_STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

py-ordereddict-stage: $(PY-ORDEREDDICT_BUILD_DIR)/.staged

py-ordereddict-host-stage: $(PY-ORDEREDDICT_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-ordereddict
#
$(PY24-ORDEREDDICT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py24-ordereddict" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ORDEREDDICT_PRIORITY)" >>$@
	@echo "Section: $(PY-ORDEREDDICT_SECTION)" >>$@
	@echo "Version: $(PY-ORDEREDDICT_VERSION_OLD)-$(PY-ORDEREDDICT_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ORDEREDDICT_MAINTAINER)" >>$@
	@echo "Source: $(PY-ORDEREDDICT_SITE)/$(PY-ORDEREDDICT_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ORDEREDDICT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-ORDEREDDICT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ORDEREDDICT_CONFLICTS)" >>$@

$(PY25-ORDEREDDICT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-ordereddict" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ORDEREDDICT_PRIORITY)" >>$@
	@echo "Section: $(PY-ORDEREDDICT_SECTION)" >>$@
	@echo "Version: $(PY-ORDEREDDICT_VERSION_OLD)-$(PY-ORDEREDDICT_IPK_VERSION_OLD)" >>$@
	@echo "Maintainer: $(PY-ORDEREDDICT_MAINTAINER)" >>$@
	@echo "Source: $(PY-ORDEREDDICT_SITE)/$(PY-ORDEREDDICT_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-ORDEREDDICT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ORDEREDDICT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ORDEREDDICT_CONFLICTS)" >>$@

$(PY26-ORDEREDDICT_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-ordereddict" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ORDEREDDICT_PRIORITY)" >>$@
	@echo "Section: $(PY-ORDEREDDICT_SECTION)" >>$@
	@echo "Version: $(PY-ORDEREDDICT_VERSION)-$(PY-ORDEREDDICT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ORDEREDDICT_MAINTAINER)" >>$@
	@echo "Source: $(PY-ORDEREDDICT_SITE)/$(PY-ORDEREDDICT_SOURCE)" >>$@
	@echo "Description: $(PY-ORDEREDDICT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-ORDEREDDICT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ORDEREDDICT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/etc/py-ordereddict/...
# Documentation files should be installed in $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/doc/py-ordereddict/...
# Daemon startup scripts should be installed in $(PY-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-ordereddict
#
# You may need to patch your application to make it use these locations.
#
$(PY24-ORDEREDDICT_IPK): $(PY-ORDEREDDICT_BUILD_DIR)/.built
	$(MAKE) py-ordereddict-stage
	rm -rf $(PY24-ORDEREDDICT_IPK_DIR) $(BUILD_DIR)/py-ordereddict_*_$(TARGET_ARCH).ipk
	(cd $(PY-ORDEREDDICT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-ORDEREDDICT_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY24-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY24-ORDEREDDICT_IPK_DIR)/CONTROL/control
	echo $(PY-ORDEREDDICT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-ORDEREDDICT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-ORDEREDDICT_IPK_DIR)

$(PY25-ORDEREDDICT_IPK): $(PY-ORDEREDDICT_BUILD_DIR)/.built
	$(MAKE) py-ordereddict-stage
	rm -rf $(PY25-ORDEREDDICT_IPK_DIR) $(BUILD_DIR)/py25-ordereddict_*_$(TARGET_ARCH).ipk
	(cd $(PY-ORDEREDDICT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-ORDEREDDICT_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY25-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY25-ORDEREDDICT_IPK_DIR)/CONTROL/control
	echo $(PY-ORDEREDDICT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ORDEREDDICT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ORDEREDDICT_IPK_DIR)

$(PY26-ORDEREDDICT_IPK): $(PY-ORDEREDDICT_BUILD_DIR)/.built
	$(MAKE) py-ordereddict-stage
	rm -rf $(PY26-ORDEREDDICT_IPK_DIR) $(BUILD_DIR)/py26-ordereddict_*_$(TARGET_ARCH).ipk
	(cd $(PY-ORDEREDDICT_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-ORDEREDDICT_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-ORDEREDDICT_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-ORDEREDDICT_IPK_DIR)/CONTROL/control
	echo $(PY-ORDEREDDICT_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-ORDEREDDICT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-ORDEREDDICT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-ordereddict-ipk: $(PY24-ORDEREDDICT_IPK) $(PY25-ORDEREDDICT_IPK) $(PY26-ORDEREDDICT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-ordereddict-clean:
	-$(MAKE) -C $(PY-ORDEREDDICT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-ordereddict-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) \
	$(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR) $(HOST_BUILD_DIR)/$(PY-ORDEREDDICT_DIR_OLD) \
	$(PY-ORDEREDDICT_HOST_BUILD_DIR) $(PY-ORDEREDDICT_BUILD_DIR) \
	$(PY24-ORDEREDDICT_IPK_DIR) $(PY24-ORDEREDDICT_IPK) \
	$(PY25-ORDEREDDICT_IPK_DIR) $(PY25-ORDEREDDICT_IPK) \
	$(PY26-ORDEREDDICT_IPK_DIR) $(PY26-ORDEREDDICT_IPK) \

#
# Some sanity check for the package.
#
py-ordereddict-check: $(PY24-ORDEREDDICT_IPK) $(PY25-ORDEREDDICT_IPK) $(PY26-ORDEREDDICT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
