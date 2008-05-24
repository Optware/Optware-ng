###########################################################
#
# mpg123
#
###########################################################
#
# MPG123_VERSION, MPG123_SITE and MPG123_SOURCE define
# the upstream location of the source code for the package.
# MPG123_DIR is the directory which is created when the source
# archive is unpacked.
# MPG123_UNZIP is the command used to unzip the source.
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
MPG123_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mpg123
MPG123_VERSION=1.4.3
MPG123_SOURCE=mpg123-$(MPG123_VERSION).tar.bz2
MPG123_DIR=mpg123-$(MPG123_VERSION)
MPG123_UNZIP=bzcat
MPG123_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPG123_DESCRIPTION=Fast console MPEG Audio Player.
MPG123_SECTION=audio
MPG123_PRIORITY=optional
MPG123_DEPENDS=
MPG123_SUGGESTS=
MPG123_CONFLICTS=

#
# MPG123_IPK_VERSION should be incremented when the ipk changes.
#
MPG123_IPK_VERSION=1

#
# MPG123_CONFFILES should be a list of user-editable files
#MPG123_CONFFILES=/opt/etc/mpg123.conf /opt/etc/init.d/SXXmpg123

#
# MPG123_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MPG123_PATCHES=$(MPG123_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPG123_CPPFLAGS=
MPG123_LDFLAGS=

MPG123_CONFIG_ARG=--with-cpu=generic_nofpu --with-audio=oss

#
# MPG123_BUILD_DIR is the directory in which the build is done.
# MPG123_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPG123_IPK_DIR is the directory in which the ipk is built.
# MPG123_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPG123_BUILD_DIR=$(BUILD_DIR)/mpg123
MPG123_SOURCE_DIR=$(SOURCE_DIR)/mpg123
MPG123_IPK_DIR=$(BUILD_DIR)/mpg123-$(MPG123_VERSION)-ipk
MPG123_IPK=$(BUILD_DIR)/mpg123_$(MPG123_VERSION)-$(MPG123_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpg123-source mpg123-unpack mpg123 mpg123-stage mpg123-ipk mpg123-clean mpg123-dirclean mpg123-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPG123_SOURCE):
	$(WGET) -P $(@D) $(MPG123_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpg123-source: $(DL_DIR)/$(MPG123_SOURCE) $(MPG123_PATCHES)

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
$(MPG123_BUILD_DIR)/.configured: $(DL_DIR)/$(MPG123_SOURCE) $(MPG123_PATCHES) make/mpg123.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MPG123_DIR) $(@D)
	$(MPG123_UNZIP) $(DL_DIR)/$(MPG123_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPG123_PATCHES)" ; \
		then cat $(MPG123_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPG123_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPG123_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MPG123_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPG123_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPG123_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MPG123_CONFIG_ARG) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mpg123-unpack: $(MPG123_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPG123_BUILD_DIR)/.built: $(MPG123_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
mpg123: $(MPG123_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPG123_BUILD_DIR)/.staged: $(MPG123_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mpg123-stage: $(MPG123_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpg123
#
$(MPG123_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpg123" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPG123_PRIORITY)" >>$@
	@echo "Section: $(MPG123_SECTION)" >>$@
	@echo "Version: $(MPG123_VERSION)-$(MPG123_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPG123_MAINTAINER)" >>$@
	@echo "Source: $(MPG123_SITE)/$(MPG123_SOURCE)" >>$@
	@echo "Description: $(MPG123_DESCRIPTION)" >>$@
	@echo "Depends: $(MPG123_DEPENDS)" >>$@
	@echo "Suggests: $(MPG123_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPG123_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPG123_IPK_DIR)/opt/sbin or $(MPG123_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPG123_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPG123_IPK_DIR)/opt/etc/mpg123/...
# Documentation files should be installed in $(MPG123_IPK_DIR)/opt/doc/mpg123/...
# Daemon startup scripts should be installed in $(MPG123_IPK_DIR)/opt/etc/init.d/S??mpg123
#
# You may need to patch your application to make it use these locations.
#
$(MPG123_IPK): $(MPG123_BUILD_DIR)/.built
	rm -rf $(MPG123_IPK_DIR) $(BUILD_DIR)/mpg123_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPG123_BUILD_DIR) DESTDIR=$(MPG123_IPK_DIR) program_transform_name="" install-strip
	$(MAKE) $(MPG123_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPG123_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpg123-ipk: $(MPG123_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpg123-clean:
	rm -f $(MPG123_BUILD_DIR)/.built
	-$(MAKE) -C $(MPG123_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpg123-dirclean:
	rm -rf $(BUILD_DIR)/$(MPG123_DIR) $(MPG123_BUILD_DIR) $(MPG123_IPK_DIR) $(MPG123_IPK)
#
#
# Some sanity check for the package.
#
mpg123-check: $(MPG123_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPG123_IPK)
