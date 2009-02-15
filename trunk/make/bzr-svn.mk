###########################################################
#
# bzr-svn
#
###########################################################

#
# BZR-SVN_VERSION, BZR-SVN_SITE and BZR-SVN_SOURCE define
# the upstream location of the source code for the package.
# BZR-SVN_DIR is the directory which is created when the source
# archive is unpacked.
# BZR-SVN_UNZIP is the command used to unzip the source.
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
BZR-SVN_VERSION=0.5.0
BZR-SVN_SITE=http://samba.org/~jelmer/bzr
BZR-SVN_SOURCE=bzr-svn-$(BZR-SVN_VERSION).tar.gz
BZR-SVN_DIR=bzr-svn-$(BZR-SVN_VERSION)
BZR-SVN_UNZIP=zcat
BZR-SVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BZR-SVN_DESCRIPTION=Support for Subversion branches in Bazaar.
BZR-SVN_SECTION=devel
BZR-SVN_PRIORITY=optional
PY25-BZR-SVN_DEPENDS=py25-bazaar-ng, py25-subvertpy
PY26-BZR-SVN_DEPENDS=py26-bazaar-ng, py26-subvertpy
BZR-SVN_CONFLICTS=

#
# BZR-SVN_IPK_VERSION should be incremented when the ipk changes.
#
BZR-SVN_IPK_VERSION=1

#
# BZR-SVN_CONFFILES should be a list of user-editable files
#BZR-SVN_CONFFILES=/opt/etc/bzr-svn.conf /opt/etc/init.d/SXXbzr-svn

#
# BZR-SVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BZR-SVN_PATCHES=$(BZR-SVN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BZR-SVN_CPPFLAGS=
BZR-SVN_LDFLAGS=

#
# BZR-SVN_BUILD_DIR is the directory in which the build is done.
# BZR-SVN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BZR-SVN_IPK_DIR is the directory in which the ipk is built.
# BZR-SVN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BZR-SVN_BUILD_DIR=$(BUILD_DIR)/bzr-svn
BZR-SVN_SOURCE_DIR=$(SOURCE_DIR)/bzr-svn

PY25-BZR-SVN_IPK_DIR=$(BUILD_DIR)/py25-bzr-svn-$(BZR-SVN_VERSION)-ipk
PY25-BZR-SVN_IPK=$(BUILD_DIR)/py25-bzr-svn_$(BZR-SVN_VERSION)-$(BZR-SVN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BZR-SVN_IPK_DIR=$(BUILD_DIR)/py26-bzr-svn-$(BZR-SVN_VERSION)-ipk
PY26-BZR-SVN_IPK=$(BUILD_DIR)/py26-bzr-svn_$(BZR-SVN_VERSION)-$(BZR-SVN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bzr-svn-source bzr-svn-unpack bzr-svn bzr-svn-stage bzr-svn-ipk bzr-svn-clean bzr-svn-dirclean bzr-svn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BZR-SVN_SOURCE):
	$(WGET) -P $(@D) $(BZR-SVN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bzr-svn-source: $(DL_DIR)/$(BZR-SVN_SOURCE) $(BZR-SVN_PATCHES)

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
$(BZR-SVN_BUILD_DIR)/.configured: $(DL_DIR)/$(BZR-SVN_SOURCE) $(BZR-SVN_PATCHES)
	$(MAKE) python-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(BZR-SVN_DIR)
	$(BZR-SVN_UNZIP) $(DL_DIR)/$(BZR-SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR-SVN_PATCHES) | patch -d $(BUILD_DIR)/$(BZR-SVN_DIR) -p1
	mv $(BUILD_DIR)/$(BZR-SVN_DIR) $(@D)/2.5
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
	rm -rf $(BUILD_DIR)/$(BZR-SVN_DIR)
	$(BZR-SVN_UNZIP) $(DL_DIR)/$(BZR-SVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR-SVN_PATCHES) | patch -d $(BUILD_DIR)/$(BZR-SVN_DIR) -p1
	mv $(BUILD_DIR)/$(BZR-SVN_DIR) $(@D)/2.6
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

bzr-svn-unpack: $(BZR-SVN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BZR-SVN_BUILD_DIR)/.built: $(BZR-SVN_BUILD_DIR)/.configured
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
bzr-svn: $(BZR-SVN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BZR-SVN_BUILD_DIR)/.staged: $(BZR-SVN_BUILD_DIR)/.built
#	rm -f $@
#	#$(MAKE) -C $(BZR-SVN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bzr-svn-stage: $(BZR-SVN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bzr-svn
#
$(PY25-BZR-SVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bzr-svn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR-SVN_PRIORITY)" >>$@
	@echo "Section: $(BZR-SVN_SECTION)" >>$@
	@echo "Version: $(BZR-SVN_VERSION)-$(BZR-SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR-SVN_MAINTAINER)" >>$@
	@echo "Source: $(BZR-SVN_SITE)/$(BZR-SVN_SOURCE)" >>$@
	@echo "Description: $(BZR-SVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BZR-SVN_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR-SVN_CONFLICTS)" >>$@

$(PY26-BZR-SVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-bzr-svn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR-SVN_PRIORITY)" >>$@
	@echo "Section: $(BZR-SVN_SECTION)" >>$@
	@echo "Version: $(BZR-SVN_VERSION)-$(BZR-SVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR-SVN_MAINTAINER)" >>$@
	@echo "Source: $(BZR-SVN_SITE)/$(BZR-SVN_SOURCE)" >>$@
	@echo "Description: $(BZR-SVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BZR-SVN_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR-SVN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BZR-SVN_IPK_DIR)/opt/sbin or $(BZR-SVN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BZR-SVN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BZR-SVN_IPK_DIR)/opt/etc/bzr-svn/...
# Documentation files should be installed in $(BZR-SVN_IPK_DIR)/opt/doc/bzr-svn/...
# Daemon startup scripts should be installed in $(BZR-SVN_IPK_DIR)/opt/etc/init.d/S??bzr-svn
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BZR-SVN_IPK): $(BZR-SVN_BUILD_DIR)/.built
	rm -rf $(PY25-BZR-SVN_IPK_DIR) $(BUILD_DIR)/py25-bzr-svn_*_$(TARGET_ARCH).ipk
	(cd $(BZR-SVN_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BZR-SVN_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-BZR-SVN_IPK_DIR)/opt/lib/python2.5/site-packages/bzrlib/*.so
	$(MAKE) $(PY25-BZR-SVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BZR-SVN_IPK_DIR)

$(PY26-BZR-SVN_IPK): $(BZR-SVN_BUILD_DIR)/.built
	rm -rf $(PY26-BZR-SVN_IPK_DIR) $(BUILD_DIR)/py26-bzr-svn_*_$(TARGET_ARCH).ipk
	(cd $(BZR-SVN_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-BZR-SVN_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-BZR-SVN_IPK_DIR)/opt/lib/python2.6/site-packages/bzrlib/*.so
	$(MAKE) $(PY26-BZR-SVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BZR-SVN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bzr-svn-ipk: $(PY25-BZR-SVN_IPK) $(PY26-BZR-SVN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bzr-svn-clean:
	-$(MAKE) -C $(BZR-SVN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bzr-svn-dirclean:
	rm -rf $(BUILD_DIR)/$(BZR-SVN_DIR) $(BZR-SVN_BUILD_DIR)
	rm -rf $(PY25-BZR-SVN_IPK_DIR) $(PY25-BZR-SVN_IPK)
	rm -rf $(PY26-BZR-SVN_IPK_DIR) $(PY26-BZR-SVN_IPK)

#
# Some sanity check for the package.
#
bzr-svn-check: $(PY25-BZR-SVN_IPK) $(PY26-BZR-SVN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
