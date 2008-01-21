###########################################################
#
# liblcms
#
###########################################################
#
# LIBLCMS_VERSION, LIBLCMS_SITE and LIBLCMS_SOURCE define
# the upstream location of the source code for the package.
# LIBLCMS_DIR is the directory which is created when the source
# archive is unpacked.
# LIBLCMS_UNZIP is the command used to unzip the source.
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
LIBLCMS_SITE=http://www.littlecms.com
LIBLCMS_VERSION=1.15
LIBLCMS_SOURCE=lcms-$(LIBLCMS_VERSION).tar.gz
LIBLCMS_DIR=lcms-$(LIBLCMS_VERSION)
LIBLCMS_UNZIP=zcat
LIBLCMS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBLCMS_DESCRIPTION=A small-footprint, speed optimized color management engine.
LIBLCMS_SECTION=graphics
LIBLCMS_PRIORITY=optional
LIBLCMS_DEPENDS=
LIBLCMS_SUGGESTS=
LIBLCMS_CONFLICTS=

#
# LIBLCMS_IPK_VERSION should be incremented when the ipk changes.
#
LIBLCMS_IPK_VERSION=1

#
# LIBLCMS_CONFFILES should be a list of user-editable files
#LIBLCMS_CONFFILES=/opt/etc/liblcms.conf /opt/etc/init.d/SXXliblcms

#
# LIBLCMS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBLCMS_PATCHES=$(LIBLCMS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBLCMS_CPPFLAGS=
LIBLCMS_LDFLAGS=

#
# LIBLCMS_BUILD_DIR is the directory in which the build is done.
# LIBLCMS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBLCMS_IPK_DIR is the directory in which the ipk is built.
# LIBLCMS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBLCMS_BUILD_DIR=$(BUILD_DIR)/liblcms
LIBLCMS_SOURCE_DIR=$(SOURCE_DIR)/liblcms
LIBLCMS_IPK_DIR=$(BUILD_DIR)/liblcms-$(LIBLCMS_VERSION)-ipk
LIBLCMS_IPK=$(BUILD_DIR)/liblcms_$(LIBLCMS_VERSION)-$(LIBLCMS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBLCMS_SOURCE):
	$(WGET) -P $(DL_DIR) $(LIBLCMS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
liblcms-source: $(DL_DIR)/$(LIBLCMS_SOURCE) $(LIBLCMS_PATCHES)

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
$(LIBLCMS_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBLCMS_SOURCE) $(LIBLCMS_PATCHES)
# make/liblcms.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBLCMS_DIR) $(LIBLCMS_BUILD_DIR)
	$(LIBLCMS_UNZIP) $(DL_DIR)/$(LIBLCMS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBLCMS_PATCHES)" ; \
		then cat $(LIBLCMS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LIBLCMS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBLCMS_DIR)" != "$(LIBLCMS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LIBLCMS_DIR) $(LIBLCMS_BUILD_DIR) ; \
	fi
	(cd $(LIBLCMS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBLCMS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBLCMS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(LIBLCMS_BUILD_DIR)/libtool
	touch $(LIBLCMS_BUILD_DIR)/.configured

liblcms-unpack: $(LIBLCMS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBLCMS_BUILD_DIR)/.built: $(LIBLCMS_BUILD_DIR)/.configured
	rm -f $(LIBLCMS_BUILD_DIR)/.built
	$(MAKE) -C $(LIBLCMS_BUILD_DIR)
	touch $(LIBLCMS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
liblcms: $(LIBLCMS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBLCMS_BUILD_DIR)/.staged: $(LIBLCMS_BUILD_DIR)/.built
	rm -f $(LIBLCMS_BUILD_DIR)/.staged
	$(MAKE) -C $(LIBLCMS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(LIBLCMS_BUILD_DIR)/.staged

liblcms-stage: $(LIBLCMS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/liblcms
#
$(LIBLCMS_IPK_DIR)/CONTROL/control:
	@install -d $(LIBLCMS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: liblcms" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBLCMS_PRIORITY)" >>$@
	@echo "Section: $(LIBLCMS_SECTION)" >>$@
	@echo "Version: $(LIBLCMS_VERSION)-$(LIBLCMS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBLCMS_MAINTAINER)" >>$@
	@echo "Source: $(LIBLCMS_SITE)/$(LIBLCMS_SOURCE)" >>$@
	@echo "Description: $(LIBLCMS_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBLCMS_DEPENDS)" >>$@
	@echo "Suggests: $(LIBLCMS_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBLCMS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBLCMS_IPK_DIR)/opt/sbin or $(LIBLCMS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBLCMS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LIBLCMS_IPK_DIR)/opt/etc/liblcms/...
# Documentation files should be installed in $(LIBLCMS_IPK_DIR)/opt/doc/liblcms/...
# Daemon startup scripts should be installed in $(LIBLCMS_IPK_DIR)/opt/etc/init.d/S??liblcms
#
# You may need to patch your application to make it use these locations.
#
$(LIBLCMS_IPK): $(LIBLCMS_BUILD_DIR)/.built
	rm -rf $(LIBLCMS_IPK_DIR) $(BUILD_DIR)/liblcms_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBLCMS_BUILD_DIR) DESTDIR=$(LIBLCMS_IPK_DIR) install-strip
#	install -d $(LIBLCMS_IPK_DIR)/opt/etc/
#	install -m 644 $(LIBLCMS_SOURCE_DIR)/liblcms.conf $(LIBLCMS_IPK_DIR)/opt/etc/liblcms.conf
#	install -d $(LIBLCMS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(LIBLCMS_SOURCE_DIR)/rc.liblcms $(LIBLCMS_IPK_DIR)/opt/etc/init.d/SXXliblcms
	$(MAKE) $(LIBLCMS_IPK_DIR)/CONTROL/control
#	install -m 755 $(LIBLCMS_SOURCE_DIR)/postinst $(LIBLCMS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(LIBLCMS_SOURCE_DIR)/prerm $(LIBLCMS_IPK_DIR)/CONTROL/prerm
	echo $(LIBLCMS_CONFFILES) | sed -e 's/ /\n/g' > $(LIBLCMS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBLCMS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
liblcms-ipk: $(LIBLCMS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
liblcms-clean:
	rm -f $(LIBLCMS_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBLCMS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
liblcms-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBLCMS_DIR) $(LIBLCMS_BUILD_DIR) $(LIBLCMS_IPK_DIR) $(LIBLCMS_IPK)
