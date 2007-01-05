###########################################################
#
# py-zope-interface
#
###########################################################

#
# PY-ZOPE-INTERFACE_VERSION, PY-ZOPE-INTERFACE_SITE and PY-ZOPE-INTERFACE_SOURCE define
# the upstream location of the source code for the package.
# PY-ZOPE-INTERFACE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-ZOPE-INTERFACE_UNZIP is the command used to unzip the source.
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
PY-ZOPE-INTERFACE_VERSION=3.3.0b2
PY-ZOPE-INTERFACE_SITE=http://cheeseshop.python.org/packages/source/z/zope.interface
PY-ZOPE-INTERFACE_SOURCE=zope.interface-$(PY-ZOPE-INTERFACE_VERSION).tar.gz
PY-ZOPE-INTERFACE_DIR=zope.interface-$(PY-ZOPE-INTERFACE_VERSION)
PY-ZOPE-INTERFACE_UNZIP=zcat
PY-ZOPE-INTERFACE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-ZOPE-INTERFACE_DESCRIPTION=A separate distribution of the zope.interface package used in Zope 3, along with the packages it depends on.
PY-ZOPE-INTERFACE_SECTION=misc
PY-ZOPE-INTERFACE_PRIORITY=optional
PY24-ZOPE-INTERFACE_DEPENDS=python24
PY25-ZOPE-INTERFACE_DEPENDS=python25
PY-ZOPE-INTERFACE_CONFLICTS=

#
# PY-ZOPE-INTERFACE_IPK_VERSION should be incremented when the ipk changes.
#
PY-ZOPE-INTERFACE_IPK_VERSION=1

#
# PY-ZOPE-INTERFACE_CONFFILES should be a list of user-editable files
#PY-ZOPE-INTERFACE_CONFFILES=/opt/etc/py-zope-interface.conf /opt/etc/init.d/SXXpy-zope-interface

#
# PY-ZOPE-INTERFACE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-ZOPE-INTERFACE_PATCHES=$(PY-ZOPE-INTERFACE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-ZOPE-INTERFACE_CPPFLAGS=
PY-ZOPE-INTERFACE_LDFLAGS=

#
# PY-ZOPE-INTERFACE_BUILD_DIR is the directory in which the build is done.
# PY-ZOPE-INTERFACE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-ZOPE-INTERFACE_IPK_DIR is the directory in which the ipk is built.
# PY-ZOPE-INTERFACE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-ZOPE-INTERFACE_BUILD_DIR=$(BUILD_DIR)/py-zope-interface
PY-ZOPE-INTERFACE_SOURCE_DIR=$(SOURCE_DIR)/py-zope-interface

PY24-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py-zope-interface-$(PY-ZOPE-INTERFACE_VERSION)-ipk
PY24-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py-zope-interface_$(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-ZOPE-INTERFACE_IPK_DIR=$(BUILD_DIR)/py25-zope-interface-$(PY-ZOPE-INTERFACE_VERSION)-ipk
PY25-ZOPE-INTERFACE_IPK=$(BUILD_DIR)/py25-zope-interface_$(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-zope-interface-source py-zope-interface-unpack py-zope-interface py-zope-interface-stage py-zope-interface-ipk py-zope-interface-clean py-zope-interface-dirclean py-zope-interface-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-zope-interface-source: $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) $(PY-ZOPE-INTERFACE_PATCHES)

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
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) $(PY-ZOPE-INTERFACE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(PY-ZOPE-INTERFACE_BUILD_DIR)
	mkdir -p $(PY-ZOPE-INTERFACE_BUILD_DIR)
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	$(PY-ZOPE-INTERFACE_UNZIP) $(DL_DIR)/$(PY-ZOPE-INTERFACE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-ZOPE-INTERFACE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured

py-zope-interface-unpack: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.built: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.configured
	rm -f $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5; \
	CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-zope-interface: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -f $(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	touch $(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged

py-zope-interface-stage: $(PY-ZOPE-INTERFACE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-zope-interface
#
$(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

$(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-zope-interface" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-ZOPE-INTERFACE_PRIORITY)" >>$@
	@echo "Section: $(PY-ZOPE-INTERFACE_SECTION)" >>$@
	@echo "Version: $(PY-ZOPE-INTERFACE_VERSION)-$(PY-ZOPE-INTERFACE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-ZOPE-INTERFACE_MAINTAINER)" >>$@
	@echo "Source: $(PY-ZOPE-INTERFACE_SITE)/$(PY-ZOPE-INTERFACE_SOURCE)" >>$@
	@echo "Description: $(PY-ZOPE-INTERFACE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-ZOPE-INTERFACE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-ZOPE-INTERFACE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/sbin or $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/etc/py-zope-interface/...
# Documentation files should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/doc/py-zope-interface/...
# Daemon startup scripts should be installed in $(PY-ZOPE-INTERFACE_IPK_DIR)/opt/etc/init.d/S??py-zope-interface
#
# You may need to patch your application to make it use these locations.
#
$(PY24-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY24-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-ZOPE-INTERFACE_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY24-ZOPE-INTERFACE_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-ZOPE-INTERFACE_IPK_DIR)

$(PY25-ZOPE-INTERFACE_IPK): $(PY-ZOPE-INTERFACE_BUILD_DIR)/.built
	rm -rf $(PY25-ZOPE-INTERFACE_IPK_DIR) $(BUILD_DIR)/py25-zope-interface_*_$(TARGET_ARCH).ipk
	(cd $(PY-ZOPE-INTERFACE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-ZOPE-INTERFACE_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY25-ZOPE-INTERFACE_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/control
	echo $(PY-ZOPE-INTERFACE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-ZOPE-INTERFACE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-ZOPE-INTERFACE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-zope-interface-ipk: $(PY24-ZOPE-INTERFACE_IPK) $(PY25-ZOPE-INTERFACE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-zope-interface-clean:
	-$(MAKE) -C $(PY-ZOPE-INTERFACE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-zope-interface-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-ZOPE-INTERFACE_DIR) $(PY-ZOPE-INTERFACE_BUILD_DIR) \
	$(PY24-ZOPE-INTERFACE_IPK_DIR) $(PY24-ZOPE-INTERFACE_IPK) \
	$(PY25-ZOPE-INTERFACE_IPK_DIR) $(PY25-ZOPE-INTERFACE_IPK)

#
# Some sanity check for the package.
#
py-zope-interface-check: $(PY24-ZOPE-INTERFACE_IPK) $(PY25-ZOPE-INTERFACE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-ZOPE-INTERFACE_IPK) $(PY24-ZOPE-INTERFACE_IPK)
