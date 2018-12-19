###########################################################
#
# py-geoip
#
###########################################################

#
# PY-GEOIP_VERSION, PY-GEOIP_SITE and PY-GEOIP_SOURCE define
# the upstream location of the source code for the package.
# PY-GEOIP_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GEOIP_UNZIP is the command used to unzip the source.
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
PY-GEOIP_VERSION=1.3.2
PY-GEOIP_SITE=https://pypi.python.org/packages/f2/7b/a463b7c3df8ef4b9c92906da29ddc9e464d4045f00c475ad31cdb9a97aae
PY-GEOIP_SOURCE=GeoIP-$(PY-GEOIP_VERSION).tar.gz
PY-GEOIP_DIR=GeoIP-$(PY-GEOIP_VERSION)
PY-GEOIP_UNZIP=zcat
PY-GEOIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GEOIP_DESCRIPTION=MaxMind GeoIP Legacy Database - Python API.
PY-GEOIP_SECTION=lib
PY-GEOIP_PRIORITY=optional
PY25-GEOIP_DEPENDS=python25, geoip
PY26-GEOIP_DEPENDS=python26, geoip
PY27-GEOIP_DEPENDS=python27, geoip
PY3-GEOIP_DEPENDS=python3, geoip
PY-GEOIP_CONFLICTS=

#
# PY-GEOIP_IPK_VERSION should be incremented when the ipk changes.
#
PY-GEOIP_IPK_VERSION=2

#
# PY-GEOIP_CONFFILES should be a list of user-editable files
#PY-GEOIP_CONFFILES=$(TARGET_PREFIX)/etc/py-geoip.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-geoip

#
# PY-GEOIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-GEOIP_PATCHES=$(PY-GEOIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GEOIP_CPPFLAGS=
PY-GEOIP_LDFLAGS=

#
# PY-GEOIP_BUILD_DIR is the directory in which the build is done.
# PY-GEOIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GEOIP_IPK_DIR is the directory in which the ipk is built.
# PY-GEOIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GEOIP_BUILD_DIR=$(BUILD_DIR)/py-geoip
PY-GEOIP_SOURCE_DIR=$(SOURCE_DIR)/py-geoip

PY25-GEOIP_IPK_DIR=$(BUILD_DIR)/py25-geoip-$(PY-GEOIP_VERSION)-ipk
PY25-GEOIP_IPK=$(BUILD_DIR)/py25-geoip_$(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-GEOIP_IPK_DIR=$(BUILD_DIR)/py26-geoip-$(PY-GEOIP_VERSION)-ipk
PY26-GEOIP_IPK=$(BUILD_DIR)/py26-geoip_$(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-GEOIP_IPK_DIR=$(BUILD_DIR)/py27-geoip-$(PY-GEOIP_VERSION)-ipk
PY27-GEOIP_IPK=$(BUILD_DIR)/py27-geoip_$(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-GEOIP_IPK_DIR=$(BUILD_DIR)/py3-geoip-$(PY-GEOIP_VERSION)-ipk
PY3-GEOIP_IPK=$(BUILD_DIR)/py3-geoip_$(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)_$(TARGET_ARCH).ipk



.PHONY: py-geoip-source py-geoip-unpack py-geoip py-geoip-stage py-geoip-ipk py-geoip-clean py-geoip-dirclean py-geoip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GEOIP_SOURCE):
	$(WGET) -P $(@D) $(PY-GEOIP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-geoip-source: $(DL_DIR)/$(PY-GEOIP_SOURCE) $(PY-GEOIP_PATCHES)

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
$(PY-GEOIP_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GEOIP_SOURCE) $(PY-GEOIP_PATCHES) make/py-geoip.mk
	$(MAKE) py-setuptools-host-stage geoip-stage
	rm -rf $(BUILD_DIR)/$(PY-GEOIP_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(PY-GEOIP_UNZIP) $(DL_DIR)/$(PY-GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GEOIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-GEOIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GEOIP_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.6
	$(PY-GEOIP_UNZIP) $(DL_DIR)/$(PY-GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GEOIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-GEOIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GEOIP_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.7
	$(PY-GEOIP_UNZIP) $(DL_DIR)/$(PY-GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GEOIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-GEOIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GEOIP_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	# 3
	$(PY-GEOIP_UNZIP) $(DL_DIR)/$(PY-GEOIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GEOIP_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-GEOIP_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GEOIP_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-geoip-unpack: $(PY-GEOIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GEOIP_BUILD_DIR)/.built: $(PY-GEOIP_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-geoip: $(PY-GEOIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GEOIP_BUILD_DIR)/.staged: $(PY-GEOIP_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.5; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

py-geoip-stage: $(PY-GEOIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-geoip
#
$(PY25-GEOIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GEOIP_PRIORITY)" >>$@
	@echo "Section: $(PY-GEOIP_SECTION)" >>$@
	@echo "Version: $(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-GEOIP_SITE)/$(PY-GEOIP_SOURCE)" >>$@
	@echo "Description: $(PY-GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-GEOIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GEOIP_CONFLICTS)" >>$@

$(PY26-GEOIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GEOIP_PRIORITY)" >>$@
	@echo "Section: $(PY-GEOIP_SECTION)" >>$@
	@echo "Version: $(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-GEOIP_SITE)/$(PY-GEOIP_SOURCE)" >>$@
	@echo "Description: $(PY-GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-GEOIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GEOIP_CONFLICTS)" >>$@

$(PY27-GEOIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GEOIP_PRIORITY)" >>$@
	@echo "Section: $(PY-GEOIP_SECTION)" >>$@
	@echo "Version: $(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-GEOIP_SITE)/$(PY-GEOIP_SOURCE)" >>$@
	@echo "Description: $(PY-GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-GEOIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GEOIP_CONFLICTS)" >>$@

$(PY3-GEOIP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-geoip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GEOIP_PRIORITY)" >>$@
	@echo "Section: $(PY-GEOIP_SECTION)" >>$@
	@echo "Version: $(PY-GEOIP_VERSION)-$(PY-GEOIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GEOIP_MAINTAINER)" >>$@
	@echo "Source: $(PY-GEOIP_SITE)/$(PY-GEOIP_SOURCE)" >>$@
	@echo "Description: $(PY-GEOIP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-GEOIP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GEOIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/py-geoip/...
# Documentation files should be installed in $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/doc/py-geoip/...
# Daemon startup scripts should be installed in $(PY-GEOIP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-geoip
#
# You may need to patch your application to make it use these locations.
#
$(PY25-GEOIP_IPK) $(PY26-GEOIP_IPK) $(PY27-GEOIP_IPK) $(PY3-GEOIP_IPK): $(PY-GEOIP_BUILD_DIR)/.built
	# 2.5
	rm -rf $(PY25-GEOIP_IPK_DIR) $(BUILD_DIR)/py25-geoip_*_$(TARGET_ARCH).ipk
	(cd $(PY-GEOIP_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY26-GEOIP_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY26-GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages/*.so
	$(MAKE) $(PY25-GEOIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-GEOIP_IPK_DIR)
	# 2.6
	rm -rf $(PY26-GEOIP_IPK_DIR) $(BUILD_DIR)/py26-geoip_*_$(TARGET_ARCH).ipk
	(cd $(PY-GEOIP_BUILD_DIR)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-GEOIP_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY26-GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/*.so
	$(MAKE) $(PY26-GEOIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-GEOIP_IPK_DIR)
	# 2.7
	rm -rf $(PY27-GEOIP_IPK_DIR) $(BUILD_DIR)/py27-geoip_*_$(TARGET_ARCH).ipk
	(cd $(PY-GEOIP_BUILD_DIR)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-GEOIP_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY27-GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/*.so
	$(MAKE) $(PY27-GEOIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-GEOIP_IPK_DIR)
	# 3
	rm -rf $(PY3-GEOIP_IPK_DIR) $(BUILD_DIR)/py3-geoip_*_$(TARGET_ARCH).ipk
	(cd $(PY-GEOIP_BUILD_DIR)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-GEOIP_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY3-GEOIP_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/*.so
	$(MAKE) $(PY3-GEOIP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-GEOIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-geoip-ipk: $(PY25-GEOIP_IPK) $(PY26-GEOIP_IPK) $(PY27-GEOIP_IPK) $(PY3-GEOIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-geoip-clean:
	-$(MAKE) -C $(PY-GEOIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-geoip-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GEOIP_DIR) $(PY-GEOIP_BUILD_DIR)
	rm -rf $(PY25-GEOIP_IPK_DIR) $(PY25-GEOIP_IPK)
	rm -rf $(PY26-GEOIP_IPK_DIR) $(PY26-GEOIP_IPK)
	rm -rf $(PY27-GEOIP_IPK_DIR) $(PY27-GEOIP_IPK)
	rm -rf $(PY3-GEOIP_IPK_DIR) $(PY3-GEOIP_IPK)

#
# Some sanity check for the package.
#
py-geoip-check: $(PY25-GEOIP_IPK) $(PY26-GEOIP_IPK) $(PY27-GEOIP_IPK) $(PY3-GEOIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
