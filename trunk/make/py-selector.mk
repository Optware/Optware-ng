###########################################################
#
# py-selector
#
###########################################################

#
# PY-SELECTOR_VERSION, PY-SELECTOR_SITE and PY-SELECTOR_SOURCE define
# the upstream location of the source code for the package.
# PY-SELECTOR_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SELECTOR_UNZIP is the command used to unzip the source.
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
PY-SELECTOR_SITE=http://cheeseshop.python.org/packages/source/s/selector
PY-SELECTOR_VERSION=0.8.11
PY-SELECTOR_SOURCE=selector-$(PY-SELECTOR_VERSION).tar.gz
PY-SELECTOR_DIR=selector-$(PY-SELECTOR_VERSION)
PY-SELECTOR_UNZIP=zcat
PY-SELECTOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SELECTOR_DESCRIPTION=WSGI delegation based on URL path and method.
PY-SELECTOR_SECTION=misc
PY-SELECTOR_PRIORITY=optional
PY24-SELECTOR_DEPENDS=python24
PY25-SELECTOR_DEPENDS=python25
PY-SELECTOR_CONFLICTS=

#
# PY-SELECTOR_IPK_VERSION should be incremented when the ipk changes.
#
PY-SELECTOR_IPK_VERSION=1

#
# PY-SELECTOR_CONFFILES should be a list of user-editable files
#PY-SELECTOR_CONFFILES=/opt/etc/py-selector.conf /opt/etc/init.d/SXXpy-selector

#
# PY-SELECTOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SELECTOR_PATCHES=$(PY-SELECTOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SELECTOR_CPPFLAGS=
PY-SELECTOR_LDFLAGS=

#
# PY-SELECTOR_BUILD_DIR is the directory in which the build is done.
# PY-SELECTOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SELECTOR_IPK_DIR is the directory in which the ipk is built.
# PY-SELECTOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SELECTOR_BUILD_DIR=$(BUILD_DIR)/py-selector
PY-SELECTOR_SOURCE_DIR=$(SOURCE_DIR)/py-selector

PY24-SELECTOR_IPK_DIR=$(BUILD_DIR)/py-selector-$(PY-SELECTOR_VERSION)-ipk
PY24-SELECTOR_IPK=$(BUILD_DIR)/py-selector_$(PY-SELECTOR_VERSION)-$(PY-SELECTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-SELECTOR_IPK_DIR=$(BUILD_DIR)/py25-selector-$(PY-SELECTOR_VERSION)-ipk
PY25-SELECTOR_IPK=$(BUILD_DIR)/py25-selector_$(PY-SELECTOR_VERSION)-$(PY-SELECTOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-selector-source py-selector-unpack py-selector py-selector-stage py-selector-ipk py-selector-clean py-selector-dirclean py-selector-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SELECTOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SELECTOR_SITE)/$(PY-SELECTOR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-selector-source: $(DL_DIR)/$(PY-SELECTOR_SOURCE) $(PY-SELECTOR_PATCHES)

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
$(PY-SELECTOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SELECTOR_SOURCE) $(PY-SELECTOR_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-SELECTOR_BUILD_DIR)
	mkdir -p $(PY-SELECTOR_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-SELECTOR_DIR)
	$(PY-SELECTOR_UNZIP) $(DL_DIR)/$(PY-SELECTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SELECTOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SELECTOR_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SELECTOR_DIR) $(PY-SELECTOR_BUILD_DIR)/2.4
	(cd $(PY-SELECTOR_BUILD_DIR)/2.4; \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-SELECTOR_DIR)
	$(PY-SELECTOR_UNZIP) $(DL_DIR)/$(PY-SELECTOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SELECTOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SELECTOR_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SELECTOR_DIR) $(PY-SELECTOR_BUILD_DIR)/2.5
	(cd $(PY-SELECTOR_BUILD_DIR)/2.5; \
	    sed -i -e '/use_setuptools/d' setup.py; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-selector-unpack: $(PY-SELECTOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SELECTOR_BUILD_DIR)/.built: $(PY-SELECTOR_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-SELECTOR_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-SELECTOR_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-selector: $(PY-SELECTOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SELECTOR_BUILD_DIR)/.staged: $(PY-SELECTOR_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-SELECTOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-selector-stage: $(PY-SELECTOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-selector
#
$(PY24-SELECTOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-selector" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SELECTOR_PRIORITY)" >>$@
	@echo "Section: $(PY-SELECTOR_SECTION)" >>$@
	@echo "Version: $(PY-SELECTOR_VERSION)-$(PY-SELECTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SELECTOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-SELECTOR_SITE)/$(PY-SELECTOR_SOURCE)" >>$@
	@echo "Description: $(PY-SELECTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SELECTOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SELECTOR_CONFLICTS)" >>$@

$(PY25-SELECTOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-selector" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SELECTOR_PRIORITY)" >>$@
	@echo "Section: $(PY-SELECTOR_SECTION)" >>$@
	@echo "Version: $(PY-SELECTOR_VERSION)-$(PY-SELECTOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SELECTOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-SELECTOR_SITE)/$(PY-SELECTOR_SOURCE)" >>$@
	@echo "Description: $(PY-SELECTOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SELECTOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SELECTOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SELECTOR_IPK_DIR)/opt/sbin or $(PY-SELECTOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SELECTOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SELECTOR_IPK_DIR)/opt/etc/py-selector/...
# Documentation files should be installed in $(PY-SELECTOR_IPK_DIR)/opt/doc/py-selector/...
# Daemon startup scripts should be installed in $(PY-SELECTOR_IPK_DIR)/opt/etc/init.d/S??py-selector
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SELECTOR_IPK): $(PY-SELECTOR_BUILD_DIR)/.built
	rm -rf $(PY24-SELECTOR_IPK_DIR) $(BUILD_DIR)/py-selector_*_$(TARGET_ARCH).ipk
	(cd $(PY-SELECTOR_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
		--root=$(PY24-SELECTOR_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-SELECTOR_IPK_DIR)/CONTROL/control
#	echo $(PY-SELECTOR_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SELECTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SELECTOR_IPK_DIR)

$(PY25-SELECTOR_IPK): $(PY-SELECTOR_BUILD_DIR)/.built
	rm -rf $(PY25-SELECTOR_IPK_DIR) $(BUILD_DIR)/py25-selector_*_$(TARGET_ARCH).ipk
	(cd $(PY-SELECTOR_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-SELECTOR_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-SELECTOR_IPK_DIR)/CONTROL/control
#	echo $(PY-SELECTOR_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SELECTOR_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SELECTOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-selector-ipk: $(PY24-SELECTOR_IPK) $(PY25-SELECTOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-selector-clean:
	-$(MAKE) -C $(PY-SELECTOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-selector-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SELECTOR_DIR) $(PY-SELECTOR_BUILD_DIR)
	rm -rf $(PY24-SELECTOR_IPK_DIR) $(PY24-SELECTOR_IPK)
	rm -rf $(PY25-SELECTOR_IPK_DIR) $(PY25-SELECTOR_IPK)

#
# Some sanity check for the package.
#
py-selector-check: $(PY24-SELECTOR_IPK) $(PY25-SELECTOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-SELECTOR_IPK) $(PY25-SELECTOR_IPK)
