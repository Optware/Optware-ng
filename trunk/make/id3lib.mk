###########################################################
#
# id3lib
#
###########################################################

# You must replace "id3lib" and "ID3LIB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ID3LIB_VERSION, ID3LIB_SITE and ID3LIB_SOURCE define
# the upstream location of the source code for the package.
# ID3LIB_DIR is the directory which is created when the source
# archive is unpacked.
# ID3LIB_UNZIP is the command used to unzip the source.
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
ID3LIB_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/id3lib
ID3LIB_VERSION=3.8.3
ID3LIB_SOURCE=id3lib-$(ID3LIB_VERSION).tar.gz
ID3LIB_DIR=id3lib-$(ID3LIB_VERSION)
ID3LIB_UNZIP=zcat
ID3LIB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ID3LIB_DESCRIPTION=Library for reading, writing, and manipulating ID3v1  and ID3v2 tags.
ID3LIB_SECTION=lib
ID3LIB_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
ID3LIB_DEPENDS=libiconv
endif
ID3LIB_SUGGESTS=
ID3LIB_CONFLICTS=

#
# ID3LIB_IPK_VERSION should be incremented when the ipk changes.
#
ID3LIB_IPK_VERSION=4

#
# ID3LIB_CONFFILES should be a list of user-editable files
#ID3LIB_CONFFILES=/opt/etc/id3lib.conf /opt/etc/init.d/SXXid3lib

#
# ID3LIB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ID3LIB_PATCHES=$(ID3LIB_SOURCE_DIR)/wchar.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ID3LIB_CPPFLAGS=
ID3LIB_LDFLAGS=

ifeq ($(LIBC_STYLE), uclibc)
ifdef TARGET_GXX
ID3LIB_CONFIG_ENV=CXX=$(TARGET_GXX)
endif
endif

#
# ID3LIB_BUILD_DIR is the directory in which the build is done.
# ID3LIB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ID3LIB_IPK_DIR is the directory in which the ipk is built.
# ID3LIB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ID3LIB_BUILD_DIR=$(BUILD_DIR)/id3lib
ID3LIB_SOURCE_DIR=$(SOURCE_DIR)/id3lib
ID3LIB_IPK_DIR=$(BUILD_DIR)/id3lib-$(ID3LIB_VERSION)-ipk
ID3LIB_IPK=$(BUILD_DIR)/id3lib_$(ID3LIB_VERSION)-$(ID3LIB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: id3lib-source id3lib-unpack id3lib id3lib-stage id3lib-ipk id3lib-clean id3lib-dirclean id3lib-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ID3LIB_SOURCE):
	$(WGET) -P $(DL_DIR) $(ID3LIB_SITE)/$(ID3LIB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
id3lib-source: $(DL_DIR)/$(ID3LIB_SOURCE) $(ID3LIB_PATCHES)

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
$(ID3LIB_BUILD_DIR)/.configured: $(DL_DIR)/$(ID3LIB_SOURCE) $(ID3LIB_PATCHES) make/id3lib.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(ID3LIB_DIR) $(ID3LIB_BUILD_DIR)
	$(ID3LIB_UNZIP) $(DL_DIR)/$(ID3LIB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ID3LIB_PATCHES)" ; \
		then cat $(ID3LIB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ID3LIB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ID3LIB_DIR)" != "$(ID3LIB_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ID3LIB_DIR) $(ID3LIB_BUILD_DIR) ; \
	fi
ifeq ($(OPTWARE_TARGET), $(filter dns323, $(OPTWARE_TARGET)))
	sed -i -e 's/^#if (defined(ID3_NEED_WCHAR_TEMPLATE))/#if 1/' \
	       -e 's/^#ifndef _GLIBCPP_USE_WCHAR_T/#if 1/' \
		$(@D)/include/id3/id3lib_strings.h
endif
	sed -i -e '/iomanip.h/d' $(ID3LIB_BUILD_DIR)/configure.in
	(cd $(ID3LIB_BUILD_DIR); \
		ACLOCAL=aclocal-1.9 AUTOMAKE=automake-1.9 \
			autoreconf -vif; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ID3LIB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ID3LIB_LDFLAGS)" \
		$(ID3LIB_CONFIG_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(ID3LIB_BUILD_DIR)/libtool
	touch $(ID3LIB_BUILD_DIR)/.configured

id3lib-unpack: $(ID3LIB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ID3LIB_BUILD_DIR)/.built: $(ID3LIB_BUILD_DIR)/.configured
	rm -f $(ID3LIB_BUILD_DIR)/.built
	$(MAKE) -C $(ID3LIB_BUILD_DIR)
	touch $(ID3LIB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
id3lib: $(ID3LIB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ID3LIB_BUILD_DIR)/.staged: $(ID3LIB_BUILD_DIR)/.built
	rm -f $(ID3LIB_BUILD_DIR)/.staged
	$(MAKE) -C $(ID3LIB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_DIR)/opt/lib/libid3.la
	touch $(ID3LIB_BUILD_DIR)/.staged

id3lib-stage: $(ID3LIB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/id3lib
#
$(ID3LIB_IPK_DIR)/CONTROL/control:
	@install -d $(ID3LIB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: id3lib" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ID3LIB_PRIORITY)" >>$@
	@echo "Section: $(ID3LIB_SECTION)" >>$@
	@echo "Version: $(ID3LIB_VERSION)-$(ID3LIB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ID3LIB_MAINTAINER)" >>$@
	@echo "Source: $(ID3LIB_SITE)/$(ID3LIB_SOURCE)" >>$@
	@echo "Description: $(ID3LIB_DESCRIPTION)" >>$@
	@echo "Depends: $(ID3LIB_DEPENDS)" >>$@
	@echo "Suggests: $(ID3LIB_SUGGESTS)" >>$@
	@echo "Conflicts: $(ID3LIB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ID3LIB_IPK_DIR)/opt/sbin or $(ID3LIB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ID3LIB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ID3LIB_IPK_DIR)/opt/etc/id3lib/...
# Documentation files should be installed in $(ID3LIB_IPK_DIR)/opt/doc/id3lib/...
# Daemon startup scripts should be installed in $(ID3LIB_IPK_DIR)/opt/etc/init.d/S??id3lib
#
# You may need to patch your application to make it use these locations.
#
$(ID3LIB_IPK): $(ID3LIB_BUILD_DIR)/.built
	rm -rf $(ID3LIB_IPK_DIR) $(BUILD_DIR)/id3lib_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ID3LIB_BUILD_DIR) DESTDIR=$(ID3LIB_IPK_DIR) install-strip
#	install -d $(ID3LIB_IPK_DIR)/opt/etc/
#	install -m 644 $(ID3LIB_SOURCE_DIR)/id3lib.conf $(ID3LIB_IPK_DIR)/opt/etc/id3lib.conf
#	install -d $(ID3LIB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ID3LIB_SOURCE_DIR)/rc.id3lib $(ID3LIB_IPK_DIR)/opt/etc/init.d/SXXid3lib
	$(MAKE) $(ID3LIB_IPK_DIR)/CONTROL/control
#	install -m 755 $(ID3LIB_SOURCE_DIR)/postinst $(ID3LIB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ID3LIB_SOURCE_DIR)/prerm $(ID3LIB_IPK_DIR)/CONTROL/prerm
	echo $(ID3LIB_CONFFILES) | sed -e 's/ /\n/g' > $(ID3LIB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ID3LIB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
id3lib-ipk: $(ID3LIB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
id3lib-clean:
	rm -f $(ID3LIB_BUILD_DIR)/.built
	-$(MAKE) -C $(ID3LIB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
id3lib-dirclean:
	rm -rf $(BUILD_DIR)/$(ID3LIB_DIR) $(ID3LIB_BUILD_DIR) $(ID3LIB_IPK_DIR) $(ID3LIB_IPK)

#
# Some sanity check for the package.
#
id3lib-check: $(ID3LIB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ID3LIB_IPK)
