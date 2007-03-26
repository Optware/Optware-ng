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
PY24-CONSTRAINT_DEPENDS=python24
PY25-CONSTRAINT_DEPENDS=python25
PY-CONSTRAINT_CONFLICTS=

#
# PY-CONSTRAINT_IPK_VERSION should be incremented when the ipk changes.
#
PY-CONSTRAINT_IPK_VERSION=3

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

PY-CONSTRAINT-DOC_IPK_DIR=$(BUILD_DIR)/py-constraint-doc-$(PY-CONSTRAINT_VERSION)-ipk
PY-CONSTRAINT-DOC_IPK=$(BUILD_DIR)/py-constraint-doc_$(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-CONSTRAINT_IPK_DIR=$(BUILD_DIR)/py-constraint-$(PY-CONSTRAINT_VERSION)-ipk
PY24-CONSTRAINT_IPK=$(BUILD_DIR)/py-constraint_$(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CONSTRAINT_IPK_DIR=$(BUILD_DIR)/py25-constraint-$(PY-CONSTRAINT_VERSION)-ipk
PY25-CONSTRAINT_IPK=$(BUILD_DIR)/py25-constraint_$(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-constraint-source py-constraint-unpack py-constraint py-constraint-stage py-constraint-ipk py-constraint-clean py-constraint-dirclean py-constraint-check

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
	rm -rf $(PY-CONSTRAINT_BUILD_DIR)
	mkdir -p $(PY-CONSTRAINT_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-CONSTRAINT_DIR)
	$(PY-CONSTRAINT_UNZIP) $(DL_DIR)/$(PY-CONSTRAINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CONSTRAINT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR)/2.4
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-CONSTRAINT_DIR)
	$(PY-CONSTRAINT_UNZIP) $(DL_DIR)/$(PY-CONSTRAINT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CONSTRAINT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR)/2.5
	touch $(PY-CONSTRAINT_BUILD_DIR)/.configured

py-constraint-unpack: $(PY-CONSTRAINT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CONSTRAINT_BUILD_DIR)/.built: $(PY-CONSTRAINT_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-CONSTRAINT_BUILD_DIR)/2.4; \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-CONSTRAINT_BUILD_DIR)/2.5; \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-constraint: $(PY-CONSTRAINT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CONSTRAINT_BUILD_DIR)/.staged: $(PY-CONSTRAINT_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-CONSTRAINT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-constraint-stage: $(PY-CONSTRAINT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-constraint
#
$(PY24-CONSTRAINT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-constraint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CONSTRAINT_PRIORITY)" >>$@
	@echo "Section: $(PY-CONSTRAINT_SECTION)" >>$@
	@echo "Version: $(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CONSTRAINT_MAINTAINER)" >>$@
	@echo "Source: $(PY-CONSTRAINT_SITE)/$(PY-CONSTRAINT_SOURCE)" >>$@
	@echo "Description: $(PY-CONSTRAINT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CONSTRAINT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CONSTRAINT_CONFLICTS)" >>$@

$(PY25-CONSTRAINT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-constraint" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CONSTRAINT_PRIORITY)" >>$@
	@echo "Section: $(PY-CONSTRAINT_SECTION)" >>$@
	@echo "Version: $(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CONSTRAINT_MAINTAINER)" >>$@
	@echo "Source: $(PY-CONSTRAINT_SITE)/$(PY-CONSTRAINT_SOURCE)" >>$@
	@echo "Description: $(PY-CONSTRAINT_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CONSTRAINT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CONSTRAINT_CONFLICTS)" >>$@

$(PY-CONSTRAINT-DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-constraint-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CONSTRAINT_PRIORITY)" >>$@
	@echo "Section: $(PY-CONSTRAINT_SECTION)" >>$@
	@echo "Version: $(PY-CONSTRAINT_VERSION)-$(PY-CONSTRAINT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CONSTRAINT_MAINTAINER)" >>$@
	@echo "Source: $(PY-CONSTRAINT_SITE)/$(PY-CONSTRAINT_SOURCE)" >>$@
	@echo "Description: $(PY-CONSTRAINT_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
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
$(PY24-CONSTRAINT_IPK): $(PY-CONSTRAINT_BUILD_DIR)/.built
	rm -rf $(PY24-CONSTRAINT_IPK_DIR) $(BUILD_DIR)/py-constraint_*_$(TARGET_ARCH).ipk
	(cd $(PY-CONSTRAINT_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
		install --root=$(PY24-CONSTRAINT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-CONSTRAINT_IPK_DIR)/CONTROL/control
#	echo $(PY-CONSTRAINT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-CONSTRAINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CONSTRAINT_IPK_DIR)

$(PY25-CONSTRAINT_IPK) $(PY-CONSTRAINT-DOC_IPK): $(PY-CONSTRAINT_BUILD_DIR)/.built
	rm -rf $(PY25-CONSTRAINT_IPK_DIR) $(BUILD_DIR)/py25-constraint_*_$(TARGET_ARCH).ipk
	(cd $(PY-CONSTRAINT_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
		install --root=$(PY25-CONSTRAINT_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-CONSTRAINT_IPK_DIR)/CONTROL/control
#	echo $(PY-CONSTRAINT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-CONSTRAINT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CONSTRAINT_IPK_DIR)
	# py-constraint-doc
	install -d $(PY-CONSTRAINT-DOC_IPK_DIR)/opt/share/doc/py-constraint/
	install $(PY-CONSTRAINT_BUILD_DIR)/2.5/README $(PY-CONSTRAINT-DOC_IPK_DIR)/opt/share/doc/py-constraint/
	cp -a $(PY-CONSTRAINT_BUILD_DIR)/2.5/examples $(PY-CONSTRAINT-DOC_IPK_DIR)/opt/share/doc/py-constraint/
	$(MAKE) $(PY-CONSTRAINT-DOC_IPK_DIR)/CONTROL/control
#	echo $(PY-CONSTRAINT_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CONSTRAINT-DOC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CONSTRAINT-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-constraint-ipk: $(PY24-CONSTRAINT_IPK) $(PY25-CONSTRAINT_IPK) $(PY-CONSTRAINT-DOC_IPK)

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
	rm -rf $(BUILD_DIR)/$(PY-CONSTRAINT_DIR) $(PY-CONSTRAINT_BUILD_DIR)
	rm -rf $(PY24-CONSTRAINT_IPK_DIR) $(PY24-CONSTRAINT_IPK)
	rm -rf $(PY25-CONSTRAINT_IPK_DIR) $(PY25-CONSTRAINT_IPK)
	rm -rf $(PY-CONSTRAINT-DOC_IPK_DIR) $(PY-CONSTRAINT-DOC_IPK)

#
# Some sanity check for the package.
#
py-constraint-check: py-constraint-ipk
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-CONSTRAINT_IPK) $(PY25-CONSTRAINT_IPK) $(PY-CONSTRAINT-DOC_IPK)
