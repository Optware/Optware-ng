###########################################################
#
# transmissiondcfp
#
###########################################################
#
# TRANSMISSIONDCFP_VERSION, TRANSMISSIONDCFP_SITE and TRANSMISSIONDCFP_SOURCE define
# the upstream location of the source code for the package.
# TRANSMISSIONDCFP_DIR is the directory which is created when the source
# archive is unpacked.
# TRANSMISSIONDCFP_UNZIP is the command used to unzip the source.
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
#  TRAC: http://trac.transmissionbt.com/timeline
#
# SVN releases also include transmissiond-dbg while official releases does not.
#
TRANSMISSIONDCFP_SITE=http://$(SOURCEFORGE_MIRROR)/project/transmissiondaemon/embedded-2018-12-19
TRANSMISSIONDCFP_VERSION=2.77+14734-17
TRANSMISSIONDCFP_ALT_VERSION=2.77plus14734-17
TRANSMISSIONDCFP_ALT2_VERSION=2.77plus14734-17
TRANSMISSIONDCFP_ALT_SITE=https://raw.githubusercontent.com/cfpp2p/transmission/Windows_Daemon_%26_Clients/nslu2-unslung-embeded
TRANSMISSIONDCFP_ALT2_SITE=http://transmissionbt.net


TRANSMISSIONDCFP_SOURCE=transmissiondcfp-$(TRANSMISSIONDCFP_VERSION).tar.bz2
TRANSMISSIONDCFP_ALT_SOURCE=transmissiondcfp-$(TRANSMISSIONDCFP_ALT_VERSION).tar.bz2
TRANSMISSIONDCFP_ALT2_SOURCE=transmissiondcfp-$(TRANSMISSIONDCFP_ALT2_VERSION).tar.bz2.zip

TRANSMISSIONDCFP_DIR=transmissiondcfp-$(TRANSMISSIONDCFP_VERSION)
TRANSMISSIONDCFP_UNZIP=bzcat
TRANSMISSIONDCFP_MAINTAINER=http://sourceforge.net/u/cfpp2p/profile/
TRANSMISSIONDCFP_DESCRIPTION=Lightweight BitTorrent daemon.
TRANSMISSIONDCFP_SECTION=net
TRANSMISSIONDCFP_PRIORITY=optional
TRANSMISSIONDCFP_DEPENDS=openssl, libcurl, libevent, zlib
ifeq ($(GETTEXT_NLS), enable)
TRANSMISSIONDCFP_DEPENDS+=, gettext
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TRANSMISSIONDCFP_DEPENDS+=, libiconv
endif
TRANSMISSIONDCFP_SUGGESTS=
TRANSMISSIONDCFP_CONFLICTS=

#
# TRANSMISSIONDCFP_IPK_VERSION should be incremented when the ipk changes.
#
TRANSMISSIONDCFP_IPK_VERSION=1

#
# TRANSMISSIONDCFP_CONFFILES should be a list of user-editable files
#TRANSMISSIONDCFP_CONFFILES=$(TARGET_PREFIX)/etc/transmissiondcfp.conf

TRANSMISSIONDCFP_PATCHES = $(TRANSMISSIONDCFP_SOURCE_DIR)/int64_switch.patch

TRANSMISSIONDCFP_CONFIG_ENV ?=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSMISSIONDCFP_CPPFLAGS=-O3 -DTR_EMBEDDED
TRANSMISSIONDCFP_LDFLAGS=-lcrypto
TRANSMISSIONDCFP-DBG_CPPFLAGS=-O0 -g -DTR_EMBEDDED
TRANSMISSIONDCFP-DBG_LDFLAGS=-lefence -lpthread
ifeq (uclibc, $(LIBC_STYLE))
TRANSMISSIONDCFP_LDFLAGS+=-lintl
TRANSMISSIONDCFP-DBG_LDFLAGS+=-lintl
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TRANSMISSIONDCFP_LDFLAGS+=-liconv
TRANSMISSIONDCFP-DBG_LDFLAGS+=-liconv
endif

#
# TRANSMISSIONDCFP_BUILD_DIR is the directory in which the build is done.
# TRANSMISSIONDCFP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSIONDCFP_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSIONDCFP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSIONDCFP_BUILD_DIR=$(BUILD_DIR)/transmissiondcfp
TRANSMISSIONDCFP_SOURCE_DIR=$(SOURCE_DIR)/transmissiondcfp
TRANSMISSIONDCFP_IPK_DIR=$(BUILD_DIR)/transmissiondcfp-$(TRANSMISSIONDCFP_VERSION)-ipk

TRANSMISSIONDCFP_IPK=$(BUILD_DIR)/transmissiondcfp_$(TRANSMISSIONDCFP_VERSION)-$(TRANSMISSIONDCFP_IPK_VERSION)_$(TARGET_ARCH).ipk


#
# TRANSMISSIONDCFP-DBG_BUILD_DIR is the directory in which the build is done.
# TRANSMISSIONDCFP-DBG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSIONDCFP-DBG_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSIONDCFP-DBG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSIONDCFP-DBG_BUILD_DIR=$(BUILD_DIR)/transmissiondcfp-dbg
TRANSMISSIONDCFP-DBG_SOURCE_DIR=$(SOURCE_DIR)/transmissiondcfp
TRANSMISSIONDCFP-DBG_IPK_DIR=$(BUILD_DIR)/transmissiondcfp-dbg-$(TRANSMISSIONDCFP_VERSION)-ipk

TRANSMISSIONDCFP-DBG_IPK=$(BUILD_DIR)/transmissiondcfp-dbg_$(TRANSMISSIONDCFP_VERSION)-$(TRANSMISSIONDCFP_IPK_VERSION)_$(TARGET_ARCH).ipk


ifeq ($(TRANSMISSIONDCFP_SOURCE), $(TRANSMISSIOND_SOURCE))
TRANSMISSIONDCFP_SKIP_FETCH=1
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifndef TRANSMISSIONDCFP_SKIP_FETCH
$(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE):
#	rm -fv	$(DL_DIR)/transmissiondcfp*.tar.bz2

	$(WGET) -P $(@D) $(TRANSMISSIONDCFP_SITE)/$(@F) || \
	$(WGET) -O $@ $(TRANSMISSIONDCFP_ALT_SITE)/$(TRANSMISSIONDCFP_ALT_SOURCE) || \
	$(WGET) -O $@ $(TRANSMISSIONDCFP_ALT2_SITE)/$(TRANSMISSIONDCFP_ALT2_SOURCE) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
transmissiondcfp-source transmissiondcfp-dbg-source: $(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE) $(TRANSMISSIONDCFP_PATCHES)

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
# Note that openssl is used only for SHA1 hash calculation and that it looks 
# better to use Transmission provided (built-in) SHA1 hash
#
$(TRANSMISSIONDCFP_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE) $(TRANSMISSIONDCFP_PATCHES) make/transmissiondcfp.mk
	$(MAKE) openssl-stage libcurl-stage libevent-stage zlib-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) $(@D)

	mkdir -p $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR)
	$(TRANSMISSIONDCFP_UNZIP) $(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSIONDCFP_PATCHES)" ; \
		then cat $(TRANSMISSIONDCFP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) $(@D) ; \
	fi

	sed -i -e '/FLAGS=/s|-g ||' $(@D)/configure
	if test `$(TARGET_CC) -dumpversion | cut -c1-3` = "3.3"; then \
		sed -i -e '/CFLAGS/s| -Wdeclaration-after-statement||' $(@D)/configure; \
	fi
	if test `$(TARGET_CC) -dumpversion | cut -c1` = "3"; then \
		sed -i -e '/CFLAGS/s| -Wextra||' -e '/CFLAGS/s| -Winit-self||' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSIONDCFP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSIONDCFP_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
                $(TRANSMISSIONDCFP_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--datadir=$(TARGET_PREFIX)/share \
		--disable-gtk \
		--disable-wx \
		--disable-nls \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


$(TRANSMISSIONDCFP-DBG_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE) $(TRANSMISSIONDCFP_PATCHES) make/transmissiondcfp.mk
	$(MAKE) openssl-stage electric-fence-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) $(@D)

	mkdir -p $(BUILD_DIR)/$(TRANSMISSION_DIR)
	$(TRANSMISSIONDCFP_UNZIP) $(DL_DIR)/$(TRANSMISSIONDCFP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSIONDCFP_PATCHES)" ; \
		then cat $(TRANSMISSIONDCFP_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) $(@D) ; \
	fi
	if test -n "$(TRANSMISSIONDCFP-DBG_SOURCES)"; then cp $(TRANSMISSIONDCFP-DBG_SOURCES) $(@D)/cli; fi

	if test `$(TARGET_CC) -dumpversion | cut -c1-3` = "3.3"; then \
		sed -i -e 's|-Wdeclaration-after-statement||' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSIONDCFP-DBG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSIONDCFP-DBG_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-gtk \
		--disable-wx \
		--disable-nls \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


transmissiondcfp-unpack: $(TRANSMISSIONDCFP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSMISSIONDCFP_BUILD_DIR)/.built: $(TRANSMISSIONDCFP_BUILD_DIR)/.configured $(TRANSMISSIONDCFP_SOURCES)
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

$(TRANSMISSIONDCFP-DBG_BUILD_DIR)/.built: $(TRANSMISSIONDCFP-DBG_BUILD_DIR)/.configured $(TRANSMISSIONDCFP-DBG_SOURCES)
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#

transmissiondcfp: $(TRANSMISSIONDCFP_BUILD_DIR)/.built


#
# If you are building a library, then you need to stage it too.
#
$(TRANSMISSIONDCFP_BUILD_DIR)/.staged: $(TRANSMISSIONDCFP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

transmissiondcfp-stage: $(TRANSMISSIONDCFP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  
#
$(TRANSMISSIONDCFP_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: transmissiondcfp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRANSMISSIONDCFP_PRIORITY)" >>$@
	@echo "Section: $(TRANSMISSIONDCFP_SECTION)" >>$@

	@echo "Version: $(TRANSMISSIONDCFP_VERSION)-$(TRANSMISSIONDCFP_IPK_VERSION)" >>$@

	@echo "Maintainer: $(TRANSMISSIONDCFP_MAINTAINER)" >>$@
	@echo "Source: $(TRANSMISSIONDCFP_SITE)/$(TRANSMISSIONDCFP_SOURCE)" >>$@
	@echo "Description: $(TRANSMISSIONDCFP_DESCRIPTION)" >>$@
	@echo "Depends: $(TRANSMISSIONDCFP_DEPENDS)" >>$@
	@echo "Suggests: $(TRANSMISSIONDCFP_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRANSMISSIONDCFP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/sbin or $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/etc/transmissiondcfp/...
# Documentation files should be installed in $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/doc/transmissiondcfp/...
# Daemon startup scripts should be installed in $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??transmissiondcfp
#
# You may need to patch your application to make it use these locations.
#

$(TRANSMISSIONDCFP_IPK): $(TRANSMISSIONDCFP_BUILD_DIR)/.built

	rm -rf $(TRANSMISSIONDCFP_IPK_DIR) $(BUILD_DIR)/transmissiondcfp_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) -C $(TRANSMISSIONDCFP_BUILD_DIR) DESTDIR=$(TRANSMISSIONDCFP_IPK_DIR) install-strip
#	$(INSTALL) -d $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/etc
#	$(INSTALL) -m 644 $(TRANSMISSIONDCFP_SOURCE_DIR)/transmissiondcfp.conf $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/etc/transmissiondcfp.conf
	$(INSTALL) -d $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/share/doc/transmissiondcfp
	$(INSTALL) -m 666 $(TRANSMISSIONDCFP_BUILD_DIR)/[CNR]*  $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/share/doc/transmissiondcfp
	$(INSTALL) -d $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/var/log
	$(INSTALL) -d $(TRANSMISSIONDCFP_IPK_DIR)$(TARGET_PREFIX)/var/run
	$(MAKE) $(TRANSMISSIONDCFP_IPK_DIR)/CONTROL/control
	$(INSTALL) -m 755 $(TRANSMISSIONDCFP_SOURCE_DIR)/postinst $(TRANSMISSIONDCFP_IPK_DIR)/CONTROL/postinst
	echo $(TRANSMISSIONDCFP_CONFFILES) | sed -e 's/ /\n/g' > $(TRANSMISSIONDCFP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSMISSIONDCFP_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TRANSMISSIONDCFP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
transmissiondcfp-ipk: $(TRANSMISSIONDCFP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
transmissiondcfp-clean:
	rm -f $(TRANSMISSIONDCFP_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSIONDCFP_BUILD_DIR) clean
	rm -f $(TRANSMISSIONDCFP-DBG_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSIONDCFP-DBG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
transmissiondcfp-dirclean:
	rm -rf $(BUILD_DIR)/$(TRANSMISSIONDCFP_DIR) $(TRANSMISSIONDCFP_BUILD_DIR) $(TRANSMISSIONDCFP_IPK_DIR) $(TRANSMISSIONDCFP_IPK)
	rm -rf $(TRANSMISSIONDCFP-DBG_BUILD_DIR)

#
# Some sanity check for the package.
# Non stripped transmissiond-dbg is intentional
transmissiondcfp-check: $(TRANSMISSIONDCFP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
