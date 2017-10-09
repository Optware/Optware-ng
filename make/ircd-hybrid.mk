###########################################################
#
# ircd-hybrid
#
###########################################################

# You must replace "ircd-hybrid" and "IRCD-HYBRID" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IRCD-HYBRID_VERSION, IRCD-HYBRID_SITE and IRCD-HYBRID_SOURCE define
# the upstream location of the source code for the package.
# IRCD-HYBRID_DIR is the directory which is created when the source
# archive is unpacked.
# IRCD-HYBRID_UNZIP is the command used to unzip the source.
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
IRCD-HYBRID_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ircd-hybrid
IRCD-HYBRID_VERSION=8.2.2
IRCD-HYBRID_SOURCE=ircd-hybrid-$(IRCD-HYBRID_VERSION).tgz
IRCD-HYBRID_DIR=ircd-hybrid-$(IRCD-HYBRID_VERSION)
IRCD-HYBRID_UNZIP=zcat
IRCD-HYBRID_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IRCD-HYBRID_DESCRIPTION=IRCD Hybrid.
IRCD-HYBRID_SECTION=devel
IRCD-HYBRID_PRIORITY=optional
IRCD-HYBRID_DEPENDS=zlib, flex, coreutils, start-stop-daemon
IRCD-HYBRID_SUGGESTS=
IRCD-HYBRID_CONFLICTS=

#
# IRCD-HYBRID_IPK_VERSION should be incremented when the ipk changes.
#
IRCD-HYBRID_IPK_VERSION=2

#
# IRCD-HYBRID_CONFFILES should be a list of user-editable files
IRCD-HYBRID_CONFFILES=$(TARGET_PREFIX)/etc/ircd.conf $(TARGET_PREFIX)/etc/init.d/S98ircd-hybrid

#
# IRCD-HYBRID_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IRCD-HYBRID_PATCHES=$(IRCD-HYBRID_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IRCD-HYBRID_CPPFLAGS=
IRCD-HYBRID_LDFLAGS=

ifeq ($(LIBC_STYLE), uclibc)
IRCD-HYBRID_CONFIGURE_OPTS=ac_cv_func_dlinfo=no
else
IRCD-HYBRID_CONFIGURE_OPTS=
endif

#
# IRCD-HYBRID_BUILD_DIR is the directory in which the build is done.
# IRCD-HYBRID_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IRCD-HYBRID_IPK_DIR is the directory in which the ipk is built.
# IRCD-HYBRID_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IRCD-HYBRID_BUILD_DIR=$(BUILD_DIR)/ircd-hybrid
IRCD-HYBRID_SOURCE_DIR=$(SOURCE_DIR)/ircd-hybrid
IRCD-HYBRID_IPK_DIR=$(BUILD_DIR)/ircd-hybrid-$(IRCD-HYBRID_VERSION)-ipk
IRCD-HYBRID_IPK=$(BUILD_DIR)/ircd-hybrid_$(IRCD-HYBRID_VERSION)-$(IRCD-HYBRID_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ircd-hybrid-source ircd-hybrid-unpack ircd-hybrid ircd-hybrid-stage ircd-hybrid-ipk ircd-hybrid-clean ircd-hybrid-dirclean ircd-hybrid-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IRCD-HYBRID_SOURCE):
	$(WGET) -P $(@D) $(IRCD-HYBRID_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ircd-hybrid-source: $(DL_DIR)/$(IRCD-HYBRID_SOURCE) $(IRCD-HYBRID_PATCHES)

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
$(IRCD-HYBRID_BUILD_DIR)/.configured: $(DL_DIR)/$(IRCD-HYBRID_SOURCE) $(IRCD-HYBRID_PATCHES) make/ircd-hybrid.mk
	$(MAKE) flex-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(IRCD-HYBRID_DIR) $(@D)
	$(IRCD-HYBRID_UNZIP) $(DL_DIR)/$(IRCD-HYBRID_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IRCD-HYBRID_PATCHES)" ; \
		then cat $(IRCD-HYBRID_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(IRCD-HYBRID_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IRCD-HYBRID_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IRCD-HYBRID_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IRCD-HYBRID_CPPFLAGS)" \
		LDFLAGS="-L$(@D)/adns $(STAGING_LDFLAGS) $(IRCD-HYBRID_LDFLAGS)" \
		$(IRCD-HYBRID_CONFIGURE_OPTS) \
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

ircd-hybrid-unpack: $(IRCD-HYBRID_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IRCD-HYBRID_BUILD_DIR)/.built: $(IRCD-HYBRID_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ircd-hybrid: $(IRCD-HYBRID_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IRCD-HYBRID_BUILD_DIR)/.staged: $(IRCD-HYBRID_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ircd-hybrid-stage: #$(IRCD-HYBRID_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ircd-hybrid
#
$(IRCD-HYBRID_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ircd-hybrid" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IRCD-HYBRID_PRIORITY)" >>$@
	@echo "Section: $(IRCD-HYBRID_SECTION)" >>$@
	@echo "Version: $(IRCD-HYBRID_VERSION)-$(IRCD-HYBRID_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IRCD-HYBRID_MAINTAINER)" >>$@
	@echo "Source: $(IRCD-HYBRID_SITE)/$(IRCD-HYBRID_SOURCE)" >>$@
	@echo "Description: $(IRCD-HYBRID_DESCRIPTION)" >>$@
	@echo "Depends: $(IRCD-HYBRID_DEPENDS)" >>$@
	@echo "Suggests: $(IRCD-HYBRID_SUGGESTS)" >>$@
	@echo "Conflicts: $(IRCD-HYBRID_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/ircd-hybrid/...
# Documentation files should be installed in $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/doc/ircd-hybrid/...
# Daemon startup scripts should be installed in $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ircd-hybrid
#
# You may need to patch your application to make it use these locations.
#
$(IRCD-HYBRID_IPK): $(IRCD-HYBRID_BUILD_DIR)/.built
	rm -rf $(IRCD-HYBRID_IPK_DIR) $(BUILD_DIR)/ircd-hybrid_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IRCD-HYBRID_BUILD_DIR) DESTDIR=$(IRCD-HYBRID_IPK_DIR) install-strip
	mv -f $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/reference.conf $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/ircd.conf
	$(INSTALL) -d $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(INSTALL) -m 755 $(IRCD-HYBRID_SOURCE_DIR)/S98ircd-hybrid $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/
#	$(INSTALL) -d $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/bin
#	$(STRIP_COMMAND) $(IRCD-HYBRID_BUILD_DIR)/src/ircd -o $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/bin/ircd
#	$(INSTALL) -d $(IRCD_HYBRID_IPK_DIR)$(TARGET_PREFIX)/doc/ircd-hybrid
#	$(INSTALL) -m 644 $(IRCD-HYBRID_BUILD_DIR)/etc/simple.conf $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/doc/ircd-hybrid/simple.conf
#	$(INSTALL) -d $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(IRCD-HYBRID_SOURCE_DIR)/ircd-hybrid.conf $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/ircd-hybrid.conf
#	$(INSTALL) -d $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(IRCD-HYBRID_SOURCE_DIR)/rc.ircd-hybrid $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXircd-hybrid
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IRCD-HYBRID_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXircd-hybrid
	$(MAKE) $(IRCD-HYBRID_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(IRCD-HYBRID_SOURCE_DIR)/postinst $(IRCD-HYBRID_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IRCD-HYBRID_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(IRCD-HYBRID_SOURCE_DIR)/prerm $(IRCD-HYBRID_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IRCD-HYBRID_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(IRCD-HYBRID_IPK_DIR)/CONTROL/postinst $(IRCD-HYBRID_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(IRCD-HYBRID_CONFFILES) | sed -e 's/ /\n/g' > $(IRCD-HYBRID_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IRCD-HYBRID_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ircd-hybrid-ipk: $(IRCD-HYBRID_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ircd-hybrid-clean:
	rm -f $(IRCD-HYBRID_BUILD_DIR)/.built
	-$(MAKE) -C $(IRCD-HYBRID_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ircd-hybrid-dirclean:
	rm -rf $(BUILD_DIR)/$(IRCD-HYBRID_DIR) $(IRCD-HYBRID_BUILD_DIR) $(IRCD-HYBRID_IPK_DIR) $(IRCD-HYBRID_IPK)
#
#
# Some sanity check for the package.
#
ircd-hybrid-check: $(IRCD-HYBRID_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
