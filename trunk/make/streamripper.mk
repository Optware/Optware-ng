###########################################################
#
# streamripper
#
###########################################################

# You must replace "streamripper" and "STREAMRIPPER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# STREAMRIPPER_VERSION, STREAMRIPPER_SITE and STREAMRIPPER_SOURCE define
# the upstream location of the source code for the package.
# STREAMRIPPER_DIR is the directory which is created when the source
# archive is unpacked.
# STREAMRIPPER_UNZIP is the command used to unzip the source.
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
STREAMRIPPER_NAME=streamripper
STREAMRIPPER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/streamripper/
STREAMRIPPER_VERSION=1.63.5
STREAMRIPPER_SOURCE=$(STREAMRIPPER_NAME)-$(STREAMRIPPER_VERSION).tar.gz
STREAMRIPPER_DIR=$(STREAMRIPPER_NAME)-$(STREAMRIPPER_VERSION)
STREAMRIPPER_UNZIP=zcat
STREAMRIPPER_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
STREAMRIPPER_DESCRIPTION=Shoutcast ripper
STREAMRIPPER_SECTION=net
STREAMRIPPER_PRIORITY=optional
STREAMRIPPER_DEPENDS=libmad, libogg, libvorbis, tre
STREAMRIPPER_CONFLICTS=

#
# STREAMRIPPER_IPK_VERSION should be incremented when the ipk changes.
#
STREAMRIPPER_IPK_VERSION=1

#
# STREAMRIPPER_CONFFILES should be a list of user-editable files
STREAMRIPPER_CONFFILES=
#/opt/etc/streamripper.conf /opt/etc/init.d/SXXstreamripper

#
# STREAMRIPPER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
STREAMRIPPER_PATCHES=
#$(STREAMRIPPER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
STREAMRIPPER_CPPFLAGS=
STREAMRIPPER_LDFLAGS=

#
# STREAMRIPPER_BUILD_DIR is the directory in which the build is done.
# STREAMRIPPER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STREAMRIPPER_IPK_DIR is the directory in which the ipk is built.
# STREAMRIPPER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STREAMRIPPER_BUILD_DIR=$(BUILD_DIR)/streamripper
STREAMRIPPER_SOURCE_DIR=$(SOURCE_DIR)/streamripper
STREAMRIPPER_IPK_DIR=$(BUILD_DIR)/streamripper-$(STREAMRIPPER_VERSION)-ipk
STREAMRIPPER_IPK=$(BUILD_DIR)/streamripper_$(STREAMRIPPER_VERSION)-$(STREAMRIPPER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: streamripper-source streamripper-unpack streamripper streamripper-stage streamripper-ipk streamripper-clean streamripper-dirclean streamripper-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STREAMRIPPER_SOURCE):
	$(WGET) -P $(@D) $(STREAMRIPPER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
streamripper-source: $(DL_DIR)/$(STREAMRIPPER_SOURCE) $(STREAMRIPPER_PATCHES)

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
$(STREAMRIPPER_BUILD_DIR)/.configured: $(DL_DIR)/$(STREAMRIPPER_SOURCE) $(STREAMRIPPER_PATCHES) make/streamripper.mk
	$(MAKE) libmad-stage
	$(MAKE) libvorbis-stage libogg-stage
	$(MAKE) tre-stage
	rm -rf $(BUILD_DIR)/$(STREAMRIPPER_DIR) $(@D)
	$(STREAMRIPPER_UNZIP) $(DL_DIR)/$(STREAMRIPPER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(STREAMRIPPER_PATCHES) | patch -d $(BUILD_DIR)/$(STREAMRIPPER_DIR) -p1
	mv $(BUILD_DIR)/$(STREAMRIPPER_DIR) $(@D)
	sed -i -e '/^DEFAULT_INCLUDES *=/s|$$| $(STAGING_CPPFLAGS)|' $(@D)/lib/Makefile.in
	cp -f $(SOURCE_DIR)/common/config.* $(@D)/
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STREAMRIPPER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STREAMRIPPER_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-oggtest \
		--disable-vorbistest \
		--with-ogg=$(STAGING_PREFIX) \
		--with-vorbis=$(STAGING_PREFIX) \
	)
	touch $@

streamripper-unpack: $(STREAMRIPPER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(STREAMRIPPER_BUILD_DIR)/.built: $(STREAMRIPPER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
streamripper: $(STREAMRIPPER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STREAMRIPPER_BUILD_DIR)/.staged: $(STREAMRIPPER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

streamripper-stage: $(STREAMRIPPER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/streamripper
#
$(STREAMRIPPER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: $(STREAMRIPPER_NAME)" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STREAMRIPPER_PRIORITY)" >>$@
	@echo "Section: $(STREAMRIPPER_SECTION)" >>$@
	@echo "Version: $(STREAMRIPPER_VERSION)-$(STREAMRIPPER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STREAMRIPPER_MAINTAINER)" >>$@
	@echo "Source: $(STREAMRIPPER_SITE)/$(STREAMRIPPER_SOURCE)" >>$@
	@echo "Description: $(STREAMRIPPER_DESCRIPTION)" >>$@
	@echo "Depends: $(STREAMRIPPER_DEPENDS)" >>$@
	@echo "Conflicts: $(STREAMRIPPER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STREAMRIPPER_IPK_DIR)/opt/sbin or $(STREAMRIPPER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STREAMRIPPER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STREAMRIPPER_IPK_DIR)/opt/etc/streamripper/...
# Documentation files should be installed in $(STREAMRIPPER_IPK_DIR)/opt/doc/streamripper/...
# Daemon startup scripts should be installed in $(STREAMRIPPER_IPK_DIR)/opt/etc/init.d/S??streamripper
#
# You may need to patch your application to make it use these locations.
#
$(STREAMRIPPER_IPK): $(STREAMRIPPER_BUILD_DIR)/.built
	rm -rf $(STREAMRIPPER_IPK_DIR) $(BUILD_DIR)/streamripper_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(STREAMRIPPER_BUILD_DIR) DESTDIR=$(STREAMRIPPER_IPK_DIR) install
	$(STRIP_COMMAND) $(STREAMRIPPER_IPK_DIR)/opt/bin/streamripper
#	install -d $(STREAMRIPPER_IPK_DIR)/opt/etc/
#	install -m 644 $(STREAMRIPPER_SOURCE_DIR)/streamripper.conf $(STREAMRIPPER_IPK_DIR)/opt/etc/streamripper.conf
#	install -d $(STREAMRIPPER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(STREAMRIPPER_SOURCE_DIR)/rc.streamripper $(STREAMRIPPER_IPK_DIR)/opt/etc/init.d/SXXstreamripper
	$(MAKE) $(STREAMRIPPER_IPK_DIR)/CONTROL/control
#	install -m 755 $(STREAMRIPPER_SOURCE_DIR)/postinst $(STREAMRIPPER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(STREAMRIPPER_SOURCE_DIR)/prerm $(STREAMRIPPER_IPK_DIR)/CONTROL/prerm
	echo $(STREAMRIPPER_CONFFILES) | sed -e 's/ /\n/g' > $(STREAMRIPPER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STREAMRIPPER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
streamripper-ipk: $(STREAMRIPPER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
streamripper-clean:
	-$(MAKE) -C $(STREAMRIPPER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
streamripper-dirclean:
	rm -rf $(BUILD_DIR)/$(STREAMRIPPER_DIR) $(STREAMRIPPER_BUILD_DIR) $(STREAMRIPPER_IPK_DIR) $(STREAMRIPPER_IPK)

#
# Some sanity check for the package.
#
streamripper-check: $(STREAMRIPPER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(STREAMRIPPER_IPK)
