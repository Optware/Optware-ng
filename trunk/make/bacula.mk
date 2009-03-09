###########################################################
#
# bacula
#
###########################################################
#
# BACULA_VERSION, BACULA_SITE and BACULA_SOURCE define
# the upstream location of the source code for the package.
# BACULA_DIR is the directory which is created when the source
# archive is unpacked.
# BACULA_UNZIP is the command used to unzip the source.
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
BACULA_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/bacula
BACULA_VERSION=2.4.4
BACULA_SOURCE=bacula-$(BACULA_VERSION).tar.gz
BACULA_DIR=bacula-$(BACULA_VERSION)
BACULA_UNZIP=zcat
BACULA_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BACULA_DESCRIPTION=A set of Open Source, enterprise ready, computer programs to manage backup, recovery, and verification of computer data across a network of computers of different kinds.
BACULA_SECTION=sysadmin
BACULA_PRIORITY=optional
BACULA_DEPENDS=libstdc++, openssl, readline, sqlite, tcpwrappers, zlib
BACULA_SUGGESTS=
BACULA_CONFLICTS=

#
# BACULA_IPK_VERSION should be incremented when the ipk changes.
#
BACULA_IPK_VERSION=1

#
# BACULA_CONFFILES should be a list of user-editable files
#BACULA_CONFFILES=/opt/etc/bacula.conf /opt/etc/init.d/SXXbacula

#
# BACULA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BACULA_PATCHES=$(BACULA_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BACULA_CPPFLAGS=
BACULA_LDFLAGS=

ifeq (uclibc, $(LIBC_STYLE))
BACULA_CONFIGURE_ENVS=ac_cv_func_posix_fadvise=no
endif

#
# BACULA_BUILD_DIR is the directory in which the build is done.
# BACULA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BACULA_IPK_DIR is the directory in which the ipk is built.
# BACULA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BACULA_BUILD_DIR=$(BUILD_DIR)/bacula
BACULA_SOURCE_DIR=$(SOURCE_DIR)/bacula

BACULA_IPK_DIR=$(BUILD_DIR)/bacula-$(BACULA_VERSION)-ipk
BACULA_IPK=$(BUILD_DIR)/bacula_$(BACULA_VERSION)-$(BACULA_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bacula-source bacula-unpack bacula bacula-stage bacula-ipk bacula-clean bacula-dirclean bacula-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BACULA_SOURCE):
	$(WGET) -P $(@D) $(BACULA_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bacula-source: $(DL_DIR)/$(BACULA_SOURCE) $(BACULA_PATCHES)

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
$(BACULA_BUILD_DIR)/.configured: $(DL_DIR)/$(BACULA_SOURCE) $(BACULA_PATCHES) make/bacula.mk
	$(MAKE) libstdc++-stage
	$(MAKE) openssl-stage readline-stage sqlite-stage tcpwrappers-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(BACULA_DIR) $(@D)
	$(BACULA_UNZIP) $(DL_DIR)/$(BACULA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BACULA_PATCHES)" ; \
		then cat $(BACULA_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BACULA_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BACULA_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BACULA_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BACULA_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BACULA_LDFLAGS)" \
		$(BACULA_CONFIGURE_ENVS) \
		ac_cv_func_setpgrp_void=yes \
		ac_cv_func_chflags=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc/bacula \
		--with-scriptdir=/opt/etc/bacula/scripts \
		--enable-smartalloc \
		--disable-conio --enable-readline \
		--with-readline=$(STAGING_PREFIX) \
		--with-openssl=$(STAGING_PREFIX) \
		--with-sqlite3=$(STAGING_PREFIX) \
		--with-tcp-wrappers=$(STAGING_PREFIX) \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

bacula-unpack: $(BACULA_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BACULA_BUILD_DIR)/.built: $(BACULA_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
bacula: $(BACULA_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BACULA_BUILD_DIR)/.staged: $(BACULA_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

bacula-stage: $(BACULA_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bacula
#
$(BACULA_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: bacula" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BACULA_PRIORITY)" >>$@
	@echo "Section: $(BACULA_SECTION)" >>$@
	@echo "Version: $(BACULA_VERSION)-$(BACULA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BACULA_MAINTAINER)" >>$@
	@echo "Source: $(BACULA_SITE)/$(BACULA_SOURCE)" >>$@
	@echo "Description: $(BACULA_DESCRIPTION)" >>$@
	@echo "Depends: $(BACULA_DEPENDS)" >>$@
	@echo "Suggests: $(BACULA_SUGGESTS)" >>$@
	@echo "Conflicts: $(BACULA_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BACULA_IPK_DIR)/opt/sbin or $(BACULA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BACULA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BACULA_IPK_DIR)/opt/etc/bacula/...
# Documentation files should be installed in $(BACULA_IPK_DIR)/opt/doc/bacula/...
# Daemon startup scripts should be installed in $(BACULA_IPK_DIR)/opt/etc/init.d/S??bacula
#
# You may need to patch your application to make it use these locations.
#
$(BACULA_IPK): $(BACULA_BUILD_DIR)/.built
	rm -rf $(BACULA_IPK_DIR) $(BUILD_DIR)/bacula_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BACULA_BUILD_DIR) DESTDIR=$(BACULA_IPK_DIR) install
	find $(BACULA_IPK_DIR)/opt/sbin -type f \! -name btraceback | xargs $(STRIP_COMMAND)
	$(MAKE) $(BACULA_IPK_DIR)/CONTROL/control
	echo $(BACULA_CONFFILES) | sed -e 's/ /\n/g' > $(BACULA_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BACULA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bacula-ipk: $(BACULA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bacula-clean:
	rm -f $(BACULA_BUILD_DIR)/.built
	-$(MAKE) -C $(BACULA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bacula-dirclean:
	rm -rf $(BUILD_DIR)/$(BACULA_DIR) $(BACULA_BUILD_DIR) $(BACULA_IPK_DIR) $(BACULA_IPK)
#
#
# Some sanity check for the package.
#
bacula-check: $(BACULA_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
