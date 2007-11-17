###########################################################
#
# py-quixote
#
###########################################################

#
# PY-QUIXOTE_VERSION, PY-QUIXOTE_SITE and PY-QUIXOTE_SOURCE define
# the upstream location of the source code for the package.
# PY-QUIXOTE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-QUIXOTE_UNZIP is the command used to unzip the source.
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
PY-QUIXOTE_VERSION=2.5
PY-QUIXOTE_SITE=http://quixote.ca/releases
PY-QUIXOTE_SOURCE=Quixote-$(PY-QUIXOTE_VERSION).tar.gz
PY-QUIXOTE_DIR=Quixote-$(PY-QUIXOTE_VERSION)
PY-QUIXOTE_UNZIP=zcat
PY-QUIXOTE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-QUIXOTE_DESCRIPTION=A highly Pythonic Web application framework.
PY-QUIXOTE_SECTION=web
PY-QUIXOTE_PRIORITY=optional
PY24-QUIXOTE_DEPENDS=python24
PY25-QUIXOTE_DEPENDS=python25
PY-QUIXOTE_CONFLICTS=

#
# PY-QUIXOTE_IPK_VERSION should be incremented when the ipk changes.
#
PY-QUIXOTE_IPK_VERSION=1

#
# PY-QUIXOTE_CONFFILES should be a list of user-editable files
#PY-QUIXOTE_CONFFILES=/opt/etc/py-quixote.conf /opt/etc/init.d/SXXpy-quixote

#
# PY-QUIXOTE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-QUIXOTE_PATCHES=$(PY-QUIXOTE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-QUIXOTE_CPPFLAGS=
PY-QUIXOTE_LDFLAGS=

#
# PY-QUIXOTE_BUILD_DIR is the directory in which the build is done.
# PY-QUIXOTE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-QUIXOTE_IPK_DIR is the directory in which the ipk is built.
# PY-QUIXOTE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-QUIXOTE_BUILD_DIR=$(BUILD_DIR)/py-quixote
PY-QUIXOTE_SOURCE_DIR=$(SOURCE_DIR)/py-quixote

PY24-QUIXOTE_IPK_DIR=$(BUILD_DIR)/py-quixote-$(PY-QUIXOTE_VERSION)-ipk
PY24-QUIXOTE_IPK=$(BUILD_DIR)/py-quixote_$(PY-QUIXOTE_VERSION)-$(PY-QUIXOTE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-QUIXOTE_IPK_DIR=$(BUILD_DIR)/py25-quixote-$(PY-QUIXOTE_VERSION)-ipk
PY25-QUIXOTE_IPK=$(BUILD_DIR)/py25-quixote_$(PY-QUIXOTE_VERSION)-$(PY-QUIXOTE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-quixote-source py-quixote-unpack py-quixote py-quixote-stage py-quixote-ipk py-quixote-clean py-quixote-dirclean py-quixote-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-QUIXOTE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-QUIXOTE_SITE)/$(PY-QUIXOTE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PY-QUIXOTE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-quixote-source: $(DL_DIR)/$(PY-QUIXOTE_SOURCE) $(PY-QUIXOTE_PATCHES)

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
$(PY-QUIXOTE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-QUIXOTE_SOURCE) $(PY-QUIXOTE_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-QUIXOTE_BUILD_DIR)
	mkdir -p $(PY-QUIXOTE_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-QUIXOTE_DIR)
	$(PY-QUIXOTE_UNZIP) $(DL_DIR)/$(PY-QUIXOTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-QUIXOTE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-QUIXOTE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-QUIXOTE_DIR) $(PY-QUIXOTE_BUILD_DIR)/2.4
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-QUIXOTE_DIR)
	$(PY-QUIXOTE_UNZIP) $(DL_DIR)/$(PY-QUIXOTE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-QUIXOTE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-QUIXOTE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-QUIXOTE_DIR) $(PY-QUIXOTE_BUILD_DIR)/2.5
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	)
	touch $@

py-quixote-unpack: $(PY-QUIXOTE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-QUIXOTE_BUILD_DIR)/.built: $(PY-QUIXOTE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-quixote: $(PY-QUIXOTE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-QUIXOTE_BUILD_DIR)/.staged: $(PY-QUIXOTE_BUILD_DIR)/.built
	rm -f $(PY-QUIXOTE_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-QUIXOTE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-QUIXOTE_BUILD_DIR)/.staged

py-quixote-stage: $(PY-QUIXOTE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-quixote
#
$(PY24-QUIXOTE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-quixote" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-QUIXOTE_PRIORITY)" >>$@
	@echo "Section: $(PY-QUIXOTE_SECTION)" >>$@
	@echo "Version: $(PY-QUIXOTE_VERSION)-$(PY-QUIXOTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-QUIXOTE_MAINTAINER)" >>$@
	@echo "Source: $(PY-QUIXOTE_SITE)/$(PY-QUIXOTE_SOURCE)" >>$@
	@echo "Description: $(PY-QUIXOTE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-QUIXOTE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-QUIXOTE_CONFLICTS)" >>$@

$(PY25-QUIXOTE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-quixote" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-QUIXOTE_PRIORITY)" >>$@
	@echo "Section: $(PY-QUIXOTE_SECTION)" >>$@
	@echo "Version: $(PY-QUIXOTE_VERSION)-$(PY-QUIXOTE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-QUIXOTE_MAINTAINER)" >>$@
	@echo "Source: $(PY-QUIXOTE_SITE)/$(PY-QUIXOTE_SOURCE)" >>$@
	@echo "Description: $(PY-QUIXOTE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-QUIXOTE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-QUIXOTE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-QUIXOTE_IPK_DIR)/opt/sbin or $(PY-QUIXOTE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-QUIXOTE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-QUIXOTE_IPK_DIR)/opt/etc/py-quixote/...
# Documentation files should be installed in $(PY-QUIXOTE_IPK_DIR)/opt/doc/py-quixote/...
# Daemon startup scripts should be installed in $(PY-QUIXOTE_IPK_DIR)/opt/etc/init.d/S??py-quixote
#
# You may need to patch your application to make it use these locations.
#
$(PY24-QUIXOTE_IPK): $(PY-QUIXOTE_BUILD_DIR)/.built
	rm -rf $(PY24-QUIXOTE_IPK_DIR) $(BUILD_DIR)/py-quixote_*_$(TARGET_ARCH).ipk
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-QUIXOTE_IPK_DIR) --prefix=/opt; \
	)
	-$(STRIP_COMMAND) `find $(PY24-QUIXOTE_IPK_DIR)/opt/lib/python2.4/site-packages/quixote -name '*.so'`
	$(MAKE) $(PY24-QUIXOTE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-QUIXOTE_IPK_DIR)

$(PY25-QUIXOTE_IPK): $(PY-QUIXOTE_BUILD_DIR)/.built
	rm -rf $(PY25-QUIXOTE_IPK_DIR) $(BUILD_DIR)/py25-quixote_*_$(TARGET_ARCH).ipk
	(cd $(PY-QUIXOTE_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-QUIXOTE_IPK_DIR) --prefix=/opt; \
	)
	-$(STRIP_COMMAND) `find $(PY25-QUIXOTE_IPK_DIR)/opt/lib/python2.5/site-packages/quixote -name '*.so'`
	$(MAKE) $(PY25-QUIXOTE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-QUIXOTE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-quixote-ipk: $(PY24-QUIXOTE_IPK) $(PY25-QUIXOTE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-quixote-clean:
	-$(MAKE) -C $(PY-QUIXOTE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-quixote-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-QUIXOTE_DIR) $(PY-QUIXOTE_BUILD_DIR) $(PY-QUIXOTE_IPK_DIR) $(PY-QUIXOTE_IPK)

#
# Some sanity check for the package.
#
py-quixote-check: $(PY24-QUIXOTE_IPK) $(PY25-QUIXOTE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-QUIXOTE_IPK) $(PY25-QUIXOTE_IPK)
