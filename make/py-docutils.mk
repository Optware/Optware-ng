###########################################################
#
# py-docutils
#
###########################################################

#
# PY-DOCUTILS_VERSION, PY-DOCUTILS_SITE and PY-DOCUTILS_SOURCE define
# the upstream location of the source code for the package.
# PY-DOCUTILS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DOCUTILS_UNZIP is the command used to unzip the source.
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
PY-DOCUTILS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/docutils
PY-DOCUTILS_VERSION=0.5
PY-DOCUTILS_SOURCE=docutils-$(PY-DOCUTILS_VERSION).tar.gz
PY-DOCUTILS_DIR=docutils-$(PY-DOCUTILS_VERSION)
PY-DOCUTILS_UNZIP=zcat
PY-DOCUTILS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DOCUTILS_DESCRIPTION=An open-source text processing system for processing plaintext documentation into useful formats.
PY-DOCUTILS_SECTION=misc
PY-DOCUTILS_PRIORITY=optional
PY24-DOCUTILS_DEPENDS=python24
PY25-DOCUTILS_DEPENDS=python25
PY-DOCUTILS_CONFLICTS=

#
# PY-DOCUTILS_IPK_VERSION should be incremented when the ipk changes.
#
PY-DOCUTILS_IPK_VERSION=1

#
# PY-DOCUTILS_CONFFILES should be a list of user-editable files
#PY-DOCUTILS_CONFFILES=/opt/etc/py-docutils.conf /opt/etc/init.d/SXXpy-docutils

#
# PY-DOCUTILS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DOCUTILS_PATCHES=$(PY-DOCUTILS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DOCUTILS_CPPFLAGS=
PY-DOCUTILS_LDFLAGS=

#
# PY-DOCUTILS_BUILD_DIR is the directory in which the build is done.
# PY-DOCUTILS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DOCUTILS_IPK_DIR is the directory in which the ipk is built.
# PY-DOCUTILS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DOCUTILS_BUILD_DIR=$(BUILD_DIR)/py-docutils
PY-DOCUTILS_SOURCE_DIR=$(SOURCE_DIR)/py-docutils

PY24-DOCUTILS_IPK_DIR=$(BUILD_DIR)/py24-docutils-$(PY-DOCUTILS_VERSION)-ipk
PY24-DOCUTILS_IPK=$(BUILD_DIR)/py24-docutils_$(PY-DOCUTILS_VERSION)-$(PY-DOCUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-DOCUTILS_IPK_DIR=$(BUILD_DIR)/py25-docutils-$(PY-DOCUTILS_VERSION)-ipk
PY25-DOCUTILS_IPK=$(BUILD_DIR)/py25-docutils_$(PY-DOCUTILS_VERSION)-$(PY-DOCUTILS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-docutils-source py-docutils-unpack py-docutils py-docutils-stage py-docutils-ipk py-docutils-clean py-docutils-dirclean py-docutils-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DOCUTILS_SOURCE):
	$(WGET) -P $(@D) $(PY-DOCUTILS_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-docutils-source: $(DL_DIR)/$(PY-DOCUTILS_SOURCE) $(PY-DOCUTILS_PATCHES)

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
$(PY-DOCUTILS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DOCUTILS_SOURCE) $(PY-DOCUTILS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-DOCUTILS_DIR)
	$(PY-DOCUTILS_UNZIP) $(DL_DIR)/$(PY-DOCUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DOCUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DOCUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DOCUTILS_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) >> setup.cfg; \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-DOCUTILS_DIR)
	$(PY-DOCUTILS_UNZIP) $(DL_DIR)/$(PY-DOCUTILS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DOCUTILS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DOCUTILS_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DOCUTILS_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	touch $@

py-docutils-unpack: $(PY-DOCUTILS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DOCUTILS_BUILD_DIR)/.built: $(PY-DOCUTILS_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build
	cd $(@D)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build
	touch $@

#
# This is the build convenience target.
#
py-docutils: $(PY-DOCUTILS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-DOCUTILS_BUILD_DIR)/.staged: $(PY-DOCUTILS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-DOCUTILS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-docutils-stage: $(PY-DOCUTILS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-docutils
#
$(PY24-DOCUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-docutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DOCUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-DOCUTILS_SECTION)" >>$@
	@echo "Version: $(PY-DOCUTILS_VERSION)-$(PY-DOCUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DOCUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-DOCUTILS_SITE)/$(PY-DOCUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-DOCUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-DOCUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DOCUTILS_CONFLICTS)" >>$@

$(PY25-DOCUTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-docutils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DOCUTILS_PRIORITY)" >>$@
	@echo "Section: $(PY-DOCUTILS_SECTION)" >>$@
	@echo "Version: $(PY-DOCUTILS_VERSION)-$(PY-DOCUTILS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DOCUTILS_MAINTAINER)" >>$@
	@echo "Source: $(PY-DOCUTILS_SITE)/$(PY-DOCUTILS_SOURCE)" >>$@
	@echo "Description: $(PY-DOCUTILS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DOCUTILS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DOCUTILS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DOCUTILS_IPK_DIR)/opt/sbin or $(PY-DOCUTILS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DOCUTILS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-DOCUTILS_IPK_DIR)/opt/etc/py-docutils/...
# Documentation files should be installed in $(PY-DOCUTILS_IPK_DIR)/opt/doc/py-docutils/...
# Daemon startup scripts should be installed in $(PY-DOCUTILS_IPK_DIR)/opt/etc/init.d/S??py-docutils
#
# You may need to patch your application to make it use these locations.
#
$(PY24-DOCUTILS_IPK): $(PY-DOCUTILS_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-docutils_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-DOCUTILS_IPK_DIR) $(BUILD_DIR)/py24-docutils_*_$(TARGET_ARCH).ipk
	cd $(PY-DOCUTILS_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-DOCUTILS_IPK_DIR) --prefix=/opt
	for f in $(PY24-DOCUTILS_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|\.py|-2.4.py|'`; done
#	$(STRIP_COMMAND) $(PY24-DOCUTILS_IPK_DIR)/opt/lib/python2.4/site-packages/pydocutils2/_docutils.so
	$(MAKE) $(PY24-DOCUTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-DOCUTILS_IPK_DIR)

$(PY25-DOCUTILS_IPK): $(PY-DOCUTILS_BUILD_DIR)/.built
	rm -rf $(PY25-DOCUTILS_IPK_DIR) $(BUILD_DIR)/py25-docutils_*_$(TARGET_ARCH).ipk
	cd $(PY-DOCUTILS_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-DOCUTILS_IPK_DIR) --prefix=/opt
#	$(STRIP_COMMAND) $(PY25-DOCUTILS_IPK_DIR)/opt/lib/python2.5/site-packages/pydocutils2/_docutils.so
	$(MAKE) $(PY25-DOCUTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DOCUTILS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-docutils-ipk: $(PY24-DOCUTILS_IPK) $(PY25-DOCUTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-docutils-clean:
	-$(MAKE) -C $(PY-DOCUTILS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-docutils-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DOCUTILS_DIR) $(PY-DOCUTILS_BUILD_DIR)
	rm -rf $(PY24-DOCUTILS_IPK_DIR) $(PY24-DOCUTILS_IPK)
	rm -rf $(PY25-DOCUTILS_IPK_DIR) $(PY25-DOCUTILS_IPK)

#
# Some sanity check for the package.
#
py-docutils-check: $(PY24-DOCUTILS_IPK) $(PY25-DOCUTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-DOCUTILS_IPK) $(PY25-DOCUTILS_IPK)
