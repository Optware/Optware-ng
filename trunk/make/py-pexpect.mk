###########################################################
#
# py-pexpect
#
###########################################################

#
# PY-PEXPECT_VERSION, PY-PEXPECT_SITE and PY-PEXPECT_SOURCE define
# the upstream location of the source code for the package.
# PY-PEXPECT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PEXPECT_UNZIP is the command used to unzip the source.
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
PY-PEXPECT_SITE=http://pypi.python.org/packages/source/p/pexpect
PY-PEXPECT_VERSION=2.4
PY-PEXPECT_SOURCE=pexpect-$(PY-PEXPECT_VERSION).tar.gz
PY-PEXPECT_DIR=pexpect-$(PY-PEXPECT_VERSION)
PY-PEXPECT_UNZIP=zcat
PY-PEXPECT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PEXPECT_DESCRIPTION=Python module for automating interactive applications.
PY-PEXPECT_SECTION=misc
PY-PEXPECT_PRIORITY=optional
PY24-PEXPECT_DEPENDS=python24
PY25-PEXPECT_DEPENDS=python25
PY-PEXPECT_CONFLICTS=

#
# PY-PEXPECT_IPK_VERSION should be incremented when the ipk changes.
#
PY-PEXPECT_IPK_VERSION=1

#
# PY-PEXPECT_CONFFILES should be a list of user-editable files
#PY-PEXPECT_CONFFILES=/opt/etc/py-pexpect.conf /opt/etc/init.d/SXXpy-pexpect

#
# PY-PEXPECT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PEXPECT_PATCHES=$(PY-PEXPECT_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PEXPECT_CPPFLAGS=
PY-PEXPECT_LDFLAGS=

#
# PY-PEXPECT_BUILD_DIR is the directory in which the build is done.
# PY-PEXPECT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PEXPECT_IPK_DIR is the directory in which the ipk is built.
# PY-PEXPECT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PEXPECT_BUILD_DIR=$(BUILD_DIR)/py-pexpect
PY-PEXPECT_SOURCE_DIR=$(SOURCE_DIR)/py-pexpect
PY24-PEXPECT_IPK_DIR=$(BUILD_DIR)/py24-pexpect-$(PY-PEXPECT_VERSION)-ipk
PY24-PEXPECT_IPK=$(BUILD_DIR)/py24-pexpect_$(PY-PEXPECT_VERSION)-$(PY-PEXPECT_IPK_VERSION)_$(TARGET_ARCH).ipk
PY25-PEXPECT_IPK_DIR=$(BUILD_DIR)/py25-pexpect-$(PY-PEXPECT_VERSION)-ipk
PY25-PEXPECT_IPK=$(BUILD_DIR)/py25-pexpect_$(PY-PEXPECT_VERSION)-$(PY-PEXPECT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PEXPECT_SOURCE):
	$(WGET) -P $(@D) $(PY-PEXPECT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pexpect-source: $(DL_DIR)/$(PY-PEXPECT_SOURCE) $(PY-PEXPECT_PATCHES)

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
$(PY-PEXPECT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PEXPECT_SOURCE) $(PY-PEXPECT_PATCHES) make/py-pexpect.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PEXPECT_DIR)
	$(PY-PEXPECT_UNZIP) $(DL_DIR)/$(PY-PEXPECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PEXPECT_PATCHES)"; then \
	    cat $(PY-PEXPECT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PEXPECT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PEXPECT_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PEXPECT_DIR)
	$(PY-PEXPECT_UNZIP) $(DL_DIR)/$(PY-PEXPECT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PEXPECT_PATCHES)"; then \
	    cat $(PY-PEXPECT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PEXPECT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PEXPECT_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	)
	touch $@

py-pexpect-unpack: $(PY-PEXPECT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PEXPECT_BUILD_DIR)/.built: $(PY-PEXPECT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-pexpect: $(PY-PEXPECT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-PEXPECT_BUILD_DIR)/.staged: $(PY-PEXPECT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-PEXPECT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-pexpect-stage: $(PY-PEXPECT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pexpect
#
$(PY24-PEXPECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-pexpect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PEXPECT_PRIORITY)" >>$@
	@echo "Section: $(PY-PEXPECT_SECTION)" >>$@
	@echo "Version: $(PY-PEXPECT_VERSION)-$(PY-PEXPECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PEXPECT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PEXPECT_SITE)/$(PY-PEXPECT_SOURCE)" >>$@
	@echo "Description: $(PY-PEXPECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PEXPECT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PEXPECT_CONFLICTS)" >>$@

$(PY25-PEXPECT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pexpect" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PEXPECT_PRIORITY)" >>$@
	@echo "Section: $(PY-PEXPECT_SECTION)" >>$@
	@echo "Version: $(PY-PEXPECT_VERSION)-$(PY-PEXPECT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PEXPECT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PEXPECT_SITE)/$(PY-PEXPECT_SOURCE)" >>$@
	@echo "Description: $(PY-PEXPECT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PEXPECT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PEXPECT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PEXPECT_IPK_DIR)/opt/sbin or $(PY-PEXPECT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PEXPECT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PEXPECT_IPK_DIR)/opt/etc/py-pexpect/...
# Documentation files should be installed in $(PY-PEXPECT_IPK_DIR)/opt/doc/py-pexpect/...
# Daemon startup scripts should be installed in $(PY-PEXPECT_IPK_DIR)/opt/etc/init.d/S??py-pexpect
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PEXPECT_IPK): $(PY-PEXPECT_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-pexpect_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-PEXPECT_IPK_DIR) $(BUILD_DIR)/py24-pexpect_*_$(TARGET_ARCH).ipk
	(cd $(PY-PEXPECT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY24-PEXPECT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PEXPECT_IPK_DIR)/CONTROL/control
#	echo $(PY-PEXPECT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PEXPECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PEXPECT_IPK_DIR)

$(PY25-PEXPECT_IPK): $(PY-PEXPECT_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-pexpect_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-PEXPECT_IPK_DIR) $(BUILD_DIR)/py25-pexpect_*_$(TARGET_ARCH).ipk
	(cd $(PY-PEXPECT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY25-PEXPECT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PEXPECT_IPK_DIR)/CONTROL/control
#	echo $(PY-PEXPECT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PEXPECT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PEXPECT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pexpect-ipk: $(PY24-PEXPECT_IPK) $(PY25-PEXPECT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pexpect-clean:
	-$(MAKE) -C $(PY-PEXPECT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pexpect-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PEXPECT_DIR) $(PY-PEXPECT_BUILD_DIR)
	rm -rf $(PY24-PEXPECT_IPK_DIR) $(PY24-PEXPECT_IPK)
	rm -rf $(PY25-PEXPECT_IPK_DIR) $(PY25-PEXPECT_IPK)
