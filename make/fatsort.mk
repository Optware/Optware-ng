###########################################################
#
# fatsort
#
###########################################################
#
# FATSORT_VERSION, FATSORT_SITE and FATSORT_SOURCE define
# the upstream location of the source code for the package.
# FATSORT_DIR is the directory which is created when the source
# archive is unpacked.
# FATSORT_UNZIP is the command used to unzip the source.
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
FATSORT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/fatsort
FATSORT_VERSION=0.9.16.254
FATSORT_SOURCE=fatsort-$(FATSORT_VERSION).tar.gz
FATSORT_DIR=fatsort-$(FATSORT_VERSION)
FATSORT_UNZIP=zcat
FATSORT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FATSORT_DESCRIPTION=A small utilitiy that sorts directory structures of FAT16 and FAT32 file systems.
FATSORT_SECTION=utils
FATSORT_PRIORITY=optional
FATSORT_DEPENDS=
ifneq (, $(filter libiconv, $(PACKAGES)))
FATSORT_DEPENDS += libiconv
endif
FATSORT_SUGGESTS=
FATSORT_CONFLICTS=

#
# FATSORT_IPK_VERSION should be incremented when the ipk changes.
#
FATSORT_IPK_VERSION=1

#
# FATSORT_CONFFILES should be a list of user-editable files
#FATSORT_CONFFILES=/opt/etc/fatsort.conf /opt/etc/init.d/SXXfatsort

#
# FATSORT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FATSORT_PATCHES=$(FATSORT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FATSORT_CPPFLAGS=
FATSORT_LDFLAGS=
ifneq (, $(filter libiconv, $(PACKAGES)))
FATSORT_LDFLAGS += -liconv
endif

#
# FATSORT_BUILD_DIR is the directory in which the build is done.
# FATSORT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FATSORT_IPK_DIR is the directory in which the ipk is built.
# FATSORT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FATSORT_BUILD_DIR=$(BUILD_DIR)/fatsort
FATSORT_SOURCE_DIR=$(SOURCE_DIR)/fatsort
FATSORT_IPK_DIR=$(BUILD_DIR)/fatsort-$(FATSORT_VERSION)-ipk
FATSORT_IPK=$(BUILD_DIR)/fatsort_$(FATSORT_VERSION)-$(FATSORT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fatsort-source fatsort-unpack fatsort fatsort-stage fatsort-ipk fatsort-clean fatsort-dirclean fatsort-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FATSORT_SOURCE):
	$(WGET) -P $(@D) $(FATSORT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fatsort-source: $(DL_DIR)/$(FATSORT_SOURCE) $(FATSORT_PATCHES)

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
$(FATSORT_BUILD_DIR)/.configured: $(DL_DIR)/$(FATSORT_SOURCE) $(FATSORT_PATCHES) make/fatsort.mk
ifneq (, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(FATSORT_DIR) $(@D)
	$(FATSORT_UNZIP) $(DL_DIR)/$(FATSORT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FATSORT_PATCHES)" ; \
		then cat $(FATSORT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FATSORT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FATSORT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FATSORT_DIR) $(@D) ; \
	fi
	sed -i -e 's/-Wall/$$(CPPFLAGS) /' $(@D)/src/Makefile
	touch $@

fatsort-unpack: $(FATSORT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FATSORT_BUILD_DIR)/.built: $(FATSORT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CC)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FATSORT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FATSORT_LDFLAGS)" \
		SBINDIR=/opt/sbin \
		MANDIR=/opt/share/man/man1 \
		;
	touch $@

#
# This is the build convenience target.
#
fatsort: $(FATSORT_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fatsort
#
$(FATSORT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fatsort" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FATSORT_PRIORITY)" >>$@
	@echo "Section: $(FATSORT_SECTION)" >>$@
	@echo "Version: $(FATSORT_VERSION)-$(FATSORT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FATSORT_MAINTAINER)" >>$@
	@echo "Source: $(FATSORT_SITE)/$(FATSORT_SOURCE)" >>$@
	@echo "Description: $(FATSORT_DESCRIPTION)" >>$@
	@echo "Depends: $(FATSORT_DEPENDS)" >>$@
	@echo "Suggests: $(FATSORT_SUGGESTS)" >>$@
	@echo "Conflicts: $(FATSORT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FATSORT_IPK_DIR)/opt/sbin or $(FATSORT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FATSORT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FATSORT_IPK_DIR)/opt/etc/fatsort/...
# Documentation files should be installed in $(FATSORT_IPK_DIR)/opt/doc/fatsort/...
# Daemon startup scripts should be installed in $(FATSORT_IPK_DIR)/opt/etc/init.d/S??fatsort
#
# You may need to patch your application to make it use these locations.
#
$(FATSORT_IPK): $(FATSORT_BUILD_DIR)/.built
	rm -rf $(FATSORT_IPK_DIR) $(BUILD_DIR)/fatsort_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FATSORT_BUILD_DIR) DESTDIR=$(FATSORT_IPK_DIR) install \
		$(TARGET_CONFIGURE_OPTS) \
		LD="$(TARGET_CC)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FATSORT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FATSORT_LDFLAGS)" \
		SBINDIR=/opt/sbin \
		MANDIR=/opt/share/man/man1 \
		;
	$(STRIP_COMMAND) $(FATSORT_IPK_DIR)/opt/sbin/fatsort
	$(MAKE) $(FATSORT_IPK_DIR)/CONTROL/control
	echo $(FATSORT_CONFFILES) | sed -e 's/ /\n/g' > $(FATSORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FATSORT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(FATSORT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fatsort-ipk: $(FATSORT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fatsort-clean:
	rm -f $(FATSORT_BUILD_DIR)/.built
	-$(MAKE) -C $(FATSORT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fatsort-dirclean:
	rm -rf $(BUILD_DIR)/$(FATSORT_DIR) $(FATSORT_BUILD_DIR) $(FATSORT_IPK_DIR) $(FATSORT_IPK)
#
#
# Some sanity check for the package.
#
fatsort-check: $(FATSORT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
