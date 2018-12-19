###########################################################
#
# py-cffi
#
###########################################################

#
# PY-CFFI_VERSION, PY-CFFI_SITE and PY-CFFI_SOURCE define
# the upstream location of the source code for the package.
# PY-CFFI_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CFFI_UNZIP is the command used to unzip the source.
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
PY-CFFI_SITE=https://pypi.python.org/packages/83/3c/00b553fd05ae32f27b3637f705c413c4ce71290aa9b4c4764df694e906d9
PY-CFFI_VERSION=1.7.0
PY-CFFI_SOURCE=cffi-$(PY-CFFI_VERSION).tar.gz
PY-CFFI_DIR=cffi-$(PY-CFFI_VERSION)
PY-CFFI_UNZIP=zcat
PY-CFFI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CFFI_DESCRIPTION=Foreign Function Interface for Python calling C code.
PY-CFFI_SECTION=misc
PY-CFFI_PRIORITY=optional
PY26-CFFI_DEPENDS=python26, py26-cparser, libffi
PY27-CFFI_DEPENDS=python27, py27-cparser, libffi
PY3-CFFI_DEPENDS=python3
PY-CFFI_CONFLICTS=

#
# PY-CFFI_IPK_VERSION should be incremented when the ipk changes.
#
PY-CFFI_IPK_VERSION=2

#
# PY-CFFI_CONFFILES should be a list of user-editable files
#PY-CFFI_CONFFILES=$(TARGET_PREFIX)/etc/py-cffi.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cffi

#
# PY-CFFI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CFFI_PATCHES=$(PY-CFFI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CFFI_CPPFLAGS=
PY-CFFI_LDFLAGS=

#
# PY-CFFI_BUILD_DIR is the directory in which the build is done.
# PY-CFFI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CFFI_IPK_DIR is the directory in which the ipk is built.
# PY-CFFI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CFFI_SOURCE_DIR=$(SOURCE_DIR)/py-cffi
PY-CFFI_BUILD_DIR=$(BUILD_DIR)/py-cffi
PY-CFFI_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-cffi

PY26-CFFI_IPK_DIR=$(BUILD_DIR)/py26-cffi-$(PY-CFFI_VERSION)-ipk
PY26-CFFI_IPK=$(BUILD_DIR)/py26-cffi_$(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CFFI_IPK_DIR=$(BUILD_DIR)/py27-cffi-$(PY-CFFI_VERSION)-ipk
PY27-CFFI_IPK=$(BUILD_DIR)/py27-cffi_$(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CFFI_IPK_DIR=$(BUILD_DIR)/py3-cffi-$(PY-CFFI_VERSION)-ipk
PY3-CFFI_IPK=$(BUILD_DIR)/py3-cffi_$(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-cffi-source py-cffi-unpack py-cffi py-cffi-stage py-cffi-ipk py-cffi-clean py-cffi-dirclean py-cffi-check py-cffi-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CFFI_SOURCE):
	$(WGET) -P $(@D) $(PY-CFFI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cffi-source: $(DL_DIR)/$(PY-CFFI_SOURCE) $(PY-CFFI_PATCHES)

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
$(PY-CFFI_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CFFI_SOURCE) $(PY-CFFI_PATCHES) make/py-cffi.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) python26-stage python27-stage python3-stage
	$(MAKE) py-setuptools-host-stage py-hgdistver-host-stage
	$(MAKE) libffi-stage
	rm -rf $(BUILD_DIR)/$(PY-CFFI_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE)
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CFFI_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CFFI_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE)
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CFFI_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CFFI_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE)
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CFFI_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CFFI_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg \
	)
#	sed -i -e '/#include <ffi\.h>/s/$$/\n#include <Python.h>/' $(@D)/2.4/c/malloc_closure.h \
		$(@D)/2.5/c/malloc_closure.h $(@D)/2.6/c/malloc_closure.h \
		$(@D)/2.7/c/malloc_closure.h $(@D)/3/c/malloc_closure.h
	touch $@

py-cffi-unpack: $(PY-CFFI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CFFI_BUILD_DIR)/.built: $(PY-CFFI_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-cffi: $(PY-CFFI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CFFI_BUILD_DIR)/.staged: $(PY-CFFI_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) py-cparser-stage
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/cffi*
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python2.7/site-packages/cffi*
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	rm -rf $(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages/cffi*
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-CFFI_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-CFFI_SOURCE) make/py-cffi.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-CFFI_DIR) $(@D)
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	$(MAKE) py-setuptools-host-stage py-hgdistver-host-stage libffi-host-stage
	$(MAKE) py-cparser-host-stage
	mkdir -p $(@D)/
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg \
	)
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg \
	)
	$(PY-CFFI_UNZIP) $(DL_DIR)/$(PY-CFFI_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CFFI_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg \
	)
#	sed -i -e '/#include <ffi\.h>/s/$$/\n#include <Python.h>/' $(@D)/2.4/c/malloc_closure.h \
		$(@D)/2.5/c/malloc_closure.h $(@D)/2.6/c/malloc_closure.h \
		$(@D)/2.7/c/malloc_closure.h $(@D)/3/c/malloc_closure.h
	(cd $(@D)/2.6; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	(cd $(@D)/3; \
	PKG_CONFIG_PATH=$(HOST_STAGING_LIB_DIR)/pkgconfig \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-cffi-stage: $(PY-CFFI_BUILD_DIR)/.staged

py-cffi-host-stage: $(PY-CFFI_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cffi
#
$(PY26-CFFI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cffi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CFFI_PRIORITY)" >>$@
	@echo "Section: $(PY-CFFI_SECTION)" >>$@
	@echo "Version: $(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CFFI_MAINTAINER)" >>$@
	@echo "Source: $(PY-CFFI_SITE)/$(PY-CFFI_SOURCE)" >>$@
	@echo "Description: $(PY-CFFI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CFFI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CFFI_CONFLICTS)" >>$@

$(PY27-CFFI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cffi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CFFI_PRIORITY)" >>$@
	@echo "Section: $(PY-CFFI_SECTION)" >>$@
	@echo "Version: $(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CFFI_MAINTAINER)" >>$@
	@echo "Source: $(PY-CFFI_SITE)/$(PY-CFFI_SOURCE)" >>$@
	@echo "Description: $(PY-CFFI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CFFI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CFFI_CONFLICTS)" >>$@

$(PY3-CFFI_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cffi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CFFI_PRIORITY)" >>$@
	@echo "Section: $(PY-CFFI_SECTION)" >>$@
	@echo "Version: $(PY-CFFI_VERSION)-$(PY-CFFI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CFFI_MAINTAINER)" >>$@
	@echo "Source: $(PY-CFFI_SITE)/$(PY-CFFI_SOURCE)" >>$@
	@echo "Description: $(PY-CFFI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CFFI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CFFI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/etc/py-cffi/...
# Documentation files should be installed in $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/doc/py-cffi/...
# Daemon startup scripts should be installed in $(PY-CFFI_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cffi
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CFFI_IPK): $(PY-CFFI_BUILD_DIR)/.built
	$(MAKE) py-cffi-stage
	rm -rf $(PY26-CFFI_IPK_DIR) $(BUILD_DIR)/py26-cffi_*_$(TARGET_ARCH).ipk
	(cd $(PY-CFFI_BUILD_DIR)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-CFFI_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY26-CFFI_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/*.so
#	rm -f $(PY26-CFFI_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-CFFI_IPK_DIR)/CONTROL/control
	echo $(PY-CFFI_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-CFFI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CFFI_IPK_DIR)

$(PY27-CFFI_IPK): $(PY-CFFI_BUILD_DIR)/.built
	$(MAKE) py-cffi-stage
	rm -rf $(PY27-CFFI_IPK_DIR) $(BUILD_DIR)/py27-cffi_*_$(TARGET_ARCH).ipk
	(cd $(PY-CFFI_BUILD_DIR)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-CFFI_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY27-CFFI_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/*.so
	rm -f $(PY27-CFFI_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-CFFI_IPK_DIR)/CONTROL/control
	echo $(PY-CFFI_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-CFFI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CFFI_IPK_DIR)

$(PY3-CFFI_IPK): $(PY-CFFI_BUILD_DIR)/.built
	$(MAKE) py-cffi-stage
	rm -rf $(PY3-CFFI_IPK_DIR) $(BUILD_DIR)/py3-cffi_*_$(TARGET_ARCH).ipk
	(cd $(PY-CFFI_BUILD_DIR)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CFFI_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY3-CFFI_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/*.so
	rm -f $(PY3-CFFI_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-CFFI_IPK_DIR)/CONTROL/control
	echo $(PY-CFFI_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-CFFI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CFFI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cffi-ipk: $(PY26-CFFI_IPK) $(PY27-CFFI_IPK) $(PY3-CFFI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cffi-clean:
	-$(MAKE) -C $(PY-CFFI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cffi-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CFFI_DIR) $(HOST_BUILD_DIR)/$(PY-CFFI_DIR) \
	$(PY-CFFI_HOST_BUILD_DIR) $(PY-CFFI_BUILD_DIR) \
	$(PY26-CFFI_IPK_DIR) $(PY26-CFFI_IPK) \
	$(PY27-CFFI_IPK_DIR) $(PY27-CFFI_IPK) \
	$(PY3-CFFI_IPK_DIR) $(PY3-CFFI_IPK) \

#
# Some sanity check for the package.
#
py-cffi-check: $(PY26-CFFI_IPK) $(PY27-CFFI_IPK) $(PY3-CFFI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
