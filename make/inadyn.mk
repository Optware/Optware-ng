###########################################################
#
# inadyn
#
###########################################################
#
# INADYN_VERSION, INADYN_SITE and INADYN_SOURCE define
# the upstream location of the source code for the package.
# INADYN_DIR is the directory which is created when the source
# archive is unpacked.
# INADYN_UNZIP is the command used to unzip the source.
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
INADYN_SITE=ftp://ftp.FreeBSD.org/pub/FreeBSD/ports/distfiles
INADYN_VERSION=1.96.2
INADYN_SOURCE=inadyn.v$(INADYN_VERSION).zip
INADYN_DIR=inadyn
INADYN_UNZIP=unzip
INADYN_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INADYN_DESCRIPTION=INADYN is a dynamic DNS client. That is, it maintains the IP address of a host name. It periodically checks whether the IP address stored by the DNS server is the real current address of the machine that is running INADYN.
INADYN_SECTION=net
INADYN_PRIORITY=optional
INADYN_DEPENDS=
INADYN_SUGGESTS=
INADYN_CONFLICTS=

#
# INADYN_IPK_VERSION should be incremented when the ipk changes.
#
INADYN_IPK_VERSION=2

#
# INADYN_CONFFILES should be a list of user-editable files
#INADYN_CONFFILES=/opt/etc/inadyn.conf /opt/etc/init.d/SXXinadyn

#
# INADYN_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#INADYN_PATCHES=$(INADYN_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INADYN_CPPFLAGS=
INADYN_LDFLAGS=

#
# INADYN_BUILD_DIR is the directory in which the build is done.
# INADYN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INADYN_IPK_DIR is the directory in which the ipk is built.
# INADYN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INADYN_BUILD_DIR=$(BUILD_DIR)/inadyn
INADYN_SOURCE_DIR=$(SOURCE_DIR)/inadyn
INADYN_IPK_DIR=$(BUILD_DIR)/inadyn-$(INADYN_VERSION)-ipk
INADYN_IPK=$(BUILD_DIR)/inadyn_$(INADYN_VERSION)-$(INADYN_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: inadyn-source inadyn-unpack inadyn inadyn-stage inadyn-ipk inadyn-clean inadyn-dirclean inadyn-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INADYN_SOURCE):
	$(WGET) -P $(DL_DIR) $(INADYN_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
inadyn-source: $(DL_DIR)/$(INADYN_SOURCE) $(INADYN_PATCHES)

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
$(INADYN_BUILD_DIR)/.configured: $(DL_DIR)/$(INADYN_SOURCE) $(INADYN_PATCHES) make/inadyn.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(INADYN_DIR) $(INADYN_BUILD_DIR)
	cd $(BUILD_DIR) && $(INADYN_UNZIP) $(DL_DIR)/$(INADYN_SOURCE)
	if test -n "$(INADYN_PATCHES)" ; \
		then cat $(INADYN_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INADYN_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(INADYN_DIR)" != "$(INADYN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(INADYN_DIR) $(INADYN_BUILD_DIR) ; \
	fi
	sed -i -e 's|/etc/inadyn.conf|/opt&|' $(@D)/man/inadyn.8 $(@D)/readme.html $(@D)/src/dyndns.h
	sed -i -e '/^COMPILE=/s|=gcc |=$$(CC) $$(CPPFLAGS) |' \
	       -e '/^LINK=/s|=gcc |=$$(CC) $$(LDFLAGS) |' \
		$(INADYN_BUILD_DIR)/makefile
#	(cd $(INADYN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INADYN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INADYN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(INADYN_BUILD_DIR)/libtool
	touch $@

inadyn-unpack: $(INADYN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INADYN_BUILD_DIR)/.built: $(INADYN_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(INADYN_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INADYN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INADYN_LDFLAGS)" \
		TARGET_ARCH=linux
	touch $@

#
# This is the build convenience target.
#
inadyn: $(INADYN_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(INADYN_BUILD_DIR)/.staged: $(INADYN_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(INADYN_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

#inadyn-stage: $(INADYN_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/inadyn
#
$(INADYN_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: inadyn" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INADYN_PRIORITY)" >>$@
	@echo "Section: $(INADYN_SECTION)" >>$@
	@echo "Version: $(INADYN_VERSION)-$(INADYN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INADYN_MAINTAINER)" >>$@
	@echo "Source: $(INADYN_SITE)/$(INADYN_SOURCE)" >>$@
	@echo "Description: $(INADYN_DESCRIPTION)" >>$@
	@echo "Depends: $(INADYN_DEPENDS)" >>$@
	@echo "Suggests: $(INADYN_SUGGESTS)" >>$@
	@echo "Conflicts: $(INADYN_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INADYN_IPK_DIR)/opt/sbin or $(INADYN_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INADYN_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INADYN_IPK_DIR)/opt/etc/inadyn/...
# Documentation files should be installed in $(INADYN_IPK_DIR)/opt/doc/inadyn/...
# Daemon startup scripts should be installed in $(INADYN_IPK_DIR)/opt/etc/init.d/S??inadyn
#
# You may need to patch your application to make it use these locations.
#
$(INADYN_IPK): $(INADYN_BUILD_DIR)/.built
	rm -rf $(INADYN_IPK_DIR) $(BUILD_DIR)/inadyn_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(INADYN_BUILD_DIR) DESTDIR=$(INADYN_IPK_DIR) install-strip
	install -d $(INADYN_IPK_DIR)/opt/bin
	install -m 755 $(INADYN_BUILD_DIR)/bin/linux/inadyn $(INADYN_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(INADYN_IPK_DIR)/opt/bin/inadyn
	install -d $(INADYN_IPK_DIR)/opt/man/man5
	install -m 644 $(INADYN_BUILD_DIR)/man/*.5 $(INADYN_IPK_DIR)/opt/man/man5
	install -d $(INADYN_IPK_DIR)/opt/man/man8
	install -m 644 $(INADYN_BUILD_DIR)/man/*.8 $(INADYN_IPK_DIR)/opt/man/man8
	install -d $(INADYN_IPK_DIR)/opt/share/doc/inadyn
	install -m 644 $(INADYN_BUILD_DIR)/readme.html $(INADYN_IPK_DIR)/opt/share/doc/inadyn
#	install -d $(INADYN_IPK_DIR)/opt/etc/
#	install -m 644 $(INADYN_SOURCE_DIR)/inadyn.conf $(INADYN_IPK_DIR)/opt/etc/inadyn.conf
	$(MAKE) $(INADYN_IPK_DIR)/CONTROL/control
#	install -m 755 $(INADYN_SOURCE_DIR)/postinst $(INADYN_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(INADYN_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(INADYN_SOURCE_DIR)/prerm $(INADYN_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(INADYN_IPK_DIR)/CONTROL/prerm
	echo $(INADYN_CONFFILES) | sed -e 's/ /\n/g' > $(INADYN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INADYN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
inadyn-ipk: $(INADYN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
inadyn-clean:
	rm -f $(INADYN_BUILD_DIR)/.built
	-$(MAKE) -C $(INADYN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
inadyn-dirclean:
	rm -rf $(BUILD_DIR)/$(INADYN_DIR) $(INADYN_BUILD_DIR) $(INADYN_IPK_DIR) $(INADYN_IPK)
#
#
# Some sanity check for the package.
#
inadyn-check: $(INADYN_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(INADYN_IPK)
