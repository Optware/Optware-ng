###########################################################
#
# ifstat
#
###########################################################
#
# IFSTAT_VERSION, IFSTAT_SITE and IFSTAT_SOURCE define
# the upstream location of the source code for the package.
# IFSTAT_DIR is the directory which is created when the source
# archive is unpacked.
# IFSTAT_UNZIP is the command used to unzip the source.
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
IFSTAT_SITE=http://gael.roualland.free.fr/ifstat/
IFSTAT_VERSION=1.1
IFSTAT_SOURCE=ifstat-$(IFSTAT_VERSION).tar.gz
IFSTAT_DIR=ifstat-$(IFSTAT_VERSION)
IFSTAT_UNZIP=zcat
IFSTAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IFSTAT_DESCRIPTION=InterFace STATistics Monitoring
IFSTAT_SECTION=net
IFSTAT_PRIORITY=optional
IFSTAT_DEPENDS=
IFSTAT_SUGGESTS=
IFSTAT_CONFLICTS=

#
# IFSTAT_IPK_VERSION should be incremented when the ipk changes.
#
IFSTAT_IPK_VERSION=1

#
# IFSTAT_CONFFILES should be a list of user-editable files
#IFSTAT_CONFFILES=/opt/etc/ifstat.conf /opt/etc/init.d/SXXifstat

#
# IFSTAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IFSTAT_PATCHES=$(IFSTAT_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IFSTAT_CPPFLAGS=
IFSTAT_LDFLAGS=

#
# IFSTAT_BUILD_DIR is the directory in which the build is done.
# IFSTAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IFSTAT_IPK_DIR is the directory in which the ipk is built.
# IFSTAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IFSTAT_BUILD_DIR=$(BUILD_DIR)/ifstat
IFSTAT_SOURCE_DIR=$(SOURCE_DIR)/ifstat
IFSTAT_IPK_DIR=$(BUILD_DIR)/ifstat-$(IFSTAT_VERSION)-ipk
IFSTAT_IPK=$(BUILD_DIR)/ifstat_$(IFSTAT_VERSION)-$(IFSTAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ifstat-source ifstat-unpack ifstat ifstat-stage ifstat-ipk ifstat-clean ifstat-dirclean ifstat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IFSTAT_SOURCE):
	$(WGET) -P $(@D) $(IFSTAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ifstat-source: $(DL_DIR)/$(IFSTAT_SOURCE) $(IFSTAT_PATCHES)

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
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(IFSTAT_BUILD_DIR)/.configured: $(DL_DIR)/$(IFSTAT_SOURCE) $(IFSTAT_PATCHES) make/ifstat.mk
	rm -rf $(BUILD_DIR)/$(IFSTAT_DIR) $(@D)
	$(IFSTAT_UNZIP) $(DL_DIR)/$(IFSTAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IFSTAT_PATCHES)" ; \
		then cat $(IFSTAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IFSTAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IFSTAT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IFSTAT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IFSTAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IFSTAT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

ifstat-unpack: $(IFSTAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IFSTAT_BUILD_DIR)/.built: $(IFSTAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ifstat: $(IFSTAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IFSTAT_BUILD_DIR)/.staged: $(IFSTAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ifstat-stage: $(IFSTAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ifstat
#
$(IFSTAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ifstat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IFSTAT_PRIORITY)" >>$@
	@echo "Section: $(IFSTAT_SECTION)" >>$@
	@echo "Version: $(IFSTAT_VERSION)-$(IFSTAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IFSTAT_MAINTAINER)" >>$@
	@echo "Source: $(IFSTAT_SITE)/$(IFSTAT_SOURCE)" >>$@
	@echo "Description: $(IFSTAT_DESCRIPTION)" >>$@
	@echo "Depends: $(IFSTAT_DEPENDS)" >>$@
	@echo "Suggests: $(IFSTAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(IFSTAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IFSTAT_IPK_DIR)/opt/sbin or $(IFSTAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IFSTAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IFSTAT_IPK_DIR)/opt/etc/ifstat/...
# Documentation files should be installed in $(IFSTAT_IPK_DIR)/opt/doc/ifstat/...
# Daemon startup scripts should be installed in $(IFSTAT_IPK_DIR)/opt/etc/init.d/S??ifstat
#
# You may need to patch your application to make it use these locations.
#
$(IFSTAT_IPK): $(IFSTAT_BUILD_DIR)/.built
	rm -rf $(IFSTAT_IPK_DIR) $(BUILD_DIR)/ifstat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IFSTAT_BUILD_DIR) DESTDIR=$(IFSTAT_IPK_DIR) install
	$(STRIP_COMMAND) $(IFSTAT_IPK_DIR)/opt/bin/*
	$(MAKE) $(IFSTAT_IPK_DIR)/CONTROL/control
	echo $(IFSTAT_CONFFILES) | sed -e 's/ /\n/g' > $(IFSTAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IFSTAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(IFSTAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ifstat-ipk: $(IFSTAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ifstat-clean:
	rm -f $(IFSTAT_BUILD_DIR)/.built
	-$(MAKE) -C $(IFSTAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ifstat-dirclean:
	rm -rf $(BUILD_DIR)/$(IFSTAT_DIR) $(IFSTAT_BUILD_DIR) $(IFSTAT_IPK_DIR) $(IFSTAT_IPK)
#
#
# Some sanity check for the package.
#
ifstat-check: $(IFSTAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
