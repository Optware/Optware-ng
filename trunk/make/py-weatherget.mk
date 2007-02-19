###########################################################
#
# py-weatherget
#
###########################################################

#
# PY-WEATHERGET_VERSION, PY-WEATHERGET_SITE and PY-WEATHERGET_SOURCE define
# the upstream location of the source code for the package.
# PY-WEATHERGET_DIR is the directory which is created when the source
# archive is unpacked.
# PY-WEATHERGET_UNZIP is the command used to unzip the source.
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
PY-WEATHERGET_VERSION=0.3.2
PY-WEATHERGET_SITE=http://download.berlios.de/weatherget
PY-WEATHERGET_SOURCE=weatherget-$(PY-WEATHERGET_VERSION).tar.bz2
PY-WEATHERGET_DIR=weatherget-$(PY-WEATHERGET_VERSION)
PY-WEATHERGET_UNZIP=bzcat
PY-WEATHERGET_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-WEATHERGET_DESCRIPTION=A command line based weather reporting tool written in python.
PY-WEATHERGET_SECTION=misc
PY-WEATHERGET_PRIORITY=optional
PY24-WEATHERGET_DEPENDS=python24
PY25-WEATHERGET_DEPENDS=python25
PY-WEATHERGET_SUGGESTS=py-weatherget-doc
PY-WEATHERGET_CONFLICTS=

#
# PY-WEATHERGET_IPK_VERSION should be incremented when the ipk changes.
#
PY-WEATHERGET_IPK_VERSION=1

#
# PY-WEATHERGET_CONFFILES should be a list of user-editable files
#PY-WEATHERGET_CONFFILES=/opt/etc/py-weatherget.conf /opt/etc/init.d/SXXpy-weatherget

#
# PY-WEATHERGET_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-WEATHERGET_PATCHES=$(PY-WEATHERGET_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-WEATHERGET_CPPFLAGS=
PY-WEATHERGET_LDFLAGS=

#
# PY-WEATHERGET_BUILD_DIR is the directory in which the build is done.
# PY-WEATHERGET_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-WEATHERGET_IPK_DIR is the directory in which the ipk is built.
# PY-WEATHERGET_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-WEATHERGET_BUILD_DIR=$(BUILD_DIR)/py-weatherget
PY-WEATHERGET_SOURCE_DIR=$(SOURCE_DIR)/py-weatherget

PY24-WEATHERGET_IPK_DIR=$(BUILD_DIR)/py-weatherget-$(PY-WEATHERGET_VERSION)-ipk
PY24-WEATHERGET_IPK=$(BUILD_DIR)/py-weatherget_$(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-WEATHERGET_IPK_DIR=$(BUILD_DIR)/py25-weatherget-$(PY-WEATHERGET_VERSION)-ipk
PY25-WEATHERGET_IPK=$(BUILD_DIR)/py25-weatherget_$(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-WEATHERGET-DOC_IPK_DIR=$(BUILD_DIR)/py-weatherget-doc-$(PY-WEATHERGET_VERSION)-ipk
PY-WEATHERGET-DOC_IPK=$(BUILD_DIR)/py-weatherget-doc_$(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-weatherget-source py-weatherget-unpack py-weatherget py-weatherget-stage py-weatherget-ipk py-weatherget-clean py-weatherget-dirclean py-weatherget-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-WEATHERGET_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-WEATHERGET_SITE)/$(PY-WEATHERGET_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-weatherget-source: $(DL_DIR)/$(PY-WEATHERGET_SOURCE) $(PY-WEATHERGET_PATCHES)

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
$(PY-WEATHERGET_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-WEATHERGET_SOURCE) $(PY-WEATHERGET_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-WEATHERGET_DIR) $(PY-WEATHERGET_BUILD_DIR)
	mkdir -p $(PY-WEATHERGET_BUILD_DIR)
	# 2.4
	$(PY-WEATHERGET_UNZIP) $(DL_DIR)/$(PY-WEATHERGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	sed -i -e 's|/usr/|/opt/|g' $(BUILD_DIR)/$(PY-WEATHERGET_DIR)/setup.py
#	cat $(PY-WEATHERGET_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEATHERGET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-WEATHERGET_DIR) $(PY-WEATHERGET_BUILD_DIR)/2.4
	(cd $(PY-WEATHERGET_BUILD_DIR)/2.4; \
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
	$(PY-WEATHERGET_UNZIP) $(DL_DIR)/$(PY-WEATHERGET_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	sed -i -e 's|/usr/|/opt/|g' $(BUILD_DIR)/$(PY-WEATHERGET_DIR)/setup.py
#	cat $(PY-WEATHERGET_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WEATHERGET_DIR) -p1
	mv $(BUILD_DIR)/$(PY-WEATHERGET_DIR) $(PY-WEATHERGET_BUILD_DIR)/2.5
	(cd $(PY-WEATHERGET_BUILD_DIR)/2.5; \
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

py-weatherget-unpack: $(PY-WEATHERGET_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-WEATHERGET_BUILD_DIR)/.built: $(PY-WEATHERGET_BUILD_DIR)/.configured
	rm -f $@
	cd $(PY-WEATHERGET_BUILD_DIR)/2.4; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(PY-WEATHERGET_BUILD_DIR)/2.5; \
	    $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-weatherget: $(PY-WEATHERGET_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-WEATHERGET_BUILD_DIR)/.staged: $(PY-WEATHERGET_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(PY-WEATHERGET_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

py-weatherget-stage: $(PY-WEATHERGET_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-weatherget
#
$(PY-WEATHERGET-DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-weatherget-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEATHERGET_PRIORITY)" >>$@
	@echo "Section: $(PY-WEATHERGET_SECTION)" >>$@
	@echo "Version: $(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEATHERGET_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEATHERGET_SITE)/$(PY-WEATHERGET_SOURCE)" >>$@
	@echo "Description: $(PY-WEATHERGET_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-WEATHERGET_CONFLICTS)" >>$@

$(PY24-WEATHERGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-weatherget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEATHERGET_PRIORITY)" >>$@
	@echo "Section: $(PY-WEATHERGET_SECTION)" >>$@
	@echo "Version: $(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEATHERGET_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEATHERGET_SITE)/$(PY-WEATHERGET_SOURCE)" >>$@
	@echo "Description: $(PY-WEATHERGET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-WEATHERGET_DEPENDS)" >>$@
	@echo "Suggests: $(PY-WEATHERGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-WEATHERGET_CONFLICTS)" >>$@

$(PY25-WEATHERGET_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-weatherget" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WEATHERGET_PRIORITY)" >>$@
	@echo "Section: $(PY-WEATHERGET_SECTION)" >>$@
	@echo "Version: $(PY-WEATHERGET_VERSION)-$(PY-WEATHERGET_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WEATHERGET_MAINTAINER)" >>$@
	@echo "Source: $(PY-WEATHERGET_SITE)/$(PY-WEATHERGET_SOURCE)" >>$@
	@echo "Description: $(PY-WEATHERGET_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-WEATHERGET_DEPENDS)" >>$@
	@echo "Suggests: $(PY-WEATHERGET_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-WEATHERGET_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-WEATHERGET_IPK_DIR)/opt/sbin or $(PY-WEATHERGET_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-WEATHERGET_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-WEATHERGET_IPK_DIR)/opt/etc/py-weatherget/...
# Documentation files should be installed in $(PY-WEATHERGET_IPK_DIR)/opt/doc/py-weatherget/...
# Daemon startup scripts should be installed in $(PY-WEATHERGET_IPK_DIR)/opt/etc/init.d/S??py-weatherget
#
# You may need to patch your application to make it use these locations.
#
$(PY24-WEATHERGET_IPK) $(PY25-WEATHERGET_IPK) $(PY-WEATHERGET-DOC_IPK): $(PY-WEATHERGET_BUILD_DIR)/.built
	# 2.4
	rm -rf $(PY24-WEATHERGET_IPK_DIR) $(BUILD_DIR)/py-weatherget_*_$(TARGET_ARCH).ipk
	install -d $(PY24-WEATHERGET_IPK_DIR)/opt/lib/python2.4/site-packages
	cd $(PY-WEATHERGET_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-WEATHERGET_IPK_DIR) --prefix=/opt
	rm -rf $(PY24-WEATHERGET_IPK_DIR)/opt/share
	$(MAKE) $(PY24-WEATHERGET_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-WEATHERGET_IPK_DIR)
	# 2.5
	rm -rf $(PY25-WEATHERGET_IPK_DIR) $(BUILD_DIR)/py25-weatherget_*_$(TARGET_ARCH).ipk
	install -d $(PY25-WEATHERGET_IPK_DIR)/opt/lib/python2.5/site-packages
	cd $(PY-WEATHERGET_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-WEATHERGET_IPK_DIR) --prefix=/opt
	for f in $(PY25-WEATHERGET_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.5|'`; done
	install -d $(PY-WEATHERGET-DOC_IPK_DIR)/opt/
	mv $(PY25-WEATHERGET_IPK_DIR)/opt/share $(PY-WEATHERGET-DOC_IPK_DIR)/opt/
	$(MAKE) $(PY25-WEATHERGET_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-WEATHERGET_IPK_DIR)
	$(MAKE) $(PY-WEATHERGET-DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-WEATHERGET-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-weatherget-ipk: $(PY24-WEATHERGET_IPK) $(PY25-WEATHERGET_IPK) $(PY-WEATHERGET-DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-weatherget-clean:
	-$(MAKE) -C $(PY-WEATHERGET_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-weatherget-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-WEATHERGET_DIR) $(PY-WEATHERGET_BUILD_DIR)
	rm -rf $(PY24-WEATHERGET_IPK_DIR) $(PY24-WEATHERGET_IPK)
	rm -rf $(PY25-WEATHERGET_IPK_DIR) $(PY25-WEATHERGET_IPK)
	rm -rf $(PY-WEATHERGET-DOC_IPK_DIR) $(PY-WEATHERGET-DOC_IPK)

#
# Some sanity check for the package.
#
py-weatherget-check: $(PY24-WEATHERGET_IPK) $(PY25-WEATHERGET_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-WEATHERGET_IPK) $(PY25-WEATHERGET_IPK)
