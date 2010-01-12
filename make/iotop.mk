###########################################################
#
# iotop
#
###########################################################

# You must replace "iotop" and "IOTOP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IOTOP_VERSION, IOTOP_SITE and IOTOP_SOURCE define
# the upstream location of the source code for the package.
# IOTOP_DIR is the directory which is created when the source
# archive is unpacked.
# IOTOP_UNZIP is the command used to unzip the source.
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
IOTOP_SITE=http://guichaz.free.fr/iotop/files
IOTOP_VERSION=0.4
IOTOP_SOURCE=iotop-$(IOTOP_VERSION).tar.gz
IOTOP_DIR=iotop-$(IOTOP_VERSION)
IOTOP_UNZIP=zcat
IOTOP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IOTOP_DESCRIPTION=Iotop is a top-like UI used to show the I/O behaviour of processes.
IOTOP_SECTION=util
IOTOP_PRIORITY=optional
IOTOP_DEPENDS=python26
IOTOP_SUGGESTS=
IOTOP_CONFLICTS=

#
# IOTOP_IPK_VERSION should be incremented when the ipk changes.
#
IOTOP_IPK_VERSION=1

#
# IOTOP_CONFFILES should be a list of user-editable files
#IOTOP_CONFFILES=/opt/etc/iotop.conf /opt/etc/init.d/SXXiotop

#
# IOTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# IOTOP_PATCHES=$(IOTOP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IOTOP_CPPFLAGS=
IOTOP_LDFLAGS=

#
# IOTOP_BUILD_DIR is the directory in which the build is done.
# IOTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IOTOP_IPK_DIR is the directory in which the ipk is built.
# IOTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IOTOP_BUILD_DIR=$(BUILD_DIR)/iotop
IOTOP_SOURCE_DIR=$(SOURCE_DIR)/iotop

IOTOP_IPK_DIR=$(BUILD_DIR)/iotop-$(IOTOP_VERSION)-ipk
IOTOP_IPK=$(BUILD_DIR)/iotop_$(IOTOP_VERSION)-$(IOTOP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iotop-source iotop-unpack iotop iotop-stage iotop-ipk iotop-clean iotop-dirclean iotop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IOTOP_SOURCE):
	$(WGET) -P $(@D) $(IOTOP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iotop-source: $(DL_DIR)/$(IOTOP_SOURCE) $(IOTOP_PATCHES)

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
$(IOTOP_BUILD_DIR)/.configured: $(DL_DIR)/$(IOTOP_SOURCE) $(IOTOP_PATCHES) make/iotop.mk
	$(MAKE) py-setuptools-stage
	rm -rf $(@D)
	rm -rf $(BUILD_DIR)/$(IOTOP_DIR)
	$(IOTOP_UNZIP) $(DL_DIR)/$(IOTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IOTOP_PATCHES)"; \
		then cat $(IOTOP_PATCHES) | patch -d $(BUILD_DIR)/$(IOTOP_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(IOTOP_DIR) $(IOTOP_BUILD_DIR)
	(cd $(@D); \
	    ( \
		echo "[build_ext]"; \
	        echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/python2.6"; \
	        echo "library-dirs=$(STAGING_LIB_DIR)"; \
	        echo "rpath=/opt/lib"; \
		echo "[build_scripts]"; \
		echo "executable=/opt/bin/python2.6" \
	    ) >> setup.cfg; \
	)
	touch $@

iotop-unpack: $(IOTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IOTOP_BUILD_DIR)/.built: $(IOTOP_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    CC='$(TARGET_CC)' LDSHARED='$(TARGET_CC) -shared' \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py build
	touch $@

#
# This is the build convenience target.
#
iotop: $(IOTOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(IOTOP_BUILD_DIR)/.staged: $(IOTOP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#iotop-stage: $(IOTOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iotop
#
$(IOTOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iotop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IOTOP_PRIORITY)" >>$@
	@echo "Section: $(IOTOP_SECTION)" >>$@
	@echo "Version: $(IOTOP_VERSION)-$(IOTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IOTOP_MAINTAINER)" >>$@
	@echo "Source: $(IOTOP_SITE)/$(IOTOP_SOURCE)" >>$@
	@echo "Description: $(IOTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(IOTOP_DEPENDS)" >>$@
	@echo "Conflicts: $(IOTOP_CONFLICTS)" >>$@


#
# This builds the IPK file.
#
# Binaries should be installed into $(IOTOP_IPK_DIR)/opt/sbin or $(IOTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IOTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IOTOP_IPK_DIR)/opt/etc/iotop/...
# Documentation files should be installed in $(IOTOP_IPK_DIR)/opt/doc/iotop/...
# Daemon startup scripts should be installed in $(IOTOP_IPK_DIR)/opt/etc/init.d/S??iotop
#
# You may need to patch your application to make it use these locations.
#
$(IOTOP_IPK): $(IOTOP_BUILD_DIR)/.built
	rm -rf $(IOTOP_IPK_DIR) $(BUILD_DIR)/iotop_*_$(TARGET_ARCH).ipk
	cd $(IOTOP_BUILD_DIR); \
	    PYTHONPATH=$(STAGING_LIB_DIR)/python2.6/site-packages \
	    $(HOST_STAGING_PREFIX)/bin/python2.6 setup.py install \
	    --root=$(IOTOP_IPK_DIR) --prefix=/opt
#	$(STRIP_COMMAND) `find $(IOTOP_IPK_DIR)/opt/lib/python2.6/site-packages -name '*.so'`
	$(MAKE) $(IOTOP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IOTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iotop-ipk: $(IOTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iotop-clean:
	-$(MAKE) -C $(IOTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iotop-dirclean:
	rm -rf $(BUILD_DIR)/$(IOTOP_DIR) $(IOTOP_BUILD_DIR)
	rm -rf $(IOTOP_IPK_DIR) $(IOTOP_IPK)

#
# Some sanity check for the package.
#
iotop-check: $(IOTOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
