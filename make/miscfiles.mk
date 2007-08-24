###########################################################
#
# miscfiles
#
###########################################################
#
# MISCFILES_VERSION, MISCFILES_SITE and MISCFILES_SOURCE define
# the upstream location of the source code for the package.
# MISCFILES_DIR is the directory which is created when the source
# archive is unpacked.
# MISCFILES_UNZIP is the command used to unzip the source.
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
MISCFILES_SITE=http://ftp.gnu.org/gnu/miscfiles
MISCFILES_VERSION=1.4.2
MISCFILES_SOURCE=miscfiles-$(MISCFILES_VERSION).tar.gz
MISCFILES_DIR=miscfiles-$(MISCFILES_VERSION)
MISCFILES_UNZIP=zcat
MISCFILES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MISCFILES_DESCRIPTION=Describe miscfiles here.
MISCFILES_SECTION=misc
MISCFILES_PRIORITY=optional
MISCFILES_DEPENDS=
MISCFILES_SUGGESTS=
MISCFILES_CONFLICTS=

#
# MISCFILES_IPK_VERSION should be incremented when the ipk changes.
#
MISCFILES_IPK_VERSION=1

#
# MISCFILES_CONFFILES should be a list of user-editable files
#MISCFILES_CONFFILES=/opt/etc/miscfiles.conf /opt/etc/init.d/SXXmiscfiles

#
# MISCFILES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MISCFILES_PATCHES=$(MISCFILES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MISCFILES_CPPFLAGS=
MISCFILES_LDFLAGS=

#
# MISCFILES_BUILD_DIR is the directory in which the build is done.
# MISCFILES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MISCFILES_IPK_DIR is the directory in which the ipk is built.
# MISCFILES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MISCFILES_BUILD_DIR=$(BUILD_DIR)/miscfiles
MISCFILES_SOURCE_DIR=$(SOURCE_DIR)/miscfiles
MISCFILES_IPK_DIR=$(BUILD_DIR)/miscfiles-$(MISCFILES_VERSION)-ipk
MISCFILES_IPK=$(BUILD_DIR)/miscfiles_$(MISCFILES_VERSION)-$(MISCFILES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: miscfiles-source miscfiles-unpack miscfiles miscfiles-stage miscfiles-ipk miscfiles-clean miscfiles-dirclean miscfiles-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MISCFILES_SOURCE):
	$(WGET) -P $(DL_DIR) $(MISCFILES_SITE)/$(MISCFILES_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MISCFILES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
miscfiles-source: $(DL_DIR)/$(MISCFILES_SOURCE) $(MISCFILES_PATCHES)

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
$(MISCFILES_BUILD_DIR)/.configured: $(DL_DIR)/$(MISCFILES_SOURCE) $(MISCFILES_PATCHES) make/miscfiles.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MISCFILES_DIR) $(MISCFILES_BUILD_DIR)
	$(MISCFILES_UNZIP) $(DL_DIR)/$(MISCFILES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MISCFILES_PATCHES)" ; \
		then cat $(MISCFILES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MISCFILES_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MISCFILES_DIR)" != "$(MISCFILES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MISCFILES_DIR) $(MISCFILES_BUILD_DIR) ; \
	fi
	(cd $(MISCFILES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MISCFILES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MISCFILES_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MISCFILES_BUILD_DIR)/libtool
	touch $@

miscfiles-unpack: $(MISCFILES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MISCFILES_BUILD_DIR)/.built: $(MISCFILES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MISCFILES_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
miscfiles: $(MISCFILES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MISCFILES_BUILD_DIR)/.staged: $(MISCFILES_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(MISCFILES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

miscfiles-stage: $(MISCFILES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/miscfiles
#
$(MISCFILES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: miscfiles" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MISCFILES_PRIORITY)" >>$@
	@echo "Section: $(MISCFILES_SECTION)" >>$@
	@echo "Version: $(MISCFILES_VERSION)-$(MISCFILES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MISCFILES_MAINTAINER)" >>$@
	@echo "Source: $(MISCFILES_SITE)/$(MISCFILES_SOURCE)" >>$@
	@echo "Description: $(MISCFILES_DESCRIPTION)" >>$@
	@echo "Depends: $(MISCFILES_DEPENDS)" >>$@
	@echo "Suggests: $(MISCFILES_SUGGESTS)" >>$@
	@echo "Conflicts: $(MISCFILES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MISCFILES_IPK_DIR)/opt/sbin or $(MISCFILES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MISCFILES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MISCFILES_IPK_DIR)/opt/etc/miscfiles/...
# Documentation files should be installed in $(MISCFILES_IPK_DIR)/opt/doc/miscfiles/...
# Daemon startup scripts should be installed in $(MISCFILES_IPK_DIR)/opt/etc/init.d/S??miscfiles
#
# You may need to patch your application to make it use these locations.
#
$(MISCFILES_IPK): $(MISCFILES_BUILD_DIR)/.built
	rm -rf $(MISCFILES_IPK_DIR) $(BUILD_DIR)/miscfiles_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MISCFILES_BUILD_DIR) prefix=$(MISCFILES_IPK_DIR)/opt install-strip
	$(MAKE) $(MISCFILES_IPK_DIR)/CONTROL/control
	echo $(MISCFILES_CONFFILES) | sed -e 's/ /\n/g' > $(MISCFILES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MISCFILES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
miscfiles-ipk: $(MISCFILES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
miscfiles-clean:
	rm -f $(MISCFILES_BUILD_DIR)/.built
	-$(MAKE) -C $(MISCFILES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
miscfiles-dirclean:
	rm -rf $(BUILD_DIR)/$(MISCFILES_DIR) $(MISCFILES_BUILD_DIR) $(MISCFILES_IPK_DIR) $(MISCFILES_IPK)
#
#
# Some sanity check for the package.
#
miscfiles-check: $(MISCFILES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MISCFILES_IPK)
