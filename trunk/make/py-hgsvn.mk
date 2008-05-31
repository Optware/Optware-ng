###########################################################
#
# py-hgsvn
#
###########################################################

#
# PY-HGSVN_VERSION, PY-HGSVN_SITE and PY-HGSVN_SOURCE define
# the upstream location of the source code for the package.
# PY-HGSVN_DIR is the directory which is created when the source
# archive is unpacked.
# PY-HGSVN_UNZIP is the command used to unzip the source.
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
PY-HGSVN_SITE=http://pypi.python.org/packages/source/h/hgsvn
PY-HGSVN_VERSION=0.1.6
PY-HGSVN_SOURCE=hgsvn-$(PY-HGSVN_VERSION).tar.gz
PY-HGSVN_DIR=hgsvn-$(PY-HGSVN_VERSION)
PY-HGSVN_UNZIP=zcat
PY-HGSVN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-HGSVN_DESCRIPTION=A set of scripts to work locally on Subversion checkouts using Mercurial.
PY-HGSVN_SECTION=misc
PY-HGSVN_PRIORITY=optional
PY-HGSVN_DEPENDS=
PY24-HGSVN_DEPENDS=py24-mercurial, py24-setuptools, svn
PY25-HGSVN_DEPENDS=py25-mercurial, py25-setuptools, svn
PY-HGSVN_CONFLICTS=

#
# PY-HGSVN_IPK_VERSION should be incremented when the ipk changes.
#
PY-HGSVN_IPK_VERSION=2

#
# PY-HGSVN_CONFFILES should be a list of user-editable files
#PY-HGSVN_CONFFILES=/opt/etc/py-hgsvn.conf /opt/etc/init.d/SXXpy-hgsvn

#
# PY-HGSVN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-HGSVN_PATCHES=$(PY-HGSVN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-HGSVN_CPPFLAGS=
PY-HGSVN_LDFLAGS=

#
# PY-HGSVN_BUILD_DIR is the directory in which the build is done.
# PY-HGSVN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-HGSVN_IPK_DIR is the directory in which the ipk is built.
# PY-HGSVN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-HGSVN_BUILD_DIR=$(BUILD_DIR)/py-hgsvn
PY-HGSVN_SOURCE_DIR=$(SOURCE_DIR)/py-hgsvn

PY-HGSVN-COMMON_IPK_DIR=$(BUILD_DIR)/py-hgsvn-common-$(PY-HGSVN_VERSION)-ipk
PY-HGSVN-COMMON_IPK=$(BUILD_DIR)/py-hgsvn-common_$(PY-HGSVN_VERSION)-$(PY-HGSVN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-HGSVN_IPK_DIR=$(BUILD_DIR)/py24-hgsvn-$(PY-HGSVN_VERSION)-ipk
PY24-HGSVN_IPK=$(BUILD_DIR)/py24-hgsvn_$(PY-HGSVN_VERSION)-$(PY-HGSVN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-HGSVN_IPK_DIR=$(BUILD_DIR)/py25-hgsvn-$(PY-HGSVN_VERSION)-ipk
PY25-HGSVN_IPK=$(BUILD_DIR)/py25-hgsvn_$(PY-HGSVN_VERSION)-$(PY-HGSVN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-hgsvn-source py-hgsvn-unpack py-hgsvn py-hgsvn-stage py-hgsvn-ipk py-hgsvn-clean py-hgsvn-dirclean py-hgsvn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-HGSVN_SOURCE):
	$(WGET) -P $(@D) $(PY-HGSVN_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-hgsvn-source: $(DL_DIR)/$(PY-HGSVN_SOURCE) $(PY-HGSVN_PATCHES)

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
$(PY-HGSVN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-HGSVN_SOURCE) $(PY-HGSVN_PATCHES) make/py-hgsvn.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-HGSVN_BUILD_DIR)
	mkdir -p $(PY-HGSVN_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-HGSVN_DIR)
	$(PY-HGSVN_UNZIP) $(DL_DIR)/$(PY-HGSVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGSVN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-HGSVN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGSVN_DIR) $(@D)/2.4
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
	rm -rf $(BUILD_DIR)/$(PY-HGSVN_DIR)
	$(PY-HGSVN_UNZIP) $(DL_DIR)/$(PY-HGSVN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-HGSVN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-HGSVN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-HGSVN_DIR) $(@D)/2.5
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

py-hgsvn-unpack: $(PY-HGSVN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-HGSVN_BUILD_DIR)/.built: $(PY-HGSVN_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build \
	    ; \
	)
	(cd $(@D)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    ; \
	)
	touch $@

#
# This is the build convenience target.
#
py-hgsvn: $(PY-HGSVN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-HGSVN_BUILD_DIR)/.staged: $(PY-HGSVN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-hgsvn-stage: $(PY-HGSVN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-hgsvn
#
$(PY24-HGSVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-hgsvn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGSVN_PRIORITY)" >>$@
	@echo "Section: $(PY-HGSVN_SECTION)" >>$@
	@echo "Version: $(PY-HGSVN_VERSION)-$(PY-HGSVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGSVN_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGSVN_SITE)/$(PY-HGSVN_SOURCE)" >>$@
	@echo "Description: $(PY-HGSVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-HGSVN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGSVN_CONFLICTS)" >>$@

$(PY25-HGSVN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-hgsvn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGSVN_PRIORITY)" >>$@
	@echo "Section: $(PY-HGSVN_SECTION)" >>$@
	@echo "Version: $(PY-HGSVN_VERSION)-$(PY-HGSVN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGSVN_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGSVN_SITE)/$(PY-HGSVN_SOURCE)" >>$@
	@echo "Description: $(PY-HGSVN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-HGSVN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGSVN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-HGSVN_IPK_DIR)/opt/sbin or $(PY-HGSVN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-HGSVN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-HGSVN_IPK_DIR)/opt/etc/py-hgsvn/...
# Documentation files should be installed in $(PY-HGSVN_IPK_DIR)/opt/doc/py-hgsvn/...
# Daemon startup scripts should be installed in $(PY-HGSVN_IPK_DIR)/opt/etc/init.d/S??py-hgsvn
#
# You may need to patch your application to make it use these locations.
#
$(PY24-HGSVN_IPK): $(PY-HGSVN_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-hgsvn_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-HGSVN_IPK_DIR) $(BUILD_DIR)/py24-hgsvn_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGSVN_BUILD_DIR)/2.4; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-HGSVN_IPK_DIR) --prefix=/opt; \
	)
	for f in $(PY24-HGSVN_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-HGSVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-HGSVN_IPK_DIR)

$(PY25-HGSVN_IPK): $(PY-HGSVN_BUILD_DIR)/.built
	rm -rf $(PY25-HGSVN_IPK_DIR) $(BUILD_DIR)/py25-hgsvn_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGSVN_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-HGSVN_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY25-HGSVN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-HGSVN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-hgsvn-ipk: $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-hgsvn-clean:
	-$(MAKE) -C $(PY-HGSVN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-hgsvn-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-HGSVN_DIR) $(PY-HGSVN_BUILD_DIR)
	rm -rf $(PY24-HGSVN_IPK_DIR) $(PY24-HGSVN_IPK)
	rm -rf $(PY25-HGSVN_IPK_DIR) $(PY25-HGSVN_IPK)

#
# Some sanity check for the package.
#
py-hgsvn-check: $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-HGSVN_IPK) $(PY25-HGSVN_IPK)
