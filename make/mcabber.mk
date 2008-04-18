###########################################################
#
# mcabber
#
###########################################################
#
# MCABBER_VERSION, MCABBER_SITE and MCABBER_SOURCE define
# the upstream location of the source code for the package.
# MCABBER_DIR is the directory which is created when the source
# archive is unpacked.
# MCABBER_UNZIP is the command used to unzip the source.
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
MCABBER_SITE=http://www.lilotux.net/~mikael/mcabber/files
MCABBER_VERSION=0.9.7
MCABBER_SOURCE=mcabber-$(MCABBER_VERSION).tar.bz2
MCABBER_DIR=mcabber-$(MCABBER_VERSION)
MCABBER_UNZIP=bzcat
MCABBER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MCABBER_DESCRIPTION=A small Jabber console client.
MCABBER_SECTION=net
MCABBER_PRIORITY=optional
MCABBER_DEPENDS=glib, openssl, ncursesw
MCABBER_SUGGESTS=
MCABBER_CONFLICTS=

#
# MCABBER_IPK_VERSION should be incremented when the ipk changes.
#
MCABBER_IPK_VERSION=1

#
# MCABBER_CONFFILES should be a list of user-editable files
#MCABBER_CONFFILES=/opt/etc/mcabber.conf /opt/etc/init.d/SXXmcabber

#
# MCABBER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MCABBER_PATCHES=$(MCABBER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MCABBER_CPPFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
MCABBER_LDFLAGS=-lm
else
MCABBER_LDFLAGS=
endif

#
# MCABBER_BUILD_DIR is the directory in which the build is done.
# MCABBER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MCABBER_IPK_DIR is the directory in which the ipk is built.
# MCABBER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MCABBER_BUILD_DIR=$(BUILD_DIR)/mcabber
MCABBER_SOURCE_DIR=$(SOURCE_DIR)/mcabber
MCABBER_IPK_DIR=$(BUILD_DIR)/mcabber-$(MCABBER_VERSION)-ipk
MCABBER_IPK=$(BUILD_DIR)/mcabber_$(MCABBER_VERSION)-$(MCABBER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mcabber-source mcabber-unpack mcabber mcabber-stage mcabber-ipk mcabber-clean mcabber-dirclean mcabber-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MCABBER_SOURCE):
	$(WGET) -P $(@D) $(MCABBER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mcabber-source: $(DL_DIR)/$(MCABBER_SOURCE) $(MCABBER_PATCHES)

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
$(MCABBER_BUILD_DIR)/.configured: $(DL_DIR)/$(MCABBER_SOURCE) $(MCABBER_PATCHES) make/mcabber.mk
	$(MAKE) glib-stage ncursesw-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(MCABBER_DIR) $(MCABBER_BUILD_DIR)
	$(MCABBER_UNZIP) $(DL_DIR)/$(MCABBER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MCABBER_PATCHES)" ; \
		then cat $(MCABBER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MCABBER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MCABBER_DIR)" != "$(MCABBER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MCABBER_DIR) $(MCABBER_BUILD_DIR) ; \
	fi
	(cd $(MCABBER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MCABBER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MCABBER_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-openssl=$(STAGING_INCLUDE_DIR) \
		--disable-hgcset \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MCABBER_BUILD_DIR)/libtool
	touch $@

mcabber-unpack: $(MCABBER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MCABBER_BUILD_DIR)/.built: $(MCABBER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MCABBER_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mcabber: $(MCABBER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MCABBER_BUILD_DIR)/.staged: $(MCABBER_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MCABBER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mcabber-stage: $(MCABBER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mcabber
#
$(MCABBER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mcabber" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MCABBER_PRIORITY)" >>$@
	@echo "Section: $(MCABBER_SECTION)" >>$@
	@echo "Version: $(MCABBER_VERSION)-$(MCABBER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MCABBER_MAINTAINER)" >>$@
	@echo "Source: $(MCABBER_SITE)/$(MCABBER_SOURCE)" >>$@
	@echo "Description: $(MCABBER_DESCRIPTION)" >>$@
	@echo "Depends: $(MCABBER_DEPENDS)" >>$@
	@echo "Suggests: $(MCABBER_SUGGESTS)" >>$@
	@echo "Conflicts: $(MCABBER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MCABBER_IPK_DIR)/opt/sbin or $(MCABBER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MCABBER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MCABBER_IPK_DIR)/opt/etc/mcabber/...
# Documentation files should be installed in $(MCABBER_IPK_DIR)/opt/doc/mcabber/...
# Daemon startup scripts should be installed in $(MCABBER_IPK_DIR)/opt/etc/init.d/S??mcabber
#
# You may need to patch your application to make it use these locations.
#
$(MCABBER_IPK): $(MCABBER_BUILD_DIR)/.built
	rm -rf $(MCABBER_IPK_DIR) $(BUILD_DIR)/mcabber_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MCABBER_BUILD_DIR) DESTDIR=$(MCABBER_IPK_DIR) install-strip
#	install -d $(MCABBER_IPK_DIR)/opt/etc/
#	install -m 644 $(MCABBER_SOURCE_DIR)/mcabber.conf $(MCABBER_IPK_DIR)/opt/etc/mcabber.conf
#	install -d $(MCABBER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MCABBER_SOURCE_DIR)/rc.mcabber $(MCABBER_IPK_DIR)/opt/etc/init.d/SXXmcabber
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MCABBER_IPK_DIR)/opt/etc/init.d/SXXmcabber
	$(MAKE) $(MCABBER_IPK_DIR)/CONTROL/control
#	install -m 755 $(MCABBER_SOURCE_DIR)/postinst $(MCABBER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MCABBER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MCABBER_SOURCE_DIR)/prerm $(MCABBER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MCABBER_IPK_DIR)/CONTROL/prerm
	echo $(MCABBER_CONFFILES) | sed -e 's/ /\n/g' > $(MCABBER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MCABBER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mcabber-ipk: $(MCABBER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mcabber-clean:
	rm -f $(MCABBER_BUILD_DIR)/.built
	-$(MAKE) -C $(MCABBER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mcabber-dirclean:
	rm -rf $(BUILD_DIR)/$(MCABBER_DIR) $(MCABBER_BUILD_DIR) $(MCABBER_IPK_DIR) $(MCABBER_IPK)
#
#
# Some sanity check for the package.
#
mcabber-check: $(MCABBER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MCABBER_IPK)
