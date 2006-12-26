###########################################################
#
# py-gd
#
###########################################################

#
# PY-GD_VERSION, PY-GD_SITE and PY-GD_SOURCE define
# the upstream location of the source code for the package.
# PY-GD_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GD_UNZIP is the command used to unzip the source.
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
PY-GD_SITE=http://newcenturycomputers.net/projects/download.cgi
PY-GD_VERSION=0.56
PY-GD_SOURCE=gdmodule-$(PY-GD_VERSION).tar.gz
PY-GD_DIR=gdmodule-$(PY-GD_VERSION)
PY-GD_UNZIP=zcat
PY-GD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GD_DESCRIPTION=GD module is an interface to the GD library.
PY-GD_SECTION=misc
PY-GD_PRIORITY=optional
PY24-GD_DEPENDS=python24, libgd
PY25-GD_DEPENDS=python25, libgd
PY-GD_CONFLICTS=

#
# PY-GD_IPK_VERSION should be incremented when the ipk changes.
#
PY-GD_IPK_VERSION=4

#
# PY-GD_CONFFILES should be a list of user-editable files
#PY-GD_CONFFILES=/opt/etc/py-gd.conf /opt/etc/init.d/SXXpy-gd

#
# PY-GD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-GD_PATCHES=$(PY-GD_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GD_CPPFLAGS=
PY-GD_LDFLAGS=

#
# PY-GD_BUILD_DIR is the directory in which the build is done.
# PY-GD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GD_IPK_DIR is the directory in which the ipk is built.
# PY-GD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GD_BUILD_DIR=$(BUILD_DIR)/py-gd
PY-GD_SOURCE_DIR=$(SOURCE_DIR)/py-gd

PY24-GD_IPK_DIR=$(BUILD_DIR)/py-gd-$(PY-GD_VERSION)-ipk
PY24-GD_IPK=$(BUILD_DIR)/py-gd_$(PY-GD_VERSION)-$(PY-GD_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-GD_IPK_DIR=$(BUILD_DIR)/py25-gd-$(PY-GD_VERSION)-ipk
PY25-GD_IPK=$(BUILD_DIR)/py25-gd_$(PY-GD_VERSION)-$(PY-GD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-gd-source py-gd-unpack py-gd py-gd-stage py-gd-ipk py-gd-clean py-gd-dirclean py-gd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GD_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-GD_SITE)/$(PY-GD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-gd-source: $(DL_DIR)/$(PY-GD_SOURCE) $(PY-GD_PATCHES)

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
$(PY-GD_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GD_SOURCE) $(PY-GD_PATCHES)
	$(MAKE) python-stage libgd-stage
	rm -rf $(PY-GD_BUILD_DIR)
	mkdir -p $(PY-GD_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-GD_DIR)
	$(PY-GD_UNZIP) $(DL_DIR)/$(PY-GD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-GD_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GD_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GD_DIR) $(PY-GD_BUILD_DIR)/2.4
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(PY-GD_BUILD_DIR)/2.4/Setup.py
	(cd $(PY-GD_BUILD_DIR)/2.4; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) > setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-GD_DIR)
	$(PY-GD_UNZIP) $(DL_DIR)/$(PY-GD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-GD_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GD_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GD_DIR) $(PY-GD_BUILD_DIR)/2.5
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(PY-GD_BUILD_DIR)/2.5/Setup.py
	(cd $(PY-GD_BUILD_DIR)/2.5; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.5"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) > setup.cfg; \
	)
	touch $@

py-gd-unpack: $(PY-GD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GD_BUILD_DIR)/.built: $(PY-GD_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-GD_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 Setup.py build; \
	)
	(cd $(PY-GD_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 Setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-gd: $(PY-GD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GD_BUILD_DIR)/.staged: $(PY-GD_BUILD_DIR)/.built
	rm -f $(PY-GD_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-GD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-GD_BUILD_DIR)/.staged

py-gd-stage: $(PY-GD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-gd
#
$(PY24-GD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-gd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GD_PRIORITY)" >>$@
	@echo "Section: $(PY-GD_SECTION)" >>$@
	@echo "Version: $(PY-GD_VERSION)-$(PY-GD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GD_MAINTAINER)" >>$@
	@echo "Source: $(PY-GD_SITE)/$(PY-GD_SOURCE)" >>$@
	@echo "Description: $(PY-GD_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-GD_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GD_CONFLICTS)" >>$@

$(PY25-GD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-gd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GD_PRIORITY)" >>$@
	@echo "Section: $(PY-GD_SECTION)" >>$@
	@echo "Version: $(PY-GD_VERSION)-$(PY-GD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GD_MAINTAINER)" >>$@
	@echo "Source: $(PY-GD_SITE)/$(PY-GD_SOURCE)" >>$@
	@echo "Description: $(PY-GD_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-GD_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GD_IPK_DIR)/opt/sbin or $(PY-GD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-GD_IPK_DIR)/opt/etc/py-gd/...
# Documentation files should be installed in $(PY-GD_IPK_DIR)/opt/doc/py-gd/...
# Daemon startup scripts should be installed in $(PY-GD_IPK_DIR)/opt/etc/init.d/S??py-gd
#
# You may need to patch your application to make it use these locations.
#
$(PY24-GD_IPK): $(PY-GD_BUILD_DIR)/.built
	rm -rf $(PY24-GD_IPK_DIR) $(BUILD_DIR)/py-gd_*_$(TARGET_ARCH).ipk
	(cd $(PY-GD_BUILD_DIR)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 Setup.py install \
	    --root=$(PY24-GD_IPK_DIR) --prefix=/opt; \
	)
	for so in `find $(PY24-GD_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`; \
		do $(STRIP_COMMAND) $$so; done
	$(MAKE) $(PY24-GD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-GD_IPK_DIR)

$(PY25-GD_IPK): $(PY-GD_BUILD_DIR)/.built
	rm -rf $(PY25-GD_IPK_DIR) $(BUILD_DIR)/py25-gd_*_$(TARGET_ARCH).ipk
	(cd $(PY-GD_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 Setup.py install \
	    --root=$(PY25-GD_IPK_DIR) --prefix=/opt; \
	)
	for so in `find $(PY25-GD_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`; \
		do $(STRIP_COMMAND) $$so; done
	$(MAKE) $(PY25-GD_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-GD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-gd-ipk: $(PY24-GD_IPK) $(PY25-GD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-gd-clean:
	-$(MAKE) -C $(PY-GD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-gd-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GD_DIR) $(PY-GD_BUILD_DIR)
	rm -rf $(PY24-GD_IPK_DIR) $(PY24-GD_IPK)
	rm -rf $(PY25-GD_IPK_DIR) $(PY25-GD_IPK)

#
# Some sanity check for the package.
#
py-gd-check: $(PY24-GD_IPK) $(PY25-GD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-GD_IPK) $(PY25-GD_IPK)
