###########################################################
#
# fuse-exfat
#
###########################################################
#
# FUSE_EXFAT_VERSION, FUSE_EXFAT_SITE and FUSE_EXFAT_SOURCE define
# the upstream location of the source code for the package.
# FUSE_EXFAT_DIR is the directory which is created when the source
# archive is unpacked.
# FUSE_EXFAT_UNZIP is the command used to unzip the source.
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
FUSE_EXFAT_SITE=http://pkgbuild.com/~giovanni/exfat
FUSE_EXFAT_VERSION=1.1.0
FUSE_EXFAT_SOURCE=fuse-exfat-$(FUSE_EXFAT_VERSION).tar.gz
FUSE_EXFAT_DIR=fuse-exfat-$(FUSE_EXFAT_VERSION)
FUSE_EXFAT_UNZIP=zcat
FUSE_EXFAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FUSE_EXFAT_DESCRIPTION=exFAT file system implementation as a FUSE module.
FUSE_EXFAT_SECTION=misc
FUSE_EXFAT_PRIORITY=optional
FUSE_EXFAT_DEPENDS=libfuse
FUSE_EXFAT_SUGGESTS=
FUSE_EXFAT_CONFLICTS=

#
# FUSE_EXFAT_IPK_VERSION should be incremented when the ipk changes.
#
FUSE_EXFAT_IPK_VERSION=1

#
# FUSE_EXFAT_CONFFILES should be a list of user-editable files
#FUSE_EXFAT_CONFFILES=/opt/etc/fuse-exfat.conf /opt/etc/init.d/SXXfuse-exfat

#
# FUSE_EXFAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FUSE_EXFAT_PATCHES=$(FUSE_EXFAT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FUSE_EXFAT_CPPFLAGS=-std=c99
FUSE_EXFAT_LDFLAGS=

#
# FUSE_EXFAT_BUILD_DIR is the directory in which the build is done.
# FUSE_EXFAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FUSE_EXFAT_IPK_DIR is the directory in which the ipk is built.
# FUSE_EXFAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FUSE_EXFAT_BUILD_DIR=$(BUILD_DIR)/fuse-exfat
FUSE_EXFAT_SOURCE_DIR=$(SOURCE_DIR)/fuse-exfat
FUSE_EXFAT_IPK_DIR=$(BUILD_DIR)/fuse-exfat-$(FUSE_EXFAT_VERSION)-ipk
FUSE_EXFAT_IPK=$(BUILD_DIR)/fuse-exfat_$(FUSE_EXFAT_VERSION)-$(FUSE_EXFAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fuse-exfat-source fuse-exfat-unpack fuse-exfat fuse-exfat-stage fuse-exfat-ipk fuse-exfat-clean fuse-exfat-dirclean fuse-exfat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FUSE_EXFAT_SOURCE):
	$(WGET) -P $(@D) $(FUSE_EXFAT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fuse-exfat-source: $(DL_DIR)/$(FUSE_EXFAT_SOURCE) $(FUSE_EXFAT_PATCHES)

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
$(FUSE_EXFAT_BUILD_DIR)/.configured: $(DL_DIR)/$(FUSE_EXFAT_SOURCE) $(FUSE_EXFAT_PATCHES) make/fuse-exfat.mk
	$(MAKE) fuse-stage
	rm -rf $(BUILD_DIR)/$(FUSE_EXFAT_DIR) $(@D)
	$(FUSE_EXFAT_UNZIP) $(DL_DIR)/$(FUSE_EXFAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FUSE_EXFAT_PATCHES)" ; \
		then cat $(FUSE_EXFAT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FUSE_EXFAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FUSE_EXFAT_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FUSE_EXFAT_DIR) $(@D) ; \
	fi
	touch $@

fuse-exfat-unpack: $(FUSE_EXFAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FUSE_EXFAT_BUILD_DIR)/.built: $(FUSE_EXFAT_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CCFLAGS="$(STAGING_CPPFLAGS) $(FUSE_EXFAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FUSE_EXFAT_LDFLAGS)" \
		scons \
	)
	touch $@

#
# This is the build convenience target.
#
fuse-exfat: $(FUSE_EXFAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FUSE_EXFAT_BUILD_DIR)/.staged: $(FUSE_EXFAT_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

fuse-exfat-stage: $(FUSE_EXFAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fuse-exfat
#
$(FUSE_EXFAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fuse-exfat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FUSE_EXFAT_PRIORITY)" >>$@
	@echo "Section: $(FUSE_EXFAT_SECTION)" >>$@
	@echo "Version: $(FUSE_EXFAT_VERSION)-$(FUSE_EXFAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FUSE_EXFAT_MAINTAINER)" >>$@
	@echo "Source: $(FUSE_EXFAT_SITE)/$(FUSE_EXFAT_SOURCE)" >>$@
	@echo "Description: $(FUSE_EXFAT_DESCRIPTION)" >>$@
	@echo "Depends: $(FUSE_EXFAT_DEPENDS)" >>$@
	@echo "Suggests: $(FUSE_EXFAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(FUSE_EXFAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FUSE_EXFAT_IPK_DIR)/opt/sbin or $(FUSE_EXFAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FUSE_EXFAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FUSE_EXFAT_IPK_DIR)/opt/etc/fuse-exfat/...
# Documentation files should be installed in $(FUSE_EXFAT_IPK_DIR)/opt/doc/fuse-exfat/...
# Daemon startup scripts should be installed in $(FUSE_EXFAT_IPK_DIR)/opt/etc/init.d/S??fuse-exfat
#
# You may need to patch your application to make it use these locations.
#
$(FUSE_EXFAT_IPK): $(FUSE_EXFAT_BUILD_DIR)/.built
	rm -rf $(FUSE_EXFAT_IPK_DIR) $(BUILD_DIR)/fuse-exfat_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(FUSE_EXFAT_BUILD_DIR) DESTDIR=$(FUSE_EXFAT_IPK_DIR) install-strip
	install -d $(FUSE_EXFAT_IPK_DIR)/opt/sbin
	install -m 755 $(FUSE_EXFAT_BUILD_DIR)/fuse/mount.exfat-fuse $(FUSE_EXFAT_IPK_DIR)/opt/sbin
	$(STRIP_COMMAND) $(FUSE_EXFAT_IPK_DIR)/opt/sbin/mount.exfat-fuse
	ln -s mount.exfat-fuse $(FUSE_EXFAT_IPK_DIR)/opt/sbin/mount.exfat
#	install -d $(FUSE_EXFAT_IPK_DIR)/opt/etc/
#	install -m 644 $(FUSE_EXFAT_SOURCE_DIR)/fuse-exfat.conf $(FUSE_EXFAT_IPK_DIR)/opt/etc/fuse-exfat.conf
#	install -d $(FUSE_EXFAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FUSE_EXFAT_SOURCE_DIR)/rc.fuse-exfat $(FUSE_EXFAT_IPK_DIR)/opt/etc/init.d/SXXfuse-exfat
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_EXFAT_IPK_DIR)/opt/etc/init.d/SXXfuse-exfat
	$(MAKE) $(FUSE_EXFAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(FUSE_EXFAT_SOURCE_DIR)/postinst $(FUSE_EXFAT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_EXFAT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FUSE_EXFAT_SOURCE_DIR)/prerm $(FUSE_EXFAT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUSE_EXFAT_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FUSE_EXFAT_IPK_DIR)/CONTROL/postinst $(FUSE_EXFAT_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FUSE_EXFAT_CONFFILES) | sed -e 's/ /\n/g' > $(FUSE_EXFAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FUSE_EXFAT_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(FUSE_EXFAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fuse-exfat-ipk: $(FUSE_EXFAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fuse-exfat-clean:
	rm -f $(FUSE_EXFAT_BUILD_DIR)/.built
	-$(MAKE) -C $(FUSE_EXFAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fuse-exfat-dirclean:
	rm -rf $(BUILD_DIR)/$(FUSE_EXFAT_DIR) $(FUSE_EXFAT_BUILD_DIR) $(FUSE_EXFAT_IPK_DIR) $(FUSE_EXFAT_IPK)
#
#
# Some sanity check for the package.
#
fuse-exfat-check: $(FUSE_EXFAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
