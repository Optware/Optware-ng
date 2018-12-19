###########################################################
#
# py-requests
#
###########################################################

#
# PY-REQUESTS_VERSION, PY-REQUESTS_SITE and PY-REQUESTS_SOURCE define
# the upstream location of the source code for the package.
# PY-REQUESTS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-REQUESTS_UNZIP is the command used to unzip the source.
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
PY-REQUESTS_VERSION=2.9.1
PY-REQUESTS_SITE=https://pypi.python.org/packages/source/r/requests
PY-REQUESTS_SOURCE=requests-$(PY-REQUESTS_VERSION).tar.gz
PY-REQUESTS_DIR=requests-$(PY-REQUESTS_VERSION)
PY-REQUESTS_UNZIP=zcat
PY-REQUESTS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-REQUESTS_DESCRIPTION=Apache2 Licensed HTTP library, written in Python, for human beings.
PY-REQUESTS_SECTION=misc
PY-REQUESTS_PRIORITY=optional
PY26-REQUESTS_DEPENDS=python26, py26-urllib3, py26-chardet
PY27-REQUESTS_DEPENDS=python27, py27-urllib3, py27-chardet
PY3-REQUESTS_DEPENDS=python3, py3-urllib3, py3-chardet
PY-REQUESTS_CONFLICTS=

#
# PY-REQUESTS_IPK_VERSION should be incremented when the ipk changes.
#
PY-REQUESTS_IPK_VERSION=4

#
# PY-REQUESTS_CONFFILES should be a list of user-editable files
#PY-REQUESTS_CONFFILES=$(TARGET_PREFIX)/etc/py-requests.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-requests

#
# PY-REQUESTS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-REQUESTS_PATCHES=$(PY-REQUESTS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-REQUESTS_CPPFLAGS=
PY-REQUESTS_LDFLAGS=

#
# PY-REQUESTS_BUILD_DIR is the directory in which the build is done.
# PY-REQUESTS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-REQUESTS_IPK_DIR is the directory in which the ipk is built.
# PY-REQUESTS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-REQUESTS_BUILD_DIR=$(BUILD_DIR)/py-requests
PY-REQUESTS_SOURCE_DIR=$(SOURCE_DIR)/py-requests

PY26-REQUESTS_IPK_DIR=$(BUILD_DIR)/py26-requests-$(PY-REQUESTS_VERSION)-ipk
PY26-REQUESTS_IPK=$(BUILD_DIR)/py26-requests_$(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-REQUESTS_IPK_DIR=$(BUILD_DIR)/py27-requests-$(PY-REQUESTS_VERSION)-ipk
PY27-REQUESTS_IPK=$(BUILD_DIR)/py27-requests_$(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-REQUESTS_IPK_DIR=$(BUILD_DIR)/py3-requests-$(PY-REQUESTS_VERSION)-ipk
PY3-REQUESTS_IPK=$(BUILD_DIR)/py3-requests_$(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-requests-source py-requests-unpack py-requests py-requests-stage py-requests-ipk py-requests-clean py-requests-dirclean py-requests-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-REQUESTS_SOURCE):
	$(WGET) -P $(@D) $(PY-REQUESTS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-requests-source: $(DL_DIR)/$(PY-REQUESTS_SOURCE) $(PY-REQUESTS_PATCHES)

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
$(PY-REQUESTS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-REQUESTS_SOURCE) $(PY-REQUESTS_PATCHES) make/py-requests.mk
	$(MAKE) py-setuptools-host-stage
	rm -rf $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(@D)
	mkdir -p $(PY-REQUESTS_BUILD_DIR)
	$(PY-REQUESTS_UNZIP) $(DL_DIR)/$(PY-REQUESTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-REQUESTS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-REQUESTS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-REQUESTS_UNZIP) $(DL_DIR)/$(PY-REQUESTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-REQUESTS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-REQUESTS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-REQUESTS_UNZIP) $(DL_DIR)/$(PY-REQUESTS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-REQUESTS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-REQUESTS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    echo "[install]"; \
	    echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-requests-unpack: $(PY-REQUESTS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-REQUESTS_BUILD_DIR)/.built: $(PY-REQUESTS_BUILD_DIR)/.configured
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
py-requests: $(PY-REQUESTS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-REQUESTS_BUILD_DIR)/.staged: $(PY-REQUESTS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-REQUESTS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-requests-stage: $(PY-REQUESTS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-requests
#
$(PY26-REQUESTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-requests" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REQUESTS_PRIORITY)" >>$@
	@echo "Section: $(PY-REQUESTS_SECTION)" >>$@
	@echo "Version: $(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REQUESTS_MAINTAINER)" >>$@
	@echo "Source: $(PY-REQUESTS_SITE)/$(PY-REQUESTS_SOURCE)" >>$@
	@echo "Description: $(PY-REQUESTS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-REQUESTS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REQUESTS_CONFLICTS)" >>$@

$(PY27-REQUESTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-requests" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REQUESTS_PRIORITY)" >>$@
	@echo "Section: $(PY-REQUESTS_SECTION)" >>$@
	@echo "Version: $(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REQUESTS_MAINTAINER)" >>$@
	@echo "Source: $(PY-REQUESTS_SITE)/$(PY-REQUESTS_SOURCE)" >>$@
	@echo "Description: $(PY-REQUESTS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-REQUESTS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REQUESTS_CONFLICTS)" >>$@

$(PY3-REQUESTS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-requests" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REQUESTS_PRIORITY)" >>$@
	@echo "Section: $(PY-REQUESTS_SECTION)" >>$@
	@echo "Version: $(PY-REQUESTS_VERSION)-$(PY-REQUESTS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REQUESTS_MAINTAINER)" >>$@
	@echo "Source: $(PY-REQUESTS_SITE)/$(PY-REQUESTS_SOURCE)" >>$@
	@echo "Description: $(PY-REQUESTS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-REQUESTS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REQUESTS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/etc/py-requests/...
# Documentation files should be installed in $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/doc/py-requests/...
# Daemon startup scripts should be installed in $(PY-REQUESTS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-requests
#
# You may need to patch your application to make it use these locations.
#
$(PY26-REQUESTS_IPK): $(PY-REQUESTS_BUILD_DIR)/.built
	rm -rf $(PY26-REQUESTS_IPK_DIR) $(BUILD_DIR)/py26-requests_*_$(TARGET_ARCH).ipk
	(cd $(PY-REQUESTS_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-REQUESTS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY26-REQUESTS_IPK_DIR)/CONTROL/control
	echo $(PY-REQUESTS_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-REQUESTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-REQUESTS_IPK_DIR)

$(PY27-REQUESTS_IPK): $(PY-REQUESTS_BUILD_DIR)/.built
	rm -rf $(PY27-REQUESTS_IPK_DIR) $(BUILD_DIR)/py27-requests_*_$(TARGET_ARCH).ipk
	(cd $(PY-REQUESTS_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-REQUESTS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY27-REQUESTS_IPK_DIR)/CONTROL/control
	echo $(PY-REQUESTS_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-REQUESTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-REQUESTS_IPK_DIR)

$(PY3-REQUESTS_IPK): $(PY-REQUESTS_BUILD_DIR)/.built
	rm -rf $(PY3-REQUESTS_IPK_DIR) $(BUILD_DIR)/py3-requests_*_$(TARGET_ARCH).ipk
	(cd $(PY-REQUESTS_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-REQUESTS_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(MAKE) $(PY3-REQUESTS_IPK_DIR)/CONTROL/control
	echo $(PY-REQUESTS_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-REQUESTS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-REQUESTS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-requests-ipk: $(PY26-REQUESTS_IPK) $(PY27-REQUESTS_IPK) $(PY3-REQUESTS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-requests-clean:
	-$(MAKE) -C $(PY-REQUESTS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-requests-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-REQUESTS_DIR) $(PY-REQUESTS_BUILD_DIR) \
	$(PY26-REQUESTS_IPK_DIR) $(PY26-REQUESTS_IPK) \
	$(PY27-REQUESTS_IPK_DIR) $(PY27-REQUESTS_IPK) \
	$(PY3-REQUESTS_IPK_DIR) $(PY3-REQUESTS_IPK) \

#
# Some sanity check for the package.
#
py-requests-check: $(PY26-REQUESTS_IPK) $(PY27-REQUESTS_IPK) $(PY3-REQUESTS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
