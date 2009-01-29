###########################################################
#
# newsbeuter
#
###########################################################
#
# NEWSBEUTER_VERSION, NEWSBEUTER_SITE and NEWSBEUTER_SOURCE define
# the upstream location of the source code for the package.
# NEWSBEUTER_DIR is the directory which is created when the source
# archive is unpacked.
# NEWSBEUTER_UNZIP is the command used to unzip the source.
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
NEWSBEUTER_SITE=http://www.newsbeuter.org/downloads
NEWSBEUTER_GCC_MAJOR:=$(shell test -x "$(TARGET_CC)" && $(TARGET_CC) -dumpversion | cut -c1)
NEWSBEUTER_VERSION=$(if $(filter 3, $(NEWSBEUTER_GCC_MAJOR)),1.2,1.3)
NEWSBEUTER_SOURCE=newsbeuter-$(NEWSBEUTER_VERSION).tar.gz
NEWSBEUTER_DIR=newsbeuter-$(NEWSBEUTER_VERSION)
NEWSBEUTER_UNZIP=zcat
NEWSBEUTER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NEWSBEUTER_DESCRIPTION=An RSS feed reader for the text console.
NEWSBEUTER_SECTION=net
NEWSBEUTER_PRIORITY=optional
NEWSBEUTER_DEPENDS=libcurl, libmrss, libstdc++, ncursesw, sqlite
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
NEWSBEUTER_DEPENDS+=, libiconv
endif
ifeq (enable, $(GETTEXT_NLS))
NEWSBEUTER_DEPENDS+=, gettext
endif
NEWSBEUTER_SUGGESTS=
NEWSBEUTER_CONFLICTS=

#
# NEWSBEUTER_IPK_VERSION should be incremented when the ipk changes.
#
NEWSBEUTER_IPK_VERSION=1

#
# NEWSBEUTER_CONFFILES should be a list of user-editable files
#NEWSBEUTER_CONFFILES=/opt/etc/newsbeuter.conf /opt/etc/init.d/SXXnewsbeuter

#
# NEWSBEUTER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NEWSBEUTER_PATCHES=$(NEWSBEUTER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NEWSBEUTER_CPPFLAGS=-ggdb -I./include -I./stfl -I./filter -I.
NEWSBEUTER_LDFLAGS=-L. -lsqlite3 -lcurl
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
NEWSBEUTER_LDFLAGS+=-liconv
endif
ifeq (uclibc, $(LIBC_STYLE))
NEWSBEUTER_LDFLAGS+=-lintl
endif

#
# NEWSBEUTER_BUILD_DIR is the directory in which the build is done.
# NEWSBEUTER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NEWSBEUTER_IPK_DIR is the directory in which the ipk is built.
# NEWSBEUTER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NEWSBEUTER_BUILD_DIR=$(BUILD_DIR)/newsbeuter
NEWSBEUTER_SOURCE_DIR=$(SOURCE_DIR)/newsbeuter
NEWSBEUTER_IPK_DIR=$(BUILD_DIR)/newsbeuter-$(NEWSBEUTER_VERSION)-ipk
NEWSBEUTER_IPK=$(BUILD_DIR)/newsbeuter_$(NEWSBEUTER_VERSION)-$(NEWSBEUTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: newsbeuter-source newsbeuter-unpack newsbeuter newsbeuter-stage newsbeuter-ipk newsbeuter-clean newsbeuter-dirclean newsbeuter-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NEWSBEUTER_SOURCE):
	$(WGET) -P $(@D) $(NEWSBEUTER_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
newsbeuter-source: $(DL_DIR)/$(NEWSBEUTER_SOURCE) $(NEWSBEUTER_PATCHES)

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
$(NEWSBEUTER_BUILD_DIR)/.configured: $(DL_DIR)/$(NEWSBEUTER_SOURCE) $(NEWSBEUTER_PATCHES) make/newsbeuter.mk
	$(MAKE) libstdc++-stage
	$(MAKE) sqlite-stage libmrss-stage libcurl-stage
	$(MAKE) stfl-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
ifeq (enable, $(GETTEXT_NLS))
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(NEWSBEUTER_DIR) $(@D)
	$(NEWSBEUTER_UNZIP) $(DL_DIR)/$(NEWSBEUTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NEWSBEUTER_PATCHES)" ; \
		then cat $(NEWSBEUTER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NEWSBEUTER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NEWSBEUTER_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(NEWSBEUTER_DIR) $(@D) ; \
	fi
	sed -i -e '/^[ 	]*stfl_/s/stfl_/struct stfl_/' $(@D)/include/stflpp.h
	sed -i -e '/#include <set>/a#include <unistd.h>' $(@D)/include/configparser.h
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	sed -i -e '/::iconv(/s/, /, (const char**) /' $(@D)/src/utils.cpp
endif
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NEWSBEUTER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NEWSBEUTER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/DEFINES=/s/$$/ $$(CPPFLAGS)/' \
	       -e '/^CXXFLAGS/s| -I/sw/include||' \
	       -e '/^LDFLAGS/s| -L/sw/lib||' \
		$(@D)/Makefile
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
		sed -i -e 's/ -Wextra//' $(@D)/Makefile; \
	fi
#	sed -i -e 's/ gettext/ _/' $(@D)/src/keymap.cpp
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

newsbeuter-unpack: $(NEWSBEUTER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NEWSBEUTER_BUILD_DIR)/.built: $(NEWSBEUTER_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NEWSBEUTER_CPPFLAGS)" \
		LDFLAGS="$(NEWSBEUTER_LDFLAGS) $(STAGING_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
newsbeuter: $(NEWSBEUTER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(NEWSBEUTER_BUILD_DIR)/.staged: $(NEWSBEUTER_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#newsbeuter-stage: $(NEWSBEUTER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/newsbeuter
#
$(NEWSBEUTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: newsbeuter" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NEWSBEUTER_PRIORITY)" >>$@
	@echo "Section: $(NEWSBEUTER_SECTION)" >>$@
	@echo "Version: $(NEWSBEUTER_VERSION)-$(NEWSBEUTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NEWSBEUTER_MAINTAINER)" >>$@
	@echo "Source: $(NEWSBEUTER_SITE)/$(NEWSBEUTER_SOURCE)" >>$@
	@echo "Description: $(NEWSBEUTER_DESCRIPTION)" >>$@
	@echo "Depends: $(NEWSBEUTER_DEPENDS)" >>$@
	@echo "Suggests: $(NEWSBEUTER_SUGGESTS)" >>$@
	@echo "Conflicts: $(NEWSBEUTER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NEWSBEUTER_IPK_DIR)/opt/sbin or $(NEWSBEUTER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NEWSBEUTER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NEWSBEUTER_IPK_DIR)/opt/etc/newsbeuter/...
# Documentation files should be installed in $(NEWSBEUTER_IPK_DIR)/opt/doc/newsbeuter/...
# Daemon startup scripts should be installed in $(NEWSBEUTER_IPK_DIR)/opt/etc/init.d/S??newsbeuter
#
# You may need to patch your application to make it use these locations.
#
$(NEWSBEUTER_IPK): $(NEWSBEUTER_BUILD_DIR)/.built
	rm -rf $(NEWSBEUTER_IPK_DIR) $(BUILD_DIR)/newsbeuter_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NEWSBEUTER_BUILD_DIR) install \
		DESTDIR=$(NEWSBEUTER_IPK_DIR) \
		prefix=$(if $(filter 1.2,$(NEWSBEUTER_VERSION)),$(NEWSBEUTER_IPK_DIR),)/opt
	$(STRIP_COMMAND) $(NEWSBEUTER_IPK_DIR)/opt/bin/*
#	install -d $(NEWSBEUTER_IPK_DIR)/opt/etc/
#	install -m 644 $(NEWSBEUTER_SOURCE_DIR)/newsbeuter.conf $(NEWSBEUTER_IPK_DIR)/opt/etc/newsbeuter.conf
#	install -d $(NEWSBEUTER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NEWSBEUTER_SOURCE_DIR)/rc.newsbeuter $(NEWSBEUTER_IPK_DIR)/opt/etc/init.d/SXXnewsbeuter
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEWSBEUTER_IPK_DIR)/opt/etc/init.d/SXXnewsbeuter
	$(MAKE) $(NEWSBEUTER_IPK_DIR)/CONTROL/control
#	install -m 755 $(NEWSBEUTER_SOURCE_DIR)/postinst $(NEWSBEUTER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEWSBEUTER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NEWSBEUTER_SOURCE_DIR)/prerm $(NEWSBEUTER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEWSBEUTER_IPK_DIR)/CONTROL/prerm
	echo $(NEWSBEUTER_CONFFILES) | sed -e 's/ /\n/g' > $(NEWSBEUTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NEWSBEUTER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
newsbeuter-ipk: $(NEWSBEUTER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
newsbeuter-clean:
	rm -f $(NEWSBEUTER_BUILD_DIR)/.built
	-$(MAKE) -C $(NEWSBEUTER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
newsbeuter-dirclean:
	rm -rf $(BUILD_DIR)/$(NEWSBEUTER_DIR) $(NEWSBEUTER_BUILD_DIR) $(NEWSBEUTER_IPK_DIR) $(NEWSBEUTER_IPK)
#
#
# Some sanity check for the package.
#
newsbeuter-check: $(NEWSBEUTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NEWSBEUTER_IPK)
