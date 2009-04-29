###########################################################
#
# py-mssql
#
###########################################################

#
# PY-MSSQL_VERSION, PY-MSSQL_SITE and PY-MSSQL_SOURCE define
# the upstream location of the source code for the package.
# PY-MSSQL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MSSQL_UNZIP is the command used to unzip the source.
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
PY-MSSQL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pymssql
PY-MSSQL_VERSION=1.0.2
PY-MSSQL_SOURCE=pymssql-$(PY-MSSQL_VERSION).tar.gz
PY-MSSQL_DIR=pymssql-$(PY-MSSQL_VERSION)
PY-MSSQL_UNZIP=zcat
PY-MSSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MSSQL_DESCRIPTION=Simple MSSQL Python extension module.
PY-MSSQL_SECTION=misc
PY-MSSQL_PRIORITY=optional
PY24-MSSQL_DEPENDS=python24, freetds
PY25-MSSQL_DEPENDS=python25, freetds
PY26-MSSQL_DEPENDS=python26, freetds
PY-MSSQL_CONFLICTS=

#
# PY-MSSQL_IPK_VERSION should be incremented when the ipk changes.
#
PY-MSSQL_IPK_VERSION=1

#
# PY-MSSQL_CONFFILES should be a list of user-editable files
#PY-MSSQL_CONFFILES=/opt/etc/py-mssql.conf /opt/etc/init.d/SXXpy-mssql

#
# PY-MSSQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-MSSQL_PATCHES=$(PY-MSSQL_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MSSQL_CPPFLAGS=
PY-MSSQL_LDFLAGS=

#
# PY-MSSQL_BUILD_DIR is the directory in which the build is done.
# PY-MSSQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MSSQL_IPK_DIR is the directory in which the ipk is built.
# PY-MSSQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MSSQL_BUILD_DIR=$(BUILD_DIR)/py-mssql
PY-MSSQL_SOURCE_DIR=$(SOURCE_DIR)/py-mssql

PY24-MSSQL_IPK_DIR=$(BUILD_DIR)/py24-mssql-$(PY-MSSQL_VERSION)-ipk
PY24-MSSQL_IPK=$(BUILD_DIR)/py24-mssql_$(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MSSQL_IPK_DIR=$(BUILD_DIR)/py25-mssql-$(PY-MSSQL_VERSION)-ipk
PY25-MSSQL_IPK=$(BUILD_DIR)/py25-mssql_$(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-MSSQL_IPK_DIR=$(BUILD_DIR)/py26-mssql-$(PY-MSSQL_VERSION)-ipk
PY26-MSSQL_IPK=$(BUILD_DIR)/py26-mssql_$(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mssql-source py-mssql-unpack py-mssql py-mssql-stage py-mssql-ipk py-mssql-clean py-mssql-dirclean py-mssql-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MSSQL_SOURCE):
	$(WGET) -P $(@D) $(PY-MSSQL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mssql-source: $(DL_DIR)/$(PY-MSSQL_SOURCE) $(PY-MSSQL_PATCHES)

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
$(PY-MSSQL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MSSQL_SOURCE) $(PY-MSSQL_PATCHES) make/py-mssql.mk
	$(MAKE) python-stage freetds-stage
	rm -rf $(PY-MSSQL_BUILD_DIR)
	mkdir -p $(PY-MSSQL_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MSSQL_DIR)
	$(PY-MSSQL_UNZIP) $(DL_DIR)/$(PY-MSSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	sed -i -e 's/\x0d$$//' $(BUILD_DIR)/$(PY-MSSQL_DIR)/setup.py
	cat $(PY-MSSQL_PATCHES) | patch --ignore-whitespace -bd $(BUILD_DIR)/$(PY-MSSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MSSQL_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "libraries=sybdb"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) > setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MSSQL_DIR)
	$(PY-MSSQL_UNZIP) $(DL_DIR)/$(PY-MSSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	sed -i -e 's/\x0d$$//' $(BUILD_DIR)/$(PY-MSSQL_DIR)/setup.py
	cat $(PY-MSSQL_PATCHES) | patch --ignore-whitespace -bd $(BUILD_DIR)/$(PY-MSSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MSSQL_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "libraries=sybdb"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) > setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-MSSQL_DIR)
	$(PY-MSSQL_UNZIP) $(DL_DIR)/$(PY-MSSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	sed -i -e 's/\x0d$$//' $(BUILD_DIR)/$(PY-MSSQL_DIR)/setup.py
	cat $(PY-MSSQL_PATCHES) | patch --ignore-whitespace -bd $(BUILD_DIR)/$(PY-MSSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MSSQL_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "libraries=sybdb"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) > setup.cfg; \
	)
	touch $@

py-mssql-unpack: $(PY-MSSQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MSSQL_BUILD_DIR)/.built: $(PY-MSSQL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-mssql: $(PY-MSSQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-MSSQL_BUILD_DIR)/.staged: $(PY-MSSQL_BUILD_DIR)/.built
#	rm -f $(PY-MSSQL_BUILD_DIR)/.staged
#	#$(MAKE) -C $(PY-MSSQL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(PY-MSSQL_BUILD_DIR)/.staged
#
#py-mssql-stage: $(PY-MSSQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mssql
#
$(PY24-MSSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-mssql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MSSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-MSSQL_SECTION)" >>$@
	@echo "Version: $(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MSSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MSSQL_SITE)/$(PY-MSSQL_SOURCE)" >>$@
	@echo "Description: $(PY-MSSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-MSSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MSSQL_CONFLICTS)" >>$@

$(PY25-MSSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mssql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MSSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-MSSQL_SECTION)" >>$@
	@echo "Version: $(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MSSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MSSQL_SITE)/$(PY-MSSQL_SOURCE)" >>$@
	@echo "Description: $(PY-MSSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MSSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MSSQL_CONFLICTS)" >>$@

$(PY26-MSSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-mssql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MSSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-MSSQL_SECTION)" >>$@
	@echo "Version: $(PY-MSSQL_VERSION)-$(PY-MSSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MSSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MSSQL_SITE)/$(PY-MSSQL_SOURCE)" >>$@
	@echo "Description: $(PY-MSSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-MSSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MSSQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MSSQL_IPK_DIR)/opt/sbin or $(PY-MSSQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MSSQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MSSQL_IPK_DIR)/opt/etc/py-mssql/...
# Documentation files should be installed in $(PY-MSSQL_IPK_DIR)/opt/doc/py-mssql/...
# Daemon startup scripts should be installed in $(PY-MSSQL_IPK_DIR)/opt/etc/init.d/S??py-mssql
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MSSQL_IPK): $(PY-MSSQL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-mssql_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-MSSQL_IPK_DIR) $(BUILD_DIR)/py24-mssql_*_$(TARGET_ARCH).ipk
	(cd $(PY-MSSQL_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MSSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-MSSQL_IPK_DIR)/opt/lib/python2.4/site-packages/ -name '*.so'`
	$(MAKE) $(PY24-MSSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MSSQL_IPK_DIR)

$(PY25-MSSQL_IPK): $(PY-MSSQL_BUILD_DIR)/.built
	rm -rf $(PY25-MSSQL_IPK_DIR) $(BUILD_DIR)/py25-mssql_*_$(TARGET_ARCH).ipk
	(cd $(PY-MSSQL_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MSSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-MSSQL_IPK_DIR)/opt/lib/python2.5/site-packages/ -name '*.so'`
	$(MAKE) $(PY25-MSSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MSSQL_IPK_DIR)

$(PY26-MSSQL_IPK): $(PY-MSSQL_BUILD_DIR)/.built
	rm -rf $(PY26-MSSQL_IPK_DIR) $(BUILD_DIR)/py26-mssql_*_$(TARGET_ARCH).ipk
	(cd $(PY-MSSQL_BUILD_DIR)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-MSSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY26-MSSQL_IPK_DIR)/opt/lib/python2.6/site-packages/ -name '*.so'`
	$(MAKE) $(PY26-MSSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-MSSQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mssql-ipk: $(PY24-MSSQL_IPK) $(PY25-MSSQL_IPK) $(PY26-MSSQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mssql-clean:
	-$(MAKE) -C $(PY-MSSQL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mssql-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MSSQL_DIR) $(PY-MSSQL_BUILD_DIR)
	rm -rf $(PY24-MSSQL_IPK_DIR) $(PY24-MSSQL_IPK)
	rm -rf $(PY25-MSSQL_IPK_DIR) $(PY25-MSSQL_IPK)
	rm -rf $(PY26-MSSQL_IPK_DIR) $(PY26-MSSQL_IPK)

#
# Some sanity check for the package.
#
py-mssql-check: $(PY24-MSSQL_IPK) $(PY25-MSSQL_IPK) $(PY26-MSSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
