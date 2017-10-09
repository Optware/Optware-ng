###########################################################
#
# rtmpdump
#
###########################################################
#
# RTMPDUMP_VERSION, RTMPDUMP_SITE and RTMPDUMP_SOURCE define
# the upstream location of the source code for the package.
# RTMPDUMP_DIR is the directory which is created when the source
# archive is unpacked.
# RTMPDUMP_UNZIP is the command used to unzip the source.
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
RTMPDUMP_SITE=http://archive.ubuntu.com/ubuntu/pool/main/r/rtmpdump
RTMPDUMP_VERSION_MAIN=2.4
RTMPDUMP_VERSION_DATE=20150115
RTMPDUMP_VERSION_GIT=a107cef
RTMPDUMP_VERSION=$(RTMPDUMP_VERSION_MAIN)+$(RTMPDUMP_VERSION_DATE).git$(RTMPDUMP_VERSION_GIT)
RTMPDUMP_SOURCE=rtmpdump_$(RTMPDUMP_VERSION).orig.tar.gz
#RTMPDUMP_DIR=rtmpdump-$(RTMPDUMP_VERSION)
RTMPDUMP_UNZIP=zcat
RTMPDUMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RTMPDUMP_DESCRIPTION=Small dumper for media content streamed over the RTMP protocol.
RTMPDUMP_SECTION=net
RTMPDUMP_PRIORITY=optional
RTMPDUMP_DEPENDS=openssl, zlib
RTMPDUMP_SUGGESTS=
RTMPDUMP_CONFLICTS=

#
# RTMPDUMP_IPK_VERSION should be incremented when the ipk changes.
#
RTMPDUMP_IPK_VERSION=3

#
# RTMPDUMP_CONFFILES should be a list of user-editable files
#RTMPDUMP_CONFFILES=$(TARGET_PREFIX)/etc/rtmpdump.conf $(TARGET_PREFIX)/etc/init.d/SXXrtmpdump

#
# RTMPDUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RTMPDUMP_PATCHES=\
$(RTMPDUMP_SOURCE_DIR)/01_unbreak_makefile.diff \
$(RTMPDUMP_SOURCE_DIR)/02_gnutls_requires.private.diff \
$(RTMPDUMP_SOURCE_DIR)/03_suppress_warning.diff

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RTMPDUMP_CPPFLAGS=
RTMPDUMP_LDFLAGS=

#
# RTMPDUMP_BUILD_DIR is the directory in which the build is done.
# RTMPDUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RTMPDUMP_IPK_DIR is the directory in which the ipk is built.
# RTMPDUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RTMPDUMP_BUILD_DIR=$(BUILD_DIR)/rtmpdump
RTMPDUMP_SOURCE_DIR=$(SOURCE_DIR)/rtmpdump
RTMPDUMP_IPK_DIR=$(BUILD_DIR)/rtmpdump-$(RTMPDUMP_VERSION)-ipk
RTMPDUMP_IPK=$(BUILD_DIR)/rtmpdump_$(RTMPDUMP_VERSION)-$(RTMPDUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rtmpdump-source rtmpdump-unpack rtmpdump rtmpdump-stage rtmpdump-ipk rtmpdump-clean rtmpdump-dirclean rtmpdump-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RTMPDUMP_SOURCE):
	$(WGET) -P $(@D) $(RTMPDUMP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rtmpdump-source: $(DL_DIR)/$(RTMPDUMP_SOURCE) $(RTMPDUMP_PATCHES)

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
$(RTMPDUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(RTMPDUMP_SOURCE) $(RTMPDUMP_PATCHES) make/rtmpdump.mk
	$(MAKE) openssl-stage zlib-stage
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	$(RTMPDUMP_UNZIP) $(DL_DIR)/$(RTMPDUMP_SOURCE) | tar -C $(@D) -xvf - --strip-components=1
	if test -n "$(RTMPDUMP_PATCHES)" ; \
		then cat $(RTMPDUMP_PATCHES) | \
		$(PATCH) -d $(@D) -p1 ; \
	fi
	touch $@

rtmpdump-unpack: $(RTMPDUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RTMPDUMP_BUILD_DIR)/.built: $(RTMPDUMP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) 	$(TARGET_CONFIGURE_OPTS) \
			CRYPTO=OPENSSL \
			XCFLAGS="$(STAGING_CPPFLAGS) $(RTMPDUMP_CPPFLAGS)" \
			XLDFLAGS="$(STAGING_LDFLAGS) $(RTMPDUMP_LDFLAGS)" \
			prefix=$(TARGET_PREFIX) \
		-C $(@D)
	touch $@

#
# This is the build convenience target.
#
rtmpdump: $(RTMPDUMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RTMPDUMP_BUILD_DIR)/.staged: $(RTMPDUMP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) prefix=$(TARGET_PREFIX) DESTDIR=$(STAGING_DIR) install -j1
	sed -i -e '/^prefix=/s|=.*|=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/librtmp.pc
	touch $@

rtmpdump-stage: $(RTMPDUMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rtmpdump
#
$(RTMPDUMP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: rtmpdump" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RTMPDUMP_PRIORITY)" >>$@
	@echo "Section: $(RTMPDUMP_SECTION)" >>$@
	@echo "Version: $(RTMPDUMP_VERSION)-$(RTMPDUMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RTMPDUMP_MAINTAINER)" >>$@
	@echo "Source: $(RTMPDUMP_SITE)/$(RTMPDUMP_SOURCE)" >>$@
	@echo "Description: $(RTMPDUMP_DESCRIPTION)" >>$@
	@echo "Depends: $(RTMPDUMP_DEPENDS)" >>$@
	@echo "Suggests: $(RTMPDUMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(RTMPDUMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/rtmpdump/...
# Documentation files should be installed in $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/doc/rtmpdump/...
# Daemon startup scripts should be installed in $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??rtmpdump
#
# You may need to patch your application to make it use these locations.
#
$(RTMPDUMP_IPK): $(RTMPDUMP_BUILD_DIR)/.built
	rm -rf $(RTMPDUMP_IPK_DIR) $(BUILD_DIR)/rtmpdump_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RTMPDUMP_BUILD_DIR) prefix=$(TARGET_PREFIX) DESTDIR=$(RTMPDUMP_IPK_DIR) install -j1
	rm -f $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/lib/*.a
	$(STRIP_COMMAND) $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/{{bin,sbin}/*,lib/*.so}
#	$(INSTALL) -d $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(RTMPDUMP_SOURCE_DIR)/rtmpdump.conf $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/rtmpdump.conf
#	$(INSTALL) -d $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(RTMPDUMP_SOURCE_DIR)/rc.rtmpdump $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrtmpdump
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RTMPDUMP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXrtmpdump
	$(MAKE) $(RTMPDUMP_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(RTMPDUMP_SOURCE_DIR)/postinst $(RTMPDUMP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RTMPDUMP_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(RTMPDUMP_SOURCE_DIR)/prerm $(RTMPDUMP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RTMPDUMP_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(RTMPDUMP_IPK_DIR)/CONTROL/postinst $(RTMPDUMP_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(RTMPDUMP_CONFFILES) | sed -e 's/ /\n/g' > $(RTMPDUMP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RTMPDUMP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(RTMPDUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rtmpdump-ipk: $(RTMPDUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rtmpdump-clean:
	rm -f $(RTMPDUMP_BUILD_DIR)/.built
	-$(MAKE) -C $(RTMPDUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rtmpdump-dirclean:
	rm -rf $(BUILD_DIR)/$(RTMPDUMP_DIR) $(RTMPDUMP_BUILD_DIR) $(RTMPDUMP_IPK_DIR) $(RTMPDUMP_IPK)
#
#
# Some sanity check for the package.
#
rtmpdump-check: $(RTMPDUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
