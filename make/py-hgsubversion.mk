###########################################################
#
# py-hgsubversion
#
###########################################################

#
# PY-HGSUBVERSION_VERSION, PY-HGSUBVERSION_SITE and PY-HGSUBVERSION_SOURCE define
# the upstream location of the source code for the package.
# PY-HGSUBVERSION_DIR is the directory which is created when the source
# archive is unpacked.
# PY-HGSUBVERSION_UNZIP is the command used to unzip the source.
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
PY-HGSUBVERSION_SITE=http://pypi.python.org/packages/source/h/hgsubversion
PY-HGSUBVERSION_VERSION=1.2
PY-HGSUBVERSION_SOURCE=hgsubversion-$(PY-HGSUBVERSION_VERSION).tar.gz
PY-HGSUBVERSION_DIR=hgsubversion-$(PY-HGSUBVERSION_VERSION)
PY-HGSUBVERSION_UNZIP=zcat
PY-HGSUBVERSION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-HGSUBVERSION_DESCRIPTION=hgsubversion is an extension for Mercurial that allows using Mercurial as a Subversion client.
PY-HGSUBVERSION_SECTION=misc
PY-HGSUBVERSION_PRIORITY=optional
PY-HGSUBVERSION_DEPENDS=
PY25-HGSUBVERSION_DEPENDS=py25-mercurial, svn-py
PY26-HGSUBVERSION_DEPENDS=py26-mercurial, svn-py
PY-HGSUBVERSION_CONFLICTS=

#
# PY-HGSUBVERSION_IPK_VERSION should be incremented when the ipk changes.
#
PY-HGSUBVERSION_IPK_VERSION=1

#
# PY-HGSUBVERSION_CONFFILES should be a list of user-editable files
#PY-HGSUBVERSION_CONFFILES=/opt/etc/py-hgsubversion.conf /opt/etc/init.d/SXXpy-hgsubversion

#
# PY-HGSUBVERSION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-HGSUBVERSION_PATCHES=$(PY-HGSUBVERSION_SOURCE_DIR)/setup-py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-HGSUBVERSION_CPPFLAGS=
PY-HGSUBVERSION_LDFLAGS=

#
# PY-HGSUBVERSION_BUILD_DIR is the directory in which the build is done.
# PY-HGSUBVERSION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-HGSUBVERSION_IPK_DIR is the directory in which the ipk is built.
# PY-HGSUBVERSION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-HGSUBVERSION_BUILD_DIR=$(BUILD_DIR)/py-hgsubversion
PY-HGSUBVERSION_SOURCE_DIR=$(SOURCE_DIR)/py-hgsubversion

#PY-HGSUBVERSION-COMMON_IPK_DIR=$(BUILD_DIR)/py-hgsubversion-common-$(PY-HGSUBVERSION_VERSION)-ipk
#PY-HGSUBVERSION-COMMON_IPK=$(BUILD_DIR)/py-hgsubversion-common_$(PY-HGSUBVERSION_VERSION)-$(PY-HGSUBVERSION_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-HGSUBVERSION_IPK_DIR=$(BUILD_DIR)/py25-hgsubversion-$(PY-HGSUBVERSION_VERSION)-ipk
PY25-HGSUBVERSION_IPK=$(BUILD_DIR)/py25-hgsubversion_$(PY-HGSUBVERSION_VERSION)-$(PY-HGSUBVERSION_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-HGSUBVERSION_IPK_DIR=$(BUILD_DIR)/py26-hgsubversion-$(PY-HGSUBVERSION_VERSION)-ipk
PY26-HGSUBVERSION_IPK=$(BUILD_DIR)/py26-hgsubversion_$(PY-HGSUBVERSION_VERSION)-$(PY-HGSUBVERSION_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-hgsubversion-source py-hgsubversion-unpack py-hgsubversion py-hgsubversion-stage py-hgsubversion-ipk py-hgsubversion-clean py-hgsubversion-dirclean py-hgsubversion-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-HGSUBVERSION_SOURCE):
	$(WGET) -P $(@D) $(PY-HGSUBVERSION_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-hgsubversion-source: $(DL_DIR)/$(PY-HGSUBVERSION_SOURCE) $(PY-HGSUBVERSION_PATCHES)

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
$(PY-HGSUBVERSION_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-HGSUBVERSION_SOURCE) $(PY-HGSUBVERSION_PATCHES) make/py-hgsubversion.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-HGSUBVERSION_BUILD_DIR)
	mkdir -p $(PY-HGSUBVERSION_BUILD_DIR)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR)
	$(PY-HGSUBVERSION_UNZIP) $(DL_DIR)/$(PY-HGSUBVERSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-HGSUBVERSION_PATCHES)"; then \
		cat $(PY-HGSUBVERSION_PATCHES) | patch -d $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR) $(@D)/2.5
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
	# 2.6
	rm -rf $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR)
	$(PY-HGSUBVERSION_UNZIP) $(DL_DIR)/$(PY-HGSUBVERSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-HGSUBVERSION_PATCHES)"; then \
		cat $(PY-HGSUBVERSION_PATCHES) | patch -d $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
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

py-hgsubversion-unpack: $(PY-HGSUBVERSION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-HGSUBVERSION_BUILD_DIR)/.built: $(PY-HGSUBVERSION_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build \
	    ; \
	)
	(cd $(@D)/2.6; \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build \
	    ; \
	)
	touch $@

#
# This is the build convenience target.
#
py-hgsubversion: $(PY-HGSUBVERSION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-HGSUBVERSION_BUILD_DIR)/.staged: $(PY-HGSUBVERSION_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-hgsubversion-stage: $(PY-HGSUBVERSION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-hgsubversion
#
$(PY25-HGSUBVERSION_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-hgsubversion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGSUBVERSION_PRIORITY)" >>$@
	@echo "Section: $(PY-HGSUBVERSION_SECTION)" >>$@
	@echo "Version: $(PY-HGSUBVERSION_VERSION)-$(PY-HGSUBVERSION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGSUBVERSION_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGSUBVERSION_SITE)/$(PY-HGSUBVERSION_SOURCE)" >>$@
	@echo "Description: $(PY-HGSUBVERSION_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-HGSUBVERSION_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGSUBVERSION_CONFLICTS)" >>$@

$(PY26-HGSUBVERSION_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-hgsubversion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-HGSUBVERSION_PRIORITY)" >>$@
	@echo "Section: $(PY-HGSUBVERSION_SECTION)" >>$@
	@echo "Version: $(PY-HGSUBVERSION_VERSION)-$(PY-HGSUBVERSION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-HGSUBVERSION_MAINTAINER)" >>$@
	@echo "Source: $(PY-HGSUBVERSION_SITE)/$(PY-HGSUBVERSION_SOURCE)" >>$@
	@echo "Description: $(PY-HGSUBVERSION_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-HGSUBVERSION_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-HGSUBVERSION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-HGSUBVERSION_IPK_DIR)/opt/sbin or $(PY-HGSUBVERSION_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-HGSUBVERSION_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-HGSUBVERSION_IPK_DIR)/opt/etc/py-hgsubversion/...
# Documentation files should be installed in $(PY-HGSUBVERSION_IPK_DIR)/opt/doc/py-hgsubversion/...
# Daemon startup scripts should be installed in $(PY-HGSUBVERSION_IPK_DIR)/opt/etc/init.d/S??py-hgsubversion
#
# You may need to patch your application to make it use these locations.
#
$(PY25-HGSUBVERSION_IPK): $(PY-HGSUBVERSION_BUILD_DIR)/.built
	rm -f $(BUILD_DIR)/py*-hgsubversion_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-HGSUBVERSION_IPK_DIR) $(BUILD_DIR)/py25-hgsubversion_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGSUBVERSION_BUILD_DIR)/2.5; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-HGSUBVERSION_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY25-HGSUBVERSION_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-HGSUBVERSION_IPK_DIR)

$(PY26-HGSUBVERSION_IPK): $(PY-HGSUBVERSION_BUILD_DIR)/.built
	rm -rf $(PY26-HGSUBVERSION_IPK_DIR) $(BUILD_DIR)/py26-hgsubversion_*_$(TARGET_ARCH).ipk
	(cd $(PY-HGSUBVERSION_BUILD_DIR)/2.6; \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(PY26-HGSUBVERSION_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY26-HGSUBVERSION_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-HGSUBVERSION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-hgsubversion-ipk: $(PY25-HGSUBVERSION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-hgsubversion-clean:
	-$(MAKE) -C $(PY-HGSUBVERSION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-hgsubversion-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-HGSUBVERSION_DIR) $(PY-HGSUBVERSION_BUILD_DIR)
	rm -rf $(PY25-HGSUBVERSION_IPK_DIR) $(PY25-HGSUBVERSION_IPK)
#	rm -rf $(PY26-HGSUBVERSION_IPK_DIR) $(PY26-HGSUBVERSION_IPK)

#
# Some sanity check for the package.
#
py-hgsubversion-check: $(PY25-HGSUBVERSION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
