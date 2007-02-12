###########################################################
#
# obexftp
#
###########################################################
#
# OBEXFTP_VERSION, OBEXFTP_SITE and OBEXFTP_SOURCE define
# the upstream location of the source code for the package.
# OBEXFTP_DIR is the directory which is created when the source
# archive is unpacked.
# OBEXFTP_UNZIP is the command used to unzip the source.
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
OBEXFTP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/openobex
OBEXFTP_VERSION=0.10.3
OBEXFTP_SOURCE=obexftp-$(OBEXFTP_VERSION).tar.gz
OBEXFTP_DIR=obexftp-$(OBEXFTP_VERSION)
OBEXFTP_UNZIP=zcat
OBEXFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OBEXFTP_DESCRIPTION=Transfer files to/from any OBEX enabled device (most likely mobiles).
OBEXFTP_SECTION=net
OBEXFTP_PRIORITY=optional
OBEXFTP_DEPENDS=openobex
OBEXFTP_SUGGESTS=
OBEXFTP_CONFLICTS=

#
# OBEXFTP_IPK_VERSION should be incremented when the ipk changes.
#
OBEXFTP_IPK_VERSION=1

#
# OBEXFTP_CONFFILES should be a list of user-editable files
#OBEXFTP_CONFFILES=/opt/etc/obexftp.conf /opt/etc/init.d/SXXobexftp

#
# OBEXFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OBEXFTP_PATCHES=$(OBEXFTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OBEXFTP_CPPFLAGS=
OBEXFTP_LDFLAGS=

#
# OBEXFTP_BUILD_DIR is the directory in which the build is done.
# OBEXFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OBEXFTP_IPK_DIR is the directory in which the ipk is built.
# OBEXFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OBEXFTP_BUILD_DIR=$(BUILD_DIR)/obexftp
OBEXFTP_SOURCE_DIR=$(SOURCE_DIR)/obexftp
OBEXFTP_IPK_DIR=$(BUILD_DIR)/obexftp-$(OBEXFTP_VERSION)-ipk
OBEXFTP_IPK=$(BUILD_DIR)/obexftp_$(OBEXFTP_VERSION)-$(OBEXFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: obexftp-source obexftp-unpack obexftp obexftp-stage obexftp-ipk obexftp-clean obexftp-dirclean obexftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OBEXFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(OBEXFTP_SITE)/$(OBEXFTP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OBEXFTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
obexftp-source: $(DL_DIR)/$(OBEXFTP_SOURCE) $(OBEXFTP_PATCHES)

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
$(OBEXFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(OBEXFTP_SOURCE) $(OBEXFTP_PATCHES) make/obexftp.mk
	$(MAKE) openobex-stage
	rm -rf $(BUILD_DIR)/$(OBEXFTP_DIR) $(OBEXFTP_BUILD_DIR)
	$(OBEXFTP_UNZIP) $(DL_DIR)/$(OBEXFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OBEXFTP_PATCHES)" ; \
		then cat $(OBEXFTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OBEXFTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OBEXFTP_DIR)" != "$(OBEXFTP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OBEXFTP_DIR) $(OBEXFTP_BUILD_DIR) ; \
	fi
	(cd $(OBEXFTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OBEXFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OBEXFTP_LDFLAGS)" \
		ac_cv_path_OPENOBEX_CONFIG=$(STAGING_PREFIX)/bin/openobex-config \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^pkgdatadir/anoinstdir=\$$(pkgdatadir)' $(OBEXFTP_BUILD_DIR)/doc/Makefile
	$(PATCH_LIBTOOL) $(OBEXFTP_BUILD_DIR)/libtool
	touch $@

obexftp-unpack: $(OBEXFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OBEXFTP_BUILD_DIR)/.built: $(OBEXFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(OBEXFTP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
obexftp: $(OBEXFTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OBEXFTP_BUILD_DIR)/.staged: $(OBEXFTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(OBEXFTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

obexftp-stage: $(OBEXFTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/obexftp
#
$(OBEXFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: obexftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OBEXFTP_PRIORITY)" >>$@
	@echo "Section: $(OBEXFTP_SECTION)" >>$@
	@echo "Version: $(OBEXFTP_VERSION)-$(OBEXFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OBEXFTP_MAINTAINER)" >>$@
	@echo "Source: $(OBEXFTP_SITE)/$(OBEXFTP_SOURCE)" >>$@
	@echo "Description: $(OBEXFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(OBEXFTP_DEPENDS)" >>$@
	@echo "Suggests: $(OBEXFTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(OBEXFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OBEXFTP_IPK_DIR)/opt/sbin or $(OBEXFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OBEXFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OBEXFTP_IPK_DIR)/opt/etc/obexftp/...
# Documentation files should be installed in $(OBEXFTP_IPK_DIR)/opt/doc/obexftp/...
# Daemon startup scripts should be installed in $(OBEXFTP_IPK_DIR)/opt/etc/init.d/S??obexftp
#
# You may need to patch your application to make it use these locations.
#
$(OBEXFTP_IPK): $(OBEXFTP_BUILD_DIR)/.built
	rm -rf $(OBEXFTP_IPK_DIR) $(BUILD_DIR)/obexftp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OBEXFTP_BUILD_DIR) DESTDIR=$(OBEXFTP_IPK_DIR) install-strip
	rm -f $(OBEXFTP_IPK_DIR)/opt/lib/*.la
	$(STRIP_COMMAND) $(OBEXFTP_IPK_DIR)/opt/lib/lib*.so.[0-9]*.[0-9]*.[0-9]*
#	install -d $(OBEXFTP_IPK_DIR)/opt/etc/
#	install -m 644 $(OBEXFTP_SOURCE_DIR)/obexftp.conf $(OBEXFTP_IPK_DIR)/opt/etc/obexftp.conf
#	install -d $(OBEXFTP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OBEXFTP_SOURCE_DIR)/rc.obexftp $(OBEXFTP_IPK_DIR)/opt/etc/init.d/SXXobexftp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OBEXFTP_IPK_DIR)/opt/etc/init.d/SXXobexftp
	$(MAKE) $(OBEXFTP_IPK_DIR)/CONTROL/control
#	install -m 755 $(OBEXFTP_SOURCE_DIR)/postinst $(OBEXFTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OBEXFTP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OBEXFTP_SOURCE_DIR)/prerm $(OBEXFTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OBEXFTP_IPK_DIR)/CONTROL/prerm
	echo $(OBEXFTP_CONFFILES) | sed -e 's/ /\n/g' > $(OBEXFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OBEXFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
obexftp-ipk: $(OBEXFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
obexftp-clean:
	rm -f $(OBEXFTP_BUILD_DIR)/.built
	-$(MAKE) -C $(OBEXFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
obexftp-dirclean:
	rm -rf $(BUILD_DIR)/$(OBEXFTP_DIR) $(OBEXFTP_BUILD_DIR) $(OBEXFTP_IPK_DIR) $(OBEXFTP_IPK)
#
#
# Some sanity check for the package.
#
obexftp-check: $(OBEXFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OBEXFTP_IPK)
