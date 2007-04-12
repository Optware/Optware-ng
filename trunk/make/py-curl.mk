###########################################################
#
# py-curl
#
###########################################################

#
# PY-CURL_VERSION, PY-CURL_SITE and PY-CURL_SOURCE define
# the upstream location of the source code for the package.
# PY-CURL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CURL_UNZIP is the command used to unzip the source.
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
PY-CURL_SITE=http://pycurl.sourceforge.net/download
PY-CURL_VERSION=7.16.1
PY-CURL_SOURCE=pycurl-$(PY-CURL_VERSION).tar.gz
PY-CURL_DIR=pycurl-$(PY-CURL_VERSION)
PY-CURL_UNZIP=zcat
PY-CURL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CURL_DESCRIPTION=PycURL is a Python interface to libcurl.
PY-CURL_SECTION=misc
PY-CURL_PRIORITY=optional
PY24-CURL_DEPENDS=python24, libcurl (>=7.16.1)
PY24-CURL_DEPENDS=python25, libcurl (>=7.16.1)
PY-CURL_CONFLICTS=

#
# PY-CURL_IPK_VERSION should be incremented when the ipk changes.
#
PY-CURL_IPK_VERSION=2

#
# PY-CURL_CONFFILES should be a list of user-editable files
#PY-CURL_CONFFILES=/opt/etc/py-curl.conf /opt/etc/init.d/SXXpy-curl

#
# PY-CURL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CURL_PATCHES=$(PY-CURL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CURL_CPPFLAGS=
PY-CURL_LDFLAGS=

#
# PY-CURL_BUILD_DIR is the directory in which the build is done.
# PY-CURL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CURL_IPK_DIR is the directory in which the ipk is built.
# PY-CURL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CURL_BUILD_DIR=$(BUILD_DIR)/py-curl
PY-CURL_SOURCE_DIR=$(SOURCE_DIR)/py-curl

PY24-CURL_IPK_DIR=$(BUILD_DIR)/py-curl-$(PY-CURL_VERSION)-ipk
PY24-CURL_IPK=$(BUILD_DIR)/py-curl_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CURL_IPK_DIR=$(BUILD_DIR)/py25-curl-$(PY-CURL_VERSION)-ipk
PY25-CURL_IPK=$(BUILD_DIR)/py25-curl_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-CURL-DOC_IPK_DIR=$(BUILD_DIR)/py-curl-doc-$(PY-CURL_VERSION)-ipk
PY-CURL-DOC_IPK=$(BUILD_DIR)/py-curl-doc_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-curl-source py-curl-unpack py-curl py-curl-stage py-curl-ipk py-curl-clean py-curl-dirclean py-curl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CURL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CURL_SITE)/$(PY-CURL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-curl-source: $(DL_DIR)/$(PY-CURL_SOURCE) $(PY-CURL_PATCHES)

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
$(PY-CURL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CURL_SOURCE) $(PY-CURL_PATCHES)
	$(MAKE) py-setuptools-stage libcurl-stage
	rm -rf $(PY-CURL_BUILD_DIR)
	mkdir -p $(PY-CURL_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CURL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR) $(PY-CURL_BUILD_DIR)/2.4
	(cd $(PY-CURL_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CURL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR) $(PY-CURL_BUILD_DIR)/2.5
	(cd $(PY-CURL_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	touch $@

py-curl-unpack: $(PY-CURL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CURL_BUILD_DIR)/.built: $(PY-CURL_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-CURL_BUILD_DIR)/2.4; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	cd $(PY-CURL_BUILD_DIR)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	touch $@

#
# This is the build convenience target.
#
py-curl: $(PY-CURL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CURL_BUILD_DIR)/.staged: $(PY-CURL_BUILD_DIR)/.built
	rm -f $@
	#$(MAKE) -C $(PY-CURL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-curl-stage: $(PY-CURL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-curl
#
$(PY-CURL-DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-curl-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

$(PY24-CURL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

$(PY25-CURL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CURL_IPK_DIR)/opt/sbin or $(PY-CURL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CURL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CURL_IPK_DIR)/opt/etc/py-curl/...
# Documentation files should be installed in $(PY-CURL_IPK_DIR)/opt/doc/py-curl/...
# Daemon startup scripts should be installed in $(PY-CURL_IPK_DIR)/opt/etc/init.d/S??py-curl
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CURL_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY24-CURL_IPK_DIR) $(BUILD_DIR)/py-curl_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/2.4; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY24-CURL_IPK_DIR) --prefix=/opt \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY24-CURL_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	rm -rf $(PY24-CURL_IPK_DIR)/opt/share
	$(MAKE) $(PY24-CURL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CURL_IPK_DIR)

$(PY25-CURL_IPK) $(PY-CURL-DOC_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY25-CURL_IPK_DIR) $(BUILD_DIR)/py25-curl_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY25-CURL_IPK_DIR) --prefix=/opt \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY25-CURL_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-CURL_IPK_DIR)/CONTROL/control
	$(MAKE) $(PY-CURL-DOC_IPK_DIR)/CONTROL/control
	install -d $(PY-CURL-DOC_IPK_DIR)/opt/
	mv $(PY25-CURL_IPK_DIR)/opt/share $(PY-CURL-DOC_IPK_DIR)/opt/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CURL_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CURL-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-curl-ipk: $(PY24-CURL_IPK) $(PY25-CURL_IPK) $(PY-CURL-DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-curl-clean:
	-$(MAKE) -C $(PY-CURL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-curl-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR) $(PY-CURL_BUILD_DIR)
	rm -rf $(PY-CURL-DOC_IPK_DIR) $(PY-CURL-DOC_IPK)
	rm -rf $(PY24-CURL_IPK_DIR) $(PY24-CURL_IPK)
	rm -rf $(PY25-CURL_IPK_DIR) $(PY25-CURL_IPK)

#
# Some sanity check for the package.
#
py-curl-check: $(PY24-CURL_IPK) $(PY25-CURL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-CURL_IPK) $(PY25-CURL_IPK)
