###########################################################
#
# arping
#
###########################################################
#
# ARPING_VERSION, ARPING_SITE and ARPING_SOURCE define
# the upstream location of the source code for the package.
# ARPING_DIR is the directory which is created when the source
# archive is unpacked.
# ARPING_UNZIP is the command used to unzip the source.
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
ARPING_SITE=ftp://ftp.habets.pp.se/pub/synscan
ARPING_VERSION=2.08
ARPING_SOURCE=arping-$(ARPING_VERSION).tar.gz
ARPING_DIR=arping-$(ARPING_VERSION)
ARPING_UNZIP=zcat
ARPING_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ARPING_DESCRIPTION=Arping is an ARP level ping utility.
ARPING_SECTION=net
ARPING_PRIORITY=optional
ARPING_DEPENDS=libpcap
ARPING_SUGGESTS=
ARPING_CONFLICTS=

#
# ARPING_IPK_VERSION should be incremented when the ipk changes.
#
ARPING_IPK_VERSION=2

#
# ARPING_CONFFILES should be a list of user-editable files
#ARPING_CONFFILES=/opt/etc/arping.conf /opt/etc/init.d/SXXarping

#
# ARPING_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ARPING_PATCHES=$(ARPING_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ARPING_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libnet11
ARPING_LDFLAGS=-L$(STAGING_LIB_DIR)/libnet11

#
# ARPING_BUILD_DIR is the directory in which the build is done.
# ARPING_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ARPING_IPK_DIR is the directory in which the ipk is built.
# ARPING_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ARPING_BUILD_DIR=$(BUILD_DIR)/arping
ARPING_SOURCE_DIR=$(SOURCE_DIR)/arping
ARPING_IPK_DIR=$(BUILD_DIR)/arping-$(ARPING_VERSION)-ipk
ARPING_IPK=$(BUILD_DIR)/arping_$(ARPING_VERSION)-$(ARPING_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: arping-source arping-unpack arping arping-stage arping-ipk arping-clean arping-dirclean arping-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ARPING_SOURCE):
	$(WGET) -P $(@D) $(ARPING_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
arping-source: $(DL_DIR)/$(ARPING_SOURCE) $(ARPING_PATCHES)

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
$(ARPING_BUILD_DIR)/.configured: $(DL_DIR)/$(ARPING_SOURCE) $(ARPING_PATCHES) make/arping.mk
	$(MAKE) libnet11-stage libpcap-stage
	rm -rf $(BUILD_DIR)/$(ARPING_DIR) $(@D)
	$(ARPING_UNZIP) $(DL_DIR)/$(ARPING_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ARPING_PATCHES)" ; \
		then cat $(ARPING_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ARPING_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ARPING_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ARPING_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ARPING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ARPING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

arping-unpack: $(ARPING_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ARPING_BUILD_DIR)/.built: $(ARPING_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) arping2 \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS2="$(ARPING_CPPFLAGS) $(STAGING_CPPFLAGS)" \
		LDFLAGS2="$(ARPING_LDFLAGS) $(STAGING_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
arping: $(ARPING_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ARPING_BUILD_DIR)/.staged: $(ARPING_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

arping-stage: $(ARPING_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/arping
#
$(ARPING_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: arping" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ARPING_PRIORITY)" >>$@
	@echo "Section: $(ARPING_SECTION)" >>$@
	@echo "Version: $(ARPING_VERSION)-$(ARPING_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ARPING_MAINTAINER)" >>$@
	@echo "Source: $(ARPING_SITE)/$(ARPING_SOURCE)" >>$@
	@echo "Description: $(ARPING_DESCRIPTION)" >>$@
	@echo "Depends: $(ARPING_DEPENDS)" >>$@
	@echo "Suggests: $(ARPING_SUGGESTS)" >>$@
	@echo "Conflicts: $(ARPING_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ARPING_IPK_DIR)/opt/sbin or $(ARPING_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ARPING_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ARPING_IPK_DIR)/opt/etc/arping/...
# Documentation files should be installed in $(ARPING_IPK_DIR)/opt/doc/arping/...
# Daemon startup scripts should be installed in $(ARPING_IPK_DIR)/opt/etc/init.d/S??arping
#
# You may need to patch your application to make it use these locations.
#
$(ARPING_IPK): $(ARPING_BUILD_DIR)/.built
	rm -rf $(ARPING_IPK_DIR) $(BUILD_DIR)/arping_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(ARPING_BUILD_DIR) DESTDIR=$(ARPING_IPK_DIR) install-strip
	install -d $(ARPING_IPK_DIR)/opt/sbin $(ARPING_IPK_DIR)/opt/share/man/man8
	install $(ARPING_BUILD_DIR)/arping $(ARPING_IPK_DIR)/opt/sbin/
	install $(ARPING_BUILD_DIR)/arping-scan-net.sh $(ARPING_IPK_DIR)/opt/sbin/
	$(STRIP_COMMAND) $(ARPING_IPK_DIR)/opt/sbin/arping
	install $(ARPING_BUILD_DIR)/arping.8 $(ARPING_IPK_DIR)/opt/share/man/man8/
	$(MAKE) $(ARPING_IPK_DIR)/CONTROL/control
	echo $(ARPING_CONFFILES) | sed -e 's/ /\n/g' > $(ARPING_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ARPING_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
arping-ipk: $(ARPING_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
arping-clean:
	rm -f $(ARPING_BUILD_DIR)/.built
	-$(MAKE) -C $(ARPING_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
arping-dirclean:
	rm -rf $(BUILD_DIR)/$(ARPING_DIR) $(ARPING_BUILD_DIR) $(ARPING_IPK_DIR) $(ARPING_IPK)
#
#
# Some sanity check for the package.
#
arping-check: $(ARPING_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
