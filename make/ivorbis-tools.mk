###########################################################
#
# ivorbis-tools
#
###########################################################

# You must replace "ivorbis-tools" and "IVORBIS-TOOLS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# IVORBIS-TOOLS_VERSION, IVORBIS-TOOLS_SITE and IVORBIS-TOOLS_SOURCE define
# the upstream location of the source code for the package.
# IVORBIS-TOOLS_DIR is the directory which is created when the source
# archive is unpacked.
# IVORBIS-TOOLS_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
IVORBIS_TOOLS_VERSION=1.0
IVORBIS_TOOLS_SITE=http://www.vorbis.com/files/$(IVORBIS_TOOLS_VERSION)/unix
IVORBIS_TOOLS_SOURCE=vorbis-tools-$(IVORBIS_TOOLS_VERSION).tar.gz
IVORBIS_TOOLS_DIR=vorbis-tools-$(IVORBIS_TOOLS_VERSION)
IVORBIS_TOOLS_UNZIP=zcat
IVORBIS_TOOLS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>

IVORBIS_TOOLS_DESCRIPTION=Tools to allow you to play, encode, and manage Ogg Vorbis files. This version is hacked to use the "Tremor" integer decoder.
IVORBIS_TOOLS_SECTION=sound
IVORBIS_TOOLS_PRIORITY=optional
IVORBIS_TOOLS_DEPENDS=libvorbis, libogg, libao, libcurl, libvorbisidec
IVORBIS_TOOLS_SUGGESTS=
IVORBIS_TOOLS_CONFLICTS=vorbis-tools

#
# IVORBIS-TOOLS_IPK_VERSION should be incremented when the ipk changes.
#
IVORBIS_TOOLS_IPK_VERSION=6

#
# IVORBIS-TOOLS_CONFFILES should be a list of user-editable files
#IVORBIS_TOOLS_CONFFILES=/opt/etc/ivorbis-tools.conf /opt/etc/init.d/SXXivorbis-tools

#
# IVORBIS-TOOLS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
IVORBIS_TOOLS_PATCHES=$(IVORBIS_TOOLS_SOURCE_DIR)/oggdec-tremor.patch \
			$(IVORBIS_TOOLS_SOURCE_DIR)/oggdec-endian.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IVORBIS_TOOLS_CPPFLAGS=
IVORBIS_TOOLS_LDFLAGS=

#
# IVORBIS-TOOLS_BUILD_DIR is the directory in which the build is done.
# IVORBIS-TOOLS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IVORBIS-TOOLS_IPK_DIR is the directory in which the ipk is built.
# IVORBIS-TOOLS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IVORBIS_TOOLS_BUILD_DIR=$(BUILD_DIR)/ivorbis-tools
IVORBIS_TOOLS_SOURCE_DIR=$(SOURCE_DIR)/ivorbis-tools
IVORBIS_TOOLS_IPK_DIR=$(BUILD_DIR)/ivorbis-tools-$(IVORBIS_TOOLS_VERSION)-ipk
IVORBIS_TOOLS_IPK=$(BUILD_DIR)/ivorbis-tools_$(IVORBIS_TOOLS_VERSION)-$(IVORBIS_TOOLS_IPK_VERSION)_${TARGET_ARCH}.ipk

.PHONY: ivorbis-tools-source ivorbis-tools-unpack ivorbis-tools ivorbis-tools-stage ivorbis-tools-ipk ivorbis-tools-clean ivorbis-tools-dirclean ivorbis-tools-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IVORBIS_TOOLS_SOURCE):
	$(WGET) -P $(DL_DIR) $(IVORBIS_TOOLS_SITE)/$(IVORBIS_TOOLS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ivorbis-tools-source: $(DL_DIR)/$(IVORBIS_TOOLS_SOURCE) $(IVORBIS_TOOLS_PATCHES)

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
$(IVORBIS_TOOLS_BUILD_DIR)/.configured: $(DL_DIR)/$(IVORBIS_TOOLS_SOURCE) $(IVORBIS_TOOLS_PATCHES)
	$(MAKE) libogg-stage libvorbis-stage libao-stage libcurl-stage libvorbisidec-stage
	rm -rf $(BUILD_DIR)/$(IVORBIS_TOOLS_DIR) $(IVORBIS_TOOLS_BUILD_DIR)
	$(IVORBIS_TOOLS_UNZIP) $(DL_DIR)/$(IVORBIS_TOOLS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(IVORBIS_TOOLS_PATCHES) | patch -d $(BUILD_DIR)/$(IVORBIS_TOOLS_DIR) -p1
	mv $(BUILD_DIR)/$(IVORBIS_TOOLS_DIR) $(IVORBIS_TOOLS_BUILD_DIR)
	(cd $(IVORBIS_TOOLS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IVORBIS_TOOLS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IVORBIS_TOOLS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-ao=$(STAGING_PREFIX) \
		--with-curl=$(STAGING_PREFIX) \
		--with-ogg=$(STAGING_PREFIX) \
		--with-vorbis=$(STAGING_PREFIX) \
		--disable-curltest \
		--disable-nls \
	)
	sed -ie '/CURLOPT_MUTE/d' $(IVORBIS_TOOLS_BUILD_DIR)/ogg123/http_transport.c
	$(PATCH_LIBTOOL) $(IVORBIS_TOOLS_BUILD_DIR)/libtool
	touch $(IVORBIS_TOOLS_BUILD_DIR)/.configured

ivorbis-tools-unpack: $(IVORBIS_TOOLS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IVORBIS_TOOLS_BUILD_DIR)/.built: $(IVORBIS_TOOLS_BUILD_DIR)/.configured
	rm -f $(IVORBIS_TOOLS_BUILD_DIR)/.built
	$(MAKE) -C $(IVORBIS_TOOLS_BUILD_DIR)
	touch $(IVORBIS_TOOLS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ivorbis-tools: $(IVORBIS_TOOLS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(IVORBIS_TOOLS_BUILD_DIR)/.staged: $(IVORBIS_TOOLS_BUILD_DIR)/.built
#	rm -f $(IVORBIS_TOOLS_BUILD_DIR)/.staged
#	$(MAKE) -C $(IVORBIS_TOOLS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(IVORBIS_TOOLS_BUILD_DIR)/.staged
#
#ivorbis-tools-stage: $(IVORBIS_TOOLS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/<foo>
#
$(IVORBIS_TOOLS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ivorbis-tools" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IVORBIS_TOOLS_PRIORITY)" >>$@
	@echo "Section: $(IVORBIS_TOOLS_SECTION)" >>$@
	@echo "Version: $(IVORBIS_TOOLS_VERSION)-$(IVORBIS_TOOLS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IVORBIS_TOOLS_MAINTAINER)" >>$@
	@echo "Source: $(IVORBIS_TOOLS_SITE)/$(IVORBIS_TOOLS_SOURCE)" >>$@
	@echo "Description: $(IVORBIS_TOOLS_DESCRIPTION)" >>$@
	@echo "Depends: $(IVORBIS_TOOLS_DEPENDS)" >>$@
	@echo "Suggests: $(IVORBIS_TOOLS_SUGGESTS)" >>$@
	@echo "Conflicts: $(IVORBIS_TOOLS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IVORBIS_TOOLS_IPK_DIR)/opt/sbin or $(IVORBIS_TOOLS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IVORBIS_TOOLS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IVORBIS_TOOLS_IPK_DIR)/opt/etc/ivorbis-tools/...
# Documentation files should be installed in $(IVORBIS_TOOLS_IPK_DIR)/opt/doc/ivorbis-tools/...
# Daemon startup scripts should be installed in $(IVORBIS_TOOLS_IPK_DIR)/opt/etc/init.d/S??ivorbis-tools
#
# You may need to patch your application to make it use these locations.
#
$(IVORBIS_TOOLS_IPK): $(IVORBIS_TOOLS_BUILD_DIR)/.built
	rm -rf $(IVORBIS_TOOLS_IPK_DIR) $(BUILD_DIR)/ivorbis-tools_*_${TARGET_ARCH}.ipk
	$(MAKE) -C $(IVORBIS_TOOLS_BUILD_DIR) DESTDIR=$(IVORBIS_TOOLS_IPK_DIR) install
	$(STRIP_COMMAND) $(IVORBIS_TOOLS_IPK_DIR)/opt/bin/*
	$(MAKE) $(IVORBIS_TOOLS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IVORBIS_TOOLS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ivorbis-tools-ipk: $(IVORBIS_TOOLS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ivorbis-tools-clean:
	-$(MAKE) -C $(IVORBIS_TOOLS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ivorbis-tools-dirclean:
	rm -rf $(BUILD_DIR)/$(IVORBIS_TOOLS_DIR) $(IVORBIS_TOOLS_BUILD_DIR) $(IVORBIS_TOOLS_IPK_DIR) $(IVORBIS_TOOLS_IPK)

#
#
# Some sanity check for the package.
#
ivorbis-tools-check: $(IVORBIS_TOOLS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IVORBIS_TOOLS_IPK)
