###########################################################
#
# py-urwid
#
###########################################################

#
# PY-URWID_VERSION, PY-URWID_SITE and PY-URWID_SOURCE define
# the upstream location of the source code for the package.
# PY-URWID_DIR is the directory which is created when the source
# archive is unpacked.
# PY-URWID_UNZIP is the command used to unzip the source.
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
PY-URWID_SITE=http://excess.org/urwid
PY-URWID_VERSION=0.9.8.2
PY-URWID_SOURCE=urwid-$(PY-URWID_VERSION).tar.gz
PY-URWID_DIR=urwid-$(PY-URWID_VERSION)
PY-URWID_UNZIP=zcat
PY-URWID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-URWID_DESCRIPTION=Urwid is a console user interface library in Python.
PY-URWID_SECTION=misc
PY-URWID_PRIORITY=optional
PY-URWID_DEPENDS=
PY24-URWID_DEPENDS=python24
PY25-URWID_DEPENDS=python25
PY-URWID_CONFLICTS=

#
# PY-URWID_IPK_VERSION should be incremented when the ipk changes.
#
PY-URWID_IPK_VERSION=1

#
# PY-URWID_CONFFILES should be a list of user-editable files
#PY-URWID_CONFFILES=/opt/etc/py-urwid.conf /opt/etc/init.d/SXXpy-urwid

#
# PY-URWID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-URWID_PATCHES=$(PY-URWID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-URWID_CPPFLAGS=
PY-URWID_LDFLAGS=

#
# PY-URWID_BUILD_DIR is the directory in which the build is done.
# PY-URWID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-URWID_IPK_DIR is the directory in which the ipk is built.
# PY-URWID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-URWID_BUILD_DIR=$(BUILD_DIR)/py-urwid
PY-URWID_SOURCE_DIR=$(SOURCE_DIR)/py-urwid

PY-URWID-COMMON_IPK_DIR=$(BUILD_DIR)/py-urwid-common-$(PY-URWID_VERSION)-ipk
PY-URWID-COMMON_IPK=$(BUILD_DIR)/py-urwid-common_$(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-URWID_IPK_DIR=$(BUILD_DIR)/py24-urwid-$(PY-URWID_VERSION)-ipk
PY24-URWID_IPK=$(BUILD_DIR)/py24-urwid_$(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-URWID_IPK_DIR=$(BUILD_DIR)/py25-urwid-$(PY-URWID_VERSION)-ipk
PY25-URWID_IPK=$(BUILD_DIR)/py25-urwid_$(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-urwid-source py-urwid-unpack py-urwid py-urwid-stage py-urwid-ipk py-urwid-clean py-urwid-dirclean py-urwid-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-URWID_SOURCE):
	$(WGET) -P $(@D) $(PY-URWID_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-urwid-source: $(DL_DIR)/$(PY-URWID_SOURCE) $(PY-URWID_PATCHES)

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
$(PY-URWID_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-URWID_SOURCE) $(PY-URWID_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-URWID_BUILD_DIR)
	mkdir -p $(PY-URWID_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-URWID_DIR)
	$(PY-URWID_UNZIP) $(DL_DIR)/$(PY-URWID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URWID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-URWID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URWID_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
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
	rm -rf $(BUILD_DIR)/$(PY-URWID_DIR)
	$(PY-URWID_UNZIP) $(DL_DIR)/$(PY-URWID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URWID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-URWID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URWID_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
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

py-urwid-unpack: $(PY-URWID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-URWID_BUILD_DIR)/.built: $(PY-URWID_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build \
	    ; \
	)
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    ; \
	)
	touch $@

#
# This is the build convenience target.
#
py-urwid: $(PY-URWID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-URWID_BUILD_DIR)/.staged: $(PY-URWID_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-urwid-stage: $(PY-URWID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-urwid
#
$(PY-URWID-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-urwid-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URWID_PRIORITY)" >>$@
	@echo "Section: $(PY-URWID_SECTION)" >>$@
	@echo "Version: $(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URWID_MAINTAINER)" >>$@
	@echo "Source: $(PY-URWID_SITE)/$(PY-URWID_SOURCE)" >>$@
	@echo "Description: $(PY-URWID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-URWID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URWID_CONFLICTS)" >>$@

$(PY24-URWID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-urwid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URWID_PRIORITY)" >>$@
	@echo "Section: $(PY-URWID_SECTION)" >>$@
	@echo "Version: $(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URWID_MAINTAINER)" >>$@
	@echo "Source: $(PY-URWID_SITE)/$(PY-URWID_SOURCE)" >>$@
	@echo "Description: $(PY-URWID_DESCRIPTION)" >>$@
	@echo "Depends: py-urwid-common, $(PY24-URWID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URWID_CONFLICTS)" >>$@

$(PY25-URWID_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-urwid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URWID_PRIORITY)" >>$@
	@echo "Section: $(PY-URWID_SECTION)" >>$@
	@echo "Version: $(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URWID_MAINTAINER)" >>$@
	@echo "Source: $(PY-URWID_SITE)/$(PY-URWID_SOURCE)" >>$@
	@echo "Description: $(PY-URWID_DESCRIPTION)" >>$@
	@echo "Depends: py-urwid-common, $(PY25-URWID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URWID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-URWID_IPK_DIR)/opt/sbin or $(PY-URWID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-URWID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-URWID_IPK_DIR)/opt/etc/py-urwid/...
# Documentation files should be installed in $(PY-URWID_IPK_DIR)/opt/doc/py-urwid/...
# Daemon startup scripts should be installed in $(PY-URWID_IPK_DIR)/opt/etc/init.d/S??py-urwid
#
# You may need to patch your application to make it use these locations.
#
$(PY24-URWID_IPK): $(PY-URWID_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-urwid_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-URWID_IPK_DIR) $(BUILD_DIR)/py24-urwid_*_$(TARGET_ARCH).ipk
	(cd $(PY-URWID_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-URWID_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY24-URWID_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY24-URWID_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-URWID_IPK_DIR)

$(PY25-URWID_IPK): $(PY-URWID_BUILD_DIR)/.built
	rm -rf $(PY25-URWID_IPK_DIR) $(BUILD_DIR)/py25-urwid_*_$(TARGET_ARCH).ipk
	(cd $(PY-URWID_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-URWID_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) `find $(PY25-URWID_IPK_DIR)/opt/lib/python2.5/site-packages -name '*.so'`
	$(MAKE) $(PY25-URWID_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-URWID_IPK_DIR)
#
	rm -rf $(PY-URWID-COMMON_IPK_DIR) $(BUILD_DIR)/py-urwid-common_*_$(TARGET_ARCH).ipk
	install -d $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid
	echo "http://excess.org/urwid/" > $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid/url.txt
	install -m 644 $(PY-URWID_BUILD_DIR)/2.5/*.html $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid
	install -d $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid/examples
	install -m 644 $(PY-URWID_BUILD_DIR)/2.5/*.py $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid/examples
	rm -f $(PY-URWID-COMMON_IPK_DIR)/opt/share/doc/py-urwid/examples/setup.py
	$(MAKE) $(PY-URWID-COMMON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-URWID-COMMON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-urwid-ipk: $(PY24-URWID_IPK) $(PY25-URWID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-urwid-clean:
	-$(MAKE) -C $(PY-URWID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-urwid-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-URWID_DIR) $(PY-URWID_BUILD_DIR)
	rm -rf $(PY24-URWID_IPK_DIR) $(PY24-URWID_IPK)
	rm -rf $(PY25-URWID_IPK_DIR) $(PY25-URWID_IPK)

#
# Some sanity check for the package.
#
py-urwid-check: $(PY24-URWID_IPK) $(PY25-URWID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-URWID_IPK) $(PY25-URWID_IPK)
