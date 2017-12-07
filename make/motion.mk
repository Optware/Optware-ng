###########################################################
#
# motion
#
###########################################################

#MOTION_SVN=http://www.lavrsen.dk/svn/motion/trunk
MOTION_SVN_REVISION=000564
ifdef MOTION_SVN
MOTION_VERSION=3.2.12+svn$(MOTION_SVN_REVISION)
else
MOTION_VERSION=4.1
endif
MOTION_SITE=http://sourceforge.net/projects/motion/files/motion%20-%20$(shell echo $(MOTION_VERSION)|cut -d '.' -f 1-2)
MOTION_SOURCE=motion-release-$(MOTION_VERSION).tar.gz
MOTION_DIR=motion-release-$(MOTION_VERSION)
MOTION_UNZIP=zcat
MOTION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOTION_DESCRIPTION=a software motion detector
MOTION_SECTION=misc
MOTION_PRIORITY=optional
MOTION_DEPENDS=ffmpeg, libjpeg, sqlite
MOTION_SUGGESTS=mysql
MOTION_CONFLICTS=

#
# MOTION_IPK_VERSION should be incremented when the ipk changes.
#
MOTION_IPK_VERSION=1

#
# MOTION_CONFFILES should be a list of user-editable files
MOTION_CONFFILES=$(TARGET_PREFIX)/etc/motion.conf $(TARGET_PREFIX)/etc/init.d/S99motion

#
# MOTION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MOTION_PATCHES=\
$(MOTION_SOURCE_DIR)/deprecated_definitions.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOTION_CPPFLAGS=
MOTION_LDFLAGS="-Wl,-rpath,$(TARGET_PREFIX)/lib/mysql" -L$(STAGING_LIB_DIR)/mysql

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
ifdef MOTION_SVN
	( cd $(BUILD_DIR) ; \
		rm -rf $(MOTION_DIR) && \
		svn co -r $(MOTION_SVN_REVISION) $(MOTION_SVN) $(MOTION_DIR) && \
		tar -czf $@ $(MOTION_DIR) --exclude .svn && \
		rm -rf $(MOTION_DIR) \
	)
else
	$(WGET) -P $(@D) $(MOTION_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
motion-source: $(DL_DIR)/$(MOTION_SOURCE) $(MOTION_PATCHES)

$(MOTION_BUILD_DIR)/.configured: $(DL_DIR)/$(MOTION_SOURCE) $(MOTION_PATCHES) make/motion.mk
	$(MAKE) libjpeg-stage ffmpeg-stage mysql-stage libjpeg-stage sqlite-stage
	rm -rf $(BUILD_DIR)/$(MOTION_DIR) $(@D)
	$(MOTION_UNZIP) $(DL_DIR)/$(MOTION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOTION_PATCHES)" ; \
		then cat $(MOTION_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MOTION_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MOTION_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MOTION_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(MOTION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOTION_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		$(strip $(if $(filter buildroot-armv5eabi-ng-legacy, $(OPTWARE_TARGET)), --without-v4l2)) \
		--with-mysql-include=$(STAGING_INCLUDE_DIR)/mysql \
		--with-mysql-lib=$(STAGING_LIB_DIR)/mysql \
		--with-sqlite \
		--without-pgsql \
		--with-ffmpeg=$(STAGING_PREFIX) \
	)
#	$(PATCH_LIBTOOL) $(MOTION_BUILD_DIR)/libtool
	touch $@

motion-unpack: $(MOTION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOTION_BUILD_DIR)/.built: $(MOTION_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
motion: $(MOTION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOTION_BUILD_DIR)/.staged: $(MOTION_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

motion-stage: $(MOTION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/motion
#
$(MOTION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: motion" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOTION_PRIORITY)" >>$@
	@echo "Section: $(MOTION_SECTION)" >>$@
	@echo "Version: $(MOTION_VERSION)-$(MOTION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOTION_MAINTAINER)" >>$@
ifdef MOTION_SVN
	@echo "Source: $(MOTION_SVN)" >>$@
else
	@echo "Source: $(MOTION_SITE)/$(MOTION_SOURCE)" >>$@
endif
	@echo "Description: $(MOTION_DESCRIPTION)" >>$@
	@echo "Depends: $(MOTION_DEPENDS)" >>$@
	@echo "Suggests: $(MOTION_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOTION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOTION_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MOTION_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOTION_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MOTION_IPK_DIR)$(TARGET_PREFIX)/etc/motion/...
# Documentation files should be installed in $(MOTION_IPK_DIR)$(TARGET_PREFIX)/doc/motion/...
#
# You may need to patch your application to make it use these locations.
#
$(MOTION_IPK): $(MOTION_BUILD_DIR)/.built
	rm -rf $(MOTION_IPK_DIR) $(BUILD_DIR)/motion_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOTION_BUILD_DIR) DESTDIR=$(MOTION_IPK_DIR) install
	$(STRIP_COMMAND) $(MOTION_IPK_DIR)$(TARGET_PREFIX)/bin/motion
	$(INSTALL) -d $(MOTION_IPK_DIR)$(TARGET_PREFIX)/etc/
	$(INSTALL) -m 644 $(MOTION_SOURCE_DIR)/motion.conf $(MOTION_IPK_DIR)$(TARGET_PREFIX)/etc/motion.conf
	$(INSTALL) -d $(MOTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(MOTION_SOURCE_DIR)/rc.motion $(MOTION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S99motion
	$(MAKE) $(MOTION_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(MOTION_SOURCE_DIR)/postinst $(MOTION_IPK_DIR)/CONTROL/postinst
	$(INSTALL) -m 755 $(MOTION_SOURCE_DIR)/prerm $(MOTION_IPK_DIR)/CONTROL/prerm
	echo $(MOTION_CONFFILES) | sed -e 's/ /\n/g' > $(MOTION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOTION_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(MOTION_IPK_DIR)

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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
