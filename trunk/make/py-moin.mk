###########################################################
#
# py-moin
#
###########################################################

#
# PY-MOIN_VERSION, PY-MOIN_SITE and PY-MOIN_SOURCE define
# the upstream location of the source code for the package.
# PY-MOIN_DIR is the directory which is created when the source
# archive is unpacked.
# PY-MOIN_UNZIP is the command used to unzip the source.
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
PY-MOIN_SITE=http://static.moinmo.in/files
PY-MOIN_VERSION=1.7.0
PY-MOIN_SOURCE=moin-$(PY-MOIN_VERSION).tar.gz
PY-MOIN_DIR=moin-$(PY-MOIN_VERSION)
PY-MOIN_UNZIP=zcat
PY-MOIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-MOIN_DESCRIPTION=MoinMoin is a nice and easy WikiEngine with advanced features, providing collaboration on easily editable web pages.
PY-MOIN_SECTION=web
PY-MOIN_PRIORITY=optional
PY24-MOIN_DEPENDS=python24, coreutils, sed, tar
PY25-MOIN_DEPENDS=python25, coreutils, sed, tar
PY-MOIN_CONFLICTS=

#
# PY-MOIN_IPK_VERSION should be incremented when the ipk changes.
#
PY-MOIN_IPK_VERSION=1

#
# PY-MOIN_CONFFILES should be a list of user-editable files
#PY-MOIN_CONFFILES=/opt/etc/py-moin.conf /opt/etc/init.d/SXXpy-moin

#
# PY-MOIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-MOIN_PATCHES=\
$(PY-MOIN_SOURCE_DIR)/setup.py.patch \
$(PY-MOIN_SOURCE_DIR)/wikiserverconfig.py.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-MOIN_CPPFLAGS=
PY-MOIN_LDFLAGS=

#
# PY-MOIN_BUILD_DIR is the directory in which the build is done.
# PY-MOIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-MOIN_IPK_DIR is the directory in which the ipk is built.
# PY-MOIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-MOIN_BUILD_DIR=$(BUILD_DIR)/py-moin
PY-MOIN_SOURCE_DIR=$(SOURCE_DIR)/py-moin

PY-MOIN-COMMON_IPK_DIR=$(BUILD_DIR)/py-moin-common-$(PY-MOIN_VERSION)-ipk
PY-MOIN-COMMON_IPK=$(BUILD_DIR)/py-moin-common_$(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-MOIN_IPK_DIR=$(BUILD_DIR)/py24-moin-$(PY-MOIN_VERSION)-ipk
PY24-MOIN_IPK=$(BUILD_DIR)/py24-moin_$(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-MOIN_IPK_DIR=$(BUILD_DIR)/py25-moin-$(PY-MOIN_VERSION)-ipk
PY25-MOIN_IPK=$(BUILD_DIR)/py25-moin_$(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-moin-source py-moin-unpack py-moin py-moin-stage py-moin-ipk py-moin-clean py-moin-dirclean py-moin-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-MOIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-MOIN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-moin-source: $(DL_DIR)/$(PY-MOIN_SOURCE) $(PY-MOIN_PATCHES)

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
$(PY-MOIN_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-MOIN_SOURCE) $(PY-MOIN_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-MOIN_DIR)
	$(PY-MOIN_UNZIP) $(DL_DIR)/$(PY-MOIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-MOIN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MOIN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MOIN_DIR) $(@D)/2.4
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.4") >> $(@D)/2.4/setup.cfg
	# 2.5
	rm -rf $(BUILD_DIR)/$(PY-MOIN_DIR)
	$(PY-MOIN_UNZIP) $(DL_DIR)/$(PY-MOIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PY-MOIN_PATCHES) | patch -d $(BUILD_DIR)/$(PY-MOIN_DIR) -p1
	mv $(BUILD_DIR)/$(PY-MOIN_DIR) $(@D)/2.5
	(echo "[build_scripts]"; \
         echo "executable=/opt/bin/python2.5") >> $(@D)/2.5/setup.cfg
	touch $@

py-moin-unpack: $(PY-MOIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-MOIN_BUILD_DIR)/.built: $(PY-MOIN_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build;
	cd $(@D)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build;
	touch $@

#
# This is the build convenience target.
#
py-moin: $(PY-MOIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-MOIN_BUILD_DIR)/.staged: $(PY-MOIN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-MOIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

py-moin-stage: $(PY-MOIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-moin
#
$(PY-MOIN-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-moin-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MOIN_PRIORITY)" >>$@
	@echo "Section: $(PY-MOIN_SECTION)" >>$@
	@echo "Version: $(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MOIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MOIN_SITE)/$(PY-MOIN_SOURCE)" >>$@
	@echo "Description: $(PY-MOIN_DESCRIPTION)" >>$@
	@echo "Depends: $(PY-MOIN-COMMON_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MOIN_CONFLICTS)" >>$@

$(PY24-MOIN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-moin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MOIN_PRIORITY)" >>$@
	@echo "Section: $(PY-MOIN_SECTION)" >>$@
	@echo "Version: $(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MOIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MOIN_SITE)/$(PY-MOIN_SOURCE)" >>$@
	@echo "Description: $(PY-MOIN_DESCRIPTION)" >>$@
	@echo "Depends: py-moin-common, $(PY24-MOIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MOIN_CONFLICTS)" >>$@

$(PY25-MOIN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-moin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-MOIN_PRIORITY)" >>$@
	@echo "Section: $(PY-MOIN_SECTION)" >>$@
	@echo "Version: $(PY-MOIN_VERSION)-$(PY-MOIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-MOIN_MAINTAINER)" >>$@
	@echo "Source: $(PY-MOIN_SITE)/$(PY-MOIN_SOURCE)" >>$@
	@echo "Description: $(PY-MOIN_DESCRIPTION)" >>$@
	@echo "Depends: py-moin-common, $(PY25-MOIN_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-MOIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-MOIN_IPK_DIR)/opt/sbin or $(PY-MOIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-MOIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-MOIN_IPK_DIR)/opt/etc/py-moin/...
# Documentation files should be installed in $(PY-MOIN_IPK_DIR)/opt/doc/py-moin/...
# Daemon startup scripts should be installed in $(PY-MOIN_IPK_DIR)/opt/etc/init.d/S??py-moin
#
# You may need to patch your application to make it use these locations.
#
$(PY24-MOIN_IPK): $(PY-MOIN_BUILD_DIR)/.built
	rm -rf $(PY24-MOIN_IPK_DIR) $(BUILD_DIR)/py24-moin_*_$(TARGET_ARCH).ipk
	cd $(PY-MOIN_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-MOIN_IPK_DIR) --prefix=/opt;
	for f in $(PY24-MOIN_IPK_DIR)/opt/bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-2.4|'`; done
	rm -rf $(PY24-MOIN_IPK_DIR)/opt/share/
	sed -e 's|python2.[4-9]|python2.4|' $(PY-MOIN_SOURCE_DIR)/createinstance.sh \
		> $(PY24-MOIN_IPK_DIR)/opt/bin/py24-moin-createinstance.sh
	chmod 755 $(PY24-MOIN_IPK_DIR)/opt/bin/py24-moin-createinstance.sh
	$(MAKE) $(PY24-MOIN_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-MOIN_IPK_DIR)

$(PY25-MOIN_IPK) $(PY-MOIN-COMMON_IPK): $(PY-MOIN_BUILD_DIR)/.built
	rm -rf $(PY25-MOIN_IPK_DIR) $(BUILD_DIR)/py25-moin_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-MOIN-COMMON_IPK_DIR) $(BUILD_DIR)/py-moin*_*_$(TARGET_ARCH).ipk
	cd $(PY-MOIN_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-MOIN_IPK_DIR) --prefix=/opt;
	cd $(PY25-MOIN_IPK_DIR)/opt/share/moin; \
	    tar --remove-files -cvzf underlay.tar.gz underlay; \
	    rm -rf underlay
	sed -e 's|python2.[4-9]|python2.5|' $(PY-MOIN_SOURCE_DIR)/createinstance.sh \
		> $(PY25-MOIN_IPK_DIR)/opt/bin/py25-moin-createinstance.sh
	chmod 755 $(PY25-MOIN_IPK_DIR)/opt/bin/py25-moin-createinstance.sh
	$(MAKE) $(PY25-MOIN_IPK_DIR)/CONTROL/control
	$(MAKE) $(PY-MOIN-COMMON_IPK_DIR)/CONTROL/control
	install -d $(PY-MOIN-COMMON_IPK_DIR)/opt/
	mv $(PY25-MOIN_IPK_DIR)/opt/share $(PY-MOIN-COMMON_IPK_DIR)/opt/
	chmod o+r $(PY-MOIN-COMMON_IPK_DIR)/opt/share/moin/data/*-log
	for f in wikiserver.py wikiserverconfig.py wikiserverlogging.conf; \
	do install $(PY-MOIN_BUILD_DIR)/2.5/$${f} $(PY-MOIN-COMMON_IPK_DIR)/opt/share/moin/$${f}; done
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-MOIN-COMMON_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-MOIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-moin-ipk: $(PY24-MOIN_IPK) $(PY25-MOIN_IPK) $(PY-MOIN-COMMON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-moin-clean:
	-$(MAKE) -C $(PY-MOIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-moin-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-MOIN_DIR) $(PY-MOIN_BUILD_DIR)
	rm -rf $(PY-MOIN-COMMON_IPK_DIR) $(PY-MOIN-COMMON_IPK)
	rm -rf $(PY24-MOIN_IPK_DIR) $(PY24-MOIN_IPK)
	rm -rf $(PY25-MOIN_IPK_DIR) $(PY25-MOIN_IPK)

#
# Some sanity check for the package.
#
py-moin-check: $(PY24-MOIN_IPK) $(PY25-MOIN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-MOIN_IPK) $(PY25-MOIN_IPK) $(PY-MOIN-COMMON_IPK)
