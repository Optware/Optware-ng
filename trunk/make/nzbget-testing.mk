###########################################################
#
# nzbget
#
###########################################################
#
# NZBGETTESTING_VERSION, NZBGETTESTING_SITE and NZBGETTESTING_SOURCE define
# the upstream location of the source code for the package.
# NZBGETTESTING_DIR is the directory which is created when the source
# archive is unpacked.
# NZBGETTESTING_UNZIP is the command used to unzip the source.
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
NZBGETTESTING_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nzbget
NZBGETTESTING_VERSION=0.7.0
NZBGETTESTING_REVISION=r342
NZBGETTESTING_SOURCE=nzbget-$(NZBGETTESTING_VERSION)-testing-$(NZBGETTESTING_REVISION).tar.gz
NZBGETTESTING_DIR=nzbget-$(NZBGETTESTING_VERSION)-testing
NZBGETTESTING_UNZIP=zcat
NZBGETTESTING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NZBGETTESTING_DESCRIPTION=A command-line client/server based binary newsgrabber for nzb-files.
NZBGETTESTING_SECTION=net
NZBGETTESTING_PRIORITY=optional
NZBGETTESTING_DEPENDS=ncurses, libxml2, libpar2, openssl
NZBGETTESTING_SUGGESTS=
NZBGETTESTING_CONFLICTS=

#
# NZBGETTESTING_IPK_VERSION should be incremented when the ipk changes.
#
NZBGETTESTING_IPK_VERSION=1

#
# NZBGETTESTING_CONFFILES should be a list of user-editable files
#NZBGETTESTING_CONFFILES=~/.nzbget

#
# NZBGETTESTING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NZBGETTESTING_PATCHES=$(NZBGETTESTING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NZBGETTESTING_CPPFLAGS=
NZBGETTESTING_LDFLAGS=
NZBGETTESTING_CONFIGURE=
ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
NZBGETTESTING_CONFIGURE += CXX=$(TARGET_GXX)
endif
endif

#
# NZBGETTESTING_BUILD_DIR is the directory in which the build is done.
# NZBGETTESTING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NZBGETTESTING_IPK_DIR is the directory in which the ipk is built.
# NZBGETTESTING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NZBGETTESTING_BUILD_DIR=$(BUILD_DIR)/nzbget-testing
NZBGETTESTING_SOURCE_DIR=$(SOURCE_DIR)/nzbget-testing
NZBGETTESTING_IPK_DIR=$(BUILD_DIR)/nzbget-testing-ipk
NZBGETTESTING_IPK=$(BUILD_DIR)/nzbget-testing_$(NZBGETTESTING_VERSION)-$(NZBGETTESTING_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NZBGETTESTING_SOURCE):
	$(WGET) -P $(DL_DIR) $(NZBGETTESTING_SITE)/$(NZBGETTESTING_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nzbget-testing-source: $(DL_DIR)/$(NZBGETTESTING_SOURCE) $(NZBGETTESTING_PATCHES)

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
$(NZBGETTESTING_BUILD_DIR)/.configured: $(DL_DIR)/$(NZBGETTESTING_SOURCE) $(NZBGETTESTING_PATCHES)
	$(MAKE) libxml2-stage ncurses-stage libpar2-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(NZBGETTESTING_DIR) $(NZBGETTESTING_BUILD_DIR)
	$(NZBGETTESTING_UNZIP) $(DL_DIR)/$(NZBGETTESTING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NZBGETTESTING_PATCHES)" ; \
		then cat $(NZBGETTESTING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NZBGETTESTING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NZBGETTESTING_DIR)" != "$(NZBGETTESTING_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NZBGETTESTING_DIR) $(NZBGETTESTING_BUILD_DIR) ; \
	fi
	(cd $(NZBGETTESTING_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NZBGETTESTING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NZBGETTESTING_LDFLAGS)" \
		LIBPREF="$(STAGING_DIR)/opt" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		$(NZBGETTESTING_CONFIGURE) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-tlslib=OpenSSL \
		$(NZBGETTESTING_CONFIGURE_OPTS) \
	)
	sed -i -e '/^CPPFLAGS/s:-I/usr.*$$::' -e '/^LDFLAGS/s:-L/usr.*$$::' \
		$(NZBGETTESTING_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(NZBGETTESTING_BUILD_DIR)/libtool
	touch $@

nzbget-testing-unpack: $(NZBGETTESTING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NZBGETTESTING_BUILD_DIR)/.built: $(NZBGETTESTING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NZBGETTESTING_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
nzbget-testing: $(NZBGETTESTING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NZBGETTESTING_BUILD_DIR)/.staged: $(NZBGETTESTING_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NZBGETTESTING_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

nzbget-testing-stage: $(NZBGETTESTING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nzbget
#
$(NZBGETTESTING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nzbget-testing" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NZBGETTESTING_PRIORITY)" >>$@
	@echo "Section: $(NZBGETTESTING_SECTION)" >>$@
	@echo "Version: $(NZBGETTESTING_VERSION)-$(NZBGETTESTING_REVISION)-$(NZBGETTESTING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NZBGETTESTING_MAINTAINER)" >>$@
	@echo "Source: $(NZBGETTESTING_SITE)/$(NZBGETTESTING_SOURCE)" >>$@
	@echo "Description: $(NZBGETTESTING_DESCRIPTION)" >>$@
	@echo "Depends: $(NZBGETTESTING_DEPENDS)" >>$@
	@echo "Suggests: $(NZBGETTESTING_SUGGESTS)" >>$@
	@echo "Conflicts: $(NZBGETTESTING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NZBGETTESTING_IPK_DIR)/opt/sbin or $(NZBGETTESTING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NZBGETTESTING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NZBGETTESTING_IPK_DIR)/opt/etc/nzbget/...
# Documentation files should be installed in $(NZBGETTESTING_IPK_DIR)/opt/doc/nzbget/...
# Daemon startup scripts should be installed in $(NZBGETTESTING_IPK_DIR)/opt/etc/init.d/S??nzbget
#
# You may need to patch your application to make it use these locations.
#
$(NZBGETTESTING_IPK): $(NZBGETTESTING_BUILD_DIR)/.built
	rm -rf $(NZBGETTESTING_IPK_DIR) $(BUILD_DIR)/nzbget_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(NZBGETTESTING_BUILD_DIR) DESTDIR=$(NZBGETTESTING_IPK_DIR) install
	install -d $(NZBGETTESTING_IPK_DIR)/opt/bin $(NZBGETTESTING_IPK_DIR)/opt/share/doc/nzbget
	install -m 755 $(NZBGETTESTING_BUILD_DIR)/nzbget $(NZBGETTESTING_IPK_DIR)/opt/bin/
	install -m 644 $(NZBGETTESTING_BUILD_DIR)/README $(NZBGETTESTING_IPK_DIR)/opt/share/doc/nzbget/
	install -m 644 $(NZBGETTESTING_BUILD_DIR)/nzbget.conf.example $(NZBGETTESTING_IPK_DIR)/opt/share/doc/nzbget/
	install -m 644 $(NZBGETTESTING_BUILD_DIR)/postprocess-example.sh $(NZBGETTESTING_IPK_DIR)/opt/share/doc/nzbget/
	install -m 644 $(NZBGETTESTING_BUILD_DIR)/postprocess-example.conf $(NZBGETTESTING_IPK_DIR)/opt/share/doc/nzbget/
	$(STRIP_COMMAND) $(NZBGETTESTING_IPK_DIR)/opt/bin/nzbget
#	install -d $(NZBGETTESTING_IPK_DIR)/opt/etc/
#	install -m 644 $(NZBGETTESTING_SOURCE_DIR)/nzbget.conf $(NZBGETTESTING_IPK_DIR)/opt/etc/nzbget.conf
#	install -d $(NZBGETTESTING_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NZBGETTESTING_SOURCE_DIR)/rc.nzbget $(NZBGETTESTING_IPK_DIR)/opt/etc/init.d/SXXnzbget
	$(MAKE) $(NZBGETTESTING_IPK_DIR)/CONTROL/control
#	install -m 755 $(NZBGETTESTING_SOURCE_DIR)/postinst $(NZBGETTESTING_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NZBGETTESTING_SOURCE_DIR)/prerm $(NZBGETTESTING_IPK_DIR)/CONTROL/prerm
#	echo $(NZBGETTESTING_CONFFILES) | sed -e 's/ /\n/g' > $(NZBGETTESTING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NZBGETTESTING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nzbget-testing-ipk: $(NZBGETTESTING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nzbget-testing-clean:
	rm -f $(NZBGETTESTING_BUILD_DIR)/.built
	-$(MAKE) -C $(NZBGETTESTING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nzbget-testing-dirclean:
	rm -rf $(BUILD_DIR)/$(NZBGETTESTING_DIR) $(NZBGETTESTING_BUILD_DIR) $(NZBGETTESTING_IPK_DIR) $(NZBGETTESTING_IPK)

#
#
# Some sanity check for the package.
#
nzbget-testing-check: $(NZBGETTESTING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NZBGETTESTING_IPK)
