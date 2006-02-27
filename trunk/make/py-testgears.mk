###########################################################
#
# py-testgears
#
###########################################################

#
# PY-TESTGEARS_VERSION, PY-TESTGEARS_SITE and PY-TESTGEARS_SOURCE define
# the upstream location of the source code for the package.
# PY-TESTGEARS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TESTGEARS_UNZIP is the command used to unzip the source.
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
PY-TESTGEARS_SITE=http://turbogears.org/download/eggs
PY-TESTGEARS_VERSION=0.2
PY-TESTGEARS_SOURCE=TestGears-$(PY-TESTGEARS_VERSION).tar.gz
PY-TESTGEARS_DIR=TestGears-$(PY-TESTGEARS_VERSION)
PY-TESTGEARS_UNZIP=zcat
PY-TESTGEARS_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-TESTGEARS_DESCRIPTION=Python module to automatically discover and run tests written as simple functions
PY-TESTGEARS_SECTION=misc
PY-TESTGEARS_PRIORITY=optional
PY-TESTGEARS_DEPENDS=python
PY-TESTGEARS_CONFLICTS=

#
# PY-TESTGEARS_IPK_VERSION should be incremented when the ipk changes.
#
PY-TESTGEARS_IPK_VERSION=2

#
# PY-TESTGEARS_CONFFILES should be a list of user-editable files
#PY-TESTGEARS_CONFFILES=/opt/etc/py-testgears.conf /opt/etc/init.d/SXXpy-testgears

#
# PY-TESTGEARS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TESTGEARS_PATCHES=$(PY-TESTGEARS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TESTGEARS_CPPFLAGS=
PY-TESTGEARS_LDFLAGS=

#
# PY-TESTGEARS_BUILD_DIR is the directory in which the build is done.
# PY-TESTGEARS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TESTGEARS_IPK_DIR is the directory in which the ipk is built.
# PY-TESTGEARS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TESTGEARS_BUILD_DIR=$(BUILD_DIR)/py-testgears
PY-TESTGEARS_SOURCE_DIR=$(SOURCE_DIR)/py-testgears
PY-TESTGEARS_IPK_DIR=$(BUILD_DIR)/py-testgears-$(PY-TESTGEARS_VERSION)-ipk
PY-TESTGEARS_IPK=$(BUILD_DIR)/py-testgears_$(PY-TESTGEARS_VERSION)-$(PY-TESTGEARS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TESTGEARS_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TESTGEARS_SITE)/$(PY-TESTGEARS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-testgears-source: $(DL_DIR)/$(PY-TESTGEARS_SOURCE) $(PY-TESTGEARS_PATCHES)

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
$(PY-TESTGEARS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TESTGEARS_SOURCE) $(PY-TESTGEARS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-TESTGEARS_DIR) $(PY-TESTGEARS_BUILD_DIR)
	$(PY-TESTGEARS_UNZIP) $(DL_DIR)/$(PY-TESTGEARS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TESTGEARS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TESTGEARS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TESTGEARS_DIR) $(PY-TESTGEARS_BUILD_DIR)
	(cd $(PY-TESTGEARS_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-TESTGEARS_BUILD_DIR)/.configured

py-testgears-unpack: $(PY-TESTGEARS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TESTGEARS_BUILD_DIR)/.built: $(PY-TESTGEARS_BUILD_DIR)/.configured
	rm -f $(PY-TESTGEARS_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-TESTGEARS_BUILD_DIR)
	touch $(PY-TESTGEARS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-testgears: $(PY-TESTGEARS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TESTGEARS_BUILD_DIR)/.staged: $(PY-TESTGEARS_BUILD_DIR)/.built
	rm -f $(PY-TESTGEARS_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-TESTGEARS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-TESTGEARS_BUILD_DIR)/.staged

py-testgears-stage: $(PY-TESTGEARS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-testgears
#
$(PY-TESTGEARS_IPK_DIR)/CONTROL/control:
	@install -d $(PY-TESTGEARS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-testgears" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TESTGEARS_PRIORITY)" >>$@
	@echo "Section: $(PY-TESTGEARS_SECTION)" >>$@
	@echo "Version: $(PY-TESTGEARS_VERSION)-$(PY-TESTGEARS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TESTGEARS_MAINTAINER)" >>$@
	@echo "Source: $(PY-TESTGEARS_SITE)/$(PY-TESTGEARS_SOURCE)" >>$@
	@echo "Description: $(PY-TESTGEARS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-TESTGEARS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TESTGEARS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TESTGEARS_IPK_DIR)/opt/sbin or $(PY-TESTGEARS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TESTGEARS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TESTGEARS_IPK_DIR)/opt/etc/py-testgears/...
# Documentation files should be installed in $(PY-TESTGEARS_IPK_DIR)/opt/doc/py-testgears/...
# Daemon startup scripts should be installed in $(PY-TESTGEARS_IPK_DIR)/opt/etc/init.d/S??py-testgears
#
# You may need to patch your application to make it use these locations.
#
$(PY-TESTGEARS_IPK): $(PY-TESTGEARS_BUILD_DIR)/.built
	rm -rf $(PY-TESTGEARS_IPK_DIR) $(BUILD_DIR)/py-testgears_*_$(TARGET_ARCH).ipk
	(cd $(PY-TESTGEARS_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-TESTGEARS_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-TESTGEARS_IPK_DIR)/CONTROL/control
	echo $(PY-TESTGEARS_CONFFILES) | sed -e 's/ /\n/g' > $(PY-TESTGEARS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-TESTGEARS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-testgears-ipk: $(PY-TESTGEARS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-testgears-clean:
	-$(MAKE) -C $(PY-TESTGEARS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-testgears-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TESTGEARS_DIR) $(PY-TESTGEARS_BUILD_DIR) $(PY-TESTGEARS_IPK_DIR) $(PY-TESTGEARS_IPK)
