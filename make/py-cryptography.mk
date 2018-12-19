###########################################################
#
# py-cryptography
#
###########################################################

#
# PY-CRYPTOGRAPHY_VERSION, PY-CRYPTOGRAPHY_SITE and PY-CRYPTOGRAPHY_SOURCE define
# the upstream location of the source code for the package.
# PY-CRYPTOGRAPHY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CRYPTOGRAPHY_UNZIP is the command used to unzip the source.
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
PY-CRYPTOGRAPHY_VERSION=1.4
PY-CRYPTOGRAPHY_SITE=https://pypi.python.org/packages/a9/5b/a383b3a778609fe8177bd51307b5ebeee369b353550675353f46cb99c6f0
PY-CRYPTOGRAPHY_SOURCE=cryptography-$(PY-CRYPTOGRAPHY_VERSION).tar.gz
PY-CRYPTOGRAPHY_DIR=cryptography-$(PY-CRYPTOGRAPHY_VERSION)
PY-CRYPTOGRAPHY_UNZIP=zcat
PY-CRYPTOGRAPHY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CRYPTOGRAPHY_DESCRIPTION=Cryptography is a package which provides cryptographic recipes and primitives to Python developers.
PY-CRYPTOGRAPHY_SECTION=lib
PY-CRYPTOGRAPHY_PRIORITY=optional
PY26-CRYPTOGRAPHY_DEPENDS=python26, py26-enum34, py26-six, py26-asn1, py26-cffi, py26-setuptools, py26-idna, py26-ipaddress, openssl
PY27-CRYPTOGRAPHY_DEPENDS=python27, py27-enum34, py27-six, py27-asn1, py27-cffi, py27-setuptools, py27-idna, py27-ipaddress, openssl
PY3-CRYPTOGRAPHY_DEPENDS=python3, py3-six, py3-asn1, py3-setuptools, py3-cffi, py3-idna, openssl
PY-CRYPTOGRAPHY_CONFLICTS=

#
# PY-CRYPTOGRAPHY_IPK_VERSION should be incremented when the ipk changes.
#
PY-CRYPTOGRAPHY_IPK_VERSION=2

#
# PY-CRYPTOGRAPHY_CONFFILES should be a list of user-editable files
#PY-CRYPTOGRAPHY_CONFFILES=$(TARGET_PREFIX)/etc/py-cryptography.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-cryptography

#
# PY-CRYPTOGRAPHY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CRYPTOGRAPHY_PATCHES=$(PY-CRYPTOGRAPHY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CRYPTOGRAPHY_CPPFLAGS=
PY-CRYPTOGRAPHY_LDFLAGS=

#
# PY-CRYPTOGRAPHY_BUILD_DIR is the directory in which the build is done.
# PY-CRYPTOGRAPHY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CRYPTOGRAPHY_IPK_DIR is the directory in which the ipk is built.
# PY-CRYPTOGRAPHY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CRYPTOGRAPHY_BUILD_DIR=$(BUILD_DIR)/py-cryptography
PY-CRYPTOGRAPHY_SOURCE_DIR=$(SOURCE_DIR)/py-cryptography
PY-CRYPTOGRAPHY_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/py-cryptography

PY26-CRYPTOGRAPHY_IPK_DIR=$(BUILD_DIR)/py26-cryptography-$(PY-CRYPTOGRAPHY_VERSION)-ipk
PY26-CRYPTOGRAPHY_IPK=$(BUILD_DIR)/py26-cryptography_$(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CRYPTOGRAPHY_IPK_DIR=$(BUILD_DIR)/py27-cryptography-$(PY-CRYPTOGRAPHY_VERSION)-ipk
PY27-CRYPTOGRAPHY_IPK=$(BUILD_DIR)/py27-cryptography_$(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CRYPTOGRAPHY_IPK_DIR=$(BUILD_DIR)/py3-cryptography-$(PY-CRYPTOGRAPHY_VERSION)-ipk
PY3-CRYPTOGRAPHY_IPK=$(BUILD_DIR)/py3-cryptography_$(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)_$(TARGET_ARCH).ipk



.PHONY: py-cryptography-source py-cryptography-unpack py-cryptography py-cryptography-stage py-cryptography-ipk py-cryptography-clean py-cryptography-dirclean py-cryptography-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE):
	$(WGET) -P $(@D) $(PY-CRYPTOGRAPHY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cryptography-source: $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) $(PY-CRYPTOGRAPHY_PATCHES)

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
$(PY-CRYPTOGRAPHY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) $(PY-CRYPTOGRAPHY_PATCHES) make/py-cryptography.mk
	$(MAKE) openssl-stage py-setuptools-host-stage py-six-host-stage py-enum34-host-stage \
		py-asn1-host-stage py-cffi-host-stage py-idna-host-stage py-ipaddress-host-stage
	rm -rf $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)
	mkdir -p $(@D)
	# 2.6
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CRYPTOGRAPHY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.7
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CRYPTOGRAPHY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	# 3
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CRYPTOGRAPHY_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-cryptography-unpack: $(PY-CRYPTOGRAPHY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CRYPTOGRAPHY_BUILD_DIR)/.built: $(PY-CRYPTOGRAPHY_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-cryptography: $(PY-CRYPTOGRAPHY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CRYPTOGRAPHY_BUILD_DIR)/.staged: $(PY-CRYPTOGRAPHY_BUILD_DIR)/.built
	rm -f $@
	(cd $(@D)/2.6; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/2.7; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	(cd $(@D)/3; \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(STAGING_DIR) --prefix=$(TARGET_PREFIX))
	touch $@

$(PY-CRYPTOGRAPHY_HOST_BUILD_DIR)/.staged: host/.configured $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) make/py-cryptography.mk
	rm -rf $(HOST_BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)
	$(MAKE) openssl-host-stage py-setuptools-host-stage py-six-host-stage py-enum34-host-stage py-asn1-host-stage py-cffi-host-stage
	mkdir -p $(@D)/
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/2.7
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	$(PY-CRYPTOGRAPHY_UNZIP) $(DL_DIR)/$(PY-CRYPTOGRAPHY_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(HOST_STAGING_INCLUDE_DIR):$(HOST_STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(HOST_STAGING_LIB_DIR)"; \
	        echo "rpath=$(HOST_STAGING_LIB_DIR)"; \
	    ) >> setup.cfg; \
	)
	(cd $(@D)/2.6; \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/2.7; \
		$(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	(cd $(@D)/3; \
		$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(HOST_STAGING_DIR) --prefix=/opt)
	touch $@

py-cryptography-stage: $(PY-CRYPTOGRAPHY_BUILD_DIR)/.staged

py-cryptography-host-stage: $(PY-CRYPTOGRAPHY_HOST_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cryptography
#
$(PY26-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-cryptography" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CRYPTOGRAPHY_PRIORITY)" >>$@
	@echo "Section: $(PY-CRYPTOGRAPHY_SECTION)" >>$@
	@echo "Version: $(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CRYPTOGRAPHY_MAINTAINER)" >>$@
	@echo "Source: $(PY-CRYPTOGRAPHY_SITE)/$(PY-CRYPTOGRAPHY_SOURCE)" >>$@
	@echo "Description: $(PY-CRYPTOGRAPHY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CRYPTOGRAPHY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CRYPTOGRAPHY_CONFLICTS)" >>$@

$(PY27-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-cryptography" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CRYPTOGRAPHY_PRIORITY)" >>$@
	@echo "Section: $(PY-CRYPTOGRAPHY_SECTION)" >>$@
	@echo "Version: $(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CRYPTOGRAPHY_MAINTAINER)" >>$@
	@echo "Source: $(PY-CRYPTOGRAPHY_SITE)/$(PY-CRYPTOGRAPHY_SOURCE)" >>$@
	@echo "Description: $(PY-CRYPTOGRAPHY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CRYPTOGRAPHY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CRYPTOGRAPHY_CONFLICTS)" >>$@

$(PY3-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-cryptography" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CRYPTOGRAPHY_PRIORITY)" >>$@
	@echo "Section: $(PY-CRYPTOGRAPHY_SECTION)" >>$@
	@echo "Version: $(PY-CRYPTOGRAPHY_VERSION)-$(PY-CRYPTOGRAPHY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CRYPTOGRAPHY_MAINTAINER)" >>$@
	@echo "Source: $(PY-CRYPTOGRAPHY_SITE)/$(PY-CRYPTOGRAPHY_SOURCE)" >>$@
	@echo "Description: $(PY-CRYPTOGRAPHY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CRYPTOGRAPHY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CRYPTOGRAPHY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/etc/py-cryptography/...
# Documentation files should be installed in $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/doc/py-cryptography/...
# Daemon startup scripts should be installed in $(PY-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-cryptography
#
# You may need to patch your application to make it use these locations.
#
$(PY26-CRYPTOGRAPHY_IPK) $(PY27-CRYPTOGRAPHY_IPK) $(PY3-CRYPTOGRAPHY_IPK): $(PY-CRYPTOGRAPHY_BUILD_DIR)/.built
	# 2.6
	rm -rf $(PY26-CRYPTOGRAPHY_IPK_DIR) $(BUILD_DIR)/py26-cryptography_*_$(TARGET_ARCH).ipk
	(cd $(PY-CRYPTOGRAPHY_BUILD_DIR)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-CRYPTOGRAPHY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY26-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/cryptography/hazmat/bindings/*.so
	$(MAKE) $(PY26-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CRYPTOGRAPHY_IPK_DIR)
	# 2.7
	rm -rf $(PY27-CRYPTOGRAPHY_IPK_DIR) $(BUILD_DIR)/py27-cryptography_*_$(TARGET_ARCH).ipk
	(cd $(PY-CRYPTOGRAPHY_BUILD_DIR)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-CRYPTOGRAPHY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY27-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/cryptography/hazmat/bindings/*.so
	$(MAKE) $(PY27-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CRYPTOGRAPHY_IPK_DIR)
	# 3
	rm -rf $(PY3-CRYPTOGRAPHY_IPK_DIR) $(BUILD_DIR)/py3-cryptography_*_$(TARGET_ARCH).ipk
	(cd $(PY-CRYPTOGRAPHY_BUILD_DIR)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --root=$(PY3-CRYPTOGRAPHY_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	$(STRIP_COMMAND) $(PY3-CRYPTOGRAPHY_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/cryptography/hazmat/bindings/*.so
	$(MAKE) $(PY3-CRYPTOGRAPHY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CRYPTOGRAPHY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cryptography-ipk: $(PY26-CRYPTOGRAPHY_IPK) $(PY27-CRYPTOGRAPHY_IPK) $(PY3-CRYPTOGRAPHY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cryptography-clean:
	-$(MAKE) -C $(PY-CRYPTOGRAPHY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cryptography-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CRYPTOGRAPHY_DIR) $(PY-CRYPTOGRAPHY_BUILD_DIR)
	rm -rf $(PY26-CRYPTOGRAPHY_IPK_DIR) $(PY26-CRYPTOGRAPHY_IPK)
	rm -rf $(PY27-CRYPTOGRAPHY_IPK_DIR) $(PY27-CRYPTOGRAPHY_IPK)
	rm -rf $(PY3-CRYPTOGRAPHY_IPK_DIR) $(PY3-CRYPTOGRAPHY_IPK)

#
# Some sanity check for the package.
#
py-cryptography-check: $(PY26-CRYPTOGRAPHY_IPK) $(PY27-CRYPTOGRAPHY_IPK) $(PY3-CRYPTOGRAPHY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
