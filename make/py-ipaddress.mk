###########################################################
#
# py-ipaddress
#
###########################################################

#
# PY-IPADDRESS_VERSION, PY-IPADDRESS_SITE and PY-IPADDRESS_SOURCE define
# the upstream location of the source code for the package.
# PY-IPADDRESS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-IPADDRESS_UNZIP is the command used to unzip the source.
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
PY-IPADDRESS_SITE=https://pypi.python.org/packages/source/i/ipaddress
PY-IPADDRESS_VERSION=1.0.14
PY-IPADDRESS_SOURCE=ipaddress-$(PY-IPADDRESS_VERSION).tar.gz
PY-IPADDRESS_DIR=ipaddress-$(PY-IPADDRESS_VERSION)
PY-IPADDRESS_UNZIP=zcat
PY-IPADDRESS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-IPADDRESS_DESCRIPTION=Port of the 3.3+ ipaddress module to 2.6, 2.7, 3.2.
PY-IPADDRESS_SECTION=misc
PY-IPADDRESS_PRIORITY=optional
PY26-IPADDRESS_DEPENDS=python26
PY27-IPADDRESS_DEPENDS=python27
PY-IPADDRESS_CONFLICTS=

#
# PY-IPADDRESS_IPK_VERSION should be incremented when the ipk changes.
#
PY-IPADDRESS_IPK_VERSION=1

#
# PY-IPADDRESS_CONFFILES should be a list of user-editable files
#PY-IPADDRESS_CONFFILES=/opt/etc/py-ipaddress.conf /opt/etc/init.d/SXXpy-ipaddress

#
# PY-IPADDRESS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-IPADDRESS_PATCHES=$(PY-IPADDRESS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-IPADDRESS_CPPFLAGS=
PY-IPADDRESS_LDFLAGS=

#
# PY-IPADDRESS_BUILD_DIR is the directory in which the build is done.
# PY-IPADDRESS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-IPADDRESS_IPK_DIR is the directory in which the ipk is built.
# PY-IPADDRESS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-IPADDRESS_SOURCE_DIR=$(SOURCE_DIR)/py-ipaddress
PY-IPADDRESS_BUILD_DIR=$(BUILD_DIR)/py-ipaddress
PY-IPADDRESS_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-ipaddress

PY26-IPADDRESS_IPK_DIR=$(BUILD_DIR)/py26-ipaddress-$(PY-IPADDRESS_VERSION)-ipk
PY26-IPADDRESS_IPK=$(BUILD_DIR)/py26-ipaddress_$(PY-IPADDRESS_VERSION)-$(PY-IPADDRESS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-IPADDRESS_IPK_DIR=$(BUILD_DIR)/py27-ipaddress-$(PY-IPADDRESS_VERSION)-ipk
PY27-IPADDRESS_IPK=$(BUILD_DIR)/py27-ipaddress_$(PY-IPADDRESS_VERSION)-$(PY-IPADDRESS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-ipaddress-source py-ipaddress-unpack py-ipaddress py-ipaddress-stage py-ipaddress-ipk py-ipaddress-clean py-ipaddress-dirclean py-ipaddress-check py-ipaddress-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-IPADDRESS_SOURCE):
	$(WGET) -P $(@D) $(PY-IPADDRESS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-ipaddress-source: $(DL_DIR)/$(PY-IPADDRESS_SOURCE) $(PY-IPADDRESS_PATCHES)

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
$(PY-IPADDRESS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-IPADDRESS_SOURCE) $(PY-IPADDRESS_PATCHES) make/py-ipaddress.mk
	$(MAKE) python26-host-stage python27-host-stage
	$(MAKE) python26-stage python27-stage
	rm -rf $(BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE)
	$(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IPADDRESS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-IPADDRESS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = /opt/bin"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE)
	$(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IPADDRESS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-IPADDRESS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = /opt/bin"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.7"; \
	    ) >> setup.cfg \
	)
	touch $@

py-ipaddress-unpack: $(PY-IPADDRESS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-IPADDRESS_BUILD_DIR)/.built: $(PY-IPADDRESS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-ipaddress: $(PY-IPADDRESS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-IPADDRESS_BUILD_DIR)/.staged: $(PY-IPADDRESS_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=/opt)
	touch $@

$(PY-IPADDRESS_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-IPADDRESS_SOURCE) make/py-ipaddress.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)
	$(MAKE) python26-host-stage python27-host-stage
	$(MAKE) py-ordereddict-host-stage
	mkdir -p $(@D)/
	$(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)/2.6
	$(PY-IPADDRESS_UNZIP) $(DL_DIR)/$(PY-IPADDRESS_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-IPADDRESS_DIR) $(@D)/2.7
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-ipaddress-stage: $(PY-IPADDRESS_BUILD_DIR)/.staged

py-ipaddress-host-stage: $(PY-IPADDRESS_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-ipaddress
#
$(PY26-IPADDRESS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-ipaddress" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IPADDRESS_PRIORITY)" >>$@
	@echo "Section: $(PY-IPADDRESS_SECTION)" >>$@
	@echo "Version: $(PY-IPADDRESS_VERSION)-$(PY-IPADDRESS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IPADDRESS_MAINTAINER)" >>$@
	@echo "Source: $(PY-IPADDRESS_SITE)/$(PY-IPADDRESS_SOURCE)" >>$@
	@echo "Description: $(PY-IPADDRESS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-IPADDRESS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IPADDRESS_CONFLICTS)" >>$@

$(PY27-IPADDRESS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py27-ipaddress" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IPADDRESS_PRIORITY)" >>$@
	@echo "Section: $(PY-IPADDRESS_SECTION)" >>$@
	@echo "Version: $(PY-IPADDRESS_VERSION)-$(PY-IPADDRESS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IPADDRESS_MAINTAINER)" >>$@
	@echo "Source: $(PY-IPADDRESS_SITE)/$(PY-IPADDRESS_SOURCE)" >>$@
	@echo "Description: $(PY-IPADDRESS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-IPADDRESS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IPADDRESS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-IPADDRESS_IPK_DIR)/opt/sbin or $(PY-IPADDRESS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-IPADDRESS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-IPADDRESS_IPK_DIR)/opt/etc/py-ipaddress/...
# Documentation files should be installed in $(PY-IPADDRESS_IPK_DIR)/opt/doc/py-ipaddress/...
# Daemon startup scripts should be installed in $(PY-IPADDRESS_IPK_DIR)/opt/etc/init.d/S??py-ipaddress
#
# You may need to patch your application to make it use these locations.
#
$(PY26-IPADDRESS_IPK): $(PY-IPADDRESS_BUILD_DIR)/.built
	$(MAKE) py-ipaddress
	rm -rf $(PY26-IPADDRESS_IPK_DIR) $(BUILD_DIR)/py26-ipaddress_*_$(TARGET_ARCH).ipk
	(cd $(PY-IPADDRESS_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-IPADDRESS_IPK_DIR) --prefix=/opt)
#	rm -f $(PY26-IPADDRESS_IPK_DIR)/opt/bin/easy_install
	$(MAKE) $(PY26-IPADDRESS_IPK_DIR)/CONTROL/control
	echo $(PY-IPADDRESS_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-IPADDRESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-IPADDRESS_IPK_DIR)

$(PY27-IPADDRESS_IPK): $(PY-IPADDRESS_BUILD_DIR)/.built
	$(MAKE) py-ipaddress
	rm -rf $(PY27-IPADDRESS_IPK_DIR) $(BUILD_DIR)/py27-ipaddress_*_$(TARGET_ARCH).ipk
	(cd $(PY-IPADDRESS_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-IPADDRESS_IPK_DIR) --prefix=/opt)
	rm -f $(PY27-IPADDRESS_IPK_DIR)/opt/bin/easy_install
	$(MAKE) $(PY27-IPADDRESS_IPK_DIR)/CONTROL/control
	echo $(PY-IPADDRESS_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-IPADDRESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-IPADDRESS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-ipaddress-ipk: $(PY26-IPADDRESS_IPK) $(PY27-IPADDRESS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-ipaddress-clean:
	-$(MAKE) -C $(PY-IPADDRESS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-ipaddress-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-IPADDRESS_DIR) $(BUILD_DIR)/$(PY-IPADDRESS_DIR_OLD) \
	$(PY-IPADDRESS_HOST_BUILD_DIR) $(PY-IPADDRESS_BUILD_DIR) \
	$(PY26-IPADDRESS_IPK_DIR) $(PY26-IPADDRESS_IPK) \
	$(PY27-IPADDRESS_IPK_DIR) $(PY27-IPADDRESS_IPK) \

#
# Some sanity check for the package.
#
py-ipaddress-check: $(PY26-IPADDRESS_IPK) $(PY27-IPADDRESS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
