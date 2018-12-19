###########################################################
#
# mkvtoolnix
#
###########################################################
#
# MKVTOOLNIX_VERSION, MKVTOOLNIX_SITE and MKVTOOLNIX_SOURCE define
# the upstream location of the source code for the package.
# MKVTOOLNIX_DIR is the directory which is created when the source
# archive is unpacked.
# MKVTOOLNIX_UNZIP is the command used to unzip the source.
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
MKVTOOLNIX_SITE=http://bunkus.org/videotools/mkvtoolnix/sources
MKVTOOLNIX_VERSION ?= 8.8.0
ifeq ($(shell test $(shell echo $(MKVTOOLNIX_VERSION) | sed 's/\..*//') -gt 5; echo $$?),0)
MKVTOOLNIX_SOURCE=mkvtoolnix-$(MKVTOOLNIX_VERSION).tar.xz
MKVTOOLNIX_UNZIP=xzcat
else
MKVTOOLNIX_SOURCE=mkvtoolnix-$(MKVTOOLNIX_VERSION).tar.bz2
MKVTOOLNIX_UNZIP=bzcat
endif
MKVTOOLNIX_DIR=mkvtoolnix-$(MKVTOOLNIX_VERSION)
MKVTOOLNIX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MKVTOOLNIX_DESCRIPTION=A set of tools to create, alter and inspect Matroska files
MKVTOOLNIX_SECTION=multimedia
MKVTOOLNIX_PRIORITY=optional
MKVTOOLNIX_DEPENDS=boost-system, boost-filesystem, boost-regex, expat, file, flac, libebml, libmatroska, libogg, libvorbis, lzo, icu, libcurl, libintl
ifeq (enable, $(GETTEXT_NLS))
MKVTOOLNIX_DEPENDS +=, gettext
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
MKVTOOLNIX_DEPENDS +=, libiconv
endif
MKVTOOLNIX_SUGGESTS=
MKVTOOLNIX_CONFLICTS=

#
# MKVTOOLNIX_IPK_VERSION should be incremented when the ipk changes.
#
MKVTOOLNIX_IPK_VERSION?=6

#
# MKVTOOLNIX_CONFFILES should be a list of user-editable files
#MKVTOOLNIX_CONFFILES=$(TARGET_PREFIX)/etc/mkvtoolnix.conf $(TARGET_PREFIX)/etc/init.d/SXXmkvtoolnix

#
# MKVTOOLNIX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MKVTOOLNIX_PATCHES=$(MKVTOOLNIX_SOURCE_DIR)/va_list.patch
ifeq ($(LIBC_STYLE),uclibc)
MKVTOOLNIX_PATCHES += $(MKVTOOLNIX_SOURCE_DIR)/$(MKVTOOLNIX_VERSION)/llround-lround.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MKVTOOLNIX_CPPFLAGS=-Wno-deprecated-declarations -Wno-unused-variable
ifeq ($(LIBC_STYLE),uclibc)
MKVTOOLNIX_CPPFLAGS += -Duint16_t=__u16 -Duint32_t=__u32 -Duint64_t=__64
endif
MKVTOOLNIX_LDFLAGS=-lintl

#
# MKVTOOLNIX_BUILD_DIR is the directory in which the build is done.
# MKVTOOLNIX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MKVTOOLNIX_IPK_DIR is the directory in which the ipk is built.
# MKVTOOLNIX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MKVTOOLNIX_BUILD_DIR=$(BUILD_DIR)/mkvtoolnix
MKVTOOLNIX_SOURCE_DIR=$(SOURCE_DIR)/mkvtoolnix
MKVTOOLNIX_IPK_DIR=$(BUILD_DIR)/mkvtoolnix-$(MKVTOOLNIX_VERSION)-ipk
MKVTOOLNIX_IPK=$(BUILD_DIR)/mkvtoolnix_$(MKVTOOLNIX_VERSION)-$(MKVTOOLNIX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mkvtoolnix-source mkvtoolnix-unpack mkvtoolnix mkvtoolnix-stage mkvtoolnix-ipk mkvtoolnix-clean mkvtoolnix-dirclean mkvtoolnix-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MKVTOOLNIX_SOURCE):
	$(WGET) -P $(@D) $(MKVTOOLNIX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mkvtoolnix-source: $(DL_DIR)/$(MKVTOOLNIX_SOURCE) $(MKVTOOLNIX_PATCHES)

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
$(MKVTOOLNIX_BUILD_DIR)/.configured: $(DL_DIR)/$(MKVTOOLNIX_SOURCE) $(MKVTOOLNIX_PATCHES) make/mkvtoolnix.mk
	$(MAKE) boost-stage bzip2-stage expat-stage file-stage flac-stage zlib-stage libcurl-stage \
		libebml-stage libmatroska-stage libogg-stage libvorbis-stage lzo-stage icu-stage
ifeq (enable, $(GETTEXT_NLS))
	$(MAKE) gettext-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(MKVTOOLNIX_DIR) $(@D)
	$(MKVTOOLNIX_UNZIP) $(DL_DIR)/$(MKVTOOLNIX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MKVTOOLNIX_PATCHES)" ; \
		then cat $(MKVTOOLNIX_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(MKVTOOLNIX_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MKVTOOLNIX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MKVTOOLNIX_DIR) $(@D) ; \
	fi
	find $(@D) -type f \( -name '*.h' -o -name '*.cpp' \) -exec sed -i -e 's/bswap_16\|bswap_32\|bswap_64/_&_/g' {} \;
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MKVTOOLNIX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MKVTOOLNIX_LDFLAGS)" \
		CURL_CFLAGS=-I$(STAGING_INCLUDE_DIR) \
		CURL_LIBS="-L$(STAGING_LIB_DIR) -lcurl" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--with-boost=$(STAGING_PREFIX) \
		--disable-gui \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mkvtoolnix-unpack: $(MKVTOOLNIX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MKVTOOLNIX_BUILD_DIR)/.built: $(MKVTOOLNIX_BUILD_DIR)/.configured
	rm -f $@
ifeq ($(shell test $(shell echo $(MKVTOOLNIX_VERSION) | sed 's/\..*//') -gt 4; echo $$?),0)
 ifneq ($(MAKE_JOBS), )
	cd $(@D); ./drake -j$(MAKE_JOBS) V=1
 else
	cd $(@D); ./drake V=1
 endif
else
	$(MAKE) -C $(@D) V=1
endif
	touch $@

#
# This is the build convenience target.
#
mkvtoolnix: $(MKVTOOLNIX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MKVTOOLNIX_BUILD_DIR)/.staged: $(MKVTOOLNIX_BUILD_DIR)/.built
	rm -f $@
ifeq ($(shell test $(shell echo $(MKVTOOLNIX_VERSION) | sed 's/\..*//') -gt 4; echo $$?),0)
	cd $(@D); ./drake DESTDIR=$(STAGING_DIR) install
else
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
endif
	touch $@

mkvtoolnix-stage: $(MKVTOOLNIX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mkvtoolnix
#
$(MKVTOOLNIX_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: mkvtoolnix" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MKVTOOLNIX_PRIORITY)" >>$@
	@echo "Section: $(MKVTOOLNIX_SECTION)" >>$@
	@echo "Version: $(MKVTOOLNIX_VERSION)-$(MKVTOOLNIX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MKVTOOLNIX_MAINTAINER)" >>$@
	@echo "Source: $(MKVTOOLNIX_SITE)/$(MKVTOOLNIX_SOURCE)" >>$@
	@echo "Description: $(MKVTOOLNIX_DESCRIPTION)" >>$@
	@echo "Depends: $(MKVTOOLNIX_DEPENDS)" >>$@
	@echo "Suggests: $(MKVTOOLNIX_SUGGESTS)" >>$@
	@echo "Conflicts: $(MKVTOOLNIX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/sbin or $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/etc/mkvtoolnix/...
# Documentation files should be installed in $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/doc/mkvtoolnix/...
# Daemon startup scripts should be installed in $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??mkvtoolnix
#
# You may need to patch your application to make it use these locations.
#
$(MKVTOOLNIX_IPK): $(MKVTOOLNIX_BUILD_DIR)/.built
	rm -rf $(MKVTOOLNIX_IPK_DIR) $(BUILD_DIR)/mkvtoolnix_*_$(TARGET_ARCH).ipk
ifeq ($(shell test $(shell echo $(MKVTOOLNIX_VERSION) | sed 's/\..*//') -gt 4; echo $$?),0)
	cd $(MKVTOOLNIX_BUILD_DIR); ./drake DESTDIR=$(MKVTOOLNIX_IPK_DIR) install
else
	$(MAKE) -C $(MKVTOOLNIX_BUILD_DIR) DESTDIR=$(MKVTOOLNIX_IPK_DIR) install
endif
	$(STRIP_COMMAND) $(MKVTOOLNIX_IPK_DIR)$(TARGET_PREFIX)/bin/mkv*
	$(MAKE) $(MKVTOOLNIX_IPK_DIR)/CONTROL/control
	echo $(MKVTOOLNIX_CONFFILES) | sed -e 's/ /\n/g' > $(MKVTOOLNIX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MKVTOOLNIX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mkvtoolnix-ipk: $(MKVTOOLNIX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mkvtoolnix-clean:
	rm -f $(MKVTOOLNIX_BUILD_DIR)/.built
	-$(MAKE) -C $(MKVTOOLNIX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mkvtoolnix-dirclean:
	rm -rf $(BUILD_DIR)/$(MKVTOOLNIX_DIR) $(MKVTOOLNIX_BUILD_DIR) $(MKVTOOLNIX_IPK_DIR) $(MKVTOOLNIX_IPK)
#
#
# Some sanity check for the package.
#
mkvtoolnix-check: $(MKVTOOLNIX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
