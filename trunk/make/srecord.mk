###########################################################
#
# srecord
#
###########################################################
#
# SRECORD_VERSION, SRECORD_SITE and SRECORD_SOURCE define
# the upstream location of the source code for the package.
# SRECORD_DIR is the directory which is created when the source
# archive is unpacked.
# SRECORD_UNZIP is the command used to unzip the source.
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
SRECORD_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/srecord
SRECORD_VERSION=1.51
SRECORD_SOURCE=srecord-$(SRECORD_VERSION).tar.gz
SRECORD_DIR=srecord-$(SRECORD_VERSION)
SRECORD_UNZIP=zcat
SRECORD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SRECORD_DESCRIPTION=A collection of powerful tools for manipulating EPROM load files
SRECORD_SECTION=utils
SRECORD_PRIORITY=optional
SRECORD_DEPENDS=libstdc++, libgcrypt
SRECORD_SUGGESTS=
SRECORD_CONFLICTS=

#
# SRECORD_IPK_VERSION should be incremented when the ipk changes.
#
SRECORD_IPK_VERSION=1

#
# SRECORD_CONFFILES should be a list of user-editable files
#SRECORD_CONFFILES=/opt/etc/srecord.conf /opt/etc/init.d/SXXsrecord

#
# SRECORD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SRECORD_PATCHES=$(SRECORD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SRECORD_CPPFLAGS=
SRECORD_LDFLAGS=

#
# SRECORD_BUILD_DIR is the directory in which the build is done.
# SRECORD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SRECORD_IPK_DIR is the directory in which the ipk is built.
# SRECORD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SRECORD_BUILD_DIR=$(BUILD_DIR)/srecord
SRECORD_SOURCE_DIR=$(SOURCE_DIR)/srecord
SRECORD_IPK_DIR=$(BUILD_DIR)/srecord-$(SRECORD_VERSION)-ipk
SRECORD_IPK=$(BUILD_DIR)/srecord_$(SRECORD_VERSION)-$(SRECORD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: srecord-source srecord-unpack srecord srecord-stage srecord-ipk srecord-clean srecord-dirclean srecord-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SRECORD_SOURCE):
	$(WGET) -P $(@D) $(SRECORD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
srecord-source: $(DL_DIR)/$(SRECORD_SOURCE) $(SRECORD_PATCHES)

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
$(SRECORD_BUILD_DIR)/.configured: $(DL_DIR)/$(SRECORD_SOURCE) $(SRECORD_PATCHES) make/srecord.mk
	$(MAKE) libstdc++-stage boost-stage libgcrypt-stage
	rm -rf $(BUILD_DIR)/$(SRECORD_DIR) $(@D)
	$(SRECORD_UNZIP) $(DL_DIR)/$(SRECORD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SRECORD_PATCHES)" ; \
		then cat $(SRECORD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SRECORD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SRECORD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SRECORD_DIR) $(@D) ; \
	fi
	sed -i -e '/^LIBS/s|$$| $$(LDFLAGS)|' $(@D)/Makefile.in
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SRECORD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SRECORD_LDFLAGS)" \
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

srecord-unpack: $(SRECORD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SRECORD_BUILD_DIR)/.built: $(SRECORD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
srecord: $(SRECORD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SRECORD_BUILD_DIR)/.staged: $(SRECORD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

srecord-stage: $(SRECORD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/srecord
#
$(SRECORD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: srecord" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SRECORD_PRIORITY)" >>$@
	@echo "Section: $(SRECORD_SECTION)" >>$@
	@echo "Version: $(SRECORD_VERSION)-$(SRECORD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SRECORD_MAINTAINER)" >>$@
	@echo "Source: $(SRECORD_SITE)/$(SRECORD_SOURCE)" >>$@
	@echo "Description: $(SRECORD_DESCRIPTION)" >>$@
	@echo "Depends: $(SRECORD_DEPENDS)" >>$@
	@echo "Suggests: $(SRECORD_SUGGESTS)" >>$@
	@echo "Conflicts: $(SRECORD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SRECORD_IPK_DIR)/opt/sbin or $(SRECORD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SRECORD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SRECORD_IPK_DIR)/opt/etc/srecord/...
# Documentation files should be installed in $(SRECORD_IPK_DIR)/opt/doc/srecord/...
# Daemon startup scripts should be installed in $(SRECORD_IPK_DIR)/opt/etc/init.d/S??srecord
#
# You may need to patch your application to make it use these locations.
#
$(SRECORD_IPK): $(SRECORD_BUILD_DIR)/.built
	rm -rf $(SRECORD_IPK_DIR) $(BUILD_DIR)/srecord_*_$(TARGET_ARCH).ipk
	rm -f $(SRECORD_BUILD_DIR)/.bindir $(SRECORD_BUILD_DIR)/man/.mandir
	$(MAKE) -C $(SRECORD_BUILD_DIR) DESTDIR=$(SRECORD_IPK_DIR) install
	$(STRIP_COMMAND) $(SRECORD_IPK_DIR)/opt/bin/srec_*
	$(MAKE) $(SRECORD_IPK_DIR)/CONTROL/control
	echo $(SRECORD_CONFFILES) | sed -e 's/ /\n/g' > $(SRECORD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SRECORD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
srecord-ipk: $(SRECORD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
srecord-clean:
	rm -f $(SRECORD_BUILD_DIR)/.built
	-$(MAKE) -C $(SRECORD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
srecord-dirclean:
	rm -rf $(BUILD_DIR)/$(SRECORD_DIR) $(SRECORD_BUILD_DIR) $(SRECORD_IPK_DIR) $(SRECORD_IPK)
#
#
# Some sanity check for the package.
#
srecord-check: $(SRECORD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
