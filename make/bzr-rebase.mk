###########################################################
#
# bzr-rebase
#
###########################################################

#
# BZR-REBASE_VERSION, BZR-REBASE_SITE and BZR-REBASE_SOURCE define
# the upstream location of the source code for the package.
# BZR-REBASE_DIR is the directory which is created when the source
# archive is unpacked.
# BZR-REBASE_UNZIP is the command used to unzip the source.
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
BZR-REBASE_VERSION=0.4.4
BZR-REBASE_SITE=http://samba.org/~jelmer/bzr
BZR-REBASE_SOURCE=bzr-rebase-$(BZR-REBASE_VERSION).tar.gz
BZR-REBASE_DIR=bzr-rebase-$(BZR-REBASE_VERSION)
BZR-REBASE_UNZIP=zcat
BZR-REBASE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BZR-REBASE_DESCRIPTION=Rebase plugin for bzr.
BZR-REBASE_SECTION=devel
BZR-REBASE_PRIORITY=optional
PY25-BZR-REBASE_DEPENDS=py25-bazaar-ng
PY26-BZR-REBASE_DEPENDS=py26-bazaar-ng
BZR-REBASE_CONFLICTS=

#
# BZR-REBASE_IPK_VERSION should be incremented when the ipk changes.
#
BZR-REBASE_IPK_VERSION=1

#
# BZR-REBASE_CONFFILES should be a list of user-editable files
#BZR-REBASE_CONFFILES=/opt/etc/bzr-rebase.conf /opt/etc/init.d/SXXbzr-rebase

#
# BZR-REBASE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BZR-REBASE_PATCHES=$(BZR-REBASE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BZR-REBASE_CPPFLAGS=
BZR-REBASE_LDFLAGS=

#
# BZR-REBASE_BUILD_DIR is the directory in which the build is done.
# BZR-REBASE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BZR-REBASE_IPK_DIR is the directory in which the ipk is built.
# BZR-REBASE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BZR-REBASE_BUILD_DIR=$(BUILD_DIR)/bzr-rebase
BZR-REBASE_SOURCE_DIR=$(SOURCE_DIR)/bzr-rebase

PY25-BZR-REBASE_IPK_DIR=$(BUILD_DIR)/py25-bzr-rebase-$(BZR-REBASE_VERSION)-ipk
PY25-BZR-REBASE_IPK=$(BUILD_DIR)/py25-bzr-rebase_$(BZR-REBASE_VERSION)-$(BZR-REBASE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BZR-REBASE_IPK_DIR=$(BUILD_DIR)/py26-bzr-rebase-$(BZR-REBASE_VERSION)-ipk
PY26-BZR-REBASE_IPK=$(BUILD_DIR)/py26-bzr-rebase_$(BZR-REBASE_VERSION)-$(BZR-REBASE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bzr-rebase-source bzr-rebase-unpack bzr-rebase bzr-rebase-stage bzr-rebase-ipk bzr-rebase-clean bzr-rebase-dirclean bzr-rebase-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BZR-REBASE_SOURCE):
	$(WGET) -P $(@D) $(BZR-REBASE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bzr-rebase-source: $(DL_DIR)/$(BZR-REBASE_SOURCE) $(BZR-REBASE_PATCHES)

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
$(BZR-REBASE_BUILD_DIR)/.configured: $(DL_DIR)/$(BZR-REBASE_SOURCE) $(BZR-REBASE_PATCHES) make/bzr-rebase.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	$(BZR-REBASE_UNZIP) $(DL_DIR)/$(BZR-REBASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR-REBASE_PATCHES) | patch -d $(BUILD_DIR)/$(BZR-REBASE_DIR) -p1
	mv $(BUILD_DIR)/$(BZR-REBASE_DIR) $(@D)/2.5
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
	$(BZR-REBASE_UNZIP) $(DL_DIR)/$(BZR-REBASE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR-REBASE_PATCHES) | patch -d $(BUILD_DIR)/$(BZR-REBASE_DIR) -p1
	mv $(BUILD_DIR)/$(BZR-REBASE_DIR) $(@D)/2.6
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

bzr-rebase-unpack: $(BZR-REBASE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BZR-REBASE_BUILD_DIR)/.built: $(BZR-REBASE_BUILD_DIR)/.configured
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
bzr-rebase: $(BZR-REBASE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BZR-REBASE_BUILD_DIR)/.staged: $(BZR-REBASE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(BZR-REBASE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bzr-rebase-stage: $(BZR-REBASE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bzr-rebase
#
$(PY25-BZR-REBASE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bzr-rebase" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR-REBASE_PRIORITY)" >>$@
	@echo "Section: $(BZR-REBASE_SECTION)" >>$@
	@echo "Version: $(BZR-REBASE_VERSION)-$(BZR-REBASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR-REBASE_MAINTAINER)" >>$@
	@echo "Source: $(BZR-REBASE_SITE)/$(BZR-REBASE_SOURCE)" >>$@
	@echo "Description: $(BZR-REBASE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BZR-REBASE_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR-REBASE_CONFLICTS)" >>$@

$(PY26-BZR-REBASE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-bzr-rebase" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR-REBASE_PRIORITY)" >>$@
	@echo "Section: $(BZR-REBASE_SECTION)" >>$@
	@echo "Version: $(BZR-REBASE_VERSION)-$(BZR-REBASE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR-REBASE_MAINTAINER)" >>$@
	@echo "Source: $(BZR-REBASE_SITE)/$(BZR-REBASE_SOURCE)" >>$@
	@echo "Description: $(BZR-REBASE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BZR-REBASE_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR-REBASE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BZR-REBASE_IPK_DIR)/opt/sbin or $(BZR-REBASE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BZR-REBASE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BZR-REBASE_IPK_DIR)/opt/etc/bzr-rebase/...
# Documentation files should be installed in $(BZR-REBASE_IPK_DIR)/opt/doc/bzr-rebase/...
# Daemon startup scripts should be installed in $(BZR-REBASE_IPK_DIR)/opt/etc/init.d/S??bzr-rebase
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BZR-REBASE_IPK): $(BZR-REBASE_BUILD_DIR)/.built
	rm -rf $(PY25-BZR-REBASE_IPK_DIR) $(BUILD_DIR)/py25-bzr-rebase_*_$(TARGET_ARCH).ipk
	(cd $(BZR-REBASE_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BZR-REBASE_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-BZR-REBASE_IPK_DIR)/opt/lib/python2.5/site-packages/bzrlib/*.so
	$(MAKE) $(PY25-BZR-REBASE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BZR-REBASE_IPK_DIR)

$(PY26-BZR-REBASE_IPK): $(BZR-REBASE_BUILD_DIR)/.built
	rm -rf $(PY26-BZR-REBASE_IPK_DIR) $(BUILD_DIR)/py26-bzr-rebase_*_$(TARGET_ARCH).ipk
	(cd $(BZR-REBASE_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-BZR-REBASE_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-BZR-REBASE_IPK_DIR)/opt/lib/python2.6/site-packages/bzrlib/*.so
	$(MAKE) $(PY26-BZR-REBASE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BZR-REBASE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bzr-rebase-ipk: $(PY25-BZR-REBASE_IPK) $(PY26-BZR-REBASE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bzr-rebase-clean:
	-$(MAKE) -C $(BZR-REBASE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bzr-rebase-dirclean:
	rm -rf $(BUILD_DIR)/$(BZR-REBASE_DIR) $(BZR-REBASE_BUILD_DIR)
	rm -rf $(PY25-BZR-REBASE_IPK_DIR) $(PY25-BZR-REBASE_IPK)
	rm -rf $(PY26-BZR-REBASE_IPK_DIR) $(PY26-BZR-REBASE_IPK)

#
# Some sanity check for the package.
#
bzr-rebase-check: $(PY25-BZR-REBASE_IPK) $(PY26-BZR-REBASE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
