###########################################################
#
# py-openzwave
#
###########################################################
#
# PY-OPENZWAVE_VERSION, PY-OPENZWAVE_SITE and PY-OPENZWAVE_SOURCE define
# the upstream location of the source code for the package.
# PY-OPENZWAVE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-OPENZWAVE_UNZIP is the command used to unzip the source.
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
PY-OPENZWAVE_URL=https://github.com/OpenZWave/python-openzwave/archive/v$(PY-OPENZWAVE_VERSION).tar.gz
PY-OPENZWAVE_VERSION=0.3.1
PY-OPENZWAVE_SOURCE=python-openzwave-$(PY-OPENZWAVE_VERSION).tar.gz
PY-OPENZWAVE_DIR=python-openzwave-$(PY-OPENZWAVE_VERSION)
PY-OPENZWAVE_UNZIP=zcat
PY-OPENZWAVE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-OPENZWAVE_DESCRIPTION=Python wrapper for openzwave: lib, api and console manager parts
PY-OPENZWAVE_SECTION=misc
PY-OPENZWAVE_PRIORITY=optional
PY27-OPENZWAVE_DEPENDS=python27, libopenzwave, py27-setuptools, py27-six, py27-urwid, py27-dispatcher
PY3-OPENZWAVE_DEPENDS=python3, libopenzwave, py3-setuptools, py3-six, py3-urwid, py3-dispatcher
PY-OPENZWAVE_SUGGESTS=
PY-OPENZWAVE_CONFLICTS=

#
# PY-OPENZWAVE_IPK_VERSION should be incremented when the ipk changes.
#
PY-OPENZWAVE_IPK_VERSION=10

#
# PY-OPENZWAVE_CONFFILES should be a list of user-editable files
#PY-OPENZWAVE_CONFFILES=$(TARGET_PREFIX)/etc/py-openzwave.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-openzwave

#
# PY-OPENZWAVE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-OPENZWAVE_PATCHES=\
$(PY-OPENZWAVE_SOURCE_DIR)/setup-lib.py.patch \
$(PY-OPENZWAVE_SOURCE_DIR)/dispatch.patch \
$(PY-OPENZWAVE_SOURCE_DIR)/no_louie.patch \
$(PY-OPENZWAVE_SOURCE_DIR)/config.location.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-OPENZWAVE_CPPFLAGS=
PY-OPENZWAVE_LDFLAGS=

#
# PY-OPENZWAVE_BUILD_DIR is the directory in which the build is done.
# PY-OPENZWAVE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-OPENZWAVE_IPK_DIR is the directory in which the ipk is built.
# PY-OPENZWAVE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-OPENZWAVE_BUILD_DIR=$(BUILD_DIR)/py-openzwave
PY-OPENZWAVE_SOURCE_DIR=$(SOURCE_DIR)/py-openzwave

PY27-OPENZWAVE_IPK_DIR=$(BUILD_DIR)/py27-openzwave-$(PY-OPENZWAVE_VERSION)-ipk
PY27-OPENZWAVE_IPK=$(BUILD_DIR)/py27-openzwave_$(PY-OPENZWAVE_VERSION)-$(PY-OPENZWAVE_IPK_VERSION)_$(TARGET_ARCH).ipk

PY3-OPENZWAVE_IPK_DIR=$(BUILD_DIR)/py3-openzwave-$(PY-OPENZWAVE_VERSION)-ipk
PY3-OPENZWAVE_IPK=$(BUILD_DIR)/py3-openzwave_$(PY-OPENZWAVE_VERSION)-$(PY-OPENZWAVE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-openzwave-source py-openzwave-unpack py-openzwave py-openzwave-stage py-openzwave-ipk py-openzwave-clean py-openzwave-dirclean py-openzwave-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
# $(PY-OPENZWAVE_URL) holds the link to the source,
# which is saved to $(DL_DIR)/$(PY-OPENZWAVE_SOURCE).
# When adding new package, remember to place sha512sum of the source to
# scripts/checksums/$(PY-OPENZWAVE_SOURCE).sha512
#
$(DL_DIR)/$(PY-OPENZWAVE_SOURCE):
	$(WGET) -O $@ $(PY-OPENZWAVE_URL) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-openzwave-source: $(DL_DIR)/$(PY-OPENZWAVE_SOURCE) $(PY-OPENZWAVE_PATCHES) \
			$(PY-OPENZWAVE_SOURCE_DIR)/libopenzwave.cpp.tar.xz

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(PY-OPENZWAVE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-OPENZWAVE_SOURCE) \
		$(PY-OPENZWAVE_SOURCE_DIR)/libopenzwave.cpp.tar.xz $(PY-OPENZWAVE_PATCHES) \
									make/py-openzwave.mk
	$(MAKE) python27-host-stage python3-host-stage py-cython-host-stage \
		python27-stage python3-stage libopenzwave-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	cp -af $(STAGING_INCLUDE_DIR)/openzwave $(@D)/
	sed -i -e '253s/.*//' $(@D)/openzwave/value_classes/ValueID.h
	# 2.7
	$(PY-OPENZWAVE_UNZIP) $(DL_DIR)/$(PY-OPENZWAVE_SOURCE) | tar -C $(@D) -xvf -
	if test -n "$(PY-OPENZWAVE_PATCHES)" ; \
		then cat $(PY-OPENZWAVE_PATCHES) | \
		$(PATCH) -d $(@D)/$(PY-OPENZWAVE_DIR) -p1 ; \
	fi
	mv -f $(@D)/$(PY-OPENZWAVE_DIR) $(@D)/2.7
	### A temporary workaround for:
	### ValueError: Cython.Compiler.Scanning.CompileTimeScope has the wrong size, try recompiling. Expected 32, got 40
	tar -xJvf $(PY-OPENZWAVE_SOURCE_DIR)/libopenzwave.cpp.tar.xz -C $(@D)/2.7/src-lib/libopenzwave
	rm -f $(@D)/2.7/src-lib/libopenzwave/libopenzwave.pyx
	sed -i -e 's|src-lib/libopenzwave/libopenzwave.pyx|src-lib/libopenzwave/libopenzwave.cpp|g' $(@D)/2.7/setup-lib.py
	### end of workaround
	(cd $(@D)/2.7; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.7"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
		echo "[build_scripts]"; \
		echo "executable=$(TARGET_PREFIX)/bin/python2.7"; \
		echo "[install]"; \
		echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	mkdir -p $(@D)/2.7/openzwave/cpp
	ln -s ../../../openzwave $(@D)/2.7/openzwave/cpp/src
	# 3
	$(PY-OPENZWAVE_UNZIP) $(DL_DIR)/$(PY-OPENZWAVE_SOURCE) | tar -C $(@D) -xvf -
	if test -n "$(PY-OPENZWAVE_PATCHES)" ; \
	        then cat $(PY-OPENZWAVE_PATCHES) | \
	        $(PATCH) -d $(@D)/$(PY-OPENZWAVE_DIR) -p1 ; \
	fi
	mv -f $(@D)/$(PY-OPENZWAVE_DIR) $(@D)/3
	(cd $(@D)/3; \
	    ( \
	        echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python$(PYTHON3_VERSION_MAJOR)m"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=$(TARGET_PREFIX)/lib"; \
	        echo "[build_scripts]"; \
	        echo "executable=$(TARGET_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR)"; \
	        echo "[install]"; \
	        echo "install_scripts=$(TARGET_PREFIX)/bin"; \
	    ) >> setup.cfg \
	)
	mkdir -p $(@D)/3/openzwave/cpp
	ln -s ../../../openzwave $(@D)/3/openzwave/cpp/src
#
#	mkdir -p $(@D)/{2.7,3}/.git
	mkdir -p $(@D)/3/.git
	touch $@

py-openzwave-unpack: $(PY-OPENZWAVE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-OPENZWAVE_BUILD_DIR)/.built: $(PY-OPENZWAVE_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.7; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup-lib.py build)
	(cd $(@D)/2.7; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup-api.py build)
	(cd $(@D)/2.7; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python2.7 setup-manager.py build)
	(cd $(@D)/3; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-lib.py build)
	(cd $(@D)/3; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-api.py build)
	(cd $(@D)/3; \
        $(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared -pthread' \
	$(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-manager.py build)
	touch $@

#
# This is the build convenience target.
#
py-openzwave: $(PY-OPENZWAVE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-OPENZWAVE_BUILD_DIR)/.staged: $(PY-OPENZWAVE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

py-openzwave-stage: $(PY-OPENZWAVE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-openzwave
#
$(PY27-OPENZWAVE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-openzwave" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-OPENZWAVE_PRIORITY)" >>$@
	@echo "Section: $(PY-OPENZWAVE_SECTION)" >>$@
	@echo "Version: $(PY-OPENZWAVE_VERSION)-$(PY-OPENZWAVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-OPENZWAVE_MAINTAINER)" >>$@
	@echo "Source: $(PY-OPENZWAVE_URL)" >>$@
	@echo "Description: $(PY-OPENZWAVE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-OPENZWAVE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-OPENZWAVE_CONFLICTS)" >>$@

$(PY3-OPENZWAVE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-openzwave" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-OPENZWAVE_PRIORITY)" >>$@
	@echo "Section: $(PY-OPENZWAVE_SECTION)" >>$@
	@echo "Version: $(PY-OPENZWAVE_VERSION)-$(PY-OPENZWAVE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-OPENZWAVE_MAINTAINER)" >>$@
	@echo "Source: $(PY-OPENZWAVE_URL)" >>$@
	@echo "Description: $(PY-OPENZWAVE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY3-OPENZWAVE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-OPENZWAVE_CONFLICTS)" >>$@
#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/py-openzwave/...
# Documentation files should be installed in $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/doc/py-openzwave/...
# Daemon startup scripts should be installed in $(PY-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-openzwave
#
# You may need to patch your application to make it use these locations.
#
$(PY27-OPENZWAVE_IPK): $(PY-OPENZWAVE_BUILD_DIR)/.built
	rm -rf $(PY27-OPENZWAVE_IPK_DIR) $(BUILD_DIR)/py27-openzwave_*_$(TARGET_ARCH).ipk
	(cd $(PY-OPENZWAVE_BUILD_DIR)/2.7; \
	  $(HOST_STAGING_PREFIX)/bin/python2.7 setup-lib.py install --root=$(PY27-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) && \
	  $(HOST_STAGING_PREFIX)/bin/python2.7 setup-api.py install --root=$(PY27-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) && \
	  $(HOST_STAGING_PREFIX)/bin/python2.7 setup-manager.py install --root=$(PY27-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	)
	find $(PY27-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7 -type f -name '*.so' -exec $(STRIP_COMMAND) {} \;
	mv -f $(PY27-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/bin/ozwsh{,-2.7}
	$(MAKE) $(PY27-OPENZWAVE_IPK_DIR)/CONTROL/control
	echo $(PY-OPENZWAVE_CONFFILES) | sed -e 's/ /\n/g' > $(PY27-OPENZWAVE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-OPENZWAVE_IPK_DIR)

$(PY3-OPENZWAVE_IPK): $(PY-OPENZWAVE_BUILD_DIR)/.built
	rm -rf $(PY3-OPENZWAVE_IPK_DIR) $(BUILD_DIR)/py3-openzwave_*_$(TARGET_ARCH).ipk
	(cd $(PY-OPENZWAVE_BUILD_DIR)/3; \
	  $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-lib.py install --root=$(PY3-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) && \
	  $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-api.py install --root=$(PY3-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) && \
	  $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup-manager.py install --root=$(PY3-OPENZWAVE_IPK_DIR) --prefix=$(TARGET_PREFIX) \
	)
	find $(PY3-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR) -type f -name '*.so' -exec $(STRIP_COMMAND) {} \;
	mv -f $(PY3-OPENZWAVE_IPK_DIR)$(TARGET_PREFIX)/bin/ozwsh{,-3}
	$(MAKE) $(PY3-OPENZWAVE_IPK_DIR)/CONTROL/control
	echo $(PY-OPENZWAVE_CONFFILES) | sed -e 's/ /\n/g' > $(PY3-OPENZWAVE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY3-OPENZWAVE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-openzwave-ipk: $(PY27-OPENZWAVE_IPK) $(PY3-OPENZWAVE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-openzwave-clean:
	rm -f $(PY-OPENZWAVE_BUILD_DIR)/.built
	-$(MAKE) -C $(PY-OPENZWAVE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-openzwave-dirclean:
	rm -rf  $(PY-OPENZWAVE_BUILD_DIR) \
		$(PY27-OPENZWAVE_IPK_DIR) $(PY27-OPENZWAVE_IPK) \
		$(PY3-OPENZWAVE_IPK_DIR) $(PY3-OPENZWAVE_IPK)
#
#
# Some sanity check for the package.
#
py-openzwave-check: $(PY27-OPENZWAVE_IPK) $(PY3-OPENZWAVE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
