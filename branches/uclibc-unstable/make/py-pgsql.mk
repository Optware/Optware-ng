###########################################################
#
# py-pgsql
#
###########################################################

#
# PY-PGSQL_VERSION, PY-PGSQL_SITE and PY-PGSQL_SOURCE define
# the upstream location of the source code for the package.
# PY-PGSQL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PGSQL_UNZIP is the command used to unzip the source.
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
PY-PGSQL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pypgsql
PY-PGSQL_VERSION=2.5.1
PY-PGSQL_SOURCE=pyPgSQL-$(PY-PGSQL_VERSION).tar.gz
PY-PGSQL_DIR=pyPgSQL-$(PY-PGSQL_VERSION)
PY-PGSQL_UNZIP=zcat
PY-PGSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PGSQL_DESCRIPTION=A Python DB-API 2.0 compliant interface to PostgreSQL databases.
PY-PGSQL_SECTION=misc
PY-PGSQL_PRIORITY=optional
PY24-PGSQL_DEPENDS=python24
PY25-PGSQL_DEPENDS=python25
PY-PGSQL_CONFLICTS=

#
# PY-PGSQL_IPK_VERSION should be incremented when the ipk changes.
#
PY-PGSQL_IPK_VERSION=2

#
# PY-PGSQL_CONFFILES should be a list of user-editable files
#PY-PGSQL_CONFFILES=/opt/etc/py-pgsql.conf /opt/etc/init.d/SXXpy-pgsql

#
# PY-PGSQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PGSQL_PATCHES=$(PY-PGSQL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PGSQL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/postgresql
PY-PGSQL_LDFLAGS=

#
# PY-PGSQL_BUILD_DIR is the directory in which the build is done.
# PY-PGSQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PGSQL_IPK_DIR is the directory in which the ipk is built.
# PY-PGSQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PGSQL_BUILD_DIR=$(BUILD_DIR)/py-pgsql
PY-PGSQL_SOURCE_DIR=$(SOURCE_DIR)/py-pgsql

PY24-PGSQL_IPK_DIR=$(BUILD_DIR)/py-pgsql-$(PY-PGSQL_VERSION)-ipk
PY24-PGSQL_IPK=$(BUILD_DIR)/py-pgsql_$(PY-PGSQL_VERSION)-$(PY-PGSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PGSQL_IPK_DIR=$(BUILD_DIR)/py25-pgsql-$(PY-PGSQL_VERSION)-ipk
PY25-PGSQL_IPK=$(BUILD_DIR)/py25-pgsql_$(PY-PGSQL_VERSION)-$(PY-PGSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pgsql-source py-pgsql-unpack py-pgsql py-pgsql-stage py-pgsql-ipk py-pgsql-clean py-pgsql-dirclean py-pgsql-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PGSQL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PGSQL_SITE)/$(PY-PGSQL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pgsql-source: $(DL_DIR)/$(PY-PGSQL_SOURCE) $(PY-PGSQL_PATCHES)

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
$(PY-PGSQL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PGSQL_SOURCE) $(PY-PGSQL_PATCHES)
	$(MAKE) postgresql-stage python-stage
	rm -rf $(PY-PGSQL_BUILD_DIR)
	mkdir -p $(PY-PGSQL_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PGSQL_DIR)
	$(PY-PGSQL_UNZIP) $(DL_DIR)/$(PY-PGSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PGSQL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PGSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PGSQL_DIR) $(PY-PGSQL_BUILD_DIR)/2.4
	(cd $(PY-PGSQL_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include_dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library_dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
	    ) >> setup.cfg; \
	    sed -i -e '/include_dirs/d' -e '/library_dirs/d' setup.py; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PGSQL_DIR)
	$(PY-PGSQL_UNZIP) $(DL_DIR)/$(PY-PGSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PGSQL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PGSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PGSQL_DIR) $(PY-PGSQL_BUILD_DIR)/2.5
	(cd $(PY-PGSQL_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include_dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library_dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
	    ) >> setup.cfg; \
	    sed -i -e '/include_dirs/d' -e '/library_dirs/d' setup.py; \
	)
	touch $@

py-pgsql-unpack: $(PY-PGSQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PGSQL_BUILD_DIR)/.built: $(PY-PGSQL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-PGSQL_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-PGSQL_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-pgsql: $(PY-PGSQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PGSQL_BUILD_DIR)/.staged: $(PY-PGSQL_BUILD_DIR)/.built
	rm -f $(PY-PGSQL_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-PGSQL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-PGSQL_BUILD_DIR)/.staged

py-pgsql-stage: $(PY-PGSQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pgsql
#
$(PY24-PGSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-pgsql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PGSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-PGSQL_SECTION)" >>$@
	@echo "Version: $(PY-PGSQL_VERSION)-$(PY-PGSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PGSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PGSQL_SITE)/$(PY-PGSQL_SOURCE)" >>$@
	@echo "Description: $(PY-PGSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PGSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PGSQL_CONFLICTS)" >>$@

$(PY25-PGSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pgsql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PGSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-PGSQL_SECTION)" >>$@
	@echo "Version: $(PY-PGSQL_VERSION)-$(PY-PGSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PGSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PGSQL_SITE)/$(PY-PGSQL_SOURCE)" >>$@
	@echo "Description: $(PY-PGSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PGSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PGSQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PGSQL_IPK_DIR)/opt/sbin or $(PY-PGSQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PGSQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PGSQL_IPK_DIR)/opt/etc/py-pgsql/...
# Documentation files should be installed in $(PY-PGSQL_IPK_DIR)/opt/doc/py-pgsql/...
# Daemon startup scripts should be installed in $(PY-PGSQL_IPK_DIR)/opt/etc/init.d/S??py-pgsql
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PGSQL_IPK): $(PY-PGSQL_BUILD_DIR)/.built
	rm -rf $(PY24-PGSQL_IPK_DIR) $(BUILD_DIR)/py-pgsql_*_$(TARGET_ARCH).ipk
	(cd $(PY-PGSQL_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-PGSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-PGSQL_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY24-PGSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PGSQL_IPK_DIR)

$(PY25-PGSQL_IPK): $(PY-PGSQL_BUILD_DIR)/.built
	rm -rf $(PY25-PGSQL_IPK_DIR) $(BUILD_DIR)/py25-pgsql_*_$(TARGET_ARCH).ipk
	(cd $(PY-PGSQL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-PGSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-PGSQL_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY25-PGSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PGSQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pgsql-ipk: $(PY24-PGSQL_IPK) $(PY25-PGSQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pgsql-clean:
	-$(MAKE) -C $(PY-PGSQL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pgsql-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PGSQL_DIR) $(PY-PGSQL_BUILD_DIR)
	rm -rf $(PY24-PGSQL_IPK_DIR) $(PY24-PGSQL_IPK)
	rm -rf $(PY25-PGSQL_IPK_DIR) $(PY25-PGSQL_IPK)

#
# Some sanity check for the package.
#
py-pgsql-check: $(PY24-PGSQL_IPK) $(PY25-PGSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PGSQL_IPK) $(PY25-PGSQL_IPK)
