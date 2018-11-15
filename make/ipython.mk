###########################################################
#
# ipython
#
###########################################################

#
# IPYTHON_VERSION, IPYTHON_SITE and IPYTHON_SOURCE define
# the upstream location of the source code for the package.
# IPYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# IPYTHON_UNZIP is the command used to unzip the source.
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
IPYTHON_SITE=https://pypi.python.org/packages/source/i/ipython
IPYTHON_VERSION=3.1.0
IPYTHON_VERSION_OLD=0.10.2
IPYTHON_SOURCE=ipython-$(IPYTHON_VERSION).tar.gz
IPYTHON_SOURCE_OLD=ipython-$(IPYTHON_VERSION_OLD).tar.gz
IPYTHON_DIR=ipython-$(IPYTHON_VERSION)
IPYTHON_DIR_OLD=ipython-$(IPYTHON_VERSION_OLD)
IPYTHON_UNZIP=zcat
IPYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPYTHON_DESCRIPTION=An enhanced interactive Python shell
IPYTHON_SECTION=misc
IPYTHON_PRIORITY=optional
IPYTHON_PY25_DEPENDS=python25, py25-setuptools
IPYTHON_PY26_DEPENDS=python26, py26-setuptools
IPYTHON_PY26_DEPENDS=python27, py27-setuptools
IPYTHON_PY3_DEPENDS=python3, py3-setuptools
IPYTHON_SUGGESTS=ipython-common
ifneq ($(IPYTHON_VERSION), $(IPYTHON_VERSION_OLD))
IPYTHON_SUGGESTS_OLD=ipython-common-old
else
IPYTHON_SUGGESTS_OLD=ipython-common
endif
IPYTHON_CONFLICTS=

#
# IPYTHON_IPK_VERSION should be incremented when the ipk changes.
#
IPYTHON_IPK_VERSION=4

#
# IPYTHON_CONFFILES should be a list of user-editable files
#IPYTHON_CONFFILES=$(TARGET_PREFIX)/etc/ipython.conf $(TARGET_PREFIX)/etc/init.d/SXXipython

#
# IPYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IPYTHON_PATCHES=$(IPYTHON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPYTHON_CPPFLAGS=
IPYTHON_LDFLAGS=

#
# IPYTHON_BUILD_DIR is the directory in which the build is done.
# IPYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPYTHON_IPK_DIR is the directory in which the ipk is built.
# IPYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPYTHON_BUILD_DIR=$(BUILD_DIR)/ipython
IPYTHON_SOURCE_DIR=$(SOURCE_DIR)/ipython

IPYTHON-COMMON_IPK_DIR=$(BUILD_DIR)/ipython-common-$(IPYTHON_VERSION)-ipk
IPYTHON-COMMON_IPK=$(BUILD_DIR)/ipython-common_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(IPYTHON_VERSION), $(IPYTHON_VERSION_OLD))
IPYTHON-COMMON-OLD_IPK_DIR=$(BUILD_DIR)/ipython-common-old-$(IPYTHON_VERSION_OLD)-ipk
IPYTHON-COMMON-OLD_IPK=$(BUILD_DIR)/ipython-common-old_$(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

IPYTHON_PY25_IPK_DIR=$(BUILD_DIR)/py25-ipython-$(IPYTHON_VERSION_OLD)-ipk
IPYTHON_PY25_IPK=$(BUILD_DIR)/py25-ipython_$(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

IPYTHON_PY26_IPK_DIR=$(BUILD_DIR)/py26-ipython-$(IPYTHON_VERSION_OLD)-ipk
IPYTHON_PY26_IPK=$(BUILD_DIR)/py26-ipython_$(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

IPYTHON_PY27_IPK_DIR=$(BUILD_DIR)/py27-ipython-$(IPYTHON_VERSION)-ipk
IPYTHON_PY27_IPK=$(BUILD_DIR)/py27-ipython_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

IPYTHON_PY3_IPK_DIR=$(BUILD_DIR)/py3-ipython-$(IPYTHON_VERSION)-ipk
IPYTHON_PY3_IPK=$(BUILD_DIR)/py3-ipython_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipython-source ipython-unpack ipython ipython-stage ipython-ipk ipython-clean ipython-dirclean ipython-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPYTHON_SOURCE):
	$(WGET) -P $(@D) $(IPYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq ($(IPYTHON_VERSION), $(IPYTHON_VERSION_OLD))
$(DL_DIR)/$(IPYTHON_SOURCE_OLD):
	$(WGET) -P $(@D) $(IPYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipython-source: $(DL_DIR)/$(IPYTHON_SOURCE) $(DL_DIR)/$(IPYTHON_SOURCE_OLD) $(IPYTHON_PATCHES)

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
$(IPYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(IPYTHON_SOURCE) $(DL_DIR)/$(IPYTHON_SOURCE_OLD) \
								$(IPYTHON_PATCHES) make/ipython.mk
	$(MAKE) py-setuptools-host-stage
	rm -rf $(IPYTHON_BUILD_DIR)
	mkdir -p $(IPYTHON_BUILD_DIR)
	# 2.5
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(IPYTHON_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR_OLD) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.5") >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(IPYTHON_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR_OLD) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6") >> setup.cfg \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(IPYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    (echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7") >> setup.cfg \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(IPYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR) $(@D)/3
	(cd $(@D)/3; \
	    (echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)") >> setup.cfg \
	)
#	see http://stackoverflow.com/questions/16771894/python-nameerror-global-name-file-is-not-defined
	sed -i -e 's/__file__/"&"/' $(@D)/2.7/setup.py $(@D)/3/setup.py
	touch $@

ipython-unpack: $(IPYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPYTHON_BUILD_DIR)/.built: $(IPYTHON_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build)
	(cd $(@D)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" build)
	(cd $(@D)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 -c "import setuptools; execfile('setup.py')" build)
	(cd $(@D)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
ipython: $(IPYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(IPYTHON_BUILD_DIR)/.staged: $(IPYTHON_BUILD_DIR)/.built
#	rm -f $(@D)/.staged
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $(@D)/.staged
#
#ipython-stage: $(IPYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipython
#
$(IPYTHON-COMMON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ipython-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION). Common files for $(IPYTHON_VERSION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

ifneq ($(IPYTHON_VERSION), $(IPYTHON_VERSION_OLD))
$(IPYTHON-COMMON-OLD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ipython-common-old" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE_OLD)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION). Common files for $(IPYTHON_VERSION_OLD)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@
endif

$(IPYTHON_PY25_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE_OLD)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY25_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS_OLD)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

$(IPYTHON_PY26_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION_OLD)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE_OLD)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY26_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS_OLD)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

$(IPYTHON_PY27_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY27_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

$(IPYTHON_PY3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY3_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/ipython/...
# Documentation files should be installed in $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/doc/ipython/...
# Daemon startup scripts should be installed in $(IPYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ipython
#
# You may need to patch your application to make it use these locations.
#
$(IPYTHON_PY25_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON_PY25_IPK_DIR) $(BUILD_DIR)/py25-ipython_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/2.5; \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
		install --root=$(IPYTHON_PY25_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON_PY25_IPK_DIR)$(TARGET_PREFIX)/share
	for f in $(IPYTHON_PY25_IPK_DIR)$(TARGET_PREFIX)/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(IPYTHON_PY25_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY25_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON_PY25_IPK_DIR)

$(IPYTHON_PY26_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(IPYTHON_PY26_IPK_DIR) $(BUILD_DIR)/py26-ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(BUILD_DIR)/ipython-common_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" \
		install --root=$(IPYTHON_PY26_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON_PY26_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(IPYTHON_PY26_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY26_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON_PY26_IPK_DIR)

$(IPYTHON_PY27_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(IPYTHON_PY27_IPK_DIR) $(BUILD_DIR)/py27-ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(BUILD_DIR)/ipython-common_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 -c "import setuptools; execfile('setup.py')" \
		install --root=$(IPYTHON_PY27_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON_PY27_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(IPYTHON_PY27_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY27_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON_PY27_IPK_DIR)

$(IPYTHON_PY3_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(IPYTHON_PY3_IPK_DIR) $(BUILD_DIR)/py3-ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(BUILD_DIR)/ipython-common_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py \
		install --root=$(IPYTHON_PY3_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON_PY3_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(IPYTHON_PY3_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY3_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON_PY3_IPK_DIR)

$(IPYTHON-COMMON_IPK): $(IPYTHON_BUILD_DIR)/.built
	(cd $(IPYTHON_BUILD_DIR)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py \
		install --root=$(IPYTHON-COMMON_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON-COMMON_IPK_DIR)$(TARGET_PREFIX)/bin $(IPYTHON-COMMON_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(IPYTHON-COMMON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON-COMMON_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON-COMMON_IPK_DIR)

ifneq ($(IPYTHON_VERSION), $(IPYTHON_VERSION_OLD))
$(IPYTHON-COMMON-OLD_IPK): $(IPYTHON_BUILD_DIR)/.built
	(cd $(IPYTHON_BUILD_DIR)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py \
		install --root=$(IPYTHON-COMMON-OLD_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(IPYTHON-COMMON-OLD_IPK_DIR)$(TARGET_PREFIX)/bin $(IPYTHON-COMMON-OLD_IPK_DIR)$(TARGET_PREFIX)/lib
	$(MAKE) $(IPYTHON-COMMON-OLD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON-COMMON-OLD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IPYTHON-COMMON-OLD_IPK_DIR)
endif

#
# This is called from the top level makefile to create the IPK file.
#
ipython-ipk: $(IPYTHON_PY25_IPK) $(IPYTHON_PY26_IPK) \
		$(IPYTHON_PY27_IPK) $(IPYTHON_PY3_IPK) \
		$(IPYTHON-COMMON_IPK) $(IPYTHON-COMMON-OLD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipython-clean:
	-$(MAKE) -C $(IPYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipython-dirclean:
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR) $(IPYTHON_BUILD_DIR)
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(IPYTHON-COMMON_IPK)
	rm -rf $(IPYTHON-COMMON-OLD_IPK_DIR) $(IPYTHON-COMMON-OLD_IPK)
	rm -rf $(IPYTHON_PY25_IPK_DIR) $(IPYTHON_PY25_IPK)
	rm -rf $(IPYTHON_PY26_IPK_DIR) $(IPYTHON_PY26_IPK)
	rm -rf $(IPYTHON_PY27_IPK_DIR) $(IPYTHON_PY27_IPK)
	rm -rf $(IPYTHON_PY3_IPK_DIR) $(IPYTHON_PY3_IPK)

#
# Some sanity check for the package.
#
ipython-check: $(IPYTHON_PY25_IPK) $(IPYTHON_PY26_IPK) \
		$(IPYTHON_PY27_IPK) $(IPYTHON_PY3_IPK) \
		$(IPYTHON-COMMON_IPK) $(IPYTHON-COMMON-OLD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
