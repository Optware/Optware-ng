###########################################################
#
# py-urllib3
#
###########################################################

#
# PY-URLLIB3_VERSION, PY-URLLIB3_SITE and PY-URLLIB3_SOURCE define
# the upstream location of the source code for the package.
# PY-URLLIB3_DIR is the directory which is created when the source
# archive is unpacked.
# PY-URLLIB3_UNZIP is the command used to unzip the source.
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
PY-URLLIB3_VERSION=1.14
PY-URLLIB3_SITE=https://pypi.python.org/packages/source/u/urllib3
PY-URLLIB3_SOURCE=urllib3-$(PY-URLLIB3_VERSION).tar.gz
PY-URLLIB3_DIR=urllib3-$(PY-URLLIB3_VERSION)
PY-URLLIB3_UNZIP=zcat
PY-URLLIB3_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-URLLIB3_DESCRIPTION=HTTP library with thread-safe connection pooling, file post, and more.
PY-URLLIB3_SECTION=misc
PY-URLLIB3_PRIORITY=optional
PY26-URLLIB3_DEPENDS=python26, py26-six
PY27-URLLIB3_DEPENDS=python27, py27-six
PY3-URLLIB3_DEPENDS=python3, py3-six
PY-URLLIB3_CONFLICTS=

#
# PY-URLLIB3_IPK_VERSION should be incremented when the ipk changes.
#
PY-URLLIB3_IPK_VERSION=4

#
# PY-URLLIB3_CONFFILES should be a list of user-editable files
#PY-URLLIB3_CONFFILES=$(TARGET_PREFIX)/etc/py-urllib3.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-urllib3

#
# PY-URLLIB3_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-URLLIB3_PATCHES=$(PY-URLLIB3_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-URLLIB3_CPPFLAGS=
PY-URLLIB3_LDFLAGS=

#
# PY-URLLIB3_BUILD_DIR is the directory in which the build is done.
# PY-URLLIB3_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-URLLIB3_IPK_DIR is the directory in which the ipk is built.
# PY-URLLIB3_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-URLLIB3_BUILD_DIR=$(BUILD_DIR)/py-urllib3
PY-URLLIB3_SOURCE_DIR=$(SOURCE_DIR)/py-urllib3

PY26-URLLIB3_IPK_DIR=$(BUILD_DIR)/py26-urllib3-$(PY-URLLIB3_VERSION)-ipk
PY26-URLLIB3_IPK=$(BUILD_DIR)/py26-urllib3_$(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-URLLIB3_IPK_DIR=$(BUILD_DIR)/py27-urllib3-$(PY-URLLIB3_VERSION)-ipk
PY27-URLLIB3_IPK=$(BUILD_DIR)/py27-urllib3_$(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-URLLIB3_IPK_DIR=$(BUILD_DIR)/py3-urllib3-$(PY-URLLIB3_VERSION)-ipk
PY3-URLLIB3_IPK=$(BUILD_DIR)/py3-urllib3_$(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-urllib3-source py-urllib3-unpack py-urllib3 py-urllib3-stage py-urllib3-ipk py-urllib3-clean py-urllib3-dirclean py-urllib3-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-URLLIB3_SOURCE):
	$(WGET) -P $(@D) $(PY-URLLIB3_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-urllib3-source: $(DL_DIR)/$(PY-URLLIB3_SOURCE) $(PY-URLLIB3_PATCHES)

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
$(PY-URLLIB3_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-URLLIB3_SOURCE) $(PY-URLLIB3_PATCHES) make/py-urllib3.mk
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(@D)
	mkdir -p $(PY-URLLIB3_BUILD_DIR)
	$(PY-URLLIB3_UNZIP) $(DL_DIR)/$(PY-URLLIB3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URLLIB3_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-URLLIB3_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-URLLIB3_UNZIP) $(DL_DIR)/$(PY-URLLIB3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URLLIB3_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-URLLIB3_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-URLLIB3_UNZIP) $(DL_DIR)/$(PY-URLLIB3_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URLLIB3_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-URLLIB3_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-urllib3-unpack: $(PY-URLLIB3_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-URLLIB3_BUILD_DIR)/.built: $(PY-URLLIB3_BUILD_DIR)/.configured
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
py-urllib3: $(PY-URLLIB3_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-URLLIB3_BUILD_DIR)/.staged: $(PY-URLLIB3_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-URLLIB3_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-urllib3-stage: $(PY-URLLIB3_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-urllib3
#
$(PY26-URLLIB3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-urllib3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URLLIB3_PRIORITY)" >>$@
	@echo "Section: $(PY-URLLIB3_SECTION)" >>$@
	@echo "Version: $(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URLLIB3_MAINTAINER)" >>$@
	@echo "Source: $(PY-URLLIB3_SITE)/$(PY-URLLIB3_SOURCE)" >>$@
	@echo "Description: $(PY-URLLIB3_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-URLLIB3_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URLLIB3_CONFLICTS)" >>$@

$(PY27-URLLIB3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-urllib3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URLLIB3_PRIORITY)" >>$@
	@echo "Section: $(PY-URLLIB3_SECTION)" >>$@
	@echo "Version: $(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URLLIB3_MAINTAINER)" >>$@
	@echo "Source: $(PY-URLLIB3_SITE)/$(PY-URLLIB3_SOURCE)" >>$@
	@echo "Description: $(PY-URLLIB3_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-URLLIB3_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URLLIB3_CONFLICTS)" >>$@

$(PY3-URLLIB3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-urllib3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URLLIB3_PRIORITY)" >>$@
	@echo "Section: $(PY-URLLIB3_SECTION)" >>$@
	@echo "Version: $(PY-URLLIB3_VERSION)-$(PY-URLLIB3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URLLIB3_MAINTAINER)" >>$@
	@echo "Source: $(PY-URLLIB3_SITE)/$(PY-URLLIB3_SOURCE)" >>$@
	@echo "Description: $(PY-URLLIB3_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-URLLIB3_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URLLIB3_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/etc/py-urllib3/...
# Documentation files should be installed in $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/doc/py-urllib3/...
# Daemon startup scripts should be installed in $(PY-URLLIB3_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-urllib3
#
# You may need to patch your application to make it use these locations.
#
$(PY26-URLLIB3_IPK): $(PY-URLLIB3_BUILD_DIR)/.built
	rm -rf $(PY26-URLLIB3_IPK_DIR) $(BUILD_DIR)/py26-urllib3_*_$(TARGET_ARCH).ipk
	(cd $(PY-URLLIB3_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-URLLIB3_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-URLLIB3_IPK_DIR)/CONTROL/control
	echo $(PY-URLLIB3_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-URLLIB3_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-URLLIB3_IPK_DIR)

$(PY27-URLLIB3_IPK): $(PY-URLLIB3_BUILD_DIR)/.built
	rm -rf $(PY27-URLLIB3_IPK_DIR) $(BUILD_DIR)/py27-urllib3_*_$(TARGET_ARCH).ipk
	(cd $(PY-URLLIB3_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-URLLIB3_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-URLLIB3_IPK_DIR)/CONTROL/control
	echo $(PY-URLLIB3_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-URLLIB3_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-URLLIB3_IPK_DIR)

$(PY3-URLLIB3_IPK): $(PY-URLLIB3_BUILD_DIR)/.built
	rm -rf $(PY3-URLLIB3_IPK_DIR) $(BUILD_DIR)/py3-urllib3_*_$(TARGET_ARCH).ipk
	(cd $(PY-URLLIB3_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-URLLIB3_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-URLLIB3_IPK_DIR)/CONTROL/control
	echo $(PY-URLLIB3_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-URLLIB3_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-URLLIB3_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-urllib3-ipk: $(PY26-URLLIB3_IPK) $(PY27-URLLIB3_IPK) $(PY3-URLLIB3_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-urllib3-clean:
	-$(MAKE) -C $(PY-URLLIB3_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-urllib3-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-URLLIB3_DIR) $(PY-URLLIB3_BUILD_DIR) \
	$(PY26-URLLIB3_IPK_DIR) $(PY26-URLLIB3_IPK) \
	$(PY27-URLLIB3_IPK_DIR) $(PY27-URLLIB3_IPK) \
	$(PY3-URLLIB3_IPK_DIR) $(PY3-URLLIB3_IPK) \

#
# Some sanity check for the package.
#
py-urllib3-check: $(PY26-URLLIB3_IPK) $(PY27-URLLIB3_IPK) $(PY3-URLLIB3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
