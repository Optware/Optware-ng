###########################################################
#
# py-bittorrent
#
###########################################################

# You must replace "py-bittorrent" and "PY-BITTORRENT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PY-BITTORRENT_VERSION, PY-BITTORRENT_SITE and PY-BITTORRENT_SOURCE define
# the upstream location of the source code for the package.
# PY-BITTORRENT_DIR is the directory which is created when the source
# archive is unpacked.
# PY-BITTORRENT_UNZIP is the command used to unzip the source.
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
PY-BITTORRENT_SITE=http://download.bittorrent.com/dl
PY-BITTORRENT_VERSION=5.0.4
PY-BITTORRENT_SOURCE=BitTorrent-$(PY-BITTORRENT_VERSION).tar.gz
PY-BITTORRENT_DIR=BitTorrent-$(PY-BITTORRENT_VERSION)
PY-BITTORRENT_UNZIP=zcat
PY-BITTORRENT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-BITTORRENT_DESCRIPTION=BitTorrent is a scatter-gather network file transfer tool.
PY-BITTORRENT_SECTION=misc
PY-BITTORRENT_PRIORITY=optional
PY24-BITTORRENT_DEPENDS=py-twisted, py-crypto
PY25-BITTORRENT_DEPENDS=py25-twisted, py25-crypto
PY-BITTORRENT_CONFLICTS=

#
# PY-BITTORRENT_IPK_VERSION should be incremented when the ipk changes.
#
PY-BITTORRENT_IPK_VERSION=1

#
# PY-BITTORRENT_CONFFILES should be a list of user-editable files
#PY-BITTORRENT_CONFFILES=/opt/etc/py-bittorrent.conf /opt/etc/init.d/SXXpy-bittorrent

#
# PY-BITTORRENT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PY-BITTORRENT_PATCHES=\
$(PY-BITTORRENT_SOURCE_DIR)/BitTorrent-platform.py.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-BITTORRENT_CPPFLAGS=
PY-BITTORRENT_LDFLAGS=

#
# PY-BITTORRENT_BUILD_DIR is the directory in which the build is done.
# PY-BITTORRENT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-BITTORRENT_IPK_DIR is the directory in which the ipk is built.
# PY-BITTORRENT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-BITTORRENT_BUILD_DIR=$(BUILD_DIR)/py-bittorrent
PY-BITTORRENT_SOURCE_DIR=$(SOURCE_DIR)/py-bittorrent

PY-BITTORRENT-COMMON_IPK_DIR=$(BUILD_DIR)/py-bittorrent-common-$(PY-BITTORRENT_VERSION)-ipk
PY-BITTORRENT-COMMON_IPK=$(BUILD_DIR)/py-bittorrent-common_$(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-BITTORRENT_IPK_DIR=$(BUILD_DIR)/py-bittorrent-$(PY-BITTORRENT_VERSION)-ipk
PY24-BITTORRENT_IPK=$(BUILD_DIR)/py-bittorrent_$(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-BITTORRENT_IPK_DIR=$(BUILD_DIR)/py25-bittorrent-$(PY-BITTORRENT_VERSION)-ipk
PY25-BITTORRENT_IPK=$(BUILD_DIR)/py25-bittorrent_$(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: py-bittorrent-source py-bittorrent-unpack py-bittorrent py-bittorrent-stage py-bittorrent-ipk py-bittorrent-clean py-bittorrent-dirclean py-bittorrent-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-BITTORRENT_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-BITTORRENT_SITE)/$(PY-BITTORRENT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
py-bittorrent-source: $(DL_DIR)/$(PY-BITTORRENT_SOURCE) $(PY-BITTORRENT_PATCHES)

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
$(PY-BITTORRENT_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-BITTORRENT_SOURCE) $(PY-BITTORRENT_PATCHES)
	$(MAKE) py-twisted-stage
	rm -rf $(BUILD_DIR)/$(PY-BITTORRENT_DIR) $(PY-BITTORRENT_BUILD_DIR)
	mkdir -p $(PY-BITTORRENT_BUILD_DIR)
	$(PY-BITTORRENT_UNZIP) $(DL_DIR)/$(PY-BITTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BITTORRENT_PATCHES)"; then \
		cat $(PY-BITTORRENT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BITTORRENT_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PY-BITTORRENT_DIR) $(PY-BITTORRENT_BUILD_DIR)/2.4
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.4; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.4") > setup.cfg \
	)
	$(PY-BITTORRENT_UNZIP) $(DL_DIR)/$(PY-BITTORRENT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PY-BITTORRENT_PATCHES)"; then \
		cat $(PY-BITTORRENT_PATCHES) | patch -d $(BUILD_DIR)/$(PY-BITTORRENT_DIR) -p0; \
	fi
	mv $(BUILD_DIR)/$(PY-BITTORRENT_DIR) $(PY-BITTORRENT_BUILD_DIR)/2.5
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.5; \
	    (echo "[build_scripts]"; \
	    echo "executable=/opt/bin/python2.5") > setup.cfg \
	)
	touch $(PY-BITTORRENT_BUILD_DIR)/.configured

py-bittorrent-unpack: $(PY-BITTORRENT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-BITTORRENT_BUILD_DIR)/.built: $(PY-BITTORRENT_BUILD_DIR)/.configured
	rm -f $(PY-BITTORRENT_BUILD_DIR)/.built
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build)
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build)
	touch $(PY-BITTORRENT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
py-bittorrent: $(PY-BITTORRENT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-BITTORRENT_BUILD_DIR)/.staged: $(PY-BITTORRENT_BUILD_DIR)/.built
	rm -f $(PY-BITTORRENT_BUILD_DIR)/.staged
	#$(MAKE) -C $(PY-BITTORRENT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PY-BITTORRENT_BUILD_DIR)/.staged

py-bittorrent-stage: $(PY-BITTORRENT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/py-bittorrent
#
$(PY-BITTORRENT-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-bittorrent-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BITTORRENT_PRIORITY)" >>$@
	@echo "Section: $(PY-BITTORRENT_SECTION)" >>$@
	@echo "Version: $(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BITTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(PY-BITTORRENT_SITE)/$(PY-BITTORRENT_SOURCE)" >>$@
	@echo "Description: $(PY-BITTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Conflicts: $(PY-BITTORRENT_CONFLICTS)" >>$@

$(PY24-BITTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-bittorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BITTORRENT_PRIORITY)" >>$@
	@echo "Section: $(PY-BITTORRENT_SECTION)" >>$@
	@echo "Version: $(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BITTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(PY-BITTORRENT_SITE)/$(PY-BITTORRENT_SOURCE)" >>$@
	@echo "Description: $(PY-BITTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: py-bittorrent-common, $(PY24-BITTORRENT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BITTORRENT_CONFLICTS)" >>$@

$(PY25-BITTORRENT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-bittorrent" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-BITTORRENT_PRIORITY)" >>$@
	@echo "Section: $(PY-BITTORRENT_SECTION)" >>$@
	@echo "Version: $(PY-BITTORRENT_VERSION)-$(PY-BITTORRENT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-BITTORRENT_MAINTAINER)" >>$@
	@echo "Source: $(PY-BITTORRENT_SITE)/$(PY-BITTORRENT_SOURCE)" >>$@
	@echo "Description: $(PY-BITTORRENT_DESCRIPTION)" >>$@
	@echo "Depends: py-bittorrent-common, $(PY25-BITTORRENT_DEPENDS)" >>$@
	@echo "Conflicts: $(PY-BITTORRENT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-BITTORRENT_IPK_DIR)/opt/sbin or $(PY-BITTORRENT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-BITTORRENT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-BITTORRENT_IPK_DIR)/opt/etc/py-bittorrent/...
# Documentation files should be installed in $(PY-BITTORRENT_IPK_DIR)/opt/doc/py-bittorrent/...
# Daemon startup scripts should be installed in $(PY-BITTORRENT_IPK_DIR)/opt/etc/init.d/S??py-bittorrent
#
# You may need to patch your application to make it use these locations.
#
$(PY24-BITTORRENT_IPK): $(PY-BITTORRENT_BUILD_DIR)/.built
	rm -rf $(PY24-BITTORRENT_IPK_DIR) $(BUILD_DIR)/py-bittorrent_*_$(TARGET_ARCH).ipk
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.4; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.4/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install --root=$(PY24-BITTORRENT_IPK_DIR) --prefix=/opt)
	rm -rf $(PY24-BITTORRENT_IPK_DIR)/opt/share
	$(MAKE) $(PY24-BITTORRENT_IPK_DIR)/CONTROL/control
#	echo $(PY-BITTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(PY24-BITTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-BITTORRENT_IPK_DIR)

$(PY25-BITTORRENT_IPK) $(PY-BITTORRENT-COMMON_IPK): $(PY-BITTORRENT_BUILD_DIR)/.built
	rm -rf $(PY-BITTORRENT-COMMON_IPK_DIR) $(BUILD_DIR)/py-bittorrent-common_*_$(TARGET_ARCH).ipk
	rm -rf $(PY25-BITTORRENT_IPK_DIR) $(BUILD_DIR)/py25-bittorrent_*_$(TARGET_ARCH).ipk
	(cd $(PY-BITTORRENT_BUILD_DIR)/2.5; \
	PYTHONPATH=$(STAGING_LIB_DIR)/python2.5/site-packages \
	$(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install --root=$(PY25-BITTORRENT_IPK_DIR) --prefix=/opt)
	for f in $(PY25-BITTORRENT_IPK_DIR)/opt/*bin/*; \
	    do mv $$f `echo $$f | sed 's|$$|-2.5|'`; done
	install -d $(PY-BITTORRENT-COMMON_IPK_DIR)/opt
	mv $(PY25-BITTORRENT_IPK_DIR)/opt/share $(PY-BITTORRENT-COMMON_IPK_DIR)/opt
	$(MAKE) $(PY25-BITTORRENT_IPK_DIR)/CONTROL/control
	$(MAKE) $(PY-BITTORRENT-COMMON_IPK_DIR)/CONTROL/control
#	echo $(PY-BITTORRENT_CONFFILES) | sed -e 's/ /\n/g' > $(PY25-BITTORRENT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-BITTORRENT-COMMON_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-BITTORRENT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
py-bittorrent-ipk: $(PY-BITTORRENT-COMMON_IPK) $(PY24-BITTORRENT_IPK) $(PY25-BITTORRENT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
py-bittorrent-clean:
	-$(MAKE) -C $(PY-BITTORRENT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
py-bittorrent-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-BITTORRENT_DIR) $(PY-BITTORRENT_BUILD_DIR) \
	$(PY24-BITTORRENT_IPK_DIR) $(PY24-BITTORRENT_IPK) \
	$(PY25-BITTORRENT_IPK_DIR) $(PY25-BITTORRENT_IPK) \
	$(PY-BITTORRENT-COMMON_IPK_DIR) $(PY-BITTORRENT-COMMON_IPK)

#
# Some sanity check for the package.
#
py-bittorrent-check: $(PY-BITTORRENT-COMMON_IPK) $(PY24-BITTORRENT_IPK) $(PY25-BITTORRENT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
		$(PY-BITTORRENT-COMMON_IPK) $(PY24-BITTORRENT_IPK) $(PY25-BITTORRENT_IPK)
