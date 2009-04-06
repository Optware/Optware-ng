###########################################################
#
# py-simpy
#
###########################################################

#
# PY-SIMPY_VERSION, PY-SIMPY_SITE and PY-SIMPY_SOURCE define
# the upstream location of the source code for the package.
# PY-SIMPY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SIMPY_UNZIP is the command used to unzip the source.
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
PY-SIMPY_SITE=http://pypi.python.org/packages/source/S/SimPy
PY-SIMPY_VERSION=2.0.1
PY-SIMPY_SOURCE=SimPy-$(PY-SIMPY_VERSION).zip
PY-SIMPY_DIR=SimPy-$(PY-SIMPY_VERSION)
PY-SIMPY_UNZIP=unzip
PY-SIMPY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SIMPY_DESCRIPTION=An object-oriented, process-based discrete-event simulation language based on standard Python.
PY-SIMPY_SECTION=misc
PY-SIMPY_PRIORITY=optional
PY25-SIMPY_DEPENDS=python25
PY26-SIMPY_DEPENDS=python26
PY-SIMPY_SUGGESTS=py-simpy-doc
PY-SIMPY_CONFLICTS=

#
# PY-SIMPY_IPK_VERSION should be incremented when the ipk changes.
#
PY-SIMPY_IPK_VERSION=1

#
# PY-SIMPY_CONFFILES should be a list of user-editable files
#PY-SIMPY_CONFFILES=/opt/etc/py-simpy.conf /opt/etc/init.d/SXXpy-simpy

#
# PY-SIMPY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-SIMPY_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SIMPY_CPPFLAGS=
PY-SIMPY_LDFLAGS=

#
# PY-SIMPY_BUILD_DIR is the directory in which the build is done.
# PY-SIMPY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SIMPY_IPK_DIR is the directory in which the ipk is built.
# PY-SIMPY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SIMPY_BUILD_DIR=$(BUILD_DIR)/py-simpy
PY-SIMPY_SOURCE_DIR=$(SOURCE_DIR)/py-simpy

PY25-SIMPY_IPK_DIR=$(BUILD_DIR)/py25-simpy-$(PY-SIMPY_VERSION)-ipk
PY25-SIMPY_IPK=$(BUILD_DIR)/py25-simpy_$(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-SIMPY_IPK_DIR=$(BUILD_DIR)/py26-simpy-$(PY-SIMPY_VERSION)-ipk
PY26-SIMPY_IPK=$(BUILD_DIR)/py26-simpy_$(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-SIMPY-DOC_IPK_DIR=$(BUILD_DIR)/py-simpy-doc-$(PY-SIMPY_VERSION)-ipk
PY-SIMPY-DOC_IPK=$(BUILD_DIR)/py-simpy-doc_$(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-simpy-source py-simpy-unpack py-simpy py-simpy-stage py-simpy-ipk py-simpy-clean py-simpy-dirclean py-simpy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SIMPY_SOURCE):
	$(WGET) -P $(@D) $(PY-SIMPY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-simpy-source: $(DL_DIR)/$(PY-SIMPY_SOURCE) $(PY-SIMPY_PATCHES)

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
$(PY-SIMPY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SIMPY_SOURCE) $(PY-SIMPY_PATCHES) make/py-simpy.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-SIMPY_DIR)
	cd $(BUILD_DIR); $(PY-SIMPY_UNZIP) $(DL_DIR)/$(PY-SIMPY_SOURCE)
#	cat $(PY-SIMPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SIMPY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIMPY_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-SIMPY_DIR)
	cd $(BUILD_DIR); $(PY-SIMPY_UNZIP) $(DL_DIR)/$(PY-SIMPY_SOURCE)
#	cat $(PY-SIMPY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SIMPY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIMPY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	touch $@

py-simpy-unpack: $(PY-SIMPY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SIMPY_BUILD_DIR)/.built: $(PY-SIMPY_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build;
	cd $(@D)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build;
	touch $@

#
# This is the build convenience target.
#
py-simpy: $(PY-SIMPY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-SIMPY_BUILD_DIR)/.staged: $(PY-SIMPY_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(PY-SIMPY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-simpy-stage: $(PY-SIMPY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-simpy
#
$(PY25-SIMPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-simpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPY_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPY_SECTION)" >>$@
	@echo "Version: $(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPY_SITE)/$(PY-SIMPY_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SIMPY_DEPENDS)" >>$@
	@echo "Suggests: $(PY-SIMPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-SIMPY_CONFLICTS)" >>$@

$(PY26-SIMPY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-simpy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPY_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPY_SECTION)" >>$@
	@echo "Version: $(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPY_SITE)/$(PY-SIMPY_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-SIMPY_DEPENDS)" >>$@
	@echo "Suggests: $(PY-SIMPY_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-SIMPY_CONFLICTS)" >>$@

$(PY-SIMPY-DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-simpy-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPY_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPY_SECTION)" >>$@
	@echo "Version: $(PY-SIMPY_VERSION)-$(PY-SIMPY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPY_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPY_SITE)/$(PY-SIMPY_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPY_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-SIMPY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SIMPY_IPK_DIR)/opt/sbin or $(PY-SIMPY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SIMPY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SIMPY_IPK_DIR)/opt/etc/py-simpy/...
# Documentation files should be installed in $(PY-SIMPY_IPK_DIR)/opt/doc/py-simpy/...
# Daemon startup scripts should be installed in $(PY-SIMPY_IPK_DIR)/opt/etc/init.d/S??py-simpy
#
# You may need to patch your application to make it use these locations.
#
$(PY25-SIMPY_IPK): $(PY-SIMPY_BUILD_DIR)/.built
	rm -rf $(PY25-SIMPY_IPK_DIR) $(BUILD_DIR)/py-simpy_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIMPY_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-SIMPY_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY25-SIMPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SIMPY_IPK_DIR)

$(PY26-SIMPY_IPK): $(PY-SIMPY_BUILD_DIR)/.built
	rm -rf $(PY26-SIMPY_IPK_DIR) $(BUILD_DIR)/py26-simpy_*_$(TARGET_ARCH).ipk
	(cd $(PY-SIMPY_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-SIMPY_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY26-SIMPY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-SIMPY_IPK_DIR)

$(PY-SIMPY-DOC_IPK): $(PY-SIMPY_BUILD_DIR)/.built
	rm -rf $(PY-SIMPY-DOC_IPK_DIR) $(BUILD_DIR)/py-simpy-doc_*_$(TARGET_ARCH).ipk
	install -d $(PY-SIMPY-DOC_IPK_DIR)/opt/share/doc/SimPy/
	install -m 644 $(PY-SIMPY_BUILD_DIR)/2.6/PKG-INFO $(PY-SIMPY-DOC_IPK_DIR)/opt/share/doc/SimPy/
	cp -rp $(PY-SIMPY_BUILD_DIR)/2.6/LGPLlicense_files $(PY-SIMPY-DOC_IPK_DIR)/opt/share/doc/SimPy/
	cp -rp $(PY-SIMPY_BUILD_DIR)/2.6/SimPyDocs $(PY-SIMPY-DOC_IPK_DIR)/opt/share/doc/SimPy/
	cp -rp $(PY-SIMPY_BUILD_DIR)/2.6/SimPyModels $(PY-SIMPY-DOC_IPK_DIR)/opt/share/doc/SimPy/
	$(MAKE) $(PY-SIMPY-DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SIMPY-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-simpy-ipk: $(PY25-SIMPY_IPK) $(PY26-SIMPY_IPK) $(PY-SIMPY-DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-simpy-clean:
	-$(MAKE) -C $(PY-SIMPY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-simpy-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SIMPY_DIR) $(PY-SIMPY_BUILD_DIR)
	rm -rf $(PY25-SIMPY_IPK_DIR) $(PY25-SIMPY_IPK)
	rm -rf $(PY26-SIMPY_IPK_DIR) $(PY26-SIMPY_IPK)
	rm -rf $(PY-SIMPY-DOC_IPK_DIR) $(PY-SIMPY-DOC_IPK)

#
# Some sanity check for the package.
#
py-simpy-check: $(PY25-SIMPY_IPK) $(PY26-SIMPY_IPK) $(PY-SIMPY-DOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
