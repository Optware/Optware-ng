###########################################################
#
# py-openssl
#
###########################################################

#
# PY-OPENSSL_VERSION, PY-OPENSSL_SITE and PY-OPENSSL_SOURCE define
# the upstream location of the source code for the package.
# PY-OPENSSL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-OPENSSL_UNZIP is the command used to unzip the source.
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
PY-OPENSSL_VERSION=0.10
PY-OPENSSL_SITE=http://pypi.python.org/packages/source/p/pyOpenSSL
PY-OPENSSL_SOURCE=pyOpenSSL-$(PY-OPENSSL_VERSION).tar.gz
PY-OPENSSL_DIR=pyOpenSSL-$(PY-OPENSSL_VERSION)
PY-OPENSSL_UNZIP=zcat
PY-OPENSSL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-OPENSSL_DESCRIPTION=Python wrapper around a small subset of the OpenSSL library.
PY-OPENSSL_SECTION=lib
PY-OPENSSL_PRIORITY=optional
PY25-OPENSSL_DEPENDS=python25, openssl
PY26-OPENSSL_DEPENDS=python26, openssl
PY-OPENSSL_CONFLICTS=

#
# PY-OPENSSL_IPK_VERSION should be incremented when the ipk changes.
#
PY-OPENSSL_IPK_VERSION=1

#
# PY-OPENSSL_CONFFILES should be a list of user-editable files
#PY-OPENSSL_CONFFILES=/opt/etc/py-openssl.conf /opt/etc/init.d/SXXpy-openssl

#
# PY-OPENSSL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-OPENSSL_PATCHES=$(PY-OPENSSL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-OPENSSL_CPPFLAGS=
PY-OPENSSL_LDFLAGS=

#
# PY-OPENSSL_BUILD_DIR is the directory in which the build is done.
# PY-OPENSSL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-OPENSSL_IPK_DIR is the directory in which the ipk is built.
# PY-OPENSSL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-OPENSSL_BUILD_DIR=$(BUILD_DIR)/py-openssl
PY-OPENSSL_SOURCE_DIR=$(SOURCE_DIR)/py-openssl

PY25-OPENSSL_IPK_DIR=$(BUILD_DIR)/py25-openssl-$(PY-OPENSSL_VERSION)-ipk
PY25-OPENSSL_IPK=$(BUILD_DIR)/py25-openssl_$(PY-OPENSSL_VERSION)-$(PY-OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-OPENSSL_IPK_DIR=$(BUILD_DIR)/py26-openssl-$(PY-OPENSSL_VERSION)-ipk
PY26-OPENSSL_IPK=$(BUILD_DIR)/py26-openssl_$(PY-OPENSSL_VERSION)-$(PY-OPENSSL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-openssl-source py-openssl-unpack py-openssl py-openssl-stage py-openssl-ipk py-openssl-clean py-openssl-dirclean py-openssl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-OPENSSL_SOURCE):
	$(WGET) -P $(@D) $(PY-OPENSSL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-openssl-source: $(DL_DIR)/$(PY-OPENSSL_SOURCE) $(PY-OPENSSL_PATCHES)

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
$(PY-OPENSSL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-OPENSSL_SOURCE) $(PY-OPENSSL_PATCHES) make/py-openssl.mk
	$(MAKE) openssl-stage py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-OPENSSL_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(PY-OPENSSL_UNZIP) $(DL_DIR)/$(PY-OPENSSL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-OPENSSL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-OPENSSL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-OPENSSL_DIR) $(@D)/2.5
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
	$(PY-OPENSSL_UNZIP) $(DL_DIR)/$(PY-OPENSSL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-OPENSSL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-OPENSSL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-OPENSSL_DIR) $(@D)/2.6
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

py-openssl-unpack: $(PY-OPENSSL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-OPENSSL_BUILD_DIR)/.built: $(PY-OPENSSL_BUILD_DIR)/.configured
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
py-openssl: $(PY-OPENSSL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-OPENSSL_BUILD_DIR)/.staged: $(PY-OPENSSL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-OPENSSL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-openssl-stage: $(PY-OPENSSL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-openssl
#
$(PY25-OPENSSL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-openssl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-OPENSSL_PRIORITY)" >>$@
	@echo "Section: $(PY-OPENSSL_SECTION)" >>$@
	@echo "Version: $(PY-OPENSSL_VERSION)-$(PY-OPENSSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-OPENSSL_MAINTAINER)" >>$@
	@echo "Source: $(PY-OPENSSL_SITE)/$(PY-OPENSSL_SOURCE)" >>$@
	@echo "Description: $(PY-OPENSSL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-OPENSSL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-OPENSSL_CONFLICTS)" >>$@

$(PY26-OPENSSL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-openssl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-OPENSSL_PRIORITY)" >>$@
	@echo "Section: $(PY-OPENSSL_SECTION)" >>$@
	@echo "Version: $(PY-OPENSSL_VERSION)-$(PY-OPENSSL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-OPENSSL_MAINTAINER)" >>$@
	@echo "Source: $(PY-OPENSSL_SITE)/$(PY-OPENSSL_SOURCE)" >>$@
	@echo "Description: $(PY-OPENSSL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-OPENSSL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-OPENSSL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-OPENSSL_IPK_DIR)/opt/sbin or $(PY-OPENSSL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-OPENSSL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-OPENSSL_IPK_DIR)/opt/etc/py-openssl/...
# Documentation files should be installed in $(PY-OPENSSL_IPK_DIR)/opt/doc/py-openssl/...
# Daemon startup scripts should be installed in $(PY-OPENSSL_IPK_DIR)/opt/etc/init.d/S??py-openssl
#
# You may need to patch your application to make it use these locations.
#
$(PY25-OPENSSL_IPK) $(PY26-OPENSSL_IPK): $(PY-OPENSSL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-openssl_*_$(TARGET_ARCH).ipk
	# 2.5
	rm -rf $(PY25-OPENSSL_IPK_DIR) $(BUILD_DIR)/py25-openssl_*_$(TARGET_ARCH).ipk
	(cd $(PY-OPENSSL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-OPENSSL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-OPENSSL_IPK_DIR)/opt/lib/python2.5/site-packages/*/*.so
	$(MAKE) $(PY25-OPENSSL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-OPENSSL_IPK_DIR)
	# 2.6
	rm -rf $(PY26-OPENSSL_IPK_DIR) $(BUILD_DIR)/py26-openssl_*_$(TARGET_ARCH).ipk
	(cd $(PY-OPENSSL_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-OPENSSL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY26-OPENSSL_IPK_DIR)/opt/lib/python2.6/site-packages/*/*.so
	$(MAKE) $(PY26-OPENSSL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-OPENSSL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-openssl-ipk: $(PY25-OPENSSL_IPK) $(PY26-OPENSSL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-openssl-clean:
	-$(MAKE) -C $(PY-OPENSSL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-openssl-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-OPENSSL_DIR) $(PY-OPENSSL_BUILD_DIR)
	rm -rf $(PY25-OPENSSL_IPK_DIR) $(PY25-OPENSSL_IPK)
	rm -rf $(PY26-OPENSSL_IPK_DIR) $(PY26-OPENSSL_IPK)

#
# Some sanity check for the package.
#
py-openssl-check: $(PY25-OPENSSL_IPK) $(PY26-OPENSSL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
