###########################################################
#
# py-twisted
#
###########################################################

#
# PY-TWISTED_VERSION, PY-TWISTED_SITE and PY-TWISTED_SOURCE define
# the upstream location of the source code for the package.
# PY-TWISTED_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TWISTED_UNZIP is the command used to unzip the source.
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
PY-TWISTED_VERSION=8.2.0
PY-TWISTED_SITE=http://tmrc.mit.edu/mirror/twisted/Twisted/8.2
PY-TWISTED_SOURCE=Twisted-$(PY-TWISTED_VERSION).tar.bz2
PY-TWISTED_DIR=Twisted-$(PY-TWISTED_VERSION)
PY-TWISTED_UNZIP=bzcat
PY-TWISTED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TWISTED_DESCRIPTION=A networking engine written in Python.
PY-TWISTED_SECTION=misc
PY-TWISTED_PRIORITY=optional
PY24-TWISTED_DEPENDS=python24, py24-zope-interface
PY25-TWISTED_DEPENDS=python25, py25-zope-interface
PY26-TWISTED_DEPENDS=python26, py26-zope-interface
PY-TWISTED_CONFLICTS=

#
# PY-TWISTED_IPK_VERSION should be incremented when the ipk changes.
#
PY-TWISTED_IPK_VERSION=1

#
# PY-TWISTED_CONFFILES should be a list of user-editable files
#PY-TWISTED_CONFFILES=/opt/etc/py-twisted.conf /opt/etc/init.d/SXXpy-twisted

#
# PY-TWISTED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TWISTED_PATCHES=$(PY-TWISTED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TWISTED_CPPFLAGS=
PY-TWISTED_LDFLAGS=

#
# PY-TWISTED_BUILD_DIR is the directory in which the build is done.
# PY-TWISTED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TWISTED_IPK_DIR is the directory in which the ipk is built.
# PY-TWISTED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TWISTED_BUILD_DIR=$(BUILD_DIR)/py-twisted
PY-TWISTED_SOURCE_DIR=$(SOURCE_DIR)/py-twisted

PY24-TWISTED_IPK_DIR=$(BUILD_DIR)/py24-twisted-$(PY-TWISTED_VERSION)-ipk
PY24-TWISTED_IPK=$(BUILD_DIR)/py24-twisted_$(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TWISTED_IPK_DIR=$(BUILD_DIR)/py25-twisted-$(PY-TWISTED_VERSION)-ipk
PY25-TWISTED_IPK=$(BUILD_DIR)/py25-twisted_$(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-TWISTED_IPK_DIR=$(BUILD_DIR)/py26-twisted-$(PY-TWISTED_VERSION)-ipk
PY26-TWISTED_IPK=$(BUILD_DIR)/py26-twisted_$(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-twisted-source py-twisted-unpack py-twisted py-twisted-stage py-twisted-ipk py-twisted-clean py-twisted-dirclean py-twisted-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TWISTED_SOURCE):
	$(WGET) -P $(@D) $(PY-TWISTED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-twisted-source: $(DL_DIR)/$(PY-TWISTED_SOURCE) $(PY-TWISTED_PATCHES)

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
$(PY-TWISTED_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TWISTED_SOURCE) $(PY-TWISTED_PATCHES) make/py-twisted.mk
	$(MAKE) py-zope-interface-stage py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-TWISTED_DIR) $(@D)
	mkdir -p $(PY-TWISTED_BUILD_DIR)
	$(PY-TWISTED_UNZIP) $(DL_DIR)/$(PY-TWISTED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TWISTED_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TWISTED_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TWISTED_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
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
	$(PY-TWISTED_UNZIP) $(DL_DIR)/$(PY-TWISTED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TWISTED_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TWISTED_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TWISTED_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
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
	$(PY-TWISTED_UNZIP) $(DL_DIR)/$(PY-TWISTED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TWISTED_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TWISTED_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TWISTED_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
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
	touch $@

py-twisted-unpack: $(PY-TWISTED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TWISTED_BUILD_DIR)/.built: $(PY-TWISTED_BUILD_DIR)/.configured
	rm -f $@
	rm -rf $(STAGING_LIB_DIR)/python2.4/site-packages/twisted
	(cd $(@D)/2.4; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.4/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" build)
	rm -rf $(STAGING_LIB_DIR)/python2.5/site-packages/twisted
	(cd $(@D)/2.5; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.5/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build)
	rm -rf $(STAGING_LIB_DIR)/python2.6/site-packages/twisted
	(cd $(@D)/2.6; \
		PYTHONPATH="$(STAGING_LIB_DIR)/python2.6/site-packages" \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" build)
	touch $@

#
# This is the build convenience target.
#
py-twisted: $(PY-TWISTED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TWISTED_BUILD_DIR)/.staged: $(PY-TWISTED_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.4; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.5; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	touch $@

py-twisted-stage: $(PY-TWISTED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-twisted
#
$(PY24-TWISTED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-twisted" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TWISTED_PRIORITY)" >>$@
	@echo "Section: $(PY-TWISTED_SECTION)" >>$@
	@echo "Version: $(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TWISTED_MAINTAINER)" >>$@
	@echo "Source: $(PY-TWISTED_SITE)/$(PY-TWISTED_SOURCE)" >>$@
	@echo "Description: $(PY-TWISTED_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TWISTED_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TWISTED_CONFLICTS)" >>$@

$(PY25-TWISTED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-twisted" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TWISTED_PRIORITY)" >>$@
	@echo "Section: $(PY-TWISTED_SECTION)" >>$@
	@echo "Version: $(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TWISTED_MAINTAINER)" >>$@
	@echo "Source: $(PY-TWISTED_SITE)/$(PY-TWISTED_SOURCE)" >>$@
	@echo "Description: $(PY-TWISTED_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TWISTED_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TWISTED_CONFLICTS)" >>$@

$(PY26-TWISTED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-twisted" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TWISTED_PRIORITY)" >>$@
	@echo "Section: $(PY-TWISTED_SECTION)" >>$@
	@echo "Version: $(PY-TWISTED_VERSION)-$(PY-TWISTED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TWISTED_MAINTAINER)" >>$@
	@echo "Source: $(PY-TWISTED_SITE)/$(PY-TWISTED_SOURCE)" >>$@
	@echo "Description: $(PY-TWISTED_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TWISTED_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TWISTED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TWISTED_IPK_DIR)/opt/sbin or $(PY-TWISTED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TWISTED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TWISTED_IPK_DIR)/opt/etc/py-twisted/...
# Documentation files should be installed in $(PY-TWISTED_IPK_DIR)/opt/doc/py-twisted/...
# Daemon startup scripts should be installed in $(PY-TWISTED_IPK_DIR)/opt/etc/init.d/S??py-twisted
#
# You may need to patch your application to make it use these locations.
#
$(PY24-TWISTED_IPK): $(PY-TWISTED_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-twisted_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-TWISTED_IPK_DIR) $(BUILD_DIR)/py24-twisted_*_$(TARGET_ARCH).ipk
	(cd $(PY-TWISTED_BUILD_DIR)/2.4; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-TWISTED_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY24-TWISTED_IPK_DIR)/opt/lib -name '*.so'`
	for f in $(PY24-TWISTED_IPK_DIR)/opt/*bin/*; \
	    do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-TWISTED_IPK_DIR)/CONTROL/control
	echo $(PY-TWISTED_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-TWISTED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TWISTED_IPK_DIR)

$(PY25-TWISTED_IPK): $(PY-TWISTED_BUILD_DIR)/.built
	rm -rf $(PY25-TWISTED_IPK_DIR) $(BUILD_DIR)/py25-twisted_*_$(TARGET_ARCH).ipk
	(cd $(PY-TWISTED_BUILD_DIR)/2.5; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-TWISTED_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY25-TWISTED_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY25-TWISTED_IPK_DIR)/CONTROL/control
	echo $(PY-TWISTED_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-TWISTED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TWISTED_IPK_DIR)

$(PY26-TWISTED_IPK): $(PY-TWISTED_BUILD_DIR)/.built
	rm -rf $(PY26-TWISTED_IPK_DIR) $(BUILD_DIR)/py26-twisted_*_$(TARGET_ARCH).ipk
	(cd $(PY-TWISTED_BUILD_DIR)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-TWISTED_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY26-TWISTED_IPK_DIR)/opt/lib -name '*.so'`
	for f in $(PY26-TWISTED_IPK_DIR)/opt/*bin/*; \
	    do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	$(MAKE) $(PY26-TWISTED_IPK_DIR)/CONTROL/control
	echo $(PY-TWISTED_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-TWISTED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-TWISTED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-twisted-ipk: $(PY24-TWISTED_IPK) $(PY25-TWISTED_IPK) $(PY26-TWISTED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-twisted-clean:
	-$(MAKE) -C $(PY-TWISTED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-twisted-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TWISTED_DIR) $(PY-TWISTED_BUILD_DIR) \
	$(PY24-TWISTED_IPK_DIR) $(PY24-TWISTED_IPK) \
	$(PY25-TWISTED_IPK_DIR) $(PY25-TWISTED_IPK) \
	$(PY26-TWISTED_IPK_DIR) $(PY26-TWISTED_IPK) \

#
# Some sanity check for the package.
#
py-twisted-check: $(PY24-TWISTED_IPK) $(PY25-TWISTED_IPK) $(PY26-TWISTED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
