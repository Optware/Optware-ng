###########################################################
#
# up-imapproxy
#
###########################################################

# You must replace "up-imapproxy" and "UP-IMAPPROXY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# UP-IMAPPROXY_VERSION, UP-IMAPPROXY_SITE and UP-IMAPPROXY_SOURCE define
# the upstream location of the source code for the package.
# UP-IMAPPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# UP-IMAPPROXY_UNZIP is the command used to unzip the source.
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
UP-IMAPPROXY_SITE=http://www.imapproxy.org/downloads
UP-IMAPPROXY_VERSION=1.2.5rc2
UP-IMAPPROXY_SOURCE=up-imapproxy-$(UP-IMAPPROXY_VERSION).tar.gz
UP-IMAPPROXY_DIR=up-imapproxy-$(UP-IMAPPROXY_VERSION)
UP-IMAPPROXY_UNZIP=zcat
UP-IMAPPROXY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UP-IMAPPROXY_DESCRIPTION=proxies IMAP transactions between an IMAP client and an IMAP server
UP-IMAPPROXY_SECTION=mail
UP-IMAPPROXY_PRIORITY=optional
UP-IMAPPROXY_DEPENDS=ncurses openssl
UP-IMAPPROXY_SUGGESTS=cyrus-imapd
UP-IMAPPROXY_CONFLICTS=

#
# UP-IMAPPROXY_IPK_VERSION should be incremented when the ipk changes.
#
UP-IMAPPROXY_IPK_VERSION=1

#
# UP-IMAPPROXY_CONFFILES should be a list of user-editable files
UP-IMAPPROXY_CONFFILES=/opt/etc/imapproxy.conf /opt/etc/init.d/S60imapproxy

#
# UP-IMAPPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UP-IMAPPROXY_PATCHES=$(UP-IMAPPROXY_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UP-IMAPPROXY_CPPFLAGS=-I $(STAGING_INCLUDE_DIR)/ncurses
UP-IMAPPROXY_LDFLAGS=

#
# UP-IMAPPROXY_BUILD_DIR is the directory in which the build is done.
# UP-IMAPPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UP-IMAPPROXY_IPK_DIR is the directory in which the ipk is built.
# UP-IMAPPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UP-IMAPPROXY_BUILD_DIR=$(BUILD_DIR)/up-imapproxy
UP-IMAPPROXY_SOURCE_DIR=$(SOURCE_DIR)/up-imapproxy
UP-IMAPPROXY_IPK_DIR=$(BUILD_DIR)/up-imapproxy-$(UP-IMAPPROXY_VERSION)-ipk
UP-IMAPPROXY_IPK=$(BUILD_DIR)/up-imapproxy_$(UP-IMAPPROXY_VERSION)-$(UP-IMAPPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: up-imapproxy-source up-imapproxy-unpack up-imapproxy up-imapproxy-stage up-imapproxy-ipk up-imapproxy-clean up-imapproxy-dirclean up-imapproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UP-IMAPPROXY_SOURCE):
	$(WGET) -P $(DL_DIR) $(UP-IMAPPROXY_SITE)/$(UP-IMAPPROXY_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UP-IMAPPROXY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
up-imapproxy-source: $(DL_DIR)/$(UP-IMAPPROXY_SOURCE) $(UP-IMAPPROXY_PATCHES)

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
$(UP-IMAPPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(UP-IMAPPROXY_SOURCE) $(UP-IMAPPROXY_PATCHES) make/up-imapproxy.mk
	$(MAKE) ncurses-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(UP-IMAPPROXY_DIR) $(UP-IMAPPROXY_BUILD_DIR)
	$(UP-IMAPPROXY_UNZIP) $(DL_DIR)/$(UP-IMAPPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UP-IMAPPROXY_PATCHES)" ; \
		then cat $(UP-IMAPPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UP-IMAPPROXY_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(UP-IMAPPROXY_DIR)" != "$(UP-IMAPPROXY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UP-IMAPPROXY_DIR) $(UP-IMAPPROXY_BUILD_DIR) ; \
	fi
	(cd $(UP-IMAPPROXY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UP-IMAPPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UP-IMAPPROXY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(UP-IMAPPROXY_BUILD_DIR)/libtool
	touch $@

up-imapproxy-unpack: $(UP-IMAPPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UP-IMAPPROXY_BUILD_DIR)/.built: $(UP-IMAPPROXY_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UP-IMAPPROXY_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
up-imapproxy: $(UP-IMAPPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UP-IMAPPROXY_BUILD_DIR)/.staged: $(UP-IMAPPROXY_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UP-IMAPPROXY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

up-imapproxy-stage: $(UP-IMAPPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/up-imapproxy
#
$(UP-IMAPPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: up-imapproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UP-IMAPPROXY_PRIORITY)" >>$@
	@echo "Section: $(UP-IMAPPROXY_SECTION)" >>$@
	@echo "Version: $(UP-IMAPPROXY_VERSION)-$(UP-IMAPPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UP-IMAPPROXY_MAINTAINER)" >>$@
	@echo "Source: $(UP-IMAPPROXY_SITE)/$(UP-IMAPPROXY_SOURCE)" >>$@
	@echo "Description: $(UP-IMAPPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(UP-IMAPPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(UP-IMAPPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(UP-IMAPPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UP-IMAPPROXY_IPK_DIR)/opt/sbin or $(UP-IMAPPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UP-IMAPPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UP-IMAPPROXY_IPK_DIR)/opt/etc/up-imapproxy/...
# Documentation files should be installed in $(UP-IMAPPROXY_IPK_DIR)/opt/doc/up-imapproxy/...
# Daemon startup scripts should be installed in $(UP-IMAPPROXY_IPK_DIR)/opt/etc/init.d/S??up-imapproxy
#
# You may need to patch your application to make it use these locations.
#
$(UP-IMAPPROXY_IPK): $(UP-IMAPPROXY_BUILD_DIR)/.built
	rm -rf $(UP-IMAPPROXY_IPK_DIR) $(BUILD_DIR)/up-imapproxy_*_$(TARGET_ARCH).ipk
	install -d $(UP-IMAPPROXY_IPK_DIR)/opt/sbin/
	install -m 0755 $(UP-IMAPPROXY_BUILD_DIR)/bin/* $(UP-IMAPPROXY_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(UP-IMAPPROXY_IPK_DIR)/opt/sbin/*
	install -d $(UP-IMAPPROXY_IPK_DIR)/opt/etc/
	install -m 644 $(UP-IMAPPROXY_BUILD_DIR)/scripts/imapproxy.conf $(UP-IMAPPROXY_IPK_DIR)/opt/etc/imapproxy.conf
	install -d $(UP-IMAPPROXY_IPK_DIR)/opt/etc/init.d
	install -m 755 $(UP-IMAPPROXY_SOURCE_DIR)/imapproxy.init $(UP-IMAPPROXY_IPK_DIR)/opt/etc/init.d/S60imapproxy
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UP-IMAPPROXY_IPK_DIR)/opt/etc/init.d/S60imapproxy
	$(MAKE) $(UP-IMAPPROXY_IPK_DIR)/CONTROL/control
#	install -m 755 $(UP-IMAPPROXY_SOURCE_DIR)/postinst $(UP-IMAPPROXY_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UP-IMAPPROXY_SOURCE_DIR)/prerm $(UP-IMAPPROXY_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(UP-IMAPPROXY_CONFFILES) | sed -e 's/ /\n/g' > $(UP-IMAPPROXY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UP-IMAPPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
up-imapproxy-ipk: $(UP-IMAPPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
up-imapproxy-clean:
	rm -f $(UP-IMAPPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(UP-IMAPPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
up-imapproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(UP-IMAPPROXY_DIR) $(UP-IMAPPROXY_BUILD_DIR) $(UP-IMAPPROXY_IPK_DIR) $(UP-IMAPPROXY_IPK)
#
#
# Some sanity check for the package.
#
up-imapproxy-check: $(UP-IMAPPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UP-IMAPPROXY_IPK)
