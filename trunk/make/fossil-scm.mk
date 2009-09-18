###########################################################
#
# fossil-scm
#
###########################################################
#
# FOSSIL-SCM_HASH, FOSSIL-SCM_SITE and FOSSIL-SCM_SOURCE define
# the upstream location of the source code for the package.
# FOSSIL-SCM_DIR is the directory which is created when the source
# archive is unpacked.
# FOSSIL-SCM_UNZIP is the command used to unzip the source.
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
FOSSIL-SCM_SITE=http://www.fossil-scm.org
FOSSIL-SCM_VERSION=20090916
FOSSIL-SCM_HASH=0eb08b860c
FOSSIL-SCM_DIR=Fossil-$(FOSSIL-SCM_HASH)
FOSSIL-SCM_SOURCE=$(FOSSIL-SCM_DIR).zip
FOSSIL-SCM_UNZIP=unzip
FOSSIL-SCM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FOSSIL-SCM_DESCRIPTION=Simple, high-reliability, distributed software configuration management
FOSSIL-SCM_SECTION=utils
FOSSIL-SCM_PRIORITY=optional
FOSSIL-SCM_DEPENDS=zlib
FOSSIL-SCM_SUGGESTS=
FOSSIL-SCM_CONFLICTS=

#
# FOSSIL-SCM_IPK_VERSION should be incremented when the ipk changes.
#
FOSSIL-SCM_IPK_VERSION=1

#
# FOSSIL-SCM_CONFFILES should be a list of user-editable files
#FOSSIL-SCM_CONFFILES=/opt/etc/fossil-scm.conf /opt/etc/init.d/SXXfossil-scm

#
# FOSSIL-SCM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FOSSIL-SCM_PATCHES=$(FOSSIL-SCM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FOSSIL-SCM_CPPFLAGS=
FOSSIL-SCM_LDFLAGS=

#
# FOSSIL-SCM_BUILD_DIR is the directory in which the build is done.
# FOSSIL-SCM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FOSSIL-SCM_IPK_DIR is the directory in which the ipk is built.
# FOSSIL-SCM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FOSSIL-SCM_BUILD_DIR=$(BUILD_DIR)/fossil-scm
FOSSIL-SCM_SOURCE_DIR=$(SOURCE_DIR)/fossil-scm
FOSSIL-SCM_IPK_DIR=$(BUILD_DIR)/fossil-scm-$(FOSSIL-SCM_VERSION)-ipk
FOSSIL-SCM_IPK=$(BUILD_DIR)/fossil-scm_$(FOSSIL-SCM_VERSION)-$(FOSSIL-SCM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fossil-scm-source fossil-scm-unpack fossil-scm fossil-scm-stage fossil-scm-ipk fossil-scm-clean fossil-scm-dirclean fossil-scm-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FOSSIL-SCM_SOURCE):
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
#	$(WGET) -P $(@D) $(FOSSIL-SCM_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fossil-scm-source: $(DL_DIR)/$(FOSSIL-SCM_SOURCE) $(FOSSIL-SCM_PATCHES)

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
$(FOSSIL-SCM_BUILD_DIR)/.configured: $(DL_DIR)/$(FOSSIL-SCM_SOURCE) $(FOSSIL-SCM_PATCHES) make/fossil-scm.mk
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(FOSSIL-SCM_DIR) $(@D)
	cd $(BUILD_DIR) && $(FOSSIL-SCM_UNZIP) $(DL_DIR)/$(FOSSIL-SCM_SOURCE)
	if test -n "$(FOSSIL-SCM_PATCHES)" ; \
		then cat $(FOSSIL-SCM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FOSSIL-SCM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FOSSIL-SCM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FOSSIL-SCM_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FOSSIL-SCM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FOSSIL-SCM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

fossil-scm-unpack: $(FOSSIL-SCM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FOSSIL-SCM_BUILD_DIR)/.built: $(FOSSIL-SCM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		TCC="$(TARGET_CC) -Wall $(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FOSSIL-SCM_LDFLAGS)" \
;
	touch $@

#
# This is the build convenience target.
#
fossil-scm: $(FOSSIL-SCM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(FOSSIL-SCM_BUILD_DIR)/.staged: $(FOSSIL-SCM_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#fossil-scm-stage: $(FOSSIL-SCM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fossil-scm
#
$(FOSSIL-SCM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fossil-scm" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FOSSIL-SCM_PRIORITY)" >>$@
	@echo "Section: $(FOSSIL-SCM_SECTION)" >>$@
	@echo "Version: $(FOSSIL-SCM_VERSION)-$(FOSSIL-SCM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FOSSIL-SCM_MAINTAINER)" >>$@
	@echo "Source: $(FOSSIL-SCM_SITE)/$(FOSSIL-SCM_SOURCE)" >>$@
	@echo "Description: $(FOSSIL-SCM_DESCRIPTION)" >>$@
	@echo "Depends: $(FOSSIL-SCM_DEPENDS)" >>$@
	@echo "Suggests: $(FOSSIL-SCM_SUGGESTS)" >>$@
	@echo "Conflicts: $(FOSSIL-SCM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FOSSIL-SCM_IPK_DIR)/opt/sbin or $(FOSSIL-SCM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FOSSIL-SCM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FOSSIL-SCM_IPK_DIR)/opt/etc/fossil-scm/...
# Documentation files should be installed in $(FOSSIL-SCM_IPK_DIR)/opt/doc/fossil-scm/...
# Daemon startup scripts should be installed in $(FOSSIL-SCM_IPK_DIR)/opt/etc/init.d/S??fossil-scm
#
# You may need to patch your application to make it use these locations.
#
$(FOSSIL-SCM_IPK): $(FOSSIL-SCM_BUILD_DIR)/.built
	rm -rf $(FOSSIL-SCM_IPK_DIR) $(BUILD_DIR)/fossil-scm_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FOSSIL-SCM_BUILD_DIR) DESTDIR=$(FOSSIL-SCM_IPK_DIR) install-strip
	install -d $(FOSSIL-SCM_IPK_DIR)/opt/bin
	install -m755 $(<D)/fossil $(FOSSIL-SCM_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(FOSSIL-SCM_IPK_DIR)/opt/bin/fossil
	$(MAKE) $(FOSSIL-SCM_IPK_DIR)/CONTROL/control
	echo $(FOSSIL-SCM_CONFFILES) | sed -e 's/ /\n/g' > $(FOSSIL-SCM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FOSSIL-SCM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fossil-scm-ipk: $(FOSSIL-SCM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fossil-scm-clean:
	rm -f $(FOSSIL-SCM_BUILD_DIR)/.built
	-$(MAKE) -C $(FOSSIL-SCM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fossil-scm-dirclean:
	rm -rf $(BUILD_DIR)/$(FOSSIL-SCM_DIR) $(FOSSIL-SCM_BUILD_DIR) $(FOSSIL-SCM_IPK_DIR) $(FOSSIL-SCM_IPK)
#
#
# Some sanity check for the package.
#
fossil-scm-check: $(FOSSIL-SCM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
