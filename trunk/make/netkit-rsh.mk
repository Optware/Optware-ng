##########################################################
#
# netkit-rsh
#
###########################################################

# You must replace "netkit-rsh" and "NETKIT-RSH" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NETKIT-RSH_VERSION, NETKIT-RSH_SITE and NETKIT-RSH_SOURCE define
# the upstream location of the source code for the package.
# NETKIT-RSH_DIR is the directory which is created when the source
# archive is unpacked.
# NETKIT-RSH_UNZIP is the command used to unzip the source.
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
NETKIT-RSH_SITE=http://ftp.uk.linux.org/pub/linux/Networking/netkit
NETKIT-RSH_VERSION=0.17
NETKIT-RSH_SOURCE=netkit-rsh-$(NETKIT-RSH_VERSION).tar.gz
NETKIT-RSH_DIR=netkit-rsh-$(NETKIT-RSH_VERSION)
NETKIT-RSH_UNZIP=zcat
NETKIT-RSH_MAINTAINER=Uwe Günther uwe@cscc.de>
NETKIT-RSH_DESCRIPTION=This package contains bsd r* client and server programs (use on trusted network only).
NETKIT-RSH_SECTION=net
NETKIT-RSH_PRIORITY=optional
NETKIT-RSH_DEPENDS=termcap
NETKIT-RSH_SUGGESTS=tcpwrappers
NETKIT-RSH_CONFLICTS=

#
# NETKIT-RSH_IPK_VERSION should be incremented when the ipk changes.
#
NETKIT-RSH_IPK_VERSION=1

#
# NETKIT-RSH_CONFFILES should be a list of user-editable files
NETKIT-RSH_CONFFILES=/etc/inetd.conf /etc/init.d/inetd.sh /etc/host.equiv ~/.rhosts

#
# NETKIT-RSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NETKIT-RSH_PATCHES= \
		$(NETKIT-RSH_SOURCE_DIR)/rcp.patch \
		$(NETKIT-RSH_SOURCE_DIR)/rexec.patch \
		$(NETKIT-RSH_SOURCE_DIR)/rsh.patch \
		$(NETKIT-RSH_SOURCE_DIR)/rshd.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NETKIT-RSH_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/termcap
NETKIT-RSH_LDFLAGS=

#
# NETKIT-RSH_BUILD_DIR is the directory in which the build is done.
# NETKIT-RSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NETKIT-RSH_IPK_DIR is the directory in which the ipk is built.
# NETKIT-RSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NETKIT-RSH_BUILD_DIR=$(BUILD_DIR)/netkit-rsh
NETKIT-RSH_SOURCE_DIR=$(SOURCE_DIR)/netkit-rsh
NETKIT-RSH_IPK_DIR=$(BUILD_DIR)/netkit-rsh-$(NETKIT-RSH_VERSION)-ipk
NETKIT-RSH_IPK=$(BUILD_DIR)/netkit-rsh_$(NETKIT-RSH_VERSION)-$(NETKIT-RSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: netkit-rsh-source netkit-rsh-unpack netkit-rsh netkit-rsh-stage netkit-rsh-ipk netkit-rsh-clean netkit-rsh-dirclean netkit-rsh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NETKIT-RSH_SOURCE):
	$(WGET) -P $(@D) $(NETKIT-RSH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
netkit-rsh-source: $(DL_DIR)/$(NETKIT-RSH_SOURCE) $(NETKIT-RSH_PATCHES)

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
$(NETKIT-RSH_BUILD_DIR)/.configured: $(DL_DIR)/$(NETKIT-RSH_SOURCE) $(NETKIT-RSH_PATCHES) make/netkit-rsh.mk
	$(MAKE) termcap-stage
	rm -rf $(BUILD_DIR)/$(NETKIT-RSH_DIR) $(NETKIT-RSH_BUILD_DIR)
	$(NETKIT-RSH_UNZIP) $(DL_DIR)/$(NETKIT-RSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NETKIT-RSH_PATCHES)" ; \
		then cat $(NETKIT-RSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NETKIT-RSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NETKIT-RSH_DIR)" != "$(NETKIT-RSH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NETKIT-RSH_DIR) $(NETKIT-RSH_BUILD_DIR) ; \
	fi
ifneq ($(TARGET_CC), $(HOSTCC))
	sed -i -e '/\.\/__conftest/d' $(@D)/configure
endif
	find $(@D) -name Makefile | xargs sed -i -e '/install/{s/ -s//;s/ -o root//}'
	sed -i -e 's/CFLAGS/CPPFLAGS/' $(@D)/MRULES
	(cd $(NETKIT-RSH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NETKIT-RSH_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(NETKIT-RSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETKIT-RSH_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(NETKIT-RSH_CPPFLAGS) $(STAGING_LDFLAGS) $(NETKIT_RSH_LDFLAGS)" \
		./configure \
		--prefix=/opt \
		--installroot=$(NETKIT-RSH_IPK_DIR) \
		--with-c-compiler="$(TARGET_CC)" \
		; \
	)
#	$(PATCH_LIBTOOL) $(NETKIT-RSH_BUILD_DIR)/libtool
	touch $@

netkit-rsh-unpack: $(NETKIT-RSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NETKIT-RSH_BUILD_DIR)/.built: $(NETKIT-RSH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(NETKIT-RSH_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
netkit-rsh: $(NETKIT-RSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NETKIT-RSH_BUILD_DIR)/.staged: $(NETKIT-RSH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NETKIT-RSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

netkit-rsh-stage: $(NETKIT-RSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/netkit-rsh
#
$(NETKIT-RSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: netkit-rsh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NETKIT-RSH_PRIORITY)" >>$@
	@echo "Section: $(NETKIT-RSH_SECTION)" >>$@
	@echo "Version: $(NETKIT-RSH_VERSION)-$(NETKIT-RSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NETKIT-RSH_MAINTAINER)" >>$@
	@echo "Source: $(NETKIT-RSH_SITE)/$(NETKIT-RSH_SOURCE)" >>$@
	@echo "Description: $(NETKIT-RSH_DESCRIPTION)" >>$@
	@echo "Depends: $(NETKIT-RSH_DEPENDS)" >>$@
	@echo "Suggests: $(NETKIT-RSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(NETKIT-RSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NETKIT-RSH_IPK_DIR)/opt/sbin or $(NETKIT-RSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NETKIT-RSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NETKIT-RSH_IPK_DIR)/opt/etc/netkit-rsh/...
# Documentation files should be installed in $(NETKIT-RSH_IPK_DIR)/opt/doc/netkit-rsh/...
# Daemon startup scripts should be installed in $(NETKIT-RSH_IPK_DIR)/opt/etc/init.d/S??netkit-rsh
#
# You may need to patch your application to make it use these locations.
#
$(NETKIT-RSH_IPK): $(NETKIT-RSH_BUILD_DIR)/.built
	rm -rf $(NETKIT-RSH_IPK_DIR) $(BUILD_DIR)/netkit-rsh_*_$(TARGET_ARCH).ipk
	
	install -d $(NETKIT-RSH_IPK_DIR)
	install -d $(NETKIT-RSH_IPK_DIR)/opt/bin/
	install -d $(NETKIT-RSH_IPK_DIR)/opt/sbin/
	install -d $(NETKIT-RSH_IPK_DIR)/opt/man/man1/
	install -d $(NETKIT-RSH_IPK_DIR)/opt/man/man8/
	$(MAKE) -C $(NETKIT-RSH_BUILD_DIR) DESTDIR=$(NETKIT-RSH_IPK_DIR) install
	for i in bin/rcp bin/rexec bin/rlogin bin/rsh sbin/in.rexecd sbin/in.rlogind sbin/in.rshd; do \
		$(STRIP_COMMAND) $(NETKIT-RSH_IPK_DIR)/opt/$${i}; \
	done
	$(MAKE) $(NETKIT-RSH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NETKIT-RSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
netkit-rsh-ipk: $(NETKIT-RSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
netkit-rsh-clean:
	rm -f $(NETKIT-RSH_BUILD_DIR)/.built
	-$(MAKE) -C $(NETKIT-RSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
netkit-rsh-dirclean:
	rm -rf $(BUILD_DIR)/$(NETKIT-RSH_DIR) $(NETKIT-RSH_BUILD_DIR) $(NETKIT-RSH_IPK_DIR) $(NETKIT-RSH_IPK)
#
#
# Some sanity check for the package.
#
netkit-rsh-check: $(NETKIT-RSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
