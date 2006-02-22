###########################################################
#
# py-ruledispatch
#
###########################################################

#
# PY-RULEDISPATCH_VERSION, PY-RULEDISPATCH_SITE and PY-RULEDISPATCH_SOURCE define
# the upstream location of the source code for the package.
# PY-RULEDISPATCH_DIR is the directory which is created when the source
# archive is unpacked.
# PY-RULEDISPATCH_UNZIP is the command used to unzip the source.
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
# PY-RULEDISPATCH_IPK_VERSION should be incremented when the ipk changes.
#
PY-RULEDISPATCH_SITE=http://turbogears.org/download/eggs
#RuleDispatch-0.5a0dev_r2097.zip
PY-RULEDISPATCH_SVN=svn://svn.eby-sarna.com/svnroot/RuleDispatch
PY-RULEDISPATCH_VERSION=0.5a
PY-RULEDISPATCH_SVN_REV=2097
PY-RULEDISPATCH_IPK_VERSION=1
ifneq ($(PY-RULEDISPATCH_SVN_REV),)
PY-RULEDISPATCH_VERSION:=$(PY-RULEDISPATCH_VERSION)dev_r$(PY-RULEDISPATCH_SVN_REV)
else
PY-RULEDISPATCH_SOURCE=RuleDispatch-$(PY-RULEDISPATCH_VERSION).zip
endif
PY-RULEDISPATCH_DIR=RuleDispatch-$(PY-RULEDISPATCH_VERSION)
PY-RULEDISPATCH_UNZIP=zcat
PY-RULEDISPATCH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-RULEDISPATCH_DESCRIPTION=Python module for rule-based dispatching and generic functions.
PY-RULEDISPATCH_SECTION=misc
PY-RULEDISPATCH_PRIORITY=optional
PY-RULEDISPATCH_DEPENDS=python
PY-RULEDISPATCH_SUGGESTS=
PY-RULEDISPATCH_CONFLICTS=


#
# PY-RULEDISPATCH_CONFFILES should be a list of user-editable files
#PY-RULEDISPATCH_CONFFILES=/opt/etc/py-ruledispatch.conf /opt/etc/init.d/SXXpy-ruledispatch

#
# PY-RULEDISPATCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-RULEDISPATCH_PATCHES=$(PY-RULEDISPATCH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-RULEDISPATCH_CPPFLAGS=
PY-RULEDISPATCH_LDFLAGS=

#
# PY-RULEDISPATCH_BUILD_DIR is the directory in which the build is done.
# PY-RULEDISPATCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-RULEDISPATCH_IPK_DIR is the directory in which the ipk is built.
# PY-RULEDISPATCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-RULEDISPATCH_BUILD_DIR=$(BUILD_DIR)/py-ruledispatch
PY-RULEDISPATCH_SOURCE_DIR=$(SOURCE_DIR)/py-ruledispatch
PY-RULEDISPATCH_IPK_DIR=$(BUILD_DIR)/py-ruledispatch-$(PY-RULEDISPATCH_VERSION)-ipk
PY-RULEDISPATCH_IPK=$(BUILD_DIR)/py-ruledispatch_$(PY-RULEDISPATCH_VERSION)-$(PY-RULEDISPATCH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-RULEDISPATCH_SVN_REV),)
$(DL_DIR)/$(PY-RULEDISPATCH_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-RULEDISPATCH_SITE)/$(PY-RULEDISPATCH_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-ruledispatch-source: $(DL_DIR)/$(PY-RULEDISPATCH_SOURCE) $(PY-RULEDISPATCH_PATCHES)

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
$(PY-RULEDISPATCH_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-RULEDISPATCH_SOURCE) $(PY-RULEDISPATCH_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-RULEDISPATCH_DIR) $(PY-RULEDISPATCH_BUILD_DIR)
ifeq ($(PY-RULEDISPATCH_SVN_REV),)
	$(PY-RULEDISPATCH_UNZIP) $(DL_DIR)/$(PY-RULEDISPATCH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-RULEDISPATCH_SVN_REV) $(PY-RULEDISPATCH_SVN) $(PY-RULEDISPATCH_DIR); \
	)
endif
	if test -n "$(PY-RULEDISPATCH_PATCHES)" ; then \
	    cat $(PY-RULEDISPATCH_PATCHES) | patch -d $(BUILD_DIR)/$(PY-RULEDISPATCH_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-RULEDISPATCH_DIR) $(PY-RULEDISPATCH_BUILD_DIR)
	(cd $(PY-RULEDISPATCH_BUILD_DIR); \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-RULEDISPATCH_BUILD_DIR)/.configured

py-ruledispatch-unpack: $(PY-RULEDISPATCH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-RULEDISPATCH_BUILD_DIR)/.built: $(PY-RULEDISPATCH_BUILD_DIR)/.configured
	rm -f $(PY-RULEDISPATCH_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-RULEDISPATCH_BUILD_DIR)
	touch $(PY-RULEDISPATCH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-ruledispatch: $(PY-RULEDISPATCH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-RULEDISPATCH_BUILD_DIR)/.staged: $(PY-RULEDISPATCH_BUILD_DIR)/.built
	rm -f $(PY-RULEDISPATCH_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-RULEDISPATCH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-RULEDISPATCH_BUILD_DIR)/.staged

py-ruledispatch-stage: $(PY-RULEDISPATCH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-ruledispatch
#
$(PY-RULEDISPATCH_IPK_DIR)/CONTROL/control:
	@install -d $(PY-RULEDISPATCH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py-ruledispatch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-RULEDISPATCH_PRIORITY)" >>$@
	@echo "Section: $(PY-RULEDISPATCH_SECTION)" >>$@
	@echo "Version: $(PY-RULEDISPATCH_VERSION)-$(PY-RULEDISPATCH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-RULEDISPATCH_MAINTAINER)" >>$@
	@echo "Source: $(PY-RULEDISPATCH_SITE)/$(PY-RULEDISPATCH_SOURCE)" >>$@
	@echo "Description: $(PY-RULEDISPATCH_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-RULEDISPATCH_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-RULEDISPATCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-RULEDISPATCH_IPK_DIR)/opt/sbin or $(PY-RULEDISPATCH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-RULEDISPATCH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-RULEDISPATCH_IPK_DIR)/opt/etc/py-ruledispatch/...
# Documentation files should be installed in $(PY-RULEDISPATCH_IPK_DIR)/opt/doc/py-ruledispatch/...
# Daemon startup scripts should be installed in $(PY-RULEDISPATCH_IPK_DIR)/opt/etc/init.d/S??py-ruledispatch
#
# You may need to patch your application to make it use these locations.
#
$(PY-RULEDISPATCH_IPK): $(PY-RULEDISPATCH_BUILD_DIR)/.built
	rm -rf $(PY-RULEDISPATCH_IPK_DIR) $(BUILD_DIR)/py-ruledispatch_*_$(TARGET_ARCH).ipk
	(cd $(PY-RULEDISPATCH_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		python2.4 setup.py --without-speedups install \
		--root=$(PY-RULEDISPATCH_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-RULEDISPATCH_IPK_DIR)/CONTROL/control
#	echo $(PY-RULEDISPATCH_CONFFILES) | sed -e 's/ /\n/g' > $(PY-RULEDISPATCH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-RULEDISPATCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-ruledispatch-ipk: $(PY-RULEDISPATCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-ruledispatch-clean:
	-$(MAKE) -C $(PY-RULEDISPATCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-ruledispatch-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-RULEDISPATCH_DIR) $(PY-RULEDISPATCH_BUILD_DIR) $(PY-RULEDISPATCH_IPK_DIR) $(PY-RULEDISPATCH_IPK)
