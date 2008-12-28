###########################################################
#
# msmtp
#
###########################################################
#
# MSMTP_VERSION, MSMTP_SITE and MSMTP_SOURCE define
# the upstream location of the source code for the package.
# MSMTP_DIR is the directory which is created when the source
# archive is unpacked.
# MSMTP_UNZIP is the command used to unzip the source.
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
MSMTP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/msmtp
MSMTP_VERSION=1.4.17
MSMTP_SOURCE=msmtp-$(MSMTP_VERSION).tar.bz2
MSMTP_DIR=msmtp-$(MSMTP_VERSION)
MSMTP_UNZIP=bzcat
MSMTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MSMTP_DESCRIPTION=msmtp is an SMTP client.
MSMTP_SECTION=mail
MSMTP_PRIORITY=optional
MSMTP_DEPENDS=gnutls, libgsasl
ifeq (libidn, $(filter libidn, $(PACKAGES)))
MSMTP_DEPENDS+=, libidn
endif
MSMTP_SUGGESTS=
MSMTP_CONFLICTS=

#
# MSMTP_IPK_VERSION should be incremented when the ipk changes.
#
MSMTP_IPK_VERSION=1

#
# MSMTP_CONFFILES should be a list of user-editable files
#MSMTP_CONFFILES=/opt/etc/msmtp.conf /opt/etc/init.d/SXXmsmtp

#
# MSMTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MSMTP_PATCHES=$(MSMTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MSMTP_CPPFLAGS=
MSMTP_LDFLAGS=-lgnutls -lgsasl
MSMTP_CONFIG_OPTS=
ifeq (libidn, $(filter libidn, $(PACKAGES)))
MSMTP_LDFLAGS+=-lidn
else
MSMTP_CONFIG_OPTS+=--without-libidn
endif

#
# MSMTP_BUILD_DIR is the directory in which the build is done.
# MSMTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MSMTP_IPK_DIR is the directory in which the ipk is built.
# MSMTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MSMTP_BUILD_DIR=$(BUILD_DIR)/msmtp
MSMTP_SOURCE_DIR=$(SOURCE_DIR)/msmtp
MSMTP_IPK_DIR=$(BUILD_DIR)/msmtp-$(MSMTP_VERSION)-ipk
MSMTP_IPK=$(BUILD_DIR)/msmtp_$(MSMTP_VERSION)-$(MSMTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: msmtp-source msmtp-unpack msmtp msmtp-stage msmtp-ipk msmtp-clean msmtp-dirclean msmtp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MSMTP_SOURCE):
	$(WGET) -P $(@D) $(MSMTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
msmtp-source: $(DL_DIR)/$(MSMTP_SOURCE) $(MSMTP_PATCHES)

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
$(MSMTP_BUILD_DIR)/.configured: $(DL_DIR)/$(MSMTP_SOURCE) $(MSMTP_PATCHES) make/msmtp.mk
	$(MAKE) gnutls-stage
	$(MAKE) gsasl-stage
ifeq (libidn, $(filter libidn, $(PACKAGES)))
	$(MAKE) libidn-stage
endif
	rm -rf $(BUILD_DIR)/$(MSMTP_DIR) $(@D)
	$(MSMTP_UNZIP) $(DL_DIR)/$(MSMTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MSMTP_PATCHES)" ; \
		then cat $(MSMTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MSMTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MSMTP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MSMTP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MSMTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MSMTP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		$(MSMTP_CONFIG_OPTS) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MSMTP_BUILD_DIR)/libtool
	touch $@

msmtp-unpack: $(MSMTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MSMTP_BUILD_DIR)/.built: $(MSMTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LIBS=""
	touch $@

#
# This is the build convenience target.
#
msmtp: $(MSMTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MSMTP_BUILD_DIR)/.staged: $(MSMTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

msmtp-stage: $(MSMTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/msmtp
#
$(MSMTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: msmtp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MSMTP_PRIORITY)" >>$@
	@echo "Section: $(MSMTP_SECTION)" >>$@
	@echo "Version: $(MSMTP_VERSION)-$(MSMTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MSMTP_MAINTAINER)" >>$@
	@echo "Source: $(MSMTP_SITE)/$(MSMTP_SOURCE)" >>$@
	@echo "Description: $(MSMTP_DESCRIPTION)" >>$@
	@echo "Depends: $(MSMTP_DEPENDS)" >>$@
	@echo "Suggests: $(MSMTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(MSMTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MSMTP_IPK_DIR)/opt/sbin or $(MSMTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MSMTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MSMTP_IPK_DIR)/opt/etc/msmtp/...
# Documentation files should be installed in $(MSMTP_IPK_DIR)/opt/doc/msmtp/...
# Daemon startup scripts should be installed in $(MSMTP_IPK_DIR)/opt/etc/init.d/S??msmtp
#
# You may need to patch your application to make it use these locations.
#
$(MSMTP_IPK): $(MSMTP_BUILD_DIR)/.built
	rm -rf $(MSMTP_IPK_DIR) $(BUILD_DIR)/msmtp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MSMTP_BUILD_DIR) install-strip transform='' DESTDIR=$(MSMTP_IPK_DIR)
#	install -d $(MSMTP_IPK_DIR)/opt/etc/
#	install -m 644 $(MSMTP_SOURCE_DIR)/msmtp.conf $(MSMTP_IPK_DIR)/opt/etc/msmtp.conf
#	install -d $(MSMTP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MSMTP_SOURCE_DIR)/rc.msmtp $(MSMTP_IPK_DIR)/opt/etc/init.d/SXXmsmtp
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSMTP_IPK_DIR)/opt/etc/init.d/SXXmsmtp
	$(MAKE) $(MSMTP_IPK_DIR)/CONTROL/control
#	install -m 755 $(MSMTP_SOURCE_DIR)/postinst $(MSMTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSMTP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MSMTP_SOURCE_DIR)/prerm $(MSMTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSMTP_IPK_DIR)/CONTROL/prerm
	echo $(MSMTP_CONFFILES) | sed -e 's/ /\n/g' > $(MSMTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MSMTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
msmtp-ipk: $(MSMTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
msmtp-clean:
	rm -f $(MSMTP_BUILD_DIR)/.built
	-$(MAKE) -C $(MSMTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
msmtp-dirclean:
	rm -rf $(BUILD_DIR)/$(MSMTP_DIR) $(MSMTP_BUILD_DIR) $(MSMTP_IPK_DIR) $(MSMTP_IPK)
#
#
# Some sanity check for the package.
#
msmtp-check: $(MSMTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MSMTP_IPK)
