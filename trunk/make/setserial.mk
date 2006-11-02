###########################################################
#
# setserial
#
###########################################################

# CAVEAT: setserial is currently compiled statically
# Otherwise calling /opt/sbin/setserial raises:
# -sh: /opt/sbin/setserial: not found
# Sounds like I did not manage to properly pass down the LDFLAGS options

#
# SETSERIAL_VERSION, SETSERIAL_SITE and SETSERIAL_SOURCE define
# the upstream location of the source code for the package.
# SETSERIAL_DIR is the directory which is created when the source
# archive is unpacked.
# SETSERIAL_UNZIP is the command used to unzip the source.
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
SETSERIAL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/setserial
SETSERIAL_VERSION=2.17
SETSERIAL_SOURCE=setserial-$(SETSERIAL_VERSION).tar.gz
SETSERIAL_DIR=setserial-$(SETSERIAL_VERSION)
SETSERIAL_UNZIP=zcat
SETSERIAL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SETSERIAL_DESCRIPTION=configuration utility for serial ports
SETSERIAL_SECTION=console
SETSERIAL_PRIORITY=optional
SETSERIAL_DEPENDS=
SETSERIAL_SUGGESTS=
SETSERIAL_CONFLICTS=

#
# SETSERIAL_IPK_VERSION should be incremented when the ipk changes.
#
SETSERIAL_IPK_VERSION=1

#
# SETSERIAL_CONFFILES should be a list of user-editable files
SETSERIAL_CONFFILES=

#
# SETSERIAL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SETSERIAL_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SETSERIAL_CPPFLAGS=
SETSERIAL_LDFLAGS=

#
# SETSERIAL_BUILD_DIR is the directory in which the build is done.
# SETSERIAL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SETSERIAL_IPK_DIR is the directory in which the ipk is built.
# SETSERIAL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SETSERIAL_BUILD_DIR=$(BUILD_DIR)/setserial
SETSERIAL_SOURCE_DIR=$(SOURCE_DIR)/setserial
SETSERIAL_IPK_DIR=$(BUILD_DIR)/setserial-$(SETSERIAL_VERSION)-ipk
SETSERIAL_IPK=$(BUILD_DIR)/setserial_$(SETSERIAL_VERSION)-$(SETSERIAL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: setserial-source setserial-unpack setserial setserial-stage setserial-ipk setserial-clean setserial-dirclean

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SETSERIAL_SOURCE):
	$(WGET) -P $(DL_DIR) $(SETSERIAL_SITE)/$(SETSERIAL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
setserial-source: $(DL_DIR)/$(SETSERIAL_SOURCE) $(SETSERIAL_PATCHES)

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
$(SETSERIAL_BUILD_DIR)/.configured: $(DL_DIR)/$(SETSERIAL_SOURCE) $(SETSERIAL_PATCHES) make/setserial.mk
	rm -rf $(BUILD_DIR)/$(SETSERIAL_DIR) $(SETSERIAL_BUILD_DIR)
	$(SETSERIAL_UNZIP) $(DL_DIR)/$(SETSERIAL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SETSERIAL_PATCHES)" ; \
		then cat $(SETSERIAL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SETSERIAL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SETSERIAL_DIR)" != "$(SETSERIAL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(SETSERIAL_DIR) $(SETSERIAL_BUILD_DIR) ; \
	fi
#	Note: the makefile does not use LDFLAGS, so hack around using CFLAGS
	(cd $(SETSERIAL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_LDFLAGS)  $(SETSERIAL_LDFLAGS) -g -O2" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(SETSERIAL_BUILD_DIR)/libtool
	touch $(SETSERIAL_BUILD_DIR)/.configured

setserial-unpack: $(SETSERIAL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SETSERIAL_BUILD_DIR)/.built: $(SETSERIAL_BUILD_DIR)/.configured
	rm -f $(SETSERIAL_BUILD_DIR)/.built
	$(MAKE) -C $(SETSERIAL_BUILD_DIR)
	touch $(SETSERIAL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
setserial: $(SETSERIAL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SETSERIAL_BUILD_DIR)/.staged: $(SETSERIAL_BUILD_DIR)/.built
	rm -f $(SETSERIAL_BUILD_DIR)/.staged
	$(MAKE) -C $(SETSERIAL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(SETSERIAL_BUILD_DIR)/.staged

setserial-stage: $(SETSERIAL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/setserial
#
$(SETSERIAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: setserial" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SETSERIAL_PRIORITY)" >>$@
	@echo "Section: $(SETSERIAL_SECTION)" >>$@
	@echo "Version: $(SETSERIAL_VERSION)-$(SETSERIAL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SETSERIAL_MAINTAINER)" >>$@
	@echo "Source: $(SETSERIAL_SITE)/$(SETSERIAL_SOURCE)" >>$@
	@echo "Description: $(SETSERIAL_DESCRIPTION)" >>$@
	@echo "Depends: $(SETSERIAL_DEPENDS)" >>$@
	@echo "Suggests: $(SETSERIAL_SUGGESTS)" >>$@
	@echo "Conflicts: $(SETSERIAL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SETSERIAL_IPK_DIR)/opt/sbin or $(SETSERIAL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SETSERIAL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SETSERIAL_IPK_DIR)/opt/etc/setserial/...
# Documentation files should be installed in $(SETSERIAL_IPK_DIR)/opt/doc/setserial/...
# Daemon startup scripts should be installed in $(SETSERIAL_IPK_DIR)/opt/etc/init.d/S??setserial
#
# You may need to patch your application to make it use these locations.
#
$(SETSERIAL_IPK): $(SETSERIAL_BUILD_DIR)/.built
	rm -rf $(SETSERIAL_IPK_DIR) $(BUILD_DIR)/setserial_*_$(TARGET_ARCH).ipk
# setserial's install rule can't easily be made to follow the rules above
	install -d $(SETSERIAL_IPK_DIR)/opt/sbin
	install -d $(SETSERIAL_IPK_DIR)/opt/man/man8
	install -m 755 $(SETSERIAL_BUILD_DIR)/setserial $(SETSERIAL_IPK_DIR)/opt/sbin
	$(TARGET_STRIP) $(SETSERIAL_IPK_DIR)/opt/sbin/setserial
	install $(SETSERIAL_BUILD_DIR)/setserial.8 $(SETSERIAL_IPK_DIR)/opt/man/man8

#	$(MAKE) -C $(SETSERIAL_BUILD_DIR) DESTDIR=$(SETSERIAL_IPK_DIR)/opt install
#	install -d $(SETSERIAL_IPK_DIR)/opt/etc/
#	install -m 644 $(SETSERIAL_SOURCE_DIR)/setserial.conf $(SETSERIAL_IPK_DIR)/opt/etc/setserial.conf
#	install -d $(SETSERIAL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SETSERIAL_SOURCE_DIR)/rc.setserial $(SETSERIAL_IPK_DIR)/opt/etc/init.d/SXXsetserial
	$(MAKE) $(SETSERIAL_IPK_DIR)/CONTROL/control
#	install -m 755 $(SETSERIAL_SOURCE_DIR)/postinst $(SETSERIAL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SETSERIAL_SOURCE_DIR)/prerm $(SETSERIAL_IPK_DIR)/CONTROL/prerm
	echo $(SETSERIAL_CONFFILES) | sed -e 's/ /\n/g' > $(SETSERIAL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SETSERIAL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
setserial-ipk: $(SETSERIAL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
setserial-clean:
	rm -f $(SETSERIAL_BUILD_DIR)/.built
	-$(MAKE) -C $(SETSERIAL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
setserial-dirclean:
	rm -rf $(BUILD_DIR)/$(SETSERIAL_DIR) $(SETSERIAL_BUILD_DIR) $(SETSERIAL_IPK_DIR) $(SETSERIAL_IPK)
