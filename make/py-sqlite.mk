###########################################################
#
# py-sqlite
#
###########################################################

#
# PY-SQLITE_VERSION, PY-SQLITE_SITE and PY-SQLITE_SOURCE define
# the upstream location of the source code for the package.
# PY-SQLITE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SQLITE_UNZIP is the command used to unzip the source.
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
PY-SQLITE_VERSION=2.3.5
PY-SQLITE_SITE=http://initd.org/pub/software/pysqlite/releases/2.3/$(PY-SQLITE_VERSION)
PY-SQLITE_SOURCE=pysqlite-$(PY-SQLITE_VERSION).tar.gz
PY-SQLITE_DIR=pysqlite-$(PY-SQLITE_VERSION)
PY-SQLITE_UNZIP=zcat
PY-SQLITE_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SQLITE_DESCRIPTION=pysqlite is an interface to the SQLite database server for Python. It aims to be fully compliant with Python database API version 2.0 while also exploiting the unique features of SQLite.
PY-SQLITE_SECTION=misc
PY-SQLITE_PRIORITY=optional
PY-SQLITE_DEPENDS=python, sqlite
PY-SQLITE_CONFLICTS=

#
# PY-SQLITE_IPK_VERSION should be incremented when the ipk changes.
#
PY-SQLITE_IPK_VERSION=1

#
# PY-SQLITE_CONFFILES should be a list of user-editable files
#PY-SQLITE_CONFFILES=/opt/etc/py-sqlite.conf /opt/etc/init.d/SXXpy-sqlite

#
# PY-SQLITE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SQLITE_PATCHES=$(PY-SQLITE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SQLITE_CPPFLAGS=
PY-SQLITE_LDFLAGS=

#
# PY-SQLITE_BUILD_DIR is the directory in which the build is done.
# PY-SQLITE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SQLITE_IPK_DIR is the directory in which the ipk is built.
# PY-SQLITE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SQLITE_BUILD_DIR=$(BUILD_DIR)/py-sqlite
PY-SQLITE_SOURCE_DIR=$(SOURCE_DIR)/py-sqlite
PY-SQLITE_IPK_DIR=$(BUILD_DIR)/py-sqlite-$(PY-SQLITE_VERSION)-ipk
PY-SQLITE_IPK=$(BUILD_DIR)/py-sqlite_$(PY-SQLITE_VERSION)-$(PY-SQLITE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SQLITE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SQLITE_SITE)/$(PY-SQLITE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-sqlite-source: $(DL_DIR)/$(PY-SQLITE_SOURCE) $(PY-SQLITE_PATCHES)

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
$(PY-SQLITE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SQLITE_SOURCE) $(PY-SQLITE_PATCHES)
	$(MAKE) py-setuptools-stage sqlite-stage
	rm -rf $(BUILD_DIR)/$(PY-SQLITE_DIR) $(PY-SQLITE_BUILD_DIR)
	$(PY-SQLITE_UNZIP) $(DL_DIR)/$(PY-SQLITE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SQLITE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SQLITE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SQLITE_DIR) $(PY-SQLITE_BUILD_DIR)
	(cd $(PY-SQLITE_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "libraries=sqlite3"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $(PY-SQLITE_BUILD_DIR)/.configured

py-sqlite-unpack: $(PY-SQLITE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SQLITE_BUILD_DIR)/.built: $(PY-SQLITE_BUILD_DIR)/.configured
	rm -f $(PY-SQLITE_BUILD_DIR)/.built
	(cd $(PY-SQLITE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" build; \
	)
	touch $(PY-SQLITE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-sqlite: $(PY-SQLITE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SQLITE_BUILD_DIR)/.staged: $(PY-SQLITE_BUILD_DIR)/.built
	rm -f $(PY-SQLITE_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-SQLITE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SQLITE_BUILD_DIR)/.staged

py-sqlite-stage: $(PY-SQLITE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-sqlite
#
$(PY-SQLITE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-SQLITE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-sqlite" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SQLITE_PRIORITY)" >>$@
	@echo "Section: $(PY-SQLITE_SECTION)" >>$@
	@echo "Version: $(PY-SQLITE_VERSION)-$(PY-SQLITE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SQLITE_MAINTAINER)" >>$@
	@echo "Source: $(PY-SQLITE_SITE)/$(PY-SQLITE_SOURCE)" >>$@
	@echo "Description: $(PY-SQLITE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-SQLITE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SQLITE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SQLITE_IPK_DIR)/opt/sbin or $(PY-SQLITE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SQLITE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SQLITE_IPK_DIR)/opt/etc/py-sqlite/...
# Documentation files should be installed in $(PY-SQLITE_IPK_DIR)/opt/doc/py-sqlite/...
# Daemon startup scripts should be installed in $(PY-SQLITE_IPK_DIR)/opt/etc/init.d/S??py-sqlite
#
# You may need to patch your application to make it use these locations.
#
$(PY-SQLITE_IPK): $(PY-SQLITE_BUILD_DIR)/.built
	rm -rf $(PY-SQLITE_IPK_DIR) $(BUILD_DIR)/py-sqlite_*_$(TARGET_ARCH).ipk
	(cd $(PY-SQLITE_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY-SQLITE_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY-SQLITE_IPK_DIR)/opt/lib/python2.4/site-packages/pysqlite2/_sqlite.so
	$(MAKE) $(PY-SQLITE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SQLITE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-sqlite-ipk: $(PY-SQLITE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-sqlite-clean:
	-$(MAKE) -C $(PY-SQLITE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-sqlite-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SQLITE_DIR) $(PY-SQLITE_BUILD_DIR) $(PY-SQLITE_IPK_DIR) $(PY-SQLITE_IPK)

#
# Some sanity check for the package.
#
py-sqlite-check: $(PY-SQLITE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-SQLITE_IPK)
