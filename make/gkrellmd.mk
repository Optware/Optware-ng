###########################################################
#
# gkrellmd
#
###########################################################

# You must replace "gkrellmd" and "GKRELLMD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GKRELLMD_VERSION, GKRELLMD_SITE and GKRELLMD_SOURCE define
# the upstream location of the source code for the package.
# GKRELLMD_DIR is the directory which is created when the source
# archive is unpacked.
# GKRELLMD_UNZIP is the command used to unzip the source.
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
GKRELLMD_SITE=http://members.dslextreme.com/users/billw/gkrellm
GKRELLMD_VERSION=2.3.2
GKRELLMD_SOURCE=gkrellm-$(GKRELLMD_VERSION).tar.gz
GKRELLMD_DIR=gkrellm-$(GKRELLMD_VERSION)
GKRELLMD_UNZIP=zcat
GKRELLMD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GKRELLMD_DESCRIPTION=Gkrellm is a utility to display system stats (cpu, processes, memory,..) in a nice little window. (Server component)
GKRELLMD_SECTION=util
GKRELLMD_PRIORITY=optional
GKRELLMD_DEPENDS=glib, zlib
GKRELLMD_SUGGESTS=
GKRELLMD_CONFLICTS=

#
# GKRELLMD_IPK_VERSION should be incremented when the ipk changes.
#
GKRELLMD_IPK_VERSION=4

#
# GKRELLMD_CONFFILES should be a list of user-editable files
GKRELLMD_CONFFILES=$(TARGET_PREFIX)/etc/init.d/S60gkrellmd

#
# GKRELLMD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GKRELLMD_PATCHES=$(GKRELLMD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GKRELLMD_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0
GKRELLMD_LDFLAGS=\
		-lz \
		-lgmodule-2.0 \
		-lglib-2.0 \
		-lgthread-2.0 \
		-pthread
GKRELLMD_MAKE_OPTIONS=\
		CC="$(TARGET_CC) -Wall -O2 -I.. -I../shared -DGKRELLM_SERVER $(STAGING_CPPFLAGS) $(GKRELLMD_CPPFLAGS)"\
		RANLIB=$(TARGET_RANLIB) \
		AR=$(TARGET_AR) \
		LD=$(TARGET_LD) \
		SYS_LIBS="$(STAGING_LDFLAGS) $(GKRELLMD_LDFLAGS)"

#
# GKRELLMD_BUILD_DIR is the directory in which the build is done.
# GKRELLMD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GKRELLMD_IPK_DIR is the directory in which the ipk is built.
# GKRELLMD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GKRELLMD_BUILD_DIR=$(BUILD_DIR)/gkrellmd
GKRELLMD_SOURCE_DIR=$(SOURCE_DIR)/gkrellmd
GKRELLMD_IPK_DIR=$(BUILD_DIR)/gkrellmd-$(GKRELLMD_VERSION)-ipk
GKRELLMD_IPK=$(BUILD_DIR)/gkrellmd_$(GKRELLMD_VERSION)-$(GKRELLMD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gkrellmd-source gkrellmd-unpack gkrellmd gkrellmd-ipk gkrellmd-clean gkrellmd-dirclean gkrellmd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GKRELLMD_SOURCE):
	$(WGET) -P $(@D) $(GKRELLMD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gkrellmd-source: $(DL_DIR)/$(GKRELLMD_SOURCE) $(GKRELLMD_PATCHES)

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
$(GKRELLMD_BUILD_DIR)/.configured: $(DL_DIR)/$(GKRELLMD_SOURCE) $(GKRELLMD_PATCHES) make/gkrellmd.mk
	$(MAKE) glib-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(GKRELLMD_DIR) $(@D)
	$(GKRELLMD_UNZIP) $(DL_DIR)/$(GKRELLMD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GKRELLMD_PATCHES)" ; \
		then cat $(GKRELLMD_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GKRELLMD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GKRELLMD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GKRELLMD_DIR) $(@D) ; \
	fi
	sed -i -e s/override/#override/ $(@D)/server/Makefile
	touch $@

gkrellmd-unpack: $(GKRELLMD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GKRELLMD_BUILD_DIR)/.built: $(GKRELLMD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)/server $(GKRELLMD_MAKE_OPTIONS)
	touch $@

#
# This is the build convenience target.
#
gkrellmd: $(GKRELLMD_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gkrellmd
#
$(GKRELLMD_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gkrellmd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GKRELLMD_PRIORITY)" >>$@
	@echo "Section: $(GKRELLMD_SECTION)" >>$@
	@echo "Version: $(GKRELLMD_VERSION)-$(GKRELLMD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GKRELLMD_MAINTAINER)" >>$@
	@echo "Source: $(GKRELLMD_SITE)/$(GKRELLMD_SOURCE)" >>$@
	@echo "Description: $(GKRELLMD_DESCRIPTION)" >>$@
	@echo "Depends: $(GKRELLMD_DEPENDS)" >>$@
	@echo "Suggests: $(GKRELLMD_SUGGESTS)" >>$@
	@echo "Conflicts: $(GKRELLMD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/gkrellmd/...
# Documentation files should be installed in $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/doc/gkrellmd/...
# Daemon startup scripts should be installed in $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gkrellmd
#
# You may need to patch your application to make it use these locations.
#
$(GKRELLMD_IPK): $(GKRELLMD_BUILD_DIR)/.built
	rm -rf $(GKRELLMD_IPK_DIR) $(BUILD_DIR)/gkrellmd_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/sbin $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
	$(STRIP_COMMAND) $(GKRELLMD_BUILD_DIR)/server/gkrellmd -o $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/sbin/gkrellmd
	$(INSTALL) -m 755 $(GKRELLMD_SOURCE_DIR)/rc.gkrellmd $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S60gkrellmd
#	$(INSTALL) -d $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(GKRELLMD_SOURCE_DIR)/gkrellmd.conf $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/gkrellmd.conf
#	$(INSTALL) -d $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(GKRELLMD_SOURCE_DIR)/rc.gkrellmd $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgkrellmd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GKRELLMD_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXgkrellmd
	$(MAKE) $(GKRELLMD_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GKRELLMD_SOURCE_DIR)/postinst $(GKRELLMD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GKRELLMD_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GKRELLMD_SOURCE_DIR)/prerm $(GKRELLMD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GKRELLMD_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GKRELLMD_IPK_DIR)/CONTROL/postinst $(GKRELLMD_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GKRELLMD_CONFFILES) | sed -e 's/ /\n/g' > $(GKRELLMD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GKRELLMD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gkrellmd-ipk: $(GKRELLMD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gkrellmd-clean:
	rm -f $(GKRELLMD_BUILD_DIR)/.built
	-$(MAKE) -C $(GKRELLMD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gkrellmd-dirclean:
	rm -rf $(BUILD_DIR)/$(GKRELLMD_DIR) $(GKRELLMD_BUILD_DIR) $(GKRELLMD_IPK_DIR) $(GKRELLMD_IPK)
#
#
# Some sanity check for the package.
#
gkrellmd-check: $(GKRELLMD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
