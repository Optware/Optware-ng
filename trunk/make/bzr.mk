###########################################################
#
# bzr
#
###########################################################

#
# BZR_VERSION, BZR_SITE and BZR_SOURCE define
# the upstream location of the source code for the package.
# BZR_DIR is the directory which is created when the source
# archive is unpacked.
# BZR_UNZIP is the command used to unzip the source.
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
BZR_VERSION=2.3.3
BZR_SITE=https://launchpad.net/bzr/2.3/$(BZR_VERSION)/+download
BZR_SOURCE=bzr-$(BZR_VERSION).tar.gz
BZR_DIR=bzr-$(BZR_VERSION)
BZR_UNZIP=zcat
BZR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BZR_DESCRIPTION=A decentralized revision control system designed to be easy for developers and end users alike.
BZR_SECTION=misc
BZR_PRIORITY=optional
PY25-BZR_DEPENDS=python25
PY26-BZR_DEPENDS=python26
BZR_CONFLICTS=

#
# BZR_IPK_VERSION should be incremented when the ipk changes.
#
BZR_IPK_VERSION=1

#
# BZR_CONFFILES should be a list of user-editable files
#BZR_CONFFILES=/opt/etc/bzr.conf /opt/etc/init.d/SXXbzr

#
# BZR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BZR_PATCHES=$(BZR_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BZR_CPPFLAGS=
BZR_LDFLAGS=

#
# BZR_BUILD_DIR is the directory in which the build is done.
# BZR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BZR_IPK_DIR is the directory in which the ipk is built.
# BZR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BZR_BUILD_DIR=$(BUILD_DIR)/bzr
BZR_SOURCE_DIR=$(SOURCE_DIR)/bzr

PY25-BZR_IPK_DIR=$(BUILD_DIR)/py25-bzr-$(BZR_VERSION)-ipk
PY25-BZR_IPK=$(BUILD_DIR)/py25-bzr_$(BZR_VERSION)-$(BZR_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BZR_IPK_DIR=$(BUILD_DIR)/py26-bzr-$(BZR_VERSION)-ipk
PY26-BZR_IPK=$(BUILD_DIR)/py26-bzr_$(BZR_VERSION)-$(BZR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bzr-source bzr-unpack bzr bzr-stage bzr-ipk bzr-clean bzr-dirclean bzr-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BZR_SOURCE):
	$(WGET) --no-check-certificate -P $(@D) $(BZR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bzr-source: $(DL_DIR)/$(BZR_SOURCE) $(BZR_PATCHES)

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
$(BZR_BUILD_DIR)/.configured: $(DL_DIR)/$(BZR_SOURCE) $(BZR_PATCHES) make/bzr.mk
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/py-bazaar-ng
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(BZR_DIR)
	$(BZR_UNZIP) $(DL_DIR)/$(BZR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR_PATCHES) | patch -d $(BUILD_DIR)/$(BZR_DIR) -p1
	mv $(BUILD_DIR)/$(BZR_DIR) $(@D)/2.5
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
	rm -rf $(BUILD_DIR)/$(BZR_DIR)
	$(BZR_UNZIP) $(DL_DIR)/$(BZR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(BZR_PATCHES) | patch -d $(BUILD_DIR)/$(BZR_DIR) -p1
	mv $(BUILD_DIR)/$(BZR_DIR) $(@D)/2.6
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

bzr-unpack: $(BZR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BZR_BUILD_DIR)/.built: $(BZR_BUILD_DIR)/.configured
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
bzr: $(BZR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BZR_BUILD_DIR)/.staged: $(BZR_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(BZR_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bzr-stage: $(BZR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bzr
#
$(PY25-BZR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bzr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR_PRIORITY)" >>$@
	@echo "Section: $(BZR_SECTION)" >>$@
	@echo "Version: $(BZR_VERSION)-$(BZR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR_MAINTAINER)" >>$@
	@echo "Source: $(BZR_SITE)/$(BZR_SOURCE)" >>$@
	@echo "Description: $(BZR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BZR_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR_CONFLICTS)" >>$@

$(PY26-BZR_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-bzr" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZR_PRIORITY)" >>$@
	@echo "Section: $(BZR_SECTION)" >>$@
	@echo "Version: $(BZR_VERSION)-$(BZR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZR_MAINTAINER)" >>$@
	@echo "Source: $(BZR_SITE)/$(BZR_SOURCE)" >>$@
	@echo "Description: $(BZR_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BZR_DEPENDS)" >>$@
	@echo "Conflicts: $(BZR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BZR_IPK_DIR)/opt/sbin or $(BZR_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BZR_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BZR_IPK_DIR)/opt/etc/bzr/...
# Documentation files should be installed in $(BZR_IPK_DIR)/opt/doc/bzr/...
# Daemon startup scripts should be installed in $(BZR_IPK_DIR)/opt/etc/init.d/S??bzr
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BZR_IPK): $(BZR_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-bzr_*.ipk
	rm -rf $(PY25-BZR_IPK_DIR) $(BUILD_DIR)/py25-bzr_*_$(TARGET_ARCH).ipk
	(cd $(BZR_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BZR_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-BZR_IPK_DIR)/opt/lib/python2.5/site-packages/bzrlib/*.so
	$(MAKE) $(PY25-BZR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BZR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY25-BZR_IPK_DIR)

$(PY26-BZR_IPK): $(BZR_BUILD_DIR)/.built
	rm -rf $(PY26-BZR_IPK_DIR) $(BUILD_DIR)/py26-bzr_*_$(TARGET_ARCH).ipk
	(cd $(BZR_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-BZR_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY26-BZR_IPK_DIR)/opt/lib/python2.6/site-packages/bzrlib/*.so
	for f in $(PY26-BZR_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	rm -rf $(PY26-BZR_IPK_DIR)/opt/man
	$(MAKE) $(PY26-BZR_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BZR_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PY26-BZR_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bzr-ipk: $(PY25-BZR_IPK) $(PY26-BZR_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bzr-clean:
	-$(MAKE) -C $(BZR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bzr-dirclean:
	rm -rf $(BUILD_DIR)/$(BZR_DIR) $(BZR_BUILD_DIR)
	rm -rf $(PY25-BZR_IPK_DIR) $(PY25-BZR_IPK)
	rm -rf $(PY26-BZR_IPK_DIR) $(PY26-BZR_IPK)

#
# Some sanity check for the package.
#
bzr-check: $(PY25-BZR_IPK) $(PY26-BZR_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
