###########################################################
#
# ntfsprogs
#
###########################################################
#
# $Id$
#
# I have placed my name as maintainer so that people can ask
# questions. But feel free to update or change this package
# if there are reasons.
#
NTFSPROGS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/linux-ntfs
NTFSPROGS_VERSION=1.13.1
NTFSPROGS_SOURCE=ntfsprogs-$(NTFSPROGS_VERSION).tar.gz
NTFSPROGS_DIR=ntfsprogs-$(NTFSPROGS_VERSION)
NTFSPROGS_UNZIP=zcat
NTFSPROGS_MAINTAINER=Marcel Nijenhof <nslu2@pion.xs4all.nl>
NTFSPROGS_DESCRIPTION=NTFS filesystem libraries and utilities
NTFSPROGS_SECTION=admin
NTFSPROGS_PRIORITY=optional
NTFSPROGS_DEPENDS=
NTFSPROGS_SUGGESTS=
NTFSPROGS_CONFLICTS=

#
# NTFSPROGS_IPK_VERSION should be incremented when the ipk changes.
#
NTFSPROGS_IPK_VERSION=1

#
# NTFSPROGS_CONFFILES should be a list of user-editable files
# NTFSPROGS_CONFFILES=/opt/etc/ntfsprogs.conf /opt/etc/init.d/SXXntfsprogs

#
# NTFSPROGS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# NTFSPROGS_PATCHES=$(NTFSPROGS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NTFSPROGS_CPPFLAGS=
NTFSPROGS_LDFLAGS=

#
# NTFSPROGS_BUILD_DIR is the directory in which the build is done.
# NTFSPROGS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NTFSPROGS_IPK_DIR is the directory in which the ipk is built.
# NTFSPROGS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NTFSPROGS_BUILD_DIR=$(BUILD_DIR)/ntfsprogs
NTFSPROGS_SOURCE_DIR=$(SOURCE_DIR)/ntfsprogs
NTFSPROGS_IPK_DIR=$(BUILD_DIR)/ntfsprogs-$(NTFSPROGS_VERSION)-ipk
NTFSPROGS_IPK=$(BUILD_DIR)/ntfsprogs_$(NTFSPROGS_VERSION)-$(NTFSPROGS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NTFSPROGS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NTFSPROGS_SITE)/$(NTFSPROGS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ntfsprogs-source: $(DL_DIR)/$(NTFSPROGS_SOURCE) $(NTFSPROGS_PATCHES)

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
$(NTFSPROGS_BUILD_DIR)/.configured: $(DL_DIR)/$(NTFSPROGS_SOURCE) $(NTFSPROGS_PATCHES) make/ntfsprogs.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(NTFSPROGS_DIR) $(NTFSPROGS_BUILD_DIR)
	$(NTFSPROGS_UNZIP) $(DL_DIR)/$(NTFSPROGS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NTFSPROGS_PATCHES)" ; \
		then cat $(NTFSPROGS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NTFSPROGS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NTFSPROGS_DIR)" != "$(NTFSPROGS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NTFSPROGS_DIR) $(NTFSPROGS_BUILD_DIR) ; \
	fi
	(cd $(NTFSPROGS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NTFSPROGS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NTFSPROGS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-gnome-vfs \
		--disable-fuse-module \
		--program-transform-name="" \
	)
	$(PATCH_LIBTOOL) $(NTFSPROGS_BUILD_DIR)/libtool
	touch $(NTFSPROGS_BUILD_DIR)/.configured

ntfsprogs-unpack: $(NTFSPROGS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NTFSPROGS_BUILD_DIR)/.built: $(NTFSPROGS_BUILD_DIR)/.configured
	rm -f $(NTFSPROGS_BUILD_DIR)/.built
	$(MAKE) -C $(NTFSPROGS_BUILD_DIR)
	touch $(NTFSPROGS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ntfsprogs: $(NTFSPROGS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NTFSPROGS_BUILD_DIR)/.staged: $(NTFSPROGS_BUILD_DIR)/.built
	rm -f $(NTFSPROGS_BUILD_DIR)/.staged
	$(MAKE) -C $(NTFSPROGS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NTFSPROGS_BUILD_DIR)/.staged

ntfsprogs-stage: $(NTFSPROGS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ntfsprogs
#
$(NTFSPROGS_IPK_DIR)/CONTROL/control:
	@install -d $(NTFSPROGS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ntfsprogs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NTFSPROGS_PRIORITY)" >>$@
	@echo "Section: $(NTFSPROGS_SECTION)" >>$@
	@echo "Version: $(NTFSPROGS_VERSION)-$(NTFSPROGS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NTFSPROGS_MAINTAINER)" >>$@
	@echo "Source: $(NTFSPROGS_SITE)/$(NTFSPROGS_SOURCE)" >>$@
	@echo "Description: $(NTFSPROGS_DESCRIPTION)" >>$@
	@echo "Depends: $(NTFSPROGS_DEPENDS)" >>$@
	@echo "Suggests: $(NTFSPROGS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NTFSPROGS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NTFSPROGS_IPK_DIR)/opt/sbin or $(NTFSPROGS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NTFSPROGS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NTFSPROGS_IPK_DIR)/opt/etc/ntfsprogs/...
# Documentation files should be installed in $(NTFSPROGS_IPK_DIR)/opt/doc/ntfsprogs/...
# Daemon startup scripts should be installed in $(NTFSPROGS_IPK_DIR)/opt/etc/init.d/S??ntfsprogs
#
# You may need to patch your application to make it use these locations.
#
$(NTFSPROGS_IPK): $(NTFSPROGS_BUILD_DIR)/.built
	rm -rf $(NTFSPROGS_IPK_DIR) $(BUILD_DIR)/ntfsprogs_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NTFSPROGS_BUILD_DIR) DESTDIR=$(NTFSPROGS_IPK_DIR) install-strip
#	install -d $(NTFSPROGS_IPK_DIR)/opt/etc/
#	install -m 644 $(NTFSPROGS_SOURCE_DIR)/ntfsprogs.conf $(NTFSPROGS_IPK_DIR)/opt/etc/ntfsprogs.conf
#	install -d $(NTFSPROGS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NTFSPROGS_SOURCE_DIR)/rc.ntfsprogs $(NTFSPROGS_IPK_DIR)/opt/etc/init.d/SXXntfsprogs
	$(MAKE) $(NTFSPROGS_IPK_DIR)/CONTROL/control
#	install -m 755 $(NTFSPROGS_SOURCE_DIR)/postinst $(NTFSPROGS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NTFSPROGS_SOURCE_DIR)/prerm $(NTFSPROGS_IPK_DIR)/CONTROL/prerm
#	echo $(NTFSPROGS_CONFFILES) | sed -e 's/ /\n/g' > $(NTFSPROGS_IPK_DIR)/CONTROL/conffiles
	rm -f $(NTFSPROGS_IPK_DIR)/opt/lib/*.la
	rm -rf $(NTFSPROGS_IPK_DIR)/sbin
	rm -rf $(NTFSPROGS_IPK_DIR)/opt/include
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NTFSPROGS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ntfsprogs-ipk: $(NTFSPROGS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ntfsprogs-clean:
	rm -f $(NTFSPROGS_BUILD_DIR)/.built
	-$(MAKE) -C $(NTFSPROGS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ntfsprogs-dirclean:
	rm -rf $(BUILD_DIR)/$(NTFSPROGS_DIR) $(NTFSPROGS_BUILD_DIR) $(NTFSPROGS_IPK_DIR) $(NTFSPROGS_IPK)
