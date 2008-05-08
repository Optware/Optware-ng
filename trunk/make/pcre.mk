###########################################################
#
# pcre
#
###########################################################
#
# PCRE_VERSION, PCRE_SITE and PCRE_SOURCE define
# the upstream location of the source code for the package.
# PCRE_DIR is the directory which is created when the source
# archive is unpacked.
# PCRE_UNZIP is the command used to unzip the source.
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

PCRE_SITE=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre
PCRE_VERSION=7.7
PCRE_SOURCE=pcre-$(PCRE_VERSION).tar.bz2
PCRE_DIR=pcre-$(PCRE_VERSION)
PCRE_UNZIP=bzcat
PCRE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCRE_DESCRIPTION=Perl-compatible regular expression library
PCRE_SECTION=util
PCRE_PRIORITY=optional
PCRE_DEPENDS=$(filter libstdc++, $(PACKAGES))
PCRE_CONFLICTS=

ifeq ($(HOSTCC), $(TARGET_CC))
	PCRE_LIBTOOL_TAG=""
else
	PCRE_LIBTOOL_TAG="--tag=CXX"
endif

#
# PCRE_IPK_VERSION should be incremented when the ipk changes.
#
PCRE_IPK_VERSION=1

#
# PCRE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PCRE_PATCHES=$(PCRE_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCRE_CPPFLAGS=
PCRE_LDFLAGS=
PCRE_CONFIG_ARGS=
ifeq (glibc, $(LIBC_STYLE))
ifeq (, $(filter libstdc++, $(PACKAGES)))
PCRE_CONFIG_ARGS +=--disable-cpp
endif
endif

#
# PCRE_BUILD_DIR is the directory in which the build is done.
# PCRE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCRE_IPK_DIR is the directory in which the ipk is built.
# PCRE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCRE_BUILD_DIR=$(BUILD_DIR)/pcre
PCRE_SOURCE_DIR=$(SOURCE_DIR)/pcre
PCRE_IPK_DIR=$(BUILD_DIR)/pcre-$(PCRE_VERSION)-ipk
PCRE_IPK=$(BUILD_DIR)/pcre_$(PCRE_VERSION)-$(PCRE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pcre-source pcre-unpack pcre pcre-stage pcre-ipk pcre-clean pcre-dirclean pcre-check
#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCRE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PCRE_SITE)/$(PCRE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PCRE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pcre-source: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES)

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
$(PCRE_BUILD_DIR)/.configured: $(DL_DIR)/$(PCRE_SOURCE) $(PCRE_PATCHES) make/pcre.mk
ifneq (, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	$(PCRE_UNZIP) $(DL_DIR)/$(PCRE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PCRE_PATCHES) | patch -d $(BUILD_DIR)/$(PCRE_DIR) -p1
	mv $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CC_FOR_BUILD=$(HOSTCC) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-utf8 \
		$(PCRE_CONFIG_ARGS) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

pcre-unpack: $(PCRE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCRE_BUILD_DIR)/.built: $(PCRE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) LIBTOOL_TAG=$(PCRE_LIBTOOL_TAG)
	touch $@
#
# This is the build convenience target.
#
pcre: $(PCRE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCRE_BUILD_DIR)/.staged: $(PCRE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libpcre.la
	rm -f $(STAGING_LIB_DIR)/libpcreposix.la
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' \
		$(STAGING_PREFIX)/bin/pcre-config \
		$(STAGING_LIB_DIR)/pkgconfig/libpcre.pc
	touch $@

pcre-stage: $(PCRE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pcre
#
$(PCRE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pcre" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCRE_PRIORITY)" >>$@
	@echo "Section: $(PCRE_SECTION)" >>$@
	@echo "Version: $(PCRE_VERSION)-$(PCRE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCRE_MAINTAINER)" >>$@
	@echo "Source: $(PCRE_SITE)/$(PCRE_SOURCE)" >>$@
	@echo "Description: $(PCRE_DESCRIPTION)" >>$@
	@echo "Depends: $(PCRE_DEPENDS)" >>$@
	@echo "Conflicts: $(PCRE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCRE_IPK_DIR)/opt/sbin or $(PCRE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCRE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PCRE_IPK_DIR)/opt/etc/pcre/...
# Documentation files should be installed in $(PCRE_IPK_DIR)/opt/doc/pcre/...
# Daemon startup scripts should be installed in $(PCRE_IPK_DIR)/opt/etc/init.d/S??pcre
#
# You may need to patch your application to make it use these locations.
#
$(PCRE_IPK): $(PCRE_BUILD_DIR)/.built
	rm -rf $(PCRE_IPK_DIR) $(BUILD_DIR)/pcre_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PCRE_BUILD_DIR) DESTDIR=$(PCRE_IPK_DIR) install
	find $(PCRE_IPK_DIR) -type d -exec chmod go+rx {} \;
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/bin/pcregrep
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/bin/pcretest
	$(STRIP_COMMAND) $(PCRE_IPK_DIR)/opt/lib/*.so
	rm -f $(PCRE_IPK_DIR)/opt/lib/*.la
	$(MAKE) $(PCRE_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCRE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pcre-ipk: $(PCRE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pcre-clean:
	-$(MAKE) -C $(PCRE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pcre-dirclean:
	rm -rf $(BUILD_DIR)/$(PCRE_DIR) $(PCRE_BUILD_DIR) $(PCRE_IPK_DIR) $(PCRE_IPK)

#
#
# Some sanity check for the package.
#
pcre-check: $(PCRE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PCRE_IPK)
