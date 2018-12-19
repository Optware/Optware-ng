###########################################################
#
# linphone
#
###########################################################
#
# LINPHONE_VERSION, LINPHONE_SITE and LINPHONE_SOURCE define
# the upstream location of the source code for the package.
# LINPHONE_DIR is the directory which is created when the source
# archive is unpacked.
# LINPHONE_UNZIP is the command used to unzip the source.
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
LINPHONE_SITE=http://mirror.its.uidaho.edu/pub/savannah/linphone/stable/sources
LINPHONE_VERSION=3.3.2
LINPHONE_SOURCE=linphone-$(LINPHONE_VERSION).tar.gz
LINPHONE_DIR=linphone-$(LINPHONE_VERSION)
LINPHONE_UNZIP=zcat
LINPHONE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LINPHONE_DESCRIPTION=Open source SIP VOIP phone.
LINPHONE_SECTION=util
LINPHONE_PRIORITY=optional
LINPHONE_DEPENDS=libosip2, libexosip2, ncurses, readline, speex, speexdsp, alsa-lib
LINPHONE_SUGGESTS=
LINPHONE_CONFLICTS=

#
# LINPHONE_IPK_VERSION should be incremented when the ipk changes.
#
LINPHONE_IPK_VERSION=4

#
# LINPHONE_CONFFILES should be a list of user-editable files
#LINPHONE_CONFFILES=$(TARGET_PREFIX)/etc/linphone.conf $(TARGET_PREFIX)/etc/init.d/SXXlinphone

#
# LINPHONE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# LINPHONE_PATCHES=$(LINPHONE_SOURCE_DIR)/msticker.c.patch

# This patch is needed if the target glibc has a broken or missing CLOCK_MONOTONIC function
ifeq ($(OPTWARE_TARGET), $(filter ds101j fsg3 mss nas100d nslu2 openwiz syno0844mv5281 syno1142mv5281 syno-x07 ts101, $(OPTWARE_TARGET)))
LINPHONE_PATCHES=$(LINPHONE_SOURCE_DIR)/msticker.c.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LINPHONE_CPPFLAGS=
LINPHONE_LDFLAGS ?=
ifeq (uclibc, $(LIBC_STYLE))
LINPHONE_LDFLAGS += -lpthread
endif

#
# LINPHONE_BUILD_DIR is the directory in which the build is done.
# LINPHONE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LINPHONE_IPK_DIR is the directory in which the ipk is built.
# LINPHONE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LINPHONE_BUILD_DIR=$(BUILD_DIR)/linphone
LINPHONE_SOURCE_DIR=$(SOURCE_DIR)/linphone
LINPHONE_IPK_DIR=$(BUILD_DIR)/linphone-$(LINPHONE_VERSION)-ipk
LINPHONE_IPK=$(BUILD_DIR)/linphone_$(LINPHONE_VERSION)-$(LINPHONE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: linphone-source linphone-unpack linphone linphone-stage linphone-ipk linphone-clean linphone-dirclean linphone-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LINPHONE_SOURCE):
	$(WGET) -P $(@D) $(LINPHONE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
linphone-source: $(DL_DIR)/$(LINPHONE_SOURCE) $(LINPHONE_PATCHES)

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
$(LINPHONE_BUILD_DIR)/.configured: $(DL_DIR)/$(LINPHONE_SOURCE) $(LINPHONE_PATCHES) make/linphone.mk
	$(MAKE) libosip2-stage libexosip2-stage ncurses-stage readline-stage speex-stage speexdsp-stage alsa-lib-stage
	rm -rf $(BUILD_DIR)/$(LINPHONE_DIR) $(@D)
	$(LINPHONE_UNZIP) $(DL_DIR)/$(LINPHONE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LINPHONE_PATCHES)" ; \
		then cat $(LINPHONE_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LINPHONE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LINPHONE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LINPHONE_DIR) $(@D) ; \
	fi
#	sed -i -e '/CFLAGS.*$$CFLAGS/s/ -Werror//' $(@D)/configure $(@D)/*/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LINPHONE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LINPHONE_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--enable-gtk_ui=no \
		--with-osip=$(STAGING_PREFIX) \
		--disable-video \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool $(@D)/*/libtool
	find $(@D) -type f -name Makefile -exec sed -i -e 's/-Werror//g' {} \;
	touch $@

linphone-unpack: $(LINPHONE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LINPHONE_BUILD_DIR)/.built: $(LINPHONE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
linphone: $(LINPHONE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LINPHONE_BUILD_DIR)/.staged: $(LINPHONE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

linphone-stage: $(LINPHONE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/linphone
#
$(LINPHONE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: linphone" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LINPHONE_PRIORITY)" >>$@
	@echo "Section: $(LINPHONE_SECTION)" >>$@
	@echo "Version: $(LINPHONE_VERSION)-$(LINPHONE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LINPHONE_MAINTAINER)" >>$@
	@echo "Source: $(LINPHONE_SITE)/$(LINPHONE_SOURCE)" >>$@
	@echo "Description: $(LINPHONE_DESCRIPTION)" >>$@
	@echo "Depends: $(LINPHONE_DEPENDS)" >>$@
	@echo "Suggests: $(LINPHONE_SUGGESTS)" >>$@
	@echo "Conflicts: $(LINPHONE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/etc/linphone/...
# Documentation files should be installed in $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/doc/linphone/...
# Daemon startup scripts should be installed in $(LINPHONE_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??linphone
#
# You may need to patch your application to make it use these locations.
#
$(LINPHONE_IPK): $(LINPHONE_BUILD_DIR)/.built
	rm -rf $(LINPHONE_IPK_DIR) $(BUILD_DIR)/linphone_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LINPHONE_BUILD_DIR) DESTDIR=$(LINPHONE_IPK_DIR) install-strip transform=''
	$(MAKE) $(LINPHONE_IPK_DIR)/CONTROL/control
	echo $(LINPHONE_CONFFILES) | sed -e 's/ /\n/g' > $(LINPHONE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LINPHONE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
linphone-ipk: $(LINPHONE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
linphone-clean:
	rm -f $(LINPHONE_BUILD_DIR)/.built
	-$(MAKE) -C $(LINPHONE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
linphone-dirclean:
	rm -rf $(BUILD_DIR)/$(LINPHONE_DIR) $(LINPHONE_BUILD_DIR) $(LINPHONE_IPK_DIR) $(LINPHONE_IPK)
#
#
# Some sanity check for the package.
#
linphone-check: $(LINPHONE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
