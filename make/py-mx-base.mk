###########################################################
#
# py-mx-base
#
###########################################################

#
# PY-MX-BASE_VERSION, PY-MX-BASE_SITE and PY-MX-BASE_SOURCE define
# the upstream location of the source code for the package.
# PY-MX-BASE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MX-BASE_UNZIP is the command used to unzip the source.
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
PY-MX-BASE_SITE=http://www.egenix.com/files/python
PY-MX-BASE_VERSION=3.1.1
PY-MX-BASE_SOURCE=egenix-mx-base-$(PY-MX-BASE_VERSION).tar.gz
PY-MX-BASE_DIR=egenix-mx-base-$(PY-MX-BASE_VERSION)
PY-MX-BASE_UNZIP=zcat
PY-MX-BASE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MX-BASE_DESCRIPTION=A collection of userful open source python packages from eGenix.com.
PY-MX-BASE_SECTION=misc
PY-MX-BASE_PRIORITY=optional
PY24-MX-BASE_DEPENDS=python24
PY25-MX-BASE_DEPENDS=python25
PY-MX-BASE_CONFLICTS=

#
# PY-MX-BASE_IPK_VERSION should be incremented when the ipk changes.
#
PY-MX-BASE_IPK_VERSION=1

#
# PY-MX-BASE_CONFFILES should be a list of user-editable files
#PY-MX-BASE_CONFFILES=/opt/etc/py-mx-base.conf /opt/etc/init.d/SXXpy-mx-base

#
# PY-MX-BASE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MX-BASE_PATCHES=$(PY-MX-BASE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY24-MX-BASE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.4
PY25-MX-BASE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.5
PY-MX-BASE_LDFLAGS=

#
# PY-MX-BASE_BUILD_DIR is the directory in which the build is done.
# PY-MX-BASE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MX-BASE_IPK_DIR is the directory in which the ipk is built.
# PY-MX-BASE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MX-BASE_BUILD_DIR=$(BUILD_DIR)/py-mx-base
PY-MX-BASE_SOURCE_DIR=$(SOURCE_DIR)/py-mx-base

PY24-MX-BASE_IPK_DIR=$(BUILD_DIR)/py24-mx-base-$(PY-MX-BASE_VERSION)-ipk
PY24-MX-BASE_IPK=$(BUILD_DIR)/py24-mx-base_$(PY-MX-BASE_VERSION)-$(PY-MX-BASE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MX-BASE_IPK_DIR=$(BUILD_DIR)/py25-mx-base-$(PY-MX-BASE_VERSION)-ipk
PY25-MX-BASE_IPK=$(BUILD_DIR)/py25-mx-base_$(PY-MX-BASE_VERSION)-$(PY-MX-BASE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mx-base-source py-mx-base-unpack py-mx-base py-mx-base-stage py-mx-base-ipk py-mx-base-clean py-mx-base-dirclean py-mx-base-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MX-BASE_SOURCE):
	$(WGET) -P $(@D) $(PY-MX-BASE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mx-base-source: $(DL_DIR)/$(PY-MX-BASE_SOURCE) $(PY-MX-BASE_PATCHES)

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
$(PY-MX-BASE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MX-BASE_SOURCE) $(PY-MX-BASE_PATCHES)
	$(MAKE) python-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MX-BASE_DIR)
	$(PY-MX-BASE_UNZIP) $(DL_DIR)/$(PY-MX-BASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-MX-BASE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MX-BASE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MX-BASE_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
            ( \
                echo "[build_ext]"; \
                echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
                echo "library-dirs=$(STAGING_LIB_DIR)"; \
                echo "rpath=/opt/lib"; \
                echo "[build_scripts]"; \
                echo "executable=/opt/bin/python2.4" \
            ) >> setup.cfg; \
        )
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MX-BASE_DIR)
	$(PY-MX-BASE_UNZIP) $(DL_DIR)/$(PY-MX-BASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(PY-MX-BASE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MX-BASE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MX-BASE_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
            ( \
                echo "[build_ext]"; \
                echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
                echo "library-dirs=$(STAGING_LIB_DIR)"; \
                echo "rpath=/opt/lib"; \
                echo "[build_scripts]"; \
                echo "executable=/opt/bin/python2.5" \
            ) >> setup.cfg; \
        )
	touch $@

py-mx-base-unpack: $(PY-MX-BASE_BUILD_DIR)/.configured

#
# This builds the actual binary.
            #$(BUILD_DIR)/python/buildpython/python setup.py build; \
#
$(PY-MX-BASE_BUILD_DIR)/.built: $(PY-MX-BASE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CPPFLAG=`echo $(STAGING_CPPFLAGS) $(PY24-MX-BASE_CPPFLAGS)` \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
        )
	(cd $(@D)/2.5; \
	 CPPFLAG=`echo $(STAGING_CPPFLAGS) $(PY25-MX-BASE_CPPFLAGS)` \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
        )
	touch $@

#
# This is the build convenience target.
#
py-mx-base: $(PY-MX-BASE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MX-BASE_BUILD_DIR)/.staged: $(PY-MX-BASE_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.4; \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(STAGING_DIR) --prefix=/opt; \
        )
	(cd $(@D)/2.5; \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(STAGING_DIR) --prefix=/opt; \
        )
	touch $@

py-mx-base-stage: $(PY-MX-BASE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mx-base
#
$(PY24-MX-BASE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-mx-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MX-BASE_PRIORITY)" >>$@
	@echo "Section: $(PY-MX-BASE_SECTION)" >>$@
	@echo "Version: $(PY-MX-BASE_VERSION)-$(PY-MX-BASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MX-BASE_MAINTAINER)" >>$@
	@echo "Source: $(PY-MX-BASE_SITE)/$(PY-MX-BASE_SOURCE)" >>$@
	@echo "Description: $(PY-MX-BASE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MX-BASE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MX-BASE_CONFLICTS)" >>$@

$(PY25-MX-BASE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mx-base" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MX-BASE_PRIORITY)" >>$@
	@echo "Section: $(PY-MX-BASE_SECTION)" >>$@
	@echo "Version: $(PY-MX-BASE_VERSION)-$(PY-MX-BASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MX-BASE_MAINTAINER)" >>$@
	@echo "Source: $(PY-MX-BASE_SITE)/$(PY-MX-BASE_SOURCE)" >>$@
	@echo "Description: $(PY-MX-BASE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MX-BASE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MX-BASE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MX-BASE_IPK_DIR)/opt/sbin or $(PY-MX-BASE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MX-BASE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MX-BASE_IPK_DIR)/opt/etc/py-mx-base/...
# Documentation files should be installed in $(PY-MX-BASE_IPK_DIR)/opt/doc/py-mx-base/...
# Daemon startup scripts should be installed in $(PY-MX-BASE_IPK_DIR)/opt/etc/init.d/S??py-mx-base
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MX-BASE_IPK): $(PY-MX-BASE_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-mx-base_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-MX-BASE_IPK_DIR) $(BUILD_DIR)/py24-mx-base_*_$(TARGET_ARCH).ipk
	(cd $(PY-MX-BASE_BUILD_DIR)/2.4; \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-MX-BASE_IPK_DIR) --prefix=/opt; \
        )
	$(STRIP_COMMAND) `find $(PY24-MX-BASE_IPK_DIR) -name '*.so'`
	$(MAKE) $(PY24-MX-BASE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MX-BASE_IPK_DIR)

$(PY25-MX-BASE_IPK): $(PY-MX-BASE_BUILD_DIR)/.built
	rm -rf $(PY25-MX-BASE_IPK_DIR) $(BUILD_DIR)/py25-mx-base_*_$(TARGET_ARCH).ipk
	(cd $(PY-MX-BASE_BUILD_DIR)/2.5; \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-MX-BASE_IPK_DIR) --prefix=/opt; \
        )
	$(STRIP_COMMAND) `find $(PY25-MX-BASE_IPK_DIR) -name '*.so'`
	$(MAKE) $(PY25-MX-BASE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MX-BASE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mx-base-ipk: $(PY24-MX-BASE_IPK) $(PY25-MX-BASE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mx-base-clean:
	-$(MAKE) -C $(PY-MX-BASE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mx-base-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MX-BASE_DIR) $(PY-MX-BASE_BUILD_DIR)
	rm -rf $(PY24-MX-BASE_IPK_DIR) $(PY24-MX-BASE_IPK)
	rm -rf $(PY25-MX-BASE_IPK_DIR) $(PY25-MX-BASE_IPK)

#
# Some sanity check for the package.
#
py-mx-base-check: $(PY24-MX-BASE_IPK) $(PY25-MX-BASE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MX-BASE_IPK) $(PY25-MX-BASE_IPK)
