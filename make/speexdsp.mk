###########################################################
#
# speexdsp
#
###########################################################
#
# SPEEXDSP_VERSION, SPEEXDSP_SITE and SPEEXDSP_SOURCE define
# the upstream location of the source code for the package.
# SPEEXDSP_DIR is the directory which is created when the source
# archive is unpacked.
# SPEEXDSP_UNZIP is the command used to unzip the source.
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
SPEEXDSP_SITE=https://github.com/xiph/speexdsp/archive
SPEEXDSP_VERSION=1.2rc3
SPEEXDSP_SOURCE=SpeexDSP-$(SPEEXDSP_VERSION).tar.gz
SPEEXDSP_DIR=speexdsp-SpeexDSP-$(SPEEXDSP_VERSION)
SPEEXDSP_UNZIP=zcat
SPEEXDSP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SPEEXDSP_DESCRIPTION=SpeexDSP is a patent-free, Open Source/Free Software DSP library.
SPEEXDSP_SECTION=audio
SPEEXDSP_PRIORITY=optional
SPEEXDSP_DEPENDS=
SPEEXDSP_SUGGESTS=
SPEEXDSP_CONFLICTS=

#
# SPEEXDSP_IPK_VERSION should be incremented when the ipk changes.
#
SPEEXDSP_IPK_VERSION=1

#
# SPEEXDSP_CONFFILES should be a list of user-editable files
#SPEEXDSP_CONFFILES=$(TARGET_PREFIX)/etc/speexdsp.conf $(TARGET_PREFIX)/etc/init.d/SXXspeexdsp

#
# SPEEXDSP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SPEEXDSP_PATCHES=$(SPEEXDSP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SPEEXDSP_CPPFLAGS=
SPEEXDSP_LDFLAGS=

#
# SPEEXDSP_BUILD_DIR is the directory in which the build is done.
# SPEEXDSP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SPEEXDSP_IPK_DIR is the directory in which the ipk is built.
# SPEEXDSP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SPEEXDSP_BUILD_DIR=$(BUILD_DIR)/speexdsp
SPEEXDSP_SOURCE_DIR=$(SOURCE_DIR)/speexdsp
SPEEXDSP_IPK_DIR=$(BUILD_DIR)/speexdsp-$(SPEEXDSP_VERSION)-ipk
SPEEXDSP_IPK=$(BUILD_DIR)/speexdsp_$(SPEEXDSP_VERSION)-$(SPEEXDSP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: speexdsp-source speexdsp-unpack speexdsp speexdsp-stage speexdsp-ipk speexdsp-clean speexdsp-dirclean speexdsp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SPEEXDSP_SOURCE):
	$(WGET) -P $(@D) $(SPEEXDSP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
speexdsp-source: $(DL_DIR)/$(SPEEXDSP_SOURCE) $(SPEEXDSP_PATCHES)

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
$(SPEEXDSP_BUILD_DIR)/.configured: $(DL_DIR)/$(SPEEXDSP_SOURCE) $(SPEEXDSP_PATCHES) make/speexdsp.mk
#	$(MAKE) <bar>-stage
	rm -rf $(BUILD_DIR)/$(SPEEXDSP_DIR) $(SPEEXDSP_BUILD_DIR)
	$(SPEEXDSP_UNZIP) $(DL_DIR)/$(SPEEXDSP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SPEEXDSP_PATCHES)" ; \
		then cat $(SPEEXDSP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(SPEEXDSP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SPEEXDSP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SPEEXDSP_DIR) $(@D) ; \
	fi
	mkdir -p $(@D)/m4
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SPEEXDSP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SPEEXDSP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

speexdsp-unpack: $(SPEEXDSP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SPEEXDSP_BUILD_DIR)/.built: $(SPEEXDSP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
speexdsp: $(SPEEXDSP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SPEEXDSP_BUILD_DIR)/.staged: $(SPEEXDSP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/speexdsp.pc
	rm -f $(STAGING_LIB_DIR)/libspeexdsp.la
	touch $@

speexdsp-stage: $(SPEEXDSP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/speexdsp
#
$(SPEEXDSP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: speexdsp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SPEEXDSP_PRIORITY)" >>$@
	@echo "Section: $(SPEEXDSP_SECTION)" >>$@
	@echo "Version: $(SPEEXDSP_VERSION)-$(SPEEXDSP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SPEEXDSP_MAINTAINER)" >>$@
	@echo "Source: $(SPEEXDSP_SITE)/$(SPEEXDSP_SOURCE)" >>$@
	@echo "Description: $(SPEEXDSP_DESCRIPTION)" >>$@
	@echo "Depends: $(SPEEXDSP_DEPENDS)" >>$@
	@echo "Suggests: $(SPEEXDSP_SUGGESTS)" >>$@
	@echo "Conflicts: $(SPEEXDSP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/speexdsp/...
# Documentation files should be installed in $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/doc/speexdsp/...
# Daemon startup scripts should be installed in $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??speexdsp
#
# You may need to patch your application to make it use these locations.
#
$(SPEEXDSP_IPK): $(SPEEXDSP_BUILD_DIR)/.built
	rm -rf $(SPEEXDSP_IPK_DIR) $(BUILD_DIR)/speexdsp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SPEEXDSP_BUILD_DIR) DESTDIR=$(SPEEXDSP_IPK_DIR) install-strip
	rm -f $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/lib/libspeexdsp.la
#	$(INSTALL) -d $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(SPEEXDSP_SOURCE_DIR)/speexdsp.conf $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/speexdsp.conf
#	$(INSTALL) -d $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(SPEEXDSP_SOURCE_DIR)/rc.speexdsp $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXspeexdsp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEXDSP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXspeexdsp
	$(MAKE) $(SPEEXDSP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(SPEEXDSP_SOURCE_DIR)/postinst $(SPEEXDSP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEXDSP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(SPEEXDSP_SOURCE_DIR)/prerm $(SPEEXDSP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SPEEXDSP_IPK_DIR)/CONTROL/prerm
	echo $(SPEEXDSP_CONFFILES) | sed -e 's/ /\n/g' > $(SPEEXDSP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SPEEXDSP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SPEEXDSP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
speexdsp-ipk: $(SPEEXDSP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
speexdsp-clean:
	rm -f $(SPEEXDSP_BUILD_DIR)/.built
	-$(MAKE) -C $(SPEEXDSP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
speexdsp-dirclean:
	rm -rf $(BUILD_DIR)/$(SPEEXDSP_DIR) $(SPEEXDSP_BUILD_DIR) $(SPEEXDSP_IPK_DIR) $(SPEEXDSP_IPK)
#
#
# Some sanity check for the package.
#
speexdsp-check: $(SPEEXDSP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
