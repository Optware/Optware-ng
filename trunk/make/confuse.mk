###########################################################
#
# confuse
#
###########################################################
#
# CONFUSE_VERSION, CONFUSE_SITE and CONFUSE_SOURCE define
# the upstream location of the source code for the package.
# CONFUSE_DIR is the directory which is created when the source
# archive is unpacked.
# CONFUSE_UNZIP is the command used to unzip the source.
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
CONFUSE_SITE=http://bzero.se/confuse
CONFUSE_VERSION=2.6
CONFUSE_SOURCE=confuse-$(CONFUSE_VERSION).tar.gz
CONFUSE_DIR=confuse-$(CONFUSE_VERSION)
CONFUSE_UNZIP=zcat
CONFUSE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CONFUSE_DESCRIPTION=a configuration file parser library
CONFUSE_SECTION=libs
CONFUSE_PRIORITY=optional
CONFUSE_DEPENDS=
CONFUSE_SUGGESTS=
CONFUSE_CONFLICTS=

#
# CONFUSE_IPK_VERSION should be incremented when the ipk changes.
#
CONFUSE_IPK_VERSION=1

#
# CONFUSE_CONFFILES should be a list of user-editable files
#CONFUSE_CONFFILES=/opt/etc/confuse.conf /opt/etc/init.d/SXXconfuse

#
# CONFUSE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CONFUSE_PATCHES=$(CONFUSE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CONFUSE_CPPFLAGS=
CONFUSE_LDFLAGS=

#
# CONFUSE_BUILD_DIR is the directory in which the build is done.
# CONFUSE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CONFUSE_IPK_DIR is the directory in which the ipk is built.
# CONFUSE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CONFUSE_BUILD_DIR=$(BUILD_DIR)/confuse
CONFUSE_SOURCE_DIR=$(SOURCE_DIR)/confuse
CONFUSE_IPK_DIR=$(BUILD_DIR)/confuse-$(CONFUSE_VERSION)-ipk
CONFUSE_IPK=$(BUILD_DIR)/confuse_$(CONFUSE_VERSION)-$(CONFUSE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: confuse-source confuse-unpack confuse confuse-stage confuse-ipk confuse-clean confuse-dirclean confuse-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CONFUSE_SOURCE):
	$(WGET) -P $(DL_DIR) $(CONFUSE_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
confuse-source: $(DL_DIR)/$(CONFUSE_SOURCE) $(CONFUSE_PATCHES)

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
$(CONFUSE_BUILD_DIR)/.configured: $(DL_DIR)/$(CONFUSE_SOURCE) $(CONFUSE_PATCHES) make/confuse.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CONFUSE_DIR) $(@D)
	$(CONFUSE_UNZIP) $(DL_DIR)/$(CONFUSE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CONFUSE_PATCHES)" ; \
		then cat $(CONFUSE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CONFUSE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CONFUSE_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CONFUSE_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CONFUSE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CONFUSE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

confuse-unpack: $(CONFUSE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CONFUSE_BUILD_DIR)/.built: $(CONFUSE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
confuse: $(CONFUSE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CONFUSE_BUILD_DIR)/.staged: $(CONFUSE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

confuse-stage: $(CONFUSE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/confuse
#
$(CONFUSE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: confuse" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CONFUSE_PRIORITY)" >>$@
	@echo "Section: $(CONFUSE_SECTION)" >>$@
	@echo "Version: $(CONFUSE_VERSION)-$(CONFUSE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CONFUSE_MAINTAINER)" >>$@
	@echo "Source: $(CONFUSE_SITE)/$(CONFUSE_SOURCE)" >>$@
	@echo "Description: $(CONFUSE_DESCRIPTION)" >>$@
	@echo "Depends: $(CONFUSE_DEPENDS)" >>$@
	@echo "Suggests: $(CONFUSE_SUGGESTS)" >>$@
	@echo "Conflicts: $(CONFUSE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CONFUSE_IPK_DIR)/opt/sbin or $(CONFUSE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CONFUSE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CONFUSE_IPK_DIR)/opt/etc/confuse/...
# Documentation files should be installed in $(CONFUSE_IPK_DIR)/opt/doc/confuse/...
# Daemon startup scripts should be installed in $(CONFUSE_IPK_DIR)/opt/etc/init.d/S??confuse
#
# You may need to patch your application to make it use these locations.
#
$(CONFUSE_IPK): $(CONFUSE_BUILD_DIR)/.built
	rm -rf $(CONFUSE_IPK_DIR) $(BUILD_DIR)/confuse_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CONFUSE_BUILD_DIR) DESTDIR=$(CONFUSE_IPK_DIR) install-strip
#	install -d $(CONFUSE_IPK_DIR)/opt/etc/
#	install -m 644 $(CONFUSE_SOURCE_DIR)/confuse.conf $(CONFUSE_IPK_DIR)/opt/etc/confuse.conf
#	install -d $(CONFUSE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CONFUSE_SOURCE_DIR)/rc.confuse $(CONFUSE_IPK_DIR)/opt/etc/init.d/SXXconfuse
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CONFUSE_IPK_DIR)/opt/etc/init.d/SXXconfuse
	$(MAKE) $(CONFUSE_IPK_DIR)/CONTROL/control
#	install -m 755 $(CONFUSE_SOURCE_DIR)/postinst $(CONFUSE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CONFUSE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CONFUSE_SOURCE_DIR)/prerm $(CONFUSE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CONFUSE_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CONFUSE_IPK_DIR)/CONTROL/postinst $(CONFUSE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CONFUSE_CONFFILES) | sed -e 's/ /\n/g' > $(CONFUSE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CONFUSE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
confuse-ipk: $(CONFUSE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
confuse-clean:
	rm -f $(CONFUSE_BUILD_DIR)/.built
	-$(MAKE) -C $(CONFUSE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
confuse-dirclean:
	rm -rf $(BUILD_DIR)/$(CONFUSE_DIR) $(CONFUSE_BUILD_DIR) $(CONFUSE_IPK_DIR) $(CONFUSE_IPK)
#
#
# Some sanity check for the package.
#
confuse-check: $(CONFUSE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CONFUSE_IPK)
