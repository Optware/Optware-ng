###########################################################
#
# py-yenc
#
###########################################################

#
# PY-YENC_VERSION, PY-YENC_SITE and PY-YENC_SOURCE define
# the upstream location of the source code for the package.
# PY-YENC_DIR is the directory which is created when the source
# archive is unpacked.
# PY-YENC_UNZIP is the command used to unzip the source.
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
PY-YENC_SITE=http://sabnzbd.sourceforge.net
PY-YENC_VERSION=0.3
PY-YENC_SOURCE=yenc-$(PY-YENC_VERSION).tar.gz
PY-YENC_DIR=yenc-$(PY-YENC_VERSION)
PY-YENC_UNZIP=zcat
PY-YENC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-YENC_DESCRIPTION=A module that provides only raw yEnc encoding/decoding with builtin crc32 calculation (C implementation).
PY-YENC_SECTION=misc
PY-YENC_PRIORITY=optional
PY24-YENC_DEPENDS=python24 
PY25-YENC_DEPENDS=python25
PY-YENC_CONFLICTS=

#
# PY-YENC_IPK_VERSION should be incremented when the ipk changes.
#
PY-YENC_IPK_VERSION=1

#
# PY-YENC_CONFFILES should be a list of user-editable files
#PY-YENC_CONFFILES=/opt/etc/py-yenc.conf /opt/etc/init.d/SXXpy-yenc

#
# PY-YENC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-YENC_PATCHES=$(PY-YENC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-YENC_CPPFLAGS=
PY-YENC_LDFLAGS=

#
# PY-YENC_BUILD_DIR is the directory in which the build is done.
# PY-YENC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-YENC_IPK_DIR is the directory in which the ipk is built.
# PY-YENC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-YENC_BUILD_DIR=$(BUILD_DIR)/py-yenc
PY-YENC_SOURCE_DIR=$(SOURCE_DIR)/py-yenc

PY24-YENC_IPK_DIR=$(BUILD_DIR)/py24-yenc-$(PY-YENC_VERSION)-ipk
PY24-YENC_IPK=$(BUILD_DIR)/py24-yenc_$(PY-YENC_VERSION)-$(PY-YENC_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-YENC_IPK_DIR=$(BUILD_DIR)/py25-yenc-$(PY-YENC_VERSION)-ipk
PY25-YENC_IPK=$(BUILD_DIR)/py25-yenc_$(PY-YENC_VERSION)-$(PY-YENC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-yenc-source py-yenc-unpack py-yenc py-yenc-stage py-yenc-ipk py-yenc-clean py-yenc-dirclean py-yenc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-YENC_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-YENC_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-yenc-source: $(DL_DIR)/$(PY-YENC_SOURCE) $(PY-YENC_PATCHES)

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
$(PY-YENC_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-YENC_SOURCE) $(PY-YENC_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-YENC_DIR) $(PY-YENC_BUILD_DIR)
	mkdir -p $(PY-YENC_BUILD_DIR)
	# 2.4
	$(PY-YENC_UNZIP) $(DL_DIR)/$(PY-YENC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-YENC_PATCHES) | patch -d $(BUILD_DIR)/$(PY-YENC_DIR) -p1
	mv $(BUILD_DIR)/$(PY-YENC_DIR) $(PY-YENC_BUILD_DIR)/2.4
	(cd $(PY-YENC_BUILD_DIR)/2.4; \
	    ( \
	        echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
	        echo "[build_scripts]"; \
	        echo "executable=/opt/bin/python2.4"; \
	        echo "[install]"; \
	        echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	# 2.5
	$(PY-YENC_UNZIP) $(DL_DIR)/$(PY-YENC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-YENC_PATCHES) | patch -d $(BUILD_DIR)/$(PY-YENC_DIR) -p1
	mv $(BUILD_DIR)/$(PY-YENC_DIR) $(PY-YENC_BUILD_DIR)/2.5
	(cd $(PY-YENC_BUILD_DIR)/2.5; \
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
	touch $@

py-yenc-unpack: $(PY-YENC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-YENC_BUILD_DIR)/.built: $(PY-YENC_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-YENC_BUILD_DIR)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-YENC_BUILD_DIR)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-yenc: $(PY-YENC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-YENC_BUILD_DIR)/.staged: $(PY-YENC_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-YENC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-yenc-stage: $(PY-YENC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-yenc
#
$(PY24-YENC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-yenc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-YENC_PRIORITY)" >>$@
	@echo "Section: $(PY-YENC_SECTION)" >>$@
	@echo "Version: $(PY-YENC_VERSION)-$(PY-YENC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-YENC_MAINTAINER)" >>$@
	@echo "Source: $(PY-YENC_SITE)/$(PY-YENC_SOURCE)" >>$@
	@echo "Description: $(PY-YENC_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-YENC_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-YENC_CONFLICTS)" >>$@

$(PY25-YENC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-yenc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-YENC_PRIORITY)" >>$@
	@echo "Section: $(PY-YENC_SECTION)" >>$@
	@echo "Version: $(PY-YENC_VERSION)-$(PY-YENC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-YENC_MAINTAINER)" >>$@
	@echo "Source: $(PY-YENC_SITE)/$(PY-YENC_SOURCE)" >>$@
	@echo "Description: $(PY-YENC_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-YENC_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-YENC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-YENC_IPK_DIR)/opt/sbin or $(PY-YENC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-YENC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-YENC_IPK_DIR)/opt/etc/py-yenc/...
# Documentation files should be installed in $(PY-YENC_IPK_DIR)/opt/doc/py-yenc/...
# Daemon startup scripts should be installed in $(PY-YENC_IPK_DIR)/opt/etc/init.d/S??py-yenc
#
# You may need to patch your application to make it use these locations.
#
$(PY24-YENC_IPK): $(PY-YENC_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-yenc_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-YENC_IPK_DIR) $(BUILD_DIR)/py24-yenc_*_$(TARGET_ARCH).ipk
	cd $(PY-YENC_BUILD_DIR)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-YENC_IPK_DIR) --prefix=/opt
	$(STRIP_COMMAND) $(PY24-YENC_IPK_DIR)/opt/lib/python2.4/site-packages/*.so
	$(MAKE) $(PY24-YENC_IPK_DIR)/CONTROL/control
#	echo $(PY-YENC_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-YENC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-YENC_IPK_DIR)

$(PY25-YENC_IPK): $(PY-YENC_BUILD_DIR)/.built
	rm -rf $(PY25-YENC_IPK_DIR) $(BUILD_DIR)/py25-yenc_*_$(TARGET_ARCH).ipk
	cd $(PY-YENC_BUILD_DIR)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-YENC_IPK_DIR) --prefix=/opt
	$(STRIP_COMMAND) $(PY25-YENC_IPK_DIR)/opt/lib/python2.5/site-packages/*.so
	$(MAKE) $(PY25-YENC_IPK_DIR)/CONTROL/control
#	echo $(PY-YENC_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-YENC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-YENC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-yenc-ipk: $(PY24-YENC_IPK) $(PY25-YENC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-yenc-clean:
	-$(MAKE) -C $(PY-YENC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-yenc-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-YENC_DIR) $(PY-YENC_BUILD_DIR)
	rm -rf $(PY24-YENC_IPK_DIR) $(PY24-YENC_IPK)
	rm -rf $(PY25-YENC_IPK_DIR) $(PY25-YENC_IPK)

#
# Some sanity check for the package.
#
py-yenc-check: $(PY24-YENC_IPK) $(PY25-YENC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-YENC_IPK) $(PY25-YENC_IPK)
