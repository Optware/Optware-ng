###########################################################
#
# subvertpy
#
###########################################################

#
# SUBVERTPY_VERSION, SUBVERTPY_SITE and SUBVERTPY_SOURCE define
# the upstream location of the source code for the package.
# SUBVERTPY_DIR is the directory which is created when the source
# archive is unpacked.
# SUBVERTPY_UNZIP is the command used to unzip the source.
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
SUBVERTPY_VERSION=0.9.1
SUBVERTPY_SITE=http://samba.org/~jelmer/subvertpy
SUBVERTPY_SOURCE=subvertpy-$(SUBVERTPY_VERSION).tar.gz
SUBVERTPY_DIR=subvertpy-$(SUBVERTPY_VERSION)
SUBVERTPY_UNZIP=zcat
SUBVERTPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SUBVERTPY_DESCRIPTION=Alternative Python bindings for Subversion, aiming to have complete, portable and "Pythonic" Python bindings.
SUBVERTPY_SECTION=devel
SUBVERTPY_PRIORITY=optional
PY25-SUBVERTPY_DEPENDS=svn, python25
PY26-SUBVERTPY_DEPENDS=svn, python26
PY27-SUBVERTPY_DEPENDS=svn, python26
PY3-SUBVERTPY_DEPENDS=svn, python3
SUBVERTPY_CONFLICTS=

#
# SUBVERTPY_IPK_VERSION should be incremented when the ipk changes.
#
SUBVERTPY_IPK_VERSION=3

#
# SUBVERTPY_CONFFILES should be a list of user-editable files
#SUBVERTPY_CONFFILES=$(TARGET_PREFIX)/etc/subvertpy.conf $(TARGET_PREFIX)/etc/init.d/SXXsubvertpy

#
# SUBVERTPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SUBVERTPY_PATCHES=$(SUBVERTPY_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SUBVERTPY_CPPFLAGS=
SUBVERTPY_LDFLAGS=

#
# SUBVERTPY_BUILD_DIR is the directory in which the build is done.
# SUBVERTPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SUBVERTPY_IPK_DIR is the directory in which the ipk is built.
# SUBVERTPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SUBVERTPY_BUILD_DIR=$(BUILD_DIR)/subvertpy
SUBVERTPY_SOURCE_DIR=$(SOURCE_DIR)/subvertpy

PY25-SUBVERTPY_IPK_DIR=$(BUILD_DIR)/py25-subvertpy-$(SUBVERTPY_VERSION)-ipk
PY25-SUBVERTPY_IPK=$(BUILD_DIR)/py25-subvertpy_$(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-SUBVERTPY_IPK_DIR=$(BUILD_DIR)/py26-subvertpy-$(SUBVERTPY_VERSION)-ipk
PY26-SUBVERTPY_IPK=$(BUILD_DIR)/py26-subvertpy_$(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-SUBVERTPY_IPK_DIR=$(BUILD_DIR)/py27-subvertpy-$(SUBVERTPY_VERSION)-ipk
PY27-SUBVERTPY_IPK=$(BUILD_DIR)/py27-subvertpy_$(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-SUBVERTPY_IPK_DIR=$(BUILD_DIR)/py3-subvertpy-$(SUBVERTPY_VERSION)-ipk
PY3-SUBVERTPY_IPK=$(BUILD_DIR)/py3-subvertpy_$(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: subvertpy-source subvertpy-unpack subvertpy subvertpy-stage subvertpy-ipk subvertpy-clean subvertpy-dirclean subvertpy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SUBVERTPY_SOURCE):
	$(WGET) -P $(@D) $(SUBVERTPY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
subvertpy-source: $(DL_DIR)/$(SUBVERTPY_SOURCE) $(SUBVERTPY_PATCHES)

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
$(SUBVERTPY_BUILD_DIR)/.configured: $(DL_DIR)/$(SUBVERTPY_SOURCE) $(SUBVERTPY_PATCHES) make/subvertpy.mk
	$(MAKE) python-stage svn-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(SUBVERTPY_DIR)
	$(SUBVERTPY_UNZIP) $(DL_DIR)/$(SUBVERTPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
	cat $(SUBVERTPY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SUBVERTPY_DIR) -p0
endif
	mv $(BUILD_DIR)/$(SUBVERTPY_DIR) $(@D)/2.5
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
	rm -rf $(BUILD_DIR)/$(SUBVERTPY_DIR)
	$(SUBVERTPY_UNZIP) $(DL_DIR)/$(SUBVERTPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
	cat $(SUBVERTPY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SUBVERTPY_DIR) -p0
endif
	mv $(BUILD_DIR)/$(SUBVERTPY_DIR) $(@D)/2.6
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
	rm -rf $(BUILD_DIR)/$(SUBVERTPY_DIR)
	$(SUBVERTPY_UNZIP) $(DL_DIR)/$(SUBVERTPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
	cat $(SUBVERTPY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SUBVERTPY_DIR) -p0
endif
	mv $(BUILD_DIR)/$(SUBVERTPY_DIR) $(@D)/2.7
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
#	rm -rf $(BUILD_DIR)/$(SUBVERTPY_DIR)
#	$(SUBVERTPY_UNZIP) $(DL_DIR)/$(SUBVERTPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
#	cat $(SUBVERTPY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(SUBVERTPY_DIR) -p0
endif
#	mv $(BUILD_DIR)/$(SUBVERTPY_DIR) $(@D)/3
#	(cd $(@D)/3; \
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

subvertpy-unpack: $(SUBVERTPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SUBVERTPY_BUILD_DIR)/.built: $(SUBVERTPY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) CC='$(TARGET_CC) -DT_PYSSIZET=19' LDSHARED='$(TARGET_CC) -shared' \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
#	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
subvertpy: $(SUBVERTPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(SUBVERTPY_BUILD_DIR)/.staged: $(SUBVERTPY_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(SUBVERTPY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#subvertpy-stage: $(SUBVERTPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/subvertpy
#
$(PY25-SUBVERTPY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-subvertpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUBVERTPY_PRIORITY)" >>$@
	@echo "Section: $(SUBVERTPY_SECTION)" >>$@
	@echo "Version: $(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUBVERTPY_MAINTAINER)" >>$@
	@echo "Source: $(SUBVERTPY_SITE)/$(SUBVERTPY_SOURCE)" >>$@
	@echo "Description: $(SUBVERTPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SUBVERTPY_DEPENDS)" >>$@
	@echo "Conflicts: $(SUBVERTPY_CONFLICTS)" >>$@

$(PY26-SUBVERTPY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-subvertpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUBVERTPY_PRIORITY)" >>$@
	@echo "Section: $(SUBVERTPY_SECTION)" >>$@
	@echo "Version: $(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUBVERTPY_MAINTAINER)" >>$@
	@echo "Source: $(SUBVERTPY_SITE)/$(SUBVERTPY_SOURCE)" >>$@
	@echo "Description: $(SUBVERTPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-SUBVERTPY_DEPENDS)" >>$@
	@echo "Conflicts: $(SUBVERTPY_CONFLICTS)" >>$@

$(PY27-SUBVERTPY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-subvertpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUBVERTPY_PRIORITY)" >>$@
	@echo "Section: $(SUBVERTPY_SECTION)" >>$@
	@echo "Version: $(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUBVERTPY_MAINTAINER)" >>$@
	@echo "Source: $(SUBVERTPY_SITE)/$(SUBVERTPY_SOURCE)" >>$@
	@echo "Description: $(SUBVERTPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-SUBVERTPY_DEPENDS)" >>$@
	@echo "Conflicts: $(SUBVERTPY_CONFLICTS)" >>$@

$(PY3-SUBVERTPY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-subvertpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SUBVERTPY_PRIORITY)" >>$@
	@echo "Section: $(SUBVERTPY_SECTION)" >>$@
	@echo "Version: $(SUBVERTPY_VERSION)-$(SUBVERTPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SUBVERTPY_MAINTAINER)" >>$@
	@echo "Source: $(SUBVERTPY_SITE)/$(SUBVERTPY_SOURCE)" >>$@
	@echo "Description: $(SUBVERTPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-SUBVERTPY_DEPENDS)" >>$@
	@echo "Conflicts: $(SUBVERTPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/etc/subvertpy/...
# Documentation files should be installed in $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/doc/subvertpy/...
# Daemon startup scripts should be installed in $(SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??subvertpy
#
# You may need to patch your application to make it use these locations.
#
$(PY25-SUBVERTPY_IPK): $(SUBVERTPY_BUILD_DIR)/.built
	rm -rf $(PY25-SUBVERTPY_IPK_DIR) $(BUILD_DIR)/py25-subvertpy_*_$(TARGET_ARCH).ipk
	(cd $(SUBVERTPY_BUILD_DIR)/2.5; \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-SUBVERTPY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	for f in $(PY25-SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.5|'`; done
	$(STRIP_COMMAND) $(PY25-SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages/subvertpy/*.so
	$(MAKE) $(PY25-SUBVERTPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SUBVERTPY_IPK_DIR)

$(PY26-SUBVERTPY_IPK): $(SUBVERTPY_BUILD_DIR)/.built
	rm -rf $(PY26-SUBVERTPY_IPK_DIR) $(BUILD_DIR)/py26-subvertpy_*_$(TARGET_ARCH).ipk
	(cd $(SUBVERTPY_BUILD_DIR)/2.6; \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-SUBVERTPY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY26-SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/subvertpy/*.so
	$(MAKE) $(PY26-SUBVERTPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-SUBVERTPY_IPK_DIR)

$(PY27-SUBVERTPY_IPK): $(SUBVERTPY_BUILD_DIR)/.built
	rm -rf $(PY27-SUBVERTPY_IPK_DIR) $(BUILD_DIR)/py27-subvertpy_*_$(TARGET_ARCH).ipk
	(cd $(SUBVERTPY_BUILD_DIR)/2.7; \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-SUBVERTPY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY27-SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/subvertpy/*.so
	$(MAKE) $(PY27-SUBVERTPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-SUBVERTPY_IPK_DIR)

$(PY3-SUBVERTPY_IPK): $(SUBVERTPY_BUILD_DIR)/.built
	rm -rf $(PY3-SUBVERTPY_IPK_DIR) $(BUILD_DIR)/py3-subvertpy_*_$(TARGET_ARCH).ipk
	(cd $(SUBVERTPY_BUILD_DIR)/3; \
	APR_CONFIG="$(STAGING_PREFIX)/bin/apr-1-config" \
	APU_CONFIG="$(STAGING_PREFIX)/bin/apu-1-config" \
	SVN_PREFIX="$(STAGING_PREFIX)" \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-SUBVERTPY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY3-SUBVERTPY_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/subvertpy/*.so
	$(MAKE) $(PY3-SUBVERTPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-SUBVERTPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
subvertpy-ipk: $(PY25-SUBVERTPY_IPK) $(PY26-SUBVERTPY_IPK) $(PY27-SUBVERTPY_IPK) #$(PY3-SUBVERTPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
subvertpy-clean:
	-$(MAKE) -C $(SUBVERTPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
subvertpy-dirclean:
	rm -rf $(BUILD_DIR)/$(SUBVERTPY_DIR) $(SUBVERTPY_BUILD_DIR)
	rm -rf $(PY25-SUBVERTPY_IPK_DIR) $(PY25-SUBVERTPY_IPK)
	rm -rf $(PY26-SUBVERTPY_IPK_DIR) $(PY26-SUBVERTPY_IPK)
	rm -rf $(PY27-SUBVERTPY_IPK_DIR) $(PY27-SUBVERTPY_IPK)
#	rm -rf $(PY3-SUBVERTPY_IPK_DIR) $(PY3-SUBVERTPY_IPK)

#
# Some sanity check for the package.
#
subvertpy-check: $(PY25-SUBVERTPY_IPK) $(PY26-SUBVERTPY_IPK) $(PY27-SUBVERTPY_IPK) #$(PY3-SUBVERTPY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
