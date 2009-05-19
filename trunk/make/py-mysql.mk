###########################################################
#
# py-mysql
#
###########################################################

#
# PY-MYSQL_VERSION, PY-MYSQL_SITE and PY-MYSQL_SOURCE define
# the upstream location of the source code for the package.
# PY-MYSQL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MYSQL_UNZIP is the command used to unzip the source.
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
PY-MYSQL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mysql-python
PY-MYSQL_VERSION=1.2.3c1
PY-MYSQL_SOURCE=MySQL-python-$(PY-MYSQL_VERSION).tar.gz
PY-MYSQL_DIR=MySQL-python-$(PY-MYSQL_VERSION)
PY-MYSQL_UNZIP=zcat
PY-MYSQL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MYSQL_DESCRIPTION=MySQL support for Python.
PY-MYSQL_SECTION=misc
PY-MYSQL_PRIORITY=optional
PY25-MYSQL_DEPENDS=python25
PY26-MYSQL_DEPENDS=python26
PY-MYSQL_CONFLICTS=

#
# PY-MYSQL_IPK_VERSION should be incremented when the ipk changes.
#
PY-MYSQL_IPK_VERSION=1

#
# PY-MYSQL_CONFFILES should be a list of user-editable files
#PY-MYSQL_CONFFILES=/opt/etc/py-mysql.conf /opt/etc/init.d/SXXpy-mysql

#
# PY-MYSQL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MYSQL_PATCHES=$(PY-MYSQL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MYSQL_CPPFLAGS=
PY-MYSQL_LDFLAGS=

#
# PY-MYSQL_BUILD_DIR is the directory in which the build is done.
# PY-MYSQL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MYSQL_IPK_DIR is the directory in which the ipk is built.
# PY-MYSQL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MYSQL_BUILD_DIR=$(BUILD_DIR)/py-mysql
PY-MYSQL_SOURCE_DIR=$(SOURCE_DIR)/py-mysql

PY25-MYSQL_IPK_DIR=$(BUILD_DIR)/py25-mysql-$(PY-MYSQL_VERSION)-ipk
PY25-MYSQL_IPK=$(BUILD_DIR)/py25-mysql_$(PY-MYSQL_VERSION)-$(PY-MYSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-MYSQL_IPK_DIR=$(BUILD_DIR)/py26-mysql-$(PY-MYSQL_VERSION)-ipk
PY26-MYSQL_IPK=$(BUILD_DIR)/py26-mysql_$(PY-MYSQL_VERSION)-$(PY-MYSQL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-mysql-source py-mysql-unpack py-mysql py-mysql-stage py-mysql-ipk py-mysql-clean py-mysql-dirclean py-mysql-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MYSQL_SOURCE):
	$(WGET) -P $(@D) $(PY-MYSQL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mysql-source: $(DL_DIR)/$(PY-MYSQL_SOURCE) $(PY-MYSQL_PATCHES)

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
$(PY-MYSQL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MYSQL_SOURCE) $(PY-MYSQL_PATCHES) make/py-mysql.mk
	$(MAKE) mysql-stage py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MYSQL_DIR)
	$(PY-MYSQL_UNZIP) $(DL_DIR)/$(PY-MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MYSQL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MYSQL_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    sed -i -e 's|# *mysql_config *=.*|mysql_config = $(STAGING_PREFIX)/bin/mysql_config|' site.cfg; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR):$(STAGING_LIB_DIR)/mysql"; \
	        echo "libraries=mysqlclient_r"; \
	        echo "rpath=/opt/lib:/opt/lib/mysql"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-MYSQL_DIR)
	$(PY-MYSQL_UNZIP) $(DL_DIR)/$(PY-MYSQL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MYSQL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MYSQL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MYSQL_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    sed -i -e 's|# *mysql_config *=.*|mysql_config = $(STAGING_PREFIX)/bin/mysql_config|' site.cfg; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR):$(STAGING_LIB_DIR)/mysql"; \
	        echo "libraries=mysqlclient_r"; \
	        echo "rpath=/opt/lib:/opt/lib/mysql"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	touch $@

py-mysql-unpack: $(PY-MYSQL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MYSQL_BUILD_DIR)/.built: $(PY-MYSQL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-mysql: $(PY-MYSQL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-MYSQL_BUILD_DIR)/.staged: $(PY-MYSQL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-mysql-stage: $(PY-MYSQL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mysql
#
$(PY25-MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-MYSQL_SECTION)" >>$@
	@echo "Version: $(PY-MYSQL_VERSION)-$(PY-MYSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYSQL_SITE)/$(PY-MYSQL_SOURCE)" >>$@
	@echo "Description: $(PY-MYSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-MYSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYSQL_CONFLICTS)" >>$@

$(PY26-MYSQL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-mysql" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MYSQL_PRIORITY)" >>$@
	@echo "Section: $(PY-MYSQL_SECTION)" >>$@
	@echo "Version: $(PY-MYSQL_VERSION)-$(PY-MYSQL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MYSQL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MYSQL_SITE)/$(PY-MYSQL_SOURCE)" >>$@
	@echo "Description: $(PY-MYSQL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-MYSQL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MYSQL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MYSQL_IPK_DIR)/opt/sbin or $(PY-MYSQL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MYSQL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MYSQL_IPK_DIR)/opt/etc/py-mysql/...
# Documentation files should be installed in $(PY-MYSQL_IPK_DIR)/opt/doc/py-mysql/...
# Daemon startup scripts should be installed in $(PY-MYSQL_IPK_DIR)/opt/etc/init.d/S??py-mysql
#
# You may need to patch your application to make it use these locations.
#
$(PY25-MYSQL_IPK): $(PY-MYSQL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-mysql_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-MYSQL_IPK_DIR) $(BUILD_DIR)/py25-mysql_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYSQL_BUILD_DIR)/2.5; \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py \
	    install --root=$(PY25-MYSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-MYSQL_IPK_DIR)/opt/lib/python2.5/site-packages/_mysql.so
	$(MAKE) $(PY25-MYSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MYSQL_IPK_DIR)

$(PY26-MYSQL_IPK): $(PY-MYSQL_BUILD_DIR)/.built
	rm -rf $(PY26-MYSQL_IPK_DIR) $(BUILD_DIR)/py26-mysql_*_$(TARGET_ARCH).ipk
	(cd $(PY-MYSQL_BUILD_DIR)/2.6; \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py \
	    install --root=$(PY26-MYSQL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY26-MYSQL_IPK_DIR)/opt/lib/python2.6/site-packages/_mysql.so
	$(MAKE) $(PY26-MYSQL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-MYSQL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mysql-ipk: $(PY25-MYSQL_IPK) $(PY26-MYSQL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mysql-clean:
	-$(MAKE) -C $(PY-MYSQL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mysql-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MYSQL_DIR) $(PY-MYSQL_BUILD_DIR)
	rm -rf $(PY25-MYSQL_IPK_DIR) $(PY25-MYSQL_IPK)
	rm -rf $(PY26-MYSQL_IPK_DIR) $(PY26-MYSQL_IPK)

#
# Some sanity check for the package.
#
py-mysql-check: $(PY25-MYSQL_IPK) $(PY26-MYSQL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
