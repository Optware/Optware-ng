###########################################################
#
# py-duplicity
#
###########################################################

#
# PY-DUPLICITY_VERSION, PY-DUPLICITY_SITE and PY-DUPLICITY_SOURCE define
# the upstream location of the source code for the package.
# PY-DUPLICITY_DIR is the directory which is created when the source
# archive is unpacked.
# PY-DUPLICITY_UNZIP is the command used to unzip the source.
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
PY-DUPLICITY_VERSION=0.4.2
PY-DUPLICITY_SITE=http://savannah.nongnu.org/download/duplicity
PY-DUPLICITY_SOURCE=duplicity-$(PY-DUPLICITY_VERSION).tar.gz
PY-DUPLICITY_DIR=duplicity-$(PY-DUPLICITY_VERSION)
PY-DUPLICITY_UNZIP=zcat
PY-DUPLICITY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-DUPLICITY_DESCRIPTION=Encrypted bandwidth-efficient backup using the rsync algorithm
PY-DUPLICITY_SECTION=misc
PY-DUPLICITY_PRIORITY=optional
PY24-DUPLICITY_DEPENDS=python24, librsync, gnupg
PY25-DUPLICITY_DEPENDS=python25, librsync, gnupg
PY-DUPLICITY_CONFLICTS=

#
# PY-DUPLICITY_IPK_VERSION should be incremented when the ipk changes.
#
PY-DUPLICITY_IPK_VERSION=1

#
# PY-DUPLICITY_CONFFILES should be a list of user-editable files
#PY-DUPLICITY_CONFFILES=/opt/etc/py-duplicity.conf /opt/etc/init.d/SXXpy-duplicity

#
# PY-DUPLICITY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-DUPLICITY_PATCHES=$(PY-DUPLICITY_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-DUPLICITY_CPPFLAGS=
PY-DUPLICITY_LDFLAGS=

#
# PY-DUPLICITY_BUILD_DIR is the directory in which the build is done.
# PY-DUPLICITY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-DUPLICITY_IPK_DIR is the directory in which the ipk is built.
# PY-DUPLICITY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-DUPLICITY_BUILD_DIR=$(BUILD_DIR)/py-duplicity
PY-DUPLICITY_SOURCE_DIR=$(SOURCE_DIR)/py-duplicity

PY24-DUPLICITY_IPK_DIR=$(BUILD_DIR)/py-duplicity-$(PY-DUPLICITY_VERSION)-ipk
PY24-DUPLICITY_IPK=$(BUILD_DIR)/py-duplicity_$(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-DUPLICITY_IPK_DIR=$(BUILD_DIR)/py25-duplicity-$(PY-DUPLICITY_VERSION)-ipk
PY25-DUPLICITY_IPK=$(BUILD_DIR)/py25-duplicity_$(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-DUPLICITY-DOC_IPK_DIR=$(BUILD_DIR)/py-duplicity-doc-$(PY-DUPLICITY_VERSION)-ipk
PY-DUPLICITY-DOC_IPK=$(BUILD_DIR)/py-duplicity-doc_$(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-duplicity-source py-duplicity-unpack py-duplicity py-duplicity-stage py-duplicity-ipk py-duplicity-clean py-duplicity-dirclean py-duplicity-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-DUPLICITY_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-DUPLICITY_SITE)/$(PY-DUPLICITY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-duplicity-source: $(DL_DIR)/$(PY-DUPLICITY_SOURCE) $(PY-DUPLICITY_PATCHES)

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
$(PY-DUPLICITY_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-DUPLICITY_SOURCE) $(PY-DUPLICITY_PATCHES)
	$(MAKE) py-setuptools-stage
	$(MAKE) librsync-stage
	rm -rf $(BUILD_DIR)/$(PY-DUPLICITY_DIR) $(PY-DUPLICITY_BUILD_DIR)
	mkdir -p $(PY-DUPLICITY_BUILD_DIR)
	# 2.4
	$(PY-DUPLICITY_UNZIP) $(DL_DIR)/$(PY-DUPLICITY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DUPLICITY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DUPLICITY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DUPLICITY_DIR) $(PY-DUPLICITY_BUILD_DIR)/2.4
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.4; \
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
	$(PY-DUPLICITY_UNZIP) $(DL_DIR)/$(PY-DUPLICITY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-DUPLICITY_PATCHES) | patch -d $(BUILD_DIR)/$(PY-DUPLICITY_DIR) -p1
	mv $(BUILD_DIR)/$(PY-DUPLICITY_DIR) $(PY-DUPLICITY_BUILD_DIR)/2.5
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.5; \
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
	touch $(PY-DUPLICITY_BUILD_DIR)/.configured

py-duplicity-unpack: $(PY-DUPLICITY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-DUPLICITY_BUILD_DIR)/.built: $(PY-DUPLICITY_BUILD_DIR)/.configured
	rm -f $(PY-DUPLICITY_BUILD_DIR)/.built
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.4; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $(PY-DUPLICITY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-duplicity: $(PY-DUPLICITY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-DUPLICITY_BUILD_DIR)/.staged: $(PY-DUPLICITY_BUILD_DIR)/.built
	rm -f $(PY-DUPLICITY_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-DUPLICITY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-DUPLICITY_BUILD_DIR)/.staged

py-duplicity-stage: $(PY-DUPLICITY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-duplicity
#
$(PY24-DUPLICITY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-duplicity" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DUPLICITY_PRIORITY)" >>$@
	@echo "Section: $(PY-DUPLICITY_SECTION)" >>$@
	@echo "Version: $(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DUPLICITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-DUPLICITY_SITE)/$(PY-DUPLICITY_SOURCE)" >>$@
	@echo "Description: $(PY-DUPLICITY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-DUPLICITY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DUPLICITY_CONFLICTS)" >>$@

$(PY25-DUPLICITY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-duplicity" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DUPLICITY_PRIORITY)" >>$@
	@echo "Section: $(PY-DUPLICITY_SECTION)" >>$@
	@echo "Version: $(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DUPLICITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-DUPLICITY_SITE)/$(PY-DUPLICITY_SOURCE)" >>$@
	@echo "Description: $(PY-DUPLICITY_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-DUPLICITY_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-DUPLICITY_CONFLICTS)" >>$@

$(PY-DUPLICITY-DOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-duplicity-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-DUPLICITY_PRIORITY)" >>$@
	@echo "Section: $(PY-DUPLICITY_SECTION)" >>$@
	@echo "Version: $(PY-DUPLICITY_VERSION)-$(PY-DUPLICITY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-DUPLICITY_MAINTAINER)" >>$@
	@echo "Source: $(PY-DUPLICITY_SITE)/$(PY-DUPLICITY_SOURCE)" >>$@
	@echo "Description: $(PY-DUPLICITY_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-DUPLICITY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-DUPLICITY_IPK_DIR)/opt/sbin or $(PY-DUPLICITY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-DUPLICITY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-DUPLICITY_IPK_DIR)/opt/etc/py-duplicity/...
# Documentation files should be installed in $(PY-DUPLICITY_IPK_DIR)/opt/doc/py-duplicity/...
# Daemon startup scripts should be installed in $(PY-DUPLICITY_IPK_DIR)/opt/etc/init.d/S??py-duplicity
#
# You may need to patch your application to make it use these locations.
#
$(PY24-DUPLICITY_IPK) $(PY25-DUPLICITY_IPK) $(PY-DUPLICITY-DOC_IPK): $(PY-DUPLICITY_BUILD_DIR)/.built
	# 2.4
	rm -rf $(PY24-DUPLICITY_IPK_DIR) $(BUILD_DIR)/py-duplicity_*_$(TARGET_ARCH).ipk
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-DUPLICITY_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY24-DUPLICITY_IPK_DIR)/opt/lib/python2.4/site-packages/duplicity/*.so
	$(MAKE) $(PY24-DUPLICITY_IPK_DIR)/CONTROL/control
	rm -rf $(PY24-DUPLICITY_IPK_DIR)/opt/share
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-DUPLICITY_IPK_DIR)
	# 2.5
	rm -rf $(PY25-DUPLICITY_IPK_DIR) $(BUILD_DIR)/py25-duplicity_*_$(TARGET_ARCH).ipk
	(cd $(PY-DUPLICITY_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-DUPLICITY_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY25-DUPLICITY_IPK_DIR)/opt/lib/python2.5/site-packages/duplicity/*.so
	for f in $(PY25-DUPLICITY_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	$(MAKE) $(PY25-DUPLICITY_IPK_DIR)/CONTROL/control
	# doc
	rm -rf $(PY-DUPLICITY-DOC_IPK_DIR) $(BUILD_DIR)/py-duplicity-doc_*_$(TARGET_ARCH).ipk
	install -d $(PY-DUPLICITY-DOC_IPK_DIR)/opt
	mv $(PY25-DUPLICITY_IPK_DIR)/opt/share $(PY-DUPLICITY-DOC_IPK_DIR)/opt
	$(MAKE) $(PY-DUPLICITY-DOC_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-DUPLICITY_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-DUPLICITY-DOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-duplicity-ipk: $(PY24-DUPLICITY_IPK) $(PY25-DUPLICITY_IPK) $(PY-DUPLICITY-DOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-duplicity-clean:
	-$(MAKE) -C $(PY-DUPLICITY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-duplicity-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-DUPLICITY_DIR) $(PY-DUPLICITY_BUILD_DIR)
	rm -rf $(PY24-DUPLICITY_IPK_DIR) $(PY24-DUPLICITY_IPK)
	rm -rf $(PY25-DUPLICITY_IPK_DIR) $(PY25-DUPLICITY_IPK)
	rm -rf $(PY-DUPLICITY-DOC_IPK_DIR) $(PY-DUPLICITY-DOC_IPK)

#
# Some sanity check for the package.
#
py-duplicity-check: $(PY24-DUPLICITY_IPK) $(PY25-DUPLICITY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-DUPLICITY_IPK) $(PY25-DUPLICITY_IPK)
