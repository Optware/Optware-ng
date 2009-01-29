###########################################################
#
# libsamplerate
#
###########################################################
#
# LIBSAMPLERATE_VERSION, LIBSAMPLERATE_SITE and LIBSAMPLERATE_SOURCE define
# the upstream location of the source code for the package.
# LIBSAMPLERATE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSAMPLERATE_UNZIP is the command used to unzip the source.
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
LIBSAMPLERATE_SITE=http://www.mega-nerd.com/SRC
LIBSAMPLERATE_VERSION=0.1.6
LIBSAMPLERATE_SOURCE=libsamplerate-$(LIBSAMPLERATE_VERSION).tar.gz
LIBSAMPLERATE_DIR=libsamplerate-$(LIBSAMPLERATE_VERSION)
LIBSAMPLERATE_UNZIP=zcat
LIBSAMPLERATE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSAMPLERATE_DESCRIPTION=Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio.
LIBSAMPLERATE_SECTION=audio
LIBSAMPLERATE_PRIORITY=optional
LIBSAMPLERATE_DEPENDS=
LIBSAMPLERATE_SUGGESTS=
LIBSAMPLERATE_CONFLICTS=

#
# LIBSAMPLERATE_IPK_VERSION should be incremented when the ipk changes.
#
LIBSAMPLERATE_IPK_VERSION=1

#
# LIBSAMPLERATE_CONFFILES should be a list of user-editable files
#LIBSAMPLERATE_CONFFILES=/opt/etc/libsamplerate.conf /opt/etc/init.d/SXXlibsamplerate

#
# LIBSAMPLERATE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSAMPLERATE_PATCHES=$(LIBSAMPLERATE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSAMPLERATE_CPPFLAGS=
LIBSAMPLERATE_LDFLAGS=

#
# LIBSAMPLERATE_BUILD_DIR is the directory in which the build is done.
# LIBSAMPLERATE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSAMPLERATE_IPK_DIR is the directory in which the ipk is built.
# LIBSAMPLERATE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSAMPLERATE_BUILD_DIR=$(BUILD_DIR)/libsamplerate
LIBSAMPLERATE_SOURCE_DIR=$(SOURCE_DIR)/libsamplerate
LIBSAMPLERATE_IPK_DIR=$(BUILD_DIR)/libsamplerate-$(LIBSAMPLERATE_VERSION)-ipk
LIBSAMPLERATE_IPK=$(BUILD_DIR)/libsamplerate_$(LIBSAMPLERATE_VERSION)-$(LIBSAMPLERATE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libsamplerate-source libsamplerate-unpack libsamplerate libsamplerate-stage libsamplerate-ipk libsamplerate-clean libsamplerate-dirclean libsamplerate-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBSAMPLERATE_SOURCE):
	$(WGET) -P $(@D) $(LIBSAMPLERATE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsamplerate-source: $(DL_DIR)/$(LIBSAMPLERATE_SOURCE) $(LIBSAMPLERATE_PATCHES)

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
$(LIBSAMPLERATE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSAMPLERATE_SOURCE) $(LIBSAMPLERATE_PATCHES) make/libsamplerate.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBSAMPLERATE_DIR) $(@D)
	$(LIBSAMPLERATE_UNZIP) $(DL_DIR)/$(LIBSAMPLERATE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSAMPLERATE_PATCHES)" ; \
		then cat $(LIBSAMPLERATE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBSAMPLERATE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSAMPLERATE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBSAMPLERATE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSAMPLERATE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSAMPLERATE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libsamplerate-unpack: $(LIBSAMPLERATE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSAMPLERATE_BUILD_DIR)/.built: $(LIBSAMPLERATE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libsamplerate: $(LIBSAMPLERATE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSAMPLERATE_BUILD_DIR)/.staged: $(LIBSAMPLERATE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libsamplerate.la
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/samplerate.pc
	touch $@

libsamplerate-stage: $(LIBSAMPLERATE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsamplerate
#
$(LIBSAMPLERATE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libsamplerate" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSAMPLERATE_PRIORITY)" >>$@
	@echo "Section: $(LIBSAMPLERATE_SECTION)" >>$@
	@echo "Version: $(LIBSAMPLERATE_VERSION)-$(LIBSAMPLERATE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSAMPLERATE_MAINTAINER)" >>$@
	@echo "Source: $(LIBSAMPLERATE_SITE)/$(LIBSAMPLERATE_SOURCE)" >>$@
	@echo "Description: $(LIBSAMPLERATE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSAMPLERATE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSAMPLERATE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSAMPLERATE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSAMPLERATE_IPK_DIR)/opt/sbin or $(LIBSAMPLERATE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSAMPLERATE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSAMPLERATE_IPK_DIR)/opt/etc/libsamplerate/...
# Documentation files should be installed in $(LIBSAMPLERATE_IPK_DIR)/opt/doc/libsamplerate/...
# Daemon startup scripts should be installed in $(LIBSAMPLERATE_IPK_DIR)/opt/etc/init.d/S??libsamplerate
#
# You may need to patch your application to make it use these locations.
#
$(LIBSAMPLERATE_IPK): $(LIBSAMPLERATE_BUILD_DIR)/.built
	rm -rf $(LIBSAMPLERATE_IPK_DIR) $(BUILD_DIR)/libsamplerate_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSAMPLERATE_BUILD_DIR) install-strip \
		DESTDIR=$(LIBSAMPLERATE_IPK_DIR) transform=''
	$(MAKE) $(LIBSAMPLERATE_IPK_DIR)/CONTROL/control
	echo $(LIBSAMPLERATE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSAMPLERATE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSAMPLERATE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsamplerate-ipk: $(LIBSAMPLERATE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsamplerate-clean:
	rm -f $(LIBSAMPLERATE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSAMPLERATE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsamplerate-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSAMPLERATE_DIR) $(LIBSAMPLERATE_BUILD_DIR) $(LIBSAMPLERATE_IPK_DIR) $(LIBSAMPLERATE_IPK)
#
#
# Some sanity check for the package.
#
libsamplerate-check: $(LIBSAMPLERATE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
