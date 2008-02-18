###########################################################
#
# nd
#
###########################################################
#
# ND_VERSION, ND_SITE and ND_SOURCE define
# the upstream location of the source code for the package.
# ND_DIR is the directory which is created when the source
# archive is unpacked.
# ND_UNZIP is the command used to unzip the source.
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
ND_SITE=http://amadigan.sixbit.org
ND_VERSION=1.0
ND_SOURCE=nd-$(ND_VERSION).tar.gz
ND_DIR=nd-$(ND_VERSION)
ND_UNZIP=zcat
ND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ND_DESCRIPTION=Simple network daemon.
ND_SECTION=network
ND_PRIORITY=optional
ND_DEPENDS=
ND_SUGGESTS=
ND_CONFLICTS=

#
# ND_IPK_VERSION should be incremented when the ipk changes.
#
ND_IPK_VERSION=1

#
# ND_CONFFILES should be a list of user-editable files
#ND_CONFFILES=/opt/etc/nd.conf /opt/etc/init.d/SXXnd

#
# ND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ND_PATCHES=$(ND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ND_CPPFLAGS=
ND_LDFLAGS=

#
# ND_BUILD_DIR is the directory in which the build is done.
# ND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ND_IPK_DIR is the directory in which the ipk is built.
# ND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ND_BUILD_DIR=$(BUILD_DIR)/nd
ND_SOURCE_DIR=$(SOURCE_DIR)/nd
ND_IPK_DIR=$(BUILD_DIR)/nd-$(ND_VERSION)-ipk
ND_IPK=$(BUILD_DIR)/nd_$(ND_VERSION)-$(ND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nd-source nd-unpack nd nd-stage nd-ipk nd-clean nd-dirclean nd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ND_SOURCE):
	$(WGET) -P $(DL_DIR) $(ND_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nd-source: $(DL_DIR)/$(ND_SOURCE) $(ND_PATCHES)

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
$(ND_BUILD_DIR)/.configured: $(DL_DIR)/$(ND_SOURCE) $(ND_PATCHES) make/nd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ND_DIR) $(@D)
	$(ND_UNZIP) $(DL_DIR)/$(ND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ND_PATCHES)" ; \
		then cat $(ND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ND_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ND_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ND_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ND_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nd-unpack: $(ND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ND_BUILD_DIR)/.built: $(ND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nd: $(ND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ND_BUILD_DIR)/.staged: $(ND_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nd-stage: $(ND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nd
#
$(ND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ND_PRIORITY)" >>$@
	@echo "Section: $(ND_SECTION)" >>$@
	@echo "Version: $(ND_VERSION)-$(ND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ND_MAINTAINER)" >>$@
	@echo "Source: $(ND_SITE)/$(ND_SOURCE)" >>$@
	@echo "Description: $(ND_DESCRIPTION)" >>$@
	@echo "Depends: $(ND_DEPENDS)" >>$@
	@echo "Suggests: $(ND_SUGGESTS)" >>$@
	@echo "Conflicts: $(ND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ND_IPK_DIR)/opt/sbin or $(ND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ND_IPK_DIR)/opt/etc/nd/...
# Documentation files should be installed in $(ND_IPK_DIR)/opt/doc/nd/...
# Daemon startup scripts should be installed in $(ND_IPK_DIR)/opt/etc/init.d/S??nd
#
# You may need to patch your application to make it use these locations.
#
$(ND_IPK): $(ND_BUILD_DIR)/.built
	rm -rf $(ND_IPK_DIR) $(BUILD_DIR)/nd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ND_BUILD_DIR) DESTDIR=$(ND_IPK_DIR) install-strip
	$(MAKE) $(ND_IPK_DIR)/CONTROL/control
	echo $(ND_CONFFILES) | sed -e 's/ /\n/g' > $(ND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nd-ipk: $(ND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nd-clean:
	rm -f $(ND_BUILD_DIR)/.built
	-$(MAKE) -C $(ND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nd-dirclean:
	rm -rf $(BUILD_DIR)/$(ND_DIR) $(ND_BUILD_DIR) $(ND_IPK_DIR) $(ND_IPK)
#
#
# Some sanity check for the package.
#
nd-check: $(ND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ND_IPK)
