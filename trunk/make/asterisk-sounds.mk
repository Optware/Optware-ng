###########################################################
#
# asterisk-sounds
#
###########################################################

# You must replace "asterisk-sounds" and "ASTERISK-SOUNDS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ASTERISK-SOUNDS_VERSION, ASTERISK-SOUNDS_SITE and ASTERISK-SOUNDS_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK-SOUNDS_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK-SOUNDS_UNZIP is the command used to unzip the source.
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
ASTERISK-SOUNDS_SITE=http://ftp.digium.com/pub/asterisk
ASTERISK-SOUNDS_VERSION=1.2.1
ASTERISK-SOUNDS_SOURCE=asterisk-sounds-$(ASTERISK-SOUNDS_VERSION).tar.gz
ASTERISK-SOUNDS_DIR=asterisk-sounds-$(ASTERISK-SOUNDS_VERSION)
ASTERISK-SOUNDS_UNZIP=zcat
ASTERISK-SOUNDS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK-SOUNDS_DESCRIPTION=Supplementary asterisk-sounds.
ASTERISK-SOUNDS_SECTION=misc
ASTERISK-SOUNDS_PRIORITY=optional
ASTERISK-SOUNDS_DEPENDS=
ASTERISK-SOUNDS_CONFLICTS=asterisk14

#
# ASTERISK-SOUNDS_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK-SOUNDS_IPK_VERSION=1

#
# ASTERISK-SOUNDS_CONFFILES should be a list of user-editable files
#ASTERISK-SOUNDS_CONFFILES=/opt/etc/asterisk-sounds.conf /opt/etc/init.d/SXXasterisk-sounds

#
# ASTERISK-SOUNDS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK-SOUNDS_PATCHES=$(ASTERISK-SOUNDS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK-SOUNDS_CPPFLAGS=
ASTERISK-SOUNDS_LDFLAGS=

#
# ASTERISK-SOUNDS_BUILD_DIR is the directory in which the build is done.
# ASTERISK-SOUNDS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK-SOUNDS_IPK_DIR is the directory in which the ipk is built.
# ASTERISK-SOUNDS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK-SOUNDS_BUILD_DIR=$(BUILD_DIR)/asterisk-sounds
ASTERISK-SOUNDS_SOURCE_DIR=$(SOURCE_DIR)/asterisk-sounds
ASTERISK-SOUNDS_IPK_DIR=$(BUILD_DIR)/asterisk-sounds-$(ASTERISK-SOUNDS_VERSION)-ipk
ASTERISK-SOUNDS_IPK=$(BUILD_DIR)/asterisk-sounds_$(ASTERISK-SOUNDS_VERSION)-$(ASTERISK-SOUNDS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK-SOUNDS_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK-SOUNDS_SITE)/$(ASTERISK-SOUNDS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk-sounds-source: $(DL_DIR)/$(ASTERISK-SOUNDS_SOURCE) $(ASTERISK-SOUNDS_PATCHES)

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
$(ASTERISK-SOUNDS_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK-SOUNDS_SOURCE) $(ASTERISK-SOUNDS_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK-SOUNDS_DIR) $(ASTERISK-SOUNDS_BUILD_DIR)
	$(ASTERISK-SOUNDS_UNZIP) $(DL_DIR)/$(ASTERISK-SOUNDS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(ASTERISK-SOUNDS_PATCHES) | patch -d $(BUILD_DIR)/$(ASTERISK-SOUNDS_DIR) -p1
	mv $(BUILD_DIR)/$(ASTERISK-SOUNDS_DIR) $(ASTERISK-SOUNDS_BUILD_DIR)
#	(cd $(ASTERISK-SOUNDS_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK-SOUNDS_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK-SOUNDS_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
	)
	touch $(ASTERISK-SOUNDS_BUILD_DIR)/.configured

asterisk-sounds-unpack: $(ASTERISK-SOUNDS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK-SOUNDS_BUILD_DIR)/.built: $(ASTERISK-SOUNDS_BUILD_DIR)/.configured
	rm -f $(ASTERISK-SOUNDS_BUILD_DIR)/.built
#	$(MAKE) -C $(ASTERISK-SOUNDS_BUILD_DIR)
	touch $(ASTERISK-SOUNDS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk-sounds: $(ASTERISK-SOUNDS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK-SOUNDS_BUILD_DIR)/.staged: $(ASTERISK-SOUNDS_BUILD_DIR)/.built
	rm -f $(ASTERISK-SOUNDS_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK-SOUNDS_BUILD_DIR) DESTDIR=$(STAGING_DIR) \
	INSTALL_PREFIX=/opt install
	touch $(ASTERISK-SOUNDS_BUILD_DIR)/.staged

asterisk-sounds-stage: $(ASTERISK-SOUNDS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk-sounds
#
$(ASTERISK-SOUNDS_IPK_DIR)/CONTROL/control:
	@install -d $(ASTERISK-SOUNDS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: asterisk-sounds" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK-SOUNDS_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK-SOUNDS_SECTION)" >>$@
	@echo "Version: $(ASTERISK-SOUNDS_VERSION)-$(ASTERISK-SOUNDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK-SOUNDS_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK-SOUNDS_SITE)/$(ASTERISK-SOUNDS_SOURCE)" >>$@
	@echo "Description: $(ASTERISK-SOUNDS_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK-SOUNDS_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK-SOUNDS_IPK_DIR)/opt/sbin or $(ASTERISK-SOUNDS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK-SOUNDS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/asterisk-sounds/...
# Documentation files should be installed in $(ASTERISK-SOUNDS_IPK_DIR)/opt/doc/asterisk-sounds/...
# Daemon startup scripts should be installed in $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/init.d/S??asterisk-sounds
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK-SOUNDS_IPK): $(ASTERISK-SOUNDS_BUILD_DIR)/.built
	rm -rf $(ASTERISK-SOUNDS_IPK_DIR) $(BUILD_DIR)/asterisk-sounds_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK-SOUNDS_BUILD_DIR) DESTDIR=$(ASTERISK-SOUNDS_IPK_DIR) \
	INSTALL_PREFIX=/opt install
#	install -d $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/
#	install -m 644 $(ASTERISK-SOUNDS_SOURCE_DIR)/asterisk-sounds.conf $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/asterisk-sounds.conf
#	install -d $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ASTERISK-SOUNDS_SOURCE_DIR)/rc.asterisk-sounds $(ASTERISK-SOUNDS_IPK_DIR)/opt/etc/init.d/SXXasterisk-sounds
	$(MAKE) $(ASTERISK-SOUNDS_IPK_DIR)/CONTROL/control
#	install -m 755 $(ASTERISK-SOUNDS_SOURCE_DIR)/postinst $(ASTERISK-SOUNDS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ASTERISK-SOUNDS_SOURCE_DIR)/prerm $(ASTERISK-SOUNDS_IPK_DIR)/CONTROL/prerm
#	echo $(ASTERISK-SOUNDS_CONFFILES) | sed -e 's/ /\n/g' > $(ASTERISK-SOUNDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK-SOUNDS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk-sounds-ipk: $(ASTERISK-SOUNDS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk-sounds-clean:
	-$(MAKE) -C $(ASTERISK-SOUNDS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-sounds-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK-SOUNDS_DIR) $(ASTERISK-SOUNDS_BUILD_DIR) $(ASTERISK-SOUNDS_IPK_DIR) $(ASTERISK-SOUNDS_IPK)
