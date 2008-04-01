###########################################################
#
# mimms
#
###########################################################
#
# MIMMS_VERSION, MIMMS_SITE and MIMMS_SOURCE define
# the upstream location of the source code for the package.
# MIMMS_DIR is the directory which is created when the source
# archive is unpacked.
# MIMMS_UNZIP is the command used to unzip the source.
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
MIMMS_SITE=http://download.savannah.gnu.org/releases/mimms
MIMMS_VERSION=0.0.9
MIMMS_SOURCE=mimms-$(MIMMS_VERSION).tar.gz
MIMMS_DIR=mimms-$(MIMMS_VERSION)
MIMMS_UNZIP=zcat
MIMMS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MIMMS_DESCRIPTION=MiMMS is a program designed to allow you to download streams using the MMS protocol and save them to your computer, as opposed to watching them live.
MIMMS_SECTION=util
MIMMS_PRIORITY=optional
MIMMS_DEPENDS=e2fslibs,popt
MIMMS_SUGGESTS=
MIMMS_CONFLICTS=

#
# MIMMS_IPK_VERSION should be incremented when the ipk changes.
#
MIMMS_IPK_VERSION=2

#
# MIMMS_CONFFILES should be a list of user-editable files
#MIMMS_CONFFILES=/opt/etc/mimms.conf /opt/etc/init.d/SXXmimms

#
# MIMMS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MIMMS_PATCHES=$(MIMMS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MIMMS_CPPFLAGS=-O2 -Wall
MIMMS_LDFLAGS=-lpopt -luuid

#
# MIMMS_BUILD_DIR is the directory in which the build is done.
# MIMMS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MIMMS_IPK_DIR is the directory in which the ipk is built.
# MIMMS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MIMMS_BUILD_DIR=$(BUILD_DIR)/mimms
MIMMS_SOURCE_DIR=$(SOURCE_DIR)/mimms
MIMMS_IPK_DIR=$(BUILD_DIR)/mimms-$(MIMMS_VERSION)-ipk
MIMMS_IPK=$(BUILD_DIR)/mimms_$(MIMMS_VERSION)-$(MIMMS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mimms-source mimms-unpack mimms mimms-stage mimms-ipk mimms-clean mimms-dirclean mimms-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MIMMS_SOURCE):
	$(WGET) -P $(DL_DIR) $(MIMMS_SITE)/$(MIMMS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MIMMS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mimms-source: $(DL_DIR)/$(MIMMS_SOURCE) $(MIMMS_PATCHES)

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
$(MIMMS_BUILD_DIR)/.configured: $(DL_DIR)/$(MIMMS_SOURCE) $(MIMMS_PATCHES) make/mimms.mk
	$(MAKE) e2fsprogs-stage popt-stage
	rm -rf $(BUILD_DIR)/$(MIMMS_DIR) $(MIMMS_BUILD_DIR)
	$(MIMMS_UNZIP) $(DL_DIR)/$(MIMMS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MIMMS_PATCHES)" ; \
		then cat $(MIMMS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MIMMS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MIMMS_DIR)" != "$(MIMMS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MIMMS_DIR) $(MIMMS_BUILD_DIR) ; \
	fi
	sed -i -e 's|/usr/|/opt/|g' $(MIMMS_BUILD_DIR)/Makefile
#	(cd $(MIMMS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MIMMS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MIMMS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

mimms-unpack: $(MIMMS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#

$(MIMMS_BUILD_DIR)/.built: $(MIMMS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MIMMS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MIMMS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MIMMS_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
mimms: $(MIMMS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MIMMS_BUILD_DIR)/.staged: $(MIMMS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MIMMS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mimms-stage: $(MIMMS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mimms
#
$(MIMMS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mimms" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MIMMS_PRIORITY)" >>$@
	@echo "Section: $(MIMMS_SECTION)" >>$@
	@echo "Version: $(MIMMS_VERSION)-$(MIMMS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MIMMS_MAINTAINER)" >>$@
	@echo "Source: $(MIMMS_SITE)/$(MIMMS_SOURCE)" >>$@
	@echo "Description: $(MIMMS_DESCRIPTION)" >>$@
	@echo "Depends: $(MIMMS_DEPENDS)" >>$@
	@echo "Suggests: $(MIMMS_SUGGESTS)" >>$@
	@echo "Conflicts: $(MIMMS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MIMMS_IPK_DIR)/opt/sbin or $(MIMMS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MIMMS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MIMMS_IPK_DIR)/opt/etc/mimms/...
# Documentation files should be installed in $(MIMMS_IPK_DIR)/opt/doc/mimms/...
# Daemon startup scripts should be installed in $(MIMMS_IPK_DIR)/opt/etc/init.d/S??mimms
#
# You may need to patch your application to make it use these locations.
#
$(MIMMS_IPK): $(MIMMS_BUILD_DIR)/.built

	rm -rf $(MIMMS_IPK_DIR) $(BUILD_DIR)/mimms_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MIMMS_BUILD_DIR) install \
		DESTDIR=$(MIMMS_IPK_DIR) \
		prefix=$(MIMMS_IPK_DIR)/opt
	$(STRIP_COMMAND) $(MIMMS_IPK_DIR)/opt/bin/mimms
	$(MAKE) $(MIMMS_IPK_DIR)/CONTROL/control
	echo $(MIMMS_CONFFILES) | sed -e 's/ /\n/g' > $(MIMMS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MIMMS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mimms-ipk: $(MIMMS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mimms-clean:
	rm -f $(MIMMS_BUILD_DIR)/.built
	-$(MAKE) -C $(MIMMS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mimms-dirclean:
	rm -rf $(BUILD_DIR)/$(MIMMS_DIR) $(MIMMS_BUILD_DIR) $(MIMMS_IPK_DIR) $(MIMMS_IPK)
#
#
# Some sanity check for the package.
#
mimms-check: $(MIMMS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MIMMS_IPK)
