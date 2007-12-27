###########################################################
#
# vitetris
#
###########################################################
#
# VITETRIS_VERSION, VITETRIS_SITE and VITETRIS_SOURCE define
# the upstream location of the source code for the package.
# VITETRIS_DIR is the directory which is created when the source
# archive is unpacked.
# VITETRIS_UNZIP is the command used to unzip the source.
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
VITETRIS_SITE=http://robert.liquidham.se/vitetris
VITETRIS_VERSION=0.3.4
VITETRIS_SOURCE=vitetris-$(VITETRIS_VERSION).tar.gz
VITETRIS_DIR=vitetris-$(VITETRIS_VERSION)
VITETRIS_UNZIP=zcat
VITETRIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VITETRIS_DESCRIPTION=vitetris is a Tetris clone for the terminal that does not use ncurses.
VITETRIS_SECTION=games
VITETRIS_PRIORITY=optional
VITETRIS_DEPENDS=
VITETRIS_SUGGESTS=
VITETRIS_CONFLICTS=

#
# VITETRIS_IPK_VERSION should be incremented when the ipk changes.
#
VITETRIS_IPK_VERSION=1

#
# VITETRIS_CONFFILES should be a list of user-editable files
#VITETRIS_CONFFILES=/opt/etc/vitetris.conf /opt/etc/init.d/SXXvitetris

#
# VITETRIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#VITETRIS_PATCHES=$(VITETRIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VITETRIS_CPPFLAGS=
VITETRIS_LDFLAGS=

#
# VITETRIS_BUILD_DIR is the directory in which the build is done.
# VITETRIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VITETRIS_IPK_DIR is the directory in which the ipk is built.
# VITETRIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VITETRIS_BUILD_DIR=$(BUILD_DIR)/vitetris
VITETRIS_SOURCE_DIR=$(SOURCE_DIR)/vitetris
VITETRIS_IPK_DIR=$(BUILD_DIR)/vitetris-$(VITETRIS_VERSION)-ipk
VITETRIS_IPK=$(BUILD_DIR)/vitetris_$(VITETRIS_VERSION)-$(VITETRIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: vitetris-source vitetris-unpack vitetris vitetris-stage vitetris-ipk vitetris-clean vitetris-dirclean vitetris-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VITETRIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(VITETRIS_SITE)/$(VITETRIS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(VITETRIS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vitetris-source: $(DL_DIR)/$(VITETRIS_SOURCE) $(VITETRIS_PATCHES)

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
$(VITETRIS_BUILD_DIR)/.configured: $(DL_DIR)/$(VITETRIS_SOURCE) $(VITETRIS_PATCHES) make/vitetris.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(VITETRIS_DIR) $(@D)
	$(VITETRIS_UNZIP) $(DL_DIR)/$(VITETRIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(VITETRIS_PATCHES)" ; \
		then cat $(VITETRIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(VITETRIS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(VITETRIS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(VITETRIS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VITETRIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VITETRIS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

vitetris-unpack: $(VITETRIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VITETRIS_BUILD_DIR)/.built: $(VITETRIS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VITETRIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VITETRIS_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
vitetris: $(VITETRIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VITETRIS_BUILD_DIR)/.staged: $(VITETRIS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

vitetris-stage: $(VITETRIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vitetris
#
$(VITETRIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: vitetris" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VITETRIS_PRIORITY)" >>$@
	@echo "Section: $(VITETRIS_SECTION)" >>$@
	@echo "Version: $(VITETRIS_VERSION)-$(VITETRIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VITETRIS_MAINTAINER)" >>$@
	@echo "Source: $(VITETRIS_SITE)/$(VITETRIS_SOURCE)" >>$@
	@echo "Description: $(VITETRIS_DESCRIPTION)" >>$@
	@echo "Depends: $(VITETRIS_DEPENDS)" >>$@
	@echo "Suggests: $(VITETRIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(VITETRIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VITETRIS_IPK_DIR)/opt/sbin or $(VITETRIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VITETRIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VITETRIS_IPK_DIR)/opt/etc/vitetris/...
# Documentation files should be installed in $(VITETRIS_IPK_DIR)/opt/doc/vitetris/...
# Daemon startup scripts should be installed in $(VITETRIS_IPK_DIR)/opt/etc/init.d/S??vitetris
#
# You may need to patch your application to make it use these locations.
#
$(VITETRIS_IPK): $(VITETRIS_BUILD_DIR)/.built
	rm -rf $(VITETRIS_IPK_DIR) $(BUILD_DIR)/vitetris_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(VITETRIS_BUILD_DIR) DESTDIR=$(VITETRIS_IPK_DIR) install
	install -d $(VITETRIS_IPK_DIR)/opt/bin $(VITETRIS_IPK_DIR)/opt/share/doc/vitetris
	$(STRIP_COMMAND) $(VITETRIS_BUILD_DIR)/tetris -o $(VITETRIS_IPK_DIR)/opt/bin/vitetris
	install -m 644 \
		$(VITETRIS_BUILD_DIR)/CHANGELOG \
		$(VITETRIS_BUILD_DIR)/README \
		$(VITETRIS_BUILD_DIR)/lice*.txt \
		$(VITETRIS_IPK_DIR)/opt/share/doc/vitetris/
	$(MAKE) $(VITETRIS_IPK_DIR)/CONTROL/control
	echo $(VITETRIS_CONFFILES) | sed -e 's/ /\n/g' > $(VITETRIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VITETRIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vitetris-ipk: $(VITETRIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vitetris-clean:
	rm -f $(VITETRIS_BUILD_DIR)/.built
	-$(MAKE) -C $(VITETRIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vitetris-dirclean:
	rm -rf $(BUILD_DIR)/$(VITETRIS_DIR) $(VITETRIS_BUILD_DIR) $(VITETRIS_IPK_DIR) $(VITETRIS_IPK)
#
#
# Some sanity check for the package.
#
vitetris-check: $(VITETRIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VITETRIS_IPK)
