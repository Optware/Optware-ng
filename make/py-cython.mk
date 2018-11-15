###########################################################
#
# py-cython
#
###########################################################

#
# PY-CYTHON_VERSION, PY-CYTHON_SITE and PY-CYTHON_SOURCE define
# the upstream location of the source code for the package.
# PY-CYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CYTHON_UNZIP is the command used to unzip the source.
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
PY-CYTHON_VERSION=0.29
PY-CYTHON_SITE=https://files.pythonhosted.org/packages/f0/66/6309291b19b498b672817bd237caec787d1b18013ee659f17b1ec5844887
PY-CYTHON_SOURCE=Cython-$(PY-CYTHON_VERSION).tar.gz
PY-CYTHON_DIR=Cython-$(PY-CYTHON_VERSION)
PY-CYTHON_UNZIP=zcat
PY-CYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CYTHON_DESCRIPTION=The Cython compiler for writing C extensions for the Python language.
PY-CYTHON_SECTION=misc
PY-CYTHON_PRIORITY=optional
PY26-CYTHON_DEPENDS=python26
PY27-CYTHON_DEPENDS=python27
PY3-CYTHON_DEPENDS=python3
PY-CYTHON_CONFLICTS=

#
# PY-CYTHON_IPK_VERSION should be incremented when the ipk changes.
#
PY-CYTHON_IPK_VERSION=1

#
# PY-CYTHON_CONFFILES should be a list of user-editable files
#PY-CYTHON_CONFFILES=$(TARGET_PREFIX)/etc/py-cython.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cython

#
# PY-CYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CYTHON_PATCHES=$(PY-CYTHON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CYTHON_CPPFLAGS=
PY-CYTHON_LDFLAGS=

#
# PY-CYTHON_BUILD_DIR is the directory in which the build is done.
# PY-CYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CYTHON_IPK_DIR is the directory in which the ipk is built.
# PY-CYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CYTHON_BUILD_DIR=$(BUILD_DIR)/py-cython
PY-CYTHON_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-cython
PY-CYTHON_SOURCE_DIR=$(SOURCE_DIR)/py-cython

PY26-CYTHON_IPK_DIR=$(BUILD_DIR)/py26-cython-$(PY-CYTHON_VERSION)-ipk
PY26-CYTHON_IPK=$(BUILD_DIR)/py26-cython_$(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CYTHON_IPK_DIR=$(BUILD_DIR)/py27-cython-$(PY-CYTHON_VERSION)-ipk
PY27-CYTHON_IPK=$(BUILD_DIR)/py27-cython_$(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CYTHON_IPK_DIR=$(BUILD_DIR)/py3-cython-$(PY-CYTHON_VERSION)-ipk
PY3-CYTHON_IPK=$(BUILD_DIR)/py3-cython_$(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-cython-source py-cython-unpack py-cython py-cython-host-stage py-cython-ipk py-cython-clean py-cython-dirclean py-cython-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CYTHON_SOURCE):
	$(WGET) -P $(@D) $(PY-CYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cython-source: $(DL_DIR)/$(PY-CYTHON_SOURCE) $(PY-CYTHON_PATCHES)

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
$(PY-CYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CYTHON_SOURCE) $(PY-CYTHON_PATCHES) make/py-cython.mk
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	rm -rf $(BUILD_DIR)/$(PY-CYTHON_DIR) $(BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)
	mkdir -p $(PY-CYTHON_BUILD_DIR)
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/2.6
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
	    ) >> setup.cfg \
	)
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/2.7
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
	    ) >> setup.cfg \
	)
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CYTHON_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/3
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
	    ) >> setup.cfg \
	)
	touch $@

py-cython-unpack: $(PY-CYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CYTHON_BUILD_DIR)/.built: $(PY-CYTHON_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-cython: $(PY-CYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-CYTHON_BUILD_DIR)/.staged: $(PY-CYTHON_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-CYTHON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-cython-stage: $(PY-CYTHON_BUILD_DIR)/.staged

$(PY-CYTHON_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-CYTHON_SOURCE) #make/py-cython.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)
	$(MAKE) python26-host-stage python27-host-stage python3-host-stage
	mkdir -p $(@D)/
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
		echo "[build_scripts]"; \
		echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=$(HOST_STAGING_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
		echo "[build_scripts]"; \
		echo "executable=$(HOST_STAGING_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(HOST_STAGING_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	$(PY-CYTHON_UNZIP) $(DL_DIR)/$(PY-CYTHON_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CYTHON_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
		echo "[build_scripts]"; \
		echo "executable=$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
		echo "[install]"; \
		echo "install_scripts=$(HOST_STAGING_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-cython-host-stage: $(PY-CYTHON_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cython
#
$(PY26-CYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CYTHON_PRIORITY)" >>$@
	@echo "Section: $(PY-CYTHON_SECTION)" >>$@
	@echo "Version: $(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CYTHON_MAINTAINER)" >>$@
	@echo "Source: $(PY-CYTHON_SITE)/$(PY-CYTHON_SOURCE)" >>$@
	@echo "Description: $(PY-CYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CYTHON_CONFLICTS)" >>$@

$(PY27-CYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CYTHON_PRIORITY)" >>$@
	@echo "Section: $(PY-CYTHON_SECTION)" >>$@
	@echo "Version: $(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CYTHON_MAINTAINER)" >>$@
	@echo "Source: $(PY-CYTHON_SITE)/$(PY-CYTHON_SOURCE)" >>$@
	@echo "Description: $(PY-CYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CYTHON_CONFLICTS)" >>$@

$(PY3-CYTHON_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CYTHON_PRIORITY)" >>$@
	@echo "Section: $(PY-CYTHON_SECTION)" >>$@
	@echo "Version: $(PY-CYTHON_VERSION)-$(PY-CYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CYTHON_MAINTAINER)" >>$@
	@echo "Source: $(PY-CYTHON_SITE)/$(PY-CYTHON_SOURCE)" >>$@
	@echo "Description: $(PY-CYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CYTHON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/py-cython/...
# Documentation files should be installed in $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/doc/py-cython/...
# Daemon startup scripts should be installed in $(PY-CYTHON_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cython
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CYTHON_IPK): $(PY-CYTHON_BUILD_DIR)/.built
	rm -rf $(PY26-CYTHON_IPK_DIR) $(BUILD_DIR)/py26-cython_*_$(TARGET_ARCH).ipk
	(cd $(PY-CYTHON_BUILD_DIR)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-CYTHON_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY26-CYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/Cython/*/*.so
	$(MAKE) $(PY26-CYTHON_IPK_DIR)/CONTROL/control
	echo $(PY-CYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-CYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CYTHON_IPK_DIR)

$(PY27-CYTHON_IPK): $(PY-CYTHON_BUILD_DIR)/.built
	rm -rf $(PY27-CYTHON_IPK_DIR) $(BUILD_DIR)/py27-cython_*_$(TARGET_ARCH).ipk
	(cd $(PY-CYTHON_BUILD_DIR)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-CYTHON_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY27-CYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/Cython/*/*.so
	$(MAKE) $(PY27-CYTHON_IPK_DIR)/CONTROL/control
	echo $(PY-CYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-CYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CYTHON_IPK_DIR)

$(PY3-CYTHON_IPK): $(PY-CYTHON_BUILD_DIR)/.built
	rm -rf $(PY3-CYTHON_IPK_DIR) $(BUILD_DIR)/py3-cython_*_$(TARGET_ARCH).ipk
	(cd $(PY-CYTHON_BUILD_DIR)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CYTHON_IPK_DIR) --prefix=$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(PY3-CYTHON_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/Cython/*/*.so
	$(MAKE) $(PY3-CYTHON_IPK_DIR)/CONTROL/control
	echo $(PY-CYTHON_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-CYTHON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CYTHON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cython-ipk: $(PY26-CYTHON_IPK) $(PY27-CYTHON_IPK) $(PY3-CYTHON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cython-clean:
	-$(MAKE) -C $(PY-CYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cython-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CYTHON_DIR) $(PY-CYTHON_BUILD_DIR) \
	$(PY26-CYTHON_IPK_DIR) $(PY26-CYTHON_IPK) \
	$(PY27-CYTHON_IPK_DIR) $(PY27-CYTHON_IPK) \
	$(PY3-CYTHON_IPK_DIR) $(PY3-CYTHON_IPK) \

#
# Some sanity check for the package.
#
py-cython-check: $(PY26-CYTHON_IPK) $(PY27-CYTHON_IPK) $(PY3-CYTHON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
