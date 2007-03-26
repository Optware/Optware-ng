###########################################################
#
# bpalogin
#
###########################################################

#
# BPALOGIN_VERSION, BPALOGIN_SITE and BPALOGIN_SOURCE define
# the upstream location of the source code for the package.
# BPALOGIN_DIR is the directory which is created when the source
# archive is unpacked.
# BPALOGIN_UNZIP is the command used to unzip the source.
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
BPALOGIN_SITE=http://bpalogin.sourceforge.net/download
BPALOGIN_VERSION=2.0.2
BPALOGIN_SOURCE=bpalogin-$(BPALOGIN_VERSION).tar.gz
BPALOGIN_DIR=bpalogin-$(BPALOGIN_VERSION)
BPALOGIN_UNZIP=zcat
BPALOGIN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BPALOGIN_DESCRIPTION=BigPond Cable Network authentication client.
BPALOGIN_SECTION=net
BPALOGIN_PRIORITY=optional
BPALOGIN_DEPENDS=
BPALOGIN_SUGGESTS=
BPALOGIN_CONFLICTS=

#
# BPALOGIN_IPK_VERSION should be incremented when the ipk changes.
#
BPALOGIN_IPK_VERSION=2

#
# BPALOGIN_CONFFILES should be a list of user-editable files
BPALOGIN_CONFFILES=/opt/etc/bpalogin.conf /opt/etc/init.d/S05bpalogin

#
# BPALOGIN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BPALOGIN_PATCHES=$(BPALOGIN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BPALOGIN_CPPFLAGS=
BPALOGIN_LDFLAGS=

#
# BPALOGIN_BUILD_DIR is the directory in which the build is done.
# BPALOGIN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BPALOGIN_IPK_DIR is the directory in which the ipk is built.
# BPALOGIN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BPALOGIN_BUILD_DIR=$(BUILD_DIR)/bpalogin
BPALOGIN_SOURCE_DIR=$(SOURCE_DIR)/bpalogin
BPALOGIN_IPK_DIR=$(BUILD_DIR)/bpalogin-$(BPALOGIN_VERSION)-ipk
BPALOGIN_IPK=$(BUILD_DIR)/bpalogin_$(BPALOGIN_VERSION)-$(BPALOGIN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BPALOGIN_SOURCE):
	$(WGET) -P $(DL_DIR) $(BPALOGIN_SITE)/$(BPALOGIN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bpalogin-source: $(DL_DIR)/$(BPALOGIN_SOURCE) $(BPALOGIN_PATCHES)

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
$(BPALOGIN_BUILD_DIR)/.configured: $(DL_DIR)/$(BPALOGIN_SOURCE) $(BPALOGIN_PATCHES) make/bpalogin.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BPALOGIN_DIR) $(BPALOGIN_BUILD_DIR)
	$(BPALOGIN_UNZIP) $(DL_DIR)/$(BPALOGIN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BPALOGIN_PATCHES)" ; \
		then cat $(BPALOGIN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BPALOGIN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BPALOGIN_DIR)" != "$(BPALOGIN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BPALOGIN_DIR) $(BPALOGIN_BUILD_DIR) ; \
	fi
	(cd $(BPALOGIN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BPALOGIN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BPALOGIN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(BPALOGIN_BUILD_DIR)/libtool
	touch $(BPALOGIN_BUILD_DIR)/.configured

bpalogin-unpack: $(BPALOGIN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BPALOGIN_BUILD_DIR)/.built: $(BPALOGIN_BUILD_DIR)/.configured
	rm -f $(BPALOGIN_BUILD_DIR)/.built
	$(MAKE) -C $(BPALOGIN_BUILD_DIR)
	touch $(BPALOGIN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
bpalogin: $(BPALOGIN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BPALOGIN_BUILD_DIR)/.staged: $(BPALOGIN_BUILD_DIR)/.built
	rm -f $(BPALOGIN_BUILD_DIR)/.staged
	$(MAKE) -C $(BPALOGIN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BPALOGIN_BUILD_DIR)/.staged

bpalogin-stage: $(BPALOGIN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bpalogin
#
$(BPALOGIN_IPK_DIR)/CONTROL/control:
	@install -d $(BPALOGIN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bpalogin" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BPALOGIN_PRIORITY)" >>$@
	@echo "Section: $(BPALOGIN_SECTION)" >>$@
	@echo "Version: $(BPALOGIN_VERSION)-$(BPALOGIN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BPALOGIN_MAINTAINER)" >>$@
	@echo "Source: $(BPALOGIN_SITE)/$(BPALOGIN_SOURCE)" >>$@
	@echo "Description: $(BPALOGIN_DESCRIPTION)" >>$@
	@echo "Depends: $(BPALOGIN_DEPENDS)" >>$@
	@echo "Suggests: $(BPALOGIN_SUGGESTS)" >>$@
	@echo "Conflicts: $(BPALOGIN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BPALOGIN_IPK_DIR)/opt/sbin or $(BPALOGIN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BPALOGIN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BPALOGIN_IPK_DIR)/opt/etc/bpalogin/...
# Documentation files should be installed in $(BPALOGIN_IPK_DIR)/opt/doc/bpalogin/...
# Daemon startup scripts should be installed in $(BPALOGIN_IPK_DIR)/opt/etc/init.d/S??bpalogin
#
# You may need to patch your application to make it use these locations.
#
$(BPALOGIN_IPK): $(BPALOGIN_BUILD_DIR)/.built
	rm -rf $(BPALOGIN_IPK_DIR) $(BUILD_DIR)/bpalogin_*_$(TARGET_ARCH).ipk
	install -d $(BPALOGIN_IPK_DIR)/opt/sbin/
	install -m 755 $(BPALOGIN_BUILD_DIR)/bpalogin $(BPALOGIN_IPK_DIR)/opt/sbin/bpalogin
	install -d $(BPALOGIN_IPK_DIR)/opt/etc/
	install -m 644 $(BPALOGIN_SOURCE_DIR)/bpalogin.conf $(BPALOGIN_IPK_DIR)/opt/etc/bpalogin.conf
	install -d $(BPALOGIN_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BPALOGIN_SOURCE_DIR)/rc.bpalogin $(BPALOGIN_IPK_DIR)/opt/etc/init.d/S05bpalogin
	$(MAKE) $(BPALOGIN_IPK_DIR)/CONTROL/control
	install -m 755 $(BPALOGIN_SOURCE_DIR)/postinst $(BPALOGIN_IPK_DIR)/CONTROL/postinst
	install -m 755 $(BPALOGIN_SOURCE_DIR)/prerm $(BPALOGIN_IPK_DIR)/CONTROL/prerm
	echo $(BPALOGIN_CONFFILES) | sed -e 's/ /\n/g' > $(BPALOGIN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BPALOGIN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bpalogin-ipk: $(BPALOGIN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bpalogin-clean:
	rm -f $(BPALOGIN_BUILD_DIR)/.built
	-$(MAKE) -C $(BPALOGIN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bpalogin-dirclean:
	rm -rf $(BUILD_DIR)/$(BPALOGIN_DIR) $(BPALOGIN_BUILD_DIR) $(BPALOGIN_IPK_DIR) $(BPALOGIN_IPK)
