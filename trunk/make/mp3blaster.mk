###########################################################
#
# mp3blaster
#
###########################################################

#
# MP3BLASTER_VERSION, MP3BLASTER_SITE and MP3BLASTER_SOURCE define
# the upstream location of the source code for the package.
# MP3BLASTER_DIR is the directory which is created when the source
# archive is unpacked.
# MP3BLASTER_UNZIP is the command used to unzip the source.
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
MP3BLASTER_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/mp3blaster
MP3BLASTER_VERSION=3.2.3
MP3BLASTER_SOURCE=mp3blaster-$(MP3BLASTER_VERSION).tar.gz
MP3BLASTER_DIR=mp3blaster-$(MP3BLASTER_VERSION)
MP3BLASTER_UNZIP=zcat
MP3BLASTER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MP3BLASTER_DESCRIPTION=interactive text-based program that plays MP3, Ogg Vorbis, wav, and sid audio files
MP3BLASTER_SECTION=apps
MP3BLASTER_PRIORITY=optional
MP3BLASTER_DEPENDS=
MP3BLASTER_SUGGESTS=
MP3BLASTER_CONFLICTS=

#
# MP3BLASTER_IPK_VERSION should be incremented when the ipk changes.
#
MP3BLASTER_IPK_VERSION=2

#
# MP3BLASTER_CONFFILES should be a list of user-editable files
#MP3BLASTER_CONFFILES=/opt/etc/mp3blaster.conf /opt/etc/init.d/SXXmp3blaster

#
# MP3BLASTER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MP3BLASTER_PATCHES=$(MP3BLASTER_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MP3BLASTER_CPPFLAGS=
MP3BLASTER_LDFLAGS=

#
# MP3BLASTER_BUILD_DIR is the directory in which the build is done.
# MP3BLASTER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MP3BLASTER_IPK_DIR is the directory in which the ipk is built.
# MP3BLASTER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MP3BLASTER_BUILD_DIR=$(BUILD_DIR)/mp3blaster
MP3BLASTER_SOURCE_DIR=$(SOURCE_DIR)/mp3blaster
MP3BLASTER_IPK_DIR=$(BUILD_DIR)/mp3blaster-$(MP3BLASTER_VERSION)-ipk
MP3BLASTER_IPK=$(BUILD_DIR)/mp3blaster_$(MP3BLASTER_VERSION)-$(MP3BLASTER_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mp3blaster-source mp3blaster-unpack mp3blaster mp3blaster-stage mp3blaster-ipk mp3blaster-clean mp3blaster-dirclean mp3blaster-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MP3BLASTER_SOURCE):
	$(WGET) -P $(DL_DIR) $(MP3BLASTER_SITE)/$(MP3BLASTER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mp3blaster-source: $(DL_DIR)/$(MP3BLASTER_SOURCE) $(MP3BLASTER_PATCHES)

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
$(MP3BLASTER_BUILD_DIR)/.configured: $(DL_DIR)/$(MP3BLASTER_SOURCE) $(MP3BLASTER_PATCHES) make/mp3blaster.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(MP3BLASTER_DIR) $(MP3BLASTER_BUILD_DIR)
	$(MP3BLASTER_UNZIP) $(DL_DIR)/$(MP3BLASTER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MP3BLASTER_PATCHES)" ; \
		then cat $(MP3BLASTER_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MP3BLASTER_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MP3BLASTER_DIR)" != "$(MP3BLASTER_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MP3BLASTER_DIR) $(MP3BLASTER_BUILD_DIR) ; \
	fi
	(cd $(MP3BLASTER_BUILD_DIR); \
	sed -i \
	    -e 's|-I$$(includedir)|-I$(STAGING_INCLUDE_DIR)|' \
	    -e 's|-I/usr/include|-I$(STAGING_INCLUDE_DIR)|' \
		mpegsound/Makefile.in \
		nmixer/Makefile.in \
		src/Makefile.in; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MP3BLASTER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MP3BLASTER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MP3BLASTER_BUILD_DIR)/libtool
	touch $(MP3BLASTER_BUILD_DIR)/.configured

mp3blaster-unpack: $(MP3BLASTER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MP3BLASTER_BUILD_DIR)/.built: $(MP3BLASTER_BUILD_DIR)/.configured
	rm -f $(MP3BLASTER_BUILD_DIR)/.built
	$(MAKE) -C $(MP3BLASTER_BUILD_DIR)
	touch $(MP3BLASTER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mp3blaster: $(MP3BLASTER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MP3BLASTER_BUILD_DIR)/.staged: $(MP3BLASTER_BUILD_DIR)/.built
	rm -f $(MP3BLASTER_BUILD_DIR)/.staged
	$(MAKE) -C $(MP3BLASTER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MP3BLASTER_BUILD_DIR)/.staged

mp3blaster-stage: $(MP3BLASTER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mp3blaster
#
$(MP3BLASTER_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mp3blaster" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MP3BLASTER_PRIORITY)" >>$@
	@echo "Section: $(MP3BLASTER_SECTION)" >>$@
	@echo "Version: $(MP3BLASTER_VERSION)-$(MP3BLASTER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MP3BLASTER_MAINTAINER)" >>$@
	@echo "Source: $(MP3BLASTER_SITE)/$(MP3BLASTER_SOURCE)" >>$@
	@echo "Description: $(MP3BLASTER_DESCRIPTION)" >>$@
	@echo "Depends: $(MP3BLASTER_DEPENDS)" >>$@
	@echo "Suggests: $(MP3BLASTER_SUGGESTS)" >>$@
	@echo "Conflicts: $(MP3BLASTER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MP3BLASTER_IPK_DIR)/opt/sbin or $(MP3BLASTER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MP3BLASTER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MP3BLASTER_IPK_DIR)/opt/etc/mp3blaster/...
# Documentation files should be installed in $(MP3BLASTER_IPK_DIR)/opt/doc/mp3blaster/...
# Daemon startup scripts should be installed in $(MP3BLASTER_IPK_DIR)/opt/etc/init.d/S??mp3blaster
#
# You may need to patch your application to make it use these locations.
#
$(MP3BLASTER_IPK): $(MP3BLASTER_BUILD_DIR)/.built
	rm -rf $(MP3BLASTER_IPK_DIR) $(BUILD_DIR)/mp3blaster_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MP3BLASTER_BUILD_DIR) DESTDIR=$(MP3BLASTER_IPK_DIR) install-strip
#	install -d $(MP3BLASTER_IPK_DIR)/opt/etc/
#	install -m 644 $(MP3BLASTER_SOURCE_DIR)/mp3blaster.conf $(MP3BLASTER_IPK_DIR)/opt/etc/mp3blaster.conf
#	install -d $(MP3BLASTER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MP3BLASTER_SOURCE_DIR)/rc.mp3blaster $(MP3BLASTER_IPK_DIR)/opt/etc/init.d/SXXmp3blaster
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXmp3blaster
	$(MAKE) $(MP3BLASTER_IPK_DIR)/CONTROL/control
#	install -m 755 $(MP3BLASTER_SOURCE_DIR)/postinst $(MP3BLASTER_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MP3BLASTER_SOURCE_DIR)/prerm $(MP3BLASTER_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(MP3BLASTER_CONFFILES) | sed -e 's/ /\n/g' > $(MP3BLASTER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MP3BLASTER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mp3blaster-ipk: $(MP3BLASTER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mp3blaster-clean:
	rm -f $(MP3BLASTER_BUILD_DIR)/.built
	-$(MAKE) -C $(MP3BLASTER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mp3blaster-dirclean:
	rm -rf $(BUILD_DIR)/$(MP3BLASTER_DIR) $(MP3BLASTER_BUILD_DIR) $(MP3BLASTER_IPK_DIR) $(MP3BLASTER_IPK)
#
#
# Some sanity check for the package.
#
mp3blaster-check: $(MP3BLASTER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MP3BLASTER_IPK)
