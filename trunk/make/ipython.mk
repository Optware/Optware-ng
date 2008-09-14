###########################################################
#
# ipython
#
###########################################################

#
# IPYTHON_VERSION, IPYTHON_SITE and IPYTHON_SOURCE define
# the upstream location of the source code for the package.
# IPYTHON_DIR is the directory which is created when the source
# archive is unpacked.
# IPYTHON_UNZIP is the command used to unzip the source.
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
IPYTHON_SITE=http://ipython.scipy.org/dist
IPYTHON_VERSION=0.9
IPYTHON_SOURCE=ipython-$(IPYTHON_VERSION).tar.gz
IPYTHON_DIR=ipython-$(IPYTHON_VERSION)
IPYTHON_UNZIP=zcat
IPYTHON_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPYTHON_DESCRIPTION=An enhanced interactive Python shell
IPYTHON_SECTION=misc
IPYTHON_PRIORITY=optional
IPYTHON_PY24_DEPENDS=python24, py24-setuptools
IPYTHON_PY25_DEPENDS=python25, py25-setuptools
IPYTHON_SUGGESTS=ipython-common
IPYTHON_CONFLICTS=

#
# IPYTHON_IPK_VERSION should be incremented when the ipk changes.
#
IPYTHON_IPK_VERSION=2

#
# IPYTHON_CONFFILES should be a list of user-editable files
#IPYTHON_CONFFILES=/opt/etc/ipython.conf /opt/etc/init.d/SXXipython

#
# IPYTHON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IPYTHON_PATCHES=$(IPYTHON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPYTHON_CPPFLAGS=
IPYTHON_LDFLAGS=

#
# IPYTHON_BUILD_DIR is the directory in which the build is done.
# IPYTHON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPYTHON_IPK_DIR is the directory in which the ipk is built.
# IPYTHON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPYTHON_BUILD_DIR=$(BUILD_DIR)/ipython
IPYTHON_SOURCE_DIR=$(SOURCE_DIR)/ipython

IPYTHON-COMMON_IPK_DIR=$(BUILD_DIR)/ipython-common-$(IPYTHON_VERSION)-ipk
IPYTHON-COMMON_IPK=$(BUILD_DIR)/ipython-common_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

IPYTHON_PY24_IPK_DIR=$(BUILD_DIR)/py24-ipython-$(IPYTHON_VERSION)-ipk
IPYTHON_PY24_IPK=$(BUILD_DIR)/py24-ipython_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

IPYTHON_PY25_IPK_DIR=$(BUILD_DIR)/py25-ipython-$(IPYTHON_VERSION)-ipk
IPYTHON_PY25_IPK=$(BUILD_DIR)/py25-ipython_$(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipython-source ipython-unpack ipython ipython-stage ipython-ipk ipython-clean ipython-dirclean ipython-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPYTHON_SOURCE):
	$(WGET) -P $(@D) $(IPYTHON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(IPYTHON_SITE)/old/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ipython-source: $(DL_DIR)/$(IPYTHON_SOURCE) $(IPYTHON_PATCHES)

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
$(IPYTHON_BUILD_DIR)/.configured: $(DL_DIR)/$(IPYTHON_SOURCE) $(IPYTHON_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(IPYTHON_BUILD_DIR)
	mkdir -p $(IPYTHON_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | patch -d $(BUILD_DIR)/$(IPYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR)
	$(IPYTHON_UNZIP) $(DL_DIR)/$(IPYTHON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(IPYTHON_PATCHES) | patch -d $(BUILD_DIR)/$(IPYTHON_DIR) -p1
	mv $(BUILD_DIR)/$(IPYTHON_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

ipython-unpack: $(IPYTHON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPYTHON_BUILD_DIR)/.built: $(IPYTHON_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" build)
	(cd $(@D)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" build)
	touch $@

#
# This is the build convenience target.
#
ipython: $(IPYTHON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IPYTHON_BUILD_DIR)/.staged: $(IPYTHON_BUILD_DIR)/.built
#	rm -f $(@D)/.staged
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $(@D)/.staged

ipython-stage: $(IPYTHON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ipython
#
$(IPYTHON-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ipython-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

$(IPYTHON_PY24_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY24_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

$(IPYTHON_PY25_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-ipython" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPYTHON_PRIORITY)" >>$@
	@echo "Section: $(IPYTHON_SECTION)" >>$@
	@echo "Version: $(IPYTHON_VERSION)-$(IPYTHON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPYTHON_MAINTAINER)" >>$@
	@echo "Source: $(IPYTHON_SITE)/$(IPYTHON_SOURCE)" >>$@
	@echo "Description: $(IPYTHON_DESCRIPTION)" >>$@
	@echo "Depends: $(IPYTHON_PY25_DEPENDS)" >>$@
	@echo "Suggests: $(IPYTHON_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPYTHON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPYTHON_IPK_DIR)/opt/sbin or $(IPYTHON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPYTHON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPYTHON_IPK_DIR)/opt/etc/ipython/...
# Documentation files should be installed in $(IPYTHON_IPK_DIR)/opt/doc/ipython/...
# Daemon startup scripts should be installed in $(IPYTHON_IPK_DIR)/opt/etc/init.d/S??ipython
#
# You may need to patch your application to make it use these locations.
#
$(IPYTHON_PY24_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON_PY24_IPK_DIR) $(BUILD_DIR)/py24-ipython_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/2.4; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
		install --root=$(IPYTHON_PY24_IPK_DIR) --prefix=/opt)
	rm -rf $(IPYTHON_PY24_IPK_DIR)/opt/share
	for f in $(IPYTHON_PY24_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(IPYTHON_PY24_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY24_IPK_DIR)

$(IPYTHON_PY25_IPK): $(IPYTHON_BUILD_DIR)/.built
	rm -rf $(IPYTHON_PY25_IPK_DIR) $(BUILD_DIR)/py25-ipython_*_$(TARGET_ARCH).ipk
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(BUILD_DIR)/ipython-common_*_$(TARGET_ARCH).ipk
	(cd $(IPYTHON_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
		install --root=$(IPYTHON_PY25_IPK_DIR) --prefix=/opt)
	rm -rf $(IPYTHON_PY25_IPK_DIR)/opt/share
	$(MAKE) $(IPYTHON_PY25_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON_PY25_IPK_DIR)

$(IPYTHON-COMMON_IPK): $(IPYTHON_BUILD_DIR)/.built
	(cd $(IPYTHON_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py \
		install --root=$(IPYTHON-COMMON_IPK_DIR) --prefix=/opt)
	rm -rf $(IPYTHON-COMMON_IPK_DIR)/opt/bin $(IPYTHON-COMMON_IPK_DIR)/opt/lib
	$(MAKE) $(IPYTHON-COMMON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPYTHON-COMMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ipython-ipk: $(IPYTHON_PY24_IPK) $(IPYTHON_PY25_IPK) $(IPYTHON-COMMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ipython-clean:
	-$(MAKE) -C $(IPYTHON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipython-dirclean:
	rm -rf $(BUILD_DIR)/$(IPYTHON_DIR) $(IPYTHON_BUILD_DIR)
	rm -rf $(IPYTHON-COMMON_IPK_DIR) $(IPYTHON-COMMON_IPK)
	rm -rf $(IPYTHON_PY24_IPK_DIR) $(IPYTHON_PY24_IPK)
	rm -rf $(IPYTHON_PY25_IPK_DIR) $(IPYTHON_PY25_IPK)

#
# Some sanity check for the package.
#
ipython-check: $(IPYTHON_PY24_IPK) $(IPYTHON_PY25_IPK) $(IPYTHON-COMMON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPYTHON_PY24_IPK) $(IPYTHON_PY25_IPK) $(IPYTHON-COMMON_IPK)
