###########################################################
#
# bzrtools
#
###########################################################

#
# BZRTOOLS_VERSION, BZRTOOLS_SITE and BZRTOOLS_SOURCE define
# the upstream location of the source code for the package.
# BZRTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# BZRTOOLS_UNZIP is the command used to unzip the source.
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
BZRTOOLS_VERSION=1.13.0
BZRTOOLS_SITE=http://launchpad.net/bzrtools/stable/$(BZRTOOLS_VERSION)/+download
BZRTOOLS_SOURCE=bzrtools-$(BZRTOOLS_VERSION).tar.gz
BZRTOOLS_DIR=bzrtools
BZRTOOLS_UNZIP=zcat
BZRTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BZRTOOLS_DESCRIPTION=A set of plugins for Bazaar.
BZRTOOLS_SECTION=devel
BZRTOOLS_PRIORITY=optional
PY25-BZRTOOLS_DEPENDS=py25-bazaar-ng
PY26-BZRTOOLS_DEPENDS=py26-bazaar-ng
BZRTOOLS_CONFLICTS=

#
# BZRTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
BZRTOOLS_IPK_VERSION=1

#
# BZRTOOLS_CONFFILES should be a list of user-editable files
#BZRTOOLS_CONFFILES=/opt/etc/bzrtools.conf /opt/etc/init.d/SXXbzrtools

#
# BZRTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BZRTOOLS_PATCHES=$(BZRTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BZRTOOLS_CPPFLAGS=
BZRTOOLS_LDFLAGS=

#
# BZRTOOLS_BUILD_DIR is the directory in which the build is done.
# BZRTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BZRTOOLS_IPK_DIR is the directory in which the ipk is built.
# BZRTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BZRTOOLS_BUILD_DIR=$(BUILD_DIR)/bzrtools
BZRTOOLS_SOURCE_DIR=$(SOURCE_DIR)/bzrtools

PY25-BZRTOOLS_IPK_DIR=$(BUILD_DIR)/py25-bzrtools-$(BZRTOOLS_VERSION)-ipk
PY25-BZRTOOLS_IPK=$(BUILD_DIR)/py25-bzrtools_$(BZRTOOLS_VERSION)-$(BZRTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BZRTOOLS_IPK_DIR=$(BUILD_DIR)/py26-bzrtools-$(BZRTOOLS_VERSION)-ipk
PY26-BZRTOOLS_IPK=$(BUILD_DIR)/py26-bzrtools_$(BZRTOOLS_VERSION)-$(BZRTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bzrtools-source bzrtools-unpack bzrtools bzrtools-stage bzrtools-ipk bzrtools-clean bzrtools-dirclean bzrtools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BZRTOOLS_SOURCE):
	$(WGET) --no-check-certificate -P $(@D) $(BZRTOOLS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bzrtools-source: $(DL_DIR)/$(BZRTOOLS_SOURCE) $(BZRTOOLS_PATCHES)

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
$(BZRTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(BZRTOOLS_SOURCE) $(BZRTOOLS_PATCHES) make/bzrtools.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	$(BZRTOOLS_UNZIP) $(DL_DIR)/$(BZRTOOLS_SOURCE) | tar -C $(@D) -xvf -
#	cat $(BZRTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(BZRTOOLS_DIR) -p1
	mv $(@D)/$(BZRTOOLS_DIR) $(@D)/2.5
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
	$(BZRTOOLS_UNZIP) $(DL_DIR)/$(BZRTOOLS_SOURCE) | tar -C $(@D) -xvf -
#	cat $(BZRTOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(BZRTOOLS_DIR) -p1
	mv $(@D)/$(BZRTOOLS_DIR) $(@D)/2.6
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

bzrtools-unpack: $(BZRTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BZRTOOLS_BUILD_DIR)/.built: $(BZRTOOLS_BUILD_DIR)/.configured
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
bzrtools: $(BZRTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(BZRTOOLS_BUILD_DIR)/.staged: $(BZRTOOLS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(BZRTOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#bzrtools-stage: $(BZRTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bzrtools
#
$(PY25-BZRTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bzrtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZRTOOLS_PRIORITY)" >>$@
	@echo "Section: $(BZRTOOLS_SECTION)" >>$@
	@echo "Version: $(BZRTOOLS_VERSION)-$(BZRTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZRTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(BZRTOOLS_SITE)/$(BZRTOOLS_SOURCE)" >>$@
	@echo "Description: $(BZRTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BZRTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(BZRTOOLS_CONFLICTS)" >>$@

$(PY26-BZRTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-bzrtools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BZRTOOLS_PRIORITY)" >>$@
	@echo "Section: $(BZRTOOLS_SECTION)" >>$@
	@echo "Version: $(BZRTOOLS_VERSION)-$(BZRTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BZRTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(BZRTOOLS_SITE)/$(BZRTOOLS_SOURCE)" >>$@
	@echo "Description: $(BZRTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BZRTOOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(BZRTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BZRTOOLS_IPK_DIR)/opt/sbin or $(BZRTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BZRTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BZRTOOLS_IPK_DIR)/opt/etc/bzrtools/...
# Documentation files should be installed in $(BZRTOOLS_IPK_DIR)/opt/doc/bzrtools/...
# Daemon startup scripts should be installed in $(BZRTOOLS_IPK_DIR)/opt/etc/init.d/S??bzrtools
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BZRTOOLS_IPK): $(BZRTOOLS_BUILD_DIR)/.built
	rm -rf $(PY25-BZRTOOLS_IPK_DIR) $(BUILD_DIR)/py25-bzrtools_*_$(TARGET_ARCH).ipk
	(cd $(BZRTOOLS_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BZRTOOLS_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-BZRTOOLS_IPK_DIR)/opt/lib/python2.5/site-packages/bzrlib/*.so
	$(MAKE) $(PY25-BZRTOOLS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BZRTOOLS_IPK_DIR)

$(PY26-BZRTOOLS_IPK): $(BZRTOOLS_BUILD_DIR)/.built
	rm -rf $(PY26-BZRTOOLS_IPK_DIR) $(BUILD_DIR)/py26-bzrtools_*_$(TARGET_ARCH).ipk
	(cd $(BZRTOOLS_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-BZRTOOLS_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-BZRTOOLS_IPK_DIR)/opt/lib/python2.6/site-packages/bzrlib/*.so
	$(MAKE) $(PY26-BZRTOOLS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BZRTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bzrtools-ipk: $(PY25-BZRTOOLS_IPK) $(PY26-BZRTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bzrtools-clean:
	-$(MAKE) -C $(BZRTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bzrtools-dirclean:
	rm -rf $(BUILD_DIR)/$(BZRTOOLS_DIR) $(BZRTOOLS_BUILD_DIR)
	rm -rf $(PY25-BZRTOOLS_IPK_DIR) $(PY25-BZRTOOLS_IPK)
	rm -rf $(PY26-BZRTOOLS_IPK_DIR) $(PY26-BZRTOOLS_IPK)

#
# Some sanity check for the package.
#
bzrtools-check: $(PY25-BZRTOOLS_IPK) $(PY26-BZRTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
