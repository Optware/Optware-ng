###########################################################
#
# py-idna
#
###########################################################

#
# PY-IDNA_VERSION, PY-IDNA_SITE and PY-IDNA_SOURCE define
# the upstream location of the source code for the package.
# PY-IDNA_DIR is the directory which is created when the source
# archive is unpacked.
# PY-IDNA_UNZIP is the command used to unzip the source.
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
PY-IDNA_SITE=https://pypi.python.org/packages/source/i/idna
PY-IDNA_VERSION=2.0
PY-IDNA_SOURCE=idna-$(PY-IDNA_VERSION).tar.gz
PY-IDNA_DIR=idna-$(PY-IDNA_VERSION)
PY-IDNA_UNZIP=zcat
PY-IDNA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-IDNA_DESCRIPTION=A library to support the Internationalised Domain Names in Applications (IDNA) protocol as specified in RFC 5891.
PY-IDNA_SECTION=misc
PY-IDNA_PRIORITY=optional
PY26-IDNA_DEPENDS=python26
PY27-IDNA_DEPENDS=python27
PY3-IDNA_DEPENDS=python3
PY-IDNA_CONFLICTS=

#
# PY-IDNA_IPK_VERSION should be incremented when the ipk changes.
#
PY-IDNA_IPK_VERSION=4

#
# PY-IDNA_CONFFILES should be a list of user-editable files
#PY-IDNA_CONFFILES=$(TARGET_PREFIX)/etc/py-idna.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-idna

#
# PY-IDNA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-IDNA_PATCHES=$(PY-IDNA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-IDNA_CPPFLAGS=
PY-IDNA_LDFLAGS=

#
# PY-IDNA_BUILD_DIR is the directory in which the build is done.
# PY-IDNA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-IDNA_IPK_DIR is the directory in which the ipk is built.
# PY-IDNA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-IDNA_SOURCE_DIR=$(SOURCE_DIR)/py-idna
PY-IDNA_BUILD_DIR=$(BUILD_DIR)/py-idna
PY-IDNA_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-idna

PY26-IDNA_IPK_DIR=$(BUILD_DIR)/py26-idna-$(PY-IDNA_VERSION)-ipk
PY26-IDNA_IPK=$(BUILD_DIR)/py26-idna_$(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-IDNA_IPK_DIR=$(BUILD_DIR)/py27-idna-$(PY-IDNA_VERSION)-ipk
PY27-IDNA_IPK=$(BUILD_DIR)/py27-idna_$(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-IDNA_IPK_DIR=$(BUILD_DIR)/py3-idna-$(PY-IDNA_VERSION)-ipk
PY3-IDNA_IPK=$(BUILD_DIR)/py3-idna_$(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-idna-source py-idna-unpack py-idna py-idna-stage py-idna-ipk py-idna-clean py-idna-dirclean py-idna-check py-idna-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-IDNA_SOURCE):
	$(WGET) -P $(@D) $(PY-IDNA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)


#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-idna-source: $(DL_DIR)/$(PY-IDNA_SOURCE) $(PY-IDNA_PATCHES)

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
$(PY-IDNA_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-IDNA_SOURCE) $(PY-IDNA_PATCHES) make/py-idna.mk
	$(MAKE) py-setuptools-host-stage
	$(MAKE) python26-stage python27-stage
	rm -rf $(BUILD_DIR)/$(PY-IDNA_DIR) $(@D)
	mkdir -p $(@D)/
#	cd $(BUILD_DIR); $(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE)
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IDNA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-IDNA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE)
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IDNA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-IDNA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[install]"; \
		echo "install_scripts = $(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
	    ) >> setup.cfg \
	)
#	cd $(BUILD_DIR); $(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE)
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-IDNA_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-IDNA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-idna-unpack: $(PY-IDNA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-IDNA_BUILD_DIR)/.built: $(PY-IDNA_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/3; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-idna: $(PY-IDNA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-IDNA_BUILD_DIR)/.staged: $(PY-IDNA_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-IDNA_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-IDNA_SOURCE) make/py-idna.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-IDNA_DIR) $(@D)
	$(MAKE) python24-host-stage python25-host-stage python26-host-stage python27-host-stage
	$(MAKE) py-ordereddict-host-stage
	mkdir -p $(@D)/
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/2.6
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/2.7
	$(PY-IDNA_UNZIP) $(DL_DIR)/$(PY-IDNA_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-IDNA_DIR) $(@D)/3
	(cd $(@D)/2.6; $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	(cd $(@D)/2.6; \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	(cd $(@D)/2.7; \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	(cd $(@D)/3; \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-idna-stage: $(PY-IDNA_BUILD_DIR)/.staged

py-idna-host-stage: $(PY-IDNA_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-idna
#
$(PY26-IDNA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-idna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IDNA_PRIORITY)" >>$@
	@echo "Section: $(PY-IDNA_SECTION)" >>$@
	@echo "Version: $(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IDNA_MAINTAINER)" >>$@
	@echo "Source: $(PY-IDNA_SITE)/$(PY-IDNA_SOURCE)" >>$@
	@echo "Description: $(PY-IDNA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-IDNA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IDNA_CONFLICTS)" >>$@

$(PY27-IDNA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-idna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IDNA_PRIORITY)" >>$@
	@echo "Section: $(PY-IDNA_SECTION)" >>$@
	@echo "Version: $(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IDNA_MAINTAINER)" >>$@
	@echo "Source: $(PY-IDNA_SITE)/$(PY-IDNA_SOURCE)" >>$@
	@echo "Description: $(PY-IDNA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-IDNA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IDNA_CONFLICTS)" >>$@

$(PY3-IDNA_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-idna" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-IDNA_PRIORITY)" >>$@
	@echo "Section: $(PY-IDNA_SECTION)" >>$@
	@echo "Version: $(PY-IDNA_VERSION)-$(PY-IDNA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-IDNA_MAINTAINER)" >>$@
	@echo "Source: $(PY-IDNA_SITE)/$(PY-IDNA_SOURCE)" >>$@
	@echo "Description: $(PY-IDNA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-IDNA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-IDNA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/etc/py-idna/...
# Documentation files should be installed in $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/doc/py-idna/...
# Daemon startup scripts should be installed in $(PY-IDNA_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-idna
#
# You may need to patch your application to make it use these locations.
#
$(PY26-IDNA_IPK): $(PY-IDNA_BUILD_DIR)/.built
	$(MAKE) py-idna
	rm -rf $(PY26-IDNA_IPK_DIR) $(BUILD_DIR)/py26-idna_*_$(TARGET_ARCH).ipk
	(cd $(PY-IDNA_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-IDNA_IPK_DIR) --prefix=$(TARGET_PREFIX))
#	rm -f $(PY26-IDNA_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY26-IDNA_IPK_DIR)/CONTROL/control
	echo $(PY-IDNA_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-IDNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-IDNA_IPK_DIR)

$(PY27-IDNA_IPK): $(PY-IDNA_BUILD_DIR)/.built
	$(MAKE) py-idna
	rm -rf $(PY27-IDNA_IPK_DIR) $(BUILD_DIR)/py27-idna_*_$(TARGET_ARCH).ipk
	(cd $(PY-IDNA_BUILD_DIR)/2.7; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.7/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-IDNA_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY27-IDNA_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY27-IDNA_IPK_DIR)/CONTROL/control
	echo $(PY-IDNA_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-IDNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-IDNA_IPK_DIR)

$(PY3-IDNA_IPK): $(PY-IDNA_BUILD_DIR)/.built
	$(MAKE) py-idna
	rm -rf $(PY3-IDNA_IPK_DIR) $(BUILD_DIR)/py3-idna_*_$(TARGET_ARCH).ipk
	(cd $(PY-IDNA_BUILD_DIR)/3; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python$(PYTHON3_VERSION_MAJOR)/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-IDNA_IPK_DIR) --prefix=$(TARGET_PREFIX))
	rm -f $(PY3-IDNA_IPK_DIR)$(TARGET_PREFIX)/bin/easy_install
	$(MAKE) $(PY3-IDNA_IPK_DIR)/CONTROL/control
	echo $(PY-IDNA_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-IDNA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-IDNA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-idna-ipk: $(PY26-IDNA_IPK) $(PY27-IDNA_IPK) $(PY3-IDNA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-idna-clean:
	-$(MAKE) -C $(PY-IDNA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-idna-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-IDNA_DIR) $(BUILD_DIR)/$(PY-IDNA_DIR_OLD) \
	$(PY-IDNA_HOST_BUILD_DIR) $(PY-IDNA_BUILD_DIR) \
	$(PY26-IDNA_IPK_DIR) $(PY26-IDNA_IPK) \
	$(PY27-IDNA_IPK_DIR) $(PY27-IDNA_IPK) \
	$(PY3-IDNA_IPK_DIR) $(PY3-IDNA_IPK) \

#
# Some sanity check for the package.
#
py-idna-check: $(PY26-IDNA_IPK) $(PY27-IDNA_IPK) $(PY3-IDNA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
