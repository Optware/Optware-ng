###########################################################
#
# libsndfile
#
###########################################################
#
# LIBSNDFILE_VERSION, LIBSNDFILE_SITE and LIBSNDFILE_SOURCE define
# the upstream location of the source code for the package.
# LIBSNDFILE_DIR is the directory which is created when the source
# archive is unpacked.
# LIBSNDFILE_UNZIP is the command used to unzip the source.
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
LIBSNDFILE_SITE=http://www.mega-nerd.com/libsndfile
ifdef NO_BUILTIN_MATH
LIBSNDFILE_VERSION=1.0.17
else
LIBSNDFILE_VERSION=1.0.18
endif
LIBSNDFILE_SOURCE=libsndfile-$(LIBSNDFILE_VERSION).tar.gz
LIBSNDFILE_DIR=libsndfile-$(LIBSNDFILE_VERSION)
LIBSNDFILE_UNZIP=zcat
LIBSNDFILE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBSNDFILE_DESCRIPTION=A C library for reading and writing files containing sampled sound (such as MS Windows WAV and the Apple/SGI AIFF format) through one standard library interface.
LIBSNDFILE_SECTION=audio
LIBSNDFILE_PRIORITY=optional
LIBSNDFILE_DEPENDS=
LIBSNDFILE_SUGGESTS=
LIBSNDFILE_CONFLICTS=

#
# LIBSNDFILE_IPK_VERSION should be incremented when the ipk changes.
#
LIBSNDFILE_IPK_VERSION=1

#
# LIBSNDFILE_CONFFILES should be a list of user-editable files
#LIBSNDFILE_CONFFILES=/opt/etc/libsndfile.conf /opt/etc/init.d/SXXlibsndfile

#
# LIBSNDFILE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBSNDFILE_PATCHES=$(LIBSNDFILE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBSNDFILE_CPPFLAGS=
LIBSNDFILE_LDFLAGS=

#
# LIBSNDFILE_BUILD_DIR is the directory in which the build is done.
# LIBSNDFILE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBSNDFILE_IPK_DIR is the directory in which the ipk is built.
# LIBSNDFILE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBSNDFILE_BUILD_DIR=$(BUILD_DIR)/libsndfile
LIBSNDFILE_SOURCE_DIR=$(SOURCE_DIR)/libsndfile
LIBSNDFILE_IPK_DIR=$(BUILD_DIR)/libsndfile-$(LIBSNDFILE_VERSION)-ipk
LIBSNDFILE_IPK=$(BUILD_DIR)/libsndfile_$(LIBSNDFILE_VERSION)-$(LIBSNDFILE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libsndfile-source libsndfile-unpack libsndfile libsndfile-stage libsndfile-ipk libsndfile-clean libsndfile-dirclean libsndfile-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBSNDFILE_SOURCE):
	$(WGET) -P $(@D) $(LIBSNDFILE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libsndfile-source: $(DL_DIR)/$(LIBSNDFILE_SOURCE) $(LIBSNDFILE_PATCHES)

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
$(LIBSNDFILE_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBSNDFILE_SOURCE) $(LIBSNDFILE_PATCHES) make/libsndfile.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBSNDFILE_DIR) $(LIBSNDFILE_BUILD_DIR)
	$(LIBSNDFILE_UNZIP) $(DL_DIR)/$(LIBSNDFILE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBSNDFILE_PATCHES)" ; \
		then cat $(LIBSNDFILE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBSNDFILE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBSNDFILE_DIR)" != "$(LIBSNDFILE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBSNDFILE_DIR) $(LIBSNDFILE_BUILD_DIR) ; \
	fi
	(cd $(LIBSNDFILE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBSNDFILE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBSNDFILE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-flac \
		--disable-sqlite \
		--disable-alsa \
	)
	$(PATCH_LIBTOOL) $(LIBSNDFILE_BUILD_DIR)/libtool
	touch $@

libsndfile-unpack: $(LIBSNDFILE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBSNDFILE_BUILD_DIR)/.built: $(LIBSNDFILE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LIBSNDFILE_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
libsndfile: $(LIBSNDFILE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBSNDFILE_BUILD_DIR)/.staged: $(LIBSNDFILE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LIBSNDFILE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/sndfile.pc
	touch $@

libsndfile-stage: $(LIBSNDFILE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libsndfile
#
$(LIBSNDFILE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: libsndfile" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBSNDFILE_PRIORITY)" >>$@
	@echo "Section: $(LIBSNDFILE_SECTION)" >>$@
	@echo "Version: $(LIBSNDFILE_VERSION)-$(LIBSNDFILE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBSNDFILE_MAINTAINER)" >>$@
	@echo "Source: $(LIBSNDFILE_SITE)/$(LIBSNDFILE_SOURCE)" >>$@
	@echo "Description: $(LIBSNDFILE_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBSNDFILE_DEPENDS)" >>$@
	@echo "Suggests: $(LIBSNDFILE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBSNDFILE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBSNDFILE_IPK_DIR)/opt/sbin or $(LIBSNDFILE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBSNDFILE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBSNDFILE_IPK_DIR)/opt/etc/libsndfile/...
# Documentation files should be installed in $(LIBSNDFILE_IPK_DIR)/opt/doc/libsndfile/...
# Daemon startup scripts should be installed in $(LIBSNDFILE_IPK_DIR)/opt/etc/init.d/S??libsndfile
#
# You may need to patch your application to make it use these locations.
#
$(LIBSNDFILE_IPK): $(LIBSNDFILE_BUILD_DIR)/.built
	rm -rf $(LIBSNDFILE_IPK_DIR) $(BUILD_DIR)/libsndfile_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBSNDFILE_BUILD_DIR) DESTDIR=$(LIBSNDFILE_IPK_DIR) install-strip transform=''
#	install -d $(LIBSNDFILE_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBSNDFILE_SOURCE_DIR)/libsndfile.conf $(LIBSNDFILE_IPK_DIR)/opt/etc/libsndfile.conf
#	install -d $(LIBSNDFILE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBSNDFILE_SOURCE_DIR)/rc.libsndfile $(LIBSNDFILE_IPK_DIR)/opt/etc/init.d/SXXlibsndfile
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSNDFILE_IPK_DIR)/opt/etc/init.d/SXXlibsndfile
	$(MAKE) $(LIBSNDFILE_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBSNDFILE_SOURCE_DIR)/postinst $(LIBSNDFILE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSNDFILE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBSNDFILE_SOURCE_DIR)/prerm $(LIBSNDFILE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBSNDFILE_IPK_DIR)/CONTROL/prerm
	echo $(LIBSNDFILE_CONFFILES) | sed -e 's/ /\n/g' > $(LIBSNDFILE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBSNDFILE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libsndfile-ipk: $(LIBSNDFILE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libsndfile-clean:
	rm -f $(LIBSNDFILE_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBSNDFILE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libsndfile-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBSNDFILE_DIR) $(LIBSNDFILE_BUILD_DIR) $(LIBSNDFILE_IPK_DIR) $(LIBSNDFILE_IPK)
#
#
# Some sanity check for the package.
#
libsndfile-check: $(LIBSNDFILE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
