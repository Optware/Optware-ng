###########################################################
#
# dmsetup
#
###########################################################
#
# DMSETUP_VERSION, DMSETUP_SITE and DMSETUP_SOURCE define
# the upstream location of the source code for the package.
# DMSETUP_DIR is the directory which is created when the source
# archive is unpacked.
# DMSETUP_UNZIP is the command used to unzip the source.
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
DMSETUP_SITE=ftp://sources.redhat.com/pub/dm
DMSETUP_VERSION=1.02.22
DMSETUP_SOURCE=device-mapper.$(DMSETUP_VERSION).tgz
DMSETUP_DIR=device-mapper.$(DMSETUP_VERSION)
DMSETUP_UNZIP=zcat
DMSETUP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DMSETUP_DESCRIPTION=Userspace library and tool for the Linux Kernel Device Mapper.
DMSETUP_SECTION=misc
DMSETUP_PRIORITY=optional
DMSETUP_DEPENDS=
DMSETUP_SUGGESTS=
DMSETUP_CONFLICTS=

#
# DMSETUP_IPK_VERSION should be incremented when the ipk changes.
#
DMSETUP_IPK_VERSION=1

#
# DMSETUP_CONFFILES should be a list of user-editable files
#DMSETUP_CONFFILES=/opt/etc/dmsetup.conf /opt/etc/init.d/SXXdmsetup

#
# DMSETUP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DMSETUP_PATCHES=$(DMSETUP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DMSETUP_CPPFLAGS=
DMSETUP_LDFLAGS=

#
# DMSETUP_BUILD_DIR is the directory in which the build is done.
# DMSETUP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DMSETUP_IPK_DIR is the directory in which the ipk is built.
# DMSETUP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DMSETUP_BUILD_DIR=$(BUILD_DIR)/dmsetup
DMSETUP_SOURCE_DIR=$(SOURCE_DIR)/dmsetup
DMSETUP_IPK_DIR=$(BUILD_DIR)/dmsetup-$(DMSETUP_VERSION)-ipk
DMSETUP_IPK=$(BUILD_DIR)/dmsetup_$(DMSETUP_VERSION)-$(DMSETUP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dmsetup-source dmsetup-unpack dmsetup dmsetup-stage dmsetup-ipk dmsetup-clean dmsetup-dirclean dmsetup-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DMSETUP_SOURCE):
	$(WGET) -P $(DL_DIR) $(DMSETUP_SITE)/$(DMSETUP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(DMSETUP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dmsetup-source: $(DL_DIR)/$(DMSETUP_SOURCE) $(DMSETUP_PATCHES)

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
$(DMSETUP_BUILD_DIR)/.configured: $(DL_DIR)/$(DMSETUP_SOURCE) $(DMSETUP_PATCHES) make/dmsetup.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DMSETUP_DIR) $(DMSETUP_BUILD_DIR)
	$(DMSETUP_UNZIP) $(DL_DIR)/$(DMSETUP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DMSETUP_PATCHES)" ; \
		then cat $(DMSETUP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DMSETUP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DMSETUP_DIR)" != "$(DMSETUP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DMSETUP_DIR) $(DMSETUP_BUILD_DIR) ; \
	fi
	(cd $(DMSETUP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DMSETUP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DMSETUP_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(DMSETUP_BUILD_DIR)/libtool
	touch $@

dmsetup-unpack: $(DMSETUP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DMSETUP_BUILD_DIR)/.built: $(DMSETUP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(DMSETUP_BUILD_DIR) DESTDIR=$(STAGING_PREFIX)
	touch $@

#
# This is the build convenience target.
#
dmsetup: $(DMSETUP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DMSETUP_BUILD_DIR)/.staged: $(DMSETUP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(DMSETUP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

dmsetup-stage: $(DMSETUP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dmsetup
#
$(DMSETUP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dmsetup" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DMSETUP_PRIORITY)" >>$@
	@echo "Section: $(DMSETUP_SECTION)" >>$@
	@echo "Version: $(DMSETUP_VERSION)-$(DMSETUP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DMSETUP_MAINTAINER)" >>$@
	@echo "Source: $(DMSETUP_SITE)/$(DMSETUP_SOURCE)" >>$@
	@echo "Description: $(DMSETUP_DESCRIPTION)" >>$@
	@echo "Depends: $(DMSETUP_DEPENDS)" >>$@
	@echo "Suggests: $(DMSETUP_SUGGESTS)" >>$@
	@echo "Conflicts: $(DMSETUP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DMSETUP_IPK_DIR)/opt/sbin or $(DMSETUP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DMSETUP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DMSETUP_IPK_DIR)/opt/etc/dmsetup/...
# Documentation files should be installed in $(DMSETUP_IPK_DIR)/opt/doc/dmsetup/...
# Daemon startup scripts should be installed in $(DMSETUP_IPK_DIR)/opt/etc/init.d/S??dmsetup
#
# You may need to patch your application to make it use these locations.
#
$(DMSETUP_IPK): $(DMSETUP_BUILD_DIR)/.built
	rm -rf $(DMSETUP_IPK_DIR) $(BUILD_DIR)/dmsetup_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DMSETUP_BUILD_DIR) install \
		DESTDIR=$(DMSETUP_IPK_DIR) \
		OWNER="" GROUP=""
	for f in \
		$(DMSETUP_IPK_DIR)/opt/sbin/dmsetup \
		$(DMSETUP_IPK_DIR)/opt/lib/libdevmapper.so.[0-9]*.[0-9]* ; \
	do chmod +w $$f; $(STRIP_COMMAND) $$f; chmod -w $$f; done
	$(MAKE) $(DMSETUP_IPK_DIR)/CONTROL/control
	echo $(DMSETUP_CONFFILES) | sed -e 's/ /\n/g' > $(DMSETUP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DMSETUP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dmsetup-ipk: $(DMSETUP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dmsetup-clean:
	rm -f $(DMSETUP_BUILD_DIR)/.built
	-$(MAKE) -C $(DMSETUP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dmsetup-dirclean:
	rm -rf $(BUILD_DIR)/$(DMSETUP_DIR) $(DMSETUP_BUILD_DIR) $(DMSETUP_IPK_DIR) $(DMSETUP_IPK)
#
#
# Some sanity check for the package.
#
dmsetup-check: $(DMSETUP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DMSETUP_IPK)
