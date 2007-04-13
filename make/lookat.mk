###########################################################
#
# lookat
#
###########################################################
#
# LOOKAT_VERSION, LOOKAT_SITE and LOOKAT_SOURCE define
# the upstream location of the source code for the package.
# LOOKAT_DIR is the directory which is created when the source
# archive is unpacked.
# LOOKAT_UNZIP is the command used to unzip the source.
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
LOOKAT_SITE=http://www.wagemakers.be/uploads/37/16
LOOKAT_VERSION=1.4.1
LOOKAT_SOURCE=lookat_bekijk-$(LOOKAT_VERSION).tar.gz
LOOKAT_DIR=lookat_bekijk-$(LOOKAT_VERSION)
LOOKAT_UNZIP=zcat
LOOKAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LOOKAT_DESCRIPTION="lookat" (or "bekijk" in the Dutch version) is a program to view Un*x text files and manual pages.
LOOKAT_SECTION=misc
LOOKAT_PRIORITY=optional
LOOKAT_DEPENDS=ncurses
LOOKAT_SUGGESTS=
LOOKAT_CONFLICTS=

#
# LOOKAT_IPK_VERSION should be incremented when the ipk changes.
#
LOOKAT_IPK_VERSION=1

#
# LOOKAT_CONFFILES should be a list of user-editable files
LOOKAT_CONFFILES=/opt/etc/lookat.conf

#
# LOOKAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LOOKAT_PATCHES=$(LOOKAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LOOKAT_CPPFLAGS=
LOOKAT_LDFLAGS=
ifneq ($(HOSTCC), $(TARGET_CC))
LOOKAT_CONFIG_ENV=ac_cv_func_malloc_0_nonnull=yes ac_cv_func_realloc_0_nonnull=yes
endif

#
# LOOKAT_BUILD_DIR is the directory in which the build is done.
# LOOKAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LOOKAT_IPK_DIR is the directory in which the ipk is built.
# LOOKAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LOOKAT_BUILD_DIR=$(BUILD_DIR)/lookat
LOOKAT_SOURCE_DIR=$(SOURCE_DIR)/lookat
LOOKAT_IPK_DIR=$(BUILD_DIR)/lookat-$(LOOKAT_VERSION)-ipk
LOOKAT_IPK=$(BUILD_DIR)/lookat_$(LOOKAT_VERSION)-$(LOOKAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lookat-source lookat-unpack lookat lookat-stage lookat-ipk lookat-clean lookat-dirclean lookat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LOOKAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(LOOKAT_SITE)/$(LOOKAT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LOOKAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lookat-source: $(DL_DIR)/$(LOOKAT_SOURCE) $(LOOKAT_PATCHES)

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
$(LOOKAT_BUILD_DIR)/.configured: $(DL_DIR)/$(LOOKAT_SOURCE) $(LOOKAT_PATCHES) make/lookat.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(LOOKAT_DIR) $(LOOKAT_BUILD_DIR)
	$(LOOKAT_UNZIP) $(DL_DIR)/$(LOOKAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LOOKAT_PATCHES)" ; \
		then cat $(LOOKAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LOOKAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LOOKAT_DIR)" != "$(LOOKAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LOOKAT_DIR) $(LOOKAT_BUILD_DIR) ; \
	fi
	(cd $(LOOKAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LOOKAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LOOKAT_LDFLAGS)" \
		$(LOOKAT_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(LOOKAT_BUILD_DIR)/libtool
	touch $@

lookat-unpack: $(LOOKAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LOOKAT_BUILD_DIR)/.built: $(LOOKAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LOOKAT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
lookat: $(LOOKAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LOOKAT_BUILD_DIR)/.staged: $(LOOKAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(LOOKAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

lookat-stage: $(LOOKAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lookat
#
$(LOOKAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lookat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LOOKAT_PRIORITY)" >>$@
	@echo "Section: $(LOOKAT_SECTION)" >>$@
	@echo "Version: $(LOOKAT_VERSION)-$(LOOKAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LOOKAT_MAINTAINER)" >>$@
	@echo "Source: $(LOOKAT_SITE)/$(LOOKAT_SOURCE)" >>$@
	@echo "Description: $(LOOKAT_DESCRIPTION)" >>$@
	@echo "Depends: $(LOOKAT_DEPENDS)" >>$@
	@echo "Suggests: $(LOOKAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(LOOKAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LOOKAT_IPK_DIR)/opt/sbin or $(LOOKAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LOOKAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LOOKAT_IPK_DIR)/opt/etc/lookat/...
# Documentation files should be installed in $(LOOKAT_IPK_DIR)/opt/doc/lookat/...
# Daemon startup scripts should be installed in $(LOOKAT_IPK_DIR)/opt/etc/init.d/S??lookat
#
# You may need to patch your application to make it use these locations.
#
$(LOOKAT_IPK): $(LOOKAT_BUILD_DIR)/.built
	rm -rf $(LOOKAT_IPK_DIR) $(BUILD_DIR)/lookat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LOOKAT_BUILD_DIR) DESTDIR=$(LOOKAT_IPK_DIR) transform="" install-strip
#	install -d $(LOOKAT_IPK_DIR)/opt/etc/
#	install -m 644 $(LOOKAT_SOURCE_DIR)/lookat.conf $(LOOKAT_IPK_DIR)/opt/etc/lookat.conf
#	install -d $(LOOKAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LOOKAT_SOURCE_DIR)/rc.lookat $(LOOKAT_IPK_DIR)/opt/etc/init.d/SXXlookat
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOOKAT_IPK_DIR)/opt/etc/init.d/SXXlookat
	$(MAKE) $(LOOKAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(LOOKAT_SOURCE_DIR)/postinst $(LOOKAT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOOKAT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LOOKAT_SOURCE_DIR)/prerm $(LOOKAT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LOOKAT_IPK_DIR)/CONTROL/prerm
	echo $(LOOKAT_CONFFILES) | sed -e 's/ /\n/g' > $(LOOKAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LOOKAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lookat-ipk: $(LOOKAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lookat-clean:
	rm -f $(LOOKAT_BUILD_DIR)/.built
	-$(MAKE) -C $(LOOKAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lookat-dirclean:
	rm -rf $(BUILD_DIR)/$(LOOKAT_DIR) $(LOOKAT_BUILD_DIR) $(LOOKAT_IPK_DIR) $(LOOKAT_IPK)
#
#
# Some sanity check for the package.
#
lookat-check: $(LOOKAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LOOKAT_IPK)
