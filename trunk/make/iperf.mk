###########################################################
#
# iperf
#
###########################################################

#
# IPERF_VERSION, IPERF_SITE and IPERF_SOURCE define
# the upstream location of the source code for the package.
# IPERF_DIR is the directory which is created when the source
# archive is unpacked.
# IPERF_UNZIP is the command used to unzip the source.
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
IPERF_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/iperf
IPERF_VERSION=2.0.4
IPERF_SOURCE=iperf-$(IPERF_VERSION).tar.gz
IPERF_DIR=iperf-$(IPERF_VERSION)
IPERF_UNZIP=zcat
IPERF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPERF_DESCRIPTION=A tool for measuring TCP and UDP bandwidth performance.
IPERF_SECTION=net
IPERF_PRIORITY=optional
IPERF_DEPENDS=
IPERF_SUGGESTS=
IPERF_CONFLICTS=

#
# IPERF_IPK_VERSION should be incremented when the ipk changes.
#
IPERF_IPK_VERSION=1

#
# IPERF_CONFFILES should be a list of user-editable files
#IPERF_CONFFILES=/opt/etc/iperf.conf /opt/etc/init.d/SXXiperf

#
# IPERF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPERF_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPERF_CPPFLAGS=
IPERF_LDFLAGS=-lpthread

#
# IPERF_BUILD_DIR is the directory in which the build is done.
# IPERF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPERF_IPK_DIR is the directory in which the ipk is built.
# IPERF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPERF_BUILD_DIR=$(BUILD_DIR)/iperf
IPERF_SOURCE_DIR=$(SOURCE_DIR)/iperf
IPERF_IPK_DIR=$(BUILD_DIR)/iperf-$(IPERF_VERSION)-ipk
IPERF_IPK=$(BUILD_DIR)/iperf_$(IPERF_VERSION)-$(IPERF_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPERF_SOURCE):
	$(WGET) -P $(@D) $(IPERF_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iperf-source: $(DL_DIR)/$(IPERF_SOURCE) $(IPERF_PATCHES)

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
$(IPERF_BUILD_DIR)/.configured: $(DL_DIR)/$(IPERF_SOURCE) $(IPERF_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(IPERF_DIR) $(@D)
	$(IPERF_UNZIP) $(DL_DIR)/$(IPERF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	#cat $(IPERF_PATCHES) | patch -d $(BUILD_DIR)/$(IPERF_DIR) -p1
	mv $(BUILD_DIR)/$(IPERF_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPERF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPERF_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_pthread_cancel=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $@

iperf-unpack: $(IPERF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPERF_BUILD_DIR)/.built: $(IPERF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
iperf: $(IPERF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(IPERF_BUILD_DIR)/.staged: $(IPERF_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#iperf-stage: $(IPERF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iperf
#
$(IPERF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iperf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPERF_PRIORITY)" >>$@
	@echo "Section: $(IPERF_SECTION)" >>$@
	@echo "Version: $(IPERF_VERSION)-$(IPERF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPERF_MAINTAINER)" >>$@
	@echo "Source: $(IPERF_SITE)/$(IPERF_SOURCE)" >>$@
	@echo "Description: $(IPERF_DESCRIPTION)" >>$@
	@echo "Depends: $(IPERF_DEPENDS)" >>$@
	@echo "Suggests: $(IPERF_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPERF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPERF_IPK_DIR)/opt/sbin or $(IPERF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPERF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IPERF_IPK_DIR)/opt/etc/iperf/...
# Documentation files should be installed in $(IPERF_IPK_DIR)/opt/doc/iperf/...
# Daemon startup scripts should be installed in $(IPERF_IPK_DIR)/opt/etc/init.d/S??iperf
#
# You may need to patch your application to make it use these locations.
#
$(IPERF_IPK): $(IPERF_BUILD_DIR)/.built
	rm -rf $(IPERF_IPK_DIR) $(BUILD_DIR)/iperf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IPERF_BUILD_DIR) DESTDIR=$(IPERF_IPK_DIR) install-strip
	$(MAKE) $(IPERF_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPERF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iperf-ipk: $(IPERF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iperf-clean:
	-$(MAKE) -C $(IPERF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iperf-dirclean:
	rm -rf $(BUILD_DIR)/$(IPERF_DIR) $(IPERF_BUILD_DIR) $(IPERF_IPK_DIR) $(IPERF_IPK)

#
# Some sanity check for the package.
#
iperf-check: $(IPERF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPERF_IPK)
