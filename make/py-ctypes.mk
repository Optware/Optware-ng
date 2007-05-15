###########################################################
#
# py-ctypes
#
###########################################################

#
# PY-CTYPES_VERSION, PY-CTYPES_SITE and PY-CTYPES_SOURCE define
# the upstream location of the source code for the package.
# PY-CTYPES_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CTYPES_UNZIP is the command used to unzip the source.
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
PY-CTYPES_VERSION=1.0.2
PY-CTYPES_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ctypes
PY-CTYPES_SOURCE=ctypes-$(PY-CTYPES_VERSION).tar.gz
PY-CTYPES_DIR=ctypes-$(PY-CTYPES_VERSION)
PY-CTYPES_UNZIP=zcat
PY-CTYPES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CTYPES_DESCRIPTION=A fast, lightweight Source Control Management system designed for efficient handling of very large distributed projects.
PY-CTYPES_SECTION=misc
PY-CTYPES_PRIORITY=optional
PY-CTYPES_DEPENDS=python
PY-CTYPES_CONFLICTS=

#
# PY-CTYPES_IPK_VERSION should be incremented when the ipk changes.
#
PY-CTYPES_IPK_VERSION=1

#
# PY-CTYPES_CONFFILES should be a list of user-editable files
#PY-CTYPES_CONFFILES=/opt/etc/py-ctypes.conf /opt/etc/init.d/SXXpy-ctypes

#
# PY-CTYPES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CTYPES_PATCHES=$(PY-CTYPES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CTYPES_CPPFLAGS=
PY-CTYPES_LDFLAGS=

#
# PY-CTYPES_BUILD_DIR is the directory in which the build is done.
# PY-CTYPES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CTYPES_IPK_DIR is the directory in which the ipk is built.
# PY-CTYPES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CTYPES_BUILD_DIR=$(BUILD_DIR)/py-ctypes
PY-CTYPES_SOURCE_DIR=$(SOURCE_DIR)/py-ctypes
PY-CTYPES_IPK_DIR=$(BUILD_DIR)/py-ctypes-$(PY-CTYPES_VERSION)-ipk
PY-CTYPES_IPK=$(BUILD_DIR)/py-ctypes_$(PY-CTYPES_VERSION)-$(PY-CTYPES_IPK_VERSION)_$(TARGET_ARCH).ipk

PY-CTYPES_TARGET_CONFIGURE_OPTS=$(shell echo $(TARGET_CONFIGURE_OPTS))

.PHONY: py-ctypes-source py-ctypes-unpack py-ctypes py-ctypes-stage py-ctypes-ipk py-ctypes-clean py-ctypes-dirclean py-ctypes-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CTYPES_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CTYPES_SITE)/$(PY-CTYPES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-ctypes-source: $(DL_DIR)/$(PY-CTYPES_SOURCE) $(PY-CTYPES_PATCHES)

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
$(PY-CTYPES_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CTYPES_SOURCE) $(PY-CTYPES_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-CTYPES_DIR) $(PY-CTYPES_BUILD_DIR)
	$(PY-CTYPES_UNZIP) $(DL_DIR)/$(PY-CTYPES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CTYPES_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CTYPES_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CTYPES_DIR) $(PY-CTYPES_BUILD_DIR)
	(cd $(PY-CTYPES_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python"; \
		echo "[install]"; \
		echo "install_scripts=/opt/bin"; \
	    ) > setup.cfg; \
	    sed -i \
		-e '/config_args =/s|=.*$$|= ["--build=$(GNU_HOST_NAME)", "--host=$(GNU_TARGET_NAME)", "--target=$(GNU_TARGET_NAME)"]|' \
		-e '/cmd =/s|"|"""|g' \
		-e '/cmd =/s|env |env $(TARGET_CONFIGURE_OPTS) CPPFLAGS="$(STAGING_CPPFLAGS)" LDFLAGS="$(STAGING_LDFLAGS)" |' \
		setup.py; \
	)
	touch $(PY-CTYPES_BUILD_DIR)/.configured

py-ctypes-unpack: $(PY-CTYPES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CTYPES_BUILD_DIR)/.built: $(PY-CTYPES_BUILD_DIR)/.configured
	rm -f $(PY-CTYPES_BUILD_DIR)/.built
	(cd $(PY-CTYPES_BUILD_DIR); \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-CTYPES_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-ctypes: $(PY-CTYPES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CTYPES_BUILD_DIR)/.staged: $(PY-CTYPES_BUILD_DIR)/.built
	rm -f $(PY-CTYPES_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-CTYPES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CTYPES_BUILD_DIR)/.staged

py-ctypes-stage: $(PY-CTYPES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-ctypes
#
$(PY-CTYPES_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CTYPES_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-ctypes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CTYPES_PRIORITY)" >>$@
	@echo "Section: $(PY-CTYPES_SECTION)" >>$@
	@echo "Version: $(PY-CTYPES_VERSION)-$(PY-CTYPES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CTYPES_MAINTAINER)" >>$@
	@echo "Source: $(PY-CTYPES_SITE)/$(PY-CTYPES_SOURCE)" >>$@
	@echo "Description: $(PY-CTYPES_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CTYPES_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CTYPES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CTYPES_IPK_DIR)/opt/sbin or $(PY-CTYPES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CTYPES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CTYPES_IPK_DIR)/opt/etc/py-ctypes/...
# Documentation files should be installed in $(PY-CTYPES_IPK_DIR)/opt/doc/py-ctypes/...
# Daemon startup scripts should be installed in $(PY-CTYPES_IPK_DIR)/opt/etc/init.d/S??py-ctypes
#
# You may need to patch your application to make it use these locations.
#
$(PY-CTYPES_IPK): $(PY-CTYPES_BUILD_DIR)/.built
	rm -rf $(PY-CTYPES_IPK_DIR) $(BUILD_DIR)/py-ctypes_*_$(TARGET_ARCH).ipk
	(cd $(PY-CTYPES_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PY-CTYPES_IPK_DIR) --prefix=/opt; \
	)
#	$(STRIP_COMMAND) $(PY-CTYPES_IPK_DIR)/opt/lib/python2.4/site-packages/ctypes/*.so
	(cd $(PY-CTYPES_IPK_DIR)/opt; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	$(MAKE) $(PY-CTYPES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CTYPES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-ctypes-ipk: $(PY-CTYPES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-ctypes-clean:
	-$(MAKE) -C $(PY-CTYPES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-ctypes-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CTYPES_DIR) $(PY-CTYPES_BUILD_DIR) $(PY-CTYPES_IPK_DIR) $(PY-CTYPES_IPK)

#
# Some sanity check for the package.
#
py-ctypes-check: $(PY-CTYPES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-CTYPES_IPK)
