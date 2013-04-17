###########################################################
#
# srtp
#
###########################################################
#
# SRTP_VERSION, SRTP_SITE and SRTP_SOURCE define
# the upstream location of the source code for the package.
# SRTP_DIR is the directory which is created when the source
# archive is unpacked.
# SRTP_UNZIP is the command used to unzip the source.
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
SRTP_SITE=http://srtp.sourceforge.net
SRTP_VERSION=1.4.2
SRTP_SOURCE=srtp-$(SRTP_VERSION).tgz
SRTP_DIR=srtp
SRTP_UNZIP=zcat
SRTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SRTP_DESCRIPTION=library implementing Secure RTP, the Secure Real-time Transport Protocol
SRTP_SECTION=utils
SRTP_PRIORITY=optional
SRTP_DEPENDS=
SRTP_SUGGESTS=
SRTP_CONFLICTS=

#
# SRTP_IPK_VERSION should be incremented when the ipk changes.
#
SRTP_IPK_VERSION=1

#
# SRTP_CONFFILES should be a list of user-editable files
#SRTP_CONFFILES=/opt/etc/srtp.conf /opt/etc/init.d/SXXsrtp

#
# SRTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SRTP_PATCHES=$(SRTP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SRTP_CPPFLAGS=
SRTP_LDFLAGS=

#
# SRTP_BUILD_DIR is the directory in which the build is done.
# SRTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SRTP_IPK_DIR is the directory in which the ipk is built.
# SRTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SRTP_BUILD_DIR=$(BUILD_DIR)/srtp
SRTP_SOURCE_DIR=$(SOURCE_DIR)/srtp
SRTP_IPK_DIR=$(BUILD_DIR)/srtp-$(SRTP_VERSION)-ipk
SRTP_IPK=$(BUILD_DIR)/srtp_$(SRTP_VERSION)-$(SRTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: srtp-source srtp-unpack srtp srtp-stage srtp-ipk srtp-clean srtp-dirclean srtp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SRTP_SOURCE):
	$(WGET) -P $(@D) $(SRTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
srtp-source: $(DL_DIR)/$(SRTP_SOURCE) $(SRTP_PATCHES)

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
$(SRTP_BUILD_DIR)/.configured: $(DL_DIR)/$(SRTP_SOURCE) $(SRTP_PATCHES) make/srtp.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(SRTP_DIR) $(@D)
	$(SRTP_UNZIP) $(DL_DIR)/$(SRTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SRTP_PATCHES)" ; \
		then cat $(SRTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SRTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(SRTP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SRTP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sed -i -e "s/\bmips/srtp_mips/g" test/srtp_driver.c; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SRTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SRTP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	touch $@

srtp-unpack: $(SRTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SRTP_BUILD_DIR)/.built: $(SRTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
srtp: $(SRTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SRTP_BUILD_DIR)/.staged: $(SRTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

srtp-stage: $(SRTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/srtp
#
$(SRTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: srtp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SRTP_PRIORITY)" >>$@
	@echo "Section: $(SRTP_SECTION)" >>$@
	@echo "Version: $(SRTP_VERSION)-$(SRTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SRTP_MAINTAINER)" >>$@
	@echo "Source: $(SRTP_SITE)/$(SRTP_SOURCE)" >>$@
	@echo "Description: $(SRTP_DESCRIPTION)" >>$@
	@echo "Depends: $(SRTP_DEPENDS)" >>$@
	@echo "Suggests: $(SRTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(SRTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SRTP_IPK_DIR)/opt/sbin or $(SRTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SRTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SRTP_IPK_DIR)/opt/etc/srtp/...
# Documentation files should be installed in $(SRTP_IPK_DIR)/opt/doc/srtp/...
# Daemon startup scripts should be installed in $(SRTP_IPK_DIR)/opt/etc/init.d/S??srtp
#
# You may need to patch your application to make it use these locations.
#
$(SRTP_IPK): $(SRTP_BUILD_DIR)/.built
	rm -rf $(SRTP_IPK_DIR) $(BUILD_DIR)/srtp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SRTP_BUILD_DIR) DESTDIR=$(SRTP_IPK_DIR) install
	$(MAKE) $(SRTP_IPK_DIR)/CONTROL/control
#	install -m 755 $(SRTP_SOURCE_DIR)/postinst $(SRTP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SRTP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SRTP_SOURCE_DIR)/prerm $(SRTP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(SRTP_IPK_DIR)/CONTROL/prerm
	echo $(SRTP_CONFFILES) | sed -e 's/ /\n/g' > $(SRTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SRTP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(SRTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
srtp-ipk: $(SRTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
srtp-clean:
	rm -f $(SRTP_BUILD_DIR)/.built
	-$(MAKE) -C $(SRTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
srtp-dirclean:
	rm -rf $(BUILD_DIR)/$(SRTP_DIR) $(SRTP_BUILD_DIR) $(SRTP_IPK_DIR) $(SRTP_IPK)
#
#
# Some sanity check for the package.
#
srtp-check: $(SRTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
