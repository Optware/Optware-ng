###########################################################
#
# btg
#
###########################################################

# You must replace "btg" and "BTG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# BTG_VERSION, BTG_SITE and BTG_SOURCE define
# the upstream location of the source code for the package.
# BTG_DIR is the directory which is created when the source
# archive is unpacked.
# BTG_UNZIP is the command used to unzip the source.
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
BTG_SITE=http://download.berlios.de/btg
BTG_VERSION=2.0.0

BTG_SVN_REV=659

ifdef BTG_SVN_REV
BTG_SVN=http://svn.berlios.de/svnroot/repos/btg/trunk
BTG_SOURCE=btg-svn-$(BTG_SVN_REV).tar.gz
else
BTG_SOURCE=btg-$(BTG_VERSION).tar.gz
endif

BTG_DIR=btg-$(shell echo $(BTG_VERSION)|cut -d "-" -f 1)
BTG_UNZIP=zcat
BTG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BTG_DESCRIPTION=BTG is a bittorrent client implemented in C++ using the Rasterbar Libtorrent library and provides various user interfaces, which communicate with a common backend running the actual bittorrent operation. Built with Ncurses and WWW UI.
BTG_SECTION=net
BTG_PRIORITY=optional
BTG_DEPENDS=libtorrent-rasterbar, boost-system, boost-filesystem, boost-date-time, boost-thread, boost-program-options, gnutls, libcurl, expat, dialog, zlib
BTG_SUGGESTS=
BTG_CONFLICTS=

#
# BTG_IPK_VERSION should be incremented when the ipk changes.
#
BTG_IPK_VERSION=1

#
# BTG_CONFFILES should be a list of user-editable files
#BTG_CONFFILES=/opt/etc/btg.conf /opt/etc/init.d/SXXbtg

#
# BTG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BTG_PATCHES=$(BTG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BTG_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
ifeq ($(OPTWARE_TARGET), $(filter openwrt-ixp4xx, $(OPTWARE_TARGET)))
BTG_CPPFLAGS+=-fno-builtin-ceil
endif
ifeq ($(OPTWARE_TARGET), $(filter mbwe-bluering, $(OPTWARE_TARGET)))
	###bad instruction `dmb' issue
	BTG_CPPFLAGS+= -mcpu=arm9
endif

BTG_LDFLAGS=-Wl,-rpath,/opt/lib/btg -ltorrent-rasterbar -lboost_system -lboost_filesystem -lboost_date_time -lboost_thread -lboost_program_options -lgnutls 

#
# BTG_BUILD_DIR is the directory in which the build is done.
# BTG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BTG_IPK_DIR is the directory in which the ipk is built.
# BTG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BTG_BUILD_DIR=$(BUILD_DIR)/btg
BTG_SOURCE_DIR=$(SOURCE_DIR)/btg
BTG_IPK_DIR=$(BUILD_DIR)/btg-$(BTG_VERSION)-ipk
ifdef BTG_SVN_REV
BTG_IPK=$(BUILD_DIR)/btg_$(BTG_VERSION)+r$(BTG_SVN_REV)-$(BTG_IPK_VERSION)_$(TARGET_ARCH).ipk
else
BTG_IPK=$(BUILD_DIR)/btg_$(BTG_VERSION)-$(BTG_IPK_VERSION)_$(TARGET_ARCH).ipk
endif

.PHONY: btg-source btg-unpack btg btg-stage btg-ipk btg-clean btg-dirclean btg-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BTG_SOURCE):
ifdef BTG_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(BTG_DIR) && \
		svn co -r $(BTG_SVN_REV) $(BTG_SVN) \
			$(BTG_DIR) && \
		tar -czf $@ $(BTG_DIR) && \
		rm -rf $(BTG_DIR) \
	) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
else
	$(WGET) -P $(@D) $(BTG_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
btg-source: $(DL_DIR)/$(BTG_SOURCE) $(BTG_PATCHES)

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
$(BTG_BUILD_DIR)/.configured: $(DL_DIR)/$(BTG_SOURCE) $(BTG_PATCHES) make/btg.mk
	$(MAKE) zlib-stage libtorrent-rasterbar-stage gnutls-stage libcurl-stage expat-stage dialog-stage ncurses-stage

	rm -rf $(BUILD_DIR)/$(BTG_DIR) $(@D)
	rm -rf $(STAGING_LIB_DIR)/btg
	$(BTG_UNZIP) $(DL_DIR)/$(BTG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BTG_PATCHES)" ; \
		then cat $(BTG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BTG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BTG_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BTG_DIR) $(@D) ; \
	fi
	sed -i -e "s/  AC_DEFINE_UNQUOTED(GNUTLS_MAJOR_VER/LIBGNUTLS_MAJOR_VER=`echo $(GNUTLS_VERSION) |cut -d "." -f 1`\nLIBGNUTLS_MINOR_VER=`echo $(GNUTLS_VERSION) |cut -d "." -f 2`\n  AC_DEFINE_UNQUOTED(GNUTLS_MAJOR_VER/" $(@D)/m4/libgnutls-version.m4
ifdef BTG_SVN_REV
	(cd $(@D); \
		./autogen.sh \
	)
else
	autoreconf -vif $(@D)
endif
	sed -i -e 's|ZLIB_HOME=/usr/local|ZLIB_HOME="$(STAGING_PREFIX)"|' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BTG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BTG_LDFLAGS)" \
		BOOST_CPPFLAGS="-I$(STAGING_INCLUDE_DIR)" \
		BOOST_LDFLAGS="-L$(STAGING_LIB_DIR)" \
		LIBTORRENT_LIBS="-L$(STAGING_LIB_DIR)" \
		LIBTORRENT_CFLAGS="-I$(STAGING_INCLUDE_DIR)" \
		LIBCURL="$(STAGING_LDFLAGS) -lcurl" \
		LIBCURL_CPPFLAGS="$(STAGING_CPPFLAGS)" \
		DIALOG="/opt/bin/dialog" \
		LIBGNUTLS_CONFIG="$(STAGING_PREFIX)/bin/libgnutls-config" \
		LIBGNUTLS_CFLAGS="$(STAGING_CPPFLAGS)" \
		LIBGNUTLS_LIBS="$(STAGING_LDFLAGS) -lgnutls" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--program-prefix= \
		--with-boost="$(STAGING_PREFIX)" \
		--with-boost-libdir="$(STAGING_LIB_DIR)" \
		--with-zlib="$(STAGING_PREFIX)" \
		--with-xmlrpc-prefix="$(STAGING_PREFIX)" \
		--without-cyberlink \
		--disable-nls \
		--disable-static \
		--disable-gui \
		--disable-viewer \
		--disable-debug \
		--enable-btg-config \
		--enable-cli \
		--enable-url \
		--enable-www \
		--enable-session-saving \
		--enable-event-callback \
		--enable-command-list \
		--includedir="$(STAGING_INCLUDE_DIR)" \
  		--oldincludedir="$(STAGING_INCLUDE_DIR)" \
		--enable-upnp \
	)
ifeq (uclibc, $(LIBC_STYLE))
	###roundf() workaround
	sed -i -e "s|roundf(ratio \* 100\.0f)|((fmod(ratio \* 100\.0f,1)<0.5)?floor(ratio \* 100\.0f):ceil(ratio \* 100\.0f))|" $(@D)/bcore/client/ratio.cpp
endif
	#sed -i -e "s|#include <bcore/type.h>|#include <bcore/type.h>\n#include <unistd.h>|" $(@D)/bcore/os/id.h
	#sed -i -e "s|#include <string>|#include <string>\n#include <unistd.h>|" $(@D)/bcore/os/exec.h
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

btg-unpack: $(BTG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BTG_BUILD_DIR)/.built: $(BTG_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
btg: $(BTG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BTG_BUILD_DIR)/.staged: $(BTG_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

btg-stage: $(BTG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/btg
#
$(BTG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: btg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BTG_PRIORITY)" >>$@
	@echo "Section: $(BTG_SECTION)" >>$@
ifdef BTG_SVN_REV
	@echo "Version: $(BTG_VERSION)+r$(BTG_SVN_REV)-$(BTG_IPK_VERSION)" >>$@
else
	@echo "Version: $(BTG_VERSION)-$(BTG_IPK_VERSION)" >>$@
endif
	@echo "Maintainer: $(BTG_MAINTAINER)" >>$@
	@echo "Source: $(BTG_SITE)/$(BTG_SOURCE)" >>$@
	@echo "Description: $(BTG_DESCRIPTION)" >>$@
	@echo "Depends: $(BTG_DEPENDS)" >>$@
	@echo "Suggests: $(BTG_SUGGESTS)" >>$@
	@echo "Conflicts: $(BTG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BTG_IPK_DIR)/opt/sbin or $(BTG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BTG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BTG_IPK_DIR)/opt/etc/btg/...
# Documentation files should be installed in $(BTG_IPK_DIR)/opt/doc/btg/...
# Daemon startup scripts should be installed in $(BTG_IPK_DIR)/opt/etc/init.d/S??btg
#
# You may need to patch your application to make it use these locations.
#
$(BTG_IPK): $(BTG_BUILD_DIR)/.built
	rm -rf $(BTG_IPK_DIR) $(BUILD_DIR)/btg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BTG_BUILD_DIR) DESTDIR=$(BTG_IPK_DIR) install-strip
#	install -d $(BTG_IPK_DIR)/opt/etc/
#	install -m 644 $(BTG_SOURCE_DIR)/btg.conf $(BTG_IPK_DIR)/opt/etc/btg.conf
#	install -d $(BTG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(BTG_SOURCE_DIR)/rc.btg $(BTG_IPK_DIR)/opt/etc/init.d/SXXbtg
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BTG_IPK_DIR)/opt/etc/init.d/SXXbtg
	$(MAKE) $(BTG_IPK_DIR)/CONTROL/control
#	install -m 755 $(BTG_SOURCE_DIR)/postinst $(BTG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BTG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BTG_SOURCE_DIR)/prerm $(BTG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(BTG_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(BTG_IPK_DIR)/CONTROL/postinst $(BTG_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(BTG_CONFFILES) | sed -e 's/ /\n/g' > $(BTG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BTG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
btg-ipk: $(BTG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
btg-clean:
	rm -f $(BTG_BUILD_DIR)/.built
	-$(MAKE) -C $(BTG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
btg-dirclean:
	rm -rf $(BUILD_DIR)/$(BTG_DIR) $(BTG_BUILD_DIR) $(BTG_IPK_DIR) $(BTG_IPK)
#
#
# Some sanity check for the package.
#
btg-check: $(BTG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BTG_IPK)
