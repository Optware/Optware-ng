###########################################################
#
# lftp
#
###########################################################
#
# LFTP_VERSION, LFTP_SITE and LFTP_SOURCE define
# the upstream location of the source code for the package.
# LFTP_DIR is the directory which is created when the source
# archive is unpacked.
# LFTP_UNZIP is the command used to unzip the source.
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
LFTP_SITE=http://ftp.yars.free.net/pub/source/lftp
LFTP_VERSION=3.7.8
LFTP_SOURCE=lftp-$(LFTP_VERSION).tar.gz
LFTP_DIR=lftp-$(LFTP_VERSION)
LFTP_UNZIP=zcat
LFTP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LFTP_DESCRIPTION=Sophisticated ftp/http client, file transfer program supporting a number of network protocols.
LFTP_SECTION=net
LFTP_PRIORITY=optional
LFTP_DEPENDS=readline, ncurses, expat, libstdc++, gnutls
LFTP_SUGGESTS=
LFTP_CONFLICTS=

#
# LFTP_IPK_VERSION should be incremented when the ipk changes.
#
LFTP_IPK_VERSION=1

#
# LFTP_CONFFILES should be a list of user-editable files
#LFTP_CONFFILES=/opt/etc/lftp.conf /opt/etc/init.d/SXXlftp

#
# LFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LFTP_PATCHES=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LFTP_CPPFLAGS=
LFTP_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
LFTP_CONFIG_ENV = \
	ac_cv_need_trio=no \
	lftp_cv_va_copy=yes \
	enable_wcwidth_replacement=yes \
	ac_cv_func_malloc_0_nonnull=yes \
	gl_cv_func_gettimeofday_clobber=no
endif

#
# LFTP_BUILD_DIR is the directory in which the build is done.
# LFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LFTP_IPK_DIR is the directory in which the ipk is built.
# LFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LFTP_BUILD_DIR=$(BUILD_DIR)/lftp
LFTP_SOURCE_DIR=$(SOURCE_DIR)/lftp
LFTP_IPK_DIR=$(BUILD_DIR)/lftp-$(LFTP_VERSION)-ipk
LFTP_IPK=$(BUILD_DIR)/lftp_$(LFTP_VERSION)-$(LFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: lftp-source lftp-unpack lftp lftp-stage lftp-ipk lftp-clean lftp-dirclean lftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LFTP_SOURCE):
	$(WGET) -P $(@D) $(LFTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
lftp-source: $(DL_DIR)/$(LFTP_SOURCE) $(LFTP_PATCHES)

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
$(LFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(LFTP_SOURCE) $(LFTP_PATCHES) make/lftp.mk
	$(MAKE) readline-stage ncurses-stage expat-stage libstdc++-stage
	$(MAKE) libgcrypt-stage libgpg-error-stage libtasn1-stage gnutls-stage
	rm -rf $(BUILD_DIR)/$(LFTP_DIR) $(@D)
	$(LFTP_UNZIP) $(DL_DIR)/$(LFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LFTP_PATCHES)" ; \
		then cat $(LFTP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LFTP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LFTP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LFTP_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LFTP_LDFLAGS)" \
		LIBGNUTLS_CONFIG=$(STAGING_PREFIX)/bin/libgnutls-config \
		$(LFTP_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

lftp-unpack: $(LFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LFTP_BUILD_DIR)/.built: $(LFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
lftp: $(LFTP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LFTP_BUILD_DIR)/.staged: $(LFTP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

lftp-stage: $(LFTP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/lftp
#
$(LFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: lftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LFTP_PRIORITY)" >>$@
	@echo "Section: $(LFTP_SECTION)" >>$@
	@echo "Version: $(LFTP_VERSION)-$(LFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LFTP_MAINTAINER)" >>$@
	@echo "Source: $(LFTP_SITE)/$(LFTP_SOURCE)" >>$@
	@echo "Description: $(LFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(LFTP_DEPENDS)" >>$@
	@echo "Suggests: $(LFTP_SUGGESTS)" >>$@
	@echo "Conflicts: $(LFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LFTP_IPK_DIR)/opt/sbin or $(LFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LFTP_IPK_DIR)/opt/etc/lftp/...
# Documentation files should be installed in $(LFTP_IPK_DIR)/opt/doc/lftp/...
# Daemon startup scripts should be installed in $(LFTP_IPK_DIR)/opt/etc/init.d/S??lftp
#
# You may need to patch your application to make it use these locations.
#
$(LFTP_IPK): $(LFTP_BUILD_DIR)/.built
	rm -rf $(LFTP_IPK_DIR) $(BUILD_DIR)/lftp_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LFTP_BUILD_DIR) DESTDIR=$(LFTP_IPK_DIR) install-strip
	$(MAKE) $(LFTP_IPK_DIR)/CONTROL/control
	echo $(LFTP_CONFFILES) | sed -e 's/ /\n/g' > $(LFTP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
lftp-ipk: $(LFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
lftp-clean:
	rm -f $(LFTP_BUILD_DIR)/.built
	-$(MAKE) -C $(LFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
lftp-dirclean:
	rm -rf $(BUILD_DIR)/$(LFTP_DIR) $(LFTP_BUILD_DIR) $(LFTP_IPK_DIR) $(LFTP_IPK)

#
# Some sanity check for the package.
#
lftp-check: $(LFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
