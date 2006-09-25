###########################################################
#
# py-codeville
#
###########################################################

#
# PY-CODEVILLE_VERSION, PY-CODEVILLE_SITE and PY-CODEVILLE_SOURCE define
# the upstream location of the source code for the package.
# PY-CODEVILLE_DIR is the directory which is created when the source
# archive is unpacked.
# PY-CODEVILLE_UNZIP is the command used to unzip the source.
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
PY-CODEVILLE_VERSION=0.1.16
PY-CODEVILLE_SITE=http://codeville.org/download
PY-CODEVILLE_SOURCE=Codeville-$(PY-CODEVILLE_VERSION).tar.gz
PY-CODEVILLE_DIR=Codeville-$(PY-CODEVILLE_VERSION)
PY-CODEVILLE_UNZIP=zcat
PY-CODEVILLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-CODEVILLE_DESCRIPTION=a distributed version control system.
PY-CODEVILLE_SECTION=web
PY-CODEVILLE_PRIORITY=optional
PY-CODEVILLE_DEPENDS=python
PY-CODEVILLE_CONFLICTS=

#
# PY-CODEVILLE_IPK_VERSION should be incremented when the ipk changes.
#
PY-CODEVILLE_IPK_VERSION=1

#
# PY-CODEVILLE_CONFFILES should be a list of user-editable files
#PY-CODEVILLE_CONFFILES=/opt/etc/py-codeville.conf /opt/etc/init.d/SXXpy-codeville

#
# PY-CODEVILLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-CODEVILLE_PATCHES=$(PY-CODEVILLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-CODEVILLE_CPPFLAGS=
PY-CODEVILLE_LDFLAGS=

#
# PY-CODEVILLE_BUILD_DIR is the directory in which the build is done.
# PY-CODEVILLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-CODEVILLE_IPK_DIR is the directory in which the ipk is built.
# PY-CODEVILLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-CODEVILLE_BUILD_DIR=$(BUILD_DIR)/py-codeville
PY-CODEVILLE_SOURCE_DIR=$(SOURCE_DIR)/py-codeville
PY-CODEVILLE_IPK_DIR=$(BUILD_DIR)/py-codeville-$(PY-CODEVILLE_VERSION)-ipk
PY-CODEVILLE_IPK=$(BUILD_DIR)/py-codeville_$(PY-CODEVILLE_VERSION)-$(PY-CODEVILLE_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-CODEVILLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-CODEVILLE_SITE)/$(PY-CODEVILLE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-codeville-source: $(DL_DIR)/$(PY-CODEVILLE_SOURCE) $(PY-CODEVILLE_PATCHES)

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
$(PY-CODEVILLE_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-CODEVILLE_SOURCE) $(PY-CODEVILLE_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-CODEVILLE_DIR) $(PY-CODEVILLE_BUILD_DIR)
	$(PY-CODEVILLE_UNZIP) $(DL_DIR)/$(PY-CODEVILLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-CODEVILLE_PATCHES) | patch -d $(BUILD_DIR)/$(PY-CODEVILLE_DIR) -p1
	mv $(BUILD_DIR)/$(PY-CODEVILLE_DIR) $(PY-CODEVILLE_BUILD_DIR)
	(cd $(PY-CODEVILLE_BUILD_DIR); \
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
	)
	touch $(PY-CODEVILLE_BUILD_DIR)/.configured

py-codeville-unpack: $(PY-CODEVILLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-CODEVILLE_BUILD_DIR)/.built: $(PY-CODEVILLE_BUILD_DIR)/.configured
	rm -f $(PY-CODEVILLE_BUILD_DIR)/.built
	(cd $(PY-CODEVILLE_BUILD_DIR); \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-CODEVILLE_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-codeville: $(PY-CODEVILLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-CODEVILLE_BUILD_DIR)/.staged: $(PY-CODEVILLE_BUILD_DIR)/.built
	rm -f $(PY-CODEVILLE_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-CODEVILLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-CODEVILLE_BUILD_DIR)/.staged

py-codeville-stage: $(PY-CODEVILLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-codeville
#
$(PY-CODEVILLE_IPK_DIR)/CONTROL/control:
	@install -d $(PY-CODEVILLE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-codeville" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-CODEVILLE_PRIORITY)" >>$@
	@echo "Section: $(PY-CODEVILLE_SECTION)" >>$@
	@echo "Version: $(PY-CODEVILLE_VERSION)-$(PY-CODEVILLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-CODEVILLE_MAINTAINER)" >>$@
	@echo "Source: $(PY-CODEVILLE_SITE)/$(PY-CODEVILLE_SOURCE)" >>$@
	@echo "Description: $(PY-CODEVILLE_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-CODEVILLE_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-CODEVILLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-CODEVILLE_IPK_DIR)/opt/sbin or $(PY-CODEVILLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-CODEVILLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-CODEVILLE_IPK_DIR)/opt/etc/py-codeville/...
# Documentation files should be installed in $(PY-CODEVILLE_IPK_DIR)/opt/doc/py-codeville/...
# Daemon startup scripts should be installed in $(PY-CODEVILLE_IPK_DIR)/opt/etc/init.d/S??py-codeville
#
# You may need to patch your application to make it use these locations.
#
$(PY-CODEVILLE_IPK): $(PY-CODEVILLE_BUILD_DIR)/.built
	rm -rf $(PY-CODEVILLE_IPK_DIR) $(BUILD_DIR)/py-codeville_*_$(TARGET_ARCH).ipk
	(cd $(PY-CODEVILLE_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PY-CODEVILLE_IPK_DIR) --prefix=/opt; \
	)
#	-$(STRIP_COMMAND) `find $(PY-CODEVILLE_IPK_DIR)/opt/lib/python2.4/site-packages/codeville -name '*.so'`
	$(MAKE) $(PY-CODEVILLE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-CODEVILLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-codeville-ipk: $(PY-CODEVILLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-codeville-clean:
	-$(MAKE) -C $(PY-CODEVILLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-codeville-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-CODEVILLE_DIR) $(PY-CODEVILLE_BUILD_DIR) $(PY-CODEVILLE_IPK_DIR) $(PY-CODEVILLE_IPK)
