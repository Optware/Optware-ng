###########################################################
#
# mediatomb
#
###########################################################
#
# MEDIATOMB_VERSION, MEDIATOMB_SITE and MEDIATOMB_SOURCE define
# the upstream location of the source code for the package.
# MEDIATOMB_DIR is the directory which is created when the source
# archive is unpacked.
# MEDIATOMB_UNZIP is the command used to unzip the source.
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
#MEDIATOMB_SVN_REPO=https://mediatomb.svn.sourceforge.net/svnroot/mediatomb/trunk
#MEDIATOMB_SVN_REV=1096
MEDIATOMB_VERSION=0.9.1
MEDIATOMB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mediatomb
MEDIATOMB_SOURCE=mediatomb-$(MEDIATOMB_VERSION).tar.gz
MEDIATOMB_DIR=mediatomb-$(MEDIATOMB_VERSION)
MEDIATOMB_UNZIP=zcat
MEDIATOMB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MEDIATOMB_DESCRIPTION=UPnP AV Mediaserver for Linux.
MEDIATOMB_SECTION=multimedia
MEDIATOMB_PRIORITY=optional
MEDIATOMB_DEPENDS=file, ossp-js, libexif, sqlite, zlib
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MEDIATOMB_DEPENDS+=, libiconv
endif
ifeq (id3lib, $(filter id3lib, $(PACKAGES)))
MEDIATOMB_DEPENDS+=, id3lib
endif
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
MEDIATOMB_DEPENDS+=, libstdc++
endif
ifeq (libuclibc++, $(filter libuclibc++, $(PACKAGES)))
MEDIATOMB_DEPENDS+=, libuclibc++
endif
MEDIATOMB_SUGGESTS=
MEDIATOMB_CONFLICTS=

#
# MEDIATOMB_IPK_VERSION should be incremented when the ipk changes.
#
MEDIATOMB_IPK_VERSION=1

#
# MEDIATOMB_CONFFILES should be a list of user-editable files
#MEDIATOMB_CONFFILES=/opt/etc/mediatomb.conf /opt/etc/init.d/SXXmediatomb

#
# MEDIATOMB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MEDIATOMB_PATCHES=$(MEDIATOMB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MEDIATOMB_CPPFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
MEDIATOMB_LDFLAGS=-lm -lpthread
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MEDIATOMB_LDFLAGS+= -liconv
endif

ifneq (id3lib, $(filter id3lib, $(PACKAGES)))
MEDIATOMB_CONFIG_ARGS=--disable-id3lib --disable-taglib
else
MEDIATOMB_CONFIG_ARGS=--enable-id3lib \
		--with-id3lib-h=$(STAGING_INCLUDE_DIR) \
		--with-id3lib-libs=$(STAGING_LIB_DIR)
endif

#
# MEDIATOMB_BUILD_DIR is the directory in which the build is done.
# MEDIATOMB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MEDIATOMB_IPK_DIR is the directory in which the ipk is built.
# MEDIATOMB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MEDIATOMB_BUILD_DIR=$(BUILD_DIR)/mediatomb
MEDIATOMB_SOURCE_DIR=$(SOURCE_DIR)/mediatomb
MEDIATOMB_IPK_DIR=$(BUILD_DIR)/mediatomb-$(MEDIATOMB_VERSION)-ipk
MEDIATOMB_IPK=$(BUILD_DIR)/mediatomb_$(MEDIATOMB_VERSION)-$(MEDIATOMB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mediatomb-source mediatomb-unpack mediatomb mediatomb-stage mediatomb-ipk mediatomb-clean mediatomb-dirclean mediatomb-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MEDIATOMB_SOURCE):
ifndef MEDIATOMB_SVN_REV
	$(WGET) -P $(DL_DIR) $(MEDIATOMB_SITE)/$(MEDIATOMB_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MEDIATOMB_SOURCE)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(MEDIATOMB_DIR) && \
		svn co -r$(MEDIATOMB_SVN_REV) $(MEDIATOMB_SVN_REPO) $(MEDIATOMB_DIR) && \
		tar -czf $@ --exclude=.svn $(MEDIATOMB_DIR) && \
		rm -rf $(MEDIATOMB_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mediatomb-source: $(DL_DIR)/$(MEDIATOMB_SOURCE) $(MEDIATOMB_PATCHES)

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
#		--with-js-libs=$(STAGING_LIB_DIR) \
#
$(MEDIATOMB_BUILD_DIR)/.configured: $(DL_DIR)/$(MEDIATOMB_SOURCE) $(MEDIATOMB_PATCHES) make/mediatomb.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
ifeq (id3lib, $(filter id3lib, $(PACKAGES)))
	$(MAKE) id3lib-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	$(MAKE) file-stage
	$(MAKE) ossp-js-stage
	$(MAKE) libexif-stage
	$(MAKE) sqlite-stage
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(MEDIATOMB_DIR) $(MEDIATOMB_BUILD_DIR)
	$(MEDIATOMB_UNZIP) $(DL_DIR)/$(MEDIATOMB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MEDIATOMB_PATCHES)" ; \
		then cat $(MEDIATOMB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MEDIATOMB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MEDIATOMB_DIR)" != "$(MEDIATOMB_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MEDIATOMB_DIR) $(MEDIATOMB_BUILD_DIR) ; \
	fi
	cd $(MEDIATOMB_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 autoreconf -vif
	(cd $(MEDIATOMB_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MEDIATOMB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MEDIATOMB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-libjs \
		--enable-libexif \
		--enable-libmagic \
		--disable-mysql \
		--disable-rpl-malloc \
		--disable-large-file \
		--enable-sqlite3 \
		--disable-fseeko-check \
		$(MEDIATOMB_CONFIG_ARGS) \
		--with-js-h=$(STAGING_INCLUDE_DIR)/js \
		--with-js-libs=$(STAGING_LIB_DIR) \
		--with-libexif-h=$(STAGING_INCLUDE_DIR) \
		--with-libexif-libs=$(STAGING_LIB_DIR) \
		--with-magic-h=$(STAGING_INCLUDE_DIR) \
		--with-magic-libs=$(STAGING_LIB_DIR) \
		--with-sqlite3-h=$(STAGING_INCLUDE_DIR) \
		--with-sqlite3-libs=$(STAGING_LIB_DIR) \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MEDIATOMB_BUILD_DIR)/libtool
	touch $@

mediatomb-unpack: $(MEDIATOMB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MEDIATOMB_BUILD_DIR)/.built: $(MEDIATOMB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MEDIATOMB_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mediatomb: $(MEDIATOMB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MEDIATOMB_BUILD_DIR)/.staged: $(MEDIATOMB_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MEDIATOMB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mediatomb-stage: $(MEDIATOMB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mediatomb
#
$(MEDIATOMB_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mediatomb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MEDIATOMB_PRIORITY)" >>$@
	@echo "Section: $(MEDIATOMB_SECTION)" >>$@
	@echo "Version: $(MEDIATOMB_VERSION)-$(MEDIATOMB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MEDIATOMB_MAINTAINER)" >>$@
	@echo "Source: $(MEDIATOMB_SITE)/$(MEDIATOMB_SOURCE)" >>$@
	@echo "Description: $(MEDIATOMB_DESCRIPTION)" >>$@
	@echo "Depends: $(MEDIATOMB_DEPENDS)" >>$@
	@echo "Suggests: $(MEDIATOMB_SUGGESTS)" >>$@
	@echo "Conflicts: $(MEDIATOMB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MEDIATOMB_IPK_DIR)/opt/sbin or $(MEDIATOMB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MEDIATOMB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MEDIATOMB_IPK_DIR)/opt/etc/mediatomb/...
# Documentation files should be installed in $(MEDIATOMB_IPK_DIR)/opt/doc/mediatomb/...
# Daemon startup scripts should be installed in $(MEDIATOMB_IPK_DIR)/opt/etc/init.d/S??mediatomb
#
# You may need to patch your application to make it use these locations.
#
$(MEDIATOMB_IPK): $(MEDIATOMB_BUILD_DIR)/.built
	rm -rf $(MEDIATOMB_IPK_DIR) $(BUILD_DIR)/mediatomb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MEDIATOMB_BUILD_DIR) DESTDIR=$(MEDIATOMB_IPK_DIR) install-strip
#	install -d $(MEDIATOMB_IPK_DIR)/opt/etc/
#	install -m 644 $(MEDIATOMB_SOURCE_DIR)/mediatomb.conf $(MEDIATOMB_IPK_DIR)/opt/etc/mediatomb.conf
#	install -d $(MEDIATOMB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MEDIATOMB_SOURCE_DIR)/rc.mediatomb $(MEDIATOMB_IPK_DIR)/opt/etc/init.d/SXXmediatomb
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIATOMB_IPK_DIR)/opt/etc/init.d/SXXmediatomb
	$(MAKE) $(MEDIATOMB_IPK_DIR)/CONTROL/control
#	install -m 755 $(MEDIATOMB_SOURCE_DIR)/postinst $(MEDIATOMB_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIATOMB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MEDIATOMB_SOURCE_DIR)/prerm $(MEDIATOMB_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MEDIATOMB_IPK_DIR)/CONTROL/prerm
	echo $(MEDIATOMB_CONFFILES) | sed -e 's/ /\n/g' > $(MEDIATOMB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MEDIATOMB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mediatomb-ipk: $(MEDIATOMB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mediatomb-clean:
	rm -f $(MEDIATOMB_BUILD_DIR)/.built
	-$(MAKE) -C $(MEDIATOMB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mediatomb-dirclean:
	rm -rf $(BUILD_DIR)/$(MEDIATOMB_DIR) $(MEDIATOMB_BUILD_DIR) $(MEDIATOMB_IPK_DIR) $(MEDIATOMB_IPK)
#
#
# Some sanity check for the package.
#
mediatomb-check: $(MEDIATOMB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MEDIATOMB_IPK)
