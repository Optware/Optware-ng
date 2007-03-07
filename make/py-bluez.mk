###########################################################
#
# py-bluez
#
###########################################################

#
# PY-BLUEZ_VERSION, PY-BLUEZ_SITE and PY-BLUEZ_SOURCE define
# the upstream location of the source code for the package.
# PY-BLUEZ_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BLUEZ_UNZIP is the command used to unzip the source.
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
PY-BLUEZ_SITE=http://org.csail.mit.edu/pybluez/release
PY-BLUEZ_VERSION=0.9.2
PY-BLUEZ_SOURCE=pybluez-src-$(PY-BLUEZ_VERSION).tar.gz
PY-BLUEZ_DIR=pybluez-$(PY-BLUEZ_VERSION)
PY-BLUEZ_UNZIP=zcat
PY-BLUEZ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BLUEZ_DESCRIPTION=Python wrappers around bluez.
PY-BLUEZ_SECTION=misc
PY-BLUEZ_PRIORITY=optional
PY24-BLUEZ_DEPENDS=python24, bluez-libs
PY25-BLUEZ_DEPENDS=python25, bluez-libs
PY-BLUEZ_CONFLICTS=

#
# PY-BLUEZ_IPK_VERSION should be incremented when the ipk changes.
#
PY-BLUEZ_IPK_VERSION=1

#
# PY-BLUEZ_CONFFILES should be a list of user-editable files
#PY-BLUEZ_CONFFILES=/opt/etc/py-bluez.conf /opt/etc/init.d/SXXpy-bluez

#
# PY-BLUEZ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BLUEZ_PATCHES=$(PY-BLUEZ_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BLUEZ_CPPFLAGS=
PY-BLUEZ_LDFLAGS=

#
# PY-BLUEZ_BUILD_DIR is the directory in which the build is done.
# PY-BLUEZ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BLUEZ_IPK_DIR is the directory in which the ipk is built.
# PY-BLUEZ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BLUEZ_BUILD_DIR=$(BUILD_DIR)/py-bluez
PY-BLUEZ_SOURCE_DIR=$(SOURCE_DIR)/py-bluez

PY24-BLUEZ_IPK_DIR=$(BUILD_DIR)/py-bluez-$(PY-BLUEZ_VERSION)-ipk
PY24-BLUEZ_IPK=$(BUILD_DIR)/py-bluez_$(PY-BLUEZ_VERSION)-$(PY-BLUEZ_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-BLUEZ_IPK_DIR=$(BUILD_DIR)/py25-bluez-$(PY-BLUEZ_VERSION)-ipk
PY25-BLUEZ_IPK=$(BUILD_DIR)/py25-bluez_$(PY-BLUEZ_VERSION)-$(PY-BLUEZ_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-bluez-source py-bluez-unpack py-bluez py-bluez-stage py-bluez-ipk py-bluez-clean py-bluez-dirclean py-bluez-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BLUEZ_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-BLUEZ_SITE)/$(PY-BLUEZ_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-bluez-source: $(DL_DIR)/$(PY-BLUEZ_SOURCE) $(PY-BLUEZ_PATCHES)

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
$(PY-BLUEZ_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BLUEZ_SOURCE) $(PY-BLUEZ_PATCHES)
	$(MAKE) python-stage bluez-libs-stage
	rm -rf $(PY-BLUEZ_BUILD_DIR)
	mkdir -p $(PY-BLUEZ_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-BLUEZ_DIR)
	$(PY-BLUEZ_UNZIP) $(DL_DIR)/$(PY-BLUEZ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-BLUEZ_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BLUEZ_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BLUEZ_DIR) $(PY-BLUEZ_BUILD_DIR)/2.4
	(cd $(PY-BLUEZ_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
		echo "[install]"; \
		echo "install_scripts=/opt/bin" \
	    ) > setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-BLUEZ_DIR)
	$(PY-BLUEZ_UNZIP) $(DL_DIR)/$(PY-BLUEZ_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-BLUEZ_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BLUEZ_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BLUEZ_DIR) $(PY-BLUEZ_BUILD_DIR)/2.5
	(cd $(PY-BLUEZ_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
		echo "[install]"; \
		echo "install_scripts=/opt/bin" \
	    ) > setup.cfg; \
	)
	touch $@

py-bluez-unpack: $(PY-BLUEZ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BLUEZ_BUILD_DIR)/.built: $(PY-BLUEZ_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-BLUEZ_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-BLUEZ_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-bluez: $(PY-BLUEZ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BLUEZ_BUILD_DIR)/.staged: $(PY-BLUEZ_BUILD_DIR)/.built
	rm -f $(PY-BLUEZ_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-BLUEZ_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-BLUEZ_BUILD_DIR)/.staged

py-bluez-stage: $(PY-BLUEZ_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-bluez
#
$(PY24-BLUEZ_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-bluez" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BLUEZ_PRIORITY)" >>$@
	@echo "Section: $(PY-BLUEZ_SECTION)" >>$@
	@echo "Version: $(PY-BLUEZ_VERSION)-$(PY-BLUEZ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BLUEZ_MAINTAINER)" >>$@
	@echo "Source: $(PY-BLUEZ_SITE)/$(PY-BLUEZ_SOURCE)" >>$@
	@echo "Description: $(PY-BLUEZ_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-BLUEZ_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BLUEZ_CONFLICTS)" >>$@

$(PY25-BLUEZ_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bluez" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BLUEZ_PRIORITY)" >>$@
	@echo "Section: $(PY-BLUEZ_SECTION)" >>$@
	@echo "Version: $(PY-BLUEZ_VERSION)-$(PY-BLUEZ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BLUEZ_MAINTAINER)" >>$@
	@echo "Source: $(PY-BLUEZ_SITE)/$(PY-BLUEZ_SOURCE)" >>$@
	@echo "Description: $(PY-BLUEZ_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BLUEZ_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BLUEZ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BLUEZ_IPK_DIR)/opt/sbin or $(PY-BLUEZ_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BLUEZ_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BLUEZ_IPK_DIR)/opt/etc/py-bluez/...
# Documentation files should be installed in $(PY-BLUEZ_IPK_DIR)/opt/doc/py-bluez/...
# Daemon startup scripts should be installed in $(PY-BLUEZ_IPK_DIR)/opt/etc/init.d/S??py-bluez
#
# You may need to patch your application to make it use these locations.
#
$(PY24-BLUEZ_IPK): $(PY-BLUEZ_BUILD_DIR)/.built
	rm -rf $(PY24-BLUEZ_IPK_DIR) $(BUILD_DIR)/py-bluez_*_$(TARGET_ARCH).ipk
	(cd $(PY-BLUEZ_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-BLUEZ_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-BLUEZ_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY24-BLUEZ_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-BLUEZ_IPK_DIR)

$(PY25-BLUEZ_IPK): $(PY-BLUEZ_BUILD_DIR)/.built
	rm -rf $(PY25-BLUEZ_IPK_DIR) $(BUILD_DIR)/py25-bluez_*_$(TARGET_ARCH).ipk
	(cd $(PY-BLUEZ_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-BLUEZ_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-BLUEZ_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-BLUEZ_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BLUEZ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-bluez-ipk: $(PY24-BLUEZ_IPK) $(PY25-BLUEZ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-bluez-clean:
	-$(MAKE) -C $(PY-BLUEZ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-bluez-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BLUEZ_DIR) $(PY-BLUEZ_BUILD_DIR)
	rm -rf $(PY24-BLUEZ_IPK_DIR) $(PY24-BLUEZ_IPK)
	rm -rf $(PY25-BLUEZ_IPK_DIR) $(PY25-BLUEZ_IPK)

#
# Some sanity check for the package.
#
py-bluez-check: $(PY24-BLUEZ_IPK) $(PY25-BLUEZ_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-BLUEZ_IPK) $(PY25-BLUEZ_IPK)
