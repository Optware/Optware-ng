###########################################################
#
# knock
# 
###########################################################
#
KNOCK_SITE=http://www.zeroflux.org/knock/files
KNOCK_VERSION=0.5
KNOCK_SOURCE=knock-$(KNOCK_VERSION).tar.gz
KNOCK_DIR=knock-$(KNOCK_VERSION)
KNOCK_UNZIP=zcat
KNOCK_MAINTAINER=Don Lubinski <nlsu2@shine-hs.com>
KNOCK_DESCRIPTION=knockd is a port-knock server. It listens to all traffic on an ethernet (or PPP) interface, looking for special "knock" sequences of port-hits. A client makes these port-hits by sending a TCP (or UDP) packet to a port on the server. This port need not be open -- since knockd listens at the link-layer level, it sees all traffic even if it is destined for a closed port. When the server detects a specific sequence of port-hits, it runs a command defined in its configuration file. This can be used to open up holes in a firewall for quick access.
KNOCK_SECTION=security
KNOCK_DEPENDS=libpcap
KNOCK_PRIORITY=optional

#
# KNOCK_IPK_VERSION should be incremented when the ipk changes.
#
KNOCK_IPK_VERSION=4

#
# KNOCK_CONFFILES should be a list of user-editable files
KNOCK_CONFFILES=/opt/etc/knockd.conf /opt/etc/init.d/S05knockd


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
KNOCK_CPPFLAGS=
KNOCK_LDFLAGS=

#
# KNOCK_BUILD_DIR is the directory in which the build is done.
# KNOCK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# KNOCK_IPK_DIR is the directory in which the ipk is built.
# KNOCK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
KNOCK_BUILD_DIR=$(BUILD_DIR)/knock
KNOCK_SOURCE_DIR=$(SOURCE_DIR)/knock
KNOCK_IPK_DIR=$(BUILD_DIR)/knock-$(KNOCK_VERSION)-ipk
KNOCK_IPK=$(BUILD_DIR)/knock_$(KNOCK_VERSION)-$(KNOCK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: knock-source knock-unpack knock knock-stage knock-ipk knock-clean knock-dirclean knock-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(KNOCK_SOURCE):
	$(WGET) -P $(@D) $(KNOCK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
knock-source: $(DL_DIR)/$(KNOCK_SOURCE) 

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
$(KNOCK_BUILD_DIR)/.configured: $(DL_DIR)/$(KNOCK_SOURCE) make/knock.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(KNOCK_DIR) $(@D)
	$(KNOCK_UNZIP) $(DL_DIR)/$(KNOCK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(KNOCK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(KNOCK_DIR) $(@D) ; \
	fi
	sed -i -e 's|/etc/knockd.conf|/opt&|' $(@D)/src/knockd.c
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(KNOCK_CPPFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(KNOCK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(KNOCK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc \
		--disable-nls \
		--disable-static \
	)
	touch $@

knock-unpack: $(KNOCK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(KNOCK_BUILD_DIR)/.built: $(KNOCK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
knock: $(KNOCK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(KNOCK_BUILD_DIR)/.staged: $(KNOCK_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

knock-stage: $(KNOCK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/knock
#
$(KNOCK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: knock" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(KNOCK_PRIORITY)" >>$@
	@echo "Section: $(KNOCK_SECTION)" >>$@
	@echo "Version: $(KNOCK_VERSION)-$(KNOCK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(KNOCK_MAINTAINER)" >>$@
	@echo "Source: $(KNOCK_SITE)/$(KNOCK_SOURCE)" >>$@
	@echo "Description: $(KNOCK_DESCRIPTION)" >>$@
	@echo "Depends: $(KNOCK_DEPENDS)" >>$@
#
#
# This builds the IPK file.
#
# Binaries should be installed into $(KNOCK_IPK_DIR)/opt/sbin or $(KNOCK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(KNOCK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(KNOCK_IPK_DIR)/opt/etc/knock/...
# Documentation files should be installed in $(KNOCK_IPK_DIR)/opt/doc/knock/...
# Daemon startup scripts should be installed in $(KNOCK_IPK_DIR)/opt/etc/init.d/S??knock
#
# You may need to patch your application to make it use these locations.
#
$(KNOCK_IPK): $(KNOCK_BUILD_DIR)/.built
	rm -rf $(KNOCK_IPK_DIR) $(BUILD_DIR)/knock_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(KNOCK_BUILD_DIR) DESTDIR=$(KNOCK_IPK_DIR) install
	$(STRIP_COMMAND) $(KNOCK_IPK_DIR)/opt/*bin/*
	mv $(KNOCK_IPK_DIR)/etc $(KNOCK_IPK_DIR)/opt/
	install -d $(KNOCK_IPK_DIR)/opt/etc/init.d
	install -m 755 $(KNOCK_SOURCE_DIR)/rc.knockd $(KNOCK_IPK_DIR)/opt/etc/init.d/S05knockd
ifneq (nslu2, $(OPTWARE_TARGET))
	sed -i -e 's/ -i ixp0//' $(KNOCK_IPK_DIR)/opt/etc/init.d/S05knockd
endif
	$(MAKE) $(KNOCK_IPK_DIR)/CONTROL/control
	echo $(KNOCK_CONFFILES) | sed -e 's/ /\n/g' > $(KNOCK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(KNOCK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
knock-ipk: $(KNOCK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
knock-clean:
	rm -f $(KNOCK_BUILD_DIR)/.built
	-$(MAKE) -C $(KNOCK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
knock-dirclean:
	rm -rf $(BUILD_DIR)/$(KNOCK_DIR) $(KNOCK_BUILD_DIR) $(KNOCK_IPK_DIR) $(KNOCK_IPK)

#
# Some sanity check for the package.
#
knock-check: $(KNOCK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
