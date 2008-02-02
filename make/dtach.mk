###########################################################
#
# dtach
#
###########################################################
#
# DTACH_VERSION, DTACH_SITE and DTACH_SOURCE define
# the upstream location of the source code for the package.
# DTACH_DIR is the directory which is created when the source
# archive is unpacked.
# DTACH_UNZIP is the command used to unzip the source.
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
DTACH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dtach
DTACH_VERSION=0.8
DTACH_SOURCE=dtach-$(DTACH_VERSION).tar.gz
DTACH_DIR=dtach-$(DTACH_VERSION)
DTACH_UNZIP=zcat
DTACH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DTACH_DESCRIPTION=A program that emulates the detach feature of screen.
DTACH_SECTION=term
DTACH_PRIORITY=optional
DTACH_DEPENDS=
DTACH_SUGGESTS=
DTACH_CONFLICTS=

#
# DTACH_IPK_VERSION should be incremented when the ipk changes.
#
DTACH_IPK_VERSION=1

#
# DTACH_CONFFILES should be a list of user-editable files
#DTACH_CONFFILES=/opt/etc/dtach.conf /opt/etc/init.d/SXXdtach

#
# DTACH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DTACH_PATCHES=$(DTACH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DTACH_CPPFLAGS=
DTACH_LDFLAGS=

#
# DTACH_BUILD_DIR is the directory in which the build is done.
# DTACH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DTACH_IPK_DIR is the directory in which the ipk is built.
# DTACH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DTACH_BUILD_DIR=$(BUILD_DIR)/dtach
DTACH_SOURCE_DIR=$(SOURCE_DIR)/dtach
DTACH_IPK_DIR=$(BUILD_DIR)/dtach-$(DTACH_VERSION)-ipk
DTACH_IPK=$(BUILD_DIR)/dtach_$(DTACH_VERSION)-$(DTACH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dtach-source dtach-unpack dtach dtach-stage dtach-ipk dtach-clean dtach-dirclean dtach-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DTACH_SOURCE):
	$(WGET) -P $(DL_DIR) $(DTACH_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dtach-source: $(DL_DIR)/$(DTACH_SOURCE) $(DTACH_PATCHES)

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
$(DTACH_BUILD_DIR)/.configured: $(DL_DIR)/$(DTACH_SOURCE) $(DTACH_PATCHES) make/dtach.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DTACH_DIR) $(DTACH_BUILD_DIR)
	$(DTACH_UNZIP) $(DL_DIR)/$(DTACH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DTACH_PATCHES)" ; \
		then cat $(DTACH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DTACH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DTACH_DIR)" != "$(DTACH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DTACH_DIR) $(DTACH_BUILD_DIR) ; \
	fi
	(cd $(DTACH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DTACH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DTACH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(DTACH_BUILD_DIR)/libtool
	touch $@

dtach-unpack: $(DTACH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DTACH_BUILD_DIR)/.built: $(DTACH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DTACH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
dtach: $(DTACH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DTACH_BUILD_DIR)/.staged: $(DTACH_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(DTACH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

dtach-stage: $(DTACH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dtach
#
$(DTACH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dtach" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DTACH_PRIORITY)" >>$@
	@echo "Section: $(DTACH_SECTION)" >>$@
	@echo "Version: $(DTACH_VERSION)-$(DTACH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DTACH_MAINTAINER)" >>$@
	@echo "Source: $(DTACH_SITE)/$(DTACH_SOURCE)" >>$@
	@echo "Description: $(DTACH_DESCRIPTION)" >>$@
	@echo "Depends: $(DTACH_DEPENDS)" >>$@
	@echo "Suggests: $(DTACH_SUGGESTS)" >>$@
	@echo "Conflicts: $(DTACH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DTACH_IPK_DIR)/opt/sbin or $(DTACH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DTACH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DTACH_IPK_DIR)/opt/etc/dtach/...
# Documentation files should be installed in $(DTACH_IPK_DIR)/opt/doc/dtach/...
# Daemon startup scripts should be installed in $(DTACH_IPK_DIR)/opt/etc/init.d/S??dtach
#
# You may need to patch your application to make it use these locations.
#
$(DTACH_IPK): $(DTACH_BUILD_DIR)/.built
	rm -rf $(DTACH_IPK_DIR) $(BUILD_DIR)/dtach_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(DTACH_BUILD_DIR) DESTDIR=$(DTACH_IPK_DIR) install-strip
	install -d $(DTACH_IPK_DIR)/opt/bin
	install $(DTACH_BUILD_DIR)/dtach $(DTACH_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(DTACH_IPK_DIR)/opt/bin/dtach
	install -d $(DTACH_IPK_DIR)/opt/share/man/man1
	install $(DTACH_BUILD_DIR)/dtach.1 $(DTACH_IPK_DIR)/opt/share/man/man1/
	$(MAKE) $(DTACH_IPK_DIR)/CONTROL/control
#	echo $(DTACH_CONFFILES) | sed -e 's/ /\n/g' > $(DTACH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DTACH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dtach-ipk: $(DTACH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dtach-clean:
	rm -f $(DTACH_BUILD_DIR)/.built
	-$(MAKE) -C $(DTACH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dtach-dirclean:
	rm -rf $(BUILD_DIR)/$(DTACH_DIR) $(DTACH_BUILD_DIR) $(DTACH_IPK_DIR) $(DTACH_IPK)
#
#
# Some sanity check for the package.
#
dtach-check: $(DTACH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DTACH_IPK)
