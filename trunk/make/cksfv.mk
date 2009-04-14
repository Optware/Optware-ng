###########################################################
#
# cksfv
#
###########################################################
#
# CKSFV_VERSION, CKSFV_SITE and CKSFV_SOURCE define
# the upstream location of the source code for the package.
# CKSFV_DIR is the directory which is created when the source
# archive is unpacked.
# CKSFV_UNZIP is the command used to unzip the source.
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
CKSFV_SITE=http://zakalwe.fi/~shd/foss/cksfv/files
CKSFV_VERSION=1.3.14
CKSFV_SOURCE=cksfv-$(CKSFV_VERSION).tar.bz2
CKSFV_DIR=cksfv-$(CKSFV_VERSION)
CKSFV_UNZIP=bzcat
CKSFV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CKSFV_DESCRIPTION=Check SFV (Simple File Verification)
CKSFV_SECTION=util
CKSFV_PRIORITY=optional
CKSFV_DEPENDS=
CKSFV_SUGGESTS=
CKSFV_CONFLICTS=

#
# CKSFV_IPK_VERSION should be incremented when the ipk changes.
#
CKSFV_IPK_VERSION=1

#
# CKSFV_CONFFILES should be a list of user-editable files
#CKSFV_CONFFILES=/opt/etc/cksfv.conf /opt/etc/init.d/SXXcksfv

#
# CKSFV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CKSFV_PATCHES=$(CKSFV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CKSFV_CPPFLAGS=
CKSFV_LDFLAGS=

#
# CKSFV_BUILD_DIR is the directory in which the build is done.
# CKSFV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CKSFV_IPK_DIR is the directory in which the ipk is built.
# CKSFV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CKSFV_BUILD_DIR=$(BUILD_DIR)/cksfv
CKSFV_SOURCE_DIR=$(SOURCE_DIR)/cksfv
CKSFV_IPK_DIR=$(BUILD_DIR)/cksfv-$(CKSFV_VERSION)-ipk
CKSFV_IPK=$(BUILD_DIR)/cksfv_$(CKSFV_VERSION)-$(CKSFV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: cksfv-source cksfv-unpack cksfv cksfv-stage cksfv-ipk cksfv-clean cksfv-dirclean cksfv-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CKSFV_SOURCE):
	$(WGET) -P $(@D) $(CKSFV_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cksfv-source: $(DL_DIR)/$(CKSFV_SOURCE) $(CKSFV_PATCHES)

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
$(CKSFV_BUILD_DIR)/.configured: $(DL_DIR)/$(CKSFV_SOURCE) $(CKSFV_PATCHES) make/cksfv.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CKSFV_DIR) $(@D)
	$(CKSFV_UNZIP) $(DL_DIR)/$(CKSFV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CKSFV_PATCHES)" ; \
		then cat $(CKSFV_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CKSFV_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CKSFV_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CKSFV_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		./configure \
		--prefix=/opt \
		--package-prefix=$(CKSFV_IPK_DIR) \
	)
#	$(PATCH_LIBTOOL) $(CKSFV_BUILD_DIR)/libtool
	touch $@

cksfv-unpack: $(CKSFV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CKSFV_BUILD_DIR)/.built: $(CKSFV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CKSFV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CKSFV_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
cksfv: $(CKSFV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(CKSFV_BUILD_DIR)/.staged: $(CKSFV_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#cksfv-stage: $(CKSFV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cksfv
#
$(CKSFV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cksfv" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CKSFV_PRIORITY)" >>$@
	@echo "Section: $(CKSFV_SECTION)" >>$@
	@echo "Version: $(CKSFV_VERSION)-$(CKSFV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CKSFV_MAINTAINER)" >>$@
	@echo "Source: $(CKSFV_SITE)/$(CKSFV_SOURCE)" >>$@
	@echo "Description: $(CKSFV_DESCRIPTION)" >>$@
	@echo "Depends: $(CKSFV_DEPENDS)" >>$@
	@echo "Suggests: $(CKSFV_SUGGESTS)" >>$@
	@echo "Conflicts: $(CKSFV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CKSFV_IPK_DIR)/opt/sbin or $(CKSFV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CKSFV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CKSFV_IPK_DIR)/opt/etc/cksfv/...
# Documentation files should be installed in $(CKSFV_IPK_DIR)/opt/doc/cksfv/...
# Daemon startup scripts should be installed in $(CKSFV_IPK_DIR)/opt/etc/init.d/S??cksfv
#
# You may need to patch your application to make it use these locations.
#
$(CKSFV_IPK): $(CKSFV_BUILD_DIR)/.built
	rm -rf $(CKSFV_IPK_DIR) $(BUILD_DIR)/cksfv_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CKSFV_BUILD_DIR) DESTDIR=$(CKSFV_IPK_DIR) install
	$(STRIP_COMMAND) $(CKSFV_IPK_DIR)/opt/bin/cksfv
	$(MAKE) $(CKSFV_IPK_DIR)/CONTROL/control
	echo $(CKSFV_CONFFILES) | sed -e 's/ /\n/g' > $(CKSFV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CKSFV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cksfv-ipk: $(CKSFV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cksfv-clean:
	rm -f $(CKSFV_BUILD_DIR)/.built
	-$(MAKE) -C $(CKSFV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cksfv-dirclean:
	rm -rf $(BUILD_DIR)/$(CKSFV_DIR) $(CKSFV_BUILD_DIR) $(CKSFV_IPK_DIR) $(CKSFV_IPK)
#
#
# Some sanity check for the package.
#
cksfv-check: $(CKSFV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
