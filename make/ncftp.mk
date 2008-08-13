###########################################################
#
# ncftp
#
###########################################################

# You must replace "ncftp" and "NCFTP" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NCFTP_VERSION, NCFTP_SITE and NCFTP_SOURCE define
# the upstream location of the source code for the package.
# NCFTP_DIR is the directory which is created when the source
# archive is unpacked.
# NCFTP_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
NCFTP_SITE=ftp://ftp.ncftp.com/ncftp
NCFTP_VERSION=3.2.2
NCFTP_SOURCE=ncftp-$(NCFTP_VERSION)-src.tar.gz
NCFTP_DIR=ncftp-$(NCFTP_VERSION)
NCFTP_UNZIP=zcat
NCFTP_MAINTAINER=Inge Arnesen <inge.arnesen@gmail.com>
NCFTP_SECTION=net
NCFTP_PRIORITY=optional
NCFTP_DEPENDS=ncurses
NCFTP_DESCRIPTION=Nice command line FTP client

#
# NCFTP_IPK_VERSION should be incremented when the ipk changes.
#
NCFTP_IPK_VERSION=1

#
# NCFTP_CONFFILES should be a list of user-editable files
NCFTP_CONFFILES=
#/opt/etc/ncftp.conf /opt/etc/init.d/SXXncftp

#
# NCFTP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
NCFTP_PATCHES=$(NCFTP_SOURCE_DIR)/configure2.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NCFTP_CPPFLAGS=
NCFTP_LDFLAGS=

#
# NCFTP_BUILD_DIR is the directory in which the build is done.
# NCFTP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NCFTP_IPK_DIR is the directory in which the ipk is built.
# NCFTP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NCFTP_BUILD_DIR=$(BUILD_DIR)/ncftp
NCFTP_SOURCE_DIR=$(SOURCE_DIR)/ncftp
NCFTP_IPK_DIR=$(BUILD_DIR)/ncftp-$(NCFTP_VERSION)-ipk
NCFTP_IPK=$(BUILD_DIR)/ncftp_$(NCFTP_VERSION)-$(NCFTP_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(HOSTCC), $(TARGET_CC))
NCFTP_CROSS_CONFIGURE_ENV=ac_cv_func_setpgrp_void=yes ac_cv_func_setvbuf_reversed=no
endif

.PHONY: ncftp-source ncftp-unpack ncftp ncftp-stage ncftp-ipk ncftp-clean ncftp-dirclean ncftp-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NCFTP_SOURCE):
	$(WGET) -P $(@D) $(NCFTP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(NCFTP_SITE)/older_versions/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ncftp-source: $(DL_DIR)/$(NCFTP_SOURCE) $(NCFTP_PATCHES)

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
$(NCFTP_BUILD_DIR)/.configured: $(DL_DIR)/$(NCFTP_SOURCE) $(NCFTP_PATCHES) make/ncftp.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NCFTP_DIR) $(@D)
	$(NCFTP_UNZIP) $(DL_DIR)/$(NCFTP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NCFTP_PATCHES)"; \
		then cat $(NCFTP_PATCHES) | patch -bd $(BUILD_DIR)/$(NCFTP_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(NCFTP_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NCFTP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NCFTP_LDFLAGS)" \
		$(NCFTP_CROSS_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--bindir=/opt/bin \
		--mandir=/opt/man \
		--prefix=opt \
		--disable-nls \
	)
	touch $@

ncftp-unpack: $(NCFTP_BUILD_DIR)/.configured

#
# This builds the actual binary.  You should change the target to refer
# directly to the main binary which is built.
#
$(NCFTP_BUILD_DIR)/.built: $(NCFTP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ncftp: $(NCFTP_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ncftp
#
$(NCFTP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ncftp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NCFTP_PRIORITY)" >>$@
	@echo "Section: $(NCFTP_SECTION)" >>$@
	@echo "Version: $(NCFTP_VERSION)-$(NCFTP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NCFTP_MAINTAINER)" >>$@
	@echo "Source: $(NCFTP_SITE)/$(NCFTP_SOURCE)" >>$@
	@echo "Description: $(NCFTP_DESCRIPTION)" >>$@
	@echo "Depends: $(NCFTP_DEPENDS)" >>$@
	@echo "Conflicts: $(NCFTP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NCFTP_IPK_DIR)/opt/sbin or $(NCFTP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NCFTP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NCFTP_IPK_DIR)/opt/etc/ncftp/...
# Documentation files should be installed in $(NCFTP_IPK_DIR)/opt/doc/ncftp/...
# Daemon startup scripts should be installed in $(NCFTP_IPK_DIR)/opt/etc/init.d/S??ncftp
#
# You may need to patch your application to make it use these locations.
#
$(NCFTP_IPK): $(NCFTP_BUILD_DIR)/.built
	rm -rf $(NCFTP_IPK_DIR) $(BUILD_DIR)/ncftp_*_$(TARGET_ARCH).ipk
	install -d $(NCFTP_IPK_DIR)/opt/bin
	$(MAKE) -C $(NCFTP_BUILD_DIR) DESTDIR=$(NCFTP_IPK_DIR) prefix=/opt install
	$(MAKE) $(NCFTP_IPK_DIR)/CONTROL/control
#	install -m 644 $(NCFTP_SOURCE_DIR)/postinst $(NCFTP_IPK_DIR)/CONTROL/postinst
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NCFTP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ncftp-ipk: $(NCFTP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ncftp-clean:
	-$(MAKE) -C $(NCFTP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ncftp-dirclean:
	rm -rf $(BUILD_DIR)/$(NCFTP_DIR) $(NCFTP_BUILD_DIR) $(NCFTP_IPK_DIR) $(NCFTP_IPK)

#
# Some sanity check for the package.
#
ncftp-check: $(NCFTP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NCFTP_IPK)
