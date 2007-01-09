###########################################################
#
# py-tgfastdata
#
###########################################################

#
# PY-TGFASTDATA_VERSION, PY-TGFASTDATA_SITE and PY-TGFASTDATA_SOURCE define
# the upstream location of the source code for the package.
# PY-TGFASTDATA_DIR is the directory which is created when the source
# archive is unpacked.
# PY-TGFASTDATA_UNZIP is the command used to unzip the source.
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
PY-TGFASTDATA_VERSION=0.9a5
PY-TGFASTDATA_SVN_TAG=$(PY-TGFASTDATA_VERSION)
PY-TGFASTDATA_REPOSITORY=http://svn.turbogears.org/projects/FastData/tags/$(PY-TGFASTDATA_SVN_TAG)
PY-TGFASTDATA_DIR=TGFastData-$(PY-TGFASTDATA_VERSION)
PY-TGFASTDATA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-TGFASTDATA_DESCRIPTION=An TurboGears extension that provides automatic user interface generation based upon an application model objects.
PY-TGFASTDATA_SECTION=misc
PY-TGFASTDATA_PRIORITY=optional
PY-TGFASTDATA_DEPENDS=python
PY-TGFASTDATA_CONFLICTS=

#
# PY-TGFASTDATA_IPK_VERSION should be incremented when the ipk changes.
#
PY-TGFASTDATA_IPK_VERSION=3

#
# PY-TGFASTDATA_CONFFILES should be a list of user-editable files
#PY-TGFASTDATA_CONFFILES=/opt/etc/py-tgfastdata.conf /opt/etc/init.d/SXXpy-tgfastdata

#
# PY-TGFASTDATA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-TGFASTDATA_PATCHES=$(PY-TGFASTDATA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-TGFASTDATA_CPPFLAGS=
PY-TGFASTDATA_LDFLAGS=

#
# PY-TGFASTDATA_BUILD_DIR is the directory in which the build is done.
# PY-TGFASTDATA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-TGFASTDATA_IPK_DIR is the directory in which the ipk is built.
# PY-TGFASTDATA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-TGFASTDATA_BUILD_DIR=$(BUILD_DIR)/py-tgfastdata
PY-TGFASTDATA_SOURCE_DIR=$(SOURCE_DIR)/py-tgfastdata
PY-TGFASTDATA_IPK_DIR=$(BUILD_DIR)/py-tgfastdata-$(PY-TGFASTDATA_VERSION)-ipk
PY-TGFASTDATA_IPK=$(BUILD_DIR)/py-tgfastdata_$(PY-TGFASTDATA_VERSION)-$(PY-TGFASTDATA_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-TGFASTDATA_SVN_TAG),)
$(DL_DIR)/$(PY-TGFASTDATA_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-TGFASTDATA_SITE)/$(PY-TGFASTDATA_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-tgfastdata-source: $(PY-TGFASTDATA_PATCHES)

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
$(PY-TGFASTDATA_BUILD_DIR)/.configured: $(PY-TGFASTDATA_PATCHES) make/py-tgfastdata.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-TGFASTDATA_DIR) $(PY-TGFASTDATA_BUILD_DIR)
ifeq ($(PY-TGFASTDATA_SVN_TAG),)
	$(PY-TGFASTDATA_UNZIP) $(DL_DIR)/$(PY-TGFASTDATA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q $(PY-TGFASTDATA_REPOSITORY) $(PY-TGFASTDATA_DIR); \
	)
endif
#	cat $(PY-TGFASTDATA_PATCHES) | patch -d $(BUILD_DIR)/$(PY-TGFASTDATA_DIR) -p1
	mv $(BUILD_DIR)/$(PY-TGFASTDATA_DIR) $(PY-TGFASTDATA_BUILD_DIR)
	(cd $(PY-TGFASTDATA_BUILD_DIR); \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-TGFASTDATA_BUILD_DIR)/.configured

py-tgfastdata-unpack: $(PY-TGFASTDATA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-TGFASTDATA_BUILD_DIR)/.built: $(PY-TGFASTDATA_BUILD_DIR)/.configured
	rm -f $(PY-TGFASTDATA_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-TGFASTDATA_BUILD_DIR)
	touch $(PY-TGFASTDATA_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-tgfastdata: $(PY-TGFASTDATA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-TGFASTDATA_BUILD_DIR)/.staged: $(PY-TGFASTDATA_BUILD_DIR)/.built
	rm -f $(PY-TGFASTDATA_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-TGFASTDATA_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-TGFASTDATA_BUILD_DIR)/.staged

py-tgfastdata-stage: $(PY-TGFASTDATA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-tgfastdata
#
$(PY-TGFASTDATA_IPK_DIR)/CONTROL/control:
	@install -d $(PY-TGFASTDATA_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-tgfastdata" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-TGFASTDATA_PRIORITY)" >>$@
	@echo "Section: $(PY-TGFASTDATA_SECTION)" >>$@
	@echo "Version: $(PY-TGFASTDATA_VERSION)-$(PY-TGFASTDATA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-TGFASTDATA_MAINTAINER)" >>$@
	@echo "Source: $(PY-TGFASTDATA_SITE)/$(PY-TGFASTDATA_SOURCE)" >>$@
	@echo "Description: $(PY-TGFASTDATA_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-TGFASTDATA_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-TGFASTDATA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-TGFASTDATA_IPK_DIR)/opt/sbin or $(PY-TGFASTDATA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-TGFASTDATA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-TGFASTDATA_IPK_DIR)/opt/etc/py-tgfastdata/...
# Documentation files should be installed in $(PY-TGFASTDATA_IPK_DIR)/opt/doc/py-tgfastdata/...
# Daemon startup scripts should be installed in $(PY-TGFASTDATA_IPK_DIR)/opt/etc/init.d/S??py-tgfastdata
#
# You may need to patch your application to make it use these locations.
#
$(PY-TGFASTDATA_IPK): $(PY-TGFASTDATA_BUILD_DIR)/.built
	rm -rf $(PY-TGFASTDATA_IPK_DIR) $(BUILD_DIR)/py-tgfastdata_*_$(TARGET_ARCH).ipk
	(cd $(PY-TGFASTDATA_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	python2.4 setup.py install --root=$(PY-TGFASTDATA_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY-TGFASTDATA_IPK_DIR)/CONTROL/control
	echo $(PY-TGFASTDATA_CONFFILES) | sed -e 's/ /\n/g' > $(PY-TGFASTDATA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-TGFASTDATA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-tgfastdata-ipk: $(PY-TGFASTDATA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-tgfastdata-clean:
	-$(MAKE) -C $(PY-TGFASTDATA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-tgfastdata-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-TGFASTDATA_DIR) $(PY-TGFASTDATA_BUILD_DIR) $(PY-TGFASTDATA_IPK_DIR) $(PY-TGFASTDATA_IPK)
