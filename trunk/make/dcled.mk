###########################################################
#
# dcled
#
###########################################################
#
# DCLED_VERSION, DCLED_SITE and DCLED_SOURCE define
# the upstream location of the source code for the package.
# DCLED_DIR is the directory which is created when the source
# archive is unpacked.
# DCLED_UNZIP is the command used to unzip the source.
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
DCLED_SITE=http://www.last-outpost.com/~malakai/dcled
DCLED_VERSION=1.2
DCLED_SOURCE=dcled-$(DCLED_VERSION).tgz
DCLED_DIR=dcled-$(DCLED_VERSION)
DCLED_UNZIP=zcat
DCLED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DCLED_DESCRIPTION=Userland driver for Dream Cheeky USB LED Message Board.
DCLED_SECTION=utils
DCLED_PRIORITY=optional
DCLED_DEPENDS=
DCLED_SUGGESTS=
DCLED_CONFLICTS=

#
# DCLED_IPK_VERSION should be incremented when the ipk changes.
#
DCLED_IPK_VERSION=1

#
# DCLED_CONFFILES should be a list of user-editable files
#DCLED_CONFFILES=/opt/etc/dcled.conf /opt/etc/init.d/SXXdcled

#
# DCLED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DCLED_PATCHES=$(DCLED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DCLED_CPPFLAGS=
DCLED_LDFLAGS=

#
# DCLED_BUILD_DIR is the directory in which the build is done.
# DCLED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DCLED_IPK_DIR is the directory in which the ipk is built.
# DCLED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DCLED_BUILD_DIR=$(BUILD_DIR)/dcled
DCLED_SOURCE_DIR=$(SOURCE_DIR)/dcled
DCLED_IPK_DIR=$(BUILD_DIR)/dcled-$(DCLED_VERSION)-ipk
DCLED_IPK=$(BUILD_DIR)/dcled_$(DCLED_VERSION)-$(DCLED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dcled-source dcled-unpack dcled dcled-stage dcled-ipk dcled-clean dcled-dirclean dcled-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DCLED_SOURCE):
	$(WGET) -P $(@D) $(DCLED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dcled-source: $(DL_DIR)/$(DCLED_SOURCE) $(DCLED_PATCHES)

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
$(DCLED_BUILD_DIR)/.configured: $(DL_DIR)/$(DCLED_SOURCE) $(DCLED_PATCHES) make/dcled.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DCLED_DIR) $(@D)
	mkdir $(@D)
	$(DCLED_UNZIP) $(DL_DIR)/$(DCLED_SOURCE) | tar -C $(@D) -xvf -
	if test -n "$(DCLED_PATCHES)" ; \
		then cat $(DCLED_PATCHES) | \
		patch -d $(@D) -p0 ; \
	fi
#	if test "$(BUILD_DIR)/$(DCLED_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DCLED_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DCLED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DCLED_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

dcled-unpack: $(DCLED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DCLED_BUILD_DIR)/.built: $(DCLED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(DCLED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DCLED_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
dcled: $(DCLED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DCLED_BUILD_DIR)/.staged: $(DCLED_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#dcled-stage: $(DCLED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dcled
#
$(DCLED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dcled" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DCLED_PRIORITY)" >>$@
	@echo "Section: $(DCLED_SECTION)" >>$@
	@echo "Version: $(DCLED_VERSION)-$(DCLED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DCLED_MAINTAINER)" >>$@
	@echo "Source: $(DCLED_SITE)/$(DCLED_SOURCE)" >>$@
	@echo "Description: $(DCLED_DESCRIPTION)" >>$@
	@echo "Depends: $(DCLED_DEPENDS)" >>$@
	@echo "Suggests: $(DCLED_SUGGESTS)" >>$@
	@echo "Conflicts: $(DCLED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DCLED_IPK_DIR)/opt/sbin or $(DCLED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DCLED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DCLED_IPK_DIR)/opt/etc/dcled/...
# Documentation files should be installed in $(DCLED_IPK_DIR)/opt/doc/dcled/...
# Daemon startup scripts should be installed in $(DCLED_IPK_DIR)/opt/etc/init.d/S??dcled
#
# You may need to patch your application to make it use these locations.
#
$(DCLED_IPK): $(DCLED_BUILD_DIR)/.built
	rm -rf $(DCLED_IPK_DIR) $(BUILD_DIR)/dcled_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DCLED_BUILD_DIR) DESTDIR=$(DCLED_IPK_DIR) install-strip
	install -d $(DCLED_IPK_DIR)/opt/bin
	install $(<D)/dcled $(DCLED_IPK_DIR)/opt/bin/dcled
	$(STRIP_COMMAND) $(DCLED_IPK_DIR)/opt/bin/dcled
	install -d $(DCLED_IPK_DIR)/opt/share/doc/dcled
	install $(<D)/README $(DCLED_IPK_DIR)/opt/share/doc/dcled/
	$(MAKE) $(DCLED_IPK_DIR)/CONTROL/control
	echo $(DCLED_CONFFILES) | sed -e 's/ /\n/g' > $(DCLED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DCLED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dcled-ipk: $(DCLED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dcled-clean:
	rm -f $(DCLED_BUILD_DIR)/.built
	-$(MAKE) -C $(DCLED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dcled-dirclean:
	rm -rf $(BUILD_DIR)/$(DCLED_DIR) $(DCLED_BUILD_DIR) $(DCLED_IPK_DIR) $(DCLED_IPK)
#
#
# Some sanity check for the package.
#
dcled-check: $(DCLED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
