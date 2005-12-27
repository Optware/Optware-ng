###########################################################
#
# py-simplejson
#
###########################################################

#
# PY-SIMPLEJSON_VERSION, PY-SIMPLEJSON_SITE and PY-SIMPLEJSON_SOURCE define
# the upstream location of the source code for the package.
# PY-SIMPLEJSON_DIR is the directory which is created when the source
# archive is unpacked.
# PY-SIMPLEJSON_UNZIP is the command used to unzip the source.
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
PY-SIMPLEJSON_SITE=http://cheeseshop.python.org/packages/source/s/simple_json
PY-SIMPLEJSON_VERSION=1.0
PY-SIMPLEJSON_SOURCE=simple_json-$(PY-SIMPLEJSON_VERSION).tar.gz
PY-SIMPLEJSON_DIR=simple_json-$(PY-SIMPLEJSON_VERSION)
PY-SIMPLEJSON_UNZIP=zcat
PY-SIMPLEJSON_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
PY-SIMPLEJSON_DESCRIPTION=Simple, fast, extensible JSON encoder/decoder for Python.
PY-SIMPLEJSON_SECTION=misc
PY-SIMPLEJSON_PRIORITY=optional
PY-SIMPLEJSON_DEPENDS=python
PY-SIMPLEJSON_CONFLICTS=

#
# PY-SIMPLEJSON_IPK_VERSION should be incremented when the ipk changes.
#
PY-SIMPLEJSON_IPK_VERSION=1

#
# PY-SIMPLEJSON_CONFFILES should be a list of user-editable files
#PY-SIMPLEJSON_CONFFILES=/opt/etc/py-simplejson.conf /opt/etc/init.d/SXXpy-simplejson

#
# PY-SIMPLEJSON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-SIMPLEJSON_PATCHES=$(PY-SIMPLEJSON_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-SIMPLEJSON_CPPFLAGS=
PY-SIMPLEJSON_LDFLAGS=

#
# PY-SIMPLEJSON_BUILD_DIR is the directory in which the build is done.
# PY-SIMPLEJSON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-SIMPLEJSON_IPK_DIR is the directory in which the ipk is built.
# PY-SIMPLEJSON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-SIMPLEJSON_BUILD_DIR=$(BUILD_DIR)/py-simplejson
PY-SIMPLEJSON_SOURCE_DIR=$(SOURCE_DIR)/py-simplejson
PY-SIMPLEJSON_IPK_DIR=$(BUILD_DIR)/py-simplejson-$(PY-SIMPLEJSON_VERSION)-ipk
PY-SIMPLEJSON_IPK=$(BUILD_DIR)/py-simplejson_$(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-SIMPLEJSON_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-SIMPLEJSON_SITE)/$(PY-SIMPLEJSON_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-simplejson-source: $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) $(PY-SIMPLEJSON_PATCHES)

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
$(PY-SIMPLEJSON_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) $(PY-SIMPLEJSON_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(PY-SIMPLEJSON_BUILD_DIR)
	$(PY-SIMPLEJSON_UNZIP) $(DL_DIR)/$(PY-SIMPLEJSON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-SIMPLEJSON_PATCHES) | patch -d $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) -p1
	mv $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(PY-SIMPLEJSON_BUILD_DIR)
	(cd $(PY-SIMPLEJSON_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-SIMPLEJSON_BUILD_DIR)/.configured

py-simplejson-unpack: $(PY-SIMPLEJSON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-SIMPLEJSON_BUILD_DIR)/.built: $(PY-SIMPLEJSON_BUILD_DIR)/.configured
	rm -f $(PY-SIMPLEJSON_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR)
	touch $(PY-SIMPLEJSON_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-simplejson: $(PY-SIMPLEJSON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-SIMPLEJSON_BUILD_DIR)/.staged: $(PY-SIMPLEJSON_BUILD_DIR)/.built
	rm -f $(PY-SIMPLEJSON_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-SIMPLEJSON_BUILD_DIR)/.staged

py-simplejson-stage: $(PY-SIMPLEJSON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-simplejson
#
$(PY-SIMPLEJSON_IPK_DIR)/CONTROL/control:
	@install -d $(PY-SIMPLEJSON_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-simplejson" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-SIMPLEJSON_PRIORITY)" >>$@
	@echo "Section: $(PY-SIMPLEJSON_SECTION)" >>$@
	@echo "Version: $(PY-SIMPLEJSON_VERSION)-$(PY-SIMPLEJSON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-SIMPLEJSON_MAINTAINER)" >>$@
	@echo "Source: $(PY-SIMPLEJSON_SITE)/$(PY-SIMPLEJSON_SOURCE)" >>$@
	@echo "Description: $(PY-SIMPLEJSON_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-SIMPLEJSON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-SIMPLEJSON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-SIMPLEJSON_IPK_DIR)/opt/sbin or $(PY-SIMPLEJSON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-SIMPLEJSON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/py-simplejson/...
# Documentation files should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/doc/py-simplejson/...
# Daemon startup scripts should be installed in $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/init.d/S??py-simplejson
#
# You may need to patch your application to make it use these locations.
#
$(PY-SIMPLEJSON_IPK): $(PY-SIMPLEJSON_BUILD_DIR)/.built
	rm -rf $(PY-SIMPLEJSON_IPK_DIR) $(BUILD_DIR)/py-simplejson_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR) DESTDIR=$(PY-SIMPLEJSON_IPK_DIR) install
	(cd $(PY-SIMPLEJSON_BUILD_DIR); \
	python2.4 setup.py install --root=$(PY-SIMPLEJSON_IPK_DIR) --prefix=/opt --single-version-externally-managed)
#	install -d $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/
#	install -m 644 $(PY-SIMPLEJSON_SOURCE_DIR)/py-simplejson.conf $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/py-simplejson.conf
#	install -d $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PY-SIMPLEJSON_SOURCE_DIR)/rc.py-simplejson $(PY-SIMPLEJSON_IPK_DIR)/opt/etc/init.d/SXXpy-simplejson
	$(MAKE) $(PY-SIMPLEJSON_IPK_DIR)/CONTROL/control
#	install -m 755 $(PY-SIMPLEJSON_SOURCE_DIR)/postinst $(PY-SIMPLEJSON_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PY-SIMPLEJSON_SOURCE_DIR)/prerm $(PY-SIMPLEJSON_IPK_DIR)/CONTROL/prerm
#	echo $(PY-SIMPLEJSON_CONFFILES) | sed -e 's/ /\n/g' > $(PY-SIMPLEJSON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-SIMPLEJSON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-simplejson-ipk: $(PY-SIMPLEJSON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-simplejson-clean:
	-$(MAKE) -C $(PY-SIMPLEJSON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-simplejson-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-SIMPLEJSON_DIR) $(PY-SIMPLEJSON_BUILD_DIR) $(PY-SIMPLEJSON_IPK_DIR) $(PY-SIMPLEJSON_IPK)
