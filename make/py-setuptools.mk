###########################################################
#
# py-setuptools
#
###########################################################

#
# PY-SETUPTOOLS_VERSION, PY-SETUPTOOLS_SITE and PY-SETUPTOOLS_SOURCE define
# the upstream location of the source code for the package.
# PY-SETUPTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SETUPTOOLS_UNZIP is the command used to unzip the source.
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
PY-SETUPTOOLS_SITE=http://cheeseshop.python.org/packages/source/s/setuptools
PY-SETUPTOOLS_VERSION=0.6c4
PY-SETUPTOOLS_SOURCE=setuptools-$(PY-SETUPTOOLS_VERSION).tar.gz
PY-SETUPTOOLS_DIR=setuptools-$(PY-SETUPTOOLS_VERSION)
PY-SETUPTOOLS_UNZIP=zcat
PY-SETUPTOOLS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SETUPTOOLS_DESCRIPTION=Tool to build and distribute Python packages, enhancement to distutils.
PY-SETUPTOOLS_SECTION=misc
PY-SETUPTOOLS_PRIORITY=optional
PY24-SETUPTOOLS_DEPENDS=python24
PY25-SETUPTOOLS_DEPENDS=python25
PY-SETUPTOOLS_CONFLICTS=

#
# PY-SETUPTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
PY-SETUPTOOLS_IPK_VERSION=1

#
# PY-SETUPTOOLS_CONFFILES should be a list of user-editable files
#PY-SETUPTOOLS_CONFFILES=/opt/etc/py-setuptools.conf /opt/etc/init.d/SXXpy-setuptools

#
# PY-SETUPTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SETUPTOOLS_PATCHES=$(PY-SETUPTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SETUPTOOLS_CPPFLAGS=
PY-SETUPTOOLS_LDFLAGS=

#
# PY-SETUPTOOLS_BUILD_DIR is the directory in which the build is done.
# PY-SETUPTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SETUPTOOLS_IPK_DIR is the directory in which the ipk is built.
# PY-SETUPTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SETUPTOOLS_SOURCE_DIR=$(SOURCE_DIR)/py-setuptools
PY-SETUPTOOLS_BUILD_DIR=$(BUILD_DIR)/py-setuptools

PY24-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py-setuptools-$(PY-SETUPTOOLS_VERSION)-ipk
PY24-SETUPTOOLS_IPK=$(BUILD_DIR)/py-setuptools_$(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-SETUPTOOLS_IPK_DIR=$(BUILD_DIR)/py25-setuptools-$(PY-SETUPTOOLS_VERSION)-ipk
PY25-SETUPTOOLS_IPK=$(BUILD_DIR)/py25-setuptools_$(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-setuptools-source py-setuptools-unpack py-setuptools py-setuptools-stage py-setuptools-ipk py-setuptools-clean py-setuptools-dirclean py-setuptools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SETUPTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-setuptools-source: $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) $(PY-SETUPTOOLS_PATCHES)

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
$(PY-SETUPTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) $(PY-SETUPTOOLS_PATCHES) make/py-setuptools.mk
	$(MAKE) python24-host-stage
	$(MAKE) python25-host-stage
	$(MAKE) python24-stage
	$(MAKE) python25-stage
	rm -rf $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(PY-SETUPTOOLS_BUILD_DIR)
	mkdir -p $(PY-SETUPTOOLS_BUILD_DIR)/
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(PY-SETUPTOOLS_BUILD_DIR)/2.4
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.4; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = /opt/bin"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE)
	$(PY-SETUPTOOLS_UNZIP) $(DL_DIR)/$(PY-SETUPTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SETUPTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(PY-SETUPTOOLS_BUILD_DIR)/2.5
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.5; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = /opt/bin"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
	    ) >> setup.cfg \
	)
	touch $(PY-SETUPTOOLS_BUILD_DIR)/.configured

py-setuptools-unpack: $(PY-SETUPTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SETUPTOOLS_BUILD_DIR)/.built: $(PY-SETUPTOOLS_BUILD_DIR)/.configured
	rm -f $(PY-SETUPTOOLS_BUILD_DIR)/.built
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.4; $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.5; $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-SETUPTOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-setuptools: $(PY-SETUPTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SETUPTOOLS_BUILD_DIR)/.staged: $(PY-SETUPTOOLS_BUILD_DIR)/.built
	rm -f $(PY-SETUPTOOLS_BUILD_DIR)/.staged
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/setuptools*
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.4; \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/setuptools*
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.5; \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	touch $(PY-SETUPTOOLS_BUILD_DIR)/.staged

py-setuptools-stage: $(PY-SETUPTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-setuptools
#
$(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(PY24-SETUPTOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

$(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(PY25-SETUPTOOLS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py25-setuptools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SETUPTOOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-SETUPTOOLS_SECTION)" >>$@
	@echo "Version: $(PY-SETUPTOOLS_VERSION)-$(PY-SETUPTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SETUPTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-SETUPTOOLS_SITE)/$(PY-SETUPTOOLS_SOURCE)" >>$@
	@echo "Description: $(PY-SETUPTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SETUPTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SETUPTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SETUPTOOLS_IPK_DIR)/opt/sbin or $(PY-SETUPTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SETUPTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SETUPTOOLS_IPK_DIR)/opt/etc/py-setuptools/...
# Documentation files should be installed in $(PY-SETUPTOOLS_IPK_DIR)/opt/doc/py-setuptools/...
# Daemon startup scripts should be installed in $(PY-SETUPTOOLS_IPK_DIR)/opt/etc/init.d/S??py-setuptools
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY24-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-SETUPTOOLS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SETUPTOOLS_IPK_DIR)

$(PY25-SETUPTOOLS_IPK): $(PY-SETUPTOOLS_BUILD_DIR)/.built
	$(MAKE) py-setuptools-stage
	rm -rf $(PY25-SETUPTOOLS_IPK_DIR) $(BUILD_DIR)/py25-setuptools_*_$(TARGET_ARCH).ipk
	(cd $(PY-SETUPTOOLS_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-SETUPTOOLS_IPK_DIR) --prefix=/opt)
	rm -f $(PY25-SETUPTOOLS_IPK_DIR)/opt/bin/easy_install
	$(MAKE) $(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/control
	echo $(PY-SETUPTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SETUPTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SETUPTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-setuptools-ipk: $(PY24-SETUPTOOLS_IPK) $(PY25-SETUPTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-setuptools-clean:
	-$(MAKE) -C $(PY-SETUPTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-setuptools-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SETUPTOOLS_DIR) $(PY-SETUPTOOLS_BUILD_DIR) \
	$(PY24-SETUPTOOLS_IPK_DIR) $(PY24-SETUPTOOLS_IPK) \
	$(PY25-SETUPTOOLS_IPK_DIR) $(PY25-SETUPTOOLS_IPK) \

#
# Some sanity check for the package.
#
py-setuptools-check: $(PY24-SETUPTOOLS_IPK) $(PY25-SETUPTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-SETUPTOOLS_IPK) $(PY25-SETUPTOOLS_IPK)
