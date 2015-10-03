###########################################################
#
# ged
#
###########################################################

# You must replace "ged" and "GED" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GED_VERSION, GED_SITE and GED_SOURCE define
# the upstream location of the source code for the package.
# GED_DIR is the directory which is created when the source
# archive is unpacked.
# GED_UNZIP is the command used to unzip the source.
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
GED_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ged
GED_VERSION=0.1
GED_SOURCE=ged-$(GED_VERSION).tar.gz
GED_DIR=ged
GED_UNZIP=zcat
GED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GED_DESCRIPTION=The ged lightweight GTK+ 2 text editor.
GED_SECTION=editor
GED_PRIORITY=optional
GED_DEPENDS=gtk2
GED_SUGGESTS=
GED_CONFLICTS=

#
# GED_IPK_VERSION should be incremented when the ipk changes.
#
GED_IPK_VERSION=1

#
# GED_CONFFILES should be a list of user-editable files
#GED_CONFFILES=/opt/etc/ged.conf /opt/etc/init.d/SXXged

#
# GED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GED_PATCHES=$(GED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GED_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/glib-2.0 -I$(STAGING_INCLUDE_DIR)/cairo \
		-I$(STAGING_INCLUDE_DIR)/pango-1.0 -I$(STAGING_INCLUDE_DIR)/gtk-2.0 \
		-I$(STAGING_LIB_DIR)/gtk-2.0/include -I$(STAGING_INCLUDE_DIR)/gdk-pixbuf-2.0 \
		-I$(STAGING_INCLUDE_DIR)/atk-1.0
GED_LDFLAGS=-lgtk-x11-2.0 -lgobject-2.0 -lglib-2.0

#
# GED_BUILD_DIR is the directory in which the build is done.
# GED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GED_IPK_DIR is the directory in which the ipk is built.
# GED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GED_BUILD_DIR=$(BUILD_DIR)/ged
GED_SOURCE_DIR=$(SOURCE_DIR)/ged
GED_IPK_DIR=$(BUILD_DIR)/ged-$(GED_VERSION)-ipk
GED_IPK=$(BUILD_DIR)/ged_$(GED_VERSION)-$(GED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ged-source ged-unpack ged ged-stage ged-ipk ged-clean ged-dirclean ged-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GED_SOURCE):
	$(WGET) -P $(@D) $(GED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ged-source: $(DL_DIR)/$(GED_SOURCE) $(GED_PATCHES)

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
$(GED_BUILD_DIR)/.configured: $(DL_DIR)/$(GED_SOURCE) $(GED_PATCHES) make/ged.mk
	$(MAKE) gtk2-stage
	rm -rf $(BUILD_DIR)/$(GED_DIR) $(@D)
	$(GED_UNZIP) $(DL_DIR)/$(GED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GED_PATCHES)" ; \
		then cat $(GED_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(GED_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GED_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(GED_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GED_LDFLAGS)" \
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

ged-unpack: $(GED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GED_BUILD_DIR)/.built: $(GED_BUILD_DIR)/.configured
	rm -f $@
	cd $(@D); $(TARGET_CC) \
		$(STAGING_CPPFLAGS) $(GED_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(GED_LDFLAGS) \
			ged.c -o ged
	touch $@

#
# This is the build convenience target.
#
ged: $(GED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(GED_BUILD_DIR)/.staged: $(GED_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

#ged-stage: $(GED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ged
#
$(GED_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ged" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GED_PRIORITY)" >>$@
	@echo "Section: $(GED_SECTION)" >>$@
	@echo "Version: $(GED_VERSION)-$(GED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GED_MAINTAINER)" >>$@
	@echo "Source: $(GED_SITE)/$(GED_SOURCE)" >>$@
	@echo "Description: $(GED_DESCRIPTION)" >>$@
	@echo "Depends: $(GED_DEPENDS)" >>$@
	@echo "Suggests: $(GED_SUGGESTS)" >>$@
	@echo "Conflicts: $(GED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GED_IPK_DIR)/opt/sbin or $(GED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GED_IPK_DIR)/opt/etc/ged/...
# Documentation files should be installed in $(GED_IPK_DIR)/opt/doc/ged/...
# Daemon startup scripts should be installed in $(GED_IPK_DIR)/opt/etc/init.d/S??ged
#
# You may need to patch your application to make it use these locations.
#
$(GED_IPK): $(GED_BUILD_DIR)/.built
	rm -rf $(GED_IPK_DIR) $(BUILD_DIR)/ged_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(GED_IPK_DIR)/opt/bin
	$(INSTALL) -m 755 $(GED_BUILD_DIR)/ged $(GED_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(GED_IPK_DIR)/opt/bin/ged
#	$(INSTALL) -d $(GED_IPK_DIR)/opt/etc/
#	$(INSTALL) -m 644 $(GED_SOURCE_DIR)/ged.conf $(GED_IPK_DIR)/opt/etc/ged.conf
#	$(INSTALL) -d $(GED_IPK_DIR)/opt/etc/init.d
#	$(INSTALL) -m 755 $(GED_SOURCE_DIR)/rc.ged $(GED_IPK_DIR)/opt/etc/init.d/SXXged
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GED_IPK_DIR)/opt/etc/init.d/SXXged
	$(MAKE) $(GED_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(GED_SOURCE_DIR)/postinst $(GED_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GED_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(GED_SOURCE_DIR)/prerm $(GED_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GED_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(GED_IPK_DIR)/CONTROL/postinst $(GED_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(GED_CONFFILES) | sed -e 's/ /\n/g' > $(GED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GED_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(GED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ged-ipk: $(GED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ged-clean:
	rm -f $(GED_BUILD_DIR)/.built
	-$(MAKE) -C $(GED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ged-dirclean:
	rm -rf $(BUILD_DIR)/$(GED_DIR) $(GED_BUILD_DIR) $(GED_IPK_DIR) $(GED_IPK)
#
#
# Some sanity check for the package.
#
ged-check: $(GED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
