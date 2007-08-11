###########################################################
#
# tnftp
#
###########################################################
#
# TNFTP_VERSION, TNFTP_SITE and TNFTP_SOURCE define
# the upstream location of the source code for the package.
# TNFTP_DIR is the directory which is created when the source
# archive is unpacked.
# TNFTP_UNZIP is the command used to unzip the source.
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
TNFTP_SITE=ftp://ftp.netbsd.org/pub/NetBSD/misc/tnftp
TNFTP_VERSION=20070806
TNFTP_SOURCE=tnftp-$(TNFTP_VERSION).tar.gz
TNFTP_DIR=tnftp-$(TNFTP_VERSION)
TNFTP_UNZIP=zcat
TNFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TNFTP_DESCRIPTION=tnftp (formerly lukemftp) is what many users affectionately call the enhanced ftp client in NetBSD.
TNFTP_SECTION=net
TNFTP_PRIORITY=optional
TNFTP_DEPENDS=
TNFTP_SUGGESTS=
TNFTP_CONFLICTS=

#
# TNFTP_IPK_VERSION should be incremented when the ipk changes.
#
TNFTP_IPK_VERSION=1

#
# TNFTP_CONFFILES should be a list of user-editable files
#TNFTP_CONFFILES=/opt/etc/tnftp.conf /opt/etc/init.d/SXXtnftp

#
# TNFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TNFTP_PATCHES=$(TNFTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TNFTP_CPPFLAGS=
TNFTP_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
TNFTP_CONFIGURE_ENV=ac_cv_func_getpgrp_void=yes
else
TNFTP_CONFIGURE_ENV=
endif

#
# TNFTP_BUILD_DIR is the directory in which the build is done.
# TNFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TNFTP_IPK_DIR is the directory in which the ipk is built.
# TNFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TNFTP_BUILD_DIR=$(BUILD_DIR)/tnftp
TNFTP_SOURCE_DIR=$(SOURCE_DIR)/tnftp
TNFTP_IPK_DIR=$(BUILD_DIR)/tnftp-$(TNFTP_VERSION)-ipk
TNFTP_IPK=$(BUILD_DIR)/tnftp_$(TNFTP_VERSION)-$(TNFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tnftp-source tnftp-unpack tnftp tnftp-stage tnftp-ipk tnftp-clean tnftp-dirclean tnftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TNFTP_SOURCE):
	$(WGET) -P $(DL_DIR) $(TNFTP_SITE)/$(TNFTP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tnftp-source: $(DL_DIR)/$(TNFTP_SOURCE) $(TNFTP_PATCHES)

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
$(TNFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(TNFTP_SOURCE) $(TNFTP_PATCHES) make/tnftp.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(TNFTP_DIR) $(TNFTP_BUILD_DIR)
	$(TNFTP_UNZIP) $(DL_DIR)/$(TNFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TNFTP_PATCHES)" ; \
		then cat $(TNFTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TNFTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TNFTP_DIR)" != "$(TNFTP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TNFTP_DIR) $(TNFTP_BUILD_DIR) ; \
	fi
	(cd $(TNFTP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TNFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TNFTP_LDFLAGS)" \
                $(TNFTP_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(TNFTP_BUILD_DIR)/libtool
	touch $(TNFTP_BUILD_DIR)/.configured

tnftp-unpack: $(TNFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TNFTP_BUILD_DIR)/.built: $(TNFTP_BUILD_DIR)/.configured
	rm -f $(TNFTP_BUILD_DIR)/.built
	$(MAKE) -C $(TNFTP_BUILD_DIR)
	touch $(TNFTP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
tnftp: $(TNFTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TNFTP_BUILD_DIR)/.staged: $(TNFTP_BUILD_DIR)/.built
	rm -f $(TNFTP_BUILD_DIR)/.staged
	$(MAKE) -C $(TNFTP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(TNFTP_BUILD_DIR)/.staged

tnftp-stage: $(TNFTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tnftp
#
$(TNFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tnftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TNFTP_PRIORITY)" >>$@
	@echo "Section: $(TNFTP_SECTION)" >>$@
	@echo "Version: $(TNFTP_VERSION)-$(TNFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TNFTP_MAINTAINER)" >>$@
	@echo "Source: $(TNFTP_SITE)/$(TNFTP_SOURCE)" >>$@
	@echo "Description: $(TNFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(TNFTP_DEPENDS)" >>$@
	@echo "Suggests: $(TNFTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(TNFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TNFTP_IPK_DIR)/opt/sbin or $(TNFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TNFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TNFTP_IPK_DIR)/opt/etc/tnftp/...
# Documentation files should be installed in $(TNFTP_IPK_DIR)/opt/doc/tnftp/...
# Daemon startup scripts should be installed in $(TNFTP_IPK_DIR)/opt/etc/init.d/S??tnftp
#
# You may need to patch your application to make it use these locations.
#
$(TNFTP_IPK): $(TNFTP_BUILD_DIR)/.built
	rm -rf $(TNFTP_IPK_DIR) $(BUILD_DIR)/tnftp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TNFTP_BUILD_DIR) install \
		transform='s:^ftp:tnftp:' \
		prefix=$(TNFTP_IPK_DIR)/opt \
		mandircat1=$(TNFTP_IPK_DIR)/opt/share/man/man1 
	chmod +w $(TNFTP_IPK_DIR)/opt/bin/tnftp && \
	$(STRIP_COMMAND) $(TNFTP_IPK_DIR)/opt/bin/tnftp && \
	chmod -w $(TNFTP_IPK_DIR)/opt/bin/tnftp
#	install -d $(TNFTP_IPK_DIR)/opt/etc/
#	install -m 644 $(TNFTP_SOURCE_DIR)/tnftp.conf $(TNFTP_IPK_DIR)/opt/etc/tnftp.conf
#	install -d $(TNFTP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TNFTP_SOURCE_DIR)/rc.tnftp $(TNFTP_IPK_DIR)/opt/etc/init.d/SXXtnftp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXtnftp
	$(MAKE) $(TNFTP_IPK_DIR)/CONTROL/control
#	install -m 755 $(TNFTP_SOURCE_DIR)/postinst $(TNFTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TNFTP_SOURCE_DIR)/prerm $(TNFTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(TNFTP_CONFFILES) | sed -e 's/ /\n/g' > $(TNFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TNFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tnftp-ipk: $(TNFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tnftp-clean:
	rm -f $(TNFTP_BUILD_DIR)/.built
	-$(MAKE) -C $(TNFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tnftp-dirclean:
	rm -rf $(BUILD_DIR)/$(TNFTP_DIR) $(TNFTP_BUILD_DIR) $(TNFTP_IPK_DIR) $(TNFTP_IPK)
#
#
# Some sanity check for the package.
#
tnftp-check: $(TNFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TNFTP_IPK)
