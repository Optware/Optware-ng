###########################################################
#
# clamav
#
###########################################################

# You must replace "clamav" and "CLAMAV" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CLAMAV_VERSION, CLAMAV_SITE and CLAMAV_SOURCE define
# the upstream location of the source code for the package.
# CLAMAV_DIR is the directory which is created when the source
# archive is unpacked.
# CLAMAV_UNZIP is the command used to unzip the source.
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
CLAMAV_SITE=http://$(SOURCEFORGE_MIRROR)/clamav
CLAMAV_VERSION=0.91.2
CLAMAV_SOURCE=clamav-$(CLAMAV_VERSION).tar.gz
CLAMAV_DIR=clamav-$(CLAMAV_VERSION)
CLAMAV_UNZIP=zcat
CLAMAV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CLAMAV_DESCRIPTION=Clam ANtivirus is a GPL anti-virus toolkit for UNIX
CLAMAV_SECTION=misc
CLAMAV_PRIORITY=optional
CLAMAV_DEPENDS=adduser,zlib,libgmp,bzip2
CLAMAV_SUGGESTS=
CLAMAV_CONFLICTS=

#
# CLAMAV_IPK_VERSION should be incremented when the ipk changes.
#
CLAMAV_IPK_VERSION=1

#
# CLAMAV_CONFFILES should be a list of user-editable files
CLAMAV_CONFFILES=/opt/etc/clamd.conf /opt/etc/freshclam.conf /opt/etc/init.d/S98clamav

#
# CLAMAV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
CLAMAV_PATCHES=$(CLAMAV_SOURCE_DIR)/configure.patch
ifeq ($(LIBC_STYLE), uclibc)
CLAMAV_PATCHES+=$(CLAMAV_SOURCE_DIR)/uclibc-shared-output.c.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLAMAV_CPPFLAGS=
CLAMAV_LDFLAGS=

#
# CLAMAV_BUILD_DIR is the directory in which the build is done.
# CLAMAV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLAMAV_IPK_DIR is the directory in which the ipk is built.
# CLAMAV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLAMAV_BUILD_DIR=$(BUILD_DIR)/clamav
CLAMAV_SOURCE_DIR=$(SOURCE_DIR)/clamav
CLAMAV_IPK_DIR=$(BUILD_DIR)/clamav-$(CLAMAV_VERSION)-ipk
CLAMAV_IPK=$(BUILD_DIR)/clamav_$(CLAMAV_VERSION)-$(CLAMAV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: clamav-source clamav-unpack clamav clamav-stage clamav-ipk clamav-clean clamav-dirclean clamav-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLAMAV_SOURCE):
	$(WGET) -P $(DL_DIR) $(CLAMAV_SITE)/$(CLAMAV_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
clamav-source: $(DL_DIR)/$(CLAMAV_SOURCE) $(CLAMAV_PATCHES)

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
$(CLAMAV_BUILD_DIR)/.configured: $(DL_DIR)/$(CLAMAV_SOURCE) $(CLAMAV_PATCHES)
	$(MAKE) zlib-stage libgmp-stage
	rm -rf $(BUILD_DIR)/$(CLAMAV_DIR) $(@D)
	$(CLAMAV_UNZIP) $(DL_DIR)/$(CLAMAV_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CLAMAV_PATCHES)"; \
		then cat $(CLAMAV_PATCHES) | patch -bd $(BUILD_DIR)/$(CLAMAV_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(CLAMAV_DIR) $(@D)
	(cd $(@D); \
		find . -name '*.[ch]' | xargs sed -i -e 's|P_tmpdir|CLAMAV_tmpdir|g'; \
		autoreconf; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLAMAV_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CLAMAV_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		ac_cv_have_accrights_in_msghdr=no \
		ac_cv_have_control_in_msghdr=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-clamav \
		--disable-static \
		--sysconfdir=/opt/etc \
		--with-zlib=$(STAGING_DIR)/opt \
		--mandir=/opt/man	\
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

clamav-unpack: $(CLAMAV_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLAMAV_BUILD_DIR)/.built: $(CLAMAV_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLAMAV_CPPFLAGS) -DCLAMAV_tmpdir=\\\"/opt/tmp\\\""
	touch $@

#
# This is the build convenience target.
#
clamav: $(CLAMAV_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLAMAV_BUILD_DIR)/.staged: $(CLAMAV_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

clamav-stage: $(CLAMAV_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/clamav
#
$(CLAMAV_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: clamav" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLAMAV_PRIORITY)" >>$@
	@echo "Section: $(CLAMAV_SECTION)" >>$@
	@echo "Version: $(CLAMAV_VERSION)-$(CLAMAV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLAMAV_MAINTAINER)" >>$@
	@echo "Source: $(CLAMAV_SITE)/$(CLAMAV_SOURCE)" >>$@
	@echo "Description: $(CLAMAV_DESCRIPTION)" >>$@
	@echo "Depends: $(CLAMAV_DEPENDS)" >>$@
	@echo "Suggests: $(CLAMAV_SUGGESTS)" >>$@
	@echo "Conflicts: $(CLAMAV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLAMAV_IPK_DIR)/opt/sbin or $(CLAMAV_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLAMAV_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLAMAV_IPK_DIR)/opt/etc/clamav/...
# Documentation files should be installed in $(CLAMAV_IPK_DIR)/opt/doc/clamav/...
# Daemon startup scripts should be installed in $(CLAMAV_IPK_DIR)/opt/etc/init.d/S??clamav
#
# You may need to patch your application to make it use these locations.
#
$(CLAMAV_IPK): $(CLAMAV_BUILD_DIR)/.built
	rm -rf $(CLAMAV_IPK_DIR) $(BUILD_DIR)/clamav_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CLAMAV_BUILD_DIR) install-strip \
		DESTDIR=$(CLAMAV_IPK_DIR) transform=""
	install -d $(CLAMAV_IPK_DIR)/opt/tmp/
	install -d $(CLAMAV_IPK_DIR)/opt/etc/
	install -m 644 $(CLAMAV_SOURCE_DIR)/clamd.conf $(CLAMAV_IPK_DIR)/opt/etc/clamd.conf
	install -m 644 $(CLAMAV_SOURCE_DIR)/freshclam.conf $(CLAMAV_IPK_DIR)/opt/etc/freshclam.conf
	install -d $(CLAMAV_IPK_DIR)/opt/etc/init.d
	install -m 755 $(CLAMAV_SOURCE_DIR)/rc.clamav $(CLAMAV_IPK_DIR)/opt/etc/init.d/S98clamav
	$(MAKE) $(CLAMAV_IPK_DIR)/CONTROL/control
	install -m 755 $(CLAMAV_SOURCE_DIR)/postinst $(CLAMAV_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CLAMAV_SOURCE_DIR)/prerm $(CLAMAV_IPK_DIR)/CONTROL/prerm
	echo $(CLAMAV_CONFFILES) | sed -e 's/ /\n/g' > $(CLAMAV_IPK_DIR)/CONTROL/conffiles
	rm $(CLAMAV_IPK_DIR)/opt/bin/clamav-config # contains staging paths
	rm $(CLAMAV_IPK_DIR)/opt/lib/libclamav.la # contains staging paths
	rm -rf $(CLAMAV_IPK_DIR)/opt/lib/pkgconfig/ # contains staging paths
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLAMAV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
clamav-ipk: $(CLAMAV_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
clamav-clean:
	-$(MAKE) -C $(CLAMAV_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
clamav-dirclean:
	rm -rf $(BUILD_DIR)/$(CLAMAV_DIR) $(CLAMAV_BUILD_DIR) $(CLAMAV_IPK_DIR) $(CLAMAV_IPK)

#
#
# Some sanity check for the package.
#
#
clamav-check: $(CLAMAV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CLAMAV_IPK)
