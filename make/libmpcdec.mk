###########################################################
#
# libmpcdec
#
###########################################################
#
# LIBMPCDEC_VERSION, LIBMPCDEC_SITE and LIBMPCDEC_SOURCE define
# the upstream location of the source code for the package.
# LIBMPCDEC_DIR is the directory which is created when the source
# archive is unpacked.
# LIBMPCDEC_UNZIP is the command used to unzip the source.
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
LIBMPCDEC_SVN=http://svn.musepack.net/libmpc/trunk
LIBMPCDEC_SVN_REVISION=000485
ifdef LIBMPCDEC_SVN
LIBMPCDEC_VERSION=1.2.6+svn$(LIBMPCDEC_SVN_REVISION)
else
LIBMPCDEC_VERSION=1.2.6
endif
LIBMPCDEC_SITE=http://files.musepack.net/source
LIBMPCDEC_SOURCE=libmpcdec-$(LIBMPCDEC_VERSION).tar.bz2
LIBMPCDEC_DIR=libmpcdec-$(LIBMPCDEC_VERSION)
LIBMPCDEC_UNZIP=bzcat
LIBMPCDEC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBMPCDEC_DESCRIPTION=Portable Musepack decoder library.
LIBMPCDEC_SECTION=audio
LIBMPCDEC_PRIORITY=optional
LIBMPCDEC_DEPENDS=
LIBMPCDEC_SUGGESTS=
LIBMPCDEC_CONFLICTS=

#
# LIBMPCDEC_IPK_VERSION should be incremented when the ipk changes.
#
LIBMPCDEC_IPK_VERSION=2

#
# LIBMPCDEC_CONFFILES should be a list of user-editable files
#LIBMPCDEC_CONFFILES=$(TARGET_PREFIX)/etc/libmpcdec.conf $(TARGET_PREFIX)/etc/init.d/SXXlibmpcdec

#
# LIBMPCDEC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBMPCDEC_PATCHES=\
$(LIBMPCDEC_SOURCE_DIR)/visibility.patch \
$(LIBMPCDEC_SOURCE_DIR)/bswap_nearbyintf.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBMPCDEC_CPPFLAGS=
LIBMPCDEC_LDFLAGS=
ifeq ($(HOSTCC), $(TARGET_CC))
LIBMPCDEC_CONFIG_ENV=
else
LIBMPCDEC_CONFIG_ENV=ac_cv_func_memcmp_working=yes
endif

#
# LIBMPCDEC_BUILD_DIR is the directory in which the build is done.
# LIBMPCDEC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBMPCDEC_IPK_DIR is the directory in which the ipk is built.
# LIBMPCDEC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBMPCDEC_BUILD_DIR=$(BUILD_DIR)/libmpcdec
LIBMPCDEC_SOURCE_DIR=$(SOURCE_DIR)/libmpcdec
LIBMPCDEC_IPK_DIR=$(BUILD_DIR)/libmpcdec-$(LIBMPCDEC_VERSION)-ipk
LIBMPCDEC_IPK=$(BUILD_DIR)/libmpcdec_$(LIBMPCDEC_VERSION)-$(LIBMPCDEC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libmpcdec-source libmpcdec-unpack libmpcdec libmpcdec-stage libmpcdec-ipk libmpcdec-clean libmpcdec-dirclean libmpcdec-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBMPCDEC_SOURCE):
ifdef LIBMPCDEC_SVN
	( cd $(BUILD_DIR) ; \
		rm -rf $(LIBMPCDEC_DIR) && \
		svn co -r $(LIBMPCDEC_SVN_REVISION) $(LIBMPCDEC_SVN) $(LIBMPCDEC_DIR) && \
		tar -cjf $@ $(LIBMPCDEC_DIR) --exclude .svn && \
		rm -rf $(LIBMPCDEC_DIR) \
	)
else
	$(WGET) -P $(@D) $(LIBMPCDEC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libmpcdec-source: $(DL_DIR)/$(LIBMPCDEC_SOURCE) $(LIBMPCDEC_PATCHES)

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
$(LIBMPCDEC_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBMPCDEC_SOURCE) $(LIBMPCDEC_PATCHES) make/libmpcdec.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LIBMPCDEC_DIR) $(@D)
	$(LIBMPCDEC_UNZIP) $(DL_DIR)/$(LIBMPCDEC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBMPCDEC_PATCHES)" ; \
		then cat $(LIBMPCDEC_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBMPCDEC_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBMPCDEC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBMPCDEC_DIR) $(@D) ; \
	fi
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBMPCDEC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBMPCDEC_LDFLAGS)" \
		$(LIBMPCDEC_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libmpcdec-unpack: $(LIBMPCDEC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBMPCDEC_BUILD_DIR)/.built: $(LIBMPCDEC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) depmode=gcc
	touch $@

#
# This is the build convenience target.
#
libmpcdec: $(LIBMPCDEC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBMPCDEC_BUILD_DIR)/.staged: $(LIBMPCDEC_BUILD_DIR)/.built
	rm -f $@
	rm -rf $(STAGING_INCLUDE_DIR)/mpcdec $(STAGING_INCLUDE_DIR)/mpc
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	ln -s mpc $(STAGING_INCLUDE_DIR)/mpcdec
	rm -f $(STAGING_LIB_DIR)/libmpcdec.la
	touch $@

libmpcdec-stage: $(LIBMPCDEC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libmpcdec
#
$(LIBMPCDEC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libmpcdec" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBMPCDEC_PRIORITY)" >>$@
	@echo "Section: $(LIBMPCDEC_SECTION)" >>$@
	@echo "Version: $(LIBMPCDEC_VERSION)-$(LIBMPCDEC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBMPCDEC_MAINTAINER)" >>$@
ifdef LIBMPCDEC_SVN
	@echo "Source: $(LIBMPCDEC_SVN)" >>$@
else
	@echo "Source: $(LIBMPCDEC_SITE)/$(LIBMPCDEC_SOURCE)" >>$@
endif
	@echo "Description: $(LIBMPCDEC_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBMPCDEC_DEPENDS)" >>$@
	@echo "Suggests: $(LIBMPCDEC_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBMPCDEC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/libmpcdec/...
# Documentation files should be installed in $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/doc/libmpcdec/...
# Daemon startup scripts should be installed in $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libmpcdec
#
# You may need to patch your application to make it use these locations.
#
$(LIBMPCDEC_IPK): $(LIBMPCDEC_BUILD_DIR)/.built
	rm -rf $(LIBMPCDEC_IPK_DIR) $(BUILD_DIR)/libmpcdec_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBMPCDEC_BUILD_DIR) DESTDIR=$(LIBMPCDEC_IPK_DIR) install-strip
	ln -s mpc $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/include/mpcdec
	rm -f $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/lib/libmpcdec.la
#	$(INSTALL) -d $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBMPCDEC_SOURCE_DIR)/libmpcdec.conf $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/libmpcdec.conf
#	$(INSTALL) -d $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBMPCDEC_SOURCE_DIR)/rc.libmpcdec $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmpcdec
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPCDEC_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibmpcdec
	$(MAKE) $(LIBMPCDEC_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBMPCDEC_SOURCE_DIR)/postinst $(LIBMPCDEC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPCDEC_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBMPCDEC_SOURCE_DIR)/prerm $(LIBMPCDEC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBMPCDEC_IPK_DIR)/CONTROL/prerm
	echo $(LIBMPCDEC_CONFFILES) | sed -e 's/ /\n/g' > $(LIBMPCDEC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBMPCDEC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libmpcdec-ipk: $(LIBMPCDEC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libmpcdec-clean:
	rm -f $(LIBMPCDEC_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBMPCDEC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libmpcdec-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBMPCDEC_DIR) $(LIBMPCDEC_BUILD_DIR) $(LIBMPCDEC_IPK_DIR) $(LIBMPCDEC_IPK)
#
#
# Some sanity check for the package.
#
libmpcdec-check: $(LIBMPCDEC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
