###########################################################
#
# py-xml
#
###########################################################

#
# PY-XML_VERSION, PY-XML_SITE and PY-XML_SOURCE define
# the upstream location of the source code for the package.
# PY-XML_DIR is the directory which is created when the source
# archive is unpacked.
# PY-XML_UNZIP is the command used to unzip the source.
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
PY-XML_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pyxml
PY-XML_VERSION=0.8.4
PY-XML_SOURCE=PyXML-$(PY-XML_VERSION).tar.gz
PY-XML_DIR=PyXML-$(PY-XML_VERSION)
PY-XML_UNZIP=zcat
PY-XML_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-XML_DESCRIPTION=The PyXML package is a collection of libraries to process XML with Python.
PY-XML_SECTION=misc
PY-XML_PRIORITY=optional
PY-XML_DEPENDS=python
PY-XML_SUGGESTS=
PY-XML_CONFLICTS=

#
# PY-XML_IPK_VERSION should be incremented when the ipk changes.
#
PY-XML_IPK_VERSION=3

#
# PY-XML_CONFFILES should be a list of user-editable files
#PY-XML_CONFFILES=/opt/etc/py-xml.conf /opt/etc/init.d/SXXpy-xml

#
# PY-XML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-XML_PATCHES=$(PY-XML_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-XML_CPPFLAGS=
PY-XML_LDFLAGS=

#
# PY-XML_BUILD_DIR is the directory in which the build is done.
# PY-XML_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-XML_IPK_DIR is the directory in which the ipk is built.
# PY-XML_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-XML_BUILD_DIR=$(BUILD_DIR)/py-xml
PY-XML_SOURCE_DIR=$(SOURCE_DIR)/py-xml
PY-XML_IPK_DIR=$(BUILD_DIR)/py-xml-$(PY-XML_VERSION)-ipk
PY-XML_IPK=$(BUILD_DIR)/py-xml_$(PY-XML_VERSION)-$(PY-XML_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-XML_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-XML_SITE)/$(PY-XML_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-xml-source: $(DL_DIR)/$(PY-XML_SOURCE) $(PY-XML_PATCHES)

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
$(PY-XML_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-XML_SOURCE) $(PY-XML_PATCHES)
	$(MAKE) python-stage
	rm -rf $(BUILD_DIR)/$(PY-XML_DIR) $(PY-XML_BUILD_DIR)
	$(PY-XML_UNZIP) $(DL_DIR)/$(PY-XML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-XML_PATCHES) | patch -d $(BUILD_DIR)/$(PY-XML_DIR) -p1
	mv $(BUILD_DIR)/$(PY-XML_DIR) $(PY-XML_BUILD_DIR)
	(cd $(PY-XML_BUILD_DIR); \
	    ( \
		echo ; \
		echo "[build_ext]"; \
		echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.4"; \
		echo "library-dirs=$(STAGING_LIB_DIR)"; \
		echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python" \
	    ) >> setup.cfg; \
	)
	touch $(PY-XML_BUILD_DIR)/.configured

py-xml-unpack: $(PY-XML_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-XML_BUILD_DIR)/.built: $(PY-XML_BUILD_DIR)/.configured
	rm -f $(PY-XML_BUILD_DIR)/.built
	(cd $(PY-XML_BUILD_DIR); \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            python2.4 setup.py build; \
        )
	touch $(PY-XML_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-xml: $(PY-XML_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-XML_BUILD_DIR)/.staged: $(PY-XML_BUILD_DIR)/.built
	rm -f $(PY-XML_BUILD_DIR)/.staged
	$(MAKE) -C $(PY-XML_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-XML_BUILD_DIR)/.staged

py-xml-stage: $(PY-XML_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-xml
#
$(PY-XML_IPK_DIR)/CONTROL/control:
	@install -d $(PY-XML_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-xml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-XML_PRIORITY)" >>$@
	@echo "Section: $(PY-XML_SECTION)" >>$@
	@echo "Version: $(PY-XML_VERSION)-$(PY-XML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-XML_MAINTAINER)" >>$@
	@echo "Source: $(PY-XML_SITE)/$(PY-XML_SOURCE)" >>$@
	@echo "Description: $(PY-XML_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-XML_DEPENDS)" >>$@
	@echo "Suggests: $(PY-XML_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-XML_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-XML_IPK_DIR)/opt/sbin or $(PY-XML_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-XML_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-XML_IPK_DIR)/opt/etc/py-xml/...
# Documentation files should be installed in $(PY-XML_IPK_DIR)/opt/doc/py-xml/...
# Daemon startup scripts should be installed in $(PY-XML_IPK_DIR)/opt/etc/init.d/S??py-xml
#
# You may need to patch your application to make it use these locations.
#
$(PY-XML_IPK): $(PY-XML_BUILD_DIR)/.built
	rm -rf $(PY-XML_IPK_DIR) $(BUILD_DIR)/py-xml_*_$(TARGET_ARCH).ipk
	(cd $(PY-XML_BUILD_DIR); \
         CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
            python2.4 setup.py install --root=$(PY-XML_IPK_DIR) --prefix=/opt; \
        )
	$(STRIP_COMMAND) `find $(PY-XML_IPK_DIR)/opt/lib/python2.4/site-packages -name '*.so'`
	$(MAKE) $(PY-XML_IPK_DIR)/CONTROL/control
	#install -m 755 $(PY-XML_SOURCE_DIR)/postinst $(PY-XML_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(PY-XML_SOURCE_DIR)/prerm $(PY-XML_IPK_DIR)/CONTROL/prerm
	#echo $(PY-XML_CONFFILES) | sed -e 's/ /\n/g' > $(PY-XML_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-XML_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-xml-ipk: $(PY-XML_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-xml-clean:
	-$(MAKE) -C $(PY-XML_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-xml-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-XML_DIR) $(PY-XML_BUILD_DIR) $(PY-XML_IPK_DIR) $(PY-XML_IPK)
