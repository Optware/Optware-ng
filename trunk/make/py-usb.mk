###########################################################
#
# py-usb
#
###########################################################

#
# PY-USB_VERSION, PY-USB_SITE and PY-USB_SOURCE define
# the upstream location of the source code for the package.
# PY-USB_DIR is the directory which is created when the source
# archive is unpacked.
# PY-USB_UNZIP is the command used to unzip the source.
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
PY-USB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pyusb
PY-USB_VERSION=0.4.1
PY-USB_SOURCE=pyusb-$(PY-USB_VERSION).tar.gz
PY-USB_DIR=pyusb-$(PY-USB_VERSION)
PY-USB_UNZIP=zcat
PY-USB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-USB_DESCRIPTION=PyUSB is a native Python module written in C that provides USB access for it.
PY-USB_SECTION=misc
PY-USB_PRIORITY=optional
PY24-USB_DEPENDS=python24, libusb
PY25-USB_DEPENDS=python25, libusb
PY-USB_CONFLICTS=

#
# PY-USB_IPK_VERSION should be incremented when the ipk changes.
#
PY-USB_IPK_VERSION=1

#
# PY-USB_CONFFILES should be a list of user-editable files
#PY-USB_CONFFILES=/opt/etc/py-usb.conf /opt/etc/init.d/SXXpy-usb

#
# PY-USB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-USB_PATCHES=$(PY-USB_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-USB_CPPFLAGS=
PY-USB_LDFLAGS=

#
# PY-USB_BUILD_DIR is the directory in which the build is done.
# PY-USB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-USB_IPK_DIR is the directory in which the ipk is built.
# PY-USB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-USB_BUILD_DIR=$(BUILD_DIR)/py-usb
PY-USB_SOURCE_DIR=$(SOURCE_DIR)/py-usb

PY24-USB_IPK_DIR=$(BUILD_DIR)/py-usb-$(PY-USB_VERSION)-ipk
PY24-USB_IPK=$(BUILD_DIR)/py-usb_$(PY-USB_VERSION)-$(PY-USB_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-USB_IPK_DIR=$(BUILD_DIR)/py25-usb-$(PY-USB_VERSION)-ipk
PY25-USB_IPK=$(BUILD_DIR)/py25-usb_$(PY-USB_VERSION)-$(PY-USB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-usb-source py-usb-unpack py-usb py-usb-stage py-usb-ipk py-usb-clean py-usb-dirclean py-usb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-USB_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-USB_SITE)/$(PY-USB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-usb-source: $(DL_DIR)/$(PY-USB_SOURCE) $(PY-USB_PATCHES)

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
$(PY-USB_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-USB_SOURCE) $(PY-USB_PATCHES)
	$(MAKE) py-setuptools-stage libusb-stage
	rm -rf $(PY-USB_BUILD_DIR)
	mkdir -p $(PY-USB_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-USB_DIR)
	$(PY-USB_UNZIP) $(DL_DIR)/$(PY-USB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-USB_PATCHES)"; then \
	    cat $(PY-USB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-USB_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-USB_DIR) $(PY-USB_BUILD_DIR)/2.4
	(cd $(PY-USB_BUILD_DIR)/2.4; \
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
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-USB_DIR)
	$(PY-USB_UNZIP) $(DL_DIR)/$(PY-USB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-USB_PATCHES)"; then \
	    cat $(PY-USB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-USB_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-USB_DIR) $(PY-USB_BUILD_DIR)/2.5
	(cd $(PY-USB_BUILD_DIR)/2.5; \
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

py-usb-unpack: $(PY-USB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-USB_BUILD_DIR)/.built: $(PY-USB_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-USB_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-USB_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-usb: $(PY-USB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-USB_BUILD_DIR)/.staged: $(PY-USB_BUILD_DIR)/.built
	rm -f $(PY-USB_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-USB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-USB_BUILD_DIR)/.staged

py-usb-stage: $(PY-USB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-usb
#
$(PY24-USB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-usb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-USB_PRIORITY)" >>$@
	@echo "Section: $(PY-USB_SECTION)" >>$@
	@echo "Version: $(PY-USB_VERSION)-$(PY-USB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-USB_MAINTAINER)" >>$@
	@echo "Source: $(PY-USB_SITE)/$(PY-USB_SOURCE)" >>$@
	@echo "Description: $(PY-USB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-USB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-USB_CONFLICTS)" >>$@

$(PY25-USB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-usb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-USB_PRIORITY)" >>$@
	@echo "Section: $(PY-USB_SECTION)" >>$@
	@echo "Version: $(PY-USB_VERSION)-$(PY-USB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-USB_MAINTAINER)" >>$@
	@echo "Source: $(PY-USB_SITE)/$(PY-USB_SOURCE)" >>$@
	@echo "Description: $(PY-USB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-USB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-USB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-USB_IPK_DIR)/opt/sbin or $(PY-USB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-USB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-USB_IPK_DIR)/opt/etc/py-usb/...
# Documentation files should be installed in $(PY-USB_IPK_DIR)/opt/doc/py-usb/...
# Daemon startup scripts should be installed in $(PY-USB_IPK_DIR)/opt/etc/init.d/S??py-usb
#
# You may need to patch your application to make it use these locations.
#
$(PY24-USB_IPK): $(PY-USB_BUILD_DIR)/.built
	rm -rf $(PY24-USB_IPK_DIR) $(BUILD_DIR)/py-usb_*_$(TARGET_ARCH).ipk
	(cd $(PY-USB_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY24-USB_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) $(PY24-USB_IPK_DIR)/opt/lib/python2.4/site-packages/usb.so
	$(MAKE) $(PY24-USB_IPK_DIR)/CONTROL/control
#	echo $(PY-USB_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-USB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-USB_IPK_DIR)

$(PY25-USB_IPK): $(PY-USB_BUILD_DIR)/.built
	rm -rf $(PY25-USB_IPK_DIR) $(BUILD_DIR)/py25-usb_*_$(TARGET_ARCH).ipk
	(cd $(PY-USB_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY25-USB_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) $(PY25-USB_IPK_DIR)/opt/lib/python2.5/site-packages/usb.so
	$(MAKE) $(PY25-USB_IPK_DIR)/CONTROL/control
#	echo $(PY-USB_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-USB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-USB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-usb-ipk: $(PY24-USB_IPK) $(PY25-USB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-usb-clean:
	-$(MAKE) -C $(PY-USB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-usb-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-USB_DIR) $(PY-USB_BUILD_DIR)
	rm -rf $(PY24-USB_IPK_DIR) $(PY24-USB_IPK)
	rm -rf $(PY25-USB_IPK_DIR) $(PY25-USB_IPK)

#
# Some sanity check for the package.
#
py-usb-check: $(PY24-USB_IPK) $(PY25-USB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-USB_IPK) $(PY25-USB_IPK)
