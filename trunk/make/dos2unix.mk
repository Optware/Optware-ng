###########################################################
#
# dos2unix
#
###########################################################
#
# DOS2UNIX_VERSION, DOS2UNIX_SITE and DOS2UNIX_SOURCE define
# the upstream location of the source code for the package.
# DOS2UNIX_DIR is the directory which is created when the source
# archive is unpacked.
# DOS2UNIX_UNZIP is the command used to unzip the source.
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
DOS2UNIX_SITE=http://waterlan.home.xs4all.nl/dos2unix
DOS2UNIX_VERSION=5.3.2
DOS2UNIX_SOURCE=dos2unix-$(DOS2UNIX_VERSION).tar.gz
DOS2UNIX_DIR=dos2unix-$(DOS2UNIX_VERSION)
DOS2UNIX_UNZIP=zcat
DOS2UNIX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DOS2UNIX_DESCRIPTION=Convert text files with DOS or Mac line breaks to Unix line breaks and vice versa.
DOS2UNIX_SECTION=utils
DOS2UNIX_PRIORITY=optional
DOS2UNIX_DEPENDS=
DOS2UNIX_SUGGESTS=
DOS2UNIX_CONFLICTS=

#
# DOS2UNIX_IPK_VERSION should be incremented when the ipk changes.
#
DOS2UNIX_IPK_VERSION=1

#
# DOS2UNIX_CONFFILES should be a list of user-editable files
#DOS2UNIX_CONFFILES=/opt/etc/dos2unix.conf /opt/etc/init.d/SXXdos2unix

#
# DOS2UNIX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# DOS2UNIX_PATCHES=$(DOS2UNIX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DOS2UNIX_CPPFLAGS=
DOS2UNIX_LDFLAGS=

#
# DOS2UNIX_BUILD_DIR is the directory in which the build is done.
# DOS2UNIX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DOS2UNIX_IPK_DIR is the directory in which the ipk is built.
# DOS2UNIX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DOS2UNIX_BUILD_DIR=$(BUILD_DIR)/dos2unix
DOS2UNIX_SOURCE_DIR=$(SOURCE_DIR)/dos2unix
DOS2UNIX_IPK_DIR=$(BUILD_DIR)/dos2unix-$(DOS2UNIX_VERSION)-ipk
DOS2UNIX_IPK=$(BUILD_DIR)/dos2unix_$(DOS2UNIX_VERSION)-$(DOS2UNIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dos2unix-source dos2unix-unpack dos2unix dos2unix-stage dos2unix-ipk dos2unix-clean dos2unix-dirclean dos2unix-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DOS2UNIX_SOURCE):
	$(WGET) -P $(@D) $(DOS2UNIX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dos2unix-source: $(DL_DIR)/$(DOS2UNIX_SOURCE) $(DOS2UNIX_PATCHES)

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
$(DOS2UNIX_BUILD_DIR)/.configured: $(DL_DIR)/$(DOS2UNIX_SOURCE) $(DOS2UNIX_PATCHES) make/dos2unix.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(DOS2UNIX_DIR) $(@D)
	$(DOS2UNIX_UNZIP) $(DL_DIR)/$(DOS2UNIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(DOS2UNIX_PATCHES)" ; \
		then cat $(DOS2UNIX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(DOS2UNIX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DOS2UNIX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(DOS2UNIX_DIR) $(@D) ; \
	fi
	sed -i -e '/^ENABLE_NLS/s/^/#/' \
	       -e '/ifdef ENABLE_NLS/s/$$/_/' $(@D)/Makefile
ifeq ($(LIBC_STYLE), uclibc)
	sed -i -e '/define USE_CANONICALIZE/s/1/0/' $(@D)/common.c
endif
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOS2UNIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOS2UNIX_LDFLAGS)" \
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

dos2unix-unpack: $(DOS2UNIX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DOS2UNIX_BUILD_DIR)/.built: $(DOS2UNIX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(DOS2UNIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(DOS2UNIX_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
dos2unix: $(DOS2UNIX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(DOS2UNIX_BUILD_DIR)/.staged: $(DOS2UNIX_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#dos2unix-stage: $(DOS2UNIX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dos2unix
#
$(DOS2UNIX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: dos2unix" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DOS2UNIX_PRIORITY)" >>$@
	@echo "Section: $(DOS2UNIX_SECTION)" >>$@
	@echo "Version: $(DOS2UNIX_VERSION)-$(DOS2UNIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DOS2UNIX_MAINTAINER)" >>$@
	@echo "Source: $(DOS2UNIX_SITE)/$(DOS2UNIX_SOURCE)" >>$@
	@echo "Description: $(DOS2UNIX_DESCRIPTION)" >>$@
	@echo "Depends: $(DOS2UNIX_DEPENDS)" >>$@
	@echo "Suggests: $(DOS2UNIX_SUGGESTS)" >>$@
	@echo "Conflicts: $(DOS2UNIX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DOS2UNIX_IPK_DIR)/opt/sbin or $(DOS2UNIX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DOS2UNIX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(DOS2UNIX_IPK_DIR)/opt/etc/dos2unix/...
# Documentation files should be installed in $(DOS2UNIX_IPK_DIR)/opt/doc/dos2unix/...
# Daemon startup scripts should be installed in $(DOS2UNIX_IPK_DIR)/opt/etc/init.d/S??dos2unix
#
# You may need to patch your application to make it use these locations.
#
$(DOS2UNIX_IPK): $(DOS2UNIX_BUILD_DIR)/.built
	rm -rf $(DOS2UNIX_IPK_DIR) $(BUILD_DIR)/dos2unix_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(DOS2UNIX_BUILD_DIR) DESTDIR=$(DOS2UNIX_IPK_DIR) prefix=/opt install
	$(STRIP_COMMAND) $(DOS2UNIX_IPK_DIR)/opt/bin/dos2unix $(DOS2UNIX_IPK_DIR)/opt/bin/unix2dos
	$(MAKE) $(DOS2UNIX_IPK_DIR)/CONTROL/control
	echo $(DOS2UNIX_CONFFILES) | sed -e 's/ /\n/g' > $(DOS2UNIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DOS2UNIX_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(DOS2UNIX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dos2unix-ipk: $(DOS2UNIX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dos2unix-clean:
	rm -f $(DOS2UNIX_BUILD_DIR)/.built
	-$(MAKE) -C $(DOS2UNIX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dos2unix-dirclean:
	rm -rf $(BUILD_DIR)/$(DOS2UNIX_DIR) $(DOS2UNIX_BUILD_DIR) $(DOS2UNIX_IPK_DIR) $(DOS2UNIX_IPK)
#
#
# Some sanity check for the package.
#
dos2unix-check: $(DOS2UNIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
