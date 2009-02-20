###########################################################
#
# py-statlib
#
###########################################################

#
# PY-STATLIB_VERSION, PY-STATLIB_SITE and PY-STATLIB_SOURCE define
# the upstream location of the source code for the package.
# PY-STATLIB_DIR is the directory which is created when the source
# archive is unpacked.
# PY-STATLIB_UNZIP is the command used to unzip the source.
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
PY-STATLIB_VERSION=1.1
PY-STATLIB_SITE=http://python-statlib.googlecode.com/files
PY-STATLIB_SOURCE=statlib-$(PY-STATLIB_VERSION).tar.gz
PY-STATLIB_DIR=statlib-$(PY-STATLIB_VERSION)
PY-STATLIB_UNZIP=zcat
PY-STATLIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-STATLIB_DESCRIPTION=Python statistics modules.
PY-STATLIB_SECTION=misc
PY-STATLIB_PRIORITY=optional
PY25-STATLIB_DEPENDS=python25
PY26-STATLIB_DEPENDS=python26
PY-STATLIB_CONFLICTS=

#
# PY-STATLIB_IPK_VERSION should be incremented when the ipk changes.
#
PY-STATLIB_IPK_VERSION=1

#
# PY-STATLIB_CONFFILES should be a list of user-editable files
#PY-STATLIB_CONFFILES=/opt/etc/py-statlib.conf /opt/etc/init.d/SXXpy-statlib

#
# PY-STATLIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-STATLIB_PATCHES=$(PY-STATLIB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-STATLIB_CPPFLAGS=
PY-STATLIB_LDFLAGS=

#
# PY-STATLIB_BUILD_DIR is the directory in which the build is done.
# PY-STATLIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-STATLIB_IPK_DIR is the directory in which the ipk is built.
# PY-STATLIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-STATLIB_BUILD_DIR=$(BUILD_DIR)/py-statlib
PY-STATLIB_SOURCE_DIR=$(SOURCE_DIR)/py-statlib

PY25-STATLIB_IPK_DIR=$(BUILD_DIR)/py25-statlib-$(PY-STATLIB_VERSION)-ipk
PY25-STATLIB_IPK=$(BUILD_DIR)/py25-statlib_$(PY-STATLIB_VERSION)-$(PY-STATLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-STATLIB_IPK_DIR=$(BUILD_DIR)/py26-statlib-$(PY-STATLIB_VERSION)-ipk
PY26-STATLIB_IPK=$(BUILD_DIR)/py26-statlib_$(PY-STATLIB_VERSION)-$(PY-STATLIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-statlib-source py-statlib-unpack py-statlib py-statlib-stage py-statlib-ipk py-statlib-clean py-statlib-dirclean py-statlib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-STATLIB_SOURCE):
	$(WGET) -P $(@D) $(PY-STATLIB_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-statlib-source: $(DL_DIR)/$(PY-STATLIB_SOURCE) $(PY-STATLIB_PATCHES)

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
$(PY-STATLIB_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-STATLIB_SOURCE) $(PY-STATLIB_PATCHES) make/py-statlib.mk
	$(MAKE) python25-stage python25-host-stage
	$(MAKE) python26-stage python26-host-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-STATLIB_DIR)
	$(PY-STATLIB_UNZIP) $(DL_DIR)/$(PY-STATLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-STATLIB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-STATLIB_DIR) -p1
	mv $(BUILD_DIR)/$(PY-STATLIB_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
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
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-STATLIB_DIR)
	$(PY-STATLIB_UNZIP) $(DL_DIR)/$(PY-STATLIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-STATLIB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-STATLIB_DIR) -p1
	mv $(BUILD_DIR)/$(PY-STATLIB_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-statlib-unpack: $(PY-STATLIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-STATLIB_BUILD_DIR)/.built: $(PY-STATLIB_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-statlib: $(PY-STATLIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-STATLIB_BUILD_DIR)/.staged: $(PY-STATLIB_BUILD_DIR)/.built
#	rm -f $@
	#$(MAKE) -C $(PY-STATLIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-statlib-stage: $(PY-STATLIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-statlib
#
$(PY25-STATLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-statlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-STATLIB_PRIORITY)" >>$@
	@echo "Section: $(PY-STATLIB_SECTION)" >>$@
	@echo "Version: $(PY-STATLIB_VERSION)-$(PY-STATLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-STATLIB_MAINTAINER)" >>$@
	@echo "Source: $(PY-STATLIB_SITE)/$(PY-STATLIB_SOURCE)" >>$@
	@echo "Description: $(PY-STATLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-STATLIB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-STATLIB_CONFLICTS)" >>$@

$(PY26-STATLIB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-statlib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-STATLIB_PRIORITY)" >>$@
	@echo "Section: $(PY-STATLIB_SECTION)" >>$@
	@echo "Version: $(PY-STATLIB_VERSION)-$(PY-STATLIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-STATLIB_MAINTAINER)" >>$@
	@echo "Source: $(PY-STATLIB_SITE)/$(PY-STATLIB_SOURCE)" >>$@
	@echo "Description: $(PY-STATLIB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-STATLIB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-STATLIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-STATLIB_IPK_DIR)/opt/sbin or $(PY-STATLIB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-STATLIB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-STATLIB_IPK_DIR)/opt/etc/py-statlib/...
# Documentation files should be installed in $(PY-STATLIB_IPK_DIR)/opt/doc/py-statlib/...
# Daemon startup scripts should be installed in $(PY-STATLIB_IPK_DIR)/opt/etc/init.d/S??py-statlib
#
# You may need to patch your application to make it use these locations.
#
$(PY25-STATLIB_IPK): $(PY-STATLIB_BUILD_DIR)/.built
	rm -rf $(PY25-STATLIB_IPK_DIR) $(BUILD_DIR)/py25-statlib_*_$(TARGET_ARCH).ipk
	(cd $(PY-STATLIB_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-STATLIB_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-STATLIB_IPK_DIR)/opt/lib/python2.5/site-packages/bzrlib/*.so
	$(MAKE) $(PY25-STATLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-STATLIB_IPK_DIR)

$(PY26-STATLIB_IPK): $(PY-STATLIB_BUILD_DIR)/.built
	rm -rf $(PY26-STATLIB_IPK_DIR) $(BUILD_DIR)/py26-statlib_*_$(TARGET_ARCH).ipk
	(cd $(PY-STATLIB_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-STATLIB_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-STATLIB_IPK_DIR)/opt/lib/python2.6/site-packages/bzrlib/*.so
	$(MAKE) $(PY26-STATLIB_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-STATLIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-statlib-ipk: $(PY25-STATLIB_IPK) $(PY26-STATLIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-statlib-clean:
	-$(MAKE) -C $(PY-STATLIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-statlib-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-STATLIB_DIR) $(PY-STATLIB_BUILD_DIR)
	rm -rf $(PY25-STATLIB_IPK_DIR) $(PY25-STATLIB_IPK)
	rm -rf $(PY26-STATLIB_IPK_DIR) $(PY26-STATLIB_IPK)

#
# Some sanity check for the package.
#
py-statlib-check: $(PY25-STATLIB_IPK) $(PY26-STATLIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
