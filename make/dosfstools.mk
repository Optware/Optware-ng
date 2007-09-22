###########################################################
#
# dosfstools
#
###########################################################
#
# DOSFSTOOLS_VERSION, DOSFSTOOLS_SITE and DOSFSTOOLS_SOURCE define
# the upstream location of the source code for the package.
# DOSFSTOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# DOSFSTOOLS_UNZIP is the command used to unzip the source.
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
DOSFSTOOLS_SITE=ftp://ftp.uni-erlangen.de/pub/Linux/LOCAL/dosfstools
DOSFSTOOLS_VERSION=2.11
DOSFSTOOLS_SOURCE=dosfstools-$(DOSFSTOOLS_VERSION).src.tar.gz
DOSFSTOOLS_DIR=dosfstools-$(DOSFSTOOLS_VERSION)
DOSFSTOOLS_UNZIP=zcat
DOSFSTOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DOSFSTOOLS_DESCRIPTION=Utilities to create and check MS-DOS FAT filesystems.
DOSFSTOOLS_SECTION=utils
DOSFSTOOLS_PRIORITY=optional
DOSFSTOOLS_DEPENDS=
DOSFSTOOLS_SUGGESTS=
DOSFSTOOLS_CONFLICTS=

#
# DOSFSTOOLS_IPK_VERSION should be incremented when the ipk changes.
#
DOSFSTOOLS_IPK_VERSION=1

#
# DOSFSTOOLS_CONFFILES should be a list of user-editable files
#DOSFSTOOLS_CONFFILES=/opt/etc/dosfstools.conf /opt/etc/init.d/SXXdosfstools

#
# DOSFSTOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DOSFSTOOLS_PATCHES=$(DOSFSTOOLS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DOSFSTOOLS_CPPFLAGS=
DOSFSTOOLS_LDFLAGS=

#
# DOSFSTOOLS_BUILD_DIR is the directory in which the build is done.
# DOSFSTOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DOSFSTOOLS_IPK_DIR is the directory in which the ipk is built.
# DOSFSTOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DOSFSTOOLS_BUILD_DIR=$(BUILD_DIR)/dosfstools
DOSFSTOOLS_SOURCE_DIR=$(SOURCE_DIR)/dosfstools
DOSFSTOOLS_IPK_DIR=$(BUILD_DIR)/dosfstools-$(DOSFSTOOLS_VERSION)-ipk
DOSFSTOOLS_IPK=$(BUILD_DIR)/dosfstools_$(DOSFSTOOLS_VERSION)-$(DOSFSTOOLS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dosfstools-source dosfstools-unpack dosfstools dosfstools-stage dosfstools-ipk dosfstools-clean dosfstools-dirclean dosfstools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DOSFSTOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(DOSFSTOOLS_SITE)/$(DOSFSTOOLS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DOSFSTOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dosfstools-source: $(DL_DIR)/$(DOSFSTOOLS_SOURCE) $(DOSFSTOOLS_PATCHES)

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
$(DOSFSTOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(DOSFSTOOLS_SOURCE) $(DOSFSTOOLS_PATCHES) make/dosfstools.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DOSFSTOOLS_DIR) $(DOSFSTOOLS_BUILD_DIR)
	$(DOSFSTOOLS_UNZIP) $(DL_DIR)/$(DOSFSTOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DOSFSTOOLS_PATCHES)" ; \
		then cat $(DOSFSTOOLS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DOSFSTOOLS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DOSFSTOOLS_DIR)" != "$(DOSFSTOOLS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DOSFSTOOLS_DIR) $(DOSFSTOOLS_BUILD_DIR) ; \
	fi
#	(cd $(DOSFSTOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOSFSTOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOSFSTOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(DOSFSTOOLS_BUILD_DIR)/libtool
	touch $@

dosfstools-unpack: $(DOSFSTOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DOSFSTOOLS_BUILD_DIR)/.built: $(DOSFSTOOLS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DOSFSTOOLS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOSFSTOOLS_CPPFLAGS)" \
		DEBUGFLAGS="$(STAGING_CPPFLAGS) $(DOSFSTOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOSFSTOOLS_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
dosfstools: $(DOSFSTOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DOSFSTOOLS_BUILD_DIR)/.staged: $(DOSFSTOOLS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DOSFSTOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

dosfstools-stage: $(DOSFSTOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dosfstools
#
$(DOSFSTOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dosfstools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOSFSTOOLS_PRIORITY)" >>$@
	@echo "Section: $(DOSFSTOOLS_SECTION)" >>$@
	@echo "Version: $(DOSFSTOOLS_VERSION)-$(DOSFSTOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOSFSTOOLS_MAINTAINER)" >>$@
	@echo "Source: $(DOSFSTOOLS_SITE)/$(DOSFSTOOLS_SOURCE)" >>$@
	@echo "Description: $(DOSFSTOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(DOSFSTOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(DOSFSTOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOSFSTOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DOSFSTOOLS_IPK_DIR)/opt/sbin or $(DOSFSTOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DOSFSTOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DOSFSTOOLS_IPK_DIR)/opt/etc/dosfstools/...
# Documentation files should be installed in $(DOSFSTOOLS_IPK_DIR)/opt/doc/dosfstools/...
# Daemon startup scripts should be installed in $(DOSFSTOOLS_IPK_DIR)/opt/etc/init.d/S??dosfstools
#
# You may need to patch your application to make it use these locations.
#
$(DOSFSTOOLS_IPK): $(DOSFSTOOLS_BUILD_DIR)/.built
	rm -rf $(DOSFSTOOLS_IPK_DIR) $(BUILD_DIR)/dosfstools_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DOSFSTOOLS_BUILD_DIR) install \
		DESTDIR=$(DOSFSTOOLS_IPK_DIR) \
		PREFIX=$(DOSFSTOOLS_IPK_DIR)/opt \
		MANDIR=$(DOSFSTOOLS_IPK_DIR)/opt/share/man/man8 \
		;
	$(STRIP_COMMAND) $(DOSFSTOOLS_IPK_DIR)/opt/sbin/dosfsck $(DOSFSTOOLS_IPK_DIR)/opt/sbin/mkdosfs
	$(MAKE) $(DOSFSTOOLS_IPK_DIR)/CONTROL/control
	echo $(DOSFSTOOLS_CONFFILES) | sed -e 's/ /\n/g' > $(DOSFSTOOLS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOSFSTOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dosfstools-ipk: $(DOSFSTOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dosfstools-clean:
	rm -f $(DOSFSTOOLS_BUILD_DIR)/.built
	-$(MAKE) -C $(DOSFSTOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dosfstools-dirclean:
	rm -rf $(BUILD_DIR)/$(DOSFSTOOLS_DIR) $(DOSFSTOOLS_BUILD_DIR) $(DOSFSTOOLS_IPK_DIR) $(DOSFSTOOLS_IPK)
#
#
# Some sanity check for the package.
#
dosfstools-check: $(DOSFSTOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DOSFSTOOLS_IPK)
