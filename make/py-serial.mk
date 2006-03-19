###########################################################
#
# py-serial
#
###########################################################

#
# PY-SERIAL_VERSION, PY-SERIAL_SITE and PY-SERIAL_SOURCE define
# the upstream location of the source code for the package.
# PY-SERIAL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SERIAL_UNZIP is the command used to unzip the source.
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
PY-SERIAL_SITE=http://dl.sourceforge.net/sourceforge/pyserial
PY-SERIAL_VERSION=2.2
PY-SERIAL_SOURCE=pyserial-$(PY-SERIAL_VERSION).zip
PY-SERIAL_DIR=pyserial-$(PY-SERIAL_VERSION)
PY-SERIAL_UNZIP=unzip
PY-SERIAL_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SERIAL_DESCRIPTION=Python module encapsulating the access to serial port.
PY-SERIAL_SECTION=misc
PY-SERIAL_PRIORITY=optional
PY-SERIAL_DEPENDS=python
PY-SERIAL_CONFLICTS=

#
# PY-SERIAL_IPK_VERSION should be incremented when the ipk changes.
#
PY-SERIAL_IPK_VERSION=3

#
# PY-SERIAL_CONFFILES should be a list of user-editable files
#PY-SERIAL_CONFFILES=/opt/etc/py-serial.conf /opt/etc/init.d/SXXpy-serial

#
# PY-SERIAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SERIAL_PATCHES=$(PY-SERIAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SERIAL_CPPFLAGS=
PY-SERIAL_LDFLAGS=

#
# PY-SERIAL_BUILD_DIR is the directory in which the build is done.
# PY-SERIAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SERIAL_IPK_DIR is the directory in which the ipk is built.
# PY-SERIAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SERIAL_BUILD_DIR=$(BUILD_DIR)/py-serial
PY-SERIAL_SOURCE_DIR=$(SOURCE_DIR)/py-serial
PY-SERIAL_IPK_DIR=$(BUILD_DIR)/py-serial-$(PY-SERIAL_VERSION)-ipk
PY-SERIAL_IPK=$(BUILD_DIR)/py-serial_$(PY-SERIAL_VERSION)-$(PY-SERIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SERIAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SERIAL_SITE)/$(PY-SERIAL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-serial-source: $(DL_DIR)/$(PY-SERIAL_SOURCE) $(PY-SERIAL_PATCHES)

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
$(PY-SERIAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SERIAL_SOURCE) $(PY-SERIAL_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-SERIAL_DIR) $(PY-SERIAL_BUILD_DIR)
	cd $(BUILD_DIR) && $(PY-SERIAL_UNZIP) $(DL_DIR)/$(PY-SERIAL_SOURCE)
#	cat $(PY-SERIAL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SERIAL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SERIAL_DIR) $(PY-SERIAL_BUILD_DIR)
	(cd $(PY-SERIAL_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") > setup.cfg \
	)
	touch $(PY-SERIAL_BUILD_DIR)/.configured

py-serial-unpack: $(PY-SERIAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SERIAL_BUILD_DIR)/.built: $(PY-SERIAL_BUILD_DIR)/.configured
	rm -f $(PY-SERIAL_BUILD_DIR)/.built
	cd $(PY-SERIAL_BUILD_DIR) &&  $(STAGING_PREFIX)/bin/python setup.py build
	touch $(PY-SERIAL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-serial: $(PY-SERIAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SERIAL_BUILD_DIR)/.staged: $(PY-SERIAL_BUILD_DIR)/.built
	rm -f $(PY-SERIAL_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-SERIAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SERIAL_BUILD_DIR)/.staged

py-serial-stage: $(PY-SERIAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-serial
#
$(PY-SERIAL_IPK_DIR)/CONTROL/control:
	@install -d $(PY-SERIAL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-serial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SERIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-SERIAL_SECTION)" >>$@
	@echo "Version: $(PY-SERIAL_VERSION)-$(PY-SERIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SERIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-SERIAL_SITE)/$(PY-SERIAL_SOURCE)" >>$@
	@echo "Description: $(PY-SERIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-SERIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SERIAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SERIAL_IPK_DIR)/opt/sbin or $(PY-SERIAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SERIAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SERIAL_IPK_DIR)/opt/etc/py-serial/...
# Documentation files should be installed in $(PY-SERIAL_IPK_DIR)/opt/doc/py-serial/...
# Daemon startup scripts should be installed in $(PY-SERIAL_IPK_DIR)/opt/etc/init.d/S??py-serial
#
# You may need to patch your application to make it use these locations.
#
$(PY-SERIAL_IPK): $(PY-SERIAL_BUILD_DIR)/.built
	rm -rf $(PY-SERIAL_IPK_DIR) $(BUILD_DIR)/py-serial_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-SERIAL_BUILD_DIR) DESTDIR=$(PY-SERIAL_IPK_DIR) install
	(cd $(PY-SERIAL_BUILD_DIR); \
	python2.4 setup.py install --root=$(PY-SERIAL_IPK_DIR) --prefix=/opt)
	install -d $(PY-SERIAL_IPK_DIR)/opt/share/doc/py-serial/examples
	install $(PY-SERIAL_BUILD_DIR)/README.txt $(PY-SERIAL_IPK_DIR)/opt/share/doc/py-serial/
	install $(PY-SERIAL_BUILD_DIR)/examples/* $(PY-SERIAL_IPK_DIR)/opt/share/doc/py-serial/examples/
	$(MAKE) $(PY-SERIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SERIAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-serial-ipk: $(PY-SERIAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-serial-clean:
	-$(MAKE) -C $(PY-SERIAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-serial-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SERIAL_DIR) $(PY-SERIAL_BUILD_DIR) $(PY-SERIAL_IPK_DIR) $(PY-SERIAL_IPK)
