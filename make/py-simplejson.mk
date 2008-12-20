###########################################################
#
# py-simplejson
#
###########################################################

#
# PY-SIMPLEJSON_VERSION, PY-SIMPLEJSON_SITE and PY-SIMPLEJSON_SOURCE define
# the upstream location of the source code for the package.
# PY-SIMPLEJSON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SIMPLEJSON_UNZIP is the command used to unzip the source.
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
PY-SIMPLEJSON_SITE=http://pypi.python.org/packages/source/s/simplejson
PY-SIMPLEJSON_VERSION=2.0.6
PY-SIMPLEJSON_SOURCE=simplejson-$(PY-SIMPLEJSON_VERSION).tar.gz
PY-SIMPLEJSON_DIR=simplejson-$(PY-SIMPLEJSON_VERSION)
PY-SIMPLEJSON_UNZIP=zcat
PY-SIMPLEJSON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-SIMPLEJSON_DESCRIPTION=Simple, fast, extensible JSON encoder/decoder for Python.
PY-SIMPLEJSON_SECTION=misc
PY-SIMPLEJSON_PRIORITY=optional
PY24-SIMPLEJSON_DEPENDS=python24
PY25-SIMPLEJSON_DEPENDS=python25
PY-SIMPLEJSON_CONFLICTS=

#
# PY-SIMPLEJSON_IPK_VERSION should be incremented when the ipk changes.
#
PY-SIMPLEJSON_IPK_VERSION=1

#
# PY-SIMPLEJSON_CONFFILES should be a list of user-editable files
#PY-SIMPLEJSON_CONFFILES=/opt/etc/py-simplejson.conf /opt/etc/init.d/SXXpy-simplejson

#
# PY-SIMPLEJSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SIMPLEJSON_PATCHES=$(PY-SIMPLEJSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SIMPLEJSON_CPPFLAGS=
PY-SIMPLEJSON_LDFLAGS=

#
# PY-SIMPLEJSON_BUILD_DIR is the directory in which the build is done.
# PY-SIMPLEJSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SIMPLEJSON_IPK_DIR is the directory in which the ipk is built.
# PY-SIMPLEJSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SIMPLEJSON_BUILD_DIR=$(BUILD_DIR)/py-simplejson
PY-SIMPLEJSON_SOURCE_DIR=$(SOURCE_DIR)/py-simplejson

PY24-SIMPLEJSON_IPK_DIR=$(BUILD_DIR)/py24-simplejson-$(PY-SIMPLEJSON_VERSION)-ipk
PY24-SIMPLEJSON_IPK=$(BUILD_DIR)/py24-simplejson_$(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-SIMPLEJSON_IPK_DIR=$(BUILD_DIR)/py25-simplejson-$(PY-SIMPLEJSON_VERSION)-ipk
PY25-SIMPLEJSON_IPK=$(BUILD_DIR)/py25-simplejson_$(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-simplejson-source py-simplejson-unpack py-simplejson py-simplejson-stage py-simplejson-ipk py-simplejson-clean py-simplejson-dirclean py-simplejson-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SIMPLEJSON_SOURCE):
	$(WGET) -P $(@D) $(PY-SIMPLEJSON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-simplejson-source: $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) $(PY-SIMPLEJSON_PATCHES)

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
$(PY-SIMPLEJSON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) $(PY-SIMPLEJSON_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR)
	$(PY-SIMPLEJSON_UNZIP) $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIMPLEJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR)
	$(PY-SIMPLEJSON_UNZIP) $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIMPLEJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-simplejson-unpack: $(PY-SIMPLEJSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SIMPLEJSON_BUILD_DIR)/.built: $(PY-SIMPLEJSON_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(@D)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-simplejson: $(PY-SIMPLEJSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SIMPLEJSON_BUILD_DIR)/.staged: $(PY-SIMPLEJSON_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-simplejson-stage: $(PY-SIMPLEJSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-simplejson
#
$(PY24-SIMPLEJSON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-simplejson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPLEJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPLEJSON_SECTION)" >>$@
	@echo "Version: $(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPLEJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPLEJSON_SITE)/$(PY-SIMPLEJSON_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPLEJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-SIMPLEJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIMPLEJSON_CONFLICTS)" >>$@

$(PY25-SIMPLEJSON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-simplejson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPLEJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPLEJSON_SECTION)" >>$@
	@echo "Version: $(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPLEJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPLEJSON_SITE)/$(PY-SIMPLEJSON_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPLEJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-SIMPLEJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIMPLEJSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SIMPLEJSON_IPK_DIR)/opt/sbin or $(PY-SIMPLEJSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SIMPLEJSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/py-simplejson/...
# Documentation files should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/doc/py-simplejson/...
# Daemon startup scripts should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/init.d/S??py-simplejson
#
# You may need to patch your application to make it use these locations.
#
$(PY24-SIMPLEJSON_IPK): $(PY-SIMPLEJSON_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-simplejson_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-SIMPLEJSON_IPK_DIR) $(BUILD_DIR)/py24-simplejson_*_$(TARGET_ARCH).ipk
	cd $(PY-SIMPLEJSON_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-SIMPLEJSON_IPK_DIR) --prefix=/opt
	$(STRIP_COMMAND) $(PY24-SIMPLEJSON_IPK_DIR)/opt/lib/python2.4/site-packages/simplejson/*.so
	$(MAKE) $(PY24-SIMPLEJSON_IPK_DIR)/CONTROL/control
#	echo $(PY-SIMPLEJSON_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-SIMPLEJSON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-SIMPLEJSON_IPK_DIR)

$(PY25-SIMPLEJSON_IPK): $(PY-SIMPLEJSON_BUILD_DIR)/.built
	rm -rf $(PY25-SIMPLEJSON_IPK_DIR) $(BUILD_DIR)/py25-simplejson_*_$(TARGET_ARCH).ipk
	cd $(PY-SIMPLEJSON_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-SIMPLEJSON_IPK_DIR) --prefix=/opt
	$(STRIP_COMMAND) $(PY25-SIMPLEJSON_IPK_DIR)/opt/lib/python2.5/site-packages/simplejson/*.so
	$(MAKE) $(PY25-SIMPLEJSON_IPK_DIR)/CONTROL/control
#	echo $(PY-SIMPLEJSON_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-SIMPLEJSON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-SIMPLEJSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-simplejson-ipk: $(PY24-SIMPLEJSON_IPK) $(PY25-SIMPLEJSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-simplejson-clean:
	-$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-simplejson-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(PY-SIMPLEJSON_BUILD_DIR)
	rm -rf $(PY24-SIMPLEJSON_IPK_DIR) $(PY24-SIMPLEJSON_IPK)
	rm -rf $(PY25-SIMPLEJSON_IPK_DIR) $(PY25-SIMPLEJSON_IPK)

#
# Some sanity check for the package.
#
py-simplejson-check: $(PY24-SIMPLEJSON_IPK) $(PY25-SIMPLEJSON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-SIMPLEJSON_IPK) $(PY25-SIMPLEJSON_IPK)
