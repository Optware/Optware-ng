###########################################################
#
# libshout
#
###########################################################
#
# LIBSHOUT_VERSION, LIBSHOUT_SITE and LIBSHOUT_SOURCE define
# the upstream location of the source code for the package.
# LIBSHOUT_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSHOUT_UNZIP is the command used to unzip the source.
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
LIBSHOUT_SITE=http://downloads.us.xiph.org/releases/libshout
LIBSHOUT_VERSION=2.2.2
LIBSHOUT_SOURCE=libshout-$(LIBSHOUT_VERSION).tar.gz
LIBSHOUT_DIR=libshout-$(LIBSHOUT_VERSION)
LIBSHOUT_UNZIP=zcat
LIBSHOUT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSHOUT_DESCRIPTION=Library which can be used to write a source client like ices.
LIBSHOUT_SECTION=audio
LIBSHOUT_PRIORITY=optional
LIBSHOUT_DEPENDS=libvorbis, speex
LIBSHOUT_SUGGESTS=
LIBSHOUT_CONFLICTS=

#
# LIBSHOUT_IPK_VERSION should be incremented when the ipk changes.
#
LIBSHOUT_IPK_VERSION=2

#
# LIBSHOUT_CONFFILES should be a list of user-editable files
#LIBSHOUT_CONFFILES=/opt/etc/libshout.conf /opt/etc/init.d/SXXlibshout

#
# LIBSHOUT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSHOUT_PATCHES=$(LIBSHOUT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSHOUT_CPPFLAGS=
LIBSHOUT_LDFLAGS=

#
# LIBSHOUT_BUILD_DIR is the directory in which the build is done.
# LIBSHOUT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSHOUT_IPK_DIR is the directory in which the ipk is built.
# LIBSHOUT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSHOUT_BUILD_DIR=$(BUILD_DIR)/libshout
LIBSHOUT_SOURCE_DIR=$(SOURCE_DIR)/libshout
LIBSHOUT_IPK_DIR=$(BUILD_DIR)/libshout-$(LIBSHOUT_VERSION)-ipk
LIBSHOUT_IPK=$(BUILD_DIR)/libshout_$(LIBSHOUT_VERSION)-$(LIBSHOUT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libshout-source libshout-unpack libshout libshout-stage libshout-ipk libshout-clean libshout-dirclean libshout-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBSHOUT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBSHOUT_SITE)/$(LIBSHOUT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LIBSHOUT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libshout-source: $(DL_DIR)/$(LIBSHOUT_SOURCE) $(LIBSHOUT_PATCHES)

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
$(LIBSHOUT_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSHOUT_SOURCE) $(LIBSHOUT_PATCHES) make/libshout.mk
	$(MAKE) libogg-stage
	$(MAKE) speex-stage
	$(MAKE) libvorbis-stage
	rm -rf $(BUILD_DIR)/$(LIBSHOUT_DIR) $(LIBSHOUT_BUILD_DIR)
	$(LIBSHOUT_UNZIP) $(DL_DIR)/$(LIBSHOUT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSHOUT_PATCHES)" ; \
		then cat $(LIBSHOUT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBSHOUT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSHOUT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBSHOUT_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSHOUT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSHOUT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ogg=$(STAGING_PREFIX) \
		--with-speex=$(STAGING_PREFIX) \
		--with-vorbis=$(STAGING_PREFIX) \
		--without-theora \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libshout-unpack: $(LIBSHOUT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSHOUT_BUILD_DIR)/.built: $(LIBSHOUT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
libshout: $(LIBSHOUT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSHOUT_BUILD_DIR)/.staged: $(LIBSHOUT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
	       -e '/^Libs:/s|$$| -lspeex|' \
		$(STAGING_LIB_DIR)/pkgconfig/shout.pc
	rm -f $(STAGING_LIB_DIR)/libshout.la
	touch $@

libshout-stage: $(LIBSHOUT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libshout
#
$(LIBSHOUT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libshout" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSHOUT_PRIORITY)" >>$@
	@echo "Section: $(LIBSHOUT_SECTION)" >>$@
	@echo "Version: $(LIBSHOUT_VERSION)-$(LIBSHOUT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSHOUT_MAINTAINER)" >>$@
	@echo "Source: $(LIBSHOUT_SITE)/$(LIBSHOUT_SOURCE)" >>$@
	@echo "Description: $(LIBSHOUT_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSHOUT_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSHOUT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSHOUT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSHOUT_IPK_DIR)/opt/sbin or $(LIBSHOUT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSHOUT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSHOUT_IPK_DIR)/opt/etc/libshout/...
# Documentation files should be installed in $(LIBSHOUT_IPK_DIR)/opt/doc/libshout/...
# Daemon startup scripts should be installed in $(LIBSHOUT_IPK_DIR)/opt/etc/init.d/S??libshout
#
# You may need to patch your application to make it use these locations.
#
$(LIBSHOUT_IPK): $(LIBSHOUT_BUILD_DIR)/.built
	rm -rf $(LIBSHOUT_IPK_DIR) $(BUILD_DIR)/libshout_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSHOUT_BUILD_DIR) DESTDIR=$(LIBSHOUT_IPK_DIR) install-strip
	rm -f $(LIBSHOUT_IPK_DIR)/libshout.la
#	install -d $(LIBSHOUT_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBSHOUT_SOURCE_DIR)/libshout.conf $(LIBSHOUT_IPK_DIR)/opt/etc/libshout.conf
#	install -d $(LIBSHOUT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBSHOUT_SOURCE_DIR)/rc.libshout $(LIBSHOUT_IPK_DIR)/opt/etc/init.d/SXXlibshout
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSHOUT_IPK_DIR)/opt/etc/init.d/SXXlibshout
	$(MAKE) $(LIBSHOUT_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBSHOUT_SOURCE_DIR)/postinst $(LIBSHOUT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSHOUT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBSHOUT_SOURCE_DIR)/prerm $(LIBSHOUT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSHOUT_IPK_DIR)/CONTROL/prerm
	echo $(LIBSHOUT_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSHOUT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSHOUT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libshout-ipk: $(LIBSHOUT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libshout-clean:
	rm -f $(LIBSHOUT_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSHOUT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libshout-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSHOUT_DIR) $(LIBSHOUT_BUILD_DIR) $(LIBSHOUT_IPK_DIR) $(LIBSHOUT_IPK)
#
#
# Some sanity check for the package.
#
libshout-check: $(LIBSHOUT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBSHOUT_IPK)
