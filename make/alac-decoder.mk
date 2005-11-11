###########################################################
#
# alac_decoder
#
###########################################################

# You must replace "alac_decoder" and "ALAC_DECODER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ALAC_DECODER_VERSION, ALAC_DECODER_SITE and ALAC_DECODER_SOURCE define
# the upstream location of the source code for the package.
# ALAC_DECODER_DIR is the directory which is created when the source
# archive is unpacked.
# ALAC_DECODER_UNZIP is the command used to unzip the source.
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
ALAC_DECODER_SITE=http://craz.net/programs/itunes/files
ALAC_DECODER_VERSION=0.1.0
ALAC_DECODER_SOURCE=alac_decoder-$(ALAC_DECODER_VERSION).tar.gz
ALAC_DECODER_DIR=alac_decoder
ALAC_DECODER_UNZIP=zcat
ALAC_DECODER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ALAC_DECODER_DESCRIPTION=A decoder for the apple lossless file format
ALAC_DECODER_SECTION=audio
ALAC_DECODER_PRIORITY=optional
ALAC_DECODER_DEPENDS=
ALAC_DECODER_CONFLICTS=

#
# ALAC_DECODER_IPK_VERSION should be incremented when the ipk changes.
#
ALAC_DECODER_IPK_VERSION=2

#
# ALAC_DECODER_CONFFILES should be a list of user-editable files
ALAC_DECODER_CONFFILES=

#
# ALAC_DECODER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ALAC_DECODER_PATCHES=$(ALAC_DECODER_SOURCE_DIR)/makefile.patch $(ALAC_DECODER_SOURCE_DIR)/alac_performance.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ALAC_DECODER_CPPFLAGS=-O3
ALAC_DECODER_LDFLAGS=

#
# ALAC_DECODER_BUILD_DIR is the directory in which the build is done.
# ALAC_DECODER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ALAC_DECODER_IPK_DIR is the directory in which the ipk is built.
# ALAC_DECODER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ALAC_DECODER_BUILD_DIR=$(BUILD_DIR)/alac_decoder_build
ALAC_DECODER_SOURCE_DIR=$(SOURCE_DIR)/alac-decoder
ALAC_DECODER_IPK_DIR=$(BUILD_DIR)/alac-decoder-$(ALAC_DECODER_VERSION)-ipk
ALAC_DECODER_IPK=$(BUILD_DIR)/alac-decoder_$(ALAC_DECODER_VERSION)-$(ALAC_DECODER_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ALAC_DECODER_SOURCE):
	$(WGET) -P $(DL_DIR) $(ALAC_DECODER_SITE)/$(ALAC_DECODER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
alac-decoder-source: $(DL_DIR)/$(ALAC_DECODER_SOURCE) $(ALAC_DECODER_PATCHES)

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
$(ALAC_DECODER_BUILD_DIR)/.built: $(DL_DIR)/$(ALAC_DECODER_SOURCE) $(ALAC_DECODER_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ALAC_DECODER_DIR) $(ALAC_DECODER_BUILD_DIR)
	$(ALAC_DECODER_UNZIP) $(DL_DIR)/$(ALAC_DECODER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(ALAC_DECODER_PATCHES) | patch -d $(BUILD_DIR)/$(ALAC_DECODER_DIR) -p1
	mv $(BUILD_DIR)/$(ALAC_DECODER_DIR) $(ALAC_DECODER_BUILD_DIR)
	(cd $(ALAC_DECODER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(ALAC_DECODER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ALAC_DECODER_LDFLAGS)" \
		$(MAKE) \
	)
	touch $(ALAC_DECODER_BUILD_DIR)/.built

# I'm not sure what this target is used for
alac-decoder-unpack: $(ALAC_DECODER_BUILD_DIR)/.built


#
# This is the build convenience target.
#
alac-decoder: $(ALAC_DECODER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(ALAC_DECODER_BUILD_DIR)/.staged: $(ALAC_DECODER_BUILD_DIR)/.built
#	rm -f $(ALAC_DECODER_BUILD_DIR)/.staged
#	$(MAKE) -C $(ALAC_DECODER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(ALAC_DECODER_BUILD_DIR)/.staged
#
#alac_decoder-stage: $(ALAC_DECODER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/alac_decoder
#
$(ALAC_DECODER_IPK_DIR)/CONTROL/control:
	@install -d $(ALAC_DECODER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: alac-decoder" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ALAC_DECODER_PRIORITY)" >>$@
	@echo "Section: $(ALAC_DECODER_SECTION)" >>$@
	@echo "Version: $(ALAC_DECODER_VERSION)-$(ALAC_DECODER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ALAC_DECODER_MAINTAINER)" >>$@
	@echo "Source: $(ALAC_DECODER_SITE)/$(ALAC_DECODER_SOURCE)" >>$@
	@echo "Description: $(ALAC_DECODER_DESCRIPTION)" >>$@
	@echo "Depends: $(ALAC_DECODER_DEPENDS)" >>$@
	@echo "Conflicts: $(ALAC_DECODER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ALAC_DECODER_IPK_DIR)/opt/sbin or $(ALAC_DECODER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ALAC_DECODER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ALAC_DECODER_IPK_DIR)/opt/etc/alac_decoder/...
# Documentation files should be installed in $(ALAC_DECODER_IPK_DIR)/opt/doc/alac_decoder/...
# Daemon startup scripts should be installed in $(ALAC_DECODER_IPK_DIR)/opt/etc/init.d/S??alac_decoder
#
# You may need to patch your application to make it use these locations.
#
$(ALAC_DECODER_IPK): $(ALAC_DECODER_BUILD_DIR)/.built
	rm -rf $(ALAC_DECODER_IPK_DIR) $(BUILD_DIR)/alac-decoder_*_$(TARGET_ARCH).ipk
	$(STRIP_COMMAND) $(ALAC_DECODER_BUILD_DIR)/alac
	install -d $(ALAC_DECODER_IPK_DIR)/opt/bin
	install -m 755 $(ALAC_DECODER_BUILD_DIR)/alac $(ALAC_DECODER_IPK_DIR)/opt/bin/alac

	$(MAKE) $(ALAC_DECODER_IPK_DIR)/CONTROL/control

	echo $(ALAC_DECODER_CONFFILES) | sed -e 's/ /\n/g' > $(ALAC_DECODER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ALAC_DECODER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
alac-decoder-ipk: $(ALAC_DECODER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
alac-decoder-clean:
	-$(MAKE) -C $(ALAC_DECODER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
alac-decoder-dirclean:
	rm -rf $(BUILD_DIR)/$(ALAC_DECODER_DIR) $(ALAC_DECODER_BUILD_DIR) $(ALAC_DECODER_IPK_DIR) $(ALAC_DECODER_IPK)
