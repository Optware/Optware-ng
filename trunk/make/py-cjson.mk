###########################################################
#
# py-cjson
#
###########################################################

#
# PY-CJSON_VERSION, PY-CJSON_SITE and PY-CJSON_SOURCE define
# the upstream location of the source code for the package.
# PY-CJSON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CJSON_UNZIP is the command used to unzip the source.
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
PY-CJSON_VERSION=1.0.5
PY-CJSON_SITE=http://pypi.python.org/packages/source/p/python-cjson
PY-CJSON_SOURCE=python-cjson-$(PY-CJSON_VERSION).tar.gz
PY-CJSON_DIR=python-cjson-$(PY-CJSON_VERSION)
PY-CJSON_UNZIP=zcat
PY-CJSON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CJSON_DESCRIPTION=A very fast JSON encoder/decoder for Python.
PY-CJSON_SECTION=misc
PY-CJSON_PRIORITY=optional
PY24-CJSON_DEPENDS=python24
PY25-CJSON_DEPENDS=python25
PY-CJSON_CONFLICTS=

#
# PY-CJSON_IPK_VERSION should be incremented when the ipk changes.
#
PY-CJSON_IPK_VERSION=1

#
# PY-CJSON_CONFFILES should be a list of user-editable files
#PY-CJSON_CONFFILES=/opt/etc/py-cjson.conf /opt/etc/init.d/SXXpy-cjson

#
# PY-CJSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CJSON_PATCHES=$(PY-CJSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CJSON_CPPFLAGS=
PY-CJSON_LDFLAGS=

#
# PY-CJSON_BUILD_DIR is the directory in which the build is done.
# PY-CJSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CJSON_IPK_DIR is the directory in which the ipk is built.
# PY-CJSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CJSON_BUILD_DIR=$(BUILD_DIR)/py-cjson
PY-CJSON_SOURCE_DIR=$(SOURCE_DIR)/py-cjson

PY24-CJSON_IPK_DIR=$(BUILD_DIR)/py-cjson-$(PY-CJSON_VERSION)-ipk
PY24-CJSON_IPK=$(BUILD_DIR)/py-cjson_$(PY-CJSON_VERSION)-$(PY-CJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CJSON_IPK_DIR=$(BUILD_DIR)/py25-cjson-$(PY-CJSON_VERSION)-ipk
PY25-CJSON_IPK=$(BUILD_DIR)/py25-cjson_$(PY-CJSON_VERSION)-$(PY-CJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-cjson-source py-cjson-unpack py-cjson py-cjson-stage py-cjson-ipk py-cjson-clean py-cjson-dirclean py-cjson-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CJSON_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CJSON_SITE)/$(PY-CJSON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cjson-source: $(DL_DIR)/$(PY-CJSON_SOURCE) $(PY-CJSON_PATCHES)

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
$(PY-CJSON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CJSON_SOURCE) $(PY-CJSON_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CJSON_DIR) $(PY-CJSON_BUILD_DIR)
	mkdir -p $(PY-CJSON_BUILD_DIR)
	# 2.4
	$(PY-CJSON_UNZIP) $(DL_DIR)/$(PY-CJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CJSON_DIR) $(PY-CJSON_BUILD_DIR)/2.4
	(cd $(PY-CJSON_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	$(PY-CJSON_UNZIP) $(DL_DIR)/$(PY-CJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CJSON_DIR) $(PY-CJSON_BUILD_DIR)/2.5
	(cd $(PY-CJSON_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $(PY-CJSON_BUILD_DIR)/.configured

py-cjson-unpack: $(PY-CJSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CJSON_BUILD_DIR)/.built: $(PY-CJSON_BUILD_DIR)/.configured
	rm -f $(PY-CJSON_BUILD_DIR)/.built
	(cd $(PY-CJSON_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-CJSON_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $(PY-CJSON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-cjson: $(PY-CJSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CJSON_BUILD_DIR)/.staged: $(PY-CJSON_BUILD_DIR)/.built
	rm -f $(PY-CJSON_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CJSON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CJSON_BUILD_DIR)/.staged

py-cjson-stage: $(PY-CJSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cjson
#
$(PY24-CJSON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-cjson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-CJSON_SECTION)" >>$@
	@echo "Version: $(PY-CJSON_VERSION)-$(PY-CJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-CJSON_SITE)/$(PY-CJSON_SOURCE)" >>$@
	@echo "Description: $(PY-CJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CJSON_CONFLICTS)" >>$@

$(PY25-CJSON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-cjson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-CJSON_SECTION)" >>$@
	@echo "Version: $(PY-CJSON_VERSION)-$(PY-CJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-CJSON_SITE)/$(PY-CJSON_SOURCE)" >>$@
	@echo "Description: $(PY-CJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CJSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CJSON_IPK_DIR)/opt/sbin or $(PY-CJSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CJSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CJSON_IPK_DIR)/opt/etc/py-cjson/...
# Documentation files should be installed in $(PY-CJSON_IPK_DIR)/opt/doc/py-cjson/...
# Daemon startup scripts should be installed in $(PY-CJSON_IPK_DIR)/opt/etc/init.d/S??py-cjson
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CJSON_IPK) $(PY25-CJSON_IPK): $(PY-CJSON_BUILD_DIR)/.built
	# 2.4
	rm -rf $(PY24-CJSON_IPK_DIR) $(BUILD_DIR)/py-cjson_*_$(TARGET_ARCH).ipk
	(cd $(PY-CJSON_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-CJSON_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY24-CJSON_IPK_DIR)/opt/lib/python2.4/site-packages/cjson*.so
	$(MAKE) $(PY24-CJSON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CJSON_IPK_DIR)
	# 2.5
	rm -rf $(PY25-CJSON_IPK_DIR) $(BUILD_DIR)/py25-cjson_*_$(TARGET_ARCH).ipk
	(cd $(PY-CJSON_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-CJSON_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-CJSON_IPK_DIR)/opt/lib/python2.5/site-packages/cjson*.so
	$(MAKE) $(PY25-CJSON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CJSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cjson-ipk: $(PY24-CJSON_IPK) $(PY25-CJSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cjson-clean:
	-$(MAKE) -C $(PY-CJSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cjson-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CJSON_DIR) $(PY-CJSON_BUILD_DIR)
	rm -rf $(PY24-CJSON_IPK_DIR) $(PY24-CJSON_IPK)
	rm -rf $(PY25-CJSON_IPK_DIR) $(PY25-CJSON_IPK)

#
# Some sanity check for the package.
#
py-cjson-check: $(PY24-CJSON_IPK) $(PY25-CJSON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-CJSON_IPK) $(PY25-CJSON_IPK)
