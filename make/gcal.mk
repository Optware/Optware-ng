###########################################################
#
# gcal
#
###########################################################
#
# GCAL_VERSION, GCAL_SITE and GCAL_SOURCE define
# the upstream location of the source code for the package.
# GCAL_DIR is the directory which is created when the source
# archive is unpacked.
# GCAL_UNZIP is the command used to unzip the source.
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
GCAL_SITE=http://ftp.gnu.org/pub/gnu/gcal
GCAL_VERSION?=4
GCAL_SOURCE=gcal-$(GCAL_VERSION).tar.gz
GCAL_DIR=gcal-$(GCAL_VERSION)
GCAL_UNZIP=zcat
GCAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GCAL_DESCRIPTION=Gcal calculates and prints calendars.
GCAL_SECTION=misc
GCAL_PRIORITY=optional
GCAL_DEPENDS=ncurses
GCAL_SUGGESTS=less
GCAL_CONFLICTS=

#
# GCAL_IPK_VERSION should be incremented when the ipk changes.
#
GCAL_IPK_VERSION?=2

#
# GCAL_CONFFILES should be a list of user-editable files
#GCAL_CONFFILES=$(TARGET_PREFIX)/etc/gcal.conf $(TARGET_PREFIX)/etc/init.d/SXXgcal

#
# GCAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GCAL_PATCHES=$(GCAL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GCAL_CPPFLAGS=
GCAL_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
GCAL_CONFIG_ENV=ac_cv_func_mmap_fixed_mapped=yes gcal_cv_func_system_ok=yes
else
GCAL_CONFIG_ENV=
endif

#
# GCAL_BUILD_DIR is the directory in which the build is done.
# GCAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GCAL_IPK_DIR is the directory in which the ipk is built.
# GCAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GCAL_BUILD_DIR=$(BUILD_DIR)/gcal
GCAL_SOURCE_DIR=$(SOURCE_DIR)/gcal
GCAL_IPK_DIR=$(BUILD_DIR)/gcal-$(GCAL_VERSION)-ipk
GCAL_IPK=$(BUILD_DIR)/gcal_$(GCAL_VERSION)-$(GCAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gcal-source gcal-unpack gcal gcal-stage gcal-ipk gcal-clean gcal-dirclean gcal-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GCAL_SOURCE):
	$(WGET) -P $(@D) $(GCAL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gcal-source: $(DL_DIR)/$(GCAL_SOURCE) $(GCAL_PATCHES)

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
$(GCAL_BUILD_DIR)/.configured: $(DL_DIR)/$(GCAL_SOURCE) $(GCAL_PATCHES) make/gcal.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(GCAL_DIR) $(@D)
	$(GCAL_UNZIP) $(DL_DIR)/$(GCAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GCAL_PATCHES)" ; \
		then cat $(GCAL_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GCAL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GCAL_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GCAL_DIR) $(@D) ; \
	fi
	-sed -i.orig -e '/gets is a security hole - use fgets instead/s|^|//|' $(@D)/lib/stdio.in.h
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GCAL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GCAL_LDFLAGS)" \
		$(GCAL_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

gcal-unpack: $(GCAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GCAL_BUILD_DIR)/.built: $(GCAL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
gcal: $(GCAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GCAL_BUILD_DIR)/.staged: $(GCAL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

gcal-stage: $(GCAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gcal
#
$(GCAL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gcal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GCAL_PRIORITY)" >>$@
	@echo "Section: $(GCAL_SECTION)" >>$@
	@echo "Version: $(GCAL_VERSION)-$(GCAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GCAL_MAINTAINER)" >>$@
	@echo "Source: $(GCAL_SITE)/$(GCAL_SOURCE)" >>$@
	@echo "Description: $(GCAL_DESCRIPTION)" >>$@
	@echo "Depends: $(GCAL_DEPENDS)" >>$@
	@echo "Suggests: $(GCAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(GCAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GCAL_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GCAL_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GCAL_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GCAL_IPK_DIR)$(TARGET_PREFIX)/etc/gcal/...
# Documentation files should be installed in $(GCAL_IPK_DIR)$(TARGET_PREFIX)/doc/gcal/...
# Daemon startup scripts should be installed in $(GCAL_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gcal
#
# You may need to patch your application to make it use these locations.
#
$(GCAL_IPK): $(GCAL_BUILD_DIR)/.built
	rm -rf $(GCAL_IPK_DIR) $(BUILD_DIR)/gcal_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GCAL_BUILD_DIR) prefix=$(GCAL_IPK_DIR)$(TARGET_PREFIX) install
	rm -f $(GCAL_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	$(STRIP_COMMAND) $(GCAL_IPK_DIR)$(TARGET_PREFIX)/bin/gcal \
		$(GCAL_IPK_DIR)$(TARGET_PREFIX)/bin/gcal2txt \
		$(GCAL_IPK_DIR)$(TARGET_PREFIX)/bin/tcal \
		$(GCAL_IPK_DIR)$(TARGET_PREFIX)/bin/txt2gcal
	rm -f $(GCAL_IPK_DIR)$(TARGET_PREFIX)/info/dir $(GCAL_IPK_DIR)$(TARGET_PREFIX)/info/dir.old
	$(MAKE) $(GCAL_IPK_DIR)/CONTROL/control
#	echo $(GCAL_CONFFILES) | sed -e 's/ /\n/g' > $(GCAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GCAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gcal-ipk: $(GCAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gcal-clean:
	rm -f $(GCAL_BUILD_DIR)/.built
	-$(MAKE) -C $(GCAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gcal-dirclean:
	rm -rf $(BUILD_DIR)/$(GCAL_DIR) $(GCAL_BUILD_DIR) $(GCAL_IPK_DIR) $(GCAL_IPK)
#
#
# Some sanity check for the package.
#
gcal-check: $(GCAL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
