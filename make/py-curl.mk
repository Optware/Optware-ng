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
PY-CURL_VERSION=7.21.5
PY-CURL_VERSION_OLD=7.21.5
PY-CURL_SOURCE=pycurl-$(PY-CURL_VERSION).tar.gz
PY-CURL_SOURCE_OLD=pycurl-$(PY-CURL_VERSION_OLD).tar.gz
PY-CURL_DIR=pycurl-$(PY-CURL_VERSION)
PY-CURL_DIR_OLD=pycurl-$(PY-CURL_VERSION_OLD)
PY-CURL_UNZIP=zcat
PY-CURL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CURL_DESCRIPTION=PycURL is a Python interface to libcurl.
PY-CURL_SECTION=misc
PY-CURL_PRIORITY=optional
PY25-CURL_DEPENDS=python25, libcurl (>=7.19.0), openssl
PY26-CURL_DEPENDS=python26, libcurl (>=7.19.0), openssl
PY27-CURL_DEPENDS=python27, libcurl (>=7.19.0), openssl
PY3-CURL_DEPENDS=python3, libcurl (>=7.19.0), openssl
PY-CURL_CONFLICTS=

#
# PY-CURL_IPK_VERSION should be incremented when the ipk changes.
#
PY-CURL_IPK_VERSION=7

#
# PY-CURL_CONFFILES should be a list of user-editable files
#PY-CURL_CONFFILES=$(TARGET_PREFIX)/etc/py-curl.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-curl

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

PY25-CURL_IPK_DIR=$(BUILD_DIR)/py25-curl-$(PY-CURL_VERSION_OLD)-ipk
PY25-CURL_IPK=$(BUILD_DIR)/py25-curl_$(PY-CURL_VERSION_OLD)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-CURL_IPK_DIR=$(BUILD_DIR)/py26-curl-$(PY-CURL_VERSION)-ipk
PY26-CURL_IPK=$(BUILD_DIR)/py26-curl_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-CURL_IPK_DIR=$(BUILD_DIR)/py27-curl-$(PY-CURL_VERSION)-ipk
PY27-CURL_IPK=$(BUILD_DIR)/py27-curl_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-CURL_IPK_DIR=$(BUILD_DIR)/py3-curl-$(PY-CURL_VERSION)-ipk
PY3-CURL_IPK=$(BUILD_DIR)/py3-curl_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-CURL-DOC_IPK_DIR=$(BUILD_DIR)/py-curl-doc-$(PY-CURL_VERSION)-ipk
PY-CURL-DOC_IPK=$(BUILD_DIR)/py-curl-doc_$(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-curl-source py-curl-unpack py-curl py-curl-stage py-curl-ipk py-curl-clean py-curl-dirclean py-curl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CURL_SOURCE):
	$(WGET) -P $(@D) $(PY-CURL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
ifneq ($(PY-CURL_VERSION),$(PY-CURL_VERSION_OLD))
$(DL_DIR)/$(PY-CURL_SOURCE_OLD):
	$(WGET) -P $(@D) $(PY-OPENSSL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-curl-source: $(DL_DIR)/$(PY-CURL_SOURCE) $(DL_DIR)/$(PY-CURL_SOURCE_OLD) $(PY-CURL_PATCHES)

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
$(PY-CURL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CURL_SOURCE) $(DL_DIR)/$(PY-CURL_SOURCE_OLD) \
								$(PY-CURL_PATCHES) make/py-curl.mk
	$(MAKE) py-setuptools-host-stage openssl-stage libcurl-stage
	rm -rf $(PY-CURL_BUILD_DIR)
	mkdir -p $(PY-CURL_BUILD_DIR)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR_OLD)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE_OLD) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CURL_DIR_OLD) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR_OLD) $(@D)/2.5
	sed -i.orig -e '/--static-libs" % CURL_CONFIG)\.read())/s|.*|"")|' \
		-e 's/, "--static-libs"//' $(@D)/2.5/setup.py
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CURL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR) $(@D)/2.6
	sed -i.orig -e '/--static-libs" % CURL_CONFIG)\.read())/s|.*|"")|' \
		-e 's/, "--static-libs"//' $(@D)/2.6/setup.py
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	# 2.7
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CURL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR) $(@D)/2.7
	sed -i.orig -e '/--static-libs" % CURL_CONFIG)\.read())/s|.*|"")|' \
		-e 's/, "--static-libs"//' $(@D)/2.7/setup.py
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7" \
	    ) >> setup.cfg; \
	)
	# 3
	rm -rf $(BUILD_DIR)/$(PY-CURL_DIR)
	$(PY-CURL_UNZIP) $(DL_DIR)/$(PY-CURL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CURL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-CURL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CURL_DIR) $(@D)/3
	sed -i.orig -e '/--static-libs" % CURL_CONFIG)\.read())/s|.*|"")|' \
		-e 's/, "--static-libs"//' $(@D)/3/setup.py
	(cd $(@D)/3; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)" \
	    ) >> setup.cfg; \
	)
	touch $@

py-curl-unpack: $(PY-CURL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CURL_BUILD_DIR)/.built: $(PY-CURL_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    --with-openssl \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	cd $(@D)/2.6; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build \
	    --with-openssl \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	cd $(@D)/2.7; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build \
	    --with-openssl \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	cd $(@D)/3; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build \
	    --with-openssl \
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
	@$(INSTALL) -d $(@D)
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

$(PY25-CURL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION_OLD)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE_OLD)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

$(PY26-CURL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

$(PY27-CURL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

$(PY3-CURL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-curl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CURL_PRIORITY)" >>$@
	@echo "Section: $(PY-CURL_SECTION)" >>$@
	@echo "Version: $(PY-CURL_VERSION)-$(PY-CURL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CURL_MAINTAINER)" >>$@
	@echo "Source: $(PY-CURL_SITE)/$(PY-CURL_SOURCE)" >>$@
	@echo "Description: $(PY-CURL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-CURL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CURL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/etc/py-curl/...
# Documentation files should be installed in $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/doc/py-curl/...
# Daemon startup scripts should be installed in $(PY-CURL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-curl
#
# You may need to patch your application to make it use these locations.
#
$(PY25-CURL_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY25-CURL_IPK_DIR) $(BUILD_DIR)/py25-curl_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY25-CURL_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY25-CURL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages -name '*.so'`
	rm -rf $(PY25-CURL_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(PY25-CURL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CURL_IPK_DIR)

$(PY26-CURL_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY26-CURL_IPK_DIR) $(BUILD_DIR)/py26-curl_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/2.6; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY26-CURL_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY26-CURL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages -name '*.so'`
	rm -rf $(PY26-CURL_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(PY26-CURL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CURL_IPK_DIR)

$(PY27-CURL_IPK) $(PY-CURL-DOC_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY27-CURL_IPK_DIR) $(BUILD_DIR)/py27-curl_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-CURL-DOC_IPK_DIR) $(BUILD_DIR)/py-curl-doc_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/2.7; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 -c "import setuptools; execfile('setup.py')" install \
	    --root=$(PY27-CURL_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY27-CURL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages -name '*.so'`
	$(MAKE) $(PY27-CURL_IPK_DIR)/CONTROL/control
	$(MAKE) $(PY-CURL-DOC_IPK_DIR)/CONTROL/control
	$(INSTALL) -d $(PY-CURL-DOC_IPK_DIR)$(TARGET_PREFIX)/
	mv $(PY27-CURL_IPK_DIR)$(TARGET_PREFIX)/share $(PY-CURL-DOC_IPK_DIR)$(TARGET_PREFIX)/
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-CURL_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CURL-DOC_IPK_DIR)

$(PY3-CURL_IPK): $(PY-CURL_BUILD_DIR)/.built
	rm -rf $(PY3-CURL_IPK_DIR) $(BUILD_DIR)/py3-curl_*_$(TARGET_ARCH).ipk
	cd $(PY-CURL_BUILD_DIR)/3; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install \
	    --root=$(PY3-CURL_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	    --curl-config=$(STAGING_PREFIX)/bin/curl-config
	$(STRIP_COMMAND) `find $(PY3-CURL_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages -name '*.so'`
	rm -rf $(PY3-CURL_IPK_DIR)$(TARGET_PREFIX)/share
	$(MAKE) $(PY3-CURL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-CURL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-curl-ipk: $(PY25-CURL_IPK) $(PY26-CURL_IPK) $(PY27-CURL_IPK) $(PY3-CURL_IPK) $(PY-CURL-DOC_IPK)

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
	rm -rf $(PY25-CURL_IPK_DIR) $(PY25-CURL_IPK)
	rm -rf $(PY26-CURL_IPK_DIR) $(PY26-CURL_IPK)
	rm -rf $(PY27-CURL_IPK_DIR) $(PY27-CURL_IPK)
	rm -rf $(PY3-CURL_IPK_DIR) $(PY3-CURL_IPK)

#
# Some sanity check for the package.
#
py-curl-check: $(PY25-CURL_IPK) $(PY26-CURL_IPK) $(PY27-CURL_IPK) $(PY3-CURL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
