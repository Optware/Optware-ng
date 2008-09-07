###########################################################
#
# bitlbee
#
###########################################################

#
# BITLBEE_VERSION, BITLBEE_SITE and BITLBEE_SOURCE define
# the upstream location of the source code for the package.
# BITLBEE_DIR is the directory which is created when the source
# archive is unpacked.
# BITLBEE_UNZIP is the command used to unzip the source.
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
BITLBEE_SITE=http://get.bitlbee.org/src/
BITLBEE_VERSION=1.2.3
BITLBEE_SOURCE=bitlbee-$(BITLBEE_VERSION).tar.gz
BITLBEE_DIR=bitlbee-$(BITLBEE_VERSION)
BITLBEE_UNZIP=zcat
BITLBEE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BITLBEE_DESCRIPTION=A gateway between IRC and proprietary IM networks
BITLBEE_SECTION=net
BITLBEE_PRIORITY=optional
BITLBEE_DEPENDS=glib, gnutls, xinetd, libgcrypt, libtasn1
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BITLBEE_DEPENDS+=, libiconv
endif
BITLBEE_SUGGESTS=
BITLBEE_CONFLICTS=

#
# BITLBEE_IPK_VERSION should be incremented when the ipk changes.
#
BITLBEE_IPK_VERSION=1

#
# BITLBEE_CONFFILES should be a list of user-editable files
BITLBEE_CONFFILES=/opt/etc/bitlbee/bitlbee.conf /opt/etc/xinetd.d/bitlbee

#
# BITLBEE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BITLBEE_PATCHES=$(BITLBEE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BITLBEE_CPPFLAGS=
BITLBEE_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
BITLBEE_LDFLAGS+=-liconv
endif

#
# BITLBEE_BUILD_DIR is the directory in which the build is done.
# BITLBEE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BITLBEE_IPK_DIR is the directory in which the ipk is built.
# BITLBEE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BITLBEE_BUILD_DIR=$(BUILD_DIR)/bitlbee
BITLBEE_SOURCE_DIR=$(SOURCE_DIR)/bitlbee
BITLBEE_IPK_DIR=$(BUILD_DIR)/bitlbee-$(BITLBEE_VERSION)-ipk
BITLBEE_IPK=$(BUILD_DIR)/bitlbee_$(BITLBEE_VERSION)-$(BITLBEE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bitlbee-source bitlbee-unpack bitlbee bitlbee-stage bitlbee-ipk bitlbee-clean bitlbee-dirclean bitlbee-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BITLBEE_SOURCE):
	$(WGET) -P $(@D) $(BITLBEE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bitlbee-source: $(DL_DIR)/$(BITLBEE_SOURCE) $(BITLBEE_PATCHES)

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
$(BITLBEE_BUILD_DIR)/.configured: $(DL_DIR)/$(BITLBEE_SOURCE) $(BITLBEE_PATCHES)
	$(MAKE) glib-stage gnutls-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(BITLBEE_DIR) $(BITLBEE_BUILD_DIR)
	$(BITLBEE_UNZIP) $(DL_DIR)/$(BITLBEE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BITLBEE_PATCHES)"; \
		then cat $(BITLBEE_PATCHES) | patch -d $(BUILD_DIR)/$(BITLBEE_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(BITLBEE_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BITLBEE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BITLBEE_LDFLAGS)" \
                PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
                PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		STAGING_DIR=$(STAGING_DIR) \
		PATH=$(STAGING_DIR)/opt/bin:$(PATH) \
		./configure \
		--prefix=/opt \
		--cpu=armv5b \
		--ssl=gnutls \
		--msn=1 \
		--yahoo=1 \
		--mandir=/opt/man \
		--datadir=/opt/var/bitlbee \
		--config=/opt/var/bitlbee \
	)
	touch $@

bitlbee-unpack: $(BITLBEE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BITLBEE_BUILD_DIR)/.built: $(BITLBEE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bitlbee: $(BITLBEE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BITLBEE_BUILD_DIR)/.staged: $(BITLBEE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

bitlbee-stage: $(BITLBEE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bitlbee
#
$(BITLBEE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bitlbee" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BITLBEE_PRIORITY)" >>$@
	@echo "Section: $(BITLBEE_SECTION)" >>$@
	@echo "Version: $(BITLBEE_VERSION)-$(BITLBEE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BITLBEE_MAINTAINER)" >>$@
	@echo "Source: $(BITLBEE_SITE)/$(BITLBEE_SOURCE)" >>$@
	@echo "Description: $(BITLBEE_DESCRIPTION)" >>$@
	@echo "Depends: $(BITLBEE_DEPENDS)" >>$@
	@echo "Suggests: $(BITLBEE_SUGGESTS)" >>$@
	@echo "Conflicts: $(BITLBEE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BITLBEE_IPK_DIR)/opt/sbin or $(BITLBEE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BITLBEE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BITLBEE_IPK_DIR)/opt/etc/bitlbee/...
# Documentation files should be installed in $(BITLBEE_IPK_DIR)/opt/doc/bitlbee/...
# Daemon startup scripts should be installed in $(BITLBEE_IPK_DIR)/opt/etc/init.d/S??bitlbee
#
# You may need to patch your application to make it use these locations.
#
$(BITLBEE_IPK): $(BITLBEE_BUILD_DIR)/.built
	rm -rf $(BITLBEE_IPK_DIR) $(BUILD_DIR)/bitlbee_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BITLBEE_BUILD_DIR) DESTDIR=$(BITLBEE_IPK_DIR) install
	install -d $(BITLBEE_IPK_DIR)/opt/etc/bitlbee
	install -m 644 $(BITLBEE_BUILD_DIR)/bitlbee.conf $(BITLBEE_IPK_DIR)/opt/etc/bitlbee/bitlbee.conf
	install -d $(BITLBEE_IPK_DIR)/opt/etc/xinetd.d
	install -m 755 $(BITLBEE_SOURCE_DIR)/xinetd.bitlbee $(BITLBEE_IPK_DIR)/opt/etc/xinetd.d/bitlbee
	$(MAKE) $(BITLBEE_IPK_DIR)/CONTROL/control
	install -m 755 $(BITLBEE_SOURCE_DIR)/postinst $(BITLBEE_IPK_DIR)/CONTROL/postinst
	#install -m 755 $(BITLBEE_SOURCE_DIR)/prerm $(BITLBEE_IPK_DIR)/CONTROL/prerm
	echo $(BITLBEE_CONFFILES) | sed -e 's/ /\n/g' > $(BITLBEE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BITLBEE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bitlbee-ipk: $(BITLBEE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bitlbee-clean:
	-$(MAKE) -C $(BITLBEE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bitlbee-dirclean:
	rm -rf $(BUILD_DIR)/$(BITLBEE_DIR) $(BITLBEE_BUILD_DIR) $(BITLBEE_IPK_DIR) $(BITLBEE_IPK)

#
# Some sanity check for the package.
#
bitlbee-check: $(BITLBEE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BITLBEE_IPK)
