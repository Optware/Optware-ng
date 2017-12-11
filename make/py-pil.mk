###########################################################
#
# py-pil
#
###########################################################

#
# PY-PIL_VERSION, PY-PIL_SITE and PY-PIL_SOURCE define
# the upstream location of the source code for the package.
# PY-PIL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PIL_UNZIP is the command used to unzip the source.
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
PY-PIL_SITE=http://effbot.org/downloads
PY-PIL_VERSION=1.1.7
PY-PIL_SOURCE=Imaging-$(PY-PIL_VERSION).tar.gz
PY-PIL_DIR=Imaging-$(PY-PIL_VERSION)
PY-PIL_UNZIP=zcat
PY-PIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PIL_DESCRIPTION=The Python Imaging Library (PIL) adds image processing capabilities to your Python interpreter.
PY-PIL_SECTION=misc
PY-PIL_PRIORITY=optional
PY25-PIL_DEPENDS=python25,freetype,libjpeg,zlib
PY26-PIL_DEPENDS=python26,freetype,libjpeg,zlib
PY27-PIL_DEPENDS=python27,freetype,libjpeg,zlib
PY-PIL_CONFLICTS=

#
# PY-PIL_IPK_VERSION should be incremented when the ipk changes.
#
PY-PIL_IPK_VERSION=2

#
# PY-PIL_CONFFILES should be a list of user-editable files
#PY-PIL_CONFFILES=$(TARGET_PREFIX)/etc/py-pil.conf $(TARGET_PREFIX)/etc/init.d/SXXpy-pil

#
# PY-PIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-PIL_PATCHES=$(PY-PIL_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PIL_CPPFLAGS=
PY-PIL_LDFLAGS=

#
# PY-PIL_BUILD_DIR is the directory in which the build is done.
# PY-PIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PIL_IPK_DIR is the directory in which the ipk is built.
# PY-PIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PIL_BUILD_DIR=$(BUILD_DIR)/py-pil
PY-PIL_SOURCE_DIR=$(SOURCE_DIR)/py-pil

PY25-PIL_IPK_DIR=$(BUILD_DIR)/py25-pil-$(PY-PIL_VERSION)-ipk
PY25-PIL_IPK=$(BUILD_DIR)/py25-pil_$(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-PIL_IPK_DIR=$(BUILD_DIR)/py26-pil-$(PY-PIL_VERSION)-ipk
PY26-PIL_IPK=$(BUILD_DIR)/py26-pil_$(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY27-PIL_IPK_DIR=$(BUILD_DIR)/py27-pil-$(PY-PIL_VERSION)-ipk
PY27-PIL_IPK=$(BUILD_DIR)/py27-pil_$(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-pil-source py-pil-unpack py-pil py-pil-stage py-pil-ipk py-pil-clean py-pil-dirclean py-pil-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PIL_SOURCE):
	$(WGET) -P $(@D) $(PY-PIL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-pil-source: $(DL_DIR)/$(PY-PIL_SOURCE) $(PY-PIL_PATCHES)

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
$(PY-PIL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PIL_SOURCE) $(PY-PIL_PATCHES) make/py-pil.mk
	$(MAKE) py-setuptools-stage freetype-stage libjpeg-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(PY-PIL_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(PY-PIL_UNZIP) $(DL_DIR)/$(PY-PIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PIL_PATCHES)"; then \
		cat $(PY-PIL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIL_DIR) -p1; \
	fi
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(BUILD_DIR)/$(PY-PIL_DIR)/setup.py
	mv $(BUILD_DIR)/$(PY-PIL_DIR) $(@D)/2.5
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
	$(PY-PIL_UNZIP) $(DL_DIR)/$(PY-PIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PIL_PATCHES)"; then \
		cat $(PY-PIL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIL_DIR) -p1; \
	fi
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(BUILD_DIR)/$(PY-PIL_DIR)/setup.py
	mv $(BUILD_DIR)/$(PY-PIL_DIR) $(@D)/2.6
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
	$(PY-PIL_UNZIP) $(DL_DIR)/$(PY-PIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PIL_PATCHES)"; then \
		cat $(PY-PIL_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PY-PIL_DIR) -p1; \
	fi
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(BUILD_DIR)/$(PY-PIL_DIR)/setup.py
	mv $(BUILD_DIR)/$(PY-PIL_DIR) $(@D)/2.7
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
	touch $@

py-pil-unpack: $(PY-PIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PIL_BUILD_DIR)/.built: $(PY-PIL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	(cd $(@D)/2.7; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-pil: $(PY-PIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-PIL_BUILD_DIR)/.staged: $(PY-PIL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-pil-stage: $(PY-PIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pil
#
$(PY25-PIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py25-pil" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIL_PRIORITY)" >>$@
	@echo "Section: $(PY-PIL_SECTION)" >>$@
	@echo "Version: $(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIL_SITE)/$(PY-PIL_SOURCE)" >>$@
	@echo "Description: $(PY-PIL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PIL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIL_CONFLICTS)" >>$@

$(PY26-PIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-pil" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIL_PRIORITY)" >>$@
	@echo "Section: $(PY-PIL_SECTION)" >>$@
	@echo "Version: $(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIL_SITE)/$(PY-PIL_SOURCE)" >>$@
	@echo "Description: $(PY-PIL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-PIL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIL_CONFLICTS)" >>$@

$(PY27-PIL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-pil" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIL_PRIORITY)" >>$@
	@echo "Section: $(PY-PIL_SECTION)" >>$@
	@echo "Version: $(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIL_SITE)/$(PY-PIL_SOURCE)" >>$@
	@echo "Description: $(PY-PIL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY27-PIL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/etc/py-pil/...
# Documentation files should be installed in $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/doc/py-pil/...
# Daemon startup scripts should be installed in $(PY-PIL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??py-pil
#
# You may need to patch your application to make it use these locations.
#
$(PY25-PIL_IPK): $(PY-PIL_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py*-pil_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-PIL_IPK_DIR) $(BUILD_DIR)/py25-pil_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIL_BUILD_DIR)/2.5; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-PIL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	for so in `find $(PY25-PIL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.5/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PY25-PIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PIL_IPK_DIR)

$(PY26-PIL_IPK): $(PY-PIL_BUILD_DIR)/.built
	rm -rf $(PY26-PIL_IPK_DIR) $(BUILD_DIR)/py26-pil_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIL_BUILD_DIR)/2.6; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-PIL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	for f in $(PY26-PIL_IPK_DIR)$(TARGET_PREFIX)/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	for so in `find $(PY26-PIL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PY26-PIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-PIL_IPK_DIR)

$(PY27-PIL_IPK): $(PY-PIL_BUILD_DIR)/.built
	rm -rf $(PY27-PIL_IPK_DIR) $(BUILD_DIR)/py27-pil_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIL_BUILD_DIR)/2.7; \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --root=$(PY27-PIL_IPK_DIR) --prefix=$(TARGET_PREFIX); \
	)
	for f in $(PY27-PIL_IPK_DIR)$(TARGET_PREFIX)/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.7|'`; done
	for so in `find $(PY27-PIL_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PY27-PIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY27-PIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pil-ipk: $(PY25-PIL_IPK) $(PY26-PIL_IPK) $(PY27-PIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-pil-clean:
	-$(MAKE) -C $(PY-PIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-pil-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PIL_DIR) $(PY-PIL_BUILD_DIR)
	rm -rf $(PY25-PIL_IPK_DIR) $(PY25-PIL_IPK)
	rm -rf $(PY26-PIL_IPK_DIR) $(PY26-PIL_IPK)
	rm -rf $(PY27-PIL_IPK_DIR) $(PY27-PIL_IPK)

#
# Some sanity check for the package.
#
py-pil-check: $(PY25-PIL_IPK) $(PY26-PIL_IPK) $(PY27-PIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
