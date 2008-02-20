###########################################################
#
# getmail
#
###########################################################

#
# PY-GETMAIL_VERSION, PY-GETMAIL_SITE and PY-GETMAIL_SOURCE define
# the upstream location of the source code for the package.
# PY-GETMAIL_DIR is the directory which is created when the source
# archive is unpacked.
# PY-GETMAIL_UNZIP is the command used to unzip the source.
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
PY-GETMAIL_SITE=http://pyropus.ca/software/getmail/old-versions
GETMAIL_VERSION=4.8.0
PY-GETMAIL_SOURCE=getmail-$(GETMAIL_VERSION).tar.gz
PY-GETMAIL_DIR=getmail-$(GETMAIL_VERSION)
PY-GETMAIL_UNZIP=zcat
PY-GETMAIL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PY-GETMAIL_DESCRIPTION=getmail is a mail retriever designed to allow you to get your mail from one or more mail accounts on various mail servers to your local machine.
PY-GETMAIL_SECTION=mail
PY-GETMAIL_PRIORITY=optional
PY24-GETMAIL_DEPENDS=python24
PY25-GETMAIL_DEPENDS=python25
PY-GETMAIL_SUGGESTS=
PY-GETMAIL_CONFLICTS=

#
# PY-GETMAIL_IPK_VERSION should be incremented when the ipk changes.
#
GETMAIL_IPK_VERSION=1

#
# PY-GETMAIL_CONFFILES should be a list of user-editable files
#PY-GETMAIL_CONFFILES=/opt/etc/getmail.conf /opt/etc/init.d/SXXgetmail

#
# PY-GETMAIL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PY-GETMAIL_PATCHES=$(PY-GETMAIL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PY-GETMAIL_CPPFLAGS=
PY-GETMAIL_LDFLAGS=

#
# PY-GETMAIL_BUILD_DIR is the directory in which the build is done.
# PY-GETMAIL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PY-GETMAIL_IPK_DIR is the directory in which the ipk is built.
# PY-GETMAIL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PY-GETMAIL_BUILD_DIR=$(BUILD_DIR)/getmail
PY-GETMAIL_SOURCE_DIR=$(SOURCE_DIR)/getmail

PY-GETMAIL-COMMON_IPK_DIR=$(BUILD_DIR)/py-getmail-common-$(GETMAIL_VERSION)-ipk
PY-GETMAIL-COMMON_IPK=$(BUILD_DIR)/py-getmail-common_$(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY24-GETMAIL_IPK_DIR=$(BUILD_DIR)/py24-getmail-$(GETMAIL_VERSION)-ipk
PY24-GETMAIL_IPK=$(BUILD_DIR)/py24-getmail_$(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-GETMAIL_IPK_DIR=$(BUILD_DIR)/py25-getmail-$(GETMAIL_VERSION)-ipk
PY25-GETMAIL_IPK=$(BUILD_DIR)/py25-getmail_$(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: getmail-source getmail-unpack getmail getmail-stage getmail-ipk getmail-clean getmail-dirclean getmail-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PY-GETMAIL_SOURCE):
	$(WGET) -P $(DL_DIR) $(PY-GETMAIL_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
getmail-source: $(DL_DIR)/$(PY-GETMAIL_SOURCE) $(PY-GETMAIL_PATCHES)

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
$(PY-GETMAIL_BUILD_DIR)/.configured: $(DL_DIR)/$(PY-GETMAIL_SOURCE) $(PY-GETMAIL_PATCHES)
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	mkdir -p $(PY-GETMAIL_BUILD_DIR)
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-GETMAIL_DIR)
	$(PY-GETMAIL_UNZIP) $(DL_DIR)/$(PY-GETMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GETMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GETMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GETMAIL_DIR) $(@D)/2.4
	(cd $(@D)/2.4; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.4" \
	    ) >> setup.cfg; \
	)
	sed -i -e '/getmail.spec/d' $(@D)/2.4/setup.py
	# 2.4
	rm -rf $(BUILD_DIR)/$(PY-GETMAIL_DIR)
	$(PY-GETMAIL_UNZIP) $(DL_DIR)/$(PY-GETMAIL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(PY-GETMAIL_PATCHES) | patch -d $(BUILD_DIR)/$(PY-GETMAIL_DIR) -p1
	mv $(BUILD_DIR)/$(PY-GETMAIL_DIR) $(@D)/2.5
	(cd $(@D)/2.5; \
	    ( \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.5" \
	    ) >> setup.cfg; \
	)
	sed -i -e '/getmail.spec/d' $(@D)/2.5/setup.py
	touch $@

getmail-unpack: $(PY-GETMAIL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PY-GETMAIL_BUILD_DIR)/.built: $(PY-GETMAIL_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py build; \
	)
	(cd $(@D)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py build; \
	)
	touch $@

#
# This is the build convenience target.
#
getmail: $(PY-GETMAIL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PY-GETMAIL_BUILD_DIR)/.staged: $(PY-GETMAIL_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(PY-GETMAIL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

getmail-stage: $(PY-GETMAIL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/getmail
#
$(PY-GETMAIL-COMMON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py-getmail-common" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GETMAIL_PRIORITY)" >>$@
	@echo "Section: $(PY-GETMAIL_SECTION)" >>$@
	@echo "Version: $(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GETMAIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-GETMAIL_SITE)/$(PY-GETMAIL_SOURCE)" >>$@
	@echo "Description: $(PY-GETMAIL_DESCRIPTION)" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: $(PY-GETMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-GETMAIL_CONFLICTS)" >>$@

$(PY24-GETMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-getmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GETMAIL_PRIORITY)" >>$@
	@echo "Section: $(PY-GETMAIL_SECTION)" >>$@
	@echo "Version: $(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GETMAIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-GETMAIL_SITE)/$(PY-GETMAIL_SOURCE)" >>$@
	@echo "Description: $(PY-GETMAIL_DESCRIPTION)" >>$@
	@echo "Depends: py-getmail-common $(PY24-GETMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(PY-GETMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-GETMAIL_CONFLICTS)" >>$@

$(PY25-GETMAIL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-getmail" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PY-GETMAIL_PRIORITY)" >>$@
	@echo "Section: $(PY-GETMAIL_SECTION)" >>$@
	@echo "Version: $(GETMAIL_VERSION)-$(GETMAIL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PY-GETMAIL_MAINTAINER)" >>$@
	@echo "Source: $(PY-GETMAIL_SITE)/$(PY-GETMAIL_SOURCE)" >>$@
	@echo "Description: $(PY-GETMAIL_DESCRIPTION)" >>$@
	@echo "Depends: py-getmail-common $(PY25-GETMAIL_DEPENDS)" >>$@
	@echo "Suggests: $(PY-GETMAIL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PY-GETMAIL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PY-GETMAIL_IPK_DIR)/opt/sbin or $(PY-GETMAIL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PY-GETMAIL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PY-GETMAIL_IPK_DIR)/opt/etc/getmail/...
# Documentation files should be installed in $(PY-GETMAIL_IPK_DIR)/opt/doc/getmail/...
# Daemon startup scripts should be installed in $(PY-GETMAIL_IPK_DIR)/opt/etc/init.d/S??getmail
#
# You may need to patch your application to make it use these locations.
#
$(PY-GETMAIL-COMMON_IPK) $(PY24-GETMAIL_IPK) $(PY25-GETMAIL_IPK): $(PY-GETMAIL_BUILD_DIR)/.built
	# 2.4 & common
	rm -rf $(PY24-GETMAIL_IPK_DIR) $(BUILD_DIR)/py24-getmail_*_$(TARGET_ARCH).ipk
	rm -rf $(PY-GETMAIL-COMMON_IPK_DIR) $(BUILD_DIR)/py-getmail-common_*_$(TARGET_ARCH).ipk
	(cd $(PY-GETMAIL_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-GETMAIL_IPK_DIR) --prefix=/opt; \
	)
	install -d $(PY-GETMAIL-COMMON_IPK_DIR)/opt/
	mv $(PY24-GETMAIL_IPK_DIR)/opt/share $(PY-GETMAIL-COMMON_IPK_DIR)/opt/
	$(MAKE) $(PY24-GETMAIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-GETMAIL_IPK_DIR)
	$(MAKE) $(PY-GETMAIL-COMMON_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY-GETMAIL-COMMON_IPK_DIR)
	# 2.5
	rm -rf $(PY25-GETMAIL_IPK_DIR) $(BUILD_DIR)/py25-getmail_*_$(TARGET_ARCH).ipk
	(cd $(PY-GETMAIL_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-GETMAIL_IPK_DIR) --prefix=/opt; \
	)
	rm -rf $(PY25-GETMAIL_IPK_DIR)/opt/share
	for f in $(PY25-GETMAIL_IPK_DIR)/opt/*bin/*; \
		do mv $$f `echo $$f | sed 's|$$|-py2.5|'`; done
	$(MAKE) $(PY25-GETMAIL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-GETMAIL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
getmail-ipk: $(PY24-GETMAIL_IPK) $(PY25-GETMAIL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
getmail-clean:
	-$(MAKE) -C $(PY-GETMAIL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
getmail-dirclean:
	rm -rf $(BUILD_DIR)/$(PY-GETMAIL_DIR) $(PY-GETMAIL_BUILD_DIR)
	rm -rf $(PY24-GETMAIL_IPK_DIR) $(PY24-GETMAIL_IPK)
	rm -rf $(PY25-GETMAIL_IPK_DIR) $(PY25-GETMAIL_IPK)

#
# Some sanity check for the package.
#
getmail-check: $(PY24-GETMAIL_IPK) $(PY25-GETMAIL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PY24-GETMAIL_IPK) $(PY25-GETMAIL_IPK)
