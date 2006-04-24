###########################################################
#
# py-constraint
#
###########################################################

#
# PY-CONSTRAINT_VERSION, PY-CONSTRAINT_SITE and PY-CONSTRAINT_SOURCE define
# the upstream location of the source code for the package.
# PY-CONSTRAINT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CONSTRAINT_UNZIP is the command used to unzip the source.
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
PY-CONSTRAINT_SITE=http://labix.org/download/python-constraint
PY-CONSTRAINT_VERSION=1.1
PY-CONSTRAINT_SOURCE=python-constraint-$(PY-CONSTRAINT_VERSION).tar.bz2
PY-CONSTRAINT_DIR=python-constraint-$(PY-CONSTRAINT_VERSION)
PY-CONSTRAINT_UNZIP=bzcat
PY-CONSTRAINT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CONSTRAINT_DESCRIPTION=A Python module offering solvers for Constraint Solving Problems (CSPs) over finite domains in simple and pure Python.
PY-CONSTRAINT_SECTION=misc
PY-CONSTRAINT_PRIORITY=optional
PY-CONSTRAINT_DEPENDS=python
PY-CONSTRAINT_CONFLICTS=

#
# PY-CONSTRAINT_IPK_VERSION should be incremented when the ipk changes.
#
PY-CONSTRAINT_IPK_VERSION=1

#
# PY-CONSTRAINT_CONFFILES should be a list of user-editable files
#PY-CONSTRAINT_CONFFILES=/opt/etc/py-constraint.conf /opt/etc/init.d/SXXpy-constraint

#
# PY-CONSTRAINT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CONSTRAINT_PATCHES=$(PY-CONSTRAINT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CONSTRAINT_CPPFLAGS=
PY-CONSTRAINT_LDFLAGS=

#
# PY-CONSTRAINT_BUILD_DIR is the directory in which the build is done.
# PY-CONSTRAINT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CONSTRAINT_IPK_DIR is the directory in which the ipk is built.
# PY-CONSTRAINT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CONSTRAINT_BUILD_DIR=$(BUILD_DIR)/py-constraint
PY-CONSTRAINT_SOURCE_DIR=$(SOURCE_DIR)/py-constraint
PY-CONSTRAINT_IPK_DIR=$(BUILD_DIR)/py-constraint-$(PY-CONSTRAINT_VERSION)-ipk
PY-CONSTRAINT_IPK=$(BUILD_DIR)/py-constraint_$(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CONSTRAINT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CONSTRAINT_SITE)/$(PY-CONSTRAINT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-constraint-source: $(DL_DIR)/$(PY-CONSTRAINT_SOURCE) $(PY-CONSTRAINT_PATCHES)

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
$(PY-CONSTRAINT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CONSTRAINT_SOURCE) $(PY-CONSTRAINT_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR)
	$(PY-CONSTRAINT_UNZIP) $(DL_DIR)/$(PY-CONSTRAINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CONSTRAINT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR)
	touch $(PY-CONSTRAINT_BUILD_DIR)/.configured

py-constraint-unpack: $(PY-CONSTRAINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CONSTRAINT_BUILD_DIR)/.built: $(PY-CONSTRAINT_BUILD_DIR)/.configured
	rm -f $(PY-CONSTRAINT_BUILD_DIR)/.built
	(cd $(PY-CONSTRAINT_BUILD_DIR); python2.4 setup.py build; )
	touch $(PY-CONSTRAINT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-constraint: $(PY-CONSTRAINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CONSTRAINT_BUILD_DIR)/.staged: $(PY-CONSTRAINT_BUILD_DIR)/.built
	rm -f $(PY-CONSTRAINT_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CONSTRAINT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CONSTRAINT_BUILD_DIR)/.staged

py-constraint-stage: $(PY-CONSTRAINT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-constraint
#
$(PY-CONSTRAINT_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CONSTRAINT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-constraint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CONSTRAINT_PRIORITY)" >>$@
	@echo "Section: $(PY-CONSTRAINT_SECTION)" >>$@
	@echo "Version: $(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CONSTRAINT_MAINTAINER)" >>$@
	@echo "Source: $(PY-CONSTRAINT_SITE)/$(PY-CONSTRAINT_SOURCE)" >>$@
	@echo "Description: $(PY-CONSTRAINT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CONSTRAINT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CONSTRAINT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CONSTRAINT_IPK_DIR)/opt/sbin or $(PY-CONSTRAINT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CONSTRAINT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CONSTRAINT_IPK_DIR)/opt/etc/py-constraint/...
# Documentation files should be installed in $(PY-CONSTRAINT_IPK_DIR)/opt/doc/py-constraint/...
# Daemon startup scripts should be installed in $(PY-CONSTRAINT_IPK_DIR)/opt/etc/init.d/S??py-constraint
#
# You may need to patch your application to make it use these locations.
#
$(PY-CONSTRAINT_IPK): $(PY-CONSTRAINT_BUILD_DIR)/.built
	rm -rf $(PY-CONSTRAINT_IPK_DIR) $(BUILD_DIR)/py-constraint_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-CONSTRAINT_BUILD_DIR) DESTDIR=$(PY-CONSTRAINT_IPK_DIR) install
	(cd $(PY-CONSTRAINT_BUILD_DIR); \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 -c "import setuptools; execfile('setup.py')" \
		install --root=$(PY-CONSTRAINT_IPK_DIR) --prefix=/opt --single-version-externally-managed)
#	$(STRIP_COMMAND) `find $(PY-CONSTRAINT_IPK_DIR)/opt/lib/ -name '*.so'`
#	install -d $(PY-CONSTRAINT_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-CONSTRAINT_SOURCE_DIR)/py-constraint.conf $(PY-CONSTRAINT_IPK_DIR)/opt/etc/py-constraint.conf
#	install -d $(PY-CONSTRAINT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-CONSTRAINT_SOURCE_DIR)/rc.py-constraint $(PY-CONSTRAINT_IPK_DIR)/opt/etc/init.d/SXXpy-constraint
	$(MAKE) $(PY-CONSTRAINT_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-CONSTRAINT_SOURCE_DIR)/postinst $(PY-CONSTRAINT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-CONSTRAINT_SOURCE_DIR)/prerm $(PY-CONSTRAINT_IPK_DIR)/CONTROL/prerm
#	echo $(PY-CONSTRAINT_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CONSTRAINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CONSTRAINT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-constraint-ipk: $(PY-CONSTRAINT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-constraint-clean:
	-$(MAKE) -C $(PY-CONSTRAINT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-constraint-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR) $(PY-CONSTRAINT_IPK_DIR) $(PY-CONSTRAINT_IPK)
