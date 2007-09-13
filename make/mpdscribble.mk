###########################################################
#
# mpdscribble
#
###########################################################
#
# MPDSCRIBBLE_VERSION, MPDSCRIBBLE_SITE and MPDSCRIBBLE_SOURCE define
# the upstream location of the source code for the package.
# MPDSCRIBBLE_DIR is the directory which is created when the source
# archive is unpacked.
# MPDSCRIBBLE_UNZIP is the command used to unzip the source.
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
MPDSCRIBBLE_SITE=http://www.frob.nl/projects/scribble
MPDSCRIBBLE_VERSION=0.2.12
MPDSCRIBBLE_SOURCE=mpdscribble-$(MPDSCRIBBLE_VERSION).tar.gz
MPDSCRIBBLE_DIR=mpdscribble-$(MPDSCRIBBLE_VERSION)
MPDSCRIBBLE_UNZIP=zcat
MPDSCRIBBLE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPDSCRIBBLE_DESCRIPTION=Last.fm reporting client for mpd.
MPDSCRIBBLE_SECTION=sound
MPDSCRIBBLE_PRIORITY=optional
MPDSCRIBBLE_DEPENDS=libsoup
MPDSCRIBBLE_SUGGESTS=
MPDSCRIBBLE_CONFLICTS=

#
# MPDSCRIBBLE_IPK_VERSION should be incremented when the ipk changes.
#
MPDSCRIBBLE_IPK_VERSION=1

#
# MPDSCRIBBLE_CONFFILES should be a list of user-editable files
#MPDSCRIBBLE_CONFFILES=/opt/etc/mpdscribble.conf /opt/etc/init.d/SXXmpdscribble

#
# MPDSCRIBBLE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MPDSCRIBBLE_PATCHES=$(MPDSCRIBBLE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPDSCRIBBLE_CPPFLAGS=
MPDSCRIBBLE_LDFLAGS=

#
# MPDSCRIBBLE_BUILD_DIR is the directory in which the build is done.
# MPDSCRIBBLE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPDSCRIBBLE_IPK_DIR is the directory in which the ipk is built.
# MPDSCRIBBLE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPDSCRIBBLE_BUILD_DIR=$(BUILD_DIR)/mpdscribble
MPDSCRIBBLE_SOURCE_DIR=$(SOURCE_DIR)/mpdscribble
MPDSCRIBBLE_IPK_DIR=$(BUILD_DIR)/mpdscribble-$(MPDSCRIBBLE_VERSION)-ipk
MPDSCRIBBLE_IPK=$(BUILD_DIR)/mpdscribble_$(MPDSCRIBBLE_VERSION)-$(MPDSCRIBBLE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpdscribble-source mpdscribble-unpack mpdscribble mpdscribble-stage mpdscribble-ipk mpdscribble-clean mpdscribble-dirclean mpdscribble-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPDSCRIBBLE_SOURCE):
	$(WGET) -P $(DL_DIR) $(MPDSCRIBBLE_SITE)/$(MPDSCRIBBLE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MPDSCRIBBLE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpdscribble-source: $(DL_DIR)/$(MPDSCRIBBLE_SOURCE) $(MPDSCRIBBLE_PATCHES)

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
$(MPDSCRIBBLE_BUILD_DIR)/.configured: $(DL_DIR)/$(MPDSCRIBBLE_SOURCE) $(MPDSCRIBBLE_PATCHES) make/mpdscribble.mk
	$(MAKE) libsoup-stage
	rm -rf $(BUILD_DIR)/$(MPDSCRIBBLE_DIR) $(MPDSCRIBBLE_BUILD_DIR)
	$(MPDSCRIBBLE_UNZIP) $(DL_DIR)/$(MPDSCRIBBLE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPDSCRIBBLE_PATCHES)" ; \
		then cat $(MPDSCRIBBLE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPDSCRIBBLE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPDSCRIBBLE_DIR)" != "$(MPDSCRIBBLE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPDSCRIBBLE_DIR) $(MPDSCRIBBLE_BUILD_DIR) ; \
	fi
	(cd $(MPDSCRIBBLE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPDSCRIBBLE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPDSCRIBBLE_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MPDSCRIBBLE_BUILD_DIR)/libtool
	touch $@

mpdscribble-unpack: $(MPDSCRIBBLE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPDSCRIBBLE_BUILD_DIR)/.built: $(MPDSCRIBBLE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MPDSCRIBBLE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mpdscribble: $(MPDSCRIBBLE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPDSCRIBBLE_BUILD_DIR)/.staged: $(MPDSCRIBBLE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MPDSCRIBBLE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mpdscribble-stage: $(MPDSCRIBBLE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpdscribble
#
$(MPDSCRIBBLE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpdscribble" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPDSCRIBBLE_PRIORITY)" >>$@
	@echo "Section: $(MPDSCRIBBLE_SECTION)" >>$@
	@echo "Version: $(MPDSCRIBBLE_VERSION)-$(MPDSCRIBBLE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPDSCRIBBLE_MAINTAINER)" >>$@
	@echo "Source: $(MPDSCRIBBLE_SITE)/$(MPDSCRIBBLE_SOURCE)" >>$@
	@echo "Description: $(MPDSCRIBBLE_DESCRIPTION)" >>$@
	@echo "Depends: $(MPDSCRIBBLE_DEPENDS)" >>$@
	@echo "Suggests: $(MPDSCRIBBLE_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPDSCRIBBLE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPDSCRIBBLE_IPK_DIR)/opt/sbin or $(MPDSCRIBBLE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPDSCRIBBLE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPDSCRIBBLE_IPK_DIR)/opt/etc/mpdscribble/...
# Documentation files should be installed in $(MPDSCRIBBLE_IPK_DIR)/opt/doc/mpdscribble/...
# Daemon startup scripts should be installed in $(MPDSCRIBBLE_IPK_DIR)/opt/etc/init.d/S??mpdscribble
#
# You may need to patch your application to make it use these locations.
#
$(MPDSCRIBBLE_IPK): $(MPDSCRIBBLE_BUILD_DIR)/.built
	rm -rf $(MPDSCRIBBLE_IPK_DIR) $(BUILD_DIR)/mpdscribble_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPDSCRIBBLE_BUILD_DIR) DESTDIR=$(MPDSCRIBBLE_IPK_DIR) install-strip
	$(MAKE) $(MPDSCRIBBLE_IPK_DIR)/CONTROL/control
	echo $(MPDSCRIBBLE_CONFFILES) | sed -e 's/ /\n/g' > $(MPDSCRIBBLE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPDSCRIBBLE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpdscribble-ipk: $(MPDSCRIBBLE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpdscribble-clean:
	rm -f $(MPDSCRIBBLE_BUILD_DIR)/.built
	-$(MAKE) -C $(MPDSCRIBBLE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpdscribble-dirclean:
	rm -rf $(BUILD_DIR)/$(MPDSCRIBBLE_DIR) $(MPDSCRIBBLE_BUILD_DIR) $(MPDSCRIBBLE_IPK_DIR) $(MPDSCRIBBLE_IPK)
#
#
# Some sanity check for the package.
#
mpdscribble-check: $(MPDSCRIBBLE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPDSCRIBBLE_IPK)
