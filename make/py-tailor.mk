###########################################################
#
# py-tailor
#
###########################################################

#
# PY-TAILOR_VERSION, PY-TAILOR_SITE and PY-TAILOR_SOURCE define
# the upstream location of the source code for the package.
# PY-TAILOR_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TAILOR_UNZIP is the command used to unzip the source.
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
PY-TAILOR_VERSION=0.9.26
PY-TAILOR_SITE=http://darcs.arstecnica.it/
PY-TAILOR_SOURCE=tailor-$(PY-TAILOR_VERSION).tar.gz
PY-TAILOR_DIR=tailor-$(PY-TAILOR_VERSION)
PY-TAILOR_UNZIP=zcat
PY-TAILOR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TAILOR_DESCRIPTION=A tool to migrate changesets between various SCMs.
PY-TAILOR_SECTION=web
PY-TAILOR_PRIORITY=optional
PY24-TAILOR_DEPENDS=python24
PY25-TAILOR_DEPENDS=python25
PY-TAILOR_CONFLICTS=

#
# PY-TAILOR_IPK_VERSION should be incremented when the ipk changes.
#
PY-TAILOR_IPK_VERSION=2

#
# PY-TAILOR_CONFFILES should be a list of user-editable files
#PY-TAILOR_CONFFILES=/opt/etc/py-tailor.conf /opt/etc/init.d/SXXpy-tailor

#
# PY-TAILOR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TAILOR_PATCHES=$(PY-TAILOR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TAILOR_CPPFLAGS=
PY-TAILOR_LDFLAGS=

#
# PY-TAILOR_BUILD_DIR is the directory in which the build is done.
# PY-TAILOR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TAILOR_IPK_DIR is the directory in which the ipk is built.
# PY-TAILOR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TAILOR_BUILD_DIR=$(BUILD_DIR)/py-tailor
PY-TAILOR_SOURCE_DIR=$(SOURCE_DIR)/py-tailor

PY24-TAILOR_IPK_DIR=$(BUILD_DIR)/py-tailor-$(PY-TAILOR_VERSION)-ipk
PY24-TAILOR_IPK=$(BUILD_DIR)/py-tailor_$(PY-TAILOR_VERSION)-$(PY-TAILOR_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-TAILOR_IPK_DIR=$(BUILD_DIR)/py25-tailor-$(PY-TAILOR_VERSION)-ipk
PY25-TAILOR_IPK=$(BUILD_DIR)/py25-tailor_$(PY-TAILOR_VERSION)-$(PY-TAILOR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-tailor-source py-tailor-unpack py-tailor py-tailor-stage py-tailor-ipk py-tailor-clean py-tailor-dirclean py-tailor-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-TAILOR_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TAILOR_SITE)/$(PY-TAILOR_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-tailor-source: $(DL_DIR)/$(PY-TAILOR_SOURCE) $(PY-TAILOR_PATCHES)

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
$(PY-TAILOR_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-TAILOR_SOURCE) $(PY-TAILOR_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-TAILOR_BUILD_DIR)
	mkdir -p $(PY-TAILOR_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-TAILOR_DIR)
	$(PY-TAILOR_UNZIP) $(DL_DIR)/$(PY-TAILOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TAILOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TAILOR_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TAILOR_DIR) $(PY-TAILOR_BUILD_DIR)/2.4
	(cd $(PY-TAILOR_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-TAILOR_DIR)
	$(PY-TAILOR_UNZIP) $(DL_DIR)/$(PY-TAILOR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-TAILOR_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TAILOR_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TAILOR_DIR) $(PY-TAILOR_BUILD_DIR)/2.5
	(cd $(PY-TAILOR_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-tailor-unpack: $(PY-TAILOR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TAILOR_BUILD_DIR)/.built: $(PY-TAILOR_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-TAILOR_BUILD_DIR)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	cd $(PY-TAILOR_BUILD_DIR)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	touch $@

#
# This is the build convenience target.
#
py-tailor: $(PY-TAILOR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TAILOR_BUILD_DIR)/.staged: $(PY-TAILOR_BUILD_DIR)/.built
	rm -f $@
	#$(MAKE) -C $(PY-TAILOR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-tailor-stage: $(PY-TAILOR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-tailor
#
$(PY24-TAILOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-tailor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TAILOR_PRIORITY)" >>$@
	@echo "Section: $(PY-TAILOR_SECTION)" >>$@
	@echo "Version: $(PY-TAILOR_VERSION)-$(PY-TAILOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TAILOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-TAILOR_SITE)/$(PY-TAILOR_SOURCE)" >>$@
	@echo "Description: $(PY-TAILOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-TAILOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TAILOR_CONFLICTS)" >>$@

$(PY25-TAILOR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-tailor" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TAILOR_PRIORITY)" >>$@
	@echo "Section: $(PY-TAILOR_SECTION)" >>$@
	@echo "Version: $(PY-TAILOR_VERSION)-$(PY-TAILOR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TAILOR_MAINTAINER)" >>$@
	@echo "Source: $(PY-TAILOR_SITE)/$(PY-TAILOR_SOURCE)" >>$@
	@echo "Description: $(PY-TAILOR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-TAILOR_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TAILOR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TAILOR_IPK_DIR)/opt/sbin or $(PY-TAILOR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TAILOR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TAILOR_IPK_DIR)/opt/etc/py-tailor/...
# Documentation files should be installed in $(PY-TAILOR_IPK_DIR)/opt/doc/py-tailor/...
# Daemon startup scripts should be installed in $(PY-TAILOR_IPK_DIR)/opt/etc/init.d/S??py-tailor
#
# You may need to patch your application to make it use these locations.
#
$(PY24-TAILOR_IPK): $(PY-TAILOR_BUILD_DIR)/.built
	rm -rf $(PY24-TAILOR_IPK_DIR) $(BUILD_DIR)/py-tailor_*_$(TARGET_ARCH).ipk
	(cd $(PY-TAILOR_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-TAILOR_IPK_DIR) --prefix=/opt; \
	)
#	-$(STRIP_COMMAND) `find $(PY24-TAILOR_IPK_DIR)/opt/lib/python2.4/site-packages/tailor -name '*.so'`
	$(MAKE) $(PY24-TAILOR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-TAILOR_IPK_DIR)

$(PY25-TAILOR_IPK): $(PY-TAILOR_BUILD_DIR)/.built
	rm -rf $(PY25-TAILOR_IPK_DIR) $(BUILD_DIR)/py25-tailor_*_$(TARGET_ARCH).ipk
	(cd $(PY-TAILOR_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-TAILOR_IPK_DIR) --prefix=/opt; \
	)
	mv $(PY25-TAILOR_IPK_DIR)/opt/bin/tailor $(PY25-TAILOR_IPK_DIR)/opt/bin/tailor-2.5
#	-$(STRIP_COMMAND) `find $(PY25-TAILOR_IPK_DIR)/opt/lib/python2.5/site-packages/tailor -name '*.so'`
	$(MAKE) $(PY25-TAILOR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-TAILOR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-tailor-ipk: $(PY24-TAILOR_IPK) $(PY25-TAILOR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-tailor-clean:
	-$(MAKE) -C $(PY-TAILOR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-tailor-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TAILOR_DIR) $(PY-TAILOR_BUILD_DIR)
	rm -rf $(PY24-TAILOR_IPK_DIR) $(PY24-TAILOR_IPK)
	rm -rf $(PY25-TAILOR_IPK_DIR) $(PY25-TAILOR_IPK)

#
# Some sanity check for the package.
#
py-tailor-check: $(PY24-TAILOR_IPK) $(PY25-TAILOR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-TAILOR_IPK) $(PY25-TAILOR_IPK)
