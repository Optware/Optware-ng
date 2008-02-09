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
TRANSMISSION_SITE=http://download.transmissionbt.com/transmission/files
TRANSMISSION_VERSION=1.05
TRANSMISSION_SVN=svn://svn.transmissionbt.com/Transmission/trunk
TRANSMISSION_SVN_REV=5000
ifdef TRANSMISSION_SVN_REV
TRANSMISSION_SOURCE=transmission-svn-$(TRANSMISSION_SVN_REV).tar.bz2
else
TRANSMISSION_SOURCE=transmission-$(TRANSMISSION_VERSION).tar.bz2
endif
TRANSMISSION_DIR=transmission-$(TRANSMISSION_VERSION)
TRANSMISSION_UNZIP=bzcat
TRANSMISSION_MAINTAINER=oleo@email.si
TRANSMISSION_DESCRIPTION=lightweight BitTorrent client and daemon with WWW interface
TRANSMISSION_SECTION=net
TRANSMISSION_PRIORITY=optional
TRANSMISSION_DEPENDS=openssl
TRANSMISSION_SUGGESTS=gnuplot, logrotate, thttpd, mini-sendmail
TRANSMISSION_CONFLICTS=torrent

#
# TRANSMISSION_IPK_VERSION should be incremented when the ipk changes.
#
TRANSMISSION_IPK_VERSION=1

#
# TRANSMISSION_CONFFILES should be a list of user-editable files
TRANSMISSION_CONFFILES=/opt/etc/transmission.conf /opt/etc/init.d/S80busybox_httpd

#
# TRANSMISSION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
TRANSMISSION_PATCHES= \
	$(TRANSMISSION_SOURCE_DIR)/cli-Makefile.am.patch \
	$(TRANSMISSION_SOURCE_DIR)/iterate.patch \
	$(TRANSMISSION_SOURCE_DIR)/transmissionh.patch \

# Additional sources to enhance transmission (like this CGI daemon)
TRANSMISSION_SOURCES=$(TRANSMISSION_SOURCE_DIR)/transmissiond.c \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TRANSMISSION_CPPFLAGS=-O3
TRANSMISSION_LDFLAGS=

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

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(TRANSMISSION_SOURCE):
#	$(WGET) -P $(DL_DIR) $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE)

$(DL_DIR)/$(TRANSMISSION_SOURCE):
	rm -fv	$(DL_DIR)/transmission*.tar.bz2
ifdef TRANSMISSION_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(TRANSMISSION_DIR) && \
		svn co -r $(TRANSMISSION_SVN_REV) $(TRANSMISSION_SVN) \
			$(TRANSMISSION_DIR) && \
		tar -cjf $@ $(TRANSMISSION_DIR) && \
		rm -rf $(TRANSMISSION_DIR) \
	)
else
	$(WGET) -P $(DL_DIR) $(TRANSMISSION_SITE)/$(TRANSMISSION_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TRANSMISSION_SOURCE)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
transmission-source: $(DL_DIR)/$(TRANSMISSION_SOURCE) $(TRANSMISSION_PATCHES)

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
$(TRANSMISSION_BUILD_DIR)/.configured: $(DL_DIR)/$(TRANSMISSION_SOURCE) $(TRANSMISSION_PATCHES) 
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(TRANSMISSION_DIR) $(TRANSMISSION_BUILD_DIR)
ifdef TRANSMISSION_SVN_REV
	$(TRANSMISSION_UNZIP) $(DL_DIR)/$(TRANSMISSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
else
	mkdir -p $(BUILD_DIR)/$(TRANSMISSION_DIR)
	$(TRANSMISSION_UNZIP) $(DL_DIR)/$(TRANSMISSION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
endif
	if test -n "$(TRANSMISSION_PATCHES)" ; \
		then cat $(TRANSMISSION_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TRANSMISSION_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(TRANSMISSION_DIR)" != "$(TRANSMISSION_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TRANSMISSION_DIR) $(TRANSMISSION_BUILD_DIR) ; \
	fi
	sed -i -e 's/-g / /' $(TRANSMISSION_BUILD_DIR)/configure.ac
	(cd $(TRANSMISSION_BUILD_DIR); \
		AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 ./autogen.sh && \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TRANSMISSION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TRANSMISSION_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		PKG_CONFIG_LIBDIR="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-gtk \
		--disable-wx \
		--disable-nls \
	)
#		AUTOMAKE=automake-1.9 ACLOCAL=aclocal-1.9 autoreconf -fi -I m4 ; \
#		--verbose \
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

transmission-unpack: $(TRANSMISSION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TRANSMISSION_BUILD_DIR)/.built: $(TRANSMISSION_BUILD_DIR)/.configured $(TRANSMISSION_SOURCES)
	rm -f $@
	cp $(TRANSMISSION_SOURCES) $(@D)/cli
	$(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
transmission: $(TRANSMISSION_BUILD_DIR)/.built

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
	@install -d $(@D)
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(TRANSMISSION_IPK_DIR)/opt/sbin or $(TRANSMISSION_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TRANSMISSION_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TRANSMISSION_IPK_DIR)/opt/etc/transmission/...
# Documentation files should be installed in $(TRANSMISSION_IPK_DIR)/opt/doc/transmission/...
# Daemon startup scripts should be installed in $(TRANSMISSION_IPK_DIR)/opt/etc/init.d/S??transmission
#
# You may need to patch your application to make it use these locations.
#
$(TRANSMISSION_IPK): $(TRANSMISSION_BUILD_DIR)/.built
	rm -rf $(TRANSMISSION_IPK_DIR) $(BUILD_DIR)/transmission_*_$(TARGET_ARCH).ipk
	install -d $(TRANSMISSION_IPK_DIR)/opt
	$(MAKE) -C $(TRANSMISSION_BUILD_DIR) DESTDIR=$(TRANSMISSION_IPK_DIR) install-strip
	install -d $(TRANSMISSION_IPK_DIR)/opt/etc
	install -m 644 $(TRANSMISSION_SOURCE_DIR)/transmission.conf $(TRANSMISSION_IPK_DIR)/opt/etc/transmission.conf
	install -d $(TRANSMISSION_IPK_DIR)/opt/etc/init.d
	install -m 755 $(TRANSMISSION_SOURCE_DIR)/S80busybox_httpd $(TRANSMISSION_IPK_DIR)/opt/etc/init.d
	install -d $(TRANSMISSION_IPK_DIR)/opt/share/www/cgi-bin
	install -m 755 $(TRANSMISSION_SOURCE_DIR)/transmission.cgi $(TRANSMISSION_IPK_DIR)/opt/share/www/cgi-bin
	install -d $(TRANSMISSION_IPK_DIR)/opt/sbin
	install -m 755 $(TRANSMISSION_SOURCE_DIR)/transmission_watchdog $(TRANSMISSION_IPK_DIR)/opt/sbin
	install -d $(TRANSMISSION_IPK_DIR)/opt/share/doc/transmission
	install -m 666 $(TRANSMISSION_SOURCE_DIR)/README.daemon $(TRANSMISSION_IPK_DIR)/opt/share/doc/transmission
	install -m 666 $(TRANSMISSION_BUILD_DIR)/NEWS $(TRANSMISSION_IPK_DIR)/opt/share/doc/transmission
	install -d $(TRANSMISSION_IPK_DIR)/opt/var/log
	install -d $(TRANSMISSION_IPK_DIR)/opt/var/run
	$(MAKE) $(TRANSMISSION_IPK_DIR)/CONTROL/control
	install -m 755 $(TRANSMISSION_SOURCE_DIR)/postinst $(TRANSMISSION_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TRANSMISSION_SOURCE_DIR)/prerm $(TRANSMISSION_IPK_DIR)/CONTROL/prerm
	echo $(TRANSMISSION_CONFFILES) | sed -e 's/ /\n/g' > $(TRANSMISSION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TRANSMISSION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
transmission-ipk: $(TRANSMISSION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
transmission-clean:
	rm -f $(TRANSMISSION_BUILD_DIR)/.built
	-$(MAKE) -C $(TRANSMISSION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
transmission-dirclean:
	rm -rf $(BUILD_DIR)/$(TRANSMISSION_DIR) $(TRANSMISSION_BUILD_DIR) $(TRANSMISSION_IPK_DIR) $(TRANSMISSION_IPK)

#
# Some sanity check for the package.
transmission-check: $(TRANSMISSION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TRANSMISSION_IPK)
