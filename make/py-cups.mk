###########################################################
#
# py-cups
#
###########################################################

#
# PY_CUPS_VERSION, PY_CUPS_SITE and PY_CUPS_SOURCE define
# the upstream location of the source code for the package.
# PY_CUPS_DIR is the directory which is created when the source
# archive is unpacked.
# PY_CUPS_UNZIP is the command used to unzip the source.
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
PY_CUPS_VERSION=1.9.73
PY_CUPS_SITE=https://pypi.python.org/packages/7c/ea/7a9bf1e69e001bdd6ee2909f08d44d9fcb9d196933236eaa99fa3b155749
PY_CUPS_SOURCE=pycups-$(PY_CUPS_VERSION).tar.bz2
PY_CUPS_DIR=pycups-$(PY_CUPS_VERSION)
PY_CUPS_UNZIP=bzcat
PY_CUPS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY_CUPS_DESCRIPTION=This is a set of Python bindings for the libcups library from the CUPS project.
PY_CUPS_SECTION=lib
PY_CUPS_PRIORITY=optional
PY26_CUPS_DEPENDS=python26, libcups
PY27_CUPS_DEPENDS=python27, libcups
PY3_CUPS_DEPENDS=python3, libcups
PY_CUPS_CONFLICTS=

#
# PY_CUPS_IPK_VERSION should be incremented when the ipk changes.
#
PY_CUPS_IPK_VERSION=2

#
# PY_CUPS_CONFFILES should be a list of user-editable files
#PY_CUPS_CONFFILES=$(TARGET_PREFIX)/etc/py-cups.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cups

#
# PY_CUPS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY_CUPS_PATCHES=$(PY_CUPS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY_CUPS_CPPFLAGS=
PY_CUPS_LDFLAGS=

#
# PY_CUPS_BUILD_DIR is the directory in which the build is done.
# PY_CUPS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY_CUPS_IPK_DIR is the directory in which the ipk is built.
# PY_CUPS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY_CUPS_BUILD_DIR=$(BUILD_DIR)/py-cups
PY_CUPS_SOURCE_DIR=$(SOURCE_DIR)/py-cups
PY_CUPS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-cups

PY26_CUPS_IPK_DIR=$(BUILD_DIR)/py26-cups-$(PY_CUPS_VERSION)-ipk
PY26_CUPS_IPK=$(BUILD_DIR)/py26-cups_$(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27_CUPS_IPK_DIR=$(BUILD_DIR)/py27-cups-$(PY_CUPS_VERSION)-ipk
PY27_CUPS_IPK=$(BUILD_DIR)/py27-cups_$(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3_CUPS_IPK_DIR=$(BUILD_DIR)/py3-cups-$(PY_CUPS_VERSION)-ipk
PY3_CUPS_IPK=$(BUILD_DIR)/py3-cups_$(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)_$(TARGET_ARCH).ipk



.PHONY: py-cups-source py-cups-unpack py-cups py-cups-stage py-cups-ipk py-cups-clean py-cups-dirclean py-cups-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY_CUPS_SOURCE):
	$(WGET) -P $(@D) $(PY_CUPS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cups-source: $(DL_DIR)/$(PY_CUPS_SOURCE) $(PY_CUPS_PATCHES)

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
$(PY_CUPS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY_CUPS_SOURCE) $(PY_CUPS_PATCHES) make/py-cups.mk
	$(MAKE) cups-stage python26-host-stage python27-host-stage python3-host-stage
	rm -rf $(BUILD_DIR)/$(PY_CUPS_DIR) $(@D)
	mkdir -p $(@D)
	# 2.6
	$(PY_CUPS_UNZIP) $(DL_DIR)/$(PY_CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY_CUPS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY_CUPS_DIR) -p1
	mv $(BUILD_DIR)/$(PY_CUPS_DIR) $(@D)/2.6
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
	$(PY_CUPS_UNZIP) $(DL_DIR)/$(PY_CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY_CUPS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY_CUPS_DIR) -p1
	mv $(BUILD_DIR)/$(PY_CUPS_DIR) $(@D)/2.7
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
	$(PY_CUPS_UNZIP) $(DL_DIR)/$(PY_CUPS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY_CUPS_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY_CUPS_DIR) -p1
	mv $(BUILD_DIR)/$(PY_CUPS_DIR) $(@D)/3
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

py-cups-unpack: $(PY_CUPS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY_CUPS_BUILD_DIR)/.built: $(PY_CUPS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-cups: $(PY_CUPS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY_CUPS_BUILD_DIR)/.staged: $(PY_CUPS_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -pthread' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -pthread' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -pthread' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

py-cups-stage: $(PY_CUPS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cups
#
$(PY26_CUPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cups" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY_CUPS_PRIORITY)" >>$@
	@echo "Section: $(PY_CUPS_SECTION)" >>$@
	@echo "Version: $(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY_CUPS_MAINTAINER)" >>$@
	@echo "Source: $(PY_CUPS_SITE)/$(PY_CUPS_SOURCE)" >>$@
	@echo "Description: $(PY_CUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26_CUPS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY_CUPS_CONFLICTS)" >>$@

$(PY27_CUPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cups" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY_CUPS_PRIORITY)" >>$@
	@echo "Section: $(PY_CUPS_SECTION)" >>$@
	@echo "Version: $(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY_CUPS_MAINTAINER)" >>$@
	@echo "Source: $(PY_CUPS_SITE)/$(PY_CUPS_SOURCE)" >>$@
	@echo "Description: $(PY_CUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27_CUPS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY_CUPS_CONFLICTS)" >>$@

$(PY3_CUPS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cups" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY_CUPS_PRIORITY)" >>$@
	@echo "Section: $(PY_CUPS_SECTION)" >>$@
	@echo "Version: $(PY_CUPS_VERSION)-$(PY_CUPS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY_CUPS_MAINTAINER)" >>$@
	@echo "Source: $(PY_CUPS_SITE)/$(PY_CUPS_SOURCE)" >>$@
	@echo "Description: $(PY_CUPS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3_CUPS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY_CUPS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/py-cups/...
# Documentation files should be installed in $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/doc/py-cups/...
# Daemon startup scripts should be installed in $(PY_CUPS_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cups
#
# You may need to patch your application to make it use these locations.
#
$(PY26_CUPS_IPK) $(PY27_CUPS_IPK) $(PY3_CUPS_IPK): $(PY_CUPS_BUILD_DIR)/.built
	# 2.6
	rm -rf $(PY26_CUPS_IPK_DIR) $(BUILD_DIR)/py26-cups_*_$(TARGET_ARCH).ipk
	(cd $(PY_CUPS_BUILD_DIR)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26_CUPS_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY26_CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/*.so
	$(MAKE) $(PY26_CUPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26_CUPS_IPK_DIR)
	# 2.7
	rm -rf $(PY27_CUPS_IPK_DIR) $(BUILD_DIR)/py27-cups_*_$(TARGET_ARCH).ipk
	(cd $(PY_CUPS_BUILD_DIR)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27_CUPS_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY27_CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/*.so
	$(MAKE) $(PY27_CUPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27_CUPS_IPK_DIR)
	# 3
	rm -rf $(PY3_CUPS_IPK_DIR) $(BUILD_DIR)/py3-cups_*_$(TARGET_ARCH).ipk
	(cd $(PY_CUPS_BUILD_DIR)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3_CUPS_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY3_CUPS_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/*.so
	$(MAKE) $(PY3_CUPS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3_CUPS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cups-ipk: $(PY26_CUPS_IPK) $(PY27_CUPS_IPK) $(PY3_CUPS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cups-clean:
	-$(MAKE) -C $(PY_CUPS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cups-dirclean:
	rm -rf $(BUILD_DIR)/$(PY_CUPS_DIR) $(PY_CUPS_BUILD_DIR) \
		$(PY26_CUPS_IPK_DIR) $(PY26_CUPS_IPK) \
		$(PY27_CUPS_IPK_DIR) $(PY27_CUPS_IPK) \
		$(PY3_CUPS_IPK_DIR) $(PY3_CUPS_IPK) \

#
# Some sanity check for the package.
#
py-cups-check: $(PY26_CUPS_IPK) $(PY27_CUPS_IPK) $(PY3_CUPS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
