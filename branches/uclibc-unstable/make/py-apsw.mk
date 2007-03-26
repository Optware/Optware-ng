###########################################################
#
# py-apsw
#
###########################################################

#
# PY-APSW_VERSION, PY-APSW_SITE and PY-APSW_SOURCE define
# the upstream location of the source code for the package.
# PY-APSW_DIR is the directory which is created when the source
# archive is unpacked.
# PY-APSW_UNZIP is the command used to unzip the source.
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
PY-APSW_VERSION=3.3.5-r1
PY-APSW_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bitpim
PY-APSW_SOURCE=apsw-$(PY-APSW_VERSION).zip
PY-APSW_DIR=apsw-$(PY-APSW_VERSION)
PY-APSW_UNZIP=unzip
PY-APSW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-APSW_DESCRIPTION=Another Python SQLite Wrapper.
PY-APSW_SECTION=misc
PY-APSW_PRIORITY=optional
PY24-APSW_DEPENDS=python24
PY25-APSW_DEPENDS=python25
PY-APSW_CONFLICTS=

#
# PY-APSW_IPK_VERSION should be incremented when the ipk changes.
#
PY-APSW_IPK_VERSION=2

#
# PY-APSW_CONFFILES should be a list of user-editable files
#PY-APSW_CONFFILES=/opt/etc/py-apsw.conf /opt/etc/init.d/SXXpy-apsw

#
# PY-APSW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-APSW_PATCHES=$(PY-APSW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-APSW_CPPFLAGS=
PY-APSW_LDFLAGS=

#
# PY-APSW_BUILD_DIR is the directory in which the build is done.
# PY-APSW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-APSW_IPK_DIR is the directory in which the ipk is built.
# PY-APSW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-APSW_BUILD_DIR=$(BUILD_DIR)/py-apsw
PY-APSW_SOURCE_DIR=$(SOURCE_DIR)/py-apsw

PY24-APSW_IPK_DIR=$(BUILD_DIR)/py-apsw-$(PY-APSW_VERSION)-ipk
PY24-APSW_IPK=$(BUILD_DIR)/py-apsw_$(PY-APSW_VERSION)-$(PY-APSW_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-APSW_IPK_DIR=$(BUILD_DIR)/py25-apsw-$(PY-APSW_VERSION)-ipk
PY25-APSW_IPK=$(BUILD_DIR)/py25-apsw_$(PY-APSW_VERSION)-$(PY-APSW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-apsw-source py-apsw-unpack py-apsw py-apsw-stage py-apsw-ipk py-apsw-clean py-apsw-dirclean py-apsw-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-APSW_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-APSW_SITE)/$(PY-APSW_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-apsw-source: $(DL_DIR)/$(PY-APSW_SOURCE) $(PY-APSW_PATCHES)

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
$(PY-APSW_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-APSW_SOURCE) $(PY-APSW_PATCHES)
	$(MAKE) python-stage sqlite-stage
	rm -rf $(PY-APSW_BUILD_DIR)
	mkdir -p $(PY-APSW_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-APSW_DIR)
	$(PY-APSW_UNZIP) $(DL_DIR)/$(PY-APSW_SOURCE) -d $(BUILD_DIR)
#	cat $(PY-APSW_PATCHES) | patch -d $(BUILD_DIR)/$(PY-APSW_DIR) -p1
	mv $(BUILD_DIR)/$(PY-APSW_DIR) $(PY-APSW_BUILD_DIR)/2.4
	(cd $(PY-APSW_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-APSW_DIR)
	$(PY-APSW_UNZIP) $(DL_DIR)/$(PY-APSW_SOURCE) -d $(BUILD_DIR)
#	cat $(PY-APSW_PATCHES) | patch -d $(BUILD_DIR)/$(PY-APSW_DIR) -p1
	mv $(BUILD_DIR)/$(PY-APSW_DIR) $(PY-APSW_BUILD_DIR)/2.5
	(cd $(PY-APSW_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	touch $(PY-APSW_BUILD_DIR)/.configured

py-apsw-unpack: $(PY-APSW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-APSW_BUILD_DIR)/.built: $(PY-APSW_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-APSW_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-APSW_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-apsw: $(PY-APSW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-APSW_BUILD_DIR)/.staged: $(PY-APSW_BUILD_DIR)/.built
	rm -f $(PY-APSW_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-APSW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-APSW_BUILD_DIR)/.staged

py-apsw-stage: $(PY-APSW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-apsw
#
$(PY24-APSW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-apsw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-APSW_PRIORITY)" >>$@
	@echo "Section: $(PY-APSW_SECTION)" >>$@
	@echo "Version: $(PY-APSW_VERSION)-$(PY-APSW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-APSW_MAINTAINER)" >>$@
	@echo "Source: $(PY-APSW_SITE)/$(PY-APSW_SOURCE)" >>$@
	@echo "Description: $(PY-APSW_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-APSW_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-APSW_CONFLICTS)" >>$@

$(PY25-APSW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-apsw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-APSW_PRIORITY)" >>$@
	@echo "Section: $(PY-APSW_SECTION)" >>$@
	@echo "Version: $(PY-APSW_VERSION)-$(PY-APSW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-APSW_MAINTAINER)" >>$@
	@echo "Source: $(PY-APSW_SITE)/$(PY-APSW_SOURCE)" >>$@
	@echo "Description: $(PY-APSW_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-APSW_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-APSW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-APSW_IPK_DIR)/opt/sbin or $(PY-APSW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-APSW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-APSW_IPK_DIR)/opt/etc/py-apsw/...
# Documentation files should be installed in $(PY-APSW_IPK_DIR)/opt/doc/py-apsw/...
# Daemon startup scripts should be installed in $(PY-APSW_IPK_DIR)/opt/etc/init.d/S??py-apsw
#
# You may need to patch your application to make it use these locations.
#
$(PY24-APSW_IPK): $(PY-APSW_BUILD_DIR)/.built
	rm -rf $(PY24-APSW_IPK_DIR) $(BUILD_DIR)/py-apsw_*_$(TARGET_ARCH).ipk
	(cd $(PY-APSW_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-APSW_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY24-APSW_IPK_DIR)/opt/lib/python2.4/site-packages/apsw.so
	$(MAKE) $(PY24-APSW_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-APSW_IPK_DIR)

$(PY25-APSW_IPK): $(PY-APSW_BUILD_DIR)/.built
	rm -rf $(PY25-APSW_IPK_DIR) $(BUILD_DIR)/py25-apsw_*_$(TARGET_ARCH).ipk
	(cd $(PY-APSW_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-APSW_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-APSW_IPK_DIR)/opt/lib/python2.5/site-packages/apsw.so
	$(MAKE) $(PY25-APSW_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-APSW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-apsw-ipk: $(PY24-APSW_IPK) $(PY25-APSW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-apsw-clean:
	-$(MAKE) -C $(PY-APSW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-apsw-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-APSW_DIR) $(PY-APSW_BUILD_DIR)
	rm -rf $(PY24-APSW_IPK_DIR) $(PY24-APSW_IPK)
	rm -rf $(PY25-APSW_IPK_DIR) $(PY25-APSW_IPK)

#
# Some sanity check for the package.
#
py-apsw-check: $(PY24-APSW_IPK) $(PY25-APSW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-APSW_IPK) $(PY25-APSW_IPK)
