###########################################################
#
# ipkg-static
#
###########################################################

#
# IPKG-STATIC_REPOSITORY defines the upstream location of the source code
# for the package.  IPKG-STATIC_DIR is the directory which is created when
# this cvs module is checked out.
#
IPKG-STATIC_SITE=http://downloads.yoctoproject.org/releases/opkg
IPKG-STATIC_VERSION=0.2.4
IPKG-STATIC_SOURCE=opkg-$(IPKG-STATIC_VERSION).tar.gz
IPKG-STATIC_DIR=opkg-$(IPKG-STATIC_VERSION)
IPKG-STATIC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IPKG-STATIC_DESCRIPTION=Static ipkg for bootstraping. This is opkg, patched to use ipkg paths
IPKG-STATIC_SECTION=base
IPKG-STATIC_PRIORITY=optional
IPKG-STATIC_DEPENDS=
IPKG-STATIC_SUGGESTS=
IPKG-STATIC_CONFLICTS=ipkg-opt

#
# IPKG-STATIC_IPK_VERSION should be incremented when the ipk changes.
#
IPKG-STATIC_IPK_VERSION=3

#
# IPKG-STATIC_CONFFILES should be a list of user-editable files
IPKG-STATIC_CONFFILES=$(TARGET_PREFIX)/etc/ipkg.conf

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IPKG-STATIC_CPPFLAGS=
IPKG-STATIC_LDFLAGS=

#
# IPKG-STATIC_BUILD_DIR is the directory in which the build is done.
# IPKG-STATIC_SOURCE_DIR is the directory which holds all the
# patches and ipkg-static control files.
# IPKG-STATIC_IPK_DIR is the directory in which the ipk is built.
# IPKG-STATIC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IPKG-STATIC_BUILD_DIR=$(BUILD_DIR)/ipkg-static
IPKG-STATIC_SOURCE_DIR=$(SOURCE_DIR)/ipkg-static
IPKG-STATIC_IPK_DIR=$(BUILD_DIR)/ipkg-static-$(IPKG-STATIC_VERSION)-ipk
IPKG-STATIC_IPK=$(BUILD_DIR)/ipkg-static_$(IPKG-STATIC_VERSION)-$(IPKG-STATIC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ipkg-static-source ipkg-static-unpack ipkg-static ipkg-static-stage ipkg-static-ipk ipkg-static-clean ipkg-static-dirclean ipkg-static-check

#
# IPKG-STATIC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IPKG-STATIC_PATCHES=\
$(IPKG-STATIC_SOURCE_DIR)/remove-ACLOCAL_AMFLAGS-I-shave-I-m4.patch \
$(IPKG-STATIC_SOURCE_DIR)/ipkg.patch \
$(IPKG-STATIC_SOURCE_DIR)/free-space-calc.patch \
$(IPKG-STATIC_SOURCE_DIR)/ipkg-add-force-checksum.patch \
$(IPKG-STATIC_SOURCE_DIR)/add-case-insensitive-flag.patch \
$(IPKG-STATIC_SOURCE_DIR)/add-find-command.patch \
$(IPKG-STATIC_SOURCE_DIR)/add-print-package-size.patch \
$(IPKG-STATIC_SOURCE_DIR)/add-print-package-installed-size.patch \
$(IPKG-STATIC_SOURCE_DIR)/change-internal-name-to-ipkg.patch \

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/$(IPKG-STATIC_SOURCE):
	$(WGET) -P $(@D) $(IPKG-STATIC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ipkg-static-source: $(DL_DIR)/$(IPKG-STATIC_SOURCE) $(IPKG-STATIC_PATCHES)

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) ipkg-static-stage <baz>-stage").
#
$(IPKG-STATIC_BUILD_DIR)/.configured: $(DL_DIR)/$(IPKG-STATIC_SOURCE) $(IPKG-STATIC_PATCHES) make/ipkg-static.mk
	rm -rf $(BUILD_DIR)/$(IPKG-STATIC_DIR) $(@D)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/$(IPKG-STATIC_SOURCE)
	if test -n "$(IPKG-STATIC_PATCHES)" ; \
		then cat $(IPKG-STATIC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(IPKG-STATIC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(IPKG-STATIC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(IPKG-STATIC_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.10) -I m4 -I shave -vif $(@D)
	(cd $(@D); \
		CPPFLAGS="$(TARGET_CFLAGS) $(IPKG-STATIC_CPPFLAGS)" \
		LDFLAGS="-Wl,--gc-sections --static $(IPKG-STATIC_LDFLAGS)" \
		$(TARGET_CONFIGURE_OPTS) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-opkgetcdir=$(TARGET_PREFIX)/etc \
		--with-opkglibdir=$(TARGET_PREFIX)/lib \
		--with-opkglockfile=$(TARGET_PREFIX)/var/lock/ipkg.lock \
		--prefix=$(TARGET_PREFIX) \
		--disable-curl \
		--disable-gpg \
		--disable-openssl \
		--enable-sha256 \
		--disable-nls \
		--disable-shared \
	)
	touch $@

#		PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \

ipkg-static-unpack: $(IPKG-STATIC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IPKG-STATIC_BUILD_DIR)/.built: $(IPKG-STATIC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" 

#
# This is the build convenience target.
#
ipkg-static: $(IPKG-STATIC_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg-static.  It is no longer
# necessary to create a seperate control file under sources/ipkg-static
#
$(IPKG-STATIC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: ipkg-static" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IPKG-STATIC_PRIORITY)" >>$@
	@echo "Section: $(IPKG-STATIC_SECTION)" >>$@
	@echo "Version: $(IPKG-STATIC_VERSION)-$(IPKG-STATIC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IPKG-STATIC_MAINTAINER)" >>$@
	@echo "Source: $(IPKG-STATIC_SITE)/$(IPKG-STATIC_SOURCE)" >>$@
	@echo "Description: $(IPKG-STATIC_DESCRIPTION)" >>$@
	@echo "Depends: $(IPKG-STATIC_DEPENDS)" >>$@
	@echo "Suggests: $(IPKG-STATIC_SUGGESTS)" >>$@
	@echo "Conflicts: $(IPKG-STATIC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/etc/ipkg/...
# Documentation files should be installed in $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/doc/ipkg-static/...
# Daemon startup scripts should be installed in $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??ipkg
#
# You may need to patch your application to make it use these locations.
#

$(IPKG-STATIC_IPK): $(IPKG-STATIC_BUILD_DIR)/.built
	rm -rf $(IPKG-STATIC_IPK_DIR) $(BUILD_DIR)/ipkg-static_*_$(TARGET_ARCH).ipk
	PATH="$(PATH):$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/bin/" \
		$(MAKE) -C $(IPKG-STATIC_BUILD_DIR) DESTDIR=$(IPKG-STATIC_IPK_DIR) install-strip
	$(INSTALL) -d $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/var/lock
	rm -f $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/opkg-key.1
	$(INSTALL) -d $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/etc/ipkg
	$(INSTALL) -m 644 $(IPKG-STATIC_SOURCE_DIR)/ipkg.conf \
		$(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/etc/ipkg.conf
	ln -s ../ipkg.conf $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/etc/ipkg/ipkg.conf
	rm -rf $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/lib
	rm -rf $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/include
	ln -s ipkg $(IPKG-STATIC_IPK_DIR)$(TARGET_PREFIX)/bin/ipkg-static
	$(MAKE) $(IPKG-STATIC_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(IPKG-STATIC_SOURCE_DIR)/postinst $(IPKG-STATIC_IPK_DIR)/CONTROL/postinst
	echo $(IPKG-STATIC_CONFFILES) | sed -e 's/ /\n/g' > $(IPKG-STATIC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IPKG-STATIC_IPK_DIR)

$(IPKG-STATIC_BUILD_DIR)/.ipk: $(IPKG-STATIC_IPK)
	rm -f $@
	touch $@

#
# This is called from the top level makefile to create the IPK file.
#
ipkg-static-ipk: $(IPKG-STATIC_BUILD_DIR)/.ipk

#
# This is called from the top level makefile to clean all of the built files.
#
ipkg-static-clean:
	rm -f $(IPKG-STATIC_BUILD_DIR)/.built
	-$(MAKE) -C $(IPKG-STATIC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ipkg-static-dirclean:
	rm -rf $(BUILD_DIR)/$(IPKG-STATIC_DIR) $(IPKG-STATIC_BUILD_DIR) $(IPKG-STATIC_IPK_DIR) $(IPKG-STATIC_IPK)

#
#
# Some sanity check for the package.
#
ipkg-static-check: $(IPKG-STATIC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IPKG-STATIC_IPK)
