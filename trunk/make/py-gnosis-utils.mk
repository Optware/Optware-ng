###########################################################
#
# py-gnosis-utils
#
###########################################################

#
# PY-GNOSIS-UTILS_VERSION, PY-GNOSIS-UTILS_SITE and PY-GNOSIS-UTILS_SOURCE define
# the upstream location of the source code for the package.
# PY-GNOSIS-UTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GNOSIS-UTILS_UNZIP is the command used to unzip the source.
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
PY-GNOSIS-UTILS_VERSION=1.2.1
PY-GNOSIS-UTILS_SITE=http://gnosis.cx/download/Gnosis_Utils.More
PY-GNOSIS-UTILS_SOURCE=Gnosis_Utils-$(PY-GNOSIS-UTILS_VERSION).tar.bz2
PY-GNOSIS-UTILS_DIR=Gnosis_Utils-$(PY-GNOSIS-UTILS_VERSION)
PY-GNOSIS-UTILS_UNZIP=bzcat
PY-GNOSIS-UTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GNOSIS-UTILS_DESCRIPTION=Gnosis Utilities contains a number of Python libraries, most (but not all) related to working with XML.
PY-GNOSIS-UTILS_SECTION=misc
PY-GNOSIS-UTILS_PRIORITY=optional
PY24-GNOSIS-UTILS_DEPENDS=python24
PY25-GNOSIS-UTILS_DEPENDS=python25
PY-GNOSIS-UTILS_CONFLICTS=

#
# PY-GNOSIS-UTILS_IPK_VERSION should be incremented when the ipk changes.
#
PY-GNOSIS-UTILS_IPK_VERSION=1

#
# PY-GNOSIS-UTILS_CONFFILES should be a list of user-editable files
#PY-GNOSIS-UTILS_CONFFILES=/opt/etc/py-gnosis-utils.conf /opt/etc/init.d/SXXpy-gnosis-utils

#
# PY-GNOSIS-UTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-GNOSIS-UTILS_PATCHES=$(PY-GNOSIS-UTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GNOSIS-UTILS_CPPFLAGS=
PY-GNOSIS-UTILS_LDFLAGS=

#
# PY-GNOSIS-UTILS_BUILD_DIR is the directory in which the build is done.
# PY-GNOSIS-UTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GNOSIS-UTILS_IPK_DIR is the directory in which the ipk is built.
# PY-GNOSIS-UTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GNOSIS-UTILS_BUILD_DIR=$(BUILD_DIR)/py-gnosis-utils
PY-GNOSIS-UTILS_SOURCE_DIR=$(SOURCE_DIR)/py-gnosis-utils

PY24-GNOSIS-UTILS_IPK_DIR=$(BUILD_DIR)/py-gnosis-utils-$(PY-GNOSIS-UTILS_VERSION)-ipk
PY24-GNOSIS-UTILS_IPK=$(BUILD_DIR)/py-gnosis-utils_$(PY-GNOSIS-UTILS_VERSION)-$(PY-GNOSIS-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-GNOSIS-UTILS_IPK_DIR=$(BUILD_DIR)/py25-gnosis-utils-$(PY-GNOSIS-UTILS_VERSION)-ipk
PY25-GNOSIS-UTILS_IPK=$(BUILD_DIR)/py25-gnosis-utils_$(PY-GNOSIS-UTILS_VERSION)-$(PY-GNOSIS-UTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-gnosis-utils-source py-gnosis-utils-unpack py-gnosis-utils py-gnosis-utils-stage py-gnosis-utils-ipk py-gnosis-utils-clean py-gnosis-utils-dirclean py-gnosis-utils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GNOSIS-UTILS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-GNOSIS-UTILS_SITE)/$(PY-GNOSIS-UTILS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-gnosis-utils-source: $(DL_DIR)/$(PY-GNOSIS-UTILS_SOURCE) $(PY-GNOSIS-UTILS_PATCHES)

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
$(PY-GNOSIS-UTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GNOSIS-UTILS_SOURCE) $(PY-GNOSIS-UTILS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) $(PY-GNOSIS-UTILS_BUILD_DIR)
	mkdir -p $(PY-GNOSIS-UTILS_BUILD_DIR)
	# 2.4
	$(PY-GNOSIS-UTILS_UNZIP) $(DL_DIR)/$(PY-GNOSIS-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GNOSIS-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) $(PY-GNOSIS-UTILS_BUILD_DIR)/2.4
	(cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.4; \
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
	$(PY-GNOSIS-UTILS_UNZIP) $(DL_DIR)/$(PY-GNOSIS-UTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GNOSIS-UTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) $(PY-GNOSIS-UTILS_BUILD_DIR)/2.5
	(cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.5; \
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
	touch $(PY-GNOSIS-UTILS_BUILD_DIR)/.configured

py-gnosis-utils-unpack: $(PY-GNOSIS-UTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GNOSIS-UTILS_BUILD_DIR)/.built: $(PY-GNOSIS-UTILS_BUILD_DIR)/.configured
	rm -f $(PY-GNOSIS-UTILS_BUILD_DIR)/.built
	cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $(PY-GNOSIS-UTILS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-gnosis-utils: $(PY-GNOSIS-UTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GNOSIS-UTILS_BUILD_DIR)/.staged: $(PY-GNOSIS-UTILS_BUILD_DIR)/.built
	rm -f $(PY-GNOSIS-UTILS_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-GNOSIS-UTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-GNOSIS-UTILS_BUILD_DIR)/.staged

py-gnosis-utils-stage: $(PY-GNOSIS-UTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-gnosis-utils
#
$(PY24-GNOSIS-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-gnosis-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GNOSIS-UTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-GNOSIS-UTILS_SECTION)" >>$@
	@echo "Version: $(PY-GNOSIS-UTILS_VERSION)-$(PY-GNOSIS-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GNOSIS-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-GNOSIS-UTILS_SITE)/$(PY-GNOSIS-UTILS_SOURCE)" >>$@
	@echo "Description: $(PY-GNOSIS-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-GNOSIS-UTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GNOSIS-UTILS_CONFLICTS)" >>$@

$(PY25-GNOSIS-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-gnosis-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GNOSIS-UTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-GNOSIS-UTILS_SECTION)" >>$@
	@echo "Version: $(PY-GNOSIS-UTILS_VERSION)-$(PY-GNOSIS-UTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GNOSIS-UTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-GNOSIS-UTILS_SITE)/$(PY-GNOSIS-UTILS_SOURCE)" >>$@
	@echo "Description: $(PY-GNOSIS-UTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-GNOSIS-UTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GNOSIS-UTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GNOSIS-UTILS_IPK_DIR)/opt/sbin or $(PY-GNOSIS-UTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GNOSIS-UTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-GNOSIS-UTILS_IPK_DIR)/opt/etc/py-gnosis-utils/...
# Documentation files should be installed in $(PY-GNOSIS-UTILS_IPK_DIR)/opt/doc/py-gnosis-utils/...
# Daemon startup scripts should be installed in $(PY-GNOSIS-UTILS_IPK_DIR)/opt/etc/init.d/S??py-gnosis-utils
#
# You may need to patch your application to make it use these locations.
#
$(PY24-GNOSIS-UTILS_IPK) $(PY25-GNOSIS-UTILS_IPK): $(PY-GNOSIS-UTILS_BUILD_DIR)/.built
	# 2.4
	rm -rf $(PY24-GNOSIS-UTILS_IPK_DIR) $(BUILD_DIR)/py-gnosis-utils_*_$(TARGET_ARCH).ipk
	cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY24-GNOSIS-UTILS_IPK_DIR) --prefix=/opt
	$(MAKE) $(PY24-GNOSIS-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-GNOSIS-UTILS_IPK_DIR)
	# 2.5
	rm -rf $(PY25-GNOSIS-UTILS_IPK_DIR) $(BUILD_DIR)/py25-gnosis-utils_*_$(TARGET_ARCH).ipk
	cd $(PY-GNOSIS-UTILS_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY25-GNOSIS-UTILS_IPK_DIR) --prefix=/opt
#	for f in $(PY25-GNOSIS-UTILS_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-GNOSIS-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-GNOSIS-UTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-gnosis-utils-ipk: $(PY24-GNOSIS-UTILS_IPK) $(PY25-GNOSIS-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-gnosis-utils-clean:
	-$(MAKE) -C $(PY-GNOSIS-UTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-gnosis-utils-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GNOSIS-UTILS_DIR) $(PY-GNOSIS-UTILS_BUILD_DIR)
	rm -rf $(PY24-GNOSIS-UTILS_IPK_DIR) $(PY24-GNOSIS-UTILS_IPK)
	rm -rf $(PY25-GNOSIS-UTILS_IPK_DIR) $(PY25-GNOSIS-UTILS_IPK)

#
# Some sanity check for the package.
#
py-gnosis-utils-check: $(PY24-GNOSIS-UTILS_IPK) $(PY25-GNOSIS-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-GNOSIS-UTILS_IPK) $(PY25-GNOSIS-UTILS_IPK)
