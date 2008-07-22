###########################################################
#
# py-flup
#
###########################################################

#
# PY-FLUP_VERSION, PY-FLUP_SITE and PY-FLUP_SOURCE define
# the upstream location of the source code for the package.
# PY-FLUP_DIR is the directory which is created when the source
# archive is unpacked.
# PY-FLUP_UNZIP is the command used to unzip the source.
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
PY-FLUP_SITE=http://www.saddi.com/software/flup/dist
PY-FLUP_VERSION=1.0.1
PY-FLUP_DIR=flup-$(PY-FLUP_VERSION)
PY-FLUP_SOURCE=$(PY-FLUP_DIR).tar.gz
PY-FLUP_UNZIP=zcat
PY-FLUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-FLUP_DESCRIPTION=A collection of python WSGI modules including those speaking AJP 1.3, FastCGI and SCGI.
PY-FLUP_SECTION=misc
PY-FLUP_PRIORITY=optional
PY24-FLUP_DEPENDS=python24
PY25-FLUP_DEPENDS=python25
PY-FLUP_CONFLICTS=

#
# PY-FLUP_IPK_VERSION should be incremented when the ipk changes.
#
PY-FLUP_IPK_VERSION=1

#
# PY-FLUP_CONFFILES should be a list of user-editable files
#PY-FLUP_CONFFILES=/opt/etc/py-flup.conf /opt/etc/init.d/SXXpy-flup

#
# PY-FLUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-FLUP_PATCHES=$(PY-FLUP_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-FLUP_CPPFLAGS=
PY-FLUP_LDFLAGS=

#
# PY-FLUP_BUILD_DIR is the directory in which the build is done.
# PY-FLUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-FLUP_IPK_DIR is the directory in which the ipk is built.
# PY-FLUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-FLUP_BUILD_DIR=$(BUILD_DIR)/py-flup
PY-FLUP_SOURCE_DIR=$(SOURCE_DIR)/py-flup

PY24-FLUP_IPK_DIR=$(BUILD_DIR)/py24-flup-$(PY-FLUP_VERSION)-ipk
PY24-FLUP_IPK=$(BUILD_DIR)/py24-flup_$(PY-FLUP_VERSION)-$(PY-FLUP_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-FLUP_IPK_DIR=$(BUILD_DIR)/py25-flup-$(PY-FLUP_VERSION)-ipk
PY25-FLUP_IPK=$(BUILD_DIR)/py25-flup_$(PY-FLUP_VERSION)-$(PY-FLUP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-flup-source py-flup-unpack py-flup py-flup-stage py-flup-ipk py-flup-clean py-flup-dirclean py-flup-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-FLUP_SOURCE):
	$(WGET) -P $(@D) $(PY-FLUP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-flup-source: $(DL_DIR)/$(PY-FLUP_SOURCE) $(PY-FLUP_PATCHES)

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
$(PY-FLUP_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-FLUP_SOURCE) $(PY-FLUP_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-FLUP_DIR)
	$(PY-FLUP_UNZIP) $(DL_DIR)/$(PY-FLUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-FLUP_PATCHES)"; then \
	    cat $(PY-FLUP_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FLUP_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-FLUP_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-FLUP_DIR)
	$(PY-FLUP_UNZIP) $(DL_DIR)/$(PY-FLUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-FLUP_PATCHES)"; then \
	    cat $(PY-FLUP_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FLUP_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-FLUP_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-flup-unpack: $(PY-FLUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-FLUP_BUILD_DIR)/.built: $(PY-FLUP_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-flup: $(PY-FLUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-FLUP_BUILD_DIR)/.staged: $(PY-FLUP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-FLUP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-flup-stage: $(PY-FLUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-flup
#
$(PY24-FLUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-flup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FLUP_PRIORITY)" >>$@
	@echo "Section: $(PY-FLUP_SECTION)" >>$@
	@echo "Version: $(PY-FLUP_VERSION)-$(PY-FLUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FLUP_MAINTAINER)" >>$@
	@echo "Source: $(PY-FLUP_SITE)/$(PY-FLUP_SOURCE)" >>$@
	@echo "Description: $(PY-FLUP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-FLUP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FLUP_CONFLICTS)" >>$@

$(PY25-FLUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-flup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FLUP_PRIORITY)" >>$@
	@echo "Section: $(PY-FLUP_SECTION)" >>$@
	@echo "Version: $(PY-FLUP_VERSION)-$(PY-FLUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FLUP_MAINTAINER)" >>$@
	@echo "Source: $(PY-FLUP_SITE)/$(PY-FLUP_SOURCE)" >>$@
	@echo "Description: $(PY-FLUP_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-FLUP_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FLUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-FLUP_IPK_DIR)/opt/sbin or $(PY-FLUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-FLUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-FLUP_IPK_DIR)/opt/etc/py-flup/...
# Documentation files should be installed in $(PY-FLUP_IPK_DIR)/opt/doc/py-flup/...
# Daemon startup scripts should be installed in $(PY-FLUP_IPK_DIR)/opt/etc/init.d/S??py-flup
#
# You may need to patch your application to make it use these locations.
#
$(PY24-FLUP_IPK): $(PY-FLUP_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-flup_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-FLUP_IPK_DIR) $(BUILD_DIR)/py24-flup_*_$(TARGET_ARCH).ipk
	(cd $(PY-FLUP_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	--root=$(PY24-FLUP_IPK_DIR) --prefix=/opt)
#	python2.4 -c "import setuptools; execfile('setup.py')" install --root=$(PY-FLUP_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-FLUP_IPK_DIR)/CONTROL/control
#	echo $(PY-FLUP_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-FLUP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-FLUP_IPK_DIR)

$(PY25-FLUP_IPK): $(PY-FLUP_BUILD_DIR)/.built
	rm -rf $(PY25-FLUP_IPK_DIR) $(BUILD_DIR)/py25-flup_*_$(TARGET_ARCH).ipk
	(cd $(PY-FLUP_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	--root=$(PY25-FLUP_IPK_DIR) --prefix=/opt)
#	python2.5 -c "import setuptools; execfile('setup.py')" install --root=$(PY-FLUP_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-FLUP_IPK_DIR)/CONTROL/control
#	echo $(PY-FLUP_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-FLUP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-FLUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-flup-ipk: $(PY24-FLUP_IPK) $(PY25-FLUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-flup-clean:
	-$(MAKE) -C $(PY-FLUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-flup-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-FLUP_DIR) $(PY-FLUP_BUILD_DIR)
	rm -rf $(PY24-FLUP_IPK_DIR) $(PY24-FLUP_IPK)
	rm -rf $(PY25-FLUP_IPK_DIR) $(PY25-FLUP_IPK)

#
# Some sanity check for the package.
#
py-flup-check: $(PY24-FLUP_IPK) $(PY25-FLUP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-FLUP_IPK) $(PY25-FLUP_IPK)
