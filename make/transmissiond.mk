###########################################################
#
# transmissiond
#
###########################################################
#
# TRANSMISSIOND_VERSION, TRANSMISSIOND_SITE and TRANSMISSIOND_SOURCE define
# the upstream location of the source code for the package.
# TRANSMISSIOND_DIR is the directory which is created when the source
# archive is unpacked.
# TRANSMISSIOND_UNZIP is the command used to unzip the source.
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
#  TRAC: http://trac.transmissiondbt.com/timeline
#
# SVN releases also include transmissiond-dbg while official releases does not.
#
TRANSMISSIOND_SITE=http://download.transmissionbt.com/transmission/files
TRANSMISSIOND_VERSION=1.41b5
#TRANSMISSIOND_SVN=svn://svn.transmissionbt.com/Transmission/trunk
#TRANSMISSIOND_SVN_REV=7069
ifdef TRANSMISSIOND_SVN_REV
TRANSMISSIOND_SOURCE=transmission-svn-$(TRANSMISSIOND_SVN_REV).tar.bz2
else
TRANSMISSIOND_SOURCE=transmission-$(TRANSMISSIOND_VERSION).tar.bz2
endif
TRANSMISSIOND_DIR=transmission-$(TRANSMISSIOND_VERSION)
TRANSMISSIOND_UNZIP=bzcat
TRANSMISSIOND_MAINTAINER=oleo@email.si
TRANSMISSIOND_DESCRIPTION=lightweight BitTorrent daemon with CGI WWW interface
TRANSMISSIOND_SECTION=net
TRANSMISSIOND_PRIORITY=optional
TRANSMISSIOND_DEPENDS=openssl, libcurl
TRANSMISSIOND_SUGGESTS=gnuplot, logrotate, thttpd, mini-sendmail, transmission
TRANSMISSIOND_CONFLICTS=torrent

#
# TRANSMISSIOND_IPK_VERSION should be incremented when the ipk changes.
#
TRANSMISSIOND_IPK_VERSION=1

# TRANSMISSIOND-DBG_INCLUDED=1

#
# TRANSMISSIOND_CONFFILES should be a list of user-editable files
TRANSMISSIOND_CONFFILES=/opt/etc/transmission.conf

TRANSMISSIOND_CONFFILES += /opt/etc/init.d/S80busybox_httpd

#
# TRANSMISSIOND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TRANSMISSIOND_PATCHES=
#\
#	$(TRANSMISSIOND_SOURCE_DIR)/cli-Makefile.am.patch \

# Additional sources to enhance transmissiond (like this CGI daemon)
TRANSMISSIOND_SOURCES=$(TRANSMISSIOND_SOURCE_DIR)/transmissiond.c \
			$(TRANSMISSIOND_SOURCE_DIR)/transmissiond.1

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSMISSIOND_CPPFLAGS=-O3 -DTR_EMBEDDED
TRANSMISSIOND_LDFLAGS=
TRANSMISSIOND-DBG_CPPFLAGS=-O0 -g -DTR_EMBEDDED
TRANSMISSIOND-DBG_LDFLAGS=-lefence -lpthread
ifeq (uclibc, $(LIBC_STYLE))
TRANSMISSIOND_LDFLAGS+=-lintl
TRANSMISSIOND-DBG_LDFLAGS+=-lintl
endif
ifeq ($(GETTEXT_NLS), enable)
TRANSMISSIOND_DEPENDS+=, gettext
endif

#
# TRANSMISSIOND_BUILD_DIR is the directory in which the build is done.
# TRANSMISSIOND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSIOND_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSIOND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSIOND_BUILD_DIR=$(BUILD_DIR)/transmissiond
TRANSMISSIOND_SOURCE_DIR=$(SOURCE_DIR)/transmissiond
TRANSMISSIOND_IPK_DIR=$(BUILD_DIR)/transmissiond-$(TRANSMISSIOND_VERSION)-ipk
ifdef TRANSMISSIOND_SVN_REV
TRANSMISSIOND_IPK=$(BUILD_DIR)/transmissiond_$(TRANSMISSIOND_VERSION)+r$(TRANSMISSIOND_SVN_REV)-$(TRANSMISSIOND_IPK_VERSION)_$(TARGET_ARCH).ipk
else
TRANSMISSIOND_IPK=$(BUILD_DIR)/transmissiond_$(TRANSMISSIOND_VERSION)-$(TRANSMISSIOND_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

#
# TRANSMISSIOND-DBG_BUILD_DIR is the directory in which the build is done.
# TRANSMISSIOND-DBG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TRANSMISSIOND-DBG_IPK_DIR is the directory in which the ipk is built.
# TRANSMISSIOND-DBG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TRANSMISSIOND-DBG_BUILD_DIR=$(BUILD_DIR)/transmissiond-dbg
TRANSMISSIOND-DBG_SOURCE_DIR=$(SOURCE_DIR)/transmissiond
TRANSMISSIOND-DBG_IPK_DIR=$(BUILD_DIR)/transmissiond-dbg-$(TRANSMISSIOND_VERSION)-ipk
ifdef TRANSMISSIOND-DBG_INCLUDED
TRANSMISSIOND-DBG_IPK=$(BUILD_DIR)/transmissiond-dbg_$(TRANSMISSIOND_VERSION)+r$(TRANSMISSIOND_SVN_REV)-$(TRANSMISSIOND_IPK_VERSION)_$(TARGET_ARCH).ipk
else
TRANSMISSIOND-DBG_IPK=$(BUILD_DIR)/transmissiond-dbg_$(TRANSMISSIOND_VERSION)-$(TRANSMISSIOND_IPK_VERSION)_$(TARGET_ARCH).ipk
endif


ifeq ($(TRANSMISSION_SOURCE), $(TRANSMISSIOND_SOURCE))
TRANSMISSIOND_SKIP_FETCH=1
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
ifndef TRANSMISSIOND_SKIP_FETCH
$(DL_DIR)/$(TRANSMISSIOND_SOURCE):
ifdef TRANSMISSIOND_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(TRANSMISSIOND_DIR) && \
		svn co -r $(TRANSMISSIOND_SVN_REV) $(TRANSMISSIOND_SVN) \
			$(TRANSMISSIOND_DIR) && \
		tar -cjf $@ $(TRANSMISSIOND_DIR) && \
		rm -rf $(TRANSMISSIOND_DIR) \
	)
else
	$(WGET) -P $(@D) $(TRANSMISSIOND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
transmissiond-source transmissiond-dbg-source: $(DL_DIR)/$(TRANSMISSIOND_SOURCE) $(TRANSMISSIOND_PATCHES)

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
# better to use Transmissiond provided (built-in) SHA1 hash
#
$(TRANSMISSIOND_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSIOND_SOURCE) $(TRANSMISSIOND_PATCHES) make/transmissiond.mk
	$(MAKE) openssl-stage libcurl-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSIOND_DIR) $(TRANSMISSIOND_BUILD_DIR)
ifndef TRANSMISSIOND_SVN_REV
	mkdir -p $(BUILD_DIR)/$(TRANSMISSIOND_DIR)
endif
	$(TRANSMISSIOND_UNZIP) $(DL_DIR)/$(TRANSMISSIOND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSIOND_PATCHES)" ; \
		then cat $(TRANSMISSIOND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TRANSMISSIOND_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSIOND_DIR)" != "$(TRANSMISSIOND_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSIOND_DIR) $(TRANSMISSIOND_BUILD_DIR) ; \
	fi
	if test -n "$(TRANSMISSIOND_SOURCES)"; then cp $(TRANSMISSIOND_SOURCES) $(@D)/cli; fi
	sed -i -e 's|-Wdeclaration-after-statement||' $(@D)/configure*
ifdef TRANSMISSIOND_SVN_REV 
	if test -x "$(@D)/autogen.sh"; \
	then cd $(@D) && ./autogen.sh; \
	else autoreconf -vif $(@D); \
	fi
endif
	sed -i -e '/FLAGS=/s|-g ||' $(@D)/configure*
	sed -i  -e 's/transmissioncli/transmissiond/g' \
		-e 's/cli./transmissiond./g' $(@D)/cli/Makefile*
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSIOND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSIOND_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--datadir=/opt/share \
		--disable-gtk \
		--disable-wx \
		--disable-nls \
	)
#		--disable-daemon \
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


$(TRANSMISSIOND-DBG_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSIOND_SOURCE) $(TRANSMISSIOND_PATCHES) make/transmissiond.mk
	$(MAKE) openssl-stage electric-fence-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(TRANSMISSIOND_DIR) $(TRANSMISSIOND-DBG_BUILD_DIR)
ifndef TRANSMISSIOND_SVN_REV
	mkdir -p $(BUILD_DIR)/$(TRANSMISSIOND_DIR)
endif
	$(TRANSMISSIOND_UNZIP) $(DL_DIR)/$(TRANSMISSIOND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TRANSMISSIOND_PATCHES)" ; \
		then cat $(TRANSMISSIOND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TRANSMISSIOND_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSIOND_DIR)" != "$(TRANSMISSIOND-DBG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSIOND_DIR) $(TRANSMISSIOND-DBG_BUILD_DIR) ; \
	fi
	if test -n "$(TRANSMISSIOND-DBG_SOURCES)"; then cp $(TRANSMISSIOND-DBG_SOURCES) $(@D)/cli; fi
ifdef TRANSMISSIOND_SVN_REV
	if test -x "$(@D)/autogen.sh"; \
	then cd $(@D) && ./autogen.sh; \
	else autoreconf -vif $(@D); \
	fi
endif
	if test `$(TARGET_CC) -dumpversion | cut -c1-3` = "3.3"; then \
		sed -i -e 's|-Wdeclaration-after-statement||' $(@D)/configure; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSIOND-DBG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSIOND-DBG_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--datadir=/opt/share \
		--disable-gtk \
		--disable-wx \
		--disable-nls \
	)
#		--disable-daemon \
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@


transmissiond-unpack: $(TRANSMISSIOND_BUILD_DIR)/.configured $(TRANSMISSIOND-DBG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSMISSIOND_BUILD_DIR)/.built: $(TRANSMISSIOND_BUILD_DIR)/.configured $(TRANSMISSIOND_SOURCES)
	rm -f $@
	cp $(TRANSMISSIOND_SOURCES) $(@D)/cli
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

$(TRANSMISSIOND-DBG_BUILD_DIR)/.built: $(TRANSMISSIOND-DBG_BUILD_DIR)/.configured $(TRANSMISSIOND-DBG_SOURCES)
	rm -f $@
	cp $(TRANSMISSIOND_SOURCES) $(@D)/cli
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
ifdef TRANSMISSIOND-DBG_INCLUDED
transmissiond: $(TRANSMISSIOND_BUILD_DIR)/.built $(TRANSMISSIOND-DBG_BUILD_DIR)/.built
else
transmissiond: $(TRANSMISSIOND_BUILD_DIR)/.built
endif

#
# If you are building a library, then you need to stage it too.
#
$(TRANSMISSIOND_BUILD_DIR)/.staged: $(TRANSMISSIOND_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

transmissiond-stage: $(TRANSMISSIOND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  
#
$(TRANSMISSIOND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: transmissiond" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TRANSMISSIOND_PRIORITY)" >>$@
	@echo "Section: $(TRANSMISSIOND_SECTION)" >>$@
ifdef TRANSMISSIOND_SVN_REV
	@echo "Version: $(TRANSMISSIOND_VERSION)+r$(TRANSMISSIOND_SVN_REV)-$(TRANSMISSIOND_IPK_VERSION)" >>$@
else
	@echo "Version: $(TRANSMISSIOND_VERSION)-$(TRANSMISSIOND_IPK_VERSION)" >>$@
endif
	@echo "Maintainer: $(TRANSMISSIOND_MAINTAINER)" >>$@
	@echo "Source: $(TRANSMISSIOND_SITE)/$(TRANSMISSIOND_SOURCE)" >>$@
	@echo "Description: $(TRANSMISSIOND_DESCRIPTION)" >>$@
	@echo "Depends: $(TRANSMISSIOND_DEPENDS)" >>$@
	@echo "Suggests: $(TRANSMISSIOND_SUGGESTS)" >>$@
	@echo "Conflicts: $(TRANSMISSIOND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSMISSIOND_IPK_DIR)/opt/sbin or $(TRANSMISSIOND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSMISSIOND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRANSMISSIOND_IPK_DIR)/opt/etc/transmissiond/...
# Documentation files should be installed in $(TRANSMISSIOND_IPK_DIR)/opt/doc/transmissiond/...
# Daemon startup scripts should be installed in $(TRANSMISSIOND_IPK_DIR)/opt/etc/init.d/S??transmissiond
#
# You may need to patch your application to make it use these locations.
#
ifdef TRANSMISSIOND-DBG_INCLUDED
$(TRANSMISSIOND_IPK): $(TRANSMISSIOND_BUILD_DIR)/.built $(TRANSMISSIOND-DBG_BUILD_DIR)/.built
else
$(TRANSMISSIOND_IPK): $(TRANSMISSIOND_BUILD_DIR)/.built
endif
	rm -rf $(TRANSMISSIOND_IPK_DIR) $(BUILD_DIR)/transmissiond_*_$(TARGET_ARCH).ipk
	install -d $(TRANSMISSIOND_IPK_DIR)/opt
	$(MAKE) -C $(TRANSMISSIOND_BUILD_DIR) DESTDIR=$(TRANSMISSIOND_IPK_DIR) install-strip
	rm -f $(TRANSMISSIOND_IPK_DIR)/opt/bin/transmission-*
	rm -rf $(TRANSMISSIOND_IPK_DIR)/opt/share/man
	rm -rf $(TRANSMISSIOND_IPK_DIR)/opt/share/transmission
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/etc
	install -m 644 $(TRANSMISSIOND_SOURCE_DIR)/transmission.conf $(TRANSMISSIOND_IPK_DIR)/opt/etc/transmission.conf
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/share/doc/transmissiond
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/etc/init.d
	install -m 755 $(TRANSMISSIOND_SOURCE_DIR)/S80busybox_httpd $(TRANSMISSIOND_IPK_DIR)/opt/etc/init.d
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/share/www/cgi-bin
	install -m 755 $(TRANSMISSIOND_SOURCE_DIR)/transmission.cgi $(TRANSMISSIOND_IPK_DIR)/opt/share/www/cgi-bin
ifdef TRANSMISSIOND-DBG_INCLUDED
	install -m 755 $(TRANSMISSIOND-DBG_BUILD_DIR)/cli/transmissiond $(TRANSMISSIOND_IPK_DIR)/opt/bin/transmissiond-dbg
endif
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/sbin
	install -m 755 $(TRANSMISSIOND_SOURCE_DIR)/transmission_watchdog $(TRANSMISSIOND_IPK_DIR)/opt/sbin
	install -m 666 $(TRANSMISSIOND_SOURCE_DIR)/README.daemon $(TRANSMISSIOND_IPK_DIR)/opt/share/doc/transmissiond
	install -m 666 $(TRANSMISSIOND_BUILD_DIR)/NEWS $(TRANSMISSIOND_IPK_DIR)/opt/share/doc/transmissiond
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/var/log
	install -d $(TRANSMISSIOND_IPK_DIR)/opt/var/run
	$(MAKE) $(TRANSMISSIOND_IPK_DIR)/CONTROL/control
	install -m 755 $(TRANSMISSIOND_SOURCE_DIR)/postinst $(TRANSMISSIOND_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TRANSMISSIOND_SOURCE_DIR)/prerm $(TRANSMISSIOND_IPK_DIR)/CONTROL/prerm
	echo $(TRANSMISSIOND_CONFFILES) | sed -e 's/ /\n/g' > $(TRANSMISSIOND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSMISSIOND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
transmissiond-ipk: $(TRANSMISSIOND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
transmissiond-clean:
	rm -f $(TRANSMISSIOND_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSIOND_BUILD_DIR) clean
	rm -f $(TRANSMISSIOND-DBG_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSIOND-DBG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
transmissiond-dirclean:
	rm -rf $(BUILD_DIR)/$(TRANSMISSIOND_DIR) $(TRANSMISSIOND_BUILD_DIR) $(TRANSMISSIOND_IPK_DIR) $(TRANSMISSIOND_IPK)
	rm -rf $(TRANSMISSIOND-DBG_BUILD_DIR)

#
# Some sanity check for the package.
# Non stripped transmissiond-dbg is intentional
transmissiond-check: $(TRANSMISSIOND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRANSMISSIOND_IPK)
