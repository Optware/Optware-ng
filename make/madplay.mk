###########################################################
#
# madplay
#
###########################################################

# You must replace "madplay" and "MADPLAY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# MADPLAY_VERSION, MADPLAY_SITE and MADPLAY_SOURCE define
# the upstream location of the source code for the package.
# MADPLAY_DIR is the directory which is created when the source
# archive is unpacked.
# MADPLAY_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
MADPLAY_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mad
MADPLAY_VERSION=0.15.2b
MADPLAY_SOURCE=madplay-$(MADPLAY_VERSION).tar.gz
MADPLAY_DIR=madplay-$(MADPLAY_VERSION)
MADPLAY_UNZIP=zcat
MADPLAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MADPLAY_DESCRIPTION=MPEG Audio Decoder player
MADPLAY_SECTION=misc
MADPLAY_PRIORITY=optional
MADPLAY_DEPENDS=libmad, libid3tag, esound
MADPLAY_SUGGESTS=
MADPLAY_CONFLICTS=

#
# MADPLAY_IPK_VERSION should be incremented when the ipk changes.
#
MADPLAY_IPK_VERSION=3

#
# MADPLAY_CONFFILES should be a list of user-editable files
MADPLAY_CONFFILES=

#
# MADPLAY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MADPLAY_PATCHES=/dev/null

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MADPLAY_CPPFLAGS=
MADPLAY_LDFLAGS=

#
# MADPLAY_BUILD_DIR is the directory in which the build is done.
# MADPLAY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MADPLAY_IPK_DIR is the directory in which the ipk is built.
# MADPLAY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MADPLAY_BUILD_DIR=$(BUILD_DIR)/madplay
MADPLAY_SOURCE_DIR=$(SOURCE_DIR)/madplay
MADPLAY_IPK_DIR=$(BUILD_DIR)/madplay-$(MADPLAY_VERSION)-ipk
MADPLAY_IPK=$(BUILD_DIR)/madplay_$(MADPLAY_VERSION)-$(MADPLAY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: madplay-source madplay-unpack madplay madplay-stage madplay-ipk madplay-clean madplay-dirclean madplay-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MADPLAY_SOURCE):
	$(WGET) -P $(@D) $(MADPLAY_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
madplay-source: $(DL_DIR)/$(MADPLAY_SOURCE) $(MADPLAY_PATCHES)

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
$(MADPLAY_BUILD_DIR)/.configured: $(DL_DIR)/$(MADPLAY_SOURCE) $(MADPLAY_PATCHES)
	$(MAKE) libmad-stage libid3tag-stage esound-stage
	rm -rf $(BUILD_DIR)/$(MADPLAY_DIR) $(MADPLAY_BUILD_DIR)
	$(MADPLAY_UNZIP) $(DL_DIR)/$(MADPLAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(MADPLAY_PATCHES) | patch -d $(BUILD_DIR)/$(MADPLAY_DIR) -p1
	mv $(BUILD_DIR)/$(MADPLAY_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MADPLAY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MADPLAY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) \
		-e 's|^sys_lib_search_path_spec=.*"$$|sys_lib_search_path_spec="$(STAGING_LIB_DIR)"|' \
		$(@D)/libtool
	touch $@

madplay-unpack: $(MADPLAY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MADPLAY_BUILD_DIR)/.built: $(MADPLAY_BUILD_DIR)/.configured
	rm -f $(MADPLAY_BUILD_DIR)/.built
	$(MAKE) -C $(MADPLAY_BUILD_DIR)
	touch $(MADPLAY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
madplay: $(MADPLAY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MADPLAY_BUILD_DIR)/.staged: $(MADPLAY_BUILD_DIR)/.built
	rm -f $(MADPLAY_BUILD_DIR)/.staged
	$(MAKE) -C $(MADPLAY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MADPLAY_BUILD_DIR)/.staged

madplay-stage: $(MADPLAY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/madplay
#
$(MADPLAY_IPK_DIR)/CONTROL/control:
	@install -d $(MADPLAY_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: madplay" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MADPLAY_PRIORITY)" >>$@
	@echo "Section: $(MADPLAY_SECTION)" >>$@
	@echo "Version: $(MADPLAY_VERSION)-$(MADPLAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MADPLAY_MAINTAINER)" >>$@
	@echo "Source: $(MADPLAY_SITE)/$(MADPLAY_SOURCE)" >>$@
	@echo "Description: $(MADPLAY_DESCRIPTION)" >>$@
	@echo "Depends: $(MADPLAY_DEPENDS)" >>$@
	@echo "Suggests: $(MADPLAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(MADPLAY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
$(MADPLAY_IPK): $(MADPLAY_BUILD_DIR)/.built
	rm -rf $(MADPLAY_IPK_DIR) $(BUILD_DIR)/madplay_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MADPLAY_BUILD_DIR) DESTDIR=$(MADPLAY_IPK_DIR) install
	$(STRIP_COMMAND) $(MADPLAY_IPK_DIR)/opt/bin/madplay
	$(MAKE) $(MADPLAY_IPK_DIR)/CONTROL/control
	echo $(MADPLAY_CONFFILES) | sed -e 's/ /\n/g' > $(MADPLAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MADPLAY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
madplay-ipk: $(MADPLAY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
madplay-clean:
	-$(MAKE) -C $(MADPLAY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
madplay-dirclean:
	rm -rf $(BUILD_DIR)/$(MADPLAY_DIR) $(MADPLAY_BUILD_DIR) $(MADPLAY_IPK_DIR) $(MADPLAY_IPK)

#
# Some sanity check for the package.
#
madplay-check: $(MADPLAY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MADPLAY_IPK)
