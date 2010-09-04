###########################################################
#
# py-lxml
#
###########################################################

#
# PY-LXML_VERSION, PY-LXML_SITE and PY-LXML_SOURCE define
# the upstream location of the source code for the package.
# PY-LXML_DIR is the directory which is created when the source
# archive is unpacked.
# PY-LXML_UNZIP is the command used to unzip the source.
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
PY-LXML_SITE=http://pypi.python.org/packages/source/l/lxml
PY-LXML_VERSION ?= 2.2.8
PY-LXML_IPK_VERSION ?= 1
PY-LXML_SOURCE=lxml-$(PY-LXML_VERSION).tar.gz
PY-LXML_DIR=lxml-$(PY-LXML_VERSION)
PY-LXML_UNZIP=zcat
PY-LXML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-LXML_DESCRIPTION=A Pythonic binding for the libxml2 and libxslt libraries.
PY-LXML_SECTION=misc
PY-LXML_PRIORITY=optional
PY25-LXML_DEPENDS=python25, libxml2, libxslt
PY26-LXML_DEPENDS=python26, libxml2, libxslt
PY-LXML_CONFLICTS=


#
# PY-LXML_CONFFILES should be a list of user-editable files
#PY-LXML_CONFFILES=/opt/etc/py-lxml.conf /opt/etc/init.d/SXXpy-lxml

#
# PY-LXML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-LXML_PATCHES=$(PY-LXML_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-LXML_CPPFLAGS=
PY-LXML_LDFLAGS=

#
# PY-LXML_BUILD_DIR is the directory in which the build is done.
# PY-LXML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-LXML_IPK_DIR is the directory in which the ipk is built.
# PY-LXML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-LXML_BUILD_DIR=$(BUILD_DIR)/py-lxml
PY-LXML_SOURCE_DIR=$(SOURCE_DIR)/py-lxml

PY25-LXML_IPK_DIR=$(BUILD_DIR)/py25-lxml-$(PY-LXML_VERSION)-ipk
PY25-LXML_IPK=$(BUILD_DIR)/py25-lxml_$(PY-LXML_VERSION)-$(PY-LXML_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-LXML_IPK_DIR=$(BUILD_DIR)/py26-lxml-$(PY-LXML_VERSION)-ipk
PY26-LXML_IPK=$(BUILD_DIR)/py26-lxml_$(PY-LXML_VERSION)-$(PY-LXML_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-lxml-source py-lxml-unpack py-lxml py-lxml-stage py-lxml-ipk py-lxml-clean py-lxml-dirclean py-lxml-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-LXML_SOURCE):
	$(WGET) -P $(@D) $(PY-LXML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-lxml-source: $(DL_DIR)/$(PY-LXML_SOURCE) $(PY-LXML_PATCHES)

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
$(PY-LXML_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-LXML_SOURCE) $(PY-LXML_PATCHES) make/py-lxml.mk
	$(MAKE) py-setuptools-stage libxml2-stage libxslt-stage pyrex-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-LXML_DIR)
	$(PY-LXML_UNZIP) $(DL_DIR)/$(PY-LXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-LXML_PATCHES) | patch -d $(BUILD_DIR)/$(PY-LXML_DIR) -p1
	mv $(BUILD_DIR)/$(PY-LXML_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/libxml2:$(STAGING_INCLUDE_DIR)/libxslt:$(STAGING_INCLUDE_DIR)/python2.5"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "libraries=xslt"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg; \
	)
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-LXML_DIR)
	$(PY-LXML_UNZIP) $(DL_DIR)/$(PY-LXML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-LXML_PATCHES) | patch -d $(BUILD_DIR)/$(PY-LXML_DIR) -p1
	mv $(BUILD_DIR)/$(PY-LXML_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    (\
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/libxml2:$(STAGING_INCLUDE_DIR)/libxslt:$(STAGING_INCLUDE_DIR)/python2.6"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "libraries=xslt"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6") >> setup.cfg; \
	)
	touch $@

py-lxml-unpack: $(PY-LXML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-LXML_BUILD_DIR)/.built: $(PY-LXML_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    --with-xslt-config=$(STAGING_PREFIX)/bin/xslt-config; \
	)
	(cd $(@D)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build \
	    --with-xslt-config=$(STAGING_PREFIX)/bin/xslt-config; \
	)
	touch $@

#
# This is the build convenience target.
#
py-lxml: $(PY-LXML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-LXML_BUILD_DIR)/.staged: $(PY-LXML_BUILD_DIR)/.built
#	rm -f $(@D)/.staged
#	$(MAKE) -C $(PY-LXML_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(@D)/.staged
#
#py-lxml-stage: $(PY-LXML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-lxml
#
$(PY25-LXML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-lxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-LXML_PRIORITY)" >>$@
	@echo "Section: $(PY-LXML_SECTION)" >>$@
	@echo "Version: $(PY-LXML_VERSION)-$(PY-LXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-LXML_MAINTAINER)" >>$@
	@echo "Source: $(PY-LXML_SITE)/$(PY-LXML_SOURCE)" >>$@
	@echo "Description: $(PY-LXML_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-LXML_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-LXML_CONFLICTS)" >>$@

$(PY26-LXML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-lxml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-LXML_PRIORITY)" >>$@
	@echo "Section: $(PY-LXML_SECTION)" >>$@
	@echo "Version: $(PY-LXML_VERSION)-$(PY-LXML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-LXML_MAINTAINER)" >>$@
	@echo "Source: $(PY-LXML_SITE)/$(PY-LXML_SOURCE)" >>$@
	@echo "Description: $(PY-LXML_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-LXML_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-LXML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-LXML_IPK_DIR)/opt/sbin or $(PY-LXML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-LXML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-LXML_IPK_DIR)/opt/etc/py-lxml/...
# Documentation files should be installed in $(PY-LXML_IPK_DIR)/opt/doc/py-lxml/...
# Daemon startup scripts should be installed in $(PY-LXML_IPK_DIR)/opt/etc/init.d/S??py-lxml
#
# You may need to patch your application to make it use these locations.
#
$(PY25-LXML_IPK): $(PY-LXML_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-lxml_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-LXML_IPK_DIR) $(BUILD_DIR)/py25-lxml_*_$(TARGET_ARCH).ipk
	(cd $(PY-LXML_BUILD_DIR)/2.5; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py \
		install --root=$(PY25-LXML_IPK_DIR) --prefix=/opt \
		--with-xslt-config=$(STAGING_PREFIX)/bin/xslt-config)
	$(STRIP_COMMAND) `find $(PY25-LXML_IPK_DIR)/opt/lib/ -name '*.so'`
	$(MAKE) $(PY25-LXML_IPK_DIR)/CONTROL/control
#	echo $(PY-LXML_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-LXML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-LXML_IPK_DIR)

$(PY26-LXML_IPK): $(PY-LXML_BUILD_DIR)/.built
	rm -rf $(PY26-LXML_IPK_DIR) $(BUILD_DIR)/py26-lxml_*_$(TARGET_ARCH).ipk
	(cd $(PY-LXML_BUILD_DIR)/2.6; \
		PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
		CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
		$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py \
		install --root=$(PY26-LXML_IPK_DIR) --prefix=/opt \
		--with-xslt-config=$(STAGING_PREFIX)/bin/xslt-config)
	$(STRIP_COMMAND) `find $(PY26-LXML_IPK_DIR)/opt/lib/ -name '*.so'`
	$(MAKE) $(PY26-LXML_IPK_DIR)/CONTROL/control
#	echo $(PY-LXML_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-LXML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-LXML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-lxml-ipk: $(PY25-LXML_IPK) $(PY26-LXML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-lxml-clean:
	-$(MAKE) -C $(PY-LXML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-lxml-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-LXML_DIR) $(PY-LXML_BUILD_DIR)
	rm -rf $(PY25-LXML_IPK_DIR) $(PY25-LXML_IPK)
	rm -rf $(PY26-LXML_IPK_DIR) $(PY26-LXML_IPK)

#
# Some sanity check for the package.
#
py-lxml-check: $(PY25-LXML_IPK) $(PY26-LXML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
