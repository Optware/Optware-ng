###########################################################
#
# ppower
#
###########################################################

# You must replace "ppower" and "PPOWER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# PPOWER_VERSION, PPOWER_SITE and PPOWER_SOURCE define
# the upstream location of the source code for the package.
# PPOWER_DIR is the directory which is created when the source
# archive is unpacked.
# PPOWER_UNZIP is the command used to unzip the source.
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
PPOWER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ppower
PPOWER_VERSION=0.1.5
PPOWER_SOURCE=ppower-$(PPOWER_VERSION).tar.gz
PPOWER_DIR=ppower-$(PPOWER_VERSION)
PPOWER_UNZIP=zcat
PPOWER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PPOWER_DESCRIPTION=Ppower, short for 'Penguin Power', is a piece of software for controlling x10 home automation equipment connected to the computer via a cm11a interface.
PPOWER_SECTION=misc
PPOWER_PRIORITY=optional
PPOWER_DEPENDS=
PPOWER_SUGGESTS=
PPOWER_CONFLICTS=

#
# PPOWER_IPK_VERSION should be incremented when the ipk changes.
#
PPOWER_IPK_VERSION=1

#
# PPOWER_CONFFILES should be a list of user-editable files
PPOWER_CONFFILES=/opt/etc/ppower.conf
#/etc/ppower.init
# /opt/etc/init.d/SXXppower

#
# PPOWER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#PPOWER_PATCHES=$(PPOWER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PPOWER_CPPFLAGS=
PPOWER_LDFLAGS=

#
# PPOWER_BUILD_DIR is the directory in which the build is done.
# PPOWER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PPOWER_IPK_DIR is the directory in which the ipk is built.
# PPOWER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PPOWER_BUILD_DIR=$(BUILD_DIR)/ppower
PPOWER_SOURCE_DIR=$(SOURCE_DIR)/ppower
PPOWER_IPK_DIR=$(BUILD_DIR)/ppower-$(PPOWER_VERSION)-ipk
PPOWER_IPK=$(BUILD_DIR)/ppower_$(PPOWER_VERSION)-$(PPOWER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ppower-source ppower-unpack ppower ppower-stage ppower-ipk ppower-clean ppower-dirclean ppower-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PPOWER_SOURCE):
	$(WGET) -P $(@D) $(PPOWER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ppower-source: $(DL_DIR)/$(PPOWER_SOURCE) $(PPOWER_PATCHES)

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
$(PPOWER_BUILD_DIR)/.configured: $(DL_DIR)/$(PPOWER_SOURCE) $(PPOWER_PATCHES) make/ppower.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PPOWER_DIR) $(@D)
	$(PPOWER_UNZIP) $(DL_DIR)/$(PPOWER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PPOWER_PATCHES)" ; \
		then cat $(PPOWER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PPOWER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PPOWER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PPOWER_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PPOWER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PPOWER_LDFLAGS)" \
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

ppower-unpack: $(PPOWER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PPOWER_BUILD_DIR)/.built: $(PPOWER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ppower: $(PPOWER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PPOWER_BUILD_DIR)/.staged: $(PPOWER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ppower-stage: $(PPOWER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ppower
#
$(PPOWER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ppower" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PPOWER_PRIORITY)" >>$@
	@echo "Section: $(PPOWER_SECTION)" >>$@
	@echo "Version: $(PPOWER_VERSION)-$(PPOWER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PPOWER_MAINTAINER)" >>$@
	@echo "Source: $(PPOWER_SITE)/$(PPOWER_SOURCE)" >>$@
	@echo "Description: $(PPOWER_DESCRIPTION)" >>$@
	@echo "Depends: $(PPOWER_DEPENDS)" >>$@
	@echo "Suggests: $(PPOWER_SUGGESTS)" >>$@
	@echo "Conflicts: $(PPOWER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PPOWER_IPK_DIR)/opt/sbin or $(PPOWER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PPOWER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PPOWER_IPK_DIR)/opt/etc/ppower/...
# Documentation files should be installed in $(PPOWER_IPK_DIR)/opt/doc/ppower/...
# Daemon startup scripts should be installed in $(PPOWER_IPK_DIR)/opt/etc/init.d/S??ppower
#
# You may need to patch your application to make it use these locations.
#
$(PPOWER_IPK): $(PPOWER_BUILD_DIR)/.built
	rm -rf $(PPOWER_IPK_DIR) $(BUILD_DIR)/ppower_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PPOWER_BUILD_DIR) DESTDIR=$(PPOWER_IPK_DIR) install-strip
	install -d $(PPOWER_IPK_DIR)/opt/etc/
	install -m 644 $(PPOWER_BUILD_DIR)/etc/ppower.conf $(PPOWER_IPK_DIR)/opt/etc/ppower.conf
#	install -d $(PPOWER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(PPOWER_SOURCE_DIR)/rc.ppower $(PPOWER_IPK_DIR)/opt/etc/init.d/SXXppower
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PPOWER_IPK_DIR)/opt/etc/init.d/SXXppower
	$(MAKE) $(PPOWER_IPK_DIR)/CONTROL/control
#	install -m 755 $(PPOWER_SOURCE_DIR)/postinst $(PPOWER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PPOWER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PPOWER_SOURCE_DIR)/prerm $(PPOWER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(PPOWER_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(PPOWER_IPK_DIR)/CONTROL/postinst $(PPOWER_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(PPOWER_CONFFILES) | sed -e 's/ /\n/g' > $(PPOWER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PPOWER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ppower-ipk: $(PPOWER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ppower-clean:
	rm -f $(PPOWER_BUILD_DIR)/.built
	-$(MAKE) -C $(PPOWER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ppower-dirclean:
	rm -rf $(BUILD_DIR)/$(PPOWER_DIR) $(PPOWER_BUILD_DIR) $(PPOWER_IPK_DIR) $(PPOWER_IPK)
#
#
# Some sanity check for the package.
#
ppower-check: $(PPOWER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
