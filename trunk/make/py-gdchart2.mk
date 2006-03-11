###########################################################
#
# py-gdchart2
#
###########################################################

#
# PY-GDCHART2_VERSION, PY-GDCHART2_SITE and PY-GDCHART2_SOURCE define
# the upstream location of the source code for the package.
# PY-GDCHART2_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GDCHART2_UNZIP is the command used to unzip the source.
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
PY-GDCHART2_SITE=http://www.nullcube.com/software/pygdchart2
PY-GDCHART2_VERSION=Beta1
PY-GDCHART2_SOURCE=pygdchart2.tar.gz
PY-GDCHART2_DIR=pygdchart2
PY-GDCHART2_UNZIP=zcat
PY-GDCHART2_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GDCHART2_DESCRIPTION=PyGDChart is a set of Python bindings for the GDChart library.
PY-GDCHART2_SECTION=misc
PY-GDCHART2_PRIORITY=optional
PY-GDCHART2_DEPENDS=python,libgd,zlib,libpng,freetype,libjpeg
PY-GDCHART2_CONFLICTS=

#
# PY-GDCHART2_IPK_VERSION should be incremented when the ipk changes.
#
PY-GDCHART2_IPK_VERSION=3

#
# PY-GDCHART2_CONFFILES should be a list of user-editable files
#PY-GDCHART2_CONFFILES=/opt/etc/py-gdchart2.conf /opt/etc/init.d/SXXpy-gdchart2

#
# PY-GDCHART2_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-GDCHART2_PATCHES=$(PY-GDCHART2_SOURCE_DIR)/setup.py.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GDCHART2_CPPFLAGS=
PY-GDCHART2_LDFLAGS=

#
# PY-GDCHART2_BUILD_DIR is the directory in which the build is done.
# PY-GDCHART2_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GDCHART2_IPK_DIR is the directory in which the ipk is built.
# PY-GDCHART2_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GDCHART2_BUILD_DIR=$(BUILD_DIR)/py-gdchart2
PY-GDCHART2_SOURCE_DIR=$(SOURCE_DIR)/py-gdchart2
PY-GDCHART2_IPK_DIR=$(BUILD_DIR)/py-gdchart2-$(PY-GDCHART2_VERSION)-ipk
PY-GDCHART2_IPK=$(BUILD_DIR)/py-gdchart2_$(PY-GDCHART2_VERSION)-$(PY-GDCHART2_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GDCHART2_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-GDCHART2_SITE)/$(PY-GDCHART2_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-gdchart2-source: $(DL_DIR)/$(PY-GDCHART2_SOURCE) $(PY-GDCHART2_PATCHES)

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
$(PY-GDCHART2_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GDCHART2_SOURCE) $(PY-GDCHART2_PATCHES)
	$(MAKE) python-stage gdchart-stage
	rm -rf $(BUILD_DIR)/$(PY-GDCHART2_DIR) $(PY-GDCHART2_BUILD_DIR)
	$(PY-GDCHART2_UNZIP) $(DL_DIR)/$(PY-GDCHART2_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-GDCHART2_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GDCHART2_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GDCHART2_DIR) $(PY-GDCHART2_BUILD_DIR)
	(cd $(PY-GDCHART2_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $(PY-GDCHART2_BUILD_DIR)/.configured

py-gdchart2-unpack: $(PY-GDCHART2_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GDCHART2_BUILD_DIR)/.built: $(PY-GDCHART2_BUILD_DIR)/.configured
	rm -f $(PY-GDCHART2_BUILD_DIR)/.built
	(cd $(PY-GDCHART2_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-GDCHART2_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-gdchart2: $(PY-GDCHART2_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GDCHART2_BUILD_DIR)/.staged: $(PY-GDCHART2_BUILD_DIR)/.built
	rm -f $(PY-GDCHART2_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-GDCHART2_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-GDCHART2_BUILD_DIR)/.staged

py-gdchart2-stage: $(PY-GDCHART2_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-gdchart2
#
$(PY-GDCHART2_IPK_DIR)/CONTROL/control:
	@install -d $(PY-GDCHART2_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-gdchart2" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GDCHART2_PRIORITY)" >>$@
	@echo "Section: $(PY-GDCHART2_SECTION)" >>$@
	@echo "Version: $(PY-GDCHART2_VERSION)-$(PY-GDCHART2_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GDCHART2_MAINTAINER)" >>$@
	@echo "Source: $(PY-GDCHART2_SITE)/$(PY-GDCHART2_SOURCE)" >>$@
	@echo "Description: $(PY-GDCHART2_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-GDCHART2_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-GDCHART2_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GDCHART2_IPK_DIR)/opt/sbin or $(PY-GDCHART2_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GDCHART2_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-GDCHART2_IPK_DIR)/opt/etc/py-gdchart2/...
# Documentation files should be installed in $(PY-GDCHART2_IPK_DIR)/opt/doc/py-gdchart2/...
# Daemon startup scripts should be installed in $(PY-GDCHART2_IPK_DIR)/opt/etc/init.d/S??py-gdchart2
#
# You may need to patch your application to make it use these locations.
#
$(PY-GDCHART2_IPK): $(PY-GDCHART2_BUILD_DIR)/.built
	rm -rf $(PY-GDCHART2_IPK_DIR) $(BUILD_DIR)/py-gdchart2_*_$(TARGET_ARCH).ipk
	(cd $(PY-GDCHART2_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py install --root=$(PY-GDCHART2_IPK_DIR) --prefix=/opt; \
	)
	for so in `find $(PY-GDCHART2_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PY-GDCHART2_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-GDCHART2_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-gdchart2-ipk: $(PY-GDCHART2_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-gdchart2-clean:
	-$(MAKE) -C $(PY-GDCHART2_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-gdchart2-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GDCHART2_DIR) $(PY-GDCHART2_BUILD_DIR) $(PY-GDCHART2_IPK_DIR) $(PY-GDCHART2_IPK)
