###########################################################
#
# py-dispatcher
#
###########################################################

#
# PY-DISPATCHER_VERSION, PY-DISPATCHER_SITE and PY-DISPATCHER_SOURCE define
# the upstream location of the source code for the package.
# PY-DISPATCHER_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DISPATCHER_UNZIP is the command used to unzip the source.
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
PY-DISPATCHER_VERSION=2.0.5
PY-DISPATCHER_SITE=https://pypi.python.org/packages/source/P/PyDispatcher
PY-DISPATCHER_SOURCE=PyDispatcher-$(PY-DISPATCHER_VERSION).tar.gz
PY-DISPATCHER_DIR=PyDispatcher-$(PY-DISPATCHER_VERSION)
PY-DISPATCHER_UNZIP=zcat
PY-DISPATCHER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DISPATCHER_DESCRIPTION=Multi-producer-multi-consumer signal dispatching mechanism.
PY-DISPATCHER_SECTION=misc
PY-DISPATCHER_PRIORITY=optional
PY26-DISPATCHER_DEPENDS=python26
PY27-DISPATCHER_DEPENDS=python27
PY3-DISPATCHER_DEPENDS=python3
PY-DISPATCHER_CONFLICTS=

#
# PY-DISPATCHER_IPK_VERSION should be incremented when the ipk changes.
#
PY-DISPATCHER_IPK_VERSION=4

#
# PY-DISPATCHER_CONFFILES should be a list of user-editable files
#PY-DISPATCHER_CONFFILES=$(TARGET_PREFIX)/etc/py-dispatcher.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-dispatcher

#
# PY-DISPATCHER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DISPATCHER_PATCHES=$(PY-DISPATCHER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DISPATCHER_CPPFLAGS=
PY-DISPATCHER_LDFLAGS=

#
# PY-DISPATCHER_BUILD_DIR is the directory in which the build is done.
# PY-DISPATCHER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DISPATCHER_IPK_DIR is the directory in which the ipk is built.
# PY-DISPATCHER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DISPATCHER_BUILD_DIR=$(BUILD_DIR)/py-dispatcher
PY-DISPATCHER_SOURCE_DIR=$(SOURCE_DIR)/py-dispatcher

PY26-DISPATCHER_IPK_DIR=$(BUILD_DIR)/py26-dispatcher-$(PY-DISPATCHER_VERSION)-ipk
PY26-DISPATCHER_IPK=$(BUILD_DIR)/py26-dispatcher_$(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-DISPATCHER_IPK_DIR=$(BUILD_DIR)/py27-dispatcher-$(PY-DISPATCHER_VERSION)-ipk
PY27-DISPATCHER_IPK=$(BUILD_DIR)/py27-dispatcher_$(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-DISPATCHER_IPK_DIR=$(BUILD_DIR)/py3-dispatcher-$(PY-DISPATCHER_VERSION)-ipk
PY3-DISPATCHER_IPK=$(BUILD_DIR)/py3-dispatcher_$(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-dispatcher-source py-dispatcher-unpack py-dispatcher py-dispatcher-stage py-dispatcher-ipk py-dispatcher-clean py-dispatcher-dirclean py-dispatcher-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DISPATCHER_SOURCE):
	$(WGET) -P $(@D) $(PY-DISPATCHER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-dispatcher-source: $(DL_DIR)/$(PY-DISPATCHER_SOURCE) $(PY-DISPATCHER_PATCHES)

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
$(PY-DISPATCHER_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DISPATCHER_SOURCE) $(PY-DISPATCHER_PATCHES) make/py-dispatcher.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(@D)
	mkdir -p $(PY-DISPATCHER_BUILD_DIR)
	$(PY-DISPATCHER_UNZIP) $(DL_DIR)/$(PY-DISPATCHER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DISPATCHER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-DISPATCHER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-DISPATCHER_UNZIP) $(DL_DIR)/$(PY-DISPATCHER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DISPATCHER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-DISPATCHER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-DISPATCHER_UNZIP) $(DL_DIR)/$(PY-DISPATCHER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DISPATCHER_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-DISPATCHER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-dispatcher-unpack: $(PY-DISPATCHER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DISPATCHER_BUILD_DIR)/.built: $(PY-DISPATCHER_BUILD_DIR)/.configured
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
py-dispatcher: $(PY-DISPATCHER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-DISPATCHER_BUILD_DIR)/.staged: $(PY-DISPATCHER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-DISPATCHER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-dispatcher-stage: $(PY-DISPATCHER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-dispatcher
#
$(PY26-DISPATCHER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-dispatcher" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DISPATCHER_PRIORITY)" >>$@
	@echo "Section: $(PY-DISPATCHER_SECTION)" >>$@
	@echo "Version: $(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DISPATCHER_MAINTAINER)" >>$@
	@echo "Source: $(PY-DISPATCHER_SITE)/$(PY-DISPATCHER_SOURCE)" >>$@
	@echo "Description: $(PY-DISPATCHER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-DISPATCHER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DISPATCHER_CONFLICTS)" >>$@

$(PY27-DISPATCHER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-dispatcher" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DISPATCHER_PRIORITY)" >>$@
	@echo "Section: $(PY-DISPATCHER_SECTION)" >>$@
	@echo "Version: $(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DISPATCHER_MAINTAINER)" >>$@
	@echo "Source: $(PY-DISPATCHER_SITE)/$(PY-DISPATCHER_SOURCE)" >>$@
	@echo "Description: $(PY-DISPATCHER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-DISPATCHER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DISPATCHER_CONFLICTS)" >>$@

$(PY3-DISPATCHER_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-dispatcher" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DISPATCHER_PRIORITY)" >>$@
	@echo "Section: $(PY-DISPATCHER_SECTION)" >>$@
	@echo "Version: $(PY-DISPATCHER_VERSION)-$(PY-DISPATCHER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DISPATCHER_MAINTAINER)" >>$@
	@echo "Source: $(PY-DISPATCHER_SITE)/$(PY-DISPATCHER_SOURCE)" >>$@
	@echo "Description: $(PY-DISPATCHER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-DISPATCHER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DISPATCHER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/etc/py-dispatcher/...
# Documentation files should be installed in $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/doc/py-dispatcher/...
# Daemon startup scripts should be installed in $(PY-DISPATCHER_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-dispatcher
#
# You may need to patch your application to make it use these locations.
#
$(PY26-DISPATCHER_IPK): $(PY-DISPATCHER_BUILD_DIR)/.built
	rm -rf $(PY26-DISPATCHER_IPK_DIR) $(BUILD_DIR)/py26-dispatcher_*_$(TARGET_ARCH).ipk
	(cd $(PY-DISPATCHER_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-DISPATCHER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-DISPATCHER_IPK_DIR)/CONTROL/control
	echo $(PY-DISPATCHER_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-DISPATCHER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-DISPATCHER_IPK_DIR)

$(PY27-DISPATCHER_IPK): $(PY-DISPATCHER_BUILD_DIR)/.built
	rm -rf $(PY27-DISPATCHER_IPK_DIR) $(BUILD_DIR)/py27-dispatcher_*_$(TARGET_ARCH).ipk
	(cd $(PY-DISPATCHER_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-DISPATCHER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-DISPATCHER_IPK_DIR)/CONTROL/control
	echo $(PY-DISPATCHER_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-DISPATCHER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-DISPATCHER_IPK_DIR)

$(PY3-DISPATCHER_IPK): $(PY-DISPATCHER_BUILD_DIR)/.built
	rm -rf $(PY3-DISPATCHER_IPK_DIR) $(BUILD_DIR)/py3-dispatcher_*_$(TARGET_ARCH).ipk
	(cd $(PY-DISPATCHER_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-DISPATCHER_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-DISPATCHER_IPK_DIR)/CONTROL/control
	echo $(PY-DISPATCHER_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-DISPATCHER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-DISPATCHER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-dispatcher-ipk: $(PY26-DISPATCHER_IPK) $(PY27-DISPATCHER_IPK) $(PY3-DISPATCHER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-dispatcher-clean:
	-$(MAKE) -C $(PY-DISPATCHER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-dispatcher-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DISPATCHER_DIR) $(PY-DISPATCHER_BUILD_DIR) \
	$(PY26-DISPATCHER_IPK_DIR) $(PY26-DISPATCHER_IPK) \
	$(PY27-DISPATCHER_IPK_DIR) $(PY27-DISPATCHER_IPK) \
	$(PY3-DISPATCHER_IPK_DIR) $(PY3-DISPATCHER_IPK) \

#
# Some sanity check for the package.
#
py-dispatcher-check: $(PY26-DISPATCHER_IPK) $(PY27-DISPATCHER_IPK) $(PY3-DISPATCHER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
