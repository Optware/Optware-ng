###########################################################
#
# py-wareweb
#
###########################################################

#
# PY-WAREWEB_VERSION, PY-WAREWEB_SITE and PY-WAREWEB_SOURCE define
# the upstream location of the source code for the package.
# PY-WAREWEB_DIR is the directory which is created when the source
# archive is unpacked.
# PY-WAREWEB_UNZIP is the command used to unzip the source.
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
# PY-WAREWEB_IPK_VERSION should be incremented when the ipk changes.
#
PY-WAREWEB_SITE=http://cheeseshop.python.org/packages/source/W/Wareweb
PY-WAREWEB_VERSION=0.3
#PY-WAREWEB_SVN_REV=
PY-WAREWEB_IPK_VERSION=2
#ifneq ($(PY-WAREWEB_SVN_REV),)
#PY-WAREWEB_SVN=http://svn.pythonpaste.org/Paste/Script/trunk
#PY-WAREWEB_xxx_VERSION:=$(PY-WAREWEB_VERSION)dev_r$(PY-WAREWEB_SVN_REV)
#else
PY-WAREWEB_SOURCE=Wareweb-$(PY-WAREWEB_VERSION).tar.gz
#endif
PY-WAREWEB_DIR=Wareweb-$(PY-WAREWEB_VERSION)
PY-WAREWEB_UNZIP=zcat
PY-WAREWEB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-WAREWEB_DESCRIPTION=A web framework, a next generation evolution from Webware/WebKit servlet model.
PY-WAREWEB_SECTION=misc
PY-WAREWEB_PRIORITY=optional
PY-WAREWEB_DEPENDS=python24, py24-paste, py24-pastedeploy, py24-pastescript
PY-WAREWEB_SUGGESTS=
PY-WAREWEB_CONFLICTS=


#
# PY-WAREWEB_CONFFILES should be a list of user-editable files
#PY-WAREWEB_CONFFILES=/opt/etc/py-wareweb.conf /opt/etc/init.d/SXXpy-wareweb

#
# PY-WAREWEB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-WAREWEB_PATCHES=$(PY-WAREWEB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-WAREWEB_CPPFLAGS=
PY-WAREWEB_LDFLAGS=

#
# PY-WAREWEB_BUILD_DIR is the directory in which the build is done.
# PY-WAREWEB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-WAREWEB_IPK_DIR is the directory in which the ipk is built.
# PY-WAREWEB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-WAREWEB_BUILD_DIR=$(BUILD_DIR)/py-wareweb
PY-WAREWEB_SOURCE_DIR=$(SOURCE_DIR)/py-wareweb
PY-WAREWEB_IPK_DIR=$(BUILD_DIR)/py24-wareweb-$(PY-WAREWEB_VERSION)-ipk
PY-WAREWEB_IPK=$(BUILD_DIR)/py24-wareweb_$(PY-WAREWEB_VERSION)-$(PY-WAREWEB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifeq ($(PY-WAREWEB_SVN_REV),)
$(DL_DIR)/$(PY-WAREWEB_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-WAREWEB_SITE)/$(PY-WAREWEB_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-wareweb-source: $(DL_DIR)/$(PY-WAREWEB_SOURCE) $(PY-WAREWEB_PATCHES)

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
$(PY-WAREWEB_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-WAREWEB_SOURCE) $(PY-WAREWEB_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(BUILD_DIR)/$(PY-WAREWEB_DIR) $(PY-WAREWEB_BUILD_DIR)
ifeq ($(PY-WAREWEB_SVN_REV),)
	$(PY-WAREWEB_UNZIP) $(DL_DIR)/$(PY-WAREWEB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	(cd $(BUILD_DIR); \
	    svn co -q -r $(PY-WAREWEB_SVN_REV) $(PY-WAREWEB_SVN) $(PY-WAREWEB_DIR); \
	)
endif
	if test -n "$(PY-WAREWEB_PATCHES)" ; then \
	    cat $(PY-WAREWEB_PATCHES) | patch -d $(BUILD_DIR)/$(PY-WAREWEB_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-WAREWEB_DIR) $(PY-WAREWEB_BUILD_DIR)
	(cd $(PY-WAREWEB_BUILD_DIR); \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python") >> setup.cfg \
	)
	touch $(PY-WAREWEB_BUILD_DIR)/.configured

py-wareweb-unpack: $(PY-WAREWEB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-WAREWEB_BUILD_DIR)/.built: $(PY-WAREWEB_BUILD_DIR)/.configured
	rm -f $(PY-WAREWEB_BUILD_DIR)/.built
#	$(MAKE) -C $(PY-WAREWEB_BUILD_DIR)
	touch $(PY-WAREWEB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-wareweb: $(PY-WAREWEB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-WAREWEB_BUILD_DIR)/.staged: $(PY-WAREWEB_BUILD_DIR)/.built
	rm -f $(PY-WAREWEB_BUILD_DIR)/.staged
#	$(MAKE) -C $(PY-WAREWEB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-WAREWEB_BUILD_DIR)/.staged

py-wareweb-stage: $(PY-WAREWEB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-wareweb
#
$(PY-WAREWEB_IPK_DIR)/CONTROL/control:
	@install -d $(PY-WAREWEB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: py24-wareweb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-WAREWEB_PRIORITY)" >>$@
	@echo "Section: $(PY-WAREWEB_SECTION)" >>$@
	@echo "Version: $(PY-WAREWEB_VERSION)-$(PY-WAREWEB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-WAREWEB_MAINTAINER)" >>$@
	@echo "Source: $(PY-WAREWEB_SITE)/$(PY-WAREWEB_SOURCE)" >>$@
	@echo "Description: $(PY-WAREWEB_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-WAREWEB_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-WAREWEB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-WAREWEB_IPK_DIR)/opt/sbin or $(PY-WAREWEB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-WAREWEB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-WAREWEB_IPK_DIR)/opt/etc/py-wareweb/...
# Documentation files should be installed in $(PY-WAREWEB_IPK_DIR)/opt/doc/py-wareweb/...
# Daemon startup scripts should be installed in $(PY-WAREWEB_IPK_DIR)/opt/etc/init.d/S??py-wareweb
#
# You may need to patch your application to make it use these locations.
#
$(PY-WAREWEB_IPK): $(PY-WAREWEB_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-wareweb_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-WAREWEB_IPK_DIR) $(BUILD_DIR)/py24-wareweb_*_$(TARGET_ARCH).ipk
	(cd $(PY-WAREWEB_BUILD_DIR); \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		python2.4 setup.py install\
		--root=$(PY-WAREWEB_IPK_DIR) --prefix=/opt --single-version-externally-managed)
	$(MAKE) $(PY-WAREWEB_IPK_DIR)/CONTROL/control
#	echo $(PY-WAREWEB_CONFFILES) | sed -e 's/ /\n/g' > $(PY-WAREWEB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-WAREWEB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-wareweb-ipk: $(PY-WAREWEB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-wareweb-clean:
	-$(MAKE) -C $(PY-WAREWEB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-wareweb-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-WAREWEB_DIR) $(PY-WAREWEB_BUILD_DIR) $(PY-WAREWEB_IPK_DIR) $(PY-WAREWEB_IPK)

#
# Some sanity check for the package.
#
py-wareweb-check: $(PY-WAREWEB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY-WAREWEB_IPK)
