###########################################################
#
# py-celementtree
#
###########################################################

#
# PY-CELEMENTTREE_VERSION, PY-CELEMENTTREE_SITE and PY-CELEMENTTREE_SOURCE define
# the upstream location of the source code for the package.
# PY-CELEMENTTREE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CELEMENTTREE_UNZIP is the command used to unzip the source.
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
PY-CELEMENTTREE_SITE=http://effbot.org/downloads
PY-CELEMENTTREE_VERSION=1.0.5-20051216
PY-CELEMENTTREE_SOURCE=cElementTree-$(PY-CELEMENTTREE_VERSION).tar.gz
PY-CELEMENTTREE_DIR=cElementTree-$(PY-CELEMENTTREE_VERSION)
PY-CELEMENTTREE_UNZIP=zcat
PY-CELEMENTTREE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CELEMENTTREE_DESCRIPTION=A toolkit that contains a number of light-weight components for working with XML (C implementation).
PY-CELEMENTTREE_SECTION=misc
PY-CELEMENTTREE_PRIORITY=optional
PY24-CELEMENTTREE_DEPENDS=python24, py24-elementtree
PY25-CELEMENTTREE_DEPENDS=python25, py25-elementtree
PY-CELEMENTTREE_CONFLICTS=

#
# PY-CELEMENTTREE_IPK_VERSION should be incremented when the ipk changes.
#
PY-CELEMENTTREE_IPK_VERSION=5

#
# PY-CELEMENTTREE_CONFFILES should be a list of user-editable files
#PY-CELEMENTTREE_CONFFILES=/opt/etc/py-celementtree.conf /opt/etc/init.d/SXXpy-celementtree

#
# PY-CELEMENTTREE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CELEMENTTREE_PATCHES=$(PY-CELEMENTTREE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CELEMENTTREE_CPPFLAGS=
PY-CELEMENTTREE_LDFLAGS=

#
# PY-CELEMENTTREE_BUILD_DIR is the directory in which the build is done.
# PY-CELEMENTTREE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CELEMENTTREE_IPK_DIR is the directory in which the ipk is built.
# PY-CELEMENTTREE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CELEMENTTREE_BUILD_DIR=$(BUILD_DIR)/py-celementtree
PY-CELEMENTTREE_SOURCE_DIR=$(SOURCE_DIR)/py-celementtree

PY24-CELEMENTTREE_IPK_DIR=$(BUILD_DIR)/py24-celementtree-$(PY-CELEMENTTREE_VERSION)-ipk
PY24-CELEMENTTREE_IPK=$(BUILD_DIR)/py24-celementtree_$(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CELEMENTTREE_IPK_DIR=$(BUILD_DIR)/py25-celementtree-$(PY-CELEMENTTREE_VERSION)-ipk
PY25-CELEMENTTREE_IPK=$(BUILD_DIR)/py25-celementtree_$(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-celementtree-source py-celementtree-unpack py-celementtree py-celementtree-stage py-celementtree-ipk py-celementtree-clean py-celementtree-dirclean py-celementtree-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CELEMENTTREE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CELEMENTTREE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-celementtree-source: $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) $(PY-CELEMENTTREE_PATCHES)

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
$(PY-CELEMENTTREE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) $(PY-CELEMENTTREE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-CELEMENTTREE_BUILD_DIR)
	mkdir -p $(PY-CELEMENTTREE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR)
	$(PY-CELEMENTTREE_UNZIP) $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CELEMENTTREE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR)/2.4
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.4; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") > setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR)
	$(PY-CELEMENTTREE_UNZIP) $(DL_DIR)/$(PY-CELEMENTTREE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CELEMENTTREE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR)/2.5
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.5; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") > setup.cfg \
	)
	touch $@

py-celementtree-unpack: $(PY-CELEMENTTREE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CELEMENTTREE_BUILD_DIR)/.built: $(PY-CELEMENTTREE_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR)
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-celementtree: $(PY-CELEMENTTREE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CELEMENTTREE_BUILD_DIR)/.staged: $(PY-CELEMENTTREE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-celementtree-stage: $(PY-CELEMENTTREE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-celementtree
#
$(PY24-CELEMENTTREE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-celementtree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CELEMENTTREE_PRIORITY)" >>$@
	@echo "Section: $(PY-CELEMENTTREE_SECTION)" >>$@
	@echo "Version: $(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CELEMENTTREE_MAINTAINER)" >>$@
	@echo "Source: $(PY-CELEMENTTREE_SITE)/$(PY-CELEMENTTREE_SOURCE)" >>$@
	@echo "Description: $(PY-CELEMENTTREE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CELEMENTTREE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CELEMENTTREE_CONFLICTS)" >>$@

$(PY25-CELEMENTTREE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-celementtree" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CELEMENTTREE_PRIORITY)" >>$@
	@echo "Section: $(PY-CELEMENTTREE_SECTION)" >>$@
	@echo "Version: $(PY-CELEMENTTREE_VERSION)-$(PY-CELEMENTTREE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CELEMENTTREE_MAINTAINER)" >>$@
	@echo "Source: $(PY-CELEMENTTREE_SITE)/$(PY-CELEMENTTREE_SOURCE)" >>$@
	@echo "Description: $(PY-CELEMENTTREE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CELEMENTTREE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CELEMENTTREE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CELEMENTTREE_IPK_DIR)/opt/sbin or $(PY-CELEMENTTREE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CELEMENTTREE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/py-celementtree/...
# Documentation files should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/doc/py-celementtree/...
# Daemon startup scripts should be installed in $(PY-CELEMENTTREE_IPK_DIR)/opt/etc/init.d/S??py-celementtree
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CELEMENTTREE_IPK): $(PY-CELEMENTTREE_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-celementtree_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-CELEMENTTREE_IPK_DIR) $(BUILD_DIR)/py24-celementtree_*_$(TARGET_ARCH).ipk
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY24-CELEMENTTREE_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) $(PY24-CELEMENTTREE_IPK_DIR)/opt/lib/python2.4/site-packages/*.so
	$(MAKE) $(PY24-CELEMENTTREE_IPK_DIR)/CONTROL/control
#	echo $(PY-CELEMENTTREE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-CELEMENTTREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CELEMENTTREE_IPK_DIR)

$(PY25-CELEMENTTREE_IPK): $(PY-CELEMENTTREE_BUILD_DIR)/.built
	rm -rf $(PY25-CELEMENTTREE_IPK_DIR) $(BUILD_DIR)/py25-celementtree_*_$(TARGET_ARCH).ipk
	(cd $(PY-CELEMENTTREE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	install --root=$(PY25-CELEMENTTREE_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) $(PY25-CELEMENTTREE_IPK_DIR)/opt/lib/python2.5/site-packages/*.so
	$(MAKE) $(PY25-CELEMENTTREE_IPK_DIR)/CONTROL/control
#	echo $(PY-CELEMENTTREE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-CELEMENTTREE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CELEMENTTREE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-celementtree-ipk: $(PY24-CELEMENTTREE_IPK) $(PY25-CELEMENTTREE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-celementtree-clean:
	-$(MAKE) -C $(PY-CELEMENTTREE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-celementtree-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CELEMENTTREE_DIR) $(PY-CELEMENTTREE_BUILD_DIR)
	rm -rf $(PY24-CELEMENTTREE_IPK_DIR) $(PY24-CELEMENTTREE_IPK)
	rm -rf $(PY25-CELEMENTTREE_IPK_DIR) $(PY25-CELEMENTTREE_IPK)

#
# Some sanity check for the package.
#
py-celementtree-check: $(PY24-CELEMENTTREE_IPK) $(PY25-CELEMENTTREE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-CELEMENTTREE_IPK) $(PY25-CELEMENTTREE_IPK)
