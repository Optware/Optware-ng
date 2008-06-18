###########################################################
#
# py-pygresql
#
###########################################################

#
# PY-PYGRESQL_VERSION, PY-PYGRESQL_SITE and PY-PYGRESQL_SOURCE define
# the upstream location of the source code for the package.
# PY-PYGRESQL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PYGRESQL_UNZIP is the command used to unzip the source.
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
PY-PYGRESQL_SITE=ftp://ftp.PyGreSQL.org/pub/distrib
PY-PYGRESQL_VERSION=3.8.1
PY-PYGRESQL_SOURCE=PyGreSQL-$(PY-PYGRESQL_VERSION).tgz
PY-PYGRESQL_DIR=PyGreSQL-$(PY-PYGRESQL_VERSION)
PY-PYGRESQL_UNZIP=zcat
PY-PYGRESQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PYGRESQL_DESCRIPTION=Python module that interfaces to a PostgreSQL database.
PY-PYGRESQL_SECTION=misc
PY-PYGRESQL_PRIORITY=optional
PY24-PYGRESQL_DEPENDS=python24, py24-mx-base
PY25-PYGRESQL_DEPENDS=python25, py25-mx-base
PY-PYGRESQL_CONFLICTS=

#
# PY-PYGRESQL_IPK_VERSION should be incremented when the ipk changes.
#
PY-PYGRESQL_IPK_VERSION=3

#
# PY-PYGRESQL_CONFFILES should be a list of user-editable files
#PY-PYGRESQL_CONFFILES=/opt/etc/py-pygresql.conf /opt/etc/init.d/SXXpy-pygresql

#
# PY-PYGRESQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-PYGRESQL_PATCHES=$(PY-PYGRESQL_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PYGRESQL_CPPFLAGS=
PY-PYGRESQL_LDFLAGS=

#
# PY-PYGRESQL_BUILD_DIR is the directory in which the build is done.
# PY-PYGRESQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PYGRESQL_IPK_DIR is the directory in which the ipk is built.
# PY-PYGRESQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PYGRESQL_BUILD_DIR=$(BUILD_DIR)/py-pygresql
PY-PYGRESQL_SOURCE_DIR=$(SOURCE_DIR)/py-pygresql

PY24-PYGRESQL_IPK_DIR=$(BUILD_DIR)/py24-pygresql-$(PY-PYGRESQL_VERSION)-ipk
PY24-PYGRESQL_IPK=$(BUILD_DIR)/py24-pygresql_$(PY-PYGRESQL_VERSION)-$(PY-PYGRESQL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PYGRESQL_IPK_DIR=$(BUILD_DIR)/py25-pygresql-$(PY-PYGRESQL_VERSION)-ipk
PY25-PYGRESQL_IPK=$(BUILD_DIR)/py25-pygresql_$(PY-PYGRESQL_VERSION)-$(PY-PYGRESQL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pygresql-source py-pygresql-unpack py-pygresql py-pygresql-stage py-pygresql-ipk py-pygresql-clean py-pygresql-dirclean py-pygresql-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PYGRESQL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PYGRESQL_SITE)/$(PY-PYGRESQL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pygresql-source: $(DL_DIR)/$(PY-PYGRESQL_SOURCE) $(PY-PYGRESQL_PATCHES)

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
$(PY-PYGRESQL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PYGRESQL_SOURCE) $(PY-PYGRESQL_PATCHES)
	$(MAKE) postgresql-stage python-stage py-mx-base-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PYGRESQL_DIR)
	$(PY-PYGRESQL_UNZIP) $(DL_DIR)/$(PY-PYGRESQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-PYGRESQL_PATCHES) | patch -b -d $(BUILD_DIR)/$(PY-PYGRESQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PYGRESQL_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include_dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4:$(STAGING_INCLUDE_DIR)/postgresql:$(STAGING_INCLUDE_DIR)/postgresql/server"; \
	        echo "library_dirs=$(STAGING_DIR)/opt/lib"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PYGRESQL_DIR)
	$(PY-PYGRESQL_UNZIP) $(DL_DIR)/$(PY-PYGRESQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-PYGRESQL_PATCHES) | patch -b -d $(BUILD_DIR)/$(PY-PYGRESQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PYGRESQL_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include_dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5:$(STAGING_INCLUDE_DIR)/postgresql:$(STAGING_INCLUDE_DIR)/postgresql/server"; \
	        echo "library_dirs=$(STAGING_DIR)/opt/lib"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-pygresql-unpack: $(PY-PYGRESQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PYGRESQL_BUILD_DIR)/.built: $(PY-PYGRESQL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-pygresql: $(PY-PYGRESQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-PYGRESQL_BUILD_DIR)/.staged: $(PY-PYGRESQL_BUILD_DIR)/.built
#	rm -f $(PY-PYGRESQL_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-PYGRESQL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(PY-PYGRESQL_BUILD_DIR)/.staged
#
#py-pygresql-stage: $(PY-PYGRESQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pygresql
#
$(PY24-PYGRESQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-pygresql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PYGRESQL_PRIORITY)" >>$@
	@echo "Section: $(PY-PYGRESQL_SECTION)" >>$@
	@echo "Version: $(PY-PYGRESQL_VERSION)-$(PY-PYGRESQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PYGRESQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PYGRESQL_SITE)/$(PY-PYGRESQL_SOURCE)" >>$@
	@echo "Description: $(PY-PYGRESQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PYGRESQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PYGRESQL_CONFLICTS)" >>$@

$(PY25-PYGRESQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-pygresql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PYGRESQL_PRIORITY)" >>$@
	@echo "Section: $(PY-PYGRESQL_SECTION)" >>$@
	@echo "Version: $(PY-PYGRESQL_VERSION)-$(PY-PYGRESQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PYGRESQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PYGRESQL_SITE)/$(PY-PYGRESQL_SOURCE)" >>$@
	@echo "Description: $(PY-PYGRESQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PYGRESQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PYGRESQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PYGRESQL_IPK_DIR)/opt/sbin or $(PY-PYGRESQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PYGRESQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PYGRESQL_IPK_DIR)/opt/etc/py-pygresql/...
# Documentation files should be installed in $(PY-PYGRESQL_IPK_DIR)/opt/doc/py-pygresql/...
# Daemon startup scripts should be installed in $(PY-PYGRESQL_IPK_DIR)/opt/etc/init.d/S??py-pygresql
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PYGRESQL_IPK): $(PY-PYGRESQL_BUILD_DIR)/.built
	rm -rf $(PY24-PYGRESQL_IPK_DIR) $(BUILD_DIR)/py-pygresql_*_$(TARGET_ARCH).ipk
	(cd $(PY-PYGRESQL_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-PYGRESQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-PYGRESQL_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY24-PYGRESQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PYGRESQL_IPK_DIR)

$(PY25-PYGRESQL_IPK): $(PY-PYGRESQL_BUILD_DIR)/.built
	rm -rf $(PY25-PYGRESQL_IPK_DIR) $(BUILD_DIR)/py25-pygresql_*_$(TARGET_ARCH).ipk
	(cd $(PY-PYGRESQL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-PYGRESQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-PYGRESQL_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY25-PYGRESQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PYGRESQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pygresql-ipk: $(PY24-PYGRESQL_IPK) $(PY25-PYGRESQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pygresql-clean:
	-$(MAKE) -C $(PY-PYGRESQL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pygresql-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PYGRESQL_DIR) $(PY-PYGRESQL_BUILD_DIR)
	rm -rf $(PY24-PYGRESQL_IPK_DIR) $(PY24-PYGRESQL_IPK)
	rm -rf $(PY25-PYGRESQL_IPK_DIR) $(PY25-PYGRESQL_IPK)

#
# Some sanity check for the package.
#
py-pygresql-check: $(PY24-PYGRESQL_IPK) $(PY25-PYGRESQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PYGRESQL_IPK) $(PY25-PYGRESQL_IPK)
