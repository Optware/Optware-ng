###########################################################
#
# wput
#
###########################################################
#
# WPUT_VERSION, WPUT_SITE and WPUT_SOURCE define
# the upstream location of the source code for the package.
# WPUT_DIR is the directory which is created when the source
# archive is unpacked.
# WPUT_UNZIP is the command used to unzip the source.
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
WPUT_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/wput
WPUT_VERSION=0.6.1
WPUT_SOURCE=wput-$(WPUT_VERSION).tgz
WPUT_DIR=wput-$(WPUT_VERSION)
WPUT_UNZIP=zcat
WPUT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WPUT_DESCRIPTION=A command-line ftp-client that uploads files or whole directories to remote ftp-servers.
WPUT_SECTION=net
WPUT_PRIORITY=optional
WPUT_DEPENDS=
WPUT_SUGGESTS=
WPUT_CONFLICTS=

#
# WPUT_IPK_VERSION should be incremented when the ipk changes.
#
WPUT_IPK_VERSION=2

#
# WPUT_CONFFILES should be a list of user-editable files
#WPUT_CONFFILES=/opt/etc/wput.conf /opt/etc/init.d/SXXwput

#
# WPUT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#WPUT_PATCHES=$(WPUT_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WPUT_CPPFLAGS=
WPUT_LDFLAGS=

#
# WPUT_BUILD_DIR is the directory in which the build is done.
# WPUT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WPUT_IPK_DIR is the directory in which the ipk is built.
# WPUT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WPUT_BUILD_DIR=$(BUILD_DIR)/wput
WPUT_SOURCE_DIR=$(SOURCE_DIR)/wput
WPUT_IPK_DIR=$(BUILD_DIR)/wput-$(WPUT_VERSION)-ipk
WPUT_IPK=$(BUILD_DIR)/wput_$(WPUT_VERSION)-$(WPUT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: wput-source wput-unpack wput wput-stage wput-ipk wput-clean wput-dirclean wput-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WPUT_SOURCE):
	$(WGET) -P $(DL_DIR) $(WPUT_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
wput-source: $(DL_DIR)/$(WPUT_SOURCE) $(WPUT_PATCHES)

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
$(WPUT_BUILD_DIR)/.configured: $(DL_DIR)/$(WPUT_SOURCE) $(WPUT_PATCHES) make/wput.mk
#	$(MAKE) gnutls-stage
	rm -rf $(BUILD_DIR)/$(WPUT_DIR) $(WPUT_BUILD_DIR)
	$(WPUT_UNZIP) $(DL_DIR)/$(WPUT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WPUT_PATCHES)" ; \
		then cat $(WPUT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(WPUT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WPUT_DIR)" != "$(WPUT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(WPUT_DIR) $(WPUT_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WPUT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WPUT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-ssl \
		--disable-nls \
		--disable-static \
	)
	sed -i \
	-e 's|$$(CC)|$$(CC) $$(CPPFLAGS)|' \
	-e 's|$$(LIBS)|$$(LIBS) $$(LDFLAGS)|' \
	$(@D)/src/Makefile
#	$(PATCH_LIBTOOL) $(WPUT_BUILD_DIR)/libtool
	touch $@

wput-unpack: $(WPUT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WPUT_BUILD_DIR)/.built: $(WPUT_BUILD_DIR)/.configured
	rm -f $@
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WPUT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WPUT_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
wput: $(WPUT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WPUT_BUILD_DIR)/.staged: $(WPUT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

wput-stage: $(WPUT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/wput
#
$(WPUT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: wput" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WPUT_PRIORITY)" >>$@
	@echo "Section: $(WPUT_SECTION)" >>$@
	@echo "Version: $(WPUT_VERSION)-$(WPUT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WPUT_MAINTAINER)" >>$@
	@echo "Source: $(WPUT_SITE)/$(WPUT_SOURCE)" >>$@
	@echo "Description: $(WPUT_DESCRIPTION)" >>$@
	@echo "Depends: $(WPUT_DEPENDS)" >>$@
	@echo "Suggests: $(WPUT_SUGGESTS)" >>$@
	@echo "Conflicts: $(WPUT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WPUT_IPK_DIR)/opt/sbin or $(WPUT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WPUT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WPUT_IPK_DIR)/opt/etc/wput/...
# Documentation files should be installed in $(WPUT_IPK_DIR)/opt/doc/wput/...
# Daemon startup scripts should be installed in $(WPUT_IPK_DIR)/opt/etc/init.d/S??wput
#
# You may need to patch your application to make it use these locations.
#
$(WPUT_IPK): $(WPUT_BUILD_DIR)/.built
	rm -rf $(WPUT_IPK_DIR) $(BUILD_DIR)/wput_*_$(TARGET_ARCH).ipk
	install -d $(WPUT_IPK_DIR)/opt/bin/
	install -d $(WPUT_IPK_DIR)/opt/share/man/man1
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WPUT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WPUT_LDFLAGS)" \
	$(MAKE) -C $(WPUT_BUILD_DIR) prefix=$(WPUT_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(WPUT_IPK_DIR)/opt/bin/*
#	install -d $(WPUT_IPK_DIR)/opt/etc/
#	install -m 644 $(WPUT_SOURCE_DIR)/wput.conf $(WPUT_IPK_DIR)/opt/etc/wput.conf
#	install -d $(WPUT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(WPUT_SOURCE_DIR)/rc.wput $(WPUT_IPK_DIR)/opt/etc/init.d/SXXwput
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXwput
	$(MAKE) $(WPUT_IPK_DIR)/CONTROL/control
#	install -m 755 $(WPUT_SOURCE_DIR)/postinst $(WPUT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(WPUT_SOURCE_DIR)/prerm $(WPUT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(WPUT_CONFFILES) | sed -e 's/ /\n/g' > $(WPUT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WPUT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
wput-ipk: $(WPUT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
wput-clean:
	rm -f $(WPUT_BUILD_DIR)/.built
	-$(MAKE) -C $(WPUT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
wput-dirclean:
	rm -rf $(BUILD_DIR)/$(WPUT_DIR) $(WPUT_BUILD_DIR) $(WPUT_IPK_DIR) $(WPUT_IPK)
#
#
# Some sanity check for the package.
#
wput-check: $(WPUT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WPUT_IPK)
