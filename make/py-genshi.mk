###########################################################
#
# py-genshi
#
###########################################################

#
# PY-GENSHI_VERSION, PY-GENSHI_SITE and PY-GENSHI_SOURCE define
# the upstream location of the source code for the package.
# PY-GENSHI_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GENSHI_UNZIP is the command used to unzip the source.
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
PY-GENSHI_SITE=http://ftp.edgewall.com/pub/genshi
PY-GENSHI_VERSION=0.5.1
PY-GENSHI_SOURCE=Genshi-$(PY-GENSHI_VERSION).tar.bz2
PY-GENSHI_DIR=Genshi-$(PY-GENSHI_VERSION)
PY-GENSHI_UNZIP=bzcat
PY-GENSHI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GENSHI_DESCRIPTION=A toolkit for stream-based generation of output for the web.
PY-GENSHI_SECTION=web
PY-GENSHI_PRIORITY=optional
PY24-GENSHI_DEPENDS=python24
PY25-GENSHI_DEPENDS=python25
PY26-GENSHI_DEPENDS=python26
PY-GENSHI_CONFLICTS=

#
# PY-GENSHI_IPK_VERSION should be incremented when the ipk changes.
#
PY-GENSHI_IPK_VERSION=2

#
# PY-GENSHI_CONFFILES should be a list of user-editable files
#PY-GENSHI_CONFFILES=/opt/etc/py-genshi.conf /opt/etc/init.d/SXXpy-genshi

#
# PY-GENSHI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-GENSHI_PATCHES=$(PY-GENSHI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GENSHI_CPPFLAGS=
PY-GENSHI_LDFLAGS=

#
# PY-GENSHI_BUILD_DIR is the directory in which the build is done.
# PY-GENSHI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY24-GENSHI_IPK_DIR is the directory in which the ipk is built.
# PY24-GENSHI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GENSHI_BUILD_DIR=$(BUILD_DIR)/py-genshi
PY-GENSHI_SOURCE_DIR=$(SOURCE_DIR)/py-genshi

PY24-GENSHI_IPK_DIR=$(BUILD_DIR)/py24-genshi-$(PY-GENSHI_VERSION)-ipk
PY24-GENSHI_IPK=$(BUILD_DIR)/py24-genshi_$(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-GENSHI_IPK_DIR=$(BUILD_DIR)/py25-genshi-$(PY-GENSHI_VERSION)-ipk
PY25-GENSHI_IPK=$(BUILD_DIR)/py25-genshi_$(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-GENSHI_IPK_DIR=$(BUILD_DIR)/py26-genshi-$(PY-GENSHI_VERSION)-ipk
PY26-GENSHI_IPK=$(BUILD_DIR)/py26-genshi_$(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-genshi-source py-genshi-unpack py-genshi py-genshi-stage py-genshi-ipk py-genshi-clean py-genshi-dirclean py-genshi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GENSHI_SOURCE):
	$(WGET) -P $(@D) $(PY-GENSHI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-genshi-source: $(DL_DIR)/$(PY-GENSHI_SOURCE) $(PY-GENSHI_PATCHES)

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
$(PY-GENSHI_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GENSHI_SOURCE) $(PY-GENSHI_PATCHES) make/py-genshi.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-GENSHI_DIR) $(@D)
	mkdir -p $(@D)
#	2.4
	$(PY-GENSHI_UNZIP) $(DL_DIR)/$(PY-GENSHI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GENSHI_PATCHES)"; \
		then cat $(PY-GENSHI_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GENSHI_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-GENSHI_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
#	2.5
	$(PY-GENSHI_UNZIP) $(DL_DIR)/$(PY-GENSHI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GENSHI_PATCHES)"; \
		then cat $(PY-GENSHI_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GENSHI_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-GENSHI_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
#	2.6
	$(PY-GENSHI_UNZIP) $(DL_DIR)/$(PY-GENSHI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-GENSHI_PATCHES)"; \
		then cat $(PY-GENSHI_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GENSHI_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-GENSHI_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
	    echo "[build_ext]"; \
	    echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	    echo "library-dirs=$(STAGING_LIB_DIR)"; \
	    echo "rpath=/opt/lib"; \
	    echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.6") >> setup.cfg \
	)
	touch $@

py-genshi-unpack: $(PY-GENSHI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GENSHI_BUILD_DIR)/.built: $(PY-GENSHI_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build)
	touch $@

#
# This is the build convenience target.
#
py-genshi: $(PY-GENSHI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GENSHI_BUILD_DIR)/.staged: $(PY-GENSHI_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-GENSHI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-genshi-stage: $(PY-GENSHI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-genshi
#
$(PY24-GENSHI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-genshi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GENSHI_PRIORITY)" >>$@
	@echo "Section: $(PY-GENSHI_SECTION)" >>$@
	@echo "Version: $(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GENSHI_MAINTAINER)" >>$@
	@echo "Source: $(PY-GENSHI_SITE)/$(PY-GENSHI_SOURCE)" >>$@
	@echo "Description: $(PY-GENSHI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-GENSHI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GENSHI_CONFLICTS)" >>$@

$(PY25-GENSHI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-genshi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GENSHI_PRIORITY)" >>$@
	@echo "Section: $(PY-GENSHI_SECTION)" >>$@
	@echo "Version: $(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GENSHI_MAINTAINER)" >>$@
	@echo "Source: $(PY-GENSHI_SITE)/$(PY-GENSHI_SOURCE)" >>$@
	@echo "Description: $(PY-GENSHI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-GENSHI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GENSHI_CONFLICTS)" >>$@

$(PY26-GENSHI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-genshi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GENSHI_PRIORITY)" >>$@
	@echo "Section: $(PY-GENSHI_SECTION)" >>$@
	@echo "Version: $(PY-GENSHI_VERSION)-$(PY-GENSHI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GENSHI_MAINTAINER)" >>$@
	@echo "Source: $(PY-GENSHI_SITE)/$(PY-GENSHI_SOURCE)" >>$@
	@echo "Description: $(PY-GENSHI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-GENSHI_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GENSHI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY24-GENSHI_IPK_DIR)/opt/sbin or $(PY24-GENSHI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY24-GENSHI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY24-GENSHI_IPK_DIR)/opt/etc/py-genshi/...
# Documentation files should be installed in $(PY24-GENSHI_IPK_DIR)/opt/doc/py-genshi/...
# Daemon startup scripts should be installed in $(PY24-GENSHI_IPK_DIR)/opt/etc/init.d/S??py-genshi
#
# You may need to patch your application to make it use these locations.
#
$(PY24-GENSHI_IPK): $(PY-GENSHI_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-genshi_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-GENSHI_IPK_DIR) $(BUILD_DIR)/py24-genshi_*_$(TARGET_ARCH).ipk
	(cd $(PY-GENSHI_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-GENSHI_IPK_DIR) --prefix=/opt)
	(cd $(PY24-GENSHI_IPK_DIR)/opt/lib/python2.4/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY24-GENSHI_IPK_DIR)/CONTROL/control
#	echo $(PY-GENSHI_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-GENSHI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-GENSHI_IPK_DIR)

$(PY25-GENSHI_IPK): $(PY-GENSHI_BUILD_DIR)/.built
	rm -rf $(PY25-GENSHI_IPK_DIR) $(BUILD_DIR)/py25-genshi_*_$(TARGET_ARCH).ipk
	(cd $(PY-GENSHI_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-GENSHI_IPK_DIR) --prefix=/opt)
	(cd $(PY25-GENSHI_IPK_DIR)/opt/lib/python2.5/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY25-GENSHI_IPK_DIR)/CONTROL/control
#	echo $(PY-GENSHI_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-GENSHI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-GENSHI_IPK_DIR)

$(PY26-GENSHI_IPK): $(PY-GENSHI_BUILD_DIR)/.built
	rm -rf $(PY26-GENSHI_IPK_DIR) $(BUILD_DIR)/py26-genshi_*_$(TARGET_ARCH).ipk
	(cd $(PY-GENSHI_BUILD_DIR)/2.6; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-GENSHI_IPK_DIR) --prefix=/opt)
	(cd $(PY26-GENSHI_IPK_DIR)/opt/lib/python2.6/site-packages; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY26-GENSHI_IPK_DIR)/CONTROL/control
#	echo $(PY-GENSHI_CONFFILES) | sed -e 's/ /\n/g' > $(PY26-GENSHI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-GENSHI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-genshi-ipk: $(PY24-GENSHI_IPK) $(PY25-GENSHI_IPK) $(PY26-GENSHI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-genshi-clean:
	-$(MAKE) -C $(PY-GENSHI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-genshi-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GENSHI_DIR) $(PY-GENSHI_BUILD_DIR)
	rm -rf $(PY24-GENSHI_IPK_DIR) $(PY24-GENSHI_IPK)
	rm -rf $(PY25-GENSHI_IPK_DIR) $(PY25-GENSHI_IPK)
	rm -rf $(PY26-GENSHI_IPK_DIR) $(PY26-GENSHI_IPK)

#
# Some sanity check for the package.
#
py-genshi-check: $(PY24-GENSHI_IPK) $(PY25-GENSHI_IPK) $(PY26-GENSHI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
