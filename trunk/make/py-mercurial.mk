###########################################################
#
# py-mercurial
#
###########################################################

#
# PY-MERCURIAL_VERSION, PY-MERCURIAL_SITE and PY-MERCURIAL_SOURCE define
# the upstream location of the source code for the package.
# PY-MERCURIAL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MERCURIAL_UNZIP is the command used to unzip the source.
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
PY-MERCURIAL_VERSION=0.8
PY-MERCURIAL_SITE=http://www.selenic.com/mercurial/release
PY-MERCURIAL_SOURCE=mercurial-$(PY-MERCURIAL_VERSION).tar.gz
PY-MERCURIAL_DIR=mercurial-$(PY-MERCURIAL_VERSION)
PY-MERCURIAL_UNZIP=zcat
PY-MERCURIAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MERCURIAL_DESCRIPTION=A fast, lightweight Source Control Management system designed for efficient handling of very large distributed projects.
PY-MERCURIAL_SECTION=misc
PY-MERCURIAL_PRIORITY=optional
PY-MERCURIAL_DEPENDS=python
PY-MERCURIAL_CONFLICTS=

#
# PY-MERCURIAL_IPK_VERSION should be incremented when the ipk changes.
#
PY-MERCURIAL_IPK_VERSION=3

#
# PY-MERCURIAL_CONFFILES should be a list of user-editable files
#PY-MERCURIAL_CONFFILES=/opt/etc/py-mercurial.conf /opt/etc/init.d/SXXpy-mercurial

#
# PY-MERCURIAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-MERCURIAL_PATCHES=$(PY-MERCURIAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MERCURIAL_CPPFLAGS=
PY-MERCURIAL_LDFLAGS=

#
# PY-MERCURIAL_BUILD_DIR is the directory in which the build is done.
# PY-MERCURIAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MERCURIAL_IPK_DIR is the directory in which the ipk is built.
# PY-MERCURIAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MERCURIAL_BUILD_DIR=$(BUILD_DIR)/py-mercurial
PY-MERCURIAL_SOURCE_DIR=$(SOURCE_DIR)/py-mercurial
PY-MERCURIAL_IPK_DIR=$(BUILD_DIR)/py-mercurial-$(PY-MERCURIAL_VERSION)-ipk
PY-MERCURIAL_IPK=$(BUILD_DIR)/py-mercurial_$(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MERCURIAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-mercurial-source: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(PY-MERCURIAL_PATCHES)

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
$(PY-MERCURIAL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MERCURIAL_SOURCE) $(PY-MERCURIAL_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(PY-MERCURIAL_BUILD_DIR)
	$(PY-MERCURIAL_UNZIP) $(DL_DIR)/$(PY-MERCURIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-MERCURIAL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MERCURIAL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(PY-MERCURIAL_BUILD_DIR)
	(cd $(PY-MERCURIAL_BUILD_DIR); \
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
	touch $(PY-MERCURIAL_BUILD_DIR)/.configured

py-mercurial-unpack: $(PY-MERCURIAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MERCURIAL_BUILD_DIR)/.built: $(PY-MERCURIAL_BUILD_DIR)/.configured
	rm -f $(PY-MERCURIAL_BUILD_DIR)/.built
	(cd $(PY-MERCURIAL_BUILD_DIR); \
	$(TARGET_CONFIGURE_OPTS) LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-MERCURIAL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-mercurial: $(PY-MERCURIAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MERCURIAL_BUILD_DIR)/.staged: $(PY-MERCURIAL_BUILD_DIR)/.built
	rm -f $(PY-MERCURIAL_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-MERCURIAL_BUILD_DIR)/.staged

py-mercurial-stage: $(PY-MERCURIAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-mercurial
#
$(PY-MERCURIAL_IPK_DIR)/CONTROL/control:
	@install -d $(PY-MERCURIAL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-mercurial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MERCURIAL_PRIORITY)" >>$@
	@echo "Section: $(PY-MERCURIAL_SECTION)" >>$@
	@echo "Version: $(PY-MERCURIAL_VERSION)-$(PY-MERCURIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MERCURIAL_MAINTAINER)" >>$@
	@echo "Source: $(PY-MERCURIAL_SITE)/$(PY-MERCURIAL_SOURCE)" >>$@
	@echo "Description: $(PY-MERCURIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-MERCURIAL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MERCURIAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MERCURIAL_IPK_DIR)/opt/sbin or $(PY-MERCURIAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MERCURIAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/etc/py-mercurial/...
# Documentation files should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/doc/py-mercurial/...
# Daemon startup scripts should be installed in $(PY-MERCURIAL_IPK_DIR)/opt/etc/init.d/S??py-mercurial
#
# You may need to patch your application to make it use these locations.
#
$(PY-MERCURIAL_IPK): $(PY-MERCURIAL_BUILD_DIR)/.built
	rm -rf $(PY-MERCURIAL_IPK_DIR) $(BUILD_DIR)/py-mercurial_*_$(TARGET_ARCH).ipk
	(cd $(PY-MERCURIAL_BUILD_DIR); \
	    python2.4 setup.py install --root=$(PY-MERCURIAL_IPK_DIR) --prefix=/opt; \
	)
	$(STRIP_COMMAND) $(PY-MERCURIAL_IPK_DIR)/opt/lib/python2.4/site-packages/mercurial/*.so
	$(MAKE) $(PY-MERCURIAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-MERCURIAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-mercurial-ipk: $(PY-MERCURIAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-mercurial-clean:
	-$(MAKE) -C $(PY-MERCURIAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-mercurial-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MERCURIAL_DIR) $(PY-MERCURIAL_BUILD_DIR) $(PY-MERCURIAL_IPK_DIR) $(PY-MERCURIAL_IPK)
