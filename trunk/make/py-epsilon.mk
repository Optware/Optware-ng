###########################################################
#
# py-epsilon
#
###########################################################

#
# PY-EPSILON_VERSION, PY-EPSILON_SITE and PY-EPSILON_SOURCE define
# the upstream location of the source code for the package.
# PY-EPSILON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-EPSILON_UNZIP is the command used to unzip the source.
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
PY-EPSILON_VERSION=0.5.12
PY-EPSILON_SOURCE=Epsilon-$(PY-EPSILON_VERSION).tar.gz
PY-EPSILON_SITE=http://divmod.org/trac/attachment/wiki/SoftwareReleases/$(PY-EPSILON_SOURCE)?format=raw
PY-EPSILON_DIR=Epsilon-$(PY-EPSILON_VERSION)
PY-EPSILON_UNZIP=zcat
PY-EPSILON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-EPSILON_DESCRIPTION=A small python utility package.
PY-EPSILON_SECTION=misc
PY-EPSILON_PRIORITY=optional
PY25-EPSILON_DEPENDS=python25, py25-twisted
PY26-EPSILON_DEPENDS=python26, py26-twisted
PY-EPSILON_CONFLICTS=

#
# PY-EPSILON_IPK_VERSION should be incremented when the ipk changes.
#
PY-EPSILON_IPK_VERSION=1

#
# PY-EPSILON_CONFFILES should be a list of user-editable files
#PY-EPSILON_CONFFILES=/opt/etc/py-epsilon.conf /opt/etc/init.d/SXXpy-epsilon

#
# PY-EPSILON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-EPSILON_PATCHES=$(PY-EPSILON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-EPSILON_CPPFLAGS=
PY-EPSILON_LDFLAGS=

#
# PY-EPSILON_BUILD_DIR is the directory in which the build is done.
# PY-EPSILON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-EPSILON_IPK_DIR is the directory in which the ipk is built.
# PY-EPSILON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-EPSILON_BUILD_DIR=$(BUILD_DIR)/py-epsilon
PY-EPSILON_SOURCE_DIR=$(SOURCE_DIR)/py-epsilon

PY25-EPSILON_IPK_DIR=$(BUILD_DIR)/py25-epsilon-$(PY-EPSILON_VERSION)-ipk
PY25-EPSILON_IPK=$(BUILD_DIR)/py25-epsilon_$(PY-EPSILON_VERSION)-$(PY-EPSILON_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-EPSILON_IPK_DIR=$(BUILD_DIR)/py26-epsilon-$(PY-EPSILON_VERSION)-ipk
PY26-EPSILON_IPK=$(BUILD_DIR)/py26-epsilon_$(PY-EPSILON_VERSION)-$(PY-EPSILON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-epsilon-source py-epsilon-unpack py-epsilon py-epsilon-stage py-epsilon-ipk py-epsilon-clean py-epsilon-dirclean py-epsilon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-EPSILON_SOURCE):
	$(WGET) -O $@ $(PY-EPSILON_SITE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-epsilon-source: $(DL_DIR)/$(PY-EPSILON_SOURCE) $(PY-EPSILON_PATCHES)

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
$(PY-EPSILON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-EPSILON_SOURCE) $(PY-EPSILON_PATCHES) make/py-epsilon.mk
	$(MAKE) py-twisted-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-EPSILON_DIR)
	$(PY-EPSILON_UNZIP) $(DL_DIR)/$(PY-EPSILON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-EPSILON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-EPSILON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-EPSILON_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-EPSILON_DIR)
	$(PY-EPSILON_UNZIP) $(DL_DIR)/$(PY-EPSILON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-EPSILON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-EPSILON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-EPSILON_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6"; \
	    echo "[install]"; \
	    echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg \
	)
	touch $@

py-epsilon-unpack: $(PY-EPSILON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-EPSILON_BUILD_DIR)/.built: $(PY-EPSILON_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	cd $(@D)/2.6; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-epsilon: $(PY-EPSILON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-EPSILON_BUILD_DIR)/.staged: $(PY-EPSILON_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.6; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
		--root=$(STAGING_DIR) --prefix=/opt)
	touch $@

py-epsilon-stage: $(PY-EPSILON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-epsilon
#
$(PY25-EPSILON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-epsilon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-EPSILON_PRIORITY)" >>$@
	@echo "Section: $(PY-EPSILON_SECTION)" >>$@
	@echo "Version: $(PY-EPSILON_VERSION)-$(PY-EPSILON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-EPSILON_MAINTAINER)" >>$@
	@echo "Source: $(PY-EPSILON_SITE)/$(PY-EPSILON_SOURCE)" >>$@
	@echo "Description: $(PY-EPSILON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-EPSILON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-EPSILON_CONFLICTS)" >>$@

$(PY26-EPSILON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-epsilon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-EPSILON_PRIORITY)" >>$@
	@echo "Section: $(PY-EPSILON_SECTION)" >>$@
	@echo "Version: $(PY-EPSILON_VERSION)-$(PY-EPSILON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-EPSILON_MAINTAINER)" >>$@
	@echo "Source: $(PY-EPSILON_SITE)/$(PY-EPSILON_SOURCE)" >>$@
	@echo "Description: $(PY-EPSILON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-EPSILON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-EPSILON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-EPSILON_IPK_DIR)/opt/sbin or $(PY-EPSILON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-EPSILON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-EPSILON_IPK_DIR)/opt/etc/py-epsilon/...
# Documentation files should be installed in $(PY-EPSILON_IPK_DIR)/opt/doc/py-epsilon/...
# Daemon startup scripts should be installed in $(PY-EPSILON_IPK_DIR)/opt/etc/init.d/S??py-epsilon
#
# You may need to patch your application to make it use these locations.
#
$(PY25-EPSILON_IPK): $(PY-EPSILON_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-epsilon_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-EPSILON_IPK_DIR) $(BUILD_DIR)/py25-epsilon_*_$(TARGET_ARCH).ipk
	(cd $(PY-EPSILON_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
		--root=$(PY25-EPSILON_IPK_DIR) --prefix=/opt)
	rm -rf $(PY25-EPSILON_IPK_DIR)/opt/lib/python2.5/site-packages/build
	mv $(PY25-EPSILON_IPK_DIR)/opt/bin/benchmark $(PY25-EPSILON_IPK_DIR)/opt/bin/py25-epsilon-benchmark
	$(MAKE) $(PY25-EPSILON_IPK_DIR)/CONTROL/control
	echo $(PY-EPSILON_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-EPSILON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-EPSILON_IPK_DIR)

$(PY26-EPSILON_IPK): $(PY-EPSILON_BUILD_DIR)/.built
	rm -rf $(PY26-EPSILON_IPK_DIR) $(BUILD_DIR)/py26-epsilon_*_$(TARGET_ARCH).ipk
	(cd $(PY-EPSILON_BUILD_DIR)/2.6; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
		--root=$(PY26-EPSILON_IPK_DIR) --prefix=/opt)
	rm -rf $(PY25-EPSILON_IPK_DIR)/opt/lib/python2.5/site-packages/build
	mv $(PY26-EPSILON_IPK_DIR)/opt/bin/benchmark $(PY26-EPSILON_IPK_DIR)/opt/bin/py26-epsilon-benchmark
	$(MAKE) $(PY26-EPSILON_IPK_DIR)/CONTROL/control
	echo $(PY-EPSILON_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-EPSILON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-EPSILON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-epsilon-ipk: $(PY25-EPSILON_IPK) $(PY26-EPSILON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-epsilon-clean:
	-$(MAKE) -C $(PY-EPSILON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-epsilon-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-EPSILON_DIR) $(PY-EPSILON_BUILD_DIR)
	rm -rf $(PY25-EPSILON_IPK_DIR) $(PY25-EPSILON_IPK)
	rm -rf $(PY26-EPSILON_IPK_DIR) $(PY26-EPSILON_IPK)

#
# Some sanity check for the package.
#
py-epsilon-check: $(PY25-EPSILON_IPK) $(PY26-EPSILON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
