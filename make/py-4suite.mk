###########################################################
#
# py-4suite
#
###########################################################

#
# PY-4SUITE_VERSION, PY-4SUITE_SITE and PY-4SUITE_SOURCE define
# the upstream location of the source code for the package.
# PY-4SUITE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-4SUITE_UNZIP is the command used to unzip the source.
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
PY-4SUITE_SITE=http://pypi.python.org/packages/source/4/4Suite-XML
PY-4SUITE_VERSION=1.0.2
PY-4SUITE_SOURCE=4Suite-XML-$(PY-4SUITE_VERSION).tar.gz
PY-4SUITE_DIR=4Suite-XML-$(PY-4SUITE_VERSION)
PY-4SUITE_UNZIP=zcat
PY-4SUITE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-4SUITE_DESCRIPTION=Python-based toolkit for XML and RDF application development.
PY-4SUITE_SECTION=misc
PY-4SUITE_PRIORITY=optional
PY24-4SUITE_DEPENDS=python24
PY25-4SUITE_DEPENDS=python25
PY-4SUITE_CONFLICTS=

#
# PY-4SUITE_IPK_VERSION should be incremented when the ipk changes.
#
PY-4SUITE_IPK_VERSION=2

#
# PY-4SUITE_CONFFILES should be a list of user-editable files
#PY-4SUITE_CONFFILES=/opt/etc/py-4suite.conf /opt/etc/init.d/SXXpy-4suite

#
# PY-4SUITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-4SUITE_PATCHES=$(PY-4SUITE_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-4SUITE_CPPFLAGS=
PY-4SUITE_LDFLAGS=

#
# PY-4SUITE_BUILD_DIR is the directory in which the build is done.
# PY-4SUITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-4SUITE_IPK_DIR is the directory in which the ipk is built.
# PY-4SUITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-4SUITE_BUILD_DIR=$(BUILD_DIR)/py-4suite
PY-4SUITE_SOURCE_DIR=$(SOURCE_DIR)/py-4suite

PY24-4SUITE_IPK_DIR=$(BUILD_DIR)/py24-4suite-$(PY-4SUITE_VERSION)-ipk
PY24-4SUITE_IPK=$(BUILD_DIR)/py24-4suite_$(PY-4SUITE_VERSION)-$(PY-4SUITE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-4SUITE_IPK_DIR=$(BUILD_DIR)/py25-4suite-$(PY-4SUITE_VERSION)-ipk
PY25-4SUITE_IPK=$(BUILD_DIR)/py25-4suite_$(PY-4SUITE_VERSION)-$(PY-4SUITE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-4suite-source py-4suite-unpack py-4suite py-4suite-stage py-4suite-ipk py-4suite-clean py-4suite-dirclean py-4suite-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-4SUITE_SOURCE):
	$(WGET) -P $(@D) $(PY-4SUITE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-4suite-source: $(DL_DIR)/$(PY-4SUITE_SOURCE) $(PY-4SUITE_PATCHES)

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
$(PY-4SUITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-4SUITE_SOURCE) $(PY-4SUITE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-4SUITE_DIR)
	$(PY-4SUITE_UNZIP) $(DL_DIR)/$(PY-4SUITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-4SUITE_PATCHES)"; then \
	    cat $(PY-4SUITE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-4SUITE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-4SUITE_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	    ; \
	    sed -i -e "s/return.*has_docs()/return False/" Ft/Lib/DistExt/Build.py; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-4SUITE_DIR)
	$(PY-4SUITE_UNZIP) $(DL_DIR)/$(PY-4SUITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-4SUITE_PATCHES)"; then \
	    cat $(PY-4SUITE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-4SUITE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-4SUITE_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg \
	    ; \
	    sed -i -e "s/return.*has_docs()/return False/" Ft/Lib/DistExt/Build.py; \
	)
	touch $@

py-4suite-unpack: $(PY-4SUITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-4SUITE_BUILD_DIR)/.built: $(PY-4SUITE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-4suite: $(PY-4SUITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-4SUITE_BUILD_DIR)/.staged: $(PY-4SUITE_BUILD_DIR)/.built
#	rm -f $(PY-4SUITE_BUILD_DIR)/.staged
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $(PY-4SUITE_BUILD_DIR)/.staged

py-4suite-stage: $(PY-4SUITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-4suite
#
$(PY24-4SUITE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-4suite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-4SUITE_PRIORITY)" >>$@
	@echo "Section: $(PY-4SUITE_SECTION)" >>$@
	@echo "Version: $(PY-4SUITE_VERSION)-$(PY-4SUITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-4SUITE_MAINTAINER)" >>$@
	@echo "Source: $(PY-4SUITE_SITE)/$(PY-4SUITE_SOURCE)" >>$@
	@echo "Description: $(PY-4SUITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-4SUITE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-4SUITE_CONFLICTS)" >>$@

$(PY25-4SUITE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-4suite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-4SUITE_PRIORITY)" >>$@
	@echo "Section: $(PY-4SUITE_SECTION)" >>$@
	@echo "Version: $(PY-4SUITE_VERSION)-$(PY-4SUITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-4SUITE_MAINTAINER)" >>$@
	@echo "Source: $(PY-4SUITE_SITE)/$(PY-4SUITE_SOURCE)" >>$@
	@echo "Description: $(PY-4SUITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-4SUITE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-4SUITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-4SUITE_IPK_DIR)/opt/sbin or $(PY-4SUITE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-4SUITE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-4SUITE_IPK_DIR)/opt/etc/py-4suite/...
# Documentation files should be installed in $(PY-4SUITE_IPK_DIR)/opt/doc/py-4suite/...
# Daemon startup scripts should be installed in $(PY-4SUITE_IPK_DIR)/opt/etc/init.d/S??py-4suite
#
# You may need to patch your application to make it use these locations.
#
$(PY24-4SUITE_IPK): $(PY-4SUITE_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-4suite_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-4SUITE_IPK_DIR) $(BUILD_DIR)/py24-4suite_*_$(TARGET_ARCH).ipk
	(cd $(PY-4SUITE_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	--root=$(PY24-4SUITE_IPK_DIR) --prefix=/opt --without-docs)
	$(STRIP_COMMAND) `find $(PY24-4SUITE_IPK_DIR)/opt/lib/ -name '*.so'`
	sed -i -e '1s|#!/usr/bin/env python|#!/opt/bin/python2.4|' $(PY24-4SUITE_IPK_DIR)/opt/bin/*
	$(MAKE) $(PY24-4SUITE_IPK_DIR)/CONTROL/control
#	echo $(PY-4SUITE_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-4SUITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-4SUITE_IPK_DIR)

$(PY25-4SUITE_IPK): $(PY-4SUITE_BUILD_DIR)/.built
	rm -rf $(PY25-4SUITE_IPK_DIR) $(BUILD_DIR)/py25-4suite_*_$(TARGET_ARCH).ipk
	(cd $(PY-4SUITE_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	--root=$(PY25-4SUITE_IPK_DIR) --prefix=/opt --without-docs)
	$(STRIP_COMMAND) `find $(PY25-4SUITE_IPK_DIR)/opt/lib/ -name '*.so'`
	sed -i -e '1s|#!/usr/bin/env python|#!/opt/bin/python2.5|' $(PY25-4SUITE_IPK_DIR)/opt/bin/*
	$(MAKE) $(PY25-4SUITE_IPK_DIR)/CONTROL/control
#	echo $(PY-4SUITE_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-4SUITE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-4SUITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-4suite-ipk: $(PY24-4SUITE_IPK) $(PY25-4SUITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-4suite-clean:
	-$(MAKE) -C $(PY-4SUITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-4suite-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-4SUITE_DIR) $(PY-4SUITE_BUILD_DIR)
	rm -rf $(PY24-4SUITE_IPK_DIR) $(PY24-4SUITE_IPK)
	rm -rf $(PY25-4SUITE_IPK_DIR) $(PY25-4SUITE_IPK)

#
# Some sanity check for the package.
#
py-4suite-check: $(PY24-4SUITE_IPK) $(PY25-4SUITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-4SUITE_IPK) $(PY25-4SUITE_IPK)
