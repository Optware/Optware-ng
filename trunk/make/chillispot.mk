###########################################################
#
# chillispot
#
###########################################################

# You must replace "chillispot" and "CHILLISPOT" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CHILLISPOT_VERSION, CHILLISPOT_SITE and CHILLISPOT_SOURCE define
# the upstream location of the source code for the package.
# CHILLISPOT_DIR is the directory which is created when the source
# archive is unpacked.
# CHILLISPOT_UNZIP is the command used to unzip the source.
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
CHILLISPOT_SITE=http://www.chillispot.org/download
CHILLISPOT_VERSION=1.0RC3
CHILLISPOT_SOURCE=chillispot-$(CHILLISPOT_VERSION).tar.gz
CHILLISPOT_DIR=chillispot-$(CHILLISPOT_VERSION)
CHILLISPOT_UNZIP=zcat
CHILLISPOT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CHILLISPOT_DESCRIPTION=ChilliSpot is an open source captive portal or wireless LAN access point controller.
CHILLISPOT_SECTION=net
CHILLISPOT_PRIORITY=optional
CHILLISPOT_DEPENDS=
CHILLISPOT_CONFLICTS=

#
# CHILLISPOT_IPK_VERSION should be incremented when the ipk changes.
#
CHILLISPOT_IPK_VERSION=2

#
# CHILLISPOT_CONFFILES should be a list of user-editable files
CHILLISPOT_CONFFILES=/opt/etc/chilli.conf /opt/etc/init.d/S80chillispot

#
# CHILLISPOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CHILLISPOT_PATCHES=$(CHILLISPOT_SOURCE_DIR)/configure.patch $(CHILLISPOT_SOURCE_DIR)/chillispot.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CHILLISPOT_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter slugosbe mssii cs05q3armel, $(OPTWARE_TARGET)))
# ugly hack to get around kernel header linux/rtnetlink.h problem
# see http://www.mail-archive.com/netdev@vger.kernel.org/msg28685.html
CHILLISPOT_CPPFLAGS+=-U__STRICT_ANSI__
endif
CHILLISPOT_LDFLAGS=

#
# CHILLISPOT_BUILD_DIR is the directory in which the build is done.
# CHILLISPOT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CHILLISPOT_IPK_DIR is the directory in which the ipk is built.
# CHILLISPOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CHILLISPOT_BUILD_DIR=$(BUILD_DIR)/chillispot
CHILLISPOT_SOURCE_DIR=$(SOURCE_DIR)/chillispot
CHILLISPOT_IPK_DIR=$(BUILD_DIR)/chillispot-$(CHILLISPOT_VERSION)-ipk
CHILLISPOT_IPK=$(BUILD_DIR)/chillispot_$(CHILLISPOT_VERSION)-$(CHILLISPOT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: chillispot-source chillispot-unpack chillispot chillispot-stage chillispot-ipk chillispot-clean chillispot-dirclean chillispot-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CHILLISPOT_SOURCE):
	$(WGET) -P $(DL_DIR) $(CHILLISPOT_SITE)/$(CHILLISPOT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
chillispot-source: $(DL_DIR)/$(CHILLISPOT_SOURCE) $(CHILLISPOT_PATCHES)

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
$(CHILLISPOT_BUILD_DIR)/.configured: $(DL_DIR)/$(CHILLISPOT_SOURCE) $(CHILLISPOT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CHILLISPOT_DIR) $(CHILLISPOT_BUILD_DIR)
	$(CHILLISPOT_UNZIP) $(DL_DIR)/$(CHILLISPOT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CHILLISPOT_PATCHES)"; \
		then cat $(CHILLISPOT_PATCHES) | patch -d $(BUILD_DIR)/$(CHILLISPOT_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(CHILLISPOT_DIR) $(CHILLISPOT_BUILD_DIR)
	(cd $(CHILLISPOT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CHILLISPOT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CHILLISPOT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(CHILLISPOT_BUILD_DIR)/libtool
	touch $(CHILLISPOT_BUILD_DIR)/.configured

chillispot-unpack: $(CHILLISPOT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CHILLISPOT_BUILD_DIR)/.built: $(CHILLISPOT_BUILD_DIR)/.configured
	rm -f $(CHILLISPOT_BUILD_DIR)/.built
	$(MAKE) -C $(CHILLISPOT_BUILD_DIR)
	touch $(CHILLISPOT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
chillispot: $(CHILLISPOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CHILLISPOT_BUILD_DIR)/.staged: $(CHILLISPOT_BUILD_DIR)/.built
	rm -f $(CHILLISPOT_BUILD_DIR)/.staged
	$(MAKE) -C $(CHILLISPOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(CHILLISPOT_BUILD_DIR)/.staged

chillispot-stage: $(CHILLISPOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/chillispot
#
$(CHILLISPOT_IPK_DIR)/CONTROL/control:
	@install -d $(CHILLISPOT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: chillispot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CHILLISPOT_PRIORITY)" >>$@
	@echo "Section: $(CHILLISPOT_SECTION)" >>$@
	@echo "Version: $(CHILLISPOT_VERSION)-$(CHILLISPOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CHILLISPOT_MAINTAINER)" >>$@
	@echo "Source: $(CHILLISPOT_SITE)/$(CHILLISPOT_SOURCE)" >>$@
	@echo "Description: $(CHILLISPOT_DESCRIPTION)" >>$@
	@echo "Depends: $(CHILLISPOT_DEPENDS)" >>$@
	@echo "Conflicts: $(CHILLISPOT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CHILLISPOT_IPK_DIR)/opt/sbin or $(CHILLISPOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CHILLISPOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CHILLISPOT_IPK_DIR)/opt/etc/chillispot/...
# Documentation files should be installed in $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/...
# Daemon startup scripts should be installed in $(CHILLISPOT_IPK_DIR)/opt/etc/init.d/S??chillispot
#
# You may need to patch your application to make it use these locations.
#
$(CHILLISPOT_IPK): $(CHILLISPOT_BUILD_DIR)/.built
	rm -rf $(CHILLISPOT_IPK_DIR) $(BUILD_DIR)/chillispot_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CHILLISPOT_BUILD_DIR) DESTDIR=$(CHILLISPOT_IPK_DIR) install
	$(STRIP_COMMAND) $(CHILLISPOT_IPK_DIR)/opt/sbin/chilli
	install -d $(CHILLISPOT_IPK_DIR)/opt/etc/
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/chilli.conf $(CHILLISPOT_IPK_DIR)/opt/etc/chilli.conf
	install -d $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/hotspotlogin.cgi $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/hotspotlogin.cgi
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/firewall.iptables $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/firewall.iptables
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/firewall.openwrt $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/firewall.openwrt
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/freeradius.users $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/freeradius.users
	install -m 644 $(CHILLISPOT_SOURCE_DIR)/dictionary.chillispot $(CHILLISPOT_IPK_DIR)/opt/doc/chillispot/dictionary.chillispot
	install -d $(CHILLISPOT_IPK_DIR)/opt/var/lib/chilli
	install -d $(CHILLISPOT_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CHILLISPOT_SOURCE_DIR)/rc.chilli $(CHILLISPOT_IPK_DIR)/opt/etc/init.d/S80chillispot
	$(MAKE) $(CHILLISPOT_IPK_DIR)/CONTROL/control
	install -m 755 $(CHILLISPOT_SOURCE_DIR)/postinst $(CHILLISPOT_IPK_DIR)/CONTROL/postinst
	install -m 755 $(CHILLISPOT_SOURCE_DIR)/prerm $(CHILLISPOT_IPK_DIR)/CONTROL/prerm
	echo $(CHILLISPOT_CONFFILES) | sed -e 's/ /\n/g' > $(CHILLISPOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CHILLISPOT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
chillispot-ipk: $(CHILLISPOT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
chillispot-clean:
	-$(MAKE) -C $(CHILLISPOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
chillispot-dirclean:
	rm -rf $(BUILD_DIR)/$(CHILLISPOT_DIR) $(CHILLISPOT_BUILD_DIR) $(CHILLISPOT_IPK_DIR) $(CHILLISPOT_IPK)

#
# Some sanity check for the package.
#
chillispot-check: $(CHILLISPOT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CHILLISPOT_IPK)
