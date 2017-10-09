###########################################################
#
# iptables
#
###########################################################

# You must replace "iptables" and "IPTABLES" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IPTABLES_VERSION, IPTABLES_SITE and IPTABLES_SOURCE define
# the upstream location of the source code for the package.
# IPTABLES_DIR is the directory which is created when the source
# archive is unpacked.
# IPTABLES_UNZIP is the command used to unzip the source.
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
IPTABLES_SITE=http://ftp.netfilter.org/pub/iptables
IPTABLES_VERSION=1.4.21
IPTABLES_SOURCE=iptables-$(IPTABLES_VERSION).tar.bz2
IPTABLES_UNZIP=bzcat
IPTABLES_SOURCES=$(DL_DIR)/$(IPTABLES_SOURCE) 
IPTABLES_DIR=iptables-$(IPTABLES_VERSION)
IPTABLES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPTABLES_DESCRIPTION=Userland utilities for controlling firewalling rules
IPTABLES_SECTION=net
IPTABLES_PRIORITY=optional
IPTABLES_DEPENDS=
IPTABLES_SUGGESTS=
IPTABLES_CONFLICTS=


#
# IPTABLES_IPK_VERSION should be incremented when the ipk changes.
#
IPTABLES_IPK_VERSION=2

#
# IPTABLES_CONFFILES should be a list of user-editable files
#IPTABLES_CONFFILES=$(TARGET_PREFIX)/etc/iptables.conf $(TARGET_PREFIX)/etc/init.d/SXXiptables

#
# IPTABLES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
IPTABLES_PATCHES=$(IPTABLES_SOURCE_DIR)/include_linux_list_h.patch


#
# IPTABLES_BUILD_DIR is the directory in which the build is done.
# IPTABLES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IPTABLES_IPK_DIR is the directory in which the ipk is built.
# IPTABLES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPTABLES_BUILD_DIR=$(BUILD_DIR)/iptables
IPTABLES_SOURCE_DIR=$(SOURCE_DIR)/iptables
IPTABLES_IPK_DIR=$(BUILD_DIR)/iptables-$(IPTABLES_VERSION)-ipk
IPTABLES_IPK=$(BUILD_DIR)/iptables_$(IPTABLES_VERSION)-$(IPTABLES_IPK_VERSION)_$(TARGET_ARCH).ipk
IPTABLES_INST_DIR=$(TARGET_PREFIX)

.PHONY: iptables-source iptables-unpack iptables iptables-stage iptables-ipk iptables-clean iptables-dirclean iptables-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IPTABLES_SOURCE):
	$(WGET) -P $(DL_DIR) $(IPTABLES_SITE)/$(IPTABLES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iptables-source: $(IPTABLES_SOURCES)

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
# --enable-devel is the default. Inserted for documentation purposes
#
$(IPTABLES_BUILD_DIR)/.configured: $(IPTABLES_SOURCES) make/iptables.mk
	rm -rf $(BUILD_DIR)/$(IPTABLES_DIR) $(IPTABLES_BUILD_DIR)
	$(IPTABLES_UNZIP) $(DL_DIR)/$(IPTABLES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IPTABLES_PATCHES)" ; \
		then cat $(IPTABLES_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(IPTABLES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPTABLES_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IPTABLES_DIR) $(@D) ; \
	fi
#	find $(@D) -type f -name '*.[ch]' -exec sed -i -e 's/list/_&_/g' -e 's/linux__list_.h/linux_list.h/' {} \;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IPTABLES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IPTABLES_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(IPTABLES_INST_DIR) \
		--enable-devel \
	)
	touch $(IPTABLES_BUILD_DIR)/.configured

iptables-unpack: $(IPTABLES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPTABLES_BUILD_DIR)/.built: $(IPTABLES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(IPTABLES_BUILD_DIR) all \
		$(TARGET_CONFIGURE_OPTS) PREFIX=$(TARGET_PREFIX)
	touch $@

#
# This is the build convenience target.
#
iptables: $(IPTABLES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IPTABLES_BUILD_DIR)/.staged: $(IPTABLES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/libip*tc.pc
	touch $@

iptables-stage: $(IPTABLES_BUILD_DIR)/.staged $(IPTABLES_BUILD_DIR)/.staged-headers

# Some applications require access to full headers to compile
# These are not installed by iptables make install. This is an
# ugly hack, but it beats hacking the iptables autoconf setup

iptables-stage-headers: $(IPTABLES_BUILD_DIR)/.staged-headers

$(IPTABLES_BUILD_DIR)/.staged-headers: $(IPTABLES_BUILD_DIR)/.staged
	cp -R $(IPTABLES_BUILD_DIR)/include $(STAGING_PREFIX)
	rm -f $(STAGING_INCLUDE_DIR)/Makefile*
	rm -f $(STAGING_INCLUDE_DIR)/*.in
	rm -fr $(STAGING_LIB_DIR)/*.la
	touch $@


#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a separate control file under sources/iptables
#
$(IPTABLES_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(IPTABLES_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: iptables" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPTABLES_PRIORITY)" >>$@
	@echo "Section: $(IPTABLES_SECTION)" >>$@
	@echo "Version: $(IPTABLES_VERSION)-$(IPTABLES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPTABLES_MAINTAINER)" >>$@
	@echo "Source: $(IPTABLES_SITE)/$(IPTABLES_SOURCE)" >>$@
	@echo "Description: $(IPTABLES_DESCRIPTION)" >>$@
	@echo "Depends: $(IPTABLES_DEPENDS)" >>$@
	@echo "Suggests: $(IPTABLES_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPTABLES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/etc/iptables/...
# Documentation files should be installed in $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/doc/iptables/...
# Daemon startup scripts should be installed in $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??iptables
#
# You may need to patch your application to make it use these locations.
#
$(IPTABLES_IPK): $(IPTABLES_BUILD_DIR)/.built
	rm -rf $(IPTABLES_IPK_DIR) $(BUILD_DIR)/iptables_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IPTABLES_BUILD_DIR) install \
		$(TARGET_CONFIGURE_OPTS) PREFIX=$(TARGET_PREFIX) DESTDIR=$(IPTABLES_IPK_DIR)
	$(STRIP_COMMAND) $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/lib/*.so* $(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/sbin/* \
		$(IPTABLES_IPK_DIR)$(TARGET_PREFIX)/lib/xtables/*.so*
	$(MAKE) $(IPTABLES_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPTABLES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iptables-ipk: $(IPTABLES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iptables-clean:
	rm -f $(IPTABLES_BUILD_DIR)/.built
	-$(MAKE) -C $(IPTABLES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iptables-dirclean:
	rm -rf $(BUILD_DIR)/$(IPTABLES_DIR) $(IPTABLES_BUILD_DIR) $(IPTABLES_IPK_DIR) $(IPTABLES_IPK)

#
#
# Some sanity check for the package.
#
iptables-check: $(IPTABLES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^


