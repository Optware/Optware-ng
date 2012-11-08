###########################################################
#
# nzbget-testing
#
###########################################################
#
# NZBGET-TESTING_VERSION, NZBGET-TESTING_SITE and NZBGET-TESTING_SOURCE define
# the upstream location of the source code for the package.
# NZBGET-TESTING_DIR is the directory which is created when the source
# archive is unpacked.
# NZBGET-TESTING_UNZIP is the command used to unzip the source.
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
NZBGET-TESTING_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nzbget
NZBGET-TESTING_VER=9.0
NZBGET-TESTING_REV=r497
NZBGET-TESTING_VERSION=$(NZBGET-TESTING_VER)-$(NZBGET-TESTING_REV)
NZBGET-TESTING_SOURCE=nzbget-$(NZBGET-TESTING_VER)-testing-$(NZBGET-TESTING_REV).tar.gz
NZBGET-TESTING_DIR=nzbget-$(NZBGET-TESTING_VER)-testing
NZBGET-TESTING_UNZIP=zcat
NZBGET-TESTING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NZBGET-TESTING_DESCRIPTION=A command-line client/server based binary newsgrabber for nzb-files (latest testing version).
NZBGET-TESTING_SECTION=net
NZBGET-TESTING_PRIORITY=optional
NZBGET-TESTING_DEPENDS=ncurses, libxml2, libpar2, openssl
NZBGET-TESTING_SUGGESTS=
NZBGET-TESTING_CONFLICTS=nzbget

#
# NZBGET-TESTING_IPK_VERSION should be incremented when the ipk changes.
#
NZBGET-TESTING_IPK_VERSION=1

#
# NZBGET-TESTING_CONFFILES should be a list of user-editable files
#NZBGET-TESTING_CONFFILES=~/.nzbget

#
# NZBGET-TESTING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NZBGET-TESTING_PATCHES=$(NZBGET-TESTING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NZBGET-TESTING_CPPFLAGS=
NZBGET-TESTING_LDFLAGS=
NZBGET-TESTING_CONFIGURE=
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
NZBGET-TESTING_CONFIGURE += CXX=$(TARGET_GXX)
endif
endif

#
# NZBGET-TESTING_BUILD_DIR is the directory in which the build is done.
# NZBGET-TESTING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NZBGET-TESTING_IPK_DIR is the directory in which the ipk is built.
# NZBGET-TESTING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NZBGET-TESTING_BUILD_DIR=$(BUILD_DIR)/nzbget-testing
NZBGET-TESTING_SOURCE_DIR=$(SOURCE_DIR)/nzbget-testing
NZBGET-TESTING_IPK_DIR=$(BUILD_DIR)/nzbget-testing-$(NZBGET-TESTING_VER)-ipk
NZBGET-TESTING_IPK=$(BUILD_DIR)/nzbget-testing_$(NZBGET-TESTING_VERSION)-$(NZBGET-TESTING_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NZBGET-TESTING_SOURCE):
	$(WGET) -P $(@D) $(NZBGET-TESTING_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nzbget-testing-source: $(DL_DIR)/$(NZBGET-TESTING_SOURCE) $(NZBGET-TESTING_PATCHES)

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
$(NZBGET-TESTING_BUILD_DIR)/.configured: $(DL_DIR)/$(NZBGET-TESTING_SOURCE) $(NZBGET-TESTING_PATCHES)
	$(MAKE) libxml2-stage ncurses-stage libpar2-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(NZBGET-TESTING_DIR) $(@D)
	$(NZBGET-TESTING_UNZIP) $(DL_DIR)/$(NZBGET-TESTING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NZBGET-TESTING_PATCHES)" ; \
		then cat $(NZBGET-TESTING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NZBGET-TESTING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NZBGET-TESTING_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NZBGET-TESTING_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NZBGET-TESTING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NZBGET-TESTING_LDFLAGS)" \
		LIBPREF="$(STAGING_DIR)/opt" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(NZBGET-TESTING_CONFIGURE) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-tlslib=OpenSSL \
		--program-prefix= \
		$(NZBGET_TESTING_CONFIGURE_OPTS) \
	)
	sed -i -e '/^CPPFLAGS/s:-I/usr.*$$::' -e '/^LDFLAGS/s:-L/usr.*$$::' $(@D)/Makefile
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

nzbget-testing-unpack: $(NZBGET-TESTING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NZBGET-TESTING_BUILD_DIR)/.built: $(NZBGET-TESTING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nzbget-testing: $(NZBGET-TESTING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NZBGET-TESTING_BUILD_DIR)/.staged: $(NZBGET-TESTING_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

nzbget-testing-stage: $(NZBGET-TESTING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nzbget
#
$(NZBGET-TESTING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nzbget-testing" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NZBGET-TESTING_PRIORITY)" >>$@
	@echo "Section: $(NZBGET-TESTING_SECTION)" >>$@
	@echo "Version: $(NZBGET-TESTING_VERSION)-$(NZBGET-TESTING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NZBGET-TESTING_MAINTAINER)" >>$@
	@echo "Source: $(NZBGET-TESTING_SITE)/$(NZBGET-TESTING_SOURCE)" >>$@
	@echo "Description: $(NZBGET-TESTING_DESCRIPTION)" >>$@
	@echo "Depends: $(NZBGET-TESTING_DEPENDS)" >>$@
	@echo "Suggests: $(NZBGET-TESTING_SUGGESTS)" >>$@
	@echo "Conflicts: $(NZBGET-TESTING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NZBGET-TESTING_IPK_DIR)/opt/sbin or $(NZBGET-TESTING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NZBGET-TESTING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NZBGET-TESTING_IPK_DIR)/opt/etc/nzbget/...
# Documentation files should be installed in $(NZBGET-TESTING_IPK_DIR)/opt/doc/nzbget/...
# Daemon startup scripts should be installed in $(NZBGET-TESTING_IPK_DIR)/opt/etc/init.d/S??nzbget
#
# You may need to patch your application to make it use these locations.
#
$(NZBGET-TESTING_IPK): $(NZBGET-TESTING_BUILD_DIR)/.built
	rm -rf $(NZBGET-TESTING_IPK_DIR) $(BUILD_DIR)/nzbget-testing_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NZBGET-TESTING_BUILD_DIR) DESTDIR=$(NZBGET-TESTING_IPK_DIR) install
	$(STRIP_COMMAND) $(NZBGET-TESTING_IPK_DIR)/opt/bin/nzbget
#	install -d $(NZBGET-TESTING_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NZBGET-TESTING_SOURCE_DIR)/rc.nzbget $(NZBGET-TESTING_IPK_DIR)/opt/etc/init.d/SXXnzbget
	$(MAKE) $(NZBGET-TESTING_IPK_DIR)/CONTROL/control
#	install -m 755 $(NZBGET-TESTING_SOURCE_DIR)/postinst $(NZBGET-TESTING_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NZBGET-TESTING_SOURCE_DIR)/prerm $(NZBGET-TESTING_IPK_DIR)/CONTROL/prerm
#	echo $(NZBGET-TESTING_CONFFILES) | sed -e 's/ /\n/g' > $(NZBGET-TESTING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NZBGET-TESTING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nzbget-testing-ipk: $(NZBGET-TESTING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nzbget-testing-clean:
	rm -f $(NZBGET-TESTING_BUILD_DIR)/.built
	-$(MAKE) -C $(NZBGET-TESTING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nzbget-testing-dirclean:
	rm -rf $(BUILD_DIR)/$(NZBGET-TESTING_DIR) $(NZBGET-TESTING_BUILD_DIR) $(NZBGET-TESTING_IPK_DIR) $(NZBGET-TESTING_IPK)

#
#
# Some sanity check for the package.
#
nzbget-testing-check: $(NZBGET-TESTING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
