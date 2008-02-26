###########################################################
#
# py-cherrypy
#
###########################################################

#
# PY-CHERRYPY_VERSION, PY-CHERRYPY_SITE and PY-CHERRYPY_SOURCE define
# the upstream location of the source code for the package.
# PY-CHERRYPY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CHERRYPY_UNZIP is the command used to unzip the source.
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
PY-CHERRYPY_VERSION=2.3.0
PY-CHERRYPY_SITE=http://download.cherrypy.org/cherrypy/$(PY-CHERRYPY_VERSION)
PY-CHERRYPY_SOURCE=CherryPy-$(PY-CHERRYPY_VERSION).tar.gz
PY-CHERRYPY_DIR=CherryPy-$(PY-CHERRYPY_VERSION)
PY-CHERRYPY_UNZIP=zcat
PY-CHERRYPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CHERRYPY_DESCRIPTION=A pythonic, object-oriented web development framework.
PY-CHERRYPY_SECTION=web
PY-CHERRYPY_PRIORITY=optional
PY24-CHERRYPY_DEPENDS=python24
PY25-CHERRYPY_DEPENDS=python25
PY-CHERRYPY_CONFLICTS=

#
# PY-CHERRYPY_IPK_VERSION should be incremented when the ipk changes.
#
PY-CHERRYPY_IPK_VERSION=1

#
# PY-CHERRYPY_CONFFILES should be a list of user-editable files
#PY-CHERRYPY_CONFFILES=/opt/etc/py-cherrypy.conf /opt/etc/init.d/SXXpy-cherrypy

#
# PY-CHERRYPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CHERRYPY_PATCHES=$(PY-CHERRYPY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CHERRYPY_CPPFLAGS=
PY-CHERRYPY_LDFLAGS=

#
# PY-CHERRYPY_BUILD_DIR is the directory in which the build is done.
# PY-CHERRYPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CHERRYPY_IPK_DIR is the directory in which the ipk is built.
# PY-CHERRYPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CHERRYPY_BUILD_DIR=$(BUILD_DIR)/py-cherrypy
PY-CHERRYPY_SOURCE_DIR=$(SOURCE_DIR)/py-cherrypy

PY24-CHERRYPY_IPK_DIR=$(BUILD_DIR)/py24-cherrypy-$(PY-CHERRYPY_VERSION)-ipk
PY24-CHERRYPY_IPK=$(BUILD_DIR)/py24-cherrypy_$(PY-CHERRYPY_VERSION)-$(PY-CHERRYPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CHERRYPY_IPK_DIR=$(BUILD_DIR)/py25-cherrypy-$(PY-CHERRYPY_VERSION)-ipk
PY25-CHERRYPY_IPK=$(BUILD_DIR)/py25-cherrypy_$(PY-CHERRYPY_VERSION)-$(PY-CHERRYPY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CHERRYPY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CHERRYPY_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cherrypy-source: $(DL_DIR)/$(PY-CHERRYPY_SOURCE) $(PY-CHERRYPY_PATCHES)

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
$(PY-CHERRYPY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CHERRYPY_SOURCE) $(PY-CHERRYPY_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CHERRYPY_DIR) $(PY-CHERRYPY_BUILD_DIR)
	mkdir -p $(PY-CHERRYPY_BUILD_DIR)
	$(PY-CHERRYPY_UNZIP) $(DL_DIR)/$(PY-CHERRYPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHERRYPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHERRYPY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHERRYPY_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") > setup.cfg \
	)
	$(PY-CHERRYPY_UNZIP) $(DL_DIR)/$(PY-CHERRYPY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHERRYPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHERRYPY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHERRYPY_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") > setup.cfg \
	)
	touch $@

py-cherrypy-unpack: $(PY-CHERRYPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CHERRYPY_BUILD_DIR)/.built: $(PY-CHERRYPY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" build)
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build)
	touch $@

#
# This is the build convenience target.
#
py-cherrypy: $(PY-CHERRYPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CHERRYPY_BUILD_DIR)/.staged: $(PY-CHERRYPY_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(STAGING_DIR) --prefix=/opt)
	touch $@

py-cherrypy-stage: $(PY-CHERRYPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cherrypy
#
$(PY24-CHERRYPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-cherrypy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHERRYPY_PRIORITY)" >>$@
	@echo "Section: $(PY-CHERRYPY_SECTION)" >>$@
	@echo "Version: $(PY-CHERRYPY_VERSION)-$(PY-CHERRYPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHERRYPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHERRYPY_SITE)/$(PY-CHERRYPY_SOURCE)" >>$@
	@echo "Description: $(PY-CHERRYPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CHERRYPY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHERRYPY_CONFLICTS)" >>$@

$(PY25-CHERRYPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-cherrypy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHERRYPY_PRIORITY)" >>$@
	@echo "Section: $(PY-CHERRYPY_SECTION)" >>$@
	@echo "Version: $(PY-CHERRYPY_VERSION)-$(PY-CHERRYPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHERRYPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHERRYPY_SITE)/$(PY-CHERRYPY_SOURCE)" >>$@
	@echo "Description: $(PY-CHERRYPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CHERRYPY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHERRYPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CHERRYPY_IPK_DIR)/opt/sbin or $(PY-CHERRYPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CHERRYPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CHERRYPY_IPK_DIR)/opt/etc/py-cherrypy/...
# Documentation files should be installed in $(PY-CHERRYPY_IPK_DIR)/opt/doc/py-cherrypy/...
# Daemon startup scripts should be installed in $(PY-CHERRYPY_IPK_DIR)/opt/etc/init.d/S??py-cherrypy
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CHERRYPY_IPK): $(PY-CHERRYPY_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-cherrypy_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-CHERRYPY_IPK_DIR) $(BUILD_DIR)/py24-cherrypy_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHERRYPY_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY24-CHERRYPY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-CHERRYPY_IPK_DIR)/CONTROL/control
	echo $(PY-CHERRYPY_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-CHERRYPY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CHERRYPY_IPK_DIR)

$(PY25-CHERRYPY_IPK): $(PY-CHERRYPY_BUILD_DIR)/.built
	rm -rf $(PY25-CHERRYPY_IPK_DIR) $(BUILD_DIR)/py25-cherrypy_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHERRYPY_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY25-CHERRYPY_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-CHERRYPY_IPK_DIR)/CONTROL/control
	echo $(PY-CHERRYPY_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-CHERRYPY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CHERRYPY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cherrypy-ipk: $(PY24-CHERRYPY_IPK) $(PY25-CHERRYPY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cherrypy-clean:
	-$(MAKE) -C $(PY-CHERRYPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cherrypy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CHERRYPY_DIR) $(PY-CHERRYPY_BUILD_DIR) \
	$(PY24-CHERRYPY_IPK_DIR) $(PY24-CHERRYPY_IPK) \
	$(PY25-CHERRYPY_IPK_DIR) $(PY25-CHERRYPY_IPK) \

#
# Some sanity check for the package.
#
py-cherrypy-check: $(PY24-CHERRYPY_IPK) $(PY25-CHERRYPY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-CHERRYPY_IPK) $(PY25-CHERRYPY_IPK)
