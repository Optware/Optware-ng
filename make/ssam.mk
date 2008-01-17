###########################################################
#
# ssam
#
###########################################################
#
# SSAM_VERSION, SSAM_SITE and SSAM_SOURCE define
# the upstream location of the source code for the package.
# SSAM_DIR is the directory which is created when the source
# archive is unpacked.
# SSAM_UNZIP is the command used to unzip the source.
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
SSAM_SITE=http://www.westley.demon.co.uk/src
SSAM_VERSION=1.9
SSAM_SOURCE=ssam-$(SSAM_VERSION).tar.gz
SSAM_DIR=ssam-$(SSAM_VERSION)
SSAM_UNZIP=zcat
SSAM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SSAM_DESCRIPTION=A stream editor that uses the UTF routines and understands the sam command set. It is analogous to sed.
SSAM_SECTION=editor
SSAM_PRIORITY=optional
SSAM_DEPENDS=
SSAM_SUGGESTS=
SSAM_CONFLICTS=

#
# SSAM_IPK_VERSION should be incremented when the ipk changes.
#
SSAM_IPK_VERSION=1

#
# SSAM_CONFFILES should be a list of user-editable files
#SSAM_CONFFILES=/opt/etc/ssam.conf /opt/etc/init.d/SXXssam

#
# SSAM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SSAM_PATCHES=$(SSAM_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SSAM_CPPFLAGS=
SSAM_LDFLAGS=

#
# SSAM_BUILD_DIR is the directory in which the build is done.
# SSAM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SSAM_IPK_DIR is the directory in which the ipk is built.
# SSAM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SSAM_BUILD_DIR=$(BUILD_DIR)/ssam
SSAM_SOURCE_DIR=$(SOURCE_DIR)/ssam
SSAM_IPK_DIR=$(BUILD_DIR)/ssam-$(SSAM_VERSION)-ipk
SSAM_IPK=$(BUILD_DIR)/ssam_$(SSAM_VERSION)-$(SSAM_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ssam-source ssam-unpack ssam ssam-stage ssam-ipk ssam-clean ssam-dirclean ssam-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SSAM_SOURCE):
	$(WGET) -P $(DL_DIR) $(SSAM_SITE)/$(SSAM_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(SSAM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ssam-source: $(DL_DIR)/$(SSAM_SOURCE) $(SSAM_PATCHES)

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
$(SSAM_BUILD_DIR)/.configured: $(DL_DIR)/$(SSAM_SOURCE) $(SSAM_PATCHES) make/ssam.mk
	$(MAKE) libutf-stage
	rm -rf $(BUILD_DIR)/$(SSAM_DIR) $(@D)
	$(SSAM_UNZIP) $(DL_DIR)/$(SSAM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SSAM_PATCHES)" ; \
		then cat $(SSAM_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SSAM_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SSAM_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SSAM_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SSAM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SSAM_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ssam-unpack: $(SSAM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SSAM_BUILD_DIR)/.built: $(SSAM_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LIBDIR=$(STAGING_LIB_DIR) INCDIR=$(STAGING_INCLUDE_DIR)
	touch $@

#
# This is the build convenience target.
#
ssam: $(SSAM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SSAM_BUILD_DIR)/.staged: $(SSAM_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@

ssam-stage: $(SSAM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ssam
#
$(SSAM_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ssam" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SSAM_PRIORITY)" >>$@
	@echo "Section: $(SSAM_SECTION)" >>$@
	@echo "Version: $(SSAM_VERSION)-$(SSAM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SSAM_MAINTAINER)" >>$@
	@echo "Source: $(SSAM_SITE)/$(SSAM_SOURCE)" >>$@
	@echo "Description: $(SSAM_DESCRIPTION)" >>$@
	@echo "Depends: $(SSAM_DEPENDS)" >>$@
	@echo "Suggests: $(SSAM_SUGGESTS)" >>$@
	@echo "Conflicts: $(SSAM_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SSAM_IPK_DIR)/opt/sbin or $(SSAM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SSAM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SSAM_IPK_DIR)/opt/etc/ssam/...
# Documentation files should be installed in $(SSAM_IPK_DIR)/opt/doc/ssam/...
# Daemon startup scripts should be installed in $(SSAM_IPK_DIR)/opt/etc/init.d/S??ssam
#
# You may need to patch your application to make it use these locations.
#
$(SSAM_IPK): $(SSAM_BUILD_DIR)/.built
	rm -rf $(SSAM_IPK_DIR) $(BUILD_DIR)/ssam_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SSAM_BUILD_DIR) DESTDIR=$(SSAM_IPK_DIR) prefix=$(SSAM_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(SSAM_IPK_DIR)/opt/bin/ssam
	$(MAKE) $(SSAM_IPK_DIR)/CONTROL/control
	echo $(SSAM_CONFFILES) | sed -e 's/ /\n/g' > $(SSAM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SSAM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ssam-ipk: $(SSAM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ssam-clean:
	rm -f $(SSAM_BUILD_DIR)/.built
	-$(MAKE) -C $(SSAM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ssam-dirclean:
	rm -rf $(BUILD_DIR)/$(SSAM_DIR) $(SSAM_BUILD_DIR) $(SSAM_IPK_DIR) $(SSAM_IPK)
#
#
# Some sanity check for the package.
#
ssam-check: $(SSAM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SSAM_IPK)
