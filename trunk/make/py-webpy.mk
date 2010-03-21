###########################################################
#
# py-webpy
#
###########################################################

#
# PY-WEBPY_VERSION, PY-WEBPY_SITE and PY-WEBPY_SOURCE define
# the upstream location of the source code for the package.
# PY-WEBPY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-WEBPY_UNZIP is the command used to unzip the source.
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
PY-WEBPY_SITE=http://webpy.org/static
PY-WEBPY_VERSION=0.34
PY-WEBPY_SOURCE=web.py-$(PY-WEBPY_VERSION).tar.gz
PY-WEBPY_DIR=web.py-$(PY-WEBPY_VERSION)
PY-WEBPY_UNZIP=zcat
PY-WEBPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-WEBPY_DESCRIPTION=A web framework for python that is as simple as it is powerful.
PY-WEBPY_SECTION=web
PY-WEBPY_PRIORITY=optional
PY-WEBPY_CONFLICTS=
PY26-WEBPY_DEPENDS=python26
PY25-WEBPY_DEPENDS=python25
PY26-WEBPY_SUGGESTS=py26-flup
PY25-WEBPY_SUGGESTS=py25-flup

#
# PY-WEBPY_IPK_VERSION should be incremented when the ipk changes.
#
PY-WEBPY_IPK_VERSION=1

#
# PY-WEBPY_CONFFILES should be a list of user-editable files
#PY-WEBPY_CONFFILES=/opt/etc/py-webpy.conf /opt/etc/init.d/SXXpy-webpy

#
# PY-WEBPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-WEBPY_PATCHES=$(PY-WEBPY_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-WEBPY_CPPFLAGS=
PY-WEBPY_LDFLAGS=

#
# PY-WEBPY_BUILD_DIR is the directory in which the build is done.
# PY-WEBPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-WEBPY_IPK_DIR is the directory in which the ipk is built.
# PY-WEBPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-WEBPY_BUILD_DIR=$(BUILD_DIR)/py-webpy
PY-WEBPY_SOURCE_DIR=$(SOURCE_DIR)/py-webpy

PY26-WEBPY_IPK_DIR=$(BUILD_DIR)/py26-webpy-$(PY-WEBPY_VERSION)-ipk
PY26-WEBPY_IPK=$(BUILD_DIR)/py26-webpy_$(PY-WEBPY_VERSION)-$(PY-WEBPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-WEBPY_IPK_DIR=$(BUILD_DIR)/py25-webpy-$(PY-WEBPY_VERSION)-ipk
PY25-WEBPY_IPK=$(BUILD_DIR)/py25-webpy_$(PY-WEBPY_VERSION)-$(PY-WEBPY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-webpy-source py-webpy-unpack py-webpy py-webpy-stage py-webpy-ipk py-webpy-clean py-webpy-dirclean py-webpy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-WEBPY_SOURCE):
	$(WGET) -P $(@D) $(PY-WEBPY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-webpy-source: $(DL_DIR)/$(PY-WEBPY_SOURCE) $(PY-WEBPY_PATCHES)

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
$(PY-WEBPY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-WEBPY_SOURCE) $(PY-WEBPY_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-WEBPY_DIR)
	$(PY-WEBPY_UNZIP) $(DL_DIR)/$(PY-WEBPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-WEBPY_PATCHES)"; \
		then cat $(PY-WEBPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEBPY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-WEBPY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-WEBPY_DIR)
	$(PY-WEBPY_UNZIP) $(DL_DIR)/$(PY-WEBPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-WEBPY_PATCHES)"; \
		then cat $(PY-WEBPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEBPY_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-WEBPY_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	touch $@

py-webpy-unpack: $(PY-WEBPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-WEBPY_BUILD_DIR)/.built: $(PY-WEBPY_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" build
	cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build
	touch $@

#
# This is the build convenience target.
#
py-webpy: $(PY-WEBPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-WEBPY_BUILD_DIR)/.staged: $(PY-WEBPY_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-webpy-stage: $(PY-WEBPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-webpy
#
$(PY26-WEBPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-webpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEBPY_PRIORITY)" >>$@
	@echo "Section: $(PY-WEBPY_SECTION)" >>$@
	@echo "Version: $(PY-WEBPY_VERSION)-$(PY-WEBPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEBPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEBPY_SITE)/$(PY-WEBPY_SOURCE)" >>$@
	@echo "Description: $(PY-WEBPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-WEBPY_DEPENDS)" >>$@
	@echo "Suggests: $(PY26-WEBPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-WEBPY_CONFLICTS)" >>$@

$(PY25-WEBPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-webpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEBPY_PRIORITY)" >>$@
	@echo "Section: $(PY-WEBPY_SECTION)" >>$@
	@echo "Version: $(PY-WEBPY_VERSION)-$(PY-WEBPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEBPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEBPY_SITE)/$(PY-WEBPY_SOURCE)" >>$@
	@echo "Description: $(PY-WEBPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-WEBPY_DEPENDS)" >>$@
	@echo "Suggests: $(PY25-WEBPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-WEBPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-WEBPY_IPK_DIR)/opt/sbin or $(PY-WEBPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-WEBPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-WEBPY_IPK_DIR)/opt/etc/py-webpy/...
# Documentation files should be installed in $(PY-WEBPY_IPK_DIR)/opt/doc/py-webpy/...
# Daemon startup scripts should be installed in $(PY-WEBPY_IPK_DIR)/opt/etc/init.d/S??py-webpy
#
# You may need to patch your application to make it use these locations.
#
$(PY26-WEBPY_IPK): $(PY-WEBPY_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-webpy_*_$(TARGET_ARCH).ipk
	rm -rf $(PY26-WEBPY_IPK_DIR) $(BUILD_DIR)/py26-webpy_*_$(TARGET_ARCH).ipk
	(cd $(PY-WEBPY_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY26-WEBPY_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) `find $(PY26-WEBPY_IPK_DIR)/opt/lib/python2.6/site-packages -name '*.so'`
	$(MAKE) $(PY26-WEBPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-WEBPY_IPK_DIR)

$(PY25-WEBPY_IPK): $(PY-WEBPY_BUILD_DIR)/.built
	rm -rf $(PY25-WEBPY_IPK_DIR) $(BUILD_DIR)/py25-webpy_*_$(TARGET_ARCH).ipk
	(cd $(PY-WEBPY_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY25-WEBPY_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) `find $(PY25-WEBPY_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-WEBPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-WEBPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-webpy-ipk: $(PY26-WEBPY_IPK) $(PY25-WEBPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-webpy-clean:
	-$(MAKE) -C $(PY-WEBPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-webpy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-WEBPY_DIR) $(PY-WEBPY_BUILD_DIR)
	rm -rf $(PY26-WEBPY_IPK_DIR) $(PY26-WEBPY_IPK)
	rm -rf $(PY25-WEBPY_IPK_DIR) $(PY25-WEBPY_IPK)

#
# Some sanity check for the package.
#
py-webpy-check: $(PY26-WEBPY_IPK) $(PY25-WEBPY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
