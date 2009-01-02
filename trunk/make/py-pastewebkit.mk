###########################################################
#
# py-pastewebkit
#
###########################################################

#
# PY-PASTEWEBKIT_VERSION, PY-PASTEWEBKIT_SITE and PY-PASTEWEBKIT_SOURCE define
# the upstream location of the source code for the package.
# PY-PASTEWEBKIT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PASTEWEBKIT_UNZIP is the command used to unzip the source.
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
PY-PASTEWEBKIT_SITE=http://cheeseshop.python.org/packages/source/P/PasteWebKit
PY-PASTEWEBKIT_VERSION=1.0
PY-PASTEWEBKIT_SOURCE=PasteWebKit-$(PY-PASTEWEBKIT_VERSION).tar.gz
PY-PASTEWEBKIT_DIR=PasteWebKit-$(PY-PASTEWEBKIT_VERSION)
PY-PASTEWEBKIT_UNZIP=zcat
PY-PASTEWEBKIT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PASTEWEBKIT_DESCRIPTION=A port/reimplementation of Webware WebKit in WSGI and Paste.
PY-PASTEWEBKIT_SECTION=misc
PY-PASTEWEBKIT_PRIORITY=optional
PY24-PASTEWEBKIT_DEPENDS=python24, py24-paste, py24-pastedeploy, py24-pastescript
PY25-PASTEWEBKIT_DEPENDS=python25, py25-paste, py25-pastedeploy, py25-pastescript
PY26-PASTEWEBKIT_DEPENDS=python26, py26-paste, py26-pastedeploy, py26-pastescript
PY-PASTEWEBKIT_CONFLICTS=

#
# PY-PASTEWEBKIT_IPK_VERSION should be incremented when the ipk changes.
#
PY-PASTEWEBKIT_IPK_VERSION=4

#
# PY-PASTEWEBKIT_CONFFILES should be a list of user-editable files
#PY-PASTEWEBKIT_CONFFILES=/opt/etc/py-pastewebkit.conf /opt/etc/init.d/SXXpy-pastewebkit

#
# PY-PASTEWEBKIT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PASTEWEBKIT_PATCHES=$(PY-PASTEWEBKIT_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PASTEWEBKIT_CPPFLAGS=
PY-PASTEWEBKIT_LDFLAGS=

#
# PY-PASTEWEBKIT_BUILD_DIR is the directory in which the build is done.
# PY-PASTEWEBKIT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PASTEWEBKIT_IPK_DIR is the directory in which the ipk is built.
# PY-PASTEWEBKIT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PASTEWEBKIT_BUILD_DIR=$(BUILD_DIR)/py-pastewebkit
PY-PASTEWEBKIT_SOURCE_DIR=$(SOURCE_DIR)/py-pastewebkit

PY24-PASTEWEBKIT_IPK_DIR=$(BUILD_DIR)/py24-pastewebkit-$(PY-PASTEWEBKIT_VERSION)-ipk
PY24-PASTEWEBKIT_IPK=$(BUILD_DIR)/py24-pastewebkit_$(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PASTEWEBKIT_IPK_DIR=$(BUILD_DIR)/py25-pastewebkit-$(PY-PASTEWEBKIT_VERSION)-ipk
PY25-PASTEWEBKIT_IPK=$(BUILD_DIR)/py25-pastewebkit_$(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PASTEWEBKIT_IPK_DIR=$(BUILD_DIR)/py26-pastewebkit-$(PY-PASTEWEBKIT_VERSION)-ipk
PY26-PASTEWEBKIT_IPK=$(BUILD_DIR)/py26-pastewebkit_$(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pastewebkit-source py-pastewebkit-unpack py-pastewebkit py-pastewebkit-stage py-pastewebkit-ipk py-pastewebkit-clean py-pastewebkit-dirclean py-pastewebkit-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PASTEWEBKIT_SITE)/$(PY-PASTEWEBKIT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pastewebkit-source: $(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE) $(PY-PASTEWEBKIT_PATCHES)

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
$(PY-PASTEWEBKIT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE) $(PY-PASTEWEBKIT_PATCHES) make/py-pastewebkit.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PASTEWEBKIT_BUILD_DIR)
	mkdir -p $(PY-PASTEWEBKIT_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR)
	$(PY-PASTEWEBKIT_UNZIP) $(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PASTEWEBKIT_PATCHES)"; then \
	    cat $(PY-PASTEWEBKIT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) $(PY-PASTEWEBKIT_BUILD_DIR)/2.4
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.4; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR)
	$(PY-PASTEWEBKIT_UNZIP) $(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PASTEWEBKIT_PATCHES)"; then \
	    cat $(PY-PASTEWEBKIT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) $(PY-PASTEWEBKIT_BUILD_DIR)/2.5
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR)
	$(PY-PASTEWEBKIT_UNZIP) $(DL_DIR)/$(PY-PASTEWEBKIT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PASTEWEBKIT_PATCHES)"; then \
	    cat $(PY-PASTEWEBKIT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) $(PY-PASTEWEBKIT_BUILD_DIR)/2.6
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-pastewebkit-unpack: $(PY-PASTEWEBKIT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PASTEWEBKIT_BUILD_DIR)/.built: $(PY-PASTEWEBKIT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-pastewebkit: $(PY-PASTEWEBKIT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PASTEWEBKIT_BUILD_DIR)/.staged: $(PY-PASTEWEBKIT_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-PASTEWEBKIT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-pastewebkit-stage: $(PY-PASTEWEBKIT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pastewebkit
#
$(PY24-PASTEWEBKIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-pastewebkit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTEWEBKIT_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTEWEBKIT_SECTION)" >>$@
	@echo "Version: $(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTEWEBKIT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTEWEBKIT_SITE)/$(PY-PASTEWEBKIT_SOURCE)" >>$@
	@echo "Description: $(PY-PASTEWEBKIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PASTEWEBKIT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTEWEBKIT_CONFLICTS)" >>$@

$(PY25-PASTEWEBKIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pastewebkit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTEWEBKIT_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTEWEBKIT_SECTION)" >>$@
	@echo "Version: $(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTEWEBKIT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTEWEBKIT_SITE)/$(PY-PASTEWEBKIT_SOURCE)" >>$@
	@echo "Description: $(PY-PASTEWEBKIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PASTEWEBKIT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTEWEBKIT_CONFLICTS)" >>$@

$(PY26-PASTEWEBKIT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-pastewebkit" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PASTEWEBKIT_PRIORITY)" >>$@
	@echo "Section: $(PY-PASTEWEBKIT_SECTION)" >>$@
	@echo "Version: $(PY-PASTEWEBKIT_VERSION)-$(PY-PASTEWEBKIT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PASTEWEBKIT_MAINTAINER)" >>$@
	@echo "Source: $(PY-PASTEWEBKIT_SITE)/$(PY-PASTEWEBKIT_SOURCE)" >>$@
	@echo "Description: $(PY-PASTEWEBKIT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PASTEWEBKIT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PASTEWEBKIT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PASTEWEBKIT_IPK_DIR)/opt/sbin or $(PY-PASTEWEBKIT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PASTEWEBKIT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PASTEWEBKIT_IPK_DIR)/opt/etc/py-pastewebkit/...
# Documentation files should be installed in $(PY-PASTEWEBKIT_IPK_DIR)/opt/doc/py-pastewebkit/...
# Daemon startup scripts should be installed in $(PY-PASTEWEBKIT_IPK_DIR)/opt/etc/init.d/S??py-pastewebkit
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PASTEWEBKIT_IPK): $(PY-PASTEWEBKIT_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-pastewebkit_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-PASTEWEBKIT_IPK_DIR) $(BUILD_DIR)/py24-pastewebkit_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY24-PASTEWEBKIT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PASTEWEBKIT_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTEWEBKIT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PASTEWEBKIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PASTEWEBKIT_IPK_DIR)

$(PY25-PASTEWEBKIT_IPK): $(PY-PASTEWEBKIT_BUILD_DIR)/.built
	rm -rf $(PY25-PASTEWEBKIT_IPK_DIR) $(BUILD_DIR)/py25-pastewebkit_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY25-PASTEWEBKIT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PASTEWEBKIT_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTEWEBKIT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PASTEWEBKIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PASTEWEBKIT_IPK_DIR)

$(PY26-PASTEWEBKIT_IPK): $(PY-PASTEWEBKIT_BUILD_DIR)/.built
	rm -rf $(PY26-PASTEWEBKIT_IPK_DIR) $(BUILD_DIR)/py26-pastewebkit_*_$(TARGET_ARCH).ipk
	(cd $(PY-PASTEWEBKIT_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	--root=$(PY26-PASTEWEBKIT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY26-PASTEWEBKIT_IPK_DIR)/CONTROL/control
#	echo $(PY-PASTEWEBKIT_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-PASTEWEBKIT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PASTEWEBKIT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pastewebkit-ipk: $(PY24-PASTEWEBKIT_IPK) $(PY25-PASTEWEBKIT_IPK) $(PY26-PASTEWEBKIT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pastewebkit-clean:
	-$(MAKE) -C $(PY-PASTEWEBKIT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pastewebkit-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PASTEWEBKIT_DIR) $(PY-PASTEWEBKIT_BUILD_DIR)
	rm -rf $(PY24-PASTEWEBKIT_IPK_DIR) $(PY24-PASTEWEBKIT_IPK)
	rm -rf $(PY25-PASTEWEBKIT_IPK_DIR) $(PY25-PASTEWEBKIT_IPK)
	rm -rf $(PY26-PASTEWEBKIT_IPK_DIR) $(PY26-PASTEWEBKIT_IPK)

#
# Some sanity check for the package.
#
py-pastewebkit-check: $(PY24-PASTEWEBKIT_IPK) $(PY25-PASTEWEBKIT_IPK) $(PY26-PASTEWEBKIT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
