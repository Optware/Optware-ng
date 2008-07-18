##########################################################
#
# py-feedparser
#
###########################################################

#
# PY-FEEDPARSER_VERSION, PY-FEEDPARSER_SITE and PY-FEEDPARSER_SOURCE define
# the upstream location of the source code for the package.
# PY-FEEDPARSER_DIR is the directory which is created when the source
# archive is unpacked.
# PY-FEEDPARSER_UNZIP is the command used to unzip the source.
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
PY-FEEDPARSER_SITE=http://pypi.python.org/packages/source/F/FeedParser
PY-FEEDPARSER_VERSION=4.1
PY-FEEDPARSER_SOURCE=feedparser-$(PY-FEEDPARSER_VERSION).tar.gz
PY-FEEDPARSER_DIR=feedparser-$(PY-FEEDPARSER_VERSION)
PY-FEEDPARSER_UNZIP=zcat
PY-FEEDPARSER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-FEEDPARSER_DESCRIPTION=Parse RSS and Atom feeds in Python.
PY-FEEDPARSER_SECTION=web
PY-FEEDPARSER_PRIORITY=optional
PY24-FEEDPARSER_DEPENDS=python24
PY25-FEEDPARSER_DEPENDS=python25
PY-FEEDPARSER_CONFLICTS=

#
# PY-FEEDPARSER_IPK_VERSION should be incremented when the ipk changes.
#
PY-FEEDPARSER_IPK_VERSION=1

#
# PY-FEEDPARSER_CONFFILES should be a list of user-editable files
#PY-FEEDPARSER_CONFFILES=/opt/etc/py-feedparser.conf /opt/etc/init.d/SXXpy-feedparser

#
# PY-FEEDPARSER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-FEEDPARSER_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-FEEDPARSER_CPPFLAGS=
PY-FEEDPARSER_LDFLAGS=

#
# PY-FEEDPARSER_BUILD_DIR is the directory in which the build is done.
# PY-FEEDPARSER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-FEEDPARSER_IPK_DIR is the directory in which the ipk is built.
# PY-FEEDPARSER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-FEEDPARSER_BUILD_DIR=$(BUILD_DIR)/py-feedparser
PY-FEEDPARSER_SOURCE_DIR=$(SOURCE_DIR)/py-feedparser

PY24-FEEDPARSER_IPK_DIR=$(BUILD_DIR)/py24-feedparser-$(PY-FEEDPARSER_VERSION)-ipk
PY24-FEEDPARSER_IPK=$(BUILD_DIR)/py24-feedparser_$(PY-FEEDPARSER_VERSION)-$(PY-FEEDPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-FEEDPARSER_IPK_DIR=$(BUILD_DIR)/py25-feedparser-$(PY-FEEDPARSER_VERSION)-ipk
PY25-FEEDPARSER_IPK=$(BUILD_DIR)/py25-feedparser_$(PY-FEEDPARSER_VERSION)-$(PY-FEEDPARSER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-feedparser-source py-feedparser-unpack py-feedparser py-feedparser-stage py-feedparser-ipk py-feedparser-clean py-feedparser-dirclean py-feedparser-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-FEEDPARSER_SOURCE):
	$(WGET) -P $(@D) $(PY-FEEDPARSER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-feedparser-source: $(DL_DIR)/$(PY-FEEDPARSER_SOURCE) $(PY-FEEDPARSER_PATCHES)

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
$(PY-FEEDPARSER_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-FEEDPARSER_SOURCE) $(PY-FEEDPARSER_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-FEEDPARSER_DIR)
	$(PY-FEEDPARSER_UNZIP) $(DL_DIR)/$(PY-FEEDPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-FEEDPARSER_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FEEDPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-FEEDPARSER_DIR) $(@D)/2.4
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.4") >> $(@D)/2.4/setup.cfg
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-FEEDPARSER_DIR)
	$(PY-FEEDPARSER_UNZIP) $(DL_DIR)/$(PY-FEEDPARSER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-FEEDPARSER_PATCHES) | patch -d $(BUILD_DIR)/$(PY-FEEDPARSER_DIR) -p1
	mv $(BUILD_DIR)/$(PY-FEEDPARSER_DIR) $(@D)/2.5
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.5") >> $(@D)/2.4/setup.cfg
	touch $@

py-feedparser-unpack: $(PY-FEEDPARSER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-FEEDPARSER_BUILD_DIR)/.built: $(PY-FEEDPARSER_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build;
	cd $(@D)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build;
	touch $@

#
# This is the build convenience target.
#
py-feedparser: $(PY-FEEDPARSER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(PY-FEEDPARSER_BUILD_DIR)/.staged: $(PY-FEEDPARSER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-FEEDPARSER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

#py-feedparser-stage: $(PY-FEEDPARSER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-feedparser
#
$(PY24-FEEDPARSER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-feedparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FEEDPARSER_PRIORITY)" >>$@
	@echo "Section: $(PY-FEEDPARSER_SECTION)" >>$@
	@echo "Version: $(PY-FEEDPARSER_VERSION)-$(PY-FEEDPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FEEDPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PY-FEEDPARSER_SITE)/$(PY-FEEDPARSER_SOURCE)" >>$@
	@echo "Description: $(PY-FEEDPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-FEEDPARSER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FEEDPARSER_CONFLICTS)" >>$@

$(PY25-FEEDPARSER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-feedparser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-FEEDPARSER_PRIORITY)" >>$@
	@echo "Section: $(PY-FEEDPARSER_SECTION)" >>$@
	@echo "Version: $(PY-FEEDPARSER_VERSION)-$(PY-FEEDPARSER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-FEEDPARSER_MAINTAINER)" >>$@
	@echo "Source: $(PY-FEEDPARSER_SITE)/$(PY-FEEDPARSER_SOURCE)" >>$@
	@echo "Description: $(PY-FEEDPARSER_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-FEEDPARSER_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-FEEDPARSER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-FEEDPARSER_IPK_DIR)/opt/sbin or $(PY-FEEDPARSER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-FEEDPARSER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-FEEDPARSER_IPK_DIR)/opt/etc/py-feedparser/...
# Documentation files should be installed in $(PY-FEEDPARSER_IPK_DIR)/opt/doc/py-feedparser/...
# Daemon startup scripts should be installed in $(PY-FEEDPARSER_IPK_DIR)/opt/etc/init.d/S??py-feedparser
#
# You may need to patch your application to make it use these locations.
#
$(PY24-FEEDPARSER_IPK): $(PY-FEEDPARSER_BUILD_DIR)/.built
	rm -rf $(PY24-FEEDPARSER_IPK_DIR) $(BUILD_DIR)/py24-feedparser_*_$(TARGET_ARCH).ipk
	cd $(PY-FEEDPARSER_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-FEEDPARSER_IPK_DIR) --prefix=/opt;
#	for f in $(PY24-FEEDPARSER_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	$(MAKE) $(PY24-FEEDPARSER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-FEEDPARSER_IPK_DIR)

$(PY25-FEEDPARSER_IPK): $(PY-FEEDPARSER_BUILD_DIR)/.built
	rm -rf $(PY25-FEEDPARSER_IPK_DIR) $(BUILD_DIR)/py25-feedparser_*_$(TARGET_ARCH).ipk
	cd $(PY-FEEDPARSER_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-FEEDPARSER_IPK_DIR) --prefix=/opt;
#	cd $(PY25-FEEDPARSER_IPK_DIR)/opt/share/feedparser
	$(MAKE) $(PY25-FEEDPARSER_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-FEEDPARSER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-feedparser-ipk: $(PY24-FEEDPARSER_IPK) $(PY25-FEEDPARSER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-feedparser-clean:
	-$(MAKE) -C $(PY-FEEDPARSER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-feedparser-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-FEEDPARSER_DIR) $(PY-FEEDPARSER_BUILD_DIR)
	rm -rf $(PY24-FEEDPARSER_IPK_DIR) $(PY24-FEEDPARSER_IPK)
	rm -rf $(PY25-FEEDPARSER_IPK_DIR) $(PY25-FEEDPARSER_IPK)

#
# Some sanity check for the package.
#
py-feedparser-check: $(PY24-FEEDPARSER_IPK) $(PY25-FEEDPARSER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-FEEDPARSER_IPK) $(PY25-FEEDPARSER_IPK)
