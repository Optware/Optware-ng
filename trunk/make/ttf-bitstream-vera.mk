###########################################################
#
# ttf_bitstream_vera
#
###########################################################

#
# TTF_BITSTREAM_VERA_VERSION, TTF_BITSTREAM_VERA_SITE and TTF_BITSTREAM_VERA_SOURCE define
# the upstream location of the source code for the package.
# TTF_BITSTREAM_VERA_DIR is the directory which is created when the source
# archive is unpacked.
# TTF_BITSTREAM_VERA_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
TTF_BITSTREAM_VERA_SITE=http://ftp.gnome.org/pub/GNOME/sources/ttf-bitstream-vera/$(TTF_BITSTREAM_VERA_VERSION)
TTF_BITSTREAM_VERA_VERSION=1.10
TTF_BITSTREAM_VERA_SOURCE=ttf-bitstream-vera-$(TTF_BITSTREAM_VERA_VERSION).tar.bz2
TTF_BITSTREAM_VERA_DIR=ttf-bitstream-vera-$(TTF_BITSTREAM_VERA_VERSION)
TTF_BITSTREAM_VERA_UNZIP=bzcat
TTF_BITSTREAM_VERA_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
TTF_BITSTREAM_VERA_DESCRIPTION=Bitstream Vera truetype font, for use with fontconfig, freetype, and xft
TTF_BITSTREAM_VERA_SECTION=font
TTF_BITSTREAM_VERA_PRIORITY=optional
TTF_BITSTREAM_VERA_DEPENDS=fontconfig

#
# TTF_BITSTREAM_VERA_IPK_VERSION should be incremented when the ipk changes.
#
TTF_BITSTREAM_VERA_IPK_VERSION=1

#
# TTF_BITSTREAM_VERA_LOCALES defines which locales get installed
#
TTF_BITSTREAM_VERA_LOCALES=

#
# TTF_BITSTREAM_VERA_CONFFILES should be a list of user-editable files
#TTF_BITSTREAM_VERA_CONFFILES=/opt/etc/ttf_bitstream_vera.conf /opt/etc/init.d/SXXttf_bitstream_vera

#
# TTF_BITSTREAM_VERA_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TTF_BITSTREAM_VERA_PATCHES=$(TTF_BITSTREAM_VERA_SOURCE_DIR)/configure.patch

#
# TTF_BITSTREAM_VERA_BUILD_DIR is the directory in which the build is done.
# TTF_BITSTREAM_VERA_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TTF_BITSTREAM_VERA_IPK_DIR is the directory in which the ipk is built.
# TTF_BITSTREAM_VERA_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TTF_BITSTREAM_VERA_BUILD_DIR=$(BUILD_DIR)/ttf-bitstream-vera
TTF_BITSTREAM_VERA_SOURCE_DIR=$(SOURCE_DIR)/ttf-bitstream-vera
TTF_BITSTREAM_VERA_IPK_DIR=$(BUILD_DIR)/ttf-bitstream-vera-$(TTF_BITSTREAM_VERA_VERSION)-ipk
TTF_BITSTREAM_VERA_IPK=$(BUILD_DIR)/ttf-bitstream-vera_$(TTF_BITSTREAM_VERA_VERSION)-$(TTF_BITSTREAM_VERA_IPK_VERSION)_armeb.ipk

#
# Automatically create a ipkg control file
#
$(TTF_BITSTREAM_VERA_SOURCE_DIR)/control:
	@rm -f $@
	@mkdir -p $(TTF_BITSTREAM_VERA_SOURCE_DIR) || true
	@echo "Package: ttf-bitstream-vera" >>$@
	@echo "Architecture: armeb" >>$@
	@echo "Priority: $(TTF_BITSTREAM_VERA_PRIORITY)" >>$@
	@echo "Section: $(TTF_BITSTREAM_VERA_SECTION)" >>$@
	@echo "Version: $(TTF_BITSTREAM_VERA_VERSION)-$(TTF_BITSTREAM_VERA_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TTF_BITSTREAM_VERA_MAINTAINER)" >>$@
	@echo "Source: $(TTF_BITSTREAM_VERA_SITE)/$(TTF_BITSTREAM_VERA_SOURCE)" >>$@
	@echo "Description: $(TTF_BITSTREAM_VERA_DESCRIPTION)" >>$@
	@echo "Depends: $(TTF_BITSTREAM_VERA_DEPENDS)" >>$@

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TTF_BITSTREAM_VERA_SOURCE):
	$(WGET) -P $(DL_DIR) $(TTF_BITSTREAM_VERA_SITE)/$(TTF_BITSTREAM_VERA_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ttf-bitstream-vera-source: $(DL_DIR)/$(TTF_BITSTREAM_VERA_SOURCE) $(TTF_BITSTREAM_VERA_PATCHES)

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
$(TTF_BITSTREAM_VERA_BUILD_DIR)/.configured: $(DL_DIR)/$(TTF_BITSTREAM_VERA_SOURCE) $(TTF_BITSTREAM_VERA_PATCHES)
	$(MAKE) glib-stage
	rm -rf $(BUILD_DIR)/$(TTF_BITSTREAM_VERA_DIR) $(TTF_BITSTREAM_VERA_BUILD_DIR)
	$(TTF_BITSTREAM_VERA_UNZIP) $(DL_DIR)/$(TTF_BITSTREAM_VERA_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(TTF_BITSTREAM_VERA_DIR) $(TTF_BITSTREAM_VERA_BUILD_DIR)
	touch $(TTF_BITSTREAM_VERA_BUILD_DIR)/.configured

ttf-bitstream-vera-unpack: $(TTF_BITSTREAM_VERA_BUILD_DIR)/.configured

#
# You should change the dependency to refer directly to the main binary
# which is built.
#
ttf-bitstream-vera: $(TTF_BITSTREAM_VERA_BUILD_DIR)/.configured

#
# This builds the IPK file.
#
# Binaries should be installed into $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/sbin or $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/etc/ttf_bitstream_vera/...
# Documentation files should be installed in $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/doc/ttf_bitstream_vera/...
# Daemon startup scripts should be installed in $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/etc/init.d/S??ttf_bitstream_vera
#
# You may need to patch your application to make it use these locations.
#
$(TTF_BITSTREAM_VERA_IPK): $(TTF_BITSTREAM_VERA_BUILD_DIR)/.configured
	rm -f $(TTF_BITSTREAM_VERA_SOURCE_DIR)/control
	$(MAKE) $(TTF_BITSTREAM_VERA_SOURCE_DIR)/control
	rm -rf $(TTF_BITSTREAM_VERA_IPK_DIR) $(BUILD_DIR)/ttf-bitstream-vera_*_armeb.ipk
	install -d $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/share/fonts/bitstream-vera
	cp $(TTF_BITSTREAM_VERA_BUILD_DIR)/*.ttf $(TTF_BITSTREAM_VERA_IPK_DIR)/opt/share/fonts/bitstream-vera

	install -d $(TTF_BITSTREAM_VERA_IPK_DIR)/CONTROL
	install -m 644 $(TTF_BITSTREAM_VERA_SOURCE_DIR)/control $(TTF_BITSTREAM_VERA_IPK_DIR)/CONTROL/control
	install -m 644 $(TTF_BITSTREAM_VERA_SOURCE_DIR)/postinst $(TTF_BITSTREAM_VERA_IPK_DIR)/CONTROL/postinst
	install -m 644 $(TTF_BITSTREAM_VERA_SOURCE_DIR)/postrm $(TTF_BITSTREAM_VERA_IPK_DIR)/CONTROL/postrm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TTF_BITSTREAM_VERA_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ttf-bitstream-vera-ipk: $(TTF_BITSTREAM_VERA_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ttf-bitstream-vera-clean:
	-$(MAKE) -C $(TTF_BITSTREAM_VERA_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ttf-bitstream-vera-dirclean:
	rm -rf $(BUILD_DIR)/$(TTF_BITSTREAM_VERA_DIR) $(TTF_BITSTREAM_VERA_BUILD_DIR) $(TTF_BITSTREAM_VERA_IPK_DIR) $(TTF_BITSTREAM_VERA_IPK) $(TTF_BITSTREAM_VERA_SOURCE_DIR)/control
