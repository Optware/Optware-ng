###########################################################
#
# py-cheetah
#
###########################################################

#
# PY-CHEETAH_VERSION, PY-CHEETAH_SITE and PY-CHEETAH_SOURCE define
# the upstream location of the source code for the package.
# PY-CHEETAH_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CHEETAH_UNZIP is the command used to unzip the source.
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
PY-CHEETAH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/cheetahtemplate
PY-CHEETAH_VERSION=2.0.1
PY-CHEETAH_SOURCE=Cheetah-$(PY-CHEETAH_VERSION).tar.gz
PY-CHEETAH_DIR=Cheetah-$(PY-CHEETAH_VERSION)
PY-CHEETAH_UNZIP=zcat
PY-CHEETAH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CHEETAH_DESCRIPTION=Cheetah - The Python-Powered Template Engine.
PY-CHEETAH_SECTION=misc
PY-CHEETAH_PRIORITY=optional
PY24-CHEETAH_DEPENDS=python24
PY25-CHEETAH_DEPENDS=python25
PY26-CHEETAH_DEPENDS=python26
PY-CHEETAH_CONFLICTS=

#
# PY-CHEETAH_IPK_VERSION should be incremented when the ipk changes.
#
PY-CHEETAH_IPK_VERSION=3

#
# PY-CHEETAH_CONFFILES should be a list of user-editable files
#PY-CHEETAH_CONFFILES=/opt/etc/py-cheetah.conf /opt/etc/init.d/SXXpy-cheetah

#
# PY-CHEETAH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CHEETAH_PATCHES=$(PY-CHEETAH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CHEETAH_CPPFLAGS=
PY-CHEETAH_LDFLAGS=

#
# PY-CHEETAH_BUILD_DIR is the directory in which the build is done.
# PY-CHEETAH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CHEETAH_IPK_DIR is the directory in which the ipk is built.
# PY-CHEETAH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CHEETAH_BUILD_DIR=$(BUILD_DIR)/py-cheetah
PY-CHEETAH_SOURCE_DIR=$(SOURCE_DIR)/py-cheetah

PY24-CHEETAH_IPK_DIR=$(BUILD_DIR)/py24-cheetah-$(PY-CHEETAH_VERSION)-ipk
PY24-CHEETAH_IPK=$(BUILD_DIR)/py24-cheetah_$(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CHEETAH_IPK_DIR=$(BUILD_DIR)/py25-cheetah-$(PY-CHEETAH_VERSION)-ipk
PY25-CHEETAH_IPK=$(BUILD_DIR)/py25-cheetah_$(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-CHEETAH_IPK_DIR=$(BUILD_DIR)/py26-cheetah-$(PY-CHEETAH_VERSION)-ipk
PY26-CHEETAH_IPK=$(BUILD_DIR)/py26-cheetah_$(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CHEETAH_SOURCE):
	$(WGET) -P $(@D) $(PY-CHEETAH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-cheetah-source: $(DL_DIR)/$(PY-CHEETAH_SOURCE) $(PY-CHEETAH_PATCHES)

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
$(PY-CHEETAH_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CHEETAH_SOURCE) $(PY-CHEETAH_PATCHES) make/py-cheetah.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-CHEETAH_DIR) $(PY-CHEETAH_BUILD_DIR)
	mkdir -p $(PY-CHEETAH_BUILD_DIR)
	# 2.4
	$(PY-CHEETAH_UNZIP) $(DL_DIR)/$(PY-CHEETAH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHEETAH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHEETAH_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHEETAH_DIR) $(PY-CHEETAH_BUILD_DIR)/2.4
	(cd $(PY-CHEETAH_BUILD_DIR)/2.4; \
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
	$(PY-CHEETAH_UNZIP) $(DL_DIR)/$(PY-CHEETAH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHEETAH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHEETAH_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHEETAH_DIR) $(PY-CHEETAH_BUILD_DIR)/2.5
	(cd $(PY-CHEETAH_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	# 2.6
	$(PY-CHEETAH_UNZIP) $(DL_DIR)/$(PY-CHEETAH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CHEETAH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CHEETAH_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CHEETAH_DIR) $(PY-CHEETAH_BUILD_DIR)/2.6
	(cd $(PY-CHEETAH_BUILD_DIR)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	touch $@

py-cheetah-unpack: $(PY-CHEETAH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CHEETAH_BUILD_DIR)/.built: $(PY-CHEETAH_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-CHEETAH_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-CHEETAH_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(PY-CHEETAH_BUILD_DIR)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-cheetah: $(PY-CHEETAH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CHEETAH_BUILD_DIR)/.staged: $(PY-CHEETAH_BUILD_DIR)/.built
#	rm -f $@
	#$(MAKE) -C $(PY-CHEETAH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-cheetah-stage: $(PY-CHEETAH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-cheetah
#
$(PY24-CHEETAH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-cheetah" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHEETAH_PRIORITY)" >>$@
	@echo "Section: $(PY-CHEETAH_SECTION)" >>$@
	@echo "Version: $(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHEETAH_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHEETAH_SITE)/$(PY-CHEETAH_SOURCE)" >>$@
	@echo "Description: $(PY-CHEETAH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CHEETAH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHEETAH_CONFLICTS)" >>$@

$(PY25-CHEETAH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-cheetah" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHEETAH_PRIORITY)" >>$@
	@echo "Section: $(PY-CHEETAH_SECTION)" >>$@
	@echo "Version: $(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHEETAH_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHEETAH_SITE)/$(PY-CHEETAH_SOURCE)" >>$@
	@echo "Description: $(PY-CHEETAH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CHEETAH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHEETAH_CONFLICTS)" >>$@

$(PY26-CHEETAH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-cheetah" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CHEETAH_PRIORITY)" >>$@
	@echo "Section: $(PY-CHEETAH_SECTION)" >>$@
	@echo "Version: $(PY-CHEETAH_VERSION)-$(PY-CHEETAH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CHEETAH_MAINTAINER)" >>$@
	@echo "Source: $(PY-CHEETAH_SITE)/$(PY-CHEETAH_SOURCE)" >>$@
	@echo "Description: $(PY-CHEETAH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-CHEETAH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CHEETAH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CHEETAH_IPK_DIR)/opt/sbin or $(PY-CHEETAH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CHEETAH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CHEETAH_IPK_DIR)/opt/etc/py-cheetah/...
# Documentation files should be installed in $(PY-CHEETAH_IPK_DIR)/opt/doc/py-cheetah/...
# Daemon startup scripts should be installed in $(PY-CHEETAH_IPK_DIR)/opt/etc/init.d/S??py-cheetah
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CHEETAH_IPK): $(PY-CHEETAH_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-cheetah_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-CHEETAH_IPK_DIR) $(BUILD_DIR)/py24-cheetah_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHEETAH_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY24-CHEETAH_IPK_DIR) --prefix=/opt; \
	)
	ls $(PY24-CHEETAH_IPK_DIR)/opt/bin/* | xargs -I{} mv {} {}-2.4
	$(STRIP_COMMAND) `find $(PY24-CHEETAH_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY24-CHEETAH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CHEETAH_IPK_DIR)

$(PY25-CHEETAH_IPK): $(PY-CHEETAH_BUILD_DIR)/.built
	rm -rf $(PY25-CHEETAH_IPK_DIR) $(BUILD_DIR)/py25-cheetah_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHEETAH_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY25-CHEETAH_IPK_DIR) --prefix=/opt; \
	)
	# ls $(PY25-CHEETAH_IPK_DIR)/opt/bin/* | xargs -I{} mv {} {}-2.5
	$(STRIP_COMMAND) `find $(PY25-CHEETAH_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-CHEETAH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CHEETAH_IPK_DIR)

$(PY26-CHEETAH_IPK): $(PY-CHEETAH_BUILD_DIR)/.built
	rm -rf $(PY26-CHEETAH_IPK_DIR) $(BUILD_DIR)/py26-cheetah_*_$(TARGET_ARCH).ipk
	(cd $(PY-CHEETAH_BUILD_DIR)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	 PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 -c "import setuptools; execfile('setup.py')" \
	    install --root=$(PY26-CHEETAH_IPK_DIR) --prefix=/opt; \
	)
	ls $(PY26-CHEETAH_IPK_DIR)/opt/bin/* | xargs -I{} mv {} {}-2.6
	$(STRIP_COMMAND) `find $(PY26-CHEETAH_IPK_DIR)/opt/lib/python2.6/site-packages -name '*.so'`
	$(MAKE) $(PY26-CHEETAH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-CHEETAH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-cheetah-ipk: $(PY24-CHEETAH_IPK) $(PY25-CHEETAH_IPK) $(PY26-CHEETAH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-cheetah-clean:
	-$(MAKE) -C $(PY-CHEETAH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-cheetah-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CHEETAH_DIR) $(PY-CHEETAH_BUILD_DIR) \
	$(PY24-CHEETAH_IPK_DIR) $(PY24-CHEETAH_IPK) \
	$(PY25-CHEETAH_IPK_DIR) $(PY25-CHEETAH_IPK) \
	$(PY26-CHEETAH_IPK_DIR) $(PY26-CHEETAH_IPK) \

#
# Some sanity check for the package.
#
py-cheetah-check: $(PY24-CHEETAH_IPK) $(PY25-CHEETAH_IPK) $(PY26-CHEETAH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
