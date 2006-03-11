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
PY-PIL_VERSION=1.1.5
PY-PIL_SOURCE=Imaging-$(PY-PIL_VERSION).tar.gz
PY-PIL_DIR=Imaging-$(PY-PIL_VERSION)
PY-PIL_UNZIP=zcat
PY-PIL_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-PIL_DESCRIPTION=The Python Imaging Library (PIL) adds image processing capabilities to your Python interpreter.
PY-PIL_SECTION=misc
PY-PIL_PRIORITY=optional
PY-PIL_DEPENDS=python,freetype,libjpeg,zlib
PY-PIL_CONFLICTS=

#
# PY-PIL_IPK_VERSION should be incremented when the ipk changes.
#
PY-PIL_IPK_VERSION=3

#
# PY-PIL_CONFFILES should be a list of user-editable files
#PY-PIL_CONFFILES=/opt/etc/py-pil.conf /opt/etc/init.d/SXXpy-pil

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
PY-PIL_IPK_DIR=$(BUILD_DIR)/py-pil-$(PY-PIL_VERSION)-ipk
PY-PIL_IPK=$(BUILD_DIR)/py-pil_$(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-PIL_SITE)/$(PY-PIL_SOURCE)

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
$(PY-PIL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PIL_SOURCE) $(PY-PIL_PATCHES)
	$(MAKE) python-stage freetype-stage libjpeg-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(PY-PIL_DIR) $(PY-PIL_BUILD_DIR)
	$(PY-PIL_UNZIP) $(DL_DIR)/$(PY-PIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-PIL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PIL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-PIL_DIR) $(PY-PIL_BUILD_DIR)
	sed -i -e 's:@STAGING_PREFIX@:$(STAGING_PREFIX):' $(PY-PIL_BUILD_DIR)/setup.py
	(cd $(PY-PIL_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) > setup.cfg; \
	)
	touch $(PY-PIL_BUILD_DIR)/.configured

py-pil-unpack: $(PY-PIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PIL_BUILD_DIR)/.built: $(PY-PIL_BUILD_DIR)/.configured
	rm -f $(PY-PIL_BUILD_DIR)/.built
	(cd $(PY-PIL_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build; \
	)
	touch $(PY-PIL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-pil: $(PY-PIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PIL_BUILD_DIR)/.staged: $(PY-PIL_BUILD_DIR)/.built
	rm -f $(PY-PIL_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-PIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-PIL_BUILD_DIR)/.staged

py-pil-stage: $(PY-PIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-pil
#
$(PY-PIL_IPK_DIR)/CONTROL/control:
	@install -d $(PY-PIL_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-pil" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PIL_PRIORITY)" >>$@
	@echo "Section: $(PY-PIL_SECTION)" >>$@
	@echo "Version: $(PY-PIL_VERSION)-$(PY-PIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-PIL_SITE)/$(PY-PIL_SOURCE)" >>$@
	@echo "Description: $(PY-PIL_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-PIL_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PIL_IPK_DIR)/opt/sbin or $(PY-PIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PIL_IPK_DIR)/opt/etc/py-pil/...
# Documentation files should be installed in $(PY-PIL_IPK_DIR)/opt/doc/py-pil/...
# Daemon startup scripts should be installed in $(PY-PIL_IPK_DIR)/opt/etc/init.d/S??py-pil
#
# You may need to patch your application to make it use these locations.
#
$(PY-PIL_IPK): $(PY-PIL_BUILD_DIR)/.built
	rm -rf $(PY-PIL_IPK_DIR) $(BUILD_DIR)/py-pil_*_$(TARGET_ARCH).ipk
	(cd $(PY-PIL_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py install --root=$(PY-PIL_IPK_DIR) --prefix=/opt; \
	)
	for so in `find $(PY-PIL_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`; do \
	    $(STRIP_COMMAND) $$so; \
	done
	$(MAKE) $(PY-PIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-PIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-pil-ipk: $(PY-PIL_IPK)

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
	rm -rf $(BUILD_DIR)/$(PY-PIL_DIR) $(PY-PIL_BUILD_DIR) $(PY-PIL_IPK_DIR) $(PY-PIL_IPK)
