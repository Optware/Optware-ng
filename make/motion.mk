###########################################################
#
# motion
#
###########################################################

MOTION_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/motion
MOTION_VERSION=3.2.9
MOTION_SOURCE=motion-$(MOTION_VERSION).tar.gz
MOTION_DIR=motion-$(MOTION_VERSION)
MOTION_UNZIP=zcat
MOTION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOTION_DESCRIPTION=a software motion detector
MOTION_SECTION=misc
MOTION_PRIORITY=optional
ifeq ($(OPTWARE_TARGET),ds101g)
MOTION_DEPENDS=ffmpeg
else
MOTION_DEPENDS=ffmpeg,mysql
endif
MOTION_SUGGESTS=
MOTION_CONFLICTS=

#
# MOTION_IPK_VERSION should be incremented when the ipk changes.
#
MOTION_IPK_VERSION=1

#
# MOTION_CONFFILES should be a list of user-editable files
MOTION_CONFFILES=/opt/etc/motion.conf /opt/etc/init.d/S99motion

#
# MOTION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOTION_PATCHES=$(MOTION_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOTION_CPPFLAGS=-DFFMPEG_AVWRITEFRAME_NEWAPI
ifeq ($(OPTWARE_TARGET),ds101g)
MOTION_LDFLAGS="-Wl,-rpath,/usr/syno/mysql/lib/mysql"
else
MOTION_LDFLAGS="-Wl,-rpath,/opt/lib/mysql"
endif

#
# MOTION_BUILD_DIR is the directory in which the build is done.
# MOTION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOTION_IPK_DIR is the directory in which the ipk is built.
# MOTION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOTION_BUILD_DIR=$(BUILD_DIR)/motion
MOTION_SOURCE_DIR=$(SOURCE_DIR)/motion
MOTION_IPK_DIR=$(BUILD_DIR)/motion-$(MOTION_VERSION)-ipk
MOTION_IPK=$(BUILD_DIR)/motion_$(MOTION_VERSION)-$(MOTION_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOTION_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOTION_SITE)/$(MOTION_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
motion-source: $(DL_DIR)/$(MOTION_SOURCE) $(MOTION_PATCHES)

$(MOTION_BUILD_DIR)/.configured: $(DL_DIR)/$(MOTION_SOURCE) $(MOTION_PATCHES) make/motion.mk
	$(MAKE) libjpeg-stage ffmpeg-stage mysql-stage
	rm -rf $(BUILD_DIR)/$(MOTION_DIR) $(MOTION_BUILD_DIR)
	$(MOTION_UNZIP) $(DL_DIR)/$(MOTION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOTION_PATCHES)" ; \
		then cat $(MOTION_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOTION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOTION_DIR)" != "$(MOTION_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MOTION_DIR) $(MOTION_BUILD_DIR) ; \
	fi
	(cd $(MOTION_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MOTION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOTION_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-mysql=$(STAGING_PREFIX) \
		--without-pgsql \
		--with-ffmpeg=$(STAGING_PREFIX) \
	)
#	$(PATCH_LIBTOOL) $(MOTION_BUILD_DIR)/libtool
	touch $(MOTION_BUILD_DIR)/.configured

motion-unpack: $(MOTION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOTION_BUILD_DIR)/.built: $(MOTION_BUILD_DIR)/.configured
	rm -f $(MOTION_BUILD_DIR)/.built
	$(MAKE) -C $(MOTION_BUILD_DIR)
	touch $(MOTION_BUILD_DIR)/.built

#
# This is the build convenience target.
#
motion: $(MOTION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOTION_BUILD_DIR)/.staged: $(MOTION_BUILD_DIR)/.built
	rm -f $(MOTION_BUILD_DIR)/.staged
	$(MAKE) -C $(MOTION_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MOTION_BUILD_DIR)/.staged

motion-stage: $(MOTION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/motion
#
$(MOTION_IPK_DIR)/CONTROL/control:
	@install -d $(MOTION_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: motion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOTION_PRIORITY)" >>$@
	@echo "Section: $(MOTION_SECTION)" >>$@
	@echo "Version: $(MOTION_VERSION)-$(MOTION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOTION_MAINTAINER)" >>$@
	@echo "Source: $(MOTION_SITE)/$(MOTION_SOURCE)" >>$@
	@echo "Description: $(MOTION_DESCRIPTION)" >>$@
	@echo "Depends: $(MOTION_DEPENDS)" >>$@
	@echo "Suggests: $(MOTION_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOTION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOTION_IPK_DIR)/opt/sbin or $(MOTION_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOTION_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOTION_IPK_DIR)/opt/etc/motion/...
# Documentation files should be installed in $(MOTION_IPK_DIR)/opt/doc/motion/...
#
# You may need to patch your application to make it use these locations.
#
$(MOTION_IPK): $(MOTION_BUILD_DIR)/.built
	rm -rf $(MOTION_IPK_DIR) $(BUILD_DIR)/motion_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOTION_BUILD_DIR) DESTDIR=$(MOTION_IPK_DIR) install
	$(STRIP_COMMAND) $(MOTION_IPK_DIR)/opt/bin/motion
	install -d $(MOTION_IPK_DIR)/opt/etc/
	install -m 644 $(MOTION_SOURCE_DIR)/motion.conf $(MOTION_IPK_DIR)/opt/etc/motion.conf
	install -d $(MOTION_IPK_DIR)/opt/etc/init.d
	install -m 755 $(MOTION_SOURCE_DIR)/rc.motion $(MOTION_IPK_DIR)/opt/etc/init.d/S99motion
	$(MAKE) $(MOTION_IPK_DIR)/CONTROL/control
	install -m 755 $(MOTION_SOURCE_DIR)/postinst $(MOTION_IPK_DIR)/CONTROL/postinst
	install -m 755 $(MOTION_SOURCE_DIR)/prerm $(MOTION_IPK_DIR)/CONTROL/prerm
	echo $(MOTION_CONFFILES) | sed -e 's/ /\n/g' > $(MOTION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOTION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
motion-ipk: $(MOTION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
motion-clean:
	rm -f $(MOTION_BUILD_DIR)/.built
	-$(MAKE) -C $(MOTION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
motion-dirclean:
	rm -rf $(BUILD_DIR)/$(MOTION_DIR) $(MOTION_BUILD_DIR) $(MOTION_IPK_DIR) $(MOTION_IPK)

#
# Some sanity check for the package.
#
motion-check: $(MOTION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOTION_IPK)
