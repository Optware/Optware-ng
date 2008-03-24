###########################################################
#
# cherokee-pyscgi
#
###########################################################

#
# CHEROKEE-PYSCGI_VERSION, CHEROKEE-PYSCGI_SITE and CHEROKEE-PYSCGI_SOURCE define
# the upstream location of the source code for the package.
# CHEROKEE-PYSCGI_DIR is the directory which is created when the source
# archive is unpacked.
# CHEROKEE-PYSCGI_UNZIP is the command used to unzip the source.
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
CHEROKEE-PYSCGI_SITE=http://www.cherokee-project.com/download/pyscgi
CHEROKEE-PYSCGI_VERSION=1.6
CHEROKEE-PYSCGI_SOURCE=cherokee_pyscgi-$(CHEROKEE-PYSCGI_VERSION).tar.gz
CHEROKEE-PYSCGI_DIR=cherokee_pyscgi-$(CHEROKEE-PYSCGI_VERSION)
CHEROKEE-PYSCGI_UNZIP=zcat
CHEROKEE-PYSCGI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHEROKEE-PYSCGI_DESCRIPTION=PySCGI is a 100% Python module implementing the SCGI protocol. It can be used to write Python-based application servers.
CHEROKEE-PYSCGI_SECTION=misc
CHEROKEE-PYSCGI_PRIORITY=optional
PY24-CHEROKEE-SCGI_DEPENDS=python24
PY25-CHEROKEE-SCGI_DEPENDS=python25
CHEROKEE-PYSCGI_CONFLICTS=

#
# CHEROKEE-PYSCGI_IPK_VERSION should be incremented when the ipk changes.
#
CHEROKEE-PYSCGI_IPK_VERSION=1

#
# CHEROKEE-PYSCGI_CONFFILES should be a list of user-editable files
#CHEROKEE-PYSCGI_CONFFILES=/opt/etc/cherokee-pyscgi.conf /opt/etc/init.d/SXXcherokee-pyscgi

#
# CHEROKEE-PYSCGI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CHEROKEE-PYSCGI_PATCHES=$(CHEROKEE-PYSCGI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHEROKEE-PYSCGI_CPPFLAGS=
CHEROKEE-PYSCGI_LDFLAGS=

#
# CHEROKEE-PYSCGI_BUILD_DIR is the directory in which the build is done.
# CHEROKEE-PYSCGI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHEROKEE-PYSCGI_IPK_DIR is the directory in which the ipk is built.
# CHEROKEE-PYSCGI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHEROKEE-PYSCGI_BUILD_DIR=$(BUILD_DIR)/cherokee-pyscgi
CHEROKEE-PYSCGI_SOURCE_DIR=$(SOURCE_DIR)/cherokee-pyscgi

PY24-CHEROKEE-SCGI_IPK_DIR=$(BUILD_DIR)/py24-cherokee-scgi-$(CHEROKEE-PYSCGI_VERSION)-ipk
PY24-CHEROKEE-SCGI_IPK=$(BUILD_DIR)/py24-cherokee-scgi_$(CHEROKEE-PYSCGI_VERSION)-$(CHEROKEE-PYSCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

PY25-CHEROKEE-SCGI_IPK_DIR=$(BUILD_DIR)/py25-cherokee-scgi-$(CHEROKEE-PYSCGI_VERSION)-ipk
PY25-CHEROKEE-SCGI_IPK=$(BUILD_DIR)/py25-cherokee-scgi_$(CHEROKEE-PYSCGI_VERSION)-$(CHEROKEE-PYSCGI_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cherokee-pyscgi-source cherokee-pyscgi-unpack cherokee-pyscgi cherokee-pyscgi-stage cherokee-pyscgi-ipk cherokee-pyscgi-clean cherokee-pyscgi-dirclean cherokee-pyscgi-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CHEROKEE-PYSCGI_SOURCE):
	$(WGET) -P $(@D) $(CHEROKEE-PYSCGI_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cherokee-pyscgi-source: $(DL_DIR)/$(CHEROKEE-PYSCGI_SOURCE) $(CHEROKEE-PYSCGI_PATCHES)

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
$(CHEROKEE-PYSCGI_BUILD_DIR)/.configured: $(DL_DIR)/$(CHEROKEE-PYSCGI_SOURCE) $(CHEROKEE-PYSCGI_PATCHES)
#	$(MAKE) somepkg-stage
	rm -rf $(@D)
	mkdir -p $(@D)
	# 2.4
	rm -rf $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR)
	$(CHEROKEE-PYSCGI_UNZIP) $(DL_DIR)/$(CHEROKEE-PYSCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(CHEROKEE-PYSCGI_PATCHES) | patch -d $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR) -p1
	mv $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR) $(@D)/2.4
	# 2.5
	rm -rf $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR)
	$(CHEROKEE-PYSCGI_UNZIP) $(DL_DIR)/$(CHEROKEE-PYSCGI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(CHEROKEE-PYSCGI_PATCHES) | patch -d $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR) -p1
	mv $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR) $(@D)/2.5
	touch $@

cherokee-pyscgi-unpack: $(CHEROKEE-PYSCGI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHEROKEE-PYSCGI_BUILD_DIR)/.built: $(CHEROKEE-PYSCGI_BUILD_DIR)/.configured
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
cherokee-pyscgi: $(CHEROKEE-PYSCGI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHEROKEE-PYSCGI_BUILD_DIR)/.staged: $(CHEROKEE-PYSCGI_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

cherokee-pyscgi-stage: $(CHEROKEE-PYSCGI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cherokee-pyscgi
#
$(PY24-CHEROKEE-SCGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py24-cherokee-scgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHEROKEE-PYSCGI_PRIORITY)" >>$@
	@echo "Section: $(CHEROKEE-PYSCGI_SECTION)" >>$@
	@echo "Version: $(CHEROKEE-PYSCGI_VERSION)-$(CHEROKEE-PYSCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHEROKEE-PYSCGI_MAINTAINER)" >>$@
	@echo "Source: $(CHEROKEE-PYSCGI_SITE)/$(CHEROKEE-PYSCGI_SOURCE)" >>$@
	@echo "Description: $(CHEROKEE-PYSCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY24-CHEROKEE-SCGI_DEPENDS)" >>$@
	@echo "Conflicts: $(CHEROKEE-PYSCGI_CONFLICTS)" >>$@

$(PY25-CHEROKEE-SCGI_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: py25-cherokee-scgi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHEROKEE-PYSCGI_PRIORITY)" >>$@
	@echo "Section: $(CHEROKEE-PYSCGI_SECTION)" >>$@
	@echo "Version: $(CHEROKEE-PYSCGI_VERSION)-$(CHEROKEE-PYSCGI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHEROKEE-PYSCGI_MAINTAINER)" >>$@
	@echo "Source: $(CHEROKEE-PYSCGI_SITE)/$(CHEROKEE-PYSCGI_SOURCE)" >>$@
	@echo "Description: $(CHEROKEE-PYSCGI_DESCRIPTION)" >>$@
	@echo "Depends: $(PY25-CHEROKEE-SCGI_DEPENDS)" >>$@
	@echo "Conflicts: $(CHEROKEE-PYSCGI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHEROKEE-PYSCGI_IPK_DIR)/opt/sbin or $(CHEROKEE-PYSCGI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHEROKEE-PYSCGI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CHEROKEE-PYSCGI_IPK_DIR)/opt/etc/cherokee-pyscgi/...
# Documentation files should be installed in $(CHEROKEE-PYSCGI_IPK_DIR)/opt/doc/cherokee-pyscgi/...
# Daemon startup scripts should be installed in $(CHEROKEE-PYSCGI_IPK_DIR)/opt/etc/init.d/S??cherokee-pyscgi
#
# You may need to patch your application to make it use these locations.
#
$(PY24-CHEROKEE-SCGI_IPK): $(CHEROKEE-PYSCGI_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/cherokee-pyscgi_*_$(TARGET_ARCH).ipk
	rm -rf $(PY24-CHEROKEE-SCGI_IPK_DIR) $(BUILD_DIR)/py24-cherokee-scgi_*_$(TARGET_ARCH).ipk
	(cd $(CHEROKEE-PYSCGI_BUILD_DIR)/2.4; \
	    $(HOST_STAGING_PREFIX)/bin/python2.4 setup.py install \
	    --root=$(PY24-CHEROKEE-SCGI_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY24-CHEROKEE-SCGI_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY24-CHEROKEE-SCGI_IPK_DIR)

$(PY25-CHEROKEE-SCGI_IPK): $(CHEROKEE-PYSCGI_BUILD_DIR)/.built
	rm -rf $(PY25-CHEROKEE-SCGI_IPK_DIR) $(BUILD_DIR)/py25-cherokee-scgi_*_$(TARGET_ARCH).ipk
	(cd $(CHEROKEE-PYSCGI_BUILD_DIR)/2.5; \
	    $(HOST_STAGING_PREFIX)/bin/python2.5 setup.py install \
	    --root=$(PY25-CHEROKEE-SCGI_IPK_DIR) --prefix=/opt; \
	)
	$(MAKE) $(PY25-CHEROKEE-SCGI_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PY25-CHEROKEE-SCGI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cherokee-pyscgi-ipk: $(PY24-CHEROKEE-SCGI_IPK) $(PY25-CHEROKEE-SCGI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cherokee-pyscgi-clean:
	-$(MAKE) -C $(CHEROKEE-PYSCGI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cherokee-pyscgi-dirclean:
	rm -rf $(BUILD_DIR)/$(CHEROKEE-PYSCGI_DIR) $(CHEROKEE-PYSCGI_BUILD_DIR)
	rm -rf $(PY24-CHEROKEE-SCGI_IPK_DIR) $(PY24-CHEROKEE-SCGI_IPK)
	rm -rf $(PY25-CHEROKEE-SCGI_IPK_DIR) $(PY25-CHEROKEE-SCGI_IPK)

#
# Some sanity check for the package.
#
cherokee-pyscgi-check: $(PY24-CHEROKEE-SCGI_IPK) $(PY25-CHEROKEE-SCGI_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) \
		$(PY24-CHEROKEE-SCGI_IPK) $(PY25-CHEROKEE-SCGI_IPK)
