###########################################################
#
# tnftpd
#
###########################################################
#
# TNFTPD_VERSION, TNFTPD_SITE and TNFTPD_SOURCE define
# the upstream location of the source code for the package.
# TNFTPD_DIR is the directory which is created when the source
# archive is unpacked.
# TNFTPD_UNZIP is the command used to unzip the source.
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
TNFTPD_SITE=ftp://ftp.netbsd.org/pub/NetBSD/misc/tnftp
TNFTPD_VERSION=20080609
TNFTPD_SOURCE=tnftpd-$(TNFTPD_VERSION).tar.gz
TNFTPD_DIR=tnftpd-$(TNFTPD_VERSION)
TNFTPD_UNZIP=zcat
TNFTPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TNFTPD_DESCRIPTION=tnftpd (formerly lukemftpd) is a port of the NetBSD FTP server to other systems.
TNFTPD_SECTION=net
TNFTPD_PRIORITY=optional
TNFTPD_DEPENDS=
TNFTPD_SUGGESTS=
TNFTPD_CONFLICTS=

#
# TNFTPD_IPK_VERSION should be incremented when the ipk changes.
#
TNFTPD_IPK_VERSION=1

#
# TNFTPD_CONFFILES should be a list of user-editable files
#TNFTPD_CONFFILES=/opt/etc/tnftpd.conf /opt/etc/init.d/SXXtnftpd

#
# TNFTPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TNFTPD_PATCHES=$(TNFTPD_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TNFTPD_CPPFLAGS=
TNFTPD_LDFLAGS=

#
# TNFTPD_BUILD_DIR is the directory in which the build is done.
# TNFTPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TNFTPD_IPK_DIR is the directory in which the ipk is built.
# TNFTPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TNFTPD_BUILD_DIR=$(BUILD_DIR)/tnftpd
TNFTPD_SOURCE_DIR=$(SOURCE_DIR)/tnftpd
TNFTPD_IPK_DIR=$(BUILD_DIR)/tnftpd-$(TNFTPD_VERSION)-ipk
TNFTPD_IPK=$(BUILD_DIR)/tnftpd_$(TNFTPD_VERSION)-$(TNFTPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tnftpd-source tnftpd-unpack tnftpd tnftpd-stage tnftpd-ipk tnftpd-clean tnftpd-dirclean tnftpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TNFTPD_SOURCE):
	$(WGET) -P $(@D) $(TNFTPD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tnftpd-source: $(DL_DIR)/$(TNFTPD_SOURCE) $(TNFTPD_PATCHES)

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
$(TNFTPD_BUILD_DIR)/.configured: $(DL_DIR)/$(TNFTPD_SOURCE) $(TNFTPD_PATCHES) make/tnftpd.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TNFTPD_DIR) $(@D)
	$(TNFTPD_UNZIP) $(DL_DIR)/$(TNFTPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TNFTPD_PATCHES)" ; \
		then cat $(TNFTPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TNFTPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TNFTPD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TNFTPD_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TNFTPD_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(TNFTPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TNFTPD_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TNFTPD_BUILD_DIR)/libtool
	touch $@

tnftpd-unpack: $(TNFTPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TNFTPD_BUILD_DIR)/.built: $(TNFTPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tnftpd: $(TNFTPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TNFTPD_BUILD_DIR)/.staged: $(TNFTPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tnftpd-stage: $(TNFTPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tnftpd
#
$(TNFTPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tnftpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TNFTPD_PRIORITY)" >>$@
	@echo "Section: $(TNFTPD_SECTION)" >>$@
	@echo "Version: $(TNFTPD_VERSION)-$(TNFTPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TNFTPD_MAINTAINER)" >>$@
	@echo "Source: $(TNFTPD_SITE)/$(TNFTPD_SOURCE)" >>$@
	@echo "Description: $(TNFTPD_DESCRIPTION)" >>$@
	@echo "Depends: $(TNFTPD_DEPENDS)" >>$@
	@echo "Suggests: $(TNFTPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(TNFTPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TNFTPD_IPK_DIR)/opt/sbin or $(TNFTPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TNFTPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TNFTPD_IPK_DIR)/opt/etc/tnftpd/...
# Documentation files should be installed in $(TNFTPD_IPK_DIR)/opt/doc/tnftpd/...
# Daemon startup scripts should be installed in $(TNFTPD_IPK_DIR)/opt/etc/init.d/S??tnftpd
#
# You may need to patch your application to make it use these locations.
#
$(TNFTPD_IPK): $(TNFTPD_BUILD_DIR)/.built
	rm -rf $(TNFTPD_IPK_DIR) $(BUILD_DIR)/tnftpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TNFTPD_BUILD_DIR) prefix=$(TNFTPD_IPK_DIR)/opt install
	chmod +w $(TNFTPD_IPK_DIR)/opt/sbin/tnftpd; \
	$(STRIP_COMMAND) $(TNFTPD_IPK_DIR)/opt/sbin/tnftpd; \
	chmod -w $(TNFTPD_IPK_DIR)/opt/sbin/tnftpd
	install -d $(TNFTPD_IPK_DIR)/opt/share/doc/tnftpd/examples/
	install $(TNFTPD_BUILD_DIR)/examples/ftpd.conf $(TNFTPD_IPK_DIR)/opt/share/doc/tnftpd/examples/
	mv $(TNFTPD_IPK_DIR)/opt/share/man/cat5 $(TNFTPD_IPK_DIR)/opt/share/man/man5
	mv $(TNFTPD_IPK_DIR)/opt/share/man/cat8 $(TNFTPD_IPK_DIR)/opt/share/man/man8
#	install -d $(TNFTPD_IPK_DIR)/opt/etc/
#	install -m 644 $(TNFTPD_SOURCE_DIR)/tnftpd.conf $(TNFTPD_IPK_DIR)/opt/etc/tnftpd.conf
#	install -d $(TNFTPD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TNFTPD_SOURCE_DIR)/rc.tnftpd $(TNFTPD_IPK_DIR)/opt/etc/init.d/SXXtnftpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXtnftpd
	$(MAKE) $(TNFTPD_IPK_DIR)/CONTROL/control
#	install -m 755 $(TNFTPD_SOURCE_DIR)/postinst $(TNFTPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TNFTPD_SOURCE_DIR)/prerm $(TNFTPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(TNFTPD_CONFFILES) | sed -e 's/ /\n/g' > $(TNFTPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TNFTPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tnftpd-ipk: $(TNFTPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tnftpd-clean:
	rm -f $(TNFTPD_BUILD_DIR)/.built
	-$(MAKE) -C $(TNFTPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tnftpd-dirclean:
	rm -rf $(BUILD_DIR)/$(TNFTPD_DIR) $(TNFTPD_BUILD_DIR) $(TNFTPD_IPK_DIR) $(TNFTPD_IPK)
#
#
# Some sanity check for the package.
#
tnftpd-check: $(TNFTPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TNFTPD_IPK)
