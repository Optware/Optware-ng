###########################################################
#
# py-crypto
#
###########################################################

#
# PY-CRYPTO_VERSION, PY-CRYPTO_SITE and PY-CRYPTO_SOURCE define
# the upstream location of the source code for the package.
# PY-CRYPTO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CRYPTO_UNZIP is the command used to unzip the source.
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
PY-CRYPTO_SITE=http://www.amk.ca/files/python/crypto
PY-CRYPTO_VERSION=2.0.1
PY-CRYPTO_SOURCE=pycrypto-$(PY-CRYPTO_VERSION).tar.gz
PY-CRYPTO_DIR=pycrypto-$(PY-CRYPTO_VERSION)
PY-CRYPTO_UNZIP=zcat
PY-CRYPTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CRYPTO_DESCRIPTION=Python Cryptography Toolkit.
PY-CRYPTO_SECTION=misc
PY-CRYPTO_PRIORITY=optional
PY-CRYPTO_DEPENDS=python, libgmp
PY-CRYPTO_CONFLICTS=

#
# PY-CRYPTO_IPK_VERSION should be incremented when the ipk changes.
#
PY-CRYPTO_IPK_VERSION=1

#
# PY-CRYPTO_CONFFILES should be a list of user-editable files
#PY-CRYPTO_CONFFILES=/opt/etc/py-crypto.conf /opt/etc/init.d/SXXpy-crypto

#
# PY-CRYPTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CRYPTO_PATCHES=$(PY-CRYPTO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CRYPTO_CPPFLAGS=
PY-CRYPTO_LDFLAGS=

#
# PY-CRYPTO_BUILD_DIR is the directory in which the build is done.
# PY-CRYPTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CRYPTO_IPK_DIR is the directory in which the ipk is built.
# PY-CRYPTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CRYPTO_BUILD_DIR=$(BUILD_DIR)/py-crypto
PY-CRYPTO_SOURCE_DIR=$(SOURCE_DIR)/py-crypto
PY-CRYPTO_IPK_DIR=$(BUILD_DIR)/py-crypto-$(PY-CRYPTO_VERSION)-ipk
PY-CRYPTO_IPK=$(BUILD_DIR)/py-crypto_$(PY-CRYPTO_VERSION)-$(PY-CRYPTO_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CRYPTO_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CRYPTO_SITE)/$(PY-CRYPTO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-crypto-source: $(DL_DIR)/$(PY-CRYPTO_SOURCE) $(PY-CRYPTO_PATCHES)

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
$(PY-CRYPTO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CRYPTO_SOURCE) $(PY-CRYPTO_PATCHES)
	$(MAKE) py-setuptools-stage libgmp-stage
	rm -rf $(BUILD_DIR)/$(PY-CRYPTO_DIR) $(PY-CRYPTO_BUILD_DIR)
	$(PY-CRYPTO_UNZIP) $(DL_DIR)/$(PY-CRYPTO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CRYPTO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CRYPTO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CRYPTO_DIR) $(PY-CRYPTO_BUILD_DIR)
	(cd $(PY-CRYPTO_BUILD_DIR); \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg; \
	)
	touch $(PY-CRYPTO_BUILD_DIR)/.configured

py-crypto-unpack: $(PY-CRYPTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CRYPTO_BUILD_DIR)/.built: $(PY-CRYPTO_BUILD_DIR)/.configured
	rm -f $(PY-CRYPTO_BUILD_DIR)/.built
	(cd $(PY-CRYPTO_BUILD_DIR); \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' python2.4 setup.py build; \
	)
	touch $(PY-CRYPTO_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-crypto: $(PY-CRYPTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CRYPTO_BUILD_DIR)/.staged: $(PY-CRYPTO_BUILD_DIR)/.built
	rm -f $(PY-CRYPTO_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-CRYPTO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CRYPTO_BUILD_DIR)/.staged

py-crypto-stage: $(PY-CRYPTO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-crypto
#
$(PY-CRYPTO_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CRYPTO_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-crypto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CRYPTO_PRIORITY)" >>$@
	@echo "Section: $(PY-CRYPTO_SECTION)" >>$@
	@echo "Version: $(PY-CRYPTO_VERSION)-$(PY-CRYPTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CRYPTO_MAINTAINER)" >>$@
	@echo "Source: $(PY-CRYPTO_SITE)/$(PY-CRYPTO_SOURCE)" >>$@
	@echo "Description: $(PY-CRYPTO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CRYPTO_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CRYPTO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CRYPTO_IPK_DIR)/opt/sbin or $(PY-CRYPTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CRYPTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CRYPTO_IPK_DIR)/opt/etc/py-crypto/...
# Documentation files should be installed in $(PY-CRYPTO_IPK_DIR)/opt/doc/py-crypto/...
# Daemon startup scripts should be installed in $(PY-CRYPTO_IPK_DIR)/opt/etc/init.d/S??py-crypto
#
# You may need to patch your application to make it use these locations.
#
$(PY-CRYPTO_IPK): $(PY-CRYPTO_BUILD_DIR)/.built
	rm -rf $(PY-CRYPTO_IPK_DIR) $(BUILD_DIR)/py-crypto_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-CRYPTO_BUILD_DIR) DESTDIR=$(PY-CRYPTO_IPK_DIR) install
	(cd $(PY-CRYPTO_BUILD_DIR); \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	python2.4 -c "import setuptools; execfile('setup.py')" \
		install --root=$(PY-CRYPTO_IPK_DIR) --prefix=/opt)
	$(STRIP_COMMAND) `find $(PY-CRYPTO_IPK_DIR)/opt/lib/ -name '*.so'`
#	install -d $(PY-CRYPTO_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-CRYPTO_SOURCE_DIR)/py-crypto.conf $(PY-CRYPTO_IPK_DIR)/opt/etc/py-crypto.conf
#	install -d $(PY-CRYPTO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-CRYPTO_SOURCE_DIR)/rc.py-crypto $(PY-CRYPTO_IPK_DIR)/opt/etc/init.d/SXXpy-crypto
	$(MAKE) $(PY-CRYPTO_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-CRYPTO_SOURCE_DIR)/postinst $(PY-CRYPTO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-CRYPTO_SOURCE_DIR)/prerm $(PY-CRYPTO_IPK_DIR)/CONTROL/prerm
#	echo $(PY-CRYPTO_CONFFILES) | sed -e 's/ /\n/g' > $(PY-CRYPTO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CRYPTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-crypto-ipk: $(PY-CRYPTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-crypto-clean:
	-$(MAKE) -C $(PY-CRYPTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-crypto-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CRYPTO_DIR) $(PY-CRYPTO_BUILD_DIR) $(PY-CRYPTO_IPK_DIR) $(PY-CRYPTO_IPK)
