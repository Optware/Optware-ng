###########################################################
#
# transmission
#
###########################################################
#
# TRANSMISSION_VERSION, TRANSMISSION_SITE and TRANSMISSION_SOURCE define
# the upstream location of the source code for the package.
# TRANSMISSION_DIR is the directory which is created when the source
# archive is unpacked.
# TRANSMISSION_UNZIP is the command used to unzip the source.
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
TRANSMISSION_SITE=https://github.com/transmission/transmission-releases/raw/master
TRANSMISSION_VERSION=2.94

#TRANSMISSION_SVN_REV=8696

ifdef TRANSMISSION_SVN_REV
TRANSMISSION_SVN=svn://svn.transmissionbt.com/Transmission/trunk
TRANSMISSION_SOURCE=transmission-svn-$(TRANSMISSION_SVN_REV).tar.bz2
else
TRANSMISSION_SOURCE=transmission-$(TRANSMISSION_VERSION).tar.xz
endif
TRANSMISSION_DIR=transmission-$(TRANSMISSION_VERSION)
TRANSMISSION_UNZIP=$(HOST_STAGING_PREFIX)/bin/xzcat
TRANSMISSION_MAINTAINER=oleo@email.si
TRANSMISSION_DESCRIPTION=Lightweight BitTorrent client and daemon, with web interface bundled.
TRANSMISSION_GTK_DESCRIPTION=Transmission GTK+ torrent client
TRANSMISSION_SECTION=net
TRANSMISSION_PRIORITY=optional
TRANSMISSION_DEPENDS=openssl, libcurl, libevent, zlib, start-stop-daemon
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TRANSMISSION_DEPENDS+=, libiconv
endif
TRANSMISSION_GTK_DEPENDS=$(TRANSMISSION_DEPENDS), gtk, gnome-icon-theme
TRANSMISSION_SUGGESTS=
TRANSMISSION_CONFLICTS=

#
# TRANSMISSION_IPK_VERSION should be incremented when the ipk changes.
#
TRANSMISSION_IPK_VERSION=1

#
# TRANSMISSION_CONFFILES should be a list of user-editable files
TRANSMISSION_CONFFILES=\
$(TARGET_PREFIX)/etc/transmission-daemon/settings.json \
$(TARGET_PREFIX)/etc/init.d/S95transmission \
$(TARGET_PREFIX)/share/transmission/web/index.html

TRANSMISSION_PATCHES=\
$(TRANSMISSION_SOURCE_DIR)/int64_switch.patch \
$(TRANSMISSION_SOURCE_DIR)/uclibc_system_quota.patch \

TRANSMISSION_CONFIG_ENV ?=

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSMISSION_CPPFLAGS=-O3 -DTR_EMBEDDED
TRANSMISSION_LDFLAGS=-lcrypto
TRANSMISSION-DBG_CPPFLAGS=-O0 -g -DTR_EMBEDDED
TRANSMISSION-DBG_LDFLAGS=-lefence -lpthread
ifeq (uclibc, $(LIBC_STYLE))
TRANSMISSION_LDFLAGS+=-lintl
TRANSMISSION-DBG_LDFLAGS+=-lintl
TRANSMISSION_NLS=enable
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TRANSMISSION_LDFLAGS += -liconv
endif
ifeq ($(GETTEXT_NLS), enable)
TRANSMISSION_NLS=enable
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
TRANSMISSION_NLS=enable
endif
ifeq ($(TRANSMISSION_NLS), enable)
TRANSMISSION_DEPENDS+=, gettext
endif


#
# TRANSMISSION_BUILD_DIR is the directory in which the build is done.
# TRANSMISSION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSION_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSION_BUILD_DIR=$(BUILD_DIR)/transmission
TRANSMISSION_SOURCE_DIR=$(SOURCE_DIR)/transmission
TRANSMISSION_IPK_DIR=$(BUILD_DIR)/transmission-$(TRANSMISSION_VERSION)-ipk
ifdef TRANSMISSION_SVN_REV
TRANSMISSION_IPK=$(BUILD_DIR)/transmission_$(TRANSMISSION_VERSION)+r$(TRANSMISSION_SVN_REV)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
else
TRANSMISSION_IPK=$(BUILD_DIR)/transmission_$(TRANSMISSION_VERSION)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

TRANSMISSION_GTK_IPK_DIR=$(BUILD_DIR)/transmission-gtk-$(TRANSMISSION_VERSION)-ipk
ifdef TRANSMISSION_SVN_REV
TRANSMISSION_GTK_IPK=$(BUILD_DIR)/transmission-gtk_$(TRANSMISSION_VERSION)+r$(TRANSMISSION_SVN_REV)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
else
TRANSMISSION_GTK_IPK=$(BUILD_DIR)/transmission-gtk_$(TRANSMISSION_VERSION)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
endif


ifeq (gtk, $(filter gtk, $(PACKAGES)))
TRANSMISSION_IPKS=$(TRANSMISSION_IPK) $(TRANSMISSION_GTK_IPK)
else
TRANSMISSION_IPKS=$(TRANSMISSION_IPK)
endif

#
# TRANSMISSION-DBG_BUILD_DIR is the directory in which the build is done.
# TRANSMISSION-DBG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSION-DBG_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSION-DBG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSION-DBG_BUILD_DIR=$(BUILD_DIR)/transmission-dbg
TRANSMISSION-DBG_SOURCE_DIR=$(SOURCE_DIR)/transmission
TRANSMISSION-DBG_IPK_DIR=$(BUILD_DIR)/transmission-dbg-$(TRANSMISSION_VERSION)-ipk
ifdef TRANSMISSION_SVN_REV
TRANSMISSION-DBG_IPK=$(BUILD_DIR)/transmission-dbg_$(TRANSMISSION_VERSION)+r$(TRANSMISSION_SVN_REV)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
else
TRANSMISSION-DBG_IPK=$(BUILD_DIR)/transmission-dbg_$(TRANSMISSION_VERSION)-$(TRANSMISSION_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

ifeq ($(TRANSMISSION_SOURCE), $(TRANSMISSIOND_SOURCE))
TRANSMISSION_SKIP_FETCH=1
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
TRANSMISSION_CONFIGURE_ARGS=--with-gtk --enable-nls
else
TRANSMISSION_CONFIGURE_ARGS=--without-gtk --disable-nls
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifndef TRANSMISSION_SKIP_FETCH
$(DL_DIR)/$(TRANSMISSION_SOURCE):
#	rm -fv	$(DL_DIR)/transmission*.tar.bz2
ifdef TRANSMISSION_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(TRANSMISSION_DIR) && \
		svn co -r $(TRANSMISSION_SVN_REV) $(TRANSMISSION_SVN) \
			$(TRANSMISSION_DIR) && \
		tar -cjf $@ $(TRANSMISSION_DIR) && \
		rm -rf $(TRANSMISSION_DIR) \
	)
else
	$(WGET) -P $(@D) $(TRANSMISSION_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
transmission-source transmission-dbg-source: $(DL_DIR)/$(TRANSMISSION_SOURCE) $(TRANSMISSION_PATCHES)

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
$(TRANSMISSION_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSION_SOURCE) $(TRANSMISSION_PATCHES) make/transmission.mk
	$(MAKE) openssl-stage libcurl-stage libevent-stage zlib-stage
ifeq ($(TRANSMISSION_NLS), enable)
	$(MAKE) gettext-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(MAKE) gtk-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSION_DIR) $(@D)
ifndef TRANSMISSION_SVN_REV
	mkdir -p $(BUILD_DIR)/$(TRANSMISSION_DIR)
endif
	$(TRANSMISSION_UNZIP) $(DL_DIR)/$(TRANSMISSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSION_PATCHES)" ; \
		then cat $(TRANSMISSION_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TRANSMISSION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSION_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSION_DIR) $(@D) ; \
	fi
#	use '$(TARGET_PREFIX)/etc' instead of $HOME/.config as default transmission home
	sed -i -e 's|return home;|return "$(TARGET_PREFIX)/etc";|' -e 's/".config"/""/' \
		$(@D)/libtransmission/platform.c
ifdef TRANSMISSION_SVN_REV
	$(AUTORECONF1.14) -vif $(@D)
endif
	sed -i -e '/FLAGS=/s|-g ||' $(@D)/configure
	if test `$(TARGET_CC) -dumpversion | cut -c1-3` = "3.3"; then \
		sed -i -e '/CFLAGS/s| -Wdeclaration-after-statement||' $(@D)/configure; \
	fi
	if test `$(TARGET_CC) -dumpversion | cut -c1` = "3"; then \
		sed -i -e '/CFLAGS/s| -Wextra||' -e '/CFLAGS/s| -Winit-self||' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSION_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
                $(TRANSMISSION_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--datadir=$(TARGET_PREFIX)/share \
		$(TRANSMISSION_CONFIGURE_ARGS) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


$(TRANSMISSION-DBG_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSION_SOURCE) $(TRANSMISSION_PATCHES) make/transmission.mk
	$(MAKE) openssl-stage libcurl-stage libevent-stage zlib-stage
ifeq ($(TRANSMISSION_NLS), enable)
	$(MAKE) gettext-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(MAKE) gtk-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSION_DIR) $(@D)
ifndef TRANSMISSION_SVN_REV
	mkdir -p $(BUILD_DIR)/$(TRANSMISSION_DIR)
endif
	$(TRANSMISSION_UNZIP) $(DL_DIR)/$(TRANSMISSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSION_PATCHES)" ; \
		then cat $(TRANSMISSION_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(TRANSMISSION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSION_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSION_DIR) $(@D) ; \
	fi
	if test -n "$(TRANSMISSION-DBG_SOURCES)"; then cp $(TRANSMISSION-DBG_SOURCES) $(@D)/cli; fi
ifdef TRANSMISSION_SVN_REV
	$(AUTORECONF1.14) -vif $(@D)
endif
	if test `$(TARGET_CC) -dumpversion | cut -c1-3` = "3.3"; then \
		sed -i -e 's|-Wdeclaration-after-statement||' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSION-DBG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSION-DBG_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		$(TRANSMISSION_CONFIGURE_ARGS) \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


transmission-unpack: $(TRANSMISSION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSMISSION_BUILD_DIR)/.built: $(TRANSMISSION_BUILD_DIR)/.configured $(TRANSMISSION_SOURCES)
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

$(TRANSMISSION-DBG_BUILD_DIR)/.built: $(TRANSMISSION-DBG_BUILD_DIR)/.configured $(TRANSMISSION-DBG_SOURCES)
	rm -f $@
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ifdef TRANSMISSION_SVN_REV
transmission: $(TRANSMISSION_BUILD_DIR)/.built $(TRANSMISSION-DBG_BUILD_DIR)/.built
else
transmission: $(TRANSMISSION_BUILD_DIR)/.built
endif

#
# If you are building a library, then you need to stage it too.
#
$(TRANSMISSION_BUILD_DIR)/.staged: $(TRANSMISSION_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

transmission-stage: $(TRANSMISSION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  
#
$(TRANSMISSION_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: transmission" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRANSMISSION_PRIORITY)" >>$@
	@echo "Section: $(TRANSMISSION_SECTION)" >>$@
ifdef TRANSMISSION_SVN_REV
	@echo "Version: $(TRANSMISSION_VERSION)+r$(TRANSMISSION_SVN_REV)-$(TRANSMISSION_IPK_VERSION)" >>$@
else
	@echo "Version: $(TRANSMISSION_VERSION)-$(TRANSMISSION_IPK_VERSION)" >>$@
endif
	@echo "Maintainer: $(TRANSMISSION_MAINTAINER)" >>$@
	@echo "Source: $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE)" >>$@
	@echo "Description: $(TRANSMISSION_DESCRIPTION)" >>$@
	@echo "Depends: $(TRANSMISSION_DEPENDS)" >>$@
	@echo "Suggests: $(TRANSMISSION_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRANSMISSION_CONFLICTS)" >>$@

$(TRANSMISSION_GTK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: transmission-gtk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRANSMISSION_PRIORITY)" >>$@
	@echo "Section: $(TRANSMISSION_SECTION)" >>$@
ifdef TRANSMISSION_SVN_REV
	@echo "Version: $(TRANSMISSION_VERSION)+r$(TRANSMISSION_SVN_REV)-$(TRANSMISSION_IPK_VERSION)" >>$@
else
	@echo "Version: $(TRANSMISSION_VERSION)-$(TRANSMISSION_IPK_VERSION)" >>$@
endif
	@echo "Maintainer: $(TRANSMISSION_MAINTAINER)" >>$@
	@echo "Source: $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE)" >>$@
	@echo "Description: $(TRANSMISSION_GTK_DESCRIPTION)" >>$@
	@echo "Depends: $(TRANSMISSION_GTK_DEPENDS)" >>$@
	@echo "Suggests: $(TRANSMISSION_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRANSMISSION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/sbin or $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/transmission/...
# Documentation files should be installed in $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/doc/transmission/...
# Daemon startup scripts should be installed in $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??transmission
#
# You may need to patch your application to make it use these locations.
#
ifdef TRANSMISSION_SVN_REV
$(TRANSMISSION_IPKS): $(TRANSMISSION_BUILD_DIR)/.built \
# $(TRANSMISSION-DBG_BUILD_DIR)/.built
else
$(TRANSMISSION_IPKS): $(TRANSMISSION_BUILD_DIR)/.built
endif
	rm -rf $(TRANSMISSION_IPK_DIR) $(BUILD_DIR)/transmission_*_$(TARGET_ARCH).ipk \
		$(TRANSMISSION_GTK_IPK_DIR) $(BUILD_DIR)/transmission-gtk_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)
	$(MAKE) -C $(TRANSMISSION_BUILD_DIR) DESTDIR=$(TRANSMISSION_IPK_DIR) install-strip
	$(INSTALL) -d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/transmission-daemon
	$(INSTALL) -m 755 $(TRANSMISSION_SOURCE_DIR)/rc.transmission $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S95transmission
	$(INSTALL) -m 644 $(TRANSMISSION_SOURCE_DIR)/settings.json $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/etc/transmission-daemon/
	$(INSTALL) -d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/share/doc/transmission
	$(INSTALL) -m 666 $(TRANSMISSION_BUILD_DIR)/[CNR]*  $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/share/doc/transmission
	$(INSTALL) -d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/var/log
	$(INSTALL) -d $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/var/run
ifeq (gtk, $(filter gtk, $(PACKAGES)))
	$(INSTALL) -d $(TRANSMISSION_GTK_IPK_DIR)$(TARGET_PREFIX)/bin $(TRANSMISSION_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	mv -f $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/bin/transmission-gtk $(TRANSMISSION_GTK_IPK_DIR)$(TARGET_PREFIX)/bin/
	mv -f $(addprefix $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/share/, applications icons pixmaps) \
		$(TRANSMISSION_GTK_IPK_DIR)$(TARGET_PREFIX)/share/
	mv -f $(TRANSMISSION_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/transmission-gtk.1 $(TRANSMISSION_GTK_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/
	$(MAKE) $(TRANSMISSION_GTK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSMISSION_GTK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TRANSMISSION_GTK_IPK_DIR)
endif
	$(MAKE) $(TRANSMISSION_IPK_DIR)/CONTROL/control
	echo $(TRANSMISSION_CONFFILES) | sed -e 's/ /\n/g' > $(TRANSMISSION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSMISSION_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TRANSMISSION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
transmission-ipk: $(TRANSMISSION_IPKS)

#
# This is called from the top level makefile to clean all of the built files.
#
transmission-clean:
	rm -f $(TRANSMISSION_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSION_BUILD_DIR) clean
	rm -f $(TRANSMISSION-DBG_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSION-DBG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
transmission-dirclean:
	rm -rf $(BUILD_DIR)/$(TRANSMISSION_DIR) $(TRANSMISSION_BUILD_DIR) $(TRANSMISSION_IPK_DIR) $(TRANSMISSION_IPK)
	rm -rf $(TRANSMISSION-DBG_BUILD_DIR)

#
# Some sanity check for the package.
# Non stripped transmissiond-dbg is intentional
transmission-check: $(TRANSMISSION_IPKS)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
