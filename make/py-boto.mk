###########################################################
#
# py-boto
#
###########################################################

#
# PY-BOTO_VERSION, PY-BOTO_SITE and PY-BOTO_SOURCE define
# the upstream location of the source code for the package.
# PY-BOTO_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BOTO_UNZIP is the command used to unzip the source.
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
PY-BOTO_VERSION=1.9b
PY-BOTO_SITE=http://boto.googlecode.com/files
PY-BOTO_SOURCE=boto-$(PY-BOTO_VERSION).tar.gz
PY-BOTO_DIR=boto-$(PY-BOTO_VERSION)
PY-BOTO_UNZIP=zcat
PY-BOTO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BOTO_DESCRIPTION=Python interface to Amazon Web Services
PY-BOTO_SECTION=misc
PY-BOTO_PRIORITY=optional
PY25-BOTO_DEPENDS=python25
PY26-BOTO_DEPENDS=python26
PY-BOTO_SUGGESTS=
PY-BOTO_CONFLICTS=

#
# PY-BOTO_IPK_VERSION should be incremented when the ipk changes.
#
PY-BOTO_IPK_VERSION=1

#
# PY-BOTO_CONFFILES should be a list of user-editable files
#PY-BOTO_CONFFILES=/opt/etc/py-boto.conf /opt/etc/init.d/SXXpy-boto

#
# PY-BOTO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-BOTO_PATCHES=$(PY-BOTO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BOTO_CPPFLAGS=
PY-BOTO_LDFLAGS=

#
# PY-BOTO_BUILD_DIR is the directory in which the build is done.
# PY-BOTO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BOTO_IPK_DIR is the directory in which the ipk is built.
# PY-BOTO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BOTO_BUILD_DIR=$(BUILD_DIR)/py-boto
PY-BOTO_SOURCE_DIR=$(SOURCE_DIR)/py-boto

PY25-BOTO_IPK_DIR=$(BUILD_DIR)/py25-boto-$(PY-BOTO_VERSION)-ipk
PY25-BOTO_IPK=$(BUILD_DIR)/py25-boto_$(PY-BOTO_VERSION)-$(PY-BOTO_IPK_VERSION)_$(TARGET_ARCH).ipk

PY26-BOTO_IPK_DIR=$(BUILD_DIR)/py26-boto-$(PY-BOTO_VERSION)-ipk
PY26-BOTO_IPK=$(BUILD_DIR)/py26-boto_$(PY-BOTO_VERSION)-$(PY-BOTO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-boto-source py-boto-unpack py-boto py-boto-stage py-boto-ipk py-boto-clean py-boto-dirclean py-boto-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BOTO_SOURCE):
	$(WGET) -P $(@D) $(PY-BOTO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-boto-source: $(DL_DIR)/$(PY-BOTO_SOURCE) $(PY-BOTO_PATCHES)

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
$(PY-BOTO_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BOTO_SOURCE) $(PY-BOTO_PATCHES) make/py-boto.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-BOTO_DIR) $(@D)
	mkdir -p $(@D)
	# 2.5
	$(PY-BOTO_UNZIP) $(DL_DIR)/$(PY-BOTO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-BOTO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BOTO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BOTO_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
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
	# 2.6
	$(PY-BOTO_UNZIP) $(DL_DIR)/$(PY-BOTO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-BOTO_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BOTO_DIR) -p1
	mv $(BUILD_DIR)/$(PY-BOTO_DIR) $(@D)/2.6
	(cd $(@D)/2.6; \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) >> setup.cfg; \
	)
	touch $@

py-boto-unpack: $(PY-BOTO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BOTO_BUILD_DIR)/.built: $(PY-BOTO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.5; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	(cd $(@D)/2.6; \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
py-boto: $(PY-BOTO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-BOTO_BUILD_DIR)/.staged: $(PY-BOTO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#py-boto-stage: $(PY-BOTO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-boto
#
$(PY25-BOTO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-boto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BOTO_PRIORITY)" >>$@
	@echo "Section: $(PY-BOTO_SECTION)" >>$@
	@echo "Version: $(PY-BOTO_VERSION)-$(PY-BOTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BOTO_MAINTAINER)" >>$@
	@echo "Source: $(PY-BOTO_SITE)/$(PY-BOTO_SOURCE)" >>$@
	@echo "Description: $(PY-BOTO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-BOTO_DEPENDS)" >>$@
	@echo "Suggests: $(PY-BOTO_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-BOTO_CONFLICTS)" >>$@

$(PY26-BOTO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py26-boto" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BOTO_PRIORITY)" >>$@
	@echo "Section: $(PY-BOTO_SECTION)" >>$@
	@echo "Version: $(PY-BOTO_VERSION)-$(PY-BOTO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BOTO_MAINTAINER)" >>$@
	@echo "Source: $(PY-BOTO_SITE)/$(PY-BOTO_SOURCE)" >>$@
	@echo "Description: $(PY-BOTO_DESCRIPTION)" >>$@
	@echo "Depends: $(PY26-BOTO_DEPENDS)" >>$@
	@echo "Suggests: $(PY-BOTO_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-BOTO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BOTO_IPK_DIR)/opt/sbin or $(PY-BOTO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BOTO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BOTO_IPK_DIR)/opt/etc/py-boto/...
# Documentation files should be installed in $(PY-BOTO_IPK_DIR)/opt/doc/py-boto/...
# Daemon startup scripts should be installed in $(PY-BOTO_IPK_DIR)/opt/etc/init.d/S??py-boto
#
# You may need to patch your application to make it use these locations.
#
$(PY25-BOTO_IPK) $(PY26-BOTO_IPK): $(PY-BOTO_BUILD_DIR)/.built
	# 2.5
	rm -rf $(PY25-BOTO_IPK_DIR) $(BUILD_DIR)/py25-boto_*_$(TARGET_ARCH).ipk
	(cd $(PY-BOTO_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BOTO_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY25-BOTO_IPK_DIR)/opt/lib/python2.5/site-packages/boto/*.so
	$(MAKE) $(PY25-BOTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BOTO_IPK_DIR)
	# 2.6
	rm -rf $(PY26-BOTO_IPK_DIR) $(BUILD_DIR)/py26-boto_*_$(TARGET_ARCH).ipk
	(cd $(PY-BOTO_BUILD_DIR)/2.6; \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install --root=$(PY26-BOTO_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY26-BOTO_IPK_DIR)/opt/lib/python2.6/site-packages/boto/*.so
	for f in $(PY26-BOTO_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.6|'`; done
	$(MAKE) $(PY26-BOTO_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY26-BOTO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-boto-ipk: $(PY25-BOTO_IPK) $(PY26-BOTO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-boto-clean:
	-$(MAKE) -C $(PY-BOTO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-boto-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BOTO_DIR) $(PY-BOTO_BUILD_DIR)
	rm -rf $(PY25-BOTO_IPK_DIR) $(PY25-BOTO_IPK)
	rm -rf $(PY26-BOTO_IPK_DIR) $(PY26-BOTO_IPK)

#
# Some sanity check for the package.
#
py-boto-check: $(PY25-BOTO_IPK) $(PY26-BOTO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
