###########################################################
#
# rdate
#
###########################################################
#
# RDATE_VERSION, RDATE_SITE and RDATE_SOURCE define
# the upstream location of the source code for the package.
# RDATE_DIR is the directory which is created when the source
# archive is unpacked.
# RDATE_UNZIP is the command used to unzip the source.
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
RDATE_SITE=http://www.aelius.com/njh/rdate
RDATE_VERSION=1.5
RDATE_SOURCE=rdate-$(RDATE_VERSION).tar.gz
RDATE_DIR=rdate-$(RDATE_VERSION)
RDATE_UNZIP=zcat
RDATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RDATE_DESCRIPTION=Using RFC868, retrieves a remote date and time and sets the local time
RDATE_SECTION=network
RDATE_PRIORITY=optional
RDATE_DEPENDS=
RDATE_SUGGESTS=
RDATE_CONFLICTS=

#
# RDATE_IPK_VERSION should be incremented when the ipk changes.
#
RDATE_IPK_VERSION=1

#
# RDATE_CONFFILES should be a list of user-editable files
#RDATE_CONFFILES=/opt/etc/rdate.conf /opt/etc/init.d/SXXrdate

#
# RDATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# RDATE_PATCHES=$(RDATE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RDATE_CPPFLAGS=
RDATE_LDFLAGS=

#
# RDATE_BUILD_DIR is the directory in which the build is done.
# RDATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RDATE_IPK_DIR is the directory in which the ipk is built.
# RDATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RDATE_BUILD_DIR=$(BUILD_DIR)/rdate
RDATE_SOURCE_DIR=$(SOURCE_DIR)/rdate
RDATE_IPK_DIR=$(BUILD_DIR)/rdate-$(RDATE_VERSION)-ipk
RDATE_IPK=$(BUILD_DIR)/rdate_$(RDATE_VERSION)-$(RDATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rdate-source rdate-unpack rdate rdate-stage rdate-ipk rdate-clean rdate-dirclean rdate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RDATE_SOURCE):
	$(WGET) -P $(@D) $(RDATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rdate-source: $(DL_DIR)/$(RDATE_SOURCE) $(RDATE_PATCHES)

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
$(RDATE_BUILD_DIR)/.configured: $(DL_DIR)/$(RDATE_SOURCE) $(RDATE_PATCHES) make/rdate.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RDATE_DIR) $(@D)
	$(RDATE_UNZIP) $(DL_DIR)/$(RDATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RDATE_PATCHES)" ; \
		then cat $(RDATE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RDATE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RDATE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RDATE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RDATE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RDATE_LDFLAGS)" \
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

rdate-unpack: $(RDATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RDATE_BUILD_DIR)/.built: $(RDATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
rdate: $(RDATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(RDATE_BUILD_DIR)/.staged: $(RDATE_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#rdate-stage: $(RDATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rdate
#
$(RDATE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rdate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RDATE_PRIORITY)" >>$@
	@echo "Section: $(RDATE_SECTION)" >>$@
	@echo "Version: $(RDATE_VERSION)-$(RDATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RDATE_MAINTAINER)" >>$@
	@echo "Source: $(RDATE_SITE)/$(RDATE_SOURCE)" >>$@
	@echo "Description: $(RDATE_DESCRIPTION)" >>$@
	@echo "Depends: $(RDATE_DEPENDS)" >>$@
	@echo "Suggests: $(RDATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(RDATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RDATE_IPK_DIR)/opt/sbin or $(RDATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RDATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RDATE_IPK_DIR)/opt/etc/rdate/...
# Documentation files should be installed in $(RDATE_IPK_DIR)/opt/doc/rdate/...
# Daemon startup scripts should be installed in $(RDATE_IPK_DIR)/opt/etc/init.d/S??rdate
#
# You may need to patch your application to make it use these locations.
#
$(RDATE_IPK): $(RDATE_BUILD_DIR)/.built
	rm -rf $(RDATE_IPK_DIR) $(BUILD_DIR)/rdate_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RDATE_BUILD_DIR) DESTDIR=$(RDATE_IPK_DIR) install-strip
	$(MAKE) $(RDATE_IPK_DIR)/CONTROL/control
	echo $(RDATE_CONFFILES) | sed -e 's/ /\n/g' > $(RDATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RDATE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RDATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rdate-ipk: $(RDATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rdate-clean:
	rm -f $(RDATE_BUILD_DIR)/.built
	-$(MAKE) -C $(RDATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rdate-dirclean:
	rm -rf $(BUILD_DIR)/$(RDATE_DIR) $(RDATE_BUILD_DIR) $(RDATE_IPK_DIR) $(RDATE_IPK)
#
#
# Some sanity check for the package.
#
rdate-check: $(RDATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
