###########################################################
#
# libtorrent-rasterbar
#
###########################################################

# You must replace "libtorrent-rasterbar" and "LIBTORRENT-RASTERBAR" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# LIBTORRENT-RASTERBAR_VERSION, LIBTORRENT-RASTERBAR_SITE and LIBTORRENT-RASTERBAR_SOURCE define
# the upstream location of the source code for the package.
# LIBTORRENT-RASTERBAR_DIR is the directory which is created when the source
# archive is unpacked.
# LIBTORRENT-RASTERBAR_UNZIP is the command used to unzip the source.
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
LIBTORRENT-RASTERBAR_SITE=https://github.com/arvidn/libtorrent/releases/download/libtorrent-1_1_10
#LIBTORRENT-RASTERBAR_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libtorrent
#LIBTORRENT-RASTERBAR_SITE=http://libtorrent.googlecode.com/files
LIBTORRENT-RASTERBAR_VERSION=1.1.10
LIBTORRENT-RASTERBAR_SOURCE=libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION).tar.gz
LIBTORRENT-RASTERBAR_DIR=libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION)
LIBTORRENT-RASTERBAR_UNZIP=zcat
LIBTORRENT-RASTERBAR_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBTORRENT-RASTERBAR_DESCRIPTION=libtorrent rasterbar.
LIBTORRENT-RASTERBAR_PYTHON_BINDING_DESCRIPTION=libtorrent rasterbar python binding.
LIBTORRENT-RASTERBAR_SECTION=net
LIBTORRENT-RASTERBAR_PRIORITY=optional
LIBTORRENT-RASTERBAR_DEPENDS= openssl, boost-system, boost-chrono, boost-random
LIBTORRENT-RASTERBAR_PYTHON_BINDING26_DEPENDS= libtorrent-rasterbar, python26, boost-python26
LIBTORRENT-RASTERBAR_PYTHON_BINDING27_DEPENDS= libtorrent-rasterbar, python27, boost-python27
LIBTORRENT-RASTERBAR_PYTHON_BINDING3_DEPENDS= libtorrent-rasterbar, python3, boost-python3
LIBTORRENT-RASTERBAR_SUGGESTS=
LIBTORRENT-RASTERBAR_CONFLICTS=

ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBTORRENT-RASTERBAR_DEPENDS+=, libiconv
endif

#
# LIBTORRENT-RASTERBAR_IPK_VERSION should be incremented when the ipk changes.
#
LIBTORRENT-RASTERBAR_IPK_VERSION=1

#
# LIBTORRENT-RASTERBAR_CONFFILES should be a list of user-editable files
#LIBTORRENT-RASTERBAR_CONFFILES=$(TARGET_PREFIX)/etc/libtorrent-rasterbar.conf $(TARGET_PREFIX)/etc/init.d/SXXlibtorrent-rasterbar

#
# LIBTORRENT-RASTERBAR_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
LIBTORRENT-RASTERBAR_PATCHES=$(LIBTORRENT-RASTERBAR_SOURCE_DIR)/config.hpp.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBTORRENT-RASTERBAR_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/python2.6
LIBTORRENT-RASTERBAR_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
LIBTORRENT-RASTERBAR_LDFLAG+= -liconv
endif

#
# LIBTORRENT-RASTERBAR_BUILD_DIR is the directory in which the build is done.
# LIBTORRENT-RASTERBAR_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBTORRENT-RASTERBAR_IPK_DIR is the directory in which the ipk is built.
# LIBTORRENT-RASTERBAR_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBTORRENT-RASTERBAR_BUILD_DIR=$(BUILD_DIR)/libtorrent-rasterbar
LIBTORRENT-RASTERBAR_SOURCE_DIR=$(SOURCE_DIR)/libtorrent-rasterbar
LIBTORRENT-RASTERBAR_IPK_DIR=$(BUILD_DIR)/libtorrent-rasterbar-$(LIBTORRENT-RASTERBAR_VERSION)-ipk
LIBTORRENT-RASTERBAR_IPK=$(BUILD_DIR)/libtorrent-rasterbar_$(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR=$(BUILD_DIR)/py26-libtorrent-rasterbar-binding-$(LIBTORRENT-RASTERBAR_VERSION)-ipk
LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK=$(BUILD_DIR)/py26-libtorrent-rasterbar-binding_$(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR=$(BUILD_DIR)/py27-libtorrent-rasterbar-binding-$(LIBTORRENT-RASTERBAR_VERSION)-ipk
LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK=$(BUILD_DIR)/py27-libtorrent-rasterbar-binding_$(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)_$(TARGET_ARCH).ipk

LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR=$(BUILD_DIR)/py3-libtorrent-rasterbar-binding-$(LIBTORRENT-RASTERBAR_VERSION)-ipk
LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK=$(BUILD_DIR)/py3-libtorrent-rasterbar-binding_$(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libtorrent-rasterbar-source libtorrent-rasterbar-unpack libtorrent-rasterbar libtorrent-rasterbar-stage libtorrent-rasterbar-ipk libtorrent-rasterbar-clean libtorrent-rasterbar-dirclean libtorrent-rasterbar-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE):
	$(WGET) -P $(@D) $(LIBTORRENT-RASTERBAR_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
libtorrent-rasterbar-source: $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) $(LIBTORRENT-RASTERBAR_PATCHES)

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
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured: $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) $(LIBTORRENT-RASTERBAR_PATCHES) make/libtorrent-rasterbar.mk
	$(MAKE) boost-stage openssl-stage python26-host-stage python26-stage python27-host-stage python27-stage python3-host-stage python3-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(@D)
	rm -rf $(STAGING_INCLUDE_DIR)/libtorrent $(STAGING_LIB_DIR)/libtorrent-rasterbar*
	$(LIBTORRENT-RASTERBAR_UNZIP) $(DL_DIR)/$(LIBTORRENT-RASTERBAR_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LIBTORRENT-RASTERBAR_PATCHES)" ; \
		then cat $(LIBTORRENT-RASTERBAR_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(@D) ; \
	fi
	sed -i -e "s|/usr/local/ssl /usr/lib/ssl /usr/ssl /usr/pkg /usr/local /usr|$(STAGING_PREFIX)|" $(@D)/m4/ax_check_openssl.m4
	sed -i -e "s|/usr /usr/local /opt /opt/local|$(STAGING_PREFIX)|" $(@D)/m4/ax_boost_base.m4
	sed -i -e "s|namespace libtorrent|#ifndef IPV6_V6ONLY\n#  define IPV6_V6ONLY 26\n#endif\n\nnamespace libtorrent|" $(@D)/include/libtorrent/socket.hpp
	sed -i -e "s|namespace libtorrent { namespace|#ifndef IPV6_V6ONLY\n#  define IPV6_V6ONLY 26\n#endif\n\nnamespace libtorrent { namespace|" $(@D)/src/enum_net.cpp
#	sed -i -e "s/#include <vector>/#include <vector>\n#include <list>/" $(@D)/include/libtorrent/udp_socket.hpp
	$(AUTORECONF1.14) -vif $(@D)
	sed -i -e "s|/usr/include|$(STAGING_INCLUDE_DIR)|" $(@D)/configure
#	sed -i -e 's|#include <boost/multi_index/ordered_index\.hpp>|#include <boost/multi_index/ordered_index.hpp>\n#include <boost/noncopyable.hpp>|' $(@D)/src/storage.cpp
	sed -i -e "s/-ftemplate-depth=120//" -e 's/-msse4\.2//' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT-RASTERBAR_CPPFLAGS)" \
		CXXFLAGS="$(STAGING_CPPFLAGS) $(LIBTORRENT-RASTERBAR_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(LIBTORRENT-RASTERBAR_LDFLAGS)" \
		BOOST_ROOT="$(STAGING_PREFIX)" \
		PYTHON="$(HOST_STAGING_PREFIX)/bin/python2.6" \
		PYTHON_CPPFLAGS="-I$(STAGING_INCLUDE_DIR)/python2.6" \
		PYTHON_LDFLAGS="-L$(STAGING_LIB_DIR) -lpython2.6" \
		PYTHON_SITE_PKG="$(TARGET_PREFIX)/lib/python2.6/site-packages" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--with-ssl \
		--with-openssl=$(STAGING_PREFIX) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
		--disable-debug \
		--enable-python-binding \
		--with-boost-system=boost_system \
		--with-boost-chrono=boost_chrono \
		--with-boost-random=boost_random \
		--with-boost-python=boost_python-py26 \
		--with-asio=shipped \
		--with-dht=on \
		--with-encryption=on \
	)

ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	sed -i -e '/^LIBS =/s/=/= -liconv /' $(@D)/src/Makefile
endif
	sed -i -e '/^import sys$$/s|$$|\n\nos.environ["CC"] = "$(TARGET_CC)"\nos.environ["CXX"] = "$(TARGET_CXX)"\nos.environ["LDSHARED"] ="$(TARGET_CC) -shared"|' $(@D)/bindings/python/setup.py
	sed -i -e 's|$$| -lpython2.6|' $(@D)/bindings/python/compile_flags
ifeq ($(OPTWARE_TARGET), $(filter shibby-tomato-arm, $(OPTWARE_TARGET)))
	### no ifaddrs.h for the target
	sed -i -e 's/#define TORRENT_USE_IFADDRS 1/#define TORRENT_USE_IFADDRS 0/' $(@D)/include/libtorrent/config.hpp
endif
ifeq ($(OPTWARE_TARGET), $(filter shibby-tomato-arm, $(OPTWARE_TARGET)))
	### no fallocate
	sed -i -e 's/#define TORRENT_HAS_FALLOCATE 1/#define TORRENT_HAS_FALLOCATE 0/' $(@D)/include/libtorrent/config.hpp
endif
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

libtorrent-rasterbar-unpack: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.configured
	rm -f $@
	sed -i -e 's|include/python[^ \t]*|include/python2.6|g' -e 's|-lpython[^ \t]*|-lpython2.6|g' -e \
		's|-lboost_python-py[^ \t]*|-lboost_python-py26|' $(@D)/bindings/python/{compile,link}_flags
	$(MAKE) -C $(@D)
	sed -i -e 's|include/python[^ \t]*|include/python2.7|g' -e 's|-lpython[^ \t]*|-lpython2.7|g' -e \
		's|-lboost_python-py[^ \t]*|-lboost_python-py27|' $(@D)/bindings/python/{compile,link}_flags
	(cd $(@D)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py build)
	sed -i -e 's|include/python[^ \t]*|include/python$(PYTHON3_VERSION_MAJOR)m|g' -e \
		"s|-lboost_python-py[^ \t]*|-lboost_python-py$(shell echo $(PYTHON3_VERSION_MAJOR)|sed 's/\.//g')|" -e \
		's|-lpython[^ \t]*|-lpython$(PYTHON3_VERSION_MAJOR)m|g' $(@D)/bindings/python/{compile,link}_flags
	(cd $(@D)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py build)
	touch $@

#
# This is the build convenience target.
#
libtorrent-rasterbar: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LIBTORRENT-RASTERBAR_BUILD_DIR)/.staged: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libtorrent-rasterbar.la
	(cd $(@D)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --prefix=$(STAGING_PREFIX))
	(cd $(@D)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --prefix=$(STAGING_PREFIX))
	touch $@

libtorrent-rasterbar-stage: $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libtorrent-rasterbar
#
$(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libtorrent-rasterbar" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT-RASTERBAR_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT-RASTERBAR_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT-RASTERBAR_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT-RASTERBAR_SITE)/$(LIBTORRENT-RASTERBAR_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT-RASTERBAR_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT-RASTERBAR_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT-RASTERBAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT-RASTERBAR_CONFLICTS)" >>$@

$(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py26-libtorrent-rasterbar-binding" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT-RASTERBAR_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT-RASTERBAR_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT-RASTERBAR_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT-RASTERBAR_SITE)/$(LIBTORRENT-RASTERBAR_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT-RASTERBAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT-RASTERBAR_CONFLICTS)" >>$@

$(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py27-libtorrent-rasterbar-binding" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT-RASTERBAR_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT-RASTERBAR_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT-RASTERBAR_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT-RASTERBAR_SITE)/$(LIBTORRENT-RASTERBAR_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT-RASTERBAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT-RASTERBAR_CONFLICTS)" >>$@

$(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: py3-libtorrent-rasterbar-binding" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBTORRENT-RASTERBAR_PRIORITY)" >>$@
	@echo "Section: $(LIBTORRENT-RASTERBAR_SECTION)" >>$@
	@echo "Version: $(LIBTORRENT-RASTERBAR_VERSION)-$(LIBTORRENT-RASTERBAR_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBTORRENT-RASTERBAR_MAINTAINER)" >>$@
	@echo "Source: $(LIBTORRENT-RASTERBAR_SITE)/$(LIBTORRENT-RASTERBAR_SOURCE)" >>$@
	@echo "Description: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_DEPENDS)" >>$@
	@echo "Suggests: $(LIBTORRENT-RASTERBAR_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBTORRENT-RASTERBAR_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/libtorrent-rasterbar/...
# Documentation files should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/doc/libtorrent-rasterbar/...
# Daemon startup scripts should be installed in $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libtorrent-rasterbar
#
# You may need to patch your application to make it use these locations.
#
$(LIBTORRENT-RASTERBAR_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK): $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT-RASTERBAR_IPK_DIR) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)
	rm -f $(BUILD_DIR)/libtorrent-rasterbar_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/py26-libtorrent-rasterbar-binding_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(LIBTORRENT-RASTERBAR_BUILD_DIR) DESTDIR=$(LIBTORRENT-RASTERBAR_IPK_DIR) install-strip
#	$(INSTALL) -d $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/libtorrent-rasterbar.conf $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/libtorrent-rasterbar.conf
#	$(INSTALL) -d $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/rc.libtorrent-rasterbar $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtorrent-rasterbar
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXlibtorrent-rasterbar
	mkdir -p $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)$(TARGET_PREFIX)/lib
	mv -f $(LIBTORRENT-RASTERBAR_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6 $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)$(TARGET_PREFIX)/lib
	$(STRIP_COMMAND) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)$(TARGET_PREFIX)/lib/python2.6/site-packages/*.so
	$(MAKE) $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/control
	$(MAKE) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/postinst $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(LIBTORRENT-RASTERBAR_SOURCE_DIR)/prerm $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/postinst $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(LIBTORRENT-RASTERBAR_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT-RASTERBAR_IPK_DIR)/CONTROL/conffiles
	echo $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT-RASTERBAR_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR)

$(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK): $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR) $(BUILD_DIR)/py27-libtorrent-rasterbar-binding_*_$(TARGET_ARCH).ipk
	(cd $(LIBTORRENT-RASTERBAR_BUILD_DIR)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python2.7 setup.py install --prefix=$(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)$(TARGET_PREFIX)/lib/python2.7/site-packages/*.so
	$(MAKE) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)/CONTROL/control
	echo $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR)

$(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK): $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	rm -rf $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR) $(BUILD_DIR)/py3-libtorrent-rasterbar-binding_*_$(TARGET_ARCH).ipk
	(cd $(LIBTORRENT-RASTERBAR_BUILD_DIR)/bindings/python; $(HOST_STAGING_PREFIX)/bin/python$(PYTHON3_VERSION_MAJOR) setup.py install --prefix=$(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)$(TARGET_PREFIX))
	$(STRIP_COMMAND) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)$(TARGET_PREFIX)/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/*.so
	$(MAKE) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)/CONTROL/control
	echo $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_CONFFILES) | sed -e 's/ /\n/g' > $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libtorrent-rasterbar-ipk: $(LIBTORRENT-RASTERBAR_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
libtorrent-rasterbar-clean:
	rm -f $(LIBTORRENT-RASTERBAR_BUILD_DIR)/.built
	-$(MAKE) -C $(LIBTORRENT-RASTERBAR_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libtorrent-rasterbar-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBTORRENT-RASTERBAR_DIR) $(LIBTORRENT-RASTERBAR_BUILD_DIR) \
		$(LIBTORRENT-RASTERBAR_IPK_DIR) $(LIBTORRENT-RASTERBAR_IPK) \
		$(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK_DIR) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK) \
		$(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK_DIR) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK) \
		$(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK_DIR) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK) \
#
#
# Some sanity check for the package.
#
libtorrent-rasterbar-check: $(LIBTORRENT-RASTERBAR_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING26_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING27_IPK) $(LIBTORRENT-RASTERBAR_PYTHON_BINDING3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
