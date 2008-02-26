###########################################################
#
# py-protocols
#
###########################################################

#
# PY-PROTOCOLS_VERSION, PY-PROTOCOLS_SITE and PY-PROTOCOLS_SOURCE define
# the upstream location of the source code for the package.
# PY-PROTOCOLS_DIR is the directory which is created when the source
# archive is unpacked.
# PY-PROTOCOLS_UNZIP is the command used to unzip the source.
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
# PY-PROTOCOLS_IPK_VERSION should be incremented when the ipk changes.
#
PY-PROTOCOLS_SITE=http://turbogears.org/download/eggs
PY-PROTOCOLS_SVN=svn://svn.eby-sarna.com/svnroot/PyProtocols
PY-PROTOCOLS_SVN_REV=2082
ifneq ($(PY-PROTOCOLS_SVN_REV),)
PY-PROTOCOLS_VERSION=1.0a0dev-r$(PY-PROTOCOLS_SVN_REV)
else
PY-PROTOCOLS_VERSION=1.0a0
endif
PY-PROTOCOLS_SOURCE=PyProtocols-$(PY-PROTOCOLS_VERSION).tar.gz
PY-PROTOCOLS_DIR=PyProtocols-$(PY-PROTOCOLS_VERSION)
PY-PROTOCOLS_UNZIP=zcat
PY-PROTOCOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-PROTOCOLS_DESCRIPTION=Python interface module.
PY-PROTOCOLS_SECTION=misc
PY-PROTOCOLS_PRIORITY=optional
PY24-PROTOCOLS_DEPENDS=python24
PY25-PROTOCOLS_DEPENDS=python25
PY-PROTOCOLS_SUGGESTS=
PY-PROTOCOLS_CONFLICTS=

PY-PROTOCOLS_IPK_VERSION=5

#
# PY-PROTOCOLS_CONFFILES should be a list of user-editable files
#PY-PROTOCOLS_CONFFILES=/opt/etc/py-protocols.conf /opt/etc/init.d/SXXpy-protocols

#
# PY-PROTOCOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-PROTOCOLS_PATCHES=$(PY-PROTOCOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-PROTOCOLS_CPPFLAGS=
PY-PROTOCOLS_LDFLAGS=

#
# PY-PROTOCOLS_BUILD_DIR is the directory in which the build is done.
# PY-PROTOCOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-PROTOCOLS_IPK_DIR is the directory in which the ipk is built.
# PY-PROTOCOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-PROTOCOLS_BUILD_DIR=$(BUILD_DIR)/py-protocols
PY-PROTOCOLS_SOURCE_DIR=$(SOURCE_DIR)/py-protocols

PY24-PROTOCOLS_IPK_DIR=$(BUILD_DIR)/py24-protocols-$(PY-PROTOCOLS_VERSION)-ipk
PY24-PROTOCOLS_IPK=$(BUILD_DIR)/py24-protocols_$(PY-PROTOCOLS_VERSION)-$(PY-PROTOCOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-PROTOCOLS_IPK_DIR=$(BUILD_DIR)/py25-protocols-$(PY-PROTOCOLS_VERSION)-ipk
PY25-PROTOCOLS_IPK=$(BUILD_DIR)/py25-protocols_$(PY-PROTOCOLS_VERSION)-$(PY-PROTOCOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-protocols-source py-protocols-unpack py-protocols py-protocols-stage py-protocols-ipk py-protocols-clean py-protocols-dirclean py-protocols-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-PROTOCOLS_SOURCE):
ifeq ($(PY-PROTOCOLS_SVN_REV),)
	$(WGET) -P $(DL_DIR) $(PY-PROTOCOLS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(PY-PROTOCOLS_DIR) && \
		svn co -q -r $(PY-PROTOCOLS_SVN_REV) $(PY-PROTOCOLS_SVN) $(PY-PROTOCOLS_DIR) && \
		tar -czf $@ $(PY-PROTOCOLS_DIR) && \
		rm -rf $(PY-PROTOCOLS_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-protocols-source: $(DL_DIR)/$(PY-PROTOCOLS_SOURCE) $(PY-PROTOCOLS_PATCHES)

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
$(PY-PROTOCOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-PROTOCOLS_SOURCE) $(PY-PROTOCOLS_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(PY-PROTOCOLS_BUILD_DIR)
	mkdir -p $(PY-PROTOCOLS_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-PROTOCOLS_DIR)
	$(PY-PROTOCOLS_UNZIP) $(DL_DIR)/$(PY-PROTOCOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PROTOCOLS_PATCHES)" ; then \
	    cat $(PY-PROTOCOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PROTOCOLS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PROTOCOLS_DIR) $(PY-PROTOCOLS_BUILD_DIR)/2.4
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.4") >> setup.cfg \
	)
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-PROTOCOLS_DIR)
	$(PY-PROTOCOLS_UNZIP) $(DL_DIR)/$(PY-PROTOCOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-PROTOCOLS_PATCHES)" ; then \
	    cat $(PY-PROTOCOLS_PATCHES) | patch -d $(BUILD_DIR)/$(PY-PROTOCOLS_DIR) -p0 ; \
        fi
	mv $(BUILD_DIR)/$(PY-PROTOCOLS_DIR) $(PY-PROTOCOLS_BUILD_DIR)/2.5
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; echo "executable=/opt/bin/python2.5") >> setup.cfg \
	)
	touch $@

py-protocols-unpack: $(PY-PROTOCOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-PROTOCOLS_BUILD_DIR)/.built: $(PY-PROTOCOLS_BUILD_DIR)/.configured
	rm -f $@
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py --without-speedups build)
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py --without-speedups build)
	touch $@

#
# This is the build convenience target.
#
py-protocols: $(PY-PROTOCOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-PROTOCOLS_BUILD_DIR)/.staged: $(PY-PROTOCOLS_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-PROTOCOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-protocols-stage: $(PY-PROTOCOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-protocols
#
$(PY24-PROTOCOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-protocols" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PROTOCOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-PROTOCOLS_SECTION)" >>$@
	@echo "Version: $(PY-PROTOCOLS_VERSION)-$(PY-PROTOCOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PROTOCOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-PROTOCOLS_SITE)/$(PY-PROTOCOLS_SOURCE)" >>$@
	@echo "Description: $(PY-PROTOCOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-PROTOCOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PROTOCOLS_CONFLICTS)" >>$@

$(PY25-PROTOCOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-protocols" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-PROTOCOLS_PRIORITY)" >>$@
	@echo "Section: $(PY-PROTOCOLS_SECTION)" >>$@
	@echo "Version: $(PY-PROTOCOLS_VERSION)-$(PY-PROTOCOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-PROTOCOLS_MAINTAINER)" >>$@
	@echo "Source: $(PY-PROTOCOLS_SITE)/$(PY-PROTOCOLS_SOURCE)" >>$@
	@echo "Description: $(PY-PROTOCOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-PROTOCOLS_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-PROTOCOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-PROTOCOLS_IPK_DIR)/opt/sbin or $(PY-PROTOCOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-PROTOCOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-PROTOCOLS_IPK_DIR)/opt/etc/py-protocols/...
# Documentation files should be installed in $(PY-PROTOCOLS_IPK_DIR)/opt/doc/py-protocols/...
# Daemon startup scripts should be installed in $(PY-PROTOCOLS_IPK_DIR)/opt/etc/init.d/S??py-protocols
#
# You may need to patch your application to make it use these locations.
#
$(PY24-PROTOCOLS_IPK): $(PY-PROTOCOLS_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/py-protocols_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-PROTOCOLS_IPK_DIR) $(BUILD_DIR)/py24-protocols_*_$(TARGET_ARCH).ipk
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py --without-speedups install \
		--root=$(PY24-PROTOCOLS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY24-PROTOCOLS_IPK_DIR)/CONTROL/control
#	echo $(PY-PROTOCOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-PROTOCOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-PROTOCOLS_IPK_DIR)

$(PY25-PROTOCOLS_IPK): $(PY-PROTOCOLS_BUILD_DIR)/.built
	rm -rf $(PY25-PROTOCOLS_IPK_DIR) $(BUILD_DIR)/py25-protocols_*_$(TARGET_ARCH).ipk
	(cd $(PY-PROTOCOLS_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
		$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py --without-speedups install \
		--root=$(PY25-PROTOCOLS_IPK_DIR) --prefix=/opt)
	$(MAKE) $(PY25-PROTOCOLS_IPK_DIR)/CONTROL/control
#	echo $(PY-PROTOCOLS_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-PROTOCOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-PROTOCOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-protocols-ipk: $(PY24-PROTOCOLS_IPK) $(PY25-PROTOCOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-protocols-clean:
	-$(MAKE) -C $(PY-PROTOCOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-protocols-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-PROTOCOLS_DIR) $(PY-PROTOCOLS_BUILD_DIR)
	rm -rf $(PY24-PROTOCOLS_IPK_DIR) $(PY24-PROTOCOLS_IPK)
	rm -rf $(PY25-PROTOCOLS_IPK_DIR) $(PY25-PROTOCOLS_IPK)

#
# Some sanity check for the package.
#
py-protocols-check: $(PY24-PROTOCOLS_IPK) $(PY25-PROTOCOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-PROTOCOLS_IPK) $(PY25-PROTOCOLS_IPK)
