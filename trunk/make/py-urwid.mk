###########################################################
#
# py-urwid
#
###########################################################

#
# PY-URWID_VERSION, PY-URWID_SITE and PY-URWID_SOURCE define
# the upstream location of the source code for the package.
# PY-URWID_DIR is the directory which is created when the source
# archive is unpacked.
# PY-URWID_UNZIP is the command used to unzip the source.
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
PY-URWID_SITE=http://excess.org/urwid
PY-URWID_VERSION=0.9.1
PY-URWID_SOURCE=urwid-$(PY-URWID_VERSION).tar.gz
PY-URWID_DIR=urwid-$(PY-URWID_VERSION)
PY-URWID_UNZIP=zcat
PY-URWID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-URWID_DESCRIPTION=Urwid is a console user interface library in Python.
PY-URWID_SECTION=misc
PY-URWID_PRIORITY=optional
PY-URWID_DEPENDS=python
PY-URWID_CONFLICTS=

#
# PY-URWID_IPK_VERSION should be incremented when the ipk changes.
#
PY-URWID_IPK_VERSION=1

#
# PY-URWID_CONFFILES should be a list of user-editable files
#PY-URWID_CONFFILES=/opt/etc/py-urwid.conf /opt/etc/init.d/SXXpy-urwid

#
# PY-URWID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-URWID_PATCHES=$(PY-URWID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-URWID_CPPFLAGS=
PY-URWID_LDFLAGS=

#
# PY-URWID_BUILD_DIR is the directory in which the build is done.
# PY-URWID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-URWID_IPK_DIR is the directory in which the ipk is built.
# PY-URWID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-URWID_BUILD_DIR=$(BUILD_DIR)/py-urwid
PY-URWID_SOURCE_DIR=$(SOURCE_DIR)/py-urwid
PY-URWID_IPK_DIR=$(BUILD_DIR)/py-urwid-$(PY-URWID_VERSION)-ipk
PY-URWID_IPK=$(BUILD_DIR)/py-urwid_$(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-URWID_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-URWID_SITE)/$(PY-URWID_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-urwid-source: $(DL_DIR)/$(PY-URWID_SOURCE) $(PY-URWID_PATCHES)

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
$(PY-URWID_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-URWID_SOURCE) $(PY-URWID_PATCHES)
	$(MAKE) python-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(PY-URWID_DIR) $(PY-URWID_BUILD_DIR)
	$(PY-URWID_UNZIP) $(DL_DIR)/$(PY-URWID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-URWID_PATCHES) | patch -d $(BUILD_DIR)/$(PY-URWID_DIR) -p1
	mv $(BUILD_DIR)/$(PY-URWID_DIR) $(PY-URWID_BUILD_DIR)
	(cd $(PY-URWID_BUILD_DIR); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) >> setup.cfg; \
	)
	touch $(PY-URWID_BUILD_DIR)/.configured

py-urwid-unpack: $(PY-URWID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-URWID_BUILD_DIR)/.built: $(PY-URWID_BUILD_DIR)/.configured
	rm -f $(PY-URWID_BUILD_DIR)/.built
	(cd $(PY-URWID_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py build \
	    ; \
	)
	touch $(PY-URWID_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-urwid: $(PY-URWID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-URWID_BUILD_DIR)/.staged: $(PY-URWID_BUILD_DIR)/.built
	rm -f $(PY-URWID_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-URWID_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-URWID_BUILD_DIR)/.staged

py-urwid-stage: $(PY-URWID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-urwid
#
$(PY-URWID_IPK_DIR)/CONTROL/control:
	@install -d $(PY-URWID_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-urwid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-URWID_PRIORITY)" >>$@
	@echo "Section: $(PY-URWID_SECTION)" >>$@
	@echo "Version: $(PY-URWID_VERSION)-$(PY-URWID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-URWID_MAINTAINER)" >>$@
	@echo "Source: $(PY-URWID_SITE)/$(PY-URWID_SOURCE)" >>$@
	@echo "Description: $(PY-URWID_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-URWID_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-URWID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-URWID_IPK_DIR)/opt/sbin or $(PY-URWID_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-URWID_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-URWID_IPK_DIR)/opt/etc/py-urwid/...
# Documentation files should be installed in $(PY-URWID_IPK_DIR)/opt/doc/py-urwid/...
# Daemon startup scripts should be installed in $(PY-URWID_IPK_DIR)/opt/etc/init.d/S??py-urwid
#
# You may need to patch your application to make it use these locations.
#
$(PY-URWID_IPK): $(PY-URWID_BUILD_DIR)/.built
	rm -rf $(PY-URWID_IPK_DIR) $(BUILD_DIR)/py-urwid_*_$(TARGET_ARCH).ipk
	(cd $(PY-URWID_BUILD_DIR); \
	 CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    python2.4 setup.py install --root=$(PY-URWID_IPK_DIR) --prefix=/opt; \
	)
	install -d $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid
	echo "http://excess.org/urwid/" > $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid/url.txt
	install -m 644 $(PY-URWID_BUILD_DIR)/*.html $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid
	install -d $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid/examples
	install -m 644 $(PY-URWID_BUILD_DIR)/*.py $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid/examples
	rm $(PY-URWID_IPK_DIR)/opt/share/doc/py-urwid/examples/setup.py
#	$(STRIP_COMMAND) `find $(PY-URWID_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY-URWID_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-URWID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-urwid-ipk: $(PY-URWID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-urwid-clean:
	-$(MAKE) -C $(PY-URWID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-urwid-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-URWID_DIR) $(PY-URWID_BUILD_DIR) $(PY-URWID_IPK_DIR) $(PY-URWID_IPK)
