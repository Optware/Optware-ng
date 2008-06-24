###########################################################
#
# rtpproxy
#
###########################################################
#
# RTPPROXY_VERSION, RTPPROXY_SITE and RTPPROXY_SOURCE define
# the upstream location of the source code for the package.
# RTPPROXY_DIR is the directory which is created when the source
# archive is unpacked.
# RTPPROXY_UNZIP is the command used to unzip the source.
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
RTPPROXY_SITE=http://b2bua.org/chrome/site
RTPPROXY_VERSION=1.1
RTPPROXY_SOURCE=rtpproxy-$(RTPPROXY_VERSION).tar.gz
RTPPROXY_DIR=rtpproxy-$(RTPPROXY_VERSION)
RTPPROXY_UNZIP=zcat
RTPPROXY_MAINTAINER=Ovidiu Sas <osas@voipembedded.com>
RTPPROXY_DESCRIPTION=RTPproxy is a proxy for RTP streams that can help SER/OpenSER \
handle NAT situations, as well as proxy IP telephony between IPv4 and IPv6 networks.
RTPPROXY_SECTION=util
RTPPROXY_PRIORITY=optional
RTPPROXY_DEPENDS=
RTPPROXY_SUGGESTS=
RTPPROXY_CONFLICTS=

#
# RTPPROXY_IPK_VERSION should be incremented when the ipk changes.
#
RTPPROXY_IPK_VERSION=1

#
# RTPPROXY_CONFFILES should be a list of user-editable files
#RTPPROXY_CONFFILES=/opt/etc/rtpproxy.conf /opt/etc/init.d/SXXrtpproxy

#
# RTPPROXY_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RTPPROXY_PATCHES=$(RTPPROXY_SOURCE_DIR)/rtpproxy.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RTPPROXY_CPPFLAGS=-fsigned-char
RTPPROXY_LDFLAGS=

#
# RTPPROXY_BUILD_DIR is the directory in which the build is done.
# RTPPROXY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RTPPROXY_IPK_DIR is the directory in which the ipk is built.
# RTPPROXY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RTPPROXY_BUILD_DIR=$(BUILD_DIR)/rtpproxy
RTPPROXY_SOURCE_DIR=$(SOURCE_DIR)/rtpproxy
RTPPROXY_IPK_DIR=$(BUILD_DIR)/rtpproxy-$(RTPPROXY_VERSION)-ipk
RTPPROXY_IPK=$(BUILD_DIR)/rtpproxy_$(RTPPROXY_VERSION)-$(RTPPROXY_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rtpproxy-source rtpproxy-unpack rtpproxy rtpproxy-stage rtpproxy-ipk rtpproxy-clean rtpproxy-dirclean rtpproxy-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RTPPROXY_SOURCE):
	$(WGET) -P $(DL_DIR) $(RTPPROXY_SITE)/$(RTPPROXY_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rtpproxy-source: $(DL_DIR)/$(RTPPROXY_SOURCE) $(RTPPROXY_PATCHES)

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
$(RTPPROXY_BUILD_DIR)/.configured: $(DL_DIR)/$(RTPPROXY_SOURCE) $(RTPPROXY_PATCHES) make/rtpproxy.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(RTPPROXY_DIR) $(RTPPROXY_BUILD_DIR)
	$(RTPPROXY_UNZIP) $(DL_DIR)/$(RTPPROXY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RTPPROXY_PATCHES)" ; \
		then cat $(RTPPROXY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RTPPROXY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RTPPROXY_DIR)" != "$(RTPPROXY_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RTPPROXY_DIR) $(RTPPROXY_BUILD_DIR) ; \
	fi
	(cd $(RTPPROXY_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RTPPROXY_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RTPPROXY_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $(RTPPROXY_BUILD_DIR)/.configured

rtpproxy-unpack: $(RTPPROXY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RTPPROXY_BUILD_DIR)/.built: $(RTPPROXY_BUILD_DIR)/.configured
	rm -f $(RTPPROXY_BUILD_DIR)/.built
	$(MAKE) -C $(RTPPROXY_BUILD_DIR)
	touch $(RTPPROXY_BUILD_DIR)/.built

#
# This is the build convenience target.
#
rtpproxy: $(RTPPROXY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RTPPROXY_BUILD_DIR)/.staged: $(RTPPROXY_BUILD_DIR)/.built
	rm -f $(RTPPROXY_BUILD_DIR)/.staged
	$(MAKE) -C $(RTPPROXY_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(RTPPROXY_BUILD_DIR)/.staged

rtpproxy-stage: $(RTPPROXY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rtpproxy
#
$(RTPPROXY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rtpproxy" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RTPPROXY_PRIORITY)" >>$@
	@echo "Section: $(RTPPROXY_SECTION)" >>$@
	@echo "Version: $(RTPPROXY_VERSION)-$(RTPPROXY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RTPPROXY_MAINTAINER)" >>$@
	@echo "Source: $(RTPPROXY_SITE)/$(RTPPROXY_SOURCE)" >>$@
	@echo "Description: $(RTPPROXY_DESCRIPTION)" >>$@
	@echo "Depends: $(RTPPROXY_DEPENDS)" >>$@
	@echo "Suggests: $(RTPPROXY_SUGGESTS)" >>$@
	@echo "Conflicts: $(RTPPROXY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RTPPROXY_IPK_DIR)/opt/sbin or $(RTPPROXY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RTPPROXY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RTPPROXY_IPK_DIR)/opt/etc/rtpproxy/...
# Documentation files should be installed in $(RTPPROXY_IPK_DIR)/opt/doc/rtpproxy/...
# Daemon startup scripts should be installed in $(RTPPROXY_IPK_DIR)/opt/etc/init.d/S??rtpproxy
#
# You may need to patch your application to make it use these locations.
#
$(RTPPROXY_IPK): $(RTPPROXY_BUILD_DIR)/.built
	rm -rf $(RTPPROXY_IPK_DIR) $(BUILD_DIR)/rtpproxy_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RTPPROXY_BUILD_DIR) DESTDIR=$(RTPPROXY_IPK_DIR) install-strip
	$(MAKE) $(RTPPROXY_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RTPPROXY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rtpproxy-ipk: $(RTPPROXY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rtpproxy-clean:
	rm -f $(RTPPROXY_BUILD_DIR)/.built
	-$(MAKE) -C $(RTPPROXY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rtpproxy-dirclean:
	rm -rf $(BUILD_DIR)/$(RTPPROXY_DIR) $(RTPPROXY_BUILD_DIR) $(RTPPROXY_IPK_DIR) $(RTPPROXY_IPK)
#
#
# Some sanity check for the package.
#
rtpproxy-check: $(RTPPROXY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RTPPROXY_IPK)
