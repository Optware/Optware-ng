###########################################################
#
# py-reportlab
#
###########################################################

#
# PY-REPORTLAB_VERSION, PY-REPORTLAB_SITE and PY-REPORTLAB_SOURCE define
# the upstream location of the source code for the package.
# PY-REPORTLAB_DIR is the directory which is created when the source
# archive is unpacked.
# PY-REPORTLAB_UNZIP is the command used to unzip the source.
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
PY-REPORTLAB_SITE=http://www.reportlab.org/ftp
PY-REPORTLAB_VERSION=2.1
PY-REPORTLAB_SOURCE=ReportLab_2_1.tgz
PY-REPORTLAB_DIR=reportlab_2_1
PY-REPORTLAB_UNZIP=zcat
PY-REPORTLAB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-REPORTLAB_DESCRIPTION=An Open Source Python library for generating PDFs and graphics.
PY-REPORTLAB_SECTION=misc
PY-REPORTLAB_PRIORITY=optional
PY24-REPORTLAB_DEPENDS=python24, py-reportlab-common
PY25-REPORTLAB_DEPENDS=python25, py-reportlab-common
PY-REPORTLAB_CONFLICTS=

PY-REPORTLAB-ACCEL_SITE=http://www.reportlab.org/daily
PY-REPORTLAB-ACCEL_SOURCE=rl_accel-0.60-daily-unix.tgz
PY-REPORTLAB-ACCEL_DIR=rl_accel-0.60-20070606

#
# PY-REPORTLAB_IPK_VERSION should be incremented when the ipk changes.
#
PY-REPORTLAB_IPK_VERSION=2

#
# PY-REPORTLAB_CONFFILES should be a list of user-editable files
#PY-REPORTLAB_CONFFILES=/opt/etc/py-reportlab.conf /opt/etc/init.d/SXXpy-reportlab

#
# PY-REPORTLAB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-REPORTLAB_PATCHES=$(PY-REPORTLAB_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-REPORTLAB_CPPFLAGS=
PY-REPORTLAB_LDFLAGS=

#
# PY-REPORTLAB_BUILD_DIR is the directory in which the build is done.
# PY-REPORTLAB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-REPORTLAB_IPK_DIR is the directory in which the ipk is built.
# PY-REPORTLAB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-REPORTLAB_BUILD_DIR=$(BUILD_DIR)/py-reportlab
PY-REPORTLAB_SOURCE_DIR=$(SOURCE_DIR)/py-reportlab

PY-REPORTLAB-COMMON_IPK_DIR=$(BUILD_DIR)/py-reportlab-common-$(PY-REPORTLAB_VERSION)-ipk
PY-REPORTLAB-COMMON_IPK=$(BUILD_DIR)/py-reportlab-common_$(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-REPORTLAB_IPK_DIR=$(BUILD_DIR)/py-reportlab-$(PY-REPORTLAB_VERSION)-ipk
PY24-REPORTLAB_IPK=$(BUILD_DIR)/py-reportlab_$(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-REPORTLAB_IPK_DIR=$(BUILD_DIR)/py25-reportlab-$(PY-REPORTLAB_VERSION)-ipk
PY25-REPORTLAB_IPK=$(BUILD_DIR)/py25-reportlab_$(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-reportlab-source py-reportlab-unpack py-reportlab py-reportlab-stage py-reportlab-ipk py-reportlab-clean py-reportlab-dirclean py-reportlab-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-REPORTLAB_SOURCE):
	$(WGET) -P $(@D) $(PY-REPORTLAB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(PY-REPORTLAB-ACCEL_SOURCE):
	$(WGET) -P $(@D) $(PY-REPORTLAB-ACCEL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-reportlab-source: $(DL_DIR)/$(PY-REPORTLAB_SOURCE) $(PY-REPORTLAB_PATCHES)

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
$(PY-REPORTLAB_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-REPORTLAB_SOURCE) $(PY-REPORTLAB_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-REPORTLAB_BUILD_DIR)
	mkdir -p $(PY-REPORTLAB_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-REPORTLAB_DIR)
	$(PY-REPORTLAB_UNZIP) $(DL_DIR)/$(PY-REPORTLAB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-REPORTLAB_PATCHES)"; then \
	    cat $(PY-REPORTLAB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-REPORTLAB_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-REPORTLAB_DIR) $(@D)/2.4
	(cd $(@D)/2.4/reportlab; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	    sed -i -e 's|^package_path.*|package_path = pjoin("/opt/share", "reportlab")|' setup.py; \
	)
	cd $(@D)/2.4/reportlab; \
		tar -xvzf $(DL_DIR)/$(PY-REPORTLAB-ACCEL_SOURCE); \
		mv $(PY-REPORTLAB-ACCEL_DIR) rl_addons; \
		cp setup.cfg rl_addons/rl_accel/
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-REPORTLAB_DIR)
	$(PY-REPORTLAB_UNZIP) $(DL_DIR)/$(PY-REPORTLAB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-REPORTLAB_PATCHES)"; then \
	    cat $(PY-REPORTLAB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-REPORTLAB_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-REPORTLAB_DIR) $(@D)/2.5
	(cd $(@D)/2.5/reportlab; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	    sed -i -e 's|^package_path.*|package_path = pjoin("/opt/share", "reportlab")|' setup.py; \
	)
	cd $(@D)/2.5/reportlab; \
		tar -xvzf $(DL_DIR)/$(PY-REPORTLAB-ACCEL_SOURCE); \
		mv $(PY-REPORTLAB-ACCEL_DIR) rl_addons; \
		cp setup.cfg rl_addons/rl_accel/
	touch $@

py-reportlab-unpack: $(PY-REPORTLAB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-REPORTLAB_BUILD_DIR)/.built: $(PY-REPORTLAB_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4/reportlab; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5/reportlab; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-reportlab: $(PY-REPORTLAB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-REPORTLAB_BUILD_DIR)/.staged: $(PY-REPORTLAB_BUILD_DIR)/.built
#	rm -f $(PY-REPORTLAB_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-REPORTLAB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(PY-REPORTLAB_BUILD_DIR)/.staged
#
#py-reportlab-stage: $(PY-REPORTLAB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-reportlab
#
$(PY-REPORTLAB-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-reportlab-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REPORTLAB_PRIORITY)" >>$@
	@echo "Section: $(PY-REPORTLAB_SECTION)" >>$@
	@echo "Version: $(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REPORTLAB_MAINTAINER)" >>$@
	@echo "Source: $(PY-REPORTLAB_SITE)/$(PY-REPORTLAB_SOURCE)" >>$@
	@echo "Description: $(PY-REPORTLAB_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-REPORTLAB_CONFLICTS)" >>$@

$(PY24-REPORTLAB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-reportlab" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REPORTLAB_PRIORITY)" >>$@
	@echo "Section: $(PY-REPORTLAB_SECTION)" >>$@
	@echo "Version: $(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REPORTLAB_MAINTAINER)" >>$@
	@echo "Source: $(PY-REPORTLAB_SITE)/$(PY-REPORTLAB_SOURCE)" >>$@
	@echo "Description: $(PY-REPORTLAB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-REPORTLAB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REPORTLAB_CONFLICTS)" >>$@

$(PY25-REPORTLAB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-reportlab" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-REPORTLAB_PRIORITY)" >>$@
	@echo "Section: $(PY-REPORTLAB_SECTION)" >>$@
	@echo "Version: $(PY-REPORTLAB_VERSION)-$(PY-REPORTLAB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-REPORTLAB_MAINTAINER)" >>$@
	@echo "Source: $(PY-REPORTLAB_SITE)/$(PY-REPORTLAB_SOURCE)" >>$@
	@echo "Description: $(PY-REPORTLAB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-REPORTLAB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-REPORTLAB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-REPORTLAB_IPK_DIR)/opt/sbin or $(PY-REPORTLAB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-REPORTLAB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-REPORTLAB_IPK_DIR)/opt/etc/py-reportlab/...
# Documentation files should be installed in $(PY-REPORTLAB_IPK_DIR)/opt/doc/py-reportlab/...
# Daemon startup scripts should be installed in $(PY-REPORTLAB_IPK_DIR)/opt/etc/init.d/S??py-reportlab
#
# You may need to patch your application to make it use these locations.
#
$(PY24-REPORTLAB_IPK): $(PY-REPORTLAB_BUILD_DIR)/.built
	rm -rf $(PY24-REPORTLAB_IPK_DIR) $(BUILD_DIR)/py-reportlab_*_$(TARGET_ARCH).ipk
	(cd $(PY-REPORTLAB_BUILD_DIR)/2.4/reportlab; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY24-REPORTLAB_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY24-REPORTLAB_IPK_DIR)/opt/lib -name '*.so'`
	rm -rf $(PY24-REPORTLAB_IPK_DIR)/opt/share
	$(MAKE) $(PY24-REPORTLAB_IPK_DIR)/CONTROL/control
#	echo $(PY-REPORTLAB_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-REPORTLAB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-REPORTLAB_IPK_DIR)

$(PY25-REPORTLAB_IPK) $(PY-REPORTLAB-COMMON_IPK): $(PY-REPORTLAB_BUILD_DIR)/.built
	rm -rf $(PY25-REPORTLAB_IPK_DIR) $(BUILD_DIR)/py25-reportlab_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-REPORTLAB-COMMON_IPK_DIR) $(BUILD_DIR)/py-reportlab-common_*_$(TARGET_ARCH).ipk
	(cd $(PY-REPORTLAB_BUILD_DIR)/2.5/reportlab; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY25-REPORTLAB_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY25-REPORTLAB_IPK_DIR)/opt/lib -name '*.so'`
	install -d $(PY-REPORTLAB-COMMON_IPK_DIR)/opt/
	mv $(PY25-REPORTLAB_IPK_DIR)/opt/share $(PY-REPORTLAB-COMMON_IPK_DIR)/opt/
#	echo $(PY-REPORTLAB_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-REPORTLAB_IPK_DIR)/CONTROL/conffiles
	$(MAKE) $(PY-REPORTLAB-COMMON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-REPORTLAB-COMMON_IPK_DIR)
	$(MAKE) $(PY25-REPORTLAB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-REPORTLAB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-reportlab-ipk: $(PY24-REPORTLAB_IPK) $(PY25-REPORTLAB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-reportlab-clean:
	-$(MAKE) -C $(PY-REPORTLAB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-reportlab-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-REPORTLAB_DIR) $(PY-REPORTLAB_BUILD_DIR)
	rm -rf $(PY-REPORTLAB-COMMON_IPK_DIR) $(PY-REPORTLAB-COMMON_IPK)
	rm -rf $(PY24-REPORTLAB_IPK_DIR) $(PY24-REPORTLAB_IPK)
	rm -rf $(PY25-REPORTLAB_IPK_DIR) $(PY25-REPORTLAB_IPK)

#
# Some sanity check for the package.
#
py-reportlab-check: $(PY24-REPORTLAB_IPK) $(PY25-REPORTLAB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-REPORTLAB_IPK) $(PY25-REPORTLAB_IPK)
