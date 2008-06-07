###########################################################
#
# mpop
#
###########################################################
#
# MPOP_VERSION, MPOP_SITE and MPOP_SOURCE define
# the upstream location of the source code for the package.
# MPOP_DIR is the directory which is created when the source
# archive is unpacked.
# MPOP_UNZIP is the command used to unzip the source.
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
MPOP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mpop
MPOP_VERSION=1.0.14
MPOP_SOURCE=mpop-$(MPOP_VERSION).tar.bz2
MPOP_DIR=mpop-$(MPOP_VERSION)
MPOP_UNZIP=bzcat
MPOP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPOP_DESCRIPTION=mpop is an SMTP client.
MPOP_SECTION=mail
MPOP_PRIORITY=optional
MPOP_DEPENDS=gnutls, libgsasl
ifeq (libidn, $(filter libidn, $(PACKAGES)))
MPOP_DEPENDS+=, libidn
endif
MPOP_SUGGESTS=
MPOP_CONFLICTS=

#
# MPOP_IPK_VERSION should be incremented when the ipk changes.
#
MPOP_IPK_VERSION=1

#
# MPOP_CONFFILES should be a list of user-editable files
#MPOP_CONFFILES=/opt/etc/mpop.conf /opt/etc/init.d/SXXmpop

#
# MPOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MPOP_PATCHES=$(MPOP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPOP_CPPFLAGS=
MPOP_LDFLAGS=-lgnutls -lgsasl
MPOP_CONFIG_OPTS=
ifeq (libidn, $(filter libidn, $(PACKAGES)))
MPOP_LDFLAGS+=-lidn
else
MPOP_CONFIG_OPTS+=--without-libidn
endif

#
# MPOP_BUILD_DIR is the directory in which the build is done.
# MPOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPOP_IPK_DIR is the directory in which the ipk is built.
# MPOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPOP_BUILD_DIR=$(BUILD_DIR)/mpop
MPOP_SOURCE_DIR=$(SOURCE_DIR)/mpop
MPOP_IPK_DIR=$(BUILD_DIR)/mpop-$(MPOP_VERSION)-ipk
MPOP_IPK=$(BUILD_DIR)/mpop_$(MPOP_VERSION)-$(MPOP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpop-source mpop-unpack mpop mpop-stage mpop-ipk mpop-clean mpop-dirclean mpop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPOP_SOURCE):
	$(WGET) -P $(@D) $(MPOP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpop-source: $(DL_DIR)/$(MPOP_SOURCE) $(MPOP_PATCHES)

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
$(MPOP_BUILD_DIR)/.configured: $(DL_DIR)/$(MPOP_SOURCE) $(MPOP_PATCHES) make/mpop.mk
	$(MAKE) gnutls-stage
	$(MAKE) gsasl-stage
ifeq (libidn, $(filter libidn, $(PACKAGES)))
	$(MAKE) libidn-stage
endif
	rm -rf $(BUILD_DIR)/$(MPOP_DIR) $(MPOP_BUILD_DIR)
	$(MPOP_UNZIP) $(DL_DIR)/$(MPOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPOP_PATCHES)" ; \
		then cat $(MPOP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPOP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPOP_DIR)" != "$(MPOP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPOP_DIR) $(MPOP_BUILD_DIR) ; \
	fi
	(cd $(MPOP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPOP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPOP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MPOP_CONFIG_OPTS) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MPOP_BUILD_DIR)/libtool
	touch $@

mpop-unpack: $(MPOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPOP_BUILD_DIR)/.built: $(MPOP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MPOP_BUILD_DIR) LIBS=""
	touch $@

#
# This is the build convenience target.
#
mpop: $(MPOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPOP_BUILD_DIR)/.staged: $(MPOP_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(MPOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $@

mpop-stage: $(MPOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpop
#
$(MPOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPOP_PRIORITY)" >>$@
	@echo "Section: $(MPOP_SECTION)" >>$@
	@echo "Version: $(MPOP_VERSION)-$(MPOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPOP_MAINTAINER)" >>$@
	@echo "Source: $(MPOP_SITE)/$(MPOP_SOURCE)" >>$@
	@echo "Description: $(MPOP_DESCRIPTION)" >>$@
	@echo "Depends: $(MPOP_DEPENDS)" >>$@
	@echo "Suggests: $(MPOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPOP_IPK_DIR)/opt/sbin or $(MPOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPOP_IPK_DIR)/opt/etc/mpop/...
# Documentation files should be installed in $(MPOP_IPK_DIR)/opt/doc/mpop/...
# Daemon startup scripts should be installed in $(MPOP_IPK_DIR)/opt/etc/init.d/S??mpop
#
# You may need to patch your application to make it use these locations.
#
$(MPOP_IPK): $(MPOP_BUILD_DIR)/.built
	rm -rf $(MPOP_IPK_DIR) $(BUILD_DIR)/mpop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPOP_BUILD_DIR) install-strip transform='' DESTDIR=$(MPOP_IPK_DIR)
#	install -d $(MPOP_IPK_DIR)/opt/etc/
#	install -m 644 $(MPOP_SOURCE_DIR)/mpop.conf $(MPOP_IPK_DIR)/opt/etc/mpop.conf
#	install -d $(MPOP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MPOP_SOURCE_DIR)/rc.mpop $(MPOP_IPK_DIR)/opt/etc/init.d/SXXmpop
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPOP_IPK_DIR)/opt/etc/init.d/SXXmpop
	$(MAKE) $(MPOP_IPK_DIR)/CONTROL/control
#	install -m 755 $(MPOP_SOURCE_DIR)/postinst $(MPOP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPOP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MPOP_SOURCE_DIR)/prerm $(MPOP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MPOP_IPK_DIR)/CONTROL/prerm
	echo $(MPOP_CONFFILES) | sed -e 's/ /\n/g' > $(MPOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpop-ipk: $(MPOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpop-clean:
	rm -f $(MPOP_BUILD_DIR)/.built
	-$(MAKE) -C $(MPOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpop-dirclean:
	rm -rf $(BUILD_DIR)/$(MPOP_DIR) $(MPOP_BUILD_DIR) $(MPOP_IPK_DIR) $(MPOP_IPK)
#
#
# Some sanity check for the package.
#
mpop-check: $(MPOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPOP_IPK)
