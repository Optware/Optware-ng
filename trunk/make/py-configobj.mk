###########################################################
#
# py-configobj
#
###########################################################

#
# PY-CONFIGOBJ_VERSION, PY-CONFIGOBJ_SITE and PY-CONFIGOBJ_SOURCE define
# the upstream location of the source code for the package.
# PY-CONFIGOBJ_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CONFIGOBJ_UNZIP is the command used to unzip the source.
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
PY-CONFIGOBJ_SITE=http://dl.sourceforge.net/sourceforge/configobj
PY-CONFIGOBJ_VERSION=4.3.1
PY-CONFIGOBJ_SOURCE=configobj-$(PY-CONFIGOBJ_VERSION).zip
PY-CONFIGOBJ_DIR=configobj-$(PY-CONFIGOBJ_VERSION)
PY-CONFIGOBJ_UNZIP=unzip
PY-CONFIGOBJ_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CONFIGOBJ_DESCRIPTION=A simple but powerful config file reader and writer in Python.
PY-CONFIGOBJ_SECTION=misc
PY-CONFIGOBJ_PRIORITY=optional
PY-CONFIGOBJ_DEPENDS=python
PY-CONFIGOBJ_CONFLICTS=

#
# PY-CONFIGOBJ_IPK_VERSION should be incremented when the ipk changes.
#
PY-CONFIGOBJ_IPK_VERSION=1

#
# PY-CONFIGOBJ_CONFFILES should be a list of user-editable files
#PY-CONFIGOBJ_CONFFILES=/opt/etc/py-configobj.conf /opt/etc/init.d/SXXpy-configobj

#
# PY-CONFIGOBJ_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CONFIGOBJ_PATCHES=$(PY-CONFIGOBJ_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CONFIGOBJ_CPPFLAGS=
PY-CONFIGOBJ_LDFLAGS=

#
# PY-CONFIGOBJ_BUILD_DIR is the directory in which the build is done.
# PY-CONFIGOBJ_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CONFIGOBJ_IPK_DIR is the directory in which the ipk is built.
# PY-CONFIGOBJ_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CONFIGOBJ_BUILD_DIR=$(BUILD_DIR)/py-configobj
PY-CONFIGOBJ_SOURCE_DIR=$(SOURCE_DIR)/py-configobj
PY-CONFIGOBJ_IPK_DIR=$(BUILD_DIR)/py-configobj-$(PY-CONFIGOBJ_VERSION)-ipk
PY-CONFIGOBJ_IPK=$(BUILD_DIR)/py-configobj_$(PY-CONFIGOBJ_VERSION)-$(PY-CONFIGOBJ_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CONFIGOBJ_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CONFIGOBJ_SITE)/$(PY-CONFIGOBJ_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-configobj-source: $(DL_DIR)/$(PY-CONFIGOBJ_SOURCE) $(PY-CONFIGOBJ_PATCHES)

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
$(PY-CONFIGOBJ_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CONFIGOBJ_SOURCE) $(PY-CONFIGOBJ_PATCHES) make/py-configobj.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CONFIGOBJ_DIR) $(PY-CONFIGOBJ_BUILD_DIR)
	cd $(BUILD_DIR); $(PY-CONFIGOBJ_UNZIP) $(DL_DIR)/$(PY-CONFIGOBJ_SOURCE)
#	cat $(PY-CONFIGOBJ_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CONFIGOBJ_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CONFIGOBJ_DIR) $(PY-CONFIGOBJ_BUILD_DIR)
	(cd $(PY-CONFIGOBJ_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-CONFIGOBJ_BUILD_DIR)/.configured

py-configobj-unpack: $(PY-CONFIGOBJ_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CONFIGOBJ_BUILD_DIR)/.built: $(PY-CONFIGOBJ_BUILD_DIR)/.configured
	rm -f $(PY-CONFIGOBJ_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-CONFIGOBJ_BUILD_DIR)
	touch $(PY-CONFIGOBJ_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-configobj: $(PY-CONFIGOBJ_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CONFIGOBJ_BUILD_DIR)/.staged: $(PY-CONFIGOBJ_BUILD_DIR)/.built
	rm -f $(PY-CONFIGOBJ_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CONFIGOBJ_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CONFIGOBJ_BUILD_DIR)/.staged

py-configobj-stage: $(PY-CONFIGOBJ_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-configobj
#
$(PY-CONFIGOBJ_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CONFIGOBJ_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-configobj" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CONFIGOBJ_PRIORITY)" >>$@
	@echo "Section: $(PY-CONFIGOBJ_SECTION)" >>$@
	@echo "Version: $(PY-CONFIGOBJ_VERSION)-$(PY-CONFIGOBJ_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CONFIGOBJ_MAINTAINER)" >>$@
	@echo "Source: $(PY-CONFIGOBJ_SITE)/$(PY-CONFIGOBJ_SOURCE)" >>$@
	@echo "Description: $(PY-CONFIGOBJ_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CONFIGOBJ_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CONFIGOBJ_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CONFIGOBJ_IPK_DIR)/opt/sbin or $(PY-CONFIGOBJ_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CONFIGOBJ_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CONFIGOBJ_IPK_DIR)/opt/etc/py-configobj/...
# Documentation files should be installed in $(PY-CONFIGOBJ_IPK_DIR)/opt/doc/py-configobj/...
# Daemon startup scripts should be installed in $(PY-CONFIGOBJ_IPK_DIR)/opt/etc/init.d/S??py-configobj
#
# You may need to patch your application to make it use these locations.
#
$(PY-CONFIGOBJ_IPK): $(PY-CONFIGOBJ_BUILD_DIR)/.built
	rm -rf $(PY-CONFIGOBJ_IPK_DIR) $(BUILD_DIR)/py-configobj_*_$(TARGET_ARCH).ipk
	(cd $(PY-CONFIGOBJ_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY-CONFIGOBJ_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-CONFIGOBJ_IPK_DIR)/CONTROL/control
	echo $(PY-CONFIGOBJ_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CONFIGOBJ_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CONFIGOBJ_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-configobj-ipk: $(PY-CONFIGOBJ_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-configobj-clean:
	-$(MAKE) -C $(PY-CONFIGOBJ_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-configobj-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CONFIGOBJ_DIR) $(PY-CONFIGOBJ_BUILD_DIR) $(PY-CONFIGOBJ_IPK_DIR) $(PY-CONFIGOBJ_IPK)
