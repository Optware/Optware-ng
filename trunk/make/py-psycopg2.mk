###########################################################
#
# py-psycopg2
#
###########################################################

#
# PY-PSYCOPG2_VERSION, PY-PSYCOPG2_SITE and PY-PSYCOPG2_SOURCE define
# the upstream location of the source code for the package.
# PY-PSYCOPG2_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PSYCOPG2_UNZIP is the command used to unzip the source.
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
PY-PSYCOPG2_SITE=http://initd.org/pub/software/psycopg
PY-PSYCOPG2_VERSION=2.0.10
PY-PSYCOPG2_SOURCE=psycopg2-$(PY-PSYCOPG2_VERSION).tar.gz
PY-PSYCOPG2_DIR=psycopg2-$(PY-PSYCOPG2_VERSION)
PY-PSYCOPG2_UNZIP=zcat
PY-PSYCOPG2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PSYCOPG2_DESCRIPTION=psycopg2 is a PostgreSQL database adapter for the Python programming language.
PY-PSYCOPG2_SECTION=misc
PY-PSYCOPG2_PRIORITY=optional
PY24-PSYCOPG2_DEPENDS=python24
PY25-PSYCOPG2_DEPENDS=python25
PY26-PSYCOPG2_DEPENDS=python26
PY-PSYCOPG2_CONFLICTS=

#
# PY-PSYCOPG2_IPK_VERSION should be incremented when the ipk changes.
#
PY-PSYCOPG2_IPK_VERSION=1

#
# PY-PSYCOPG2_CONFFILES should be a list of user-editable files
#PY-PSYCOPG2_CONFFILES=/opt/etc/py-psycopg2.conf /opt/etc/init.d/SXXpy-psycopg2

#
# PY-PSYCOPG2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PSYCOPG2_PATCHES=$(PY-PSYCOPG2_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PSYCOPG2_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/postgresql
PY-PSYCOPG2_LDFLAGS=

#
# PY-PSYCOPG2_BUILD_DIR is the directory in which the build is done.
# PY-PSYCOPG2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PSYCOPG2_IPK_DIR is the directory in which the ipk is built.
# PY-PSYCOPG2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PSYCOPG2_BUILD_DIR=$(BUILD_DIR)/py-psycopg2
PY-PSYCOPG2_SOURCE_DIR=$(SOURCE_DIR)/py-psycopg2

PY24-PSYCOPG2_IPK_DIR=$(BUILD_DIR)/py24-psycopg2-$(PY-PSYCOPG2_VERSION)-ipk
PY24-PSYCOPG2_IPK=$(BUILD_DIR)/py24-psycopg2_$(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PSYCOPG2_IPK_DIR=$(BUILD_DIR)/py25-psycopg2-$(PY-PSYCOPG2_VERSION)-ipk
PY25-PSYCOPG2_IPK=$(BUILD_DIR)/py25-psycopg2_$(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PSYCOPG2_IPK_DIR=$(BUILD_DIR)/py26-psycopg2-$(PY-PSYCOPG2_VERSION)-ipk
PY26-PSYCOPG2_IPK=$(BUILD_DIR)/py26-psycopg2_$(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-psycopg2-source py-psycopg2-unpack py-psycopg2 py-psycopg2-stage py-psycopg2-ipk py-psycopg2-clean py-psycopg2-dirclean py-psycopg2-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PSYCOPG2_SOURCE):
	$(WGET) -P $(@D) $(PY-PSYCOPG2_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(PY-PSYCOPG2_SITE)/PSYCOPG-2-0/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-psycopg2-source: $(DL_DIR)/$(PY-PSYCOPG2_SOURCE) $(PY-PSYCOPG2_PATCHES)

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
$(PY-PSYCOPG2_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PSYCOPG2_SOURCE) $(PY-PSYCOPG2_PATCHES) make/py-psycopg2.mk
	$(MAKE) postgresql-stage py-setuptools-stage
	rm -rf $(PY-PSYCOPG2_BUILD_DIR)
	mkdir -p $(PY-PSYCOPG2_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG2_DIR)
	$(PY-PSYCOPG2_UNZIP) $(DL_DIR)/$(PY-PSYCOPG2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PSYCOPG2_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "#pg_config=$(STAGING_PREFIX)/bin/pg_config"; \
	        echo "include_dirs=.:$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library_dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	    sed -i -e '/datetime\.h/s/^/if True: #/' \
		   -e '/^def get_pg_config/a\    return ""' $(@D)/2.4/setup.py; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG2_DIR)
	$(PY-PSYCOPG2_UNZIP) $(DL_DIR)/$(PY-PSYCOPG2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PSYCOPG2_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "#pg_config=$(STAGING_PREFIX)/bin/pg_config"; \
	        echo "include_dirs=.:$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library_dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	    sed -i -e '/datetime\.h/s/^/if True: #/' \
		   -e '/^def get_pg_config/a\    return ""' $(@D)/2.5/setup.py; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG2_DIR)
	$(PY-PSYCOPG2_UNZIP) $(DL_DIR)/$(PY-PSYCOPG2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-PSYCOPG2_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "#pg_config=$(STAGING_PREFIX)/bin/pg_config"; \
	        echo "include_dirs=.:$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library_dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	    sed -i -e '/datetime\.h/s/^/if True: #/' \
		   -e '/^def get_pg_config/a\    return ""' $(@D)/2.6/setup.py; \
	)
	touch $@

py-psycopg2-unpack: $(PY-PSYCOPG2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PSYCOPG2_BUILD_DIR)/.built: $(PY-PSYCOPG2_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -Wl,-rpath,/opt/lib' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -Wl,-rpath,/opt/lib' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared -Wl,-rpath,/opt/lib' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-psycopg2: $(PY-PSYCOPG2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PSYCOPG2_BUILD_DIR)/.staged: $(PY-PSYCOPG2_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-psycopg2-stage: $(PY-PSYCOPG2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-psycopg2
#
$(PY24-PSYCOPG2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-psycopg2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PSYCOPG2_PRIORITY)" >>$@
	@echo "Section: $(PY-PSYCOPG2_SECTION)" >>$@
	@echo "Version: $(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PSYCOPG2_MAINTAINER)" >>$@
	@echo "Source: $(PY-PSYCOPG2_SITE)/$(PY-PSYCOPG2_SOURCE)" >>$@
	@echo "Description: $(PY-PSYCOPG2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PSYCOPG2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PSYCOPG2_CONFLICTS)" >>$@

$(PY25-PSYCOPG2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-psycopg2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PSYCOPG2_PRIORITY)" >>$@
	@echo "Section: $(PY-PSYCOPG2_SECTION)" >>$@
	@echo "Version: $(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PSYCOPG2_MAINTAINER)" >>$@
	@echo "Source: $(PY-PSYCOPG2_SITE)/$(PY-PSYCOPG2_SOURCE)" >>$@
	@echo "Description: $(PY-PSYCOPG2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PSYCOPG2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PSYCOPG2_CONFLICTS)" >>$@

$(PY26-PSYCOPG2_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-psycopg2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PSYCOPG2_PRIORITY)" >>$@
	@echo "Section: $(PY-PSYCOPG2_SECTION)" >>$@
	@echo "Version: $(PY-PSYCOPG2_VERSION)-$(PY-PSYCOPG2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PSYCOPG2_MAINTAINER)" >>$@
	@echo "Source: $(PY-PSYCOPG2_SITE)/$(PY-PSYCOPG2_SOURCE)" >>$@
	@echo "Description: $(PY-PSYCOPG2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PSYCOPG2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PSYCOPG2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PSYCOPG2_IPK_DIR)/opt/sbin or $(PY-PSYCOPG2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PSYCOPG2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PSYCOPG2_IPK_DIR)/opt/etc/py-psycopg2/...
# Documentation files should be installed in $(PY-PSYCOPG2_IPK_DIR)/opt/doc/py-psycopg2/...
# Daemon startup scripts should be installed in $(PY-PSYCOPG2_IPK_DIR)/opt/etc/init.d/S??py-psycopg2
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PSYCOPG2_IPK): $(PY-PSYCOPG2_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-psycopg2_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-PSYCOPG2_IPK_DIR) $(BUILD_DIR)/py24-psycopg2_*_$(TARGET_ARCH).ipk
	(cd $(PY-PSYCOPG2_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY24-PSYCOPG2_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-PSYCOPG2_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY24-PSYCOPG2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PSYCOPG2_IPK_DIR)

$(PY25-PSYCOPG2_IPK): $(PY-PSYCOPG2_BUILD_DIR)/.built
	rm -rf $(PY25-PSYCOPG2_IPK_DIR) $(BUILD_DIR)/py25-psycopg2_*_$(TARGET_ARCH).ipk
	(cd $(PY-PSYCOPG2_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY25-PSYCOPG2_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-PSYCOPG2_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY25-PSYCOPG2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PSYCOPG2_IPK_DIR)

$(PY26-PSYCOPG2_IPK): $(PY-PSYCOPG2_BUILD_DIR)/.built
	rm -rf $(PY26-PSYCOPG2_IPK_DIR) $(BUILD_DIR)/py26-psycopg2_*_$(TARGET_ARCH).ipk
	(cd $(PY-PSYCOPG2_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY26-PSYCOPG2_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY26-PSYCOPG2_IPK_DIR)/opt/lib -name '*.so'`
	$(MAKE) $(PY26-PSYCOPG2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PSYCOPG2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-psycopg2-ipk: $(PY24-PSYCOPG2_IPK) $(PY25-PSYCOPG2_IPK) $(PY26-PSYCOPG2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-psycopg2-clean:
	-$(MAKE) -C $(PY-PSYCOPG2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-psycopg2-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PSYCOPG2_DIR) $(PY-PSYCOPG2_BUILD_DIR)
	rm -rf $(PY24-PSYCOPG2_IPK_DIR) $(PY24-PSYCOPG2_IPK)
	rm -rf $(PY25-PSYCOPG2_IPK_DIR) $(PY25-PSYCOPG2_IPK)
	rm -rf $(PY26-PSYCOPG2_IPK_DIR) $(PY26-PSYCOPG2_IPK)

#
# Some sanity check for the package.
#
py-psycopg2-check: $(PY24-PSYCOPG2_IPK) $(PY25-PSYCOPG2_IPK) $(PY26-PSYCOPG2_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
