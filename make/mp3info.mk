###########################################################
#
# mp3info
#
###########################################################
#
# MP3INFO_VERSION, MP3INFO_SITE and MP3INFO_SOURCE define
# the upstream location of the source code for the package.
# MP3INFO_DIR is the directory which is created when the source
# archive is unpacked.
# MP3INFO_UNZIP is the command used to unzip the source.
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
MP3INFO_SITE=http://www.ibiblio.org/pub/linux/apps/sound/mp3-utils/mp3info
MP3INFO_VERSION=0.8.5a
MP3INFO_SOURCE=mp3info-$(MP3INFO_VERSION).tgz
MP3INFO_DIR=mp3info-$(MP3INFO_VERSION)
MP3INFO_UNZIP=zcat
MP3INFO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MP3INFO_DESCRIPTION=A little utility used to read and modify the ID3 tags of MP3 files.
MP3INFO_SECTION=audio
MP3INFO_PRIORITY=optional
MP3INFO_DEPENDS=ncurses
MP3INFO_SUGGESTS=
MP3INFO_CONFLICTS=

#
# MP3INFO_IPK_VERSION should be incremented when the ipk changes.
#
MP3INFO_IPK_VERSION=1

#
# MP3INFO_CONFFILES should be a list of user-editable files
#MP3INFO_CONFFILES=/opt/etc/mp3info.conf /opt/etc/init.d/SXXmp3info

#
# MP3INFO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MP3INFO_PATCHES=$(MP3INFO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MP3INFO_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
MP3INFO_LDFLAGS=

#
# MP3INFO_BUILD_DIR is the directory in which the build is done.
# MP3INFO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MP3INFO_IPK_DIR is the directory in which the ipk is built.
# MP3INFO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MP3INFO_BUILD_DIR=$(BUILD_DIR)/mp3info
MP3INFO_SOURCE_DIR=$(SOURCE_DIR)/mp3info
MP3INFO_IPK_DIR=$(BUILD_DIR)/mp3info-$(MP3INFO_VERSION)-ipk
MP3INFO_IPK=$(BUILD_DIR)/mp3info_$(MP3INFO_VERSION)-$(MP3INFO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mp3info-source mp3info-unpack mp3info mp3info-stage mp3info-ipk mp3info-clean mp3info-dirclean mp3info-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MP3INFO_SOURCE):
	$(WGET) -P $(@D) $(MP3INFO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mp3info-source: $(DL_DIR)/$(MP3INFO_SOURCE) $(MP3INFO_PATCHES)

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
$(MP3INFO_BUILD_DIR)/.configured: $(DL_DIR)/$(MP3INFO_SOURCE) $(MP3INFO_PATCHES) make/mp3info.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(MP3INFO_DIR) $(@D)
	$(MP3INFO_UNZIP) $(DL_DIR)/$(MP3INFO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MP3INFO_PATCHES)" ; \
		then cat $(MP3INFO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MP3INFO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MP3INFO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(MP3INFO_DIR) $(@D) ; \
	fi
	sed -i -e '/^LIBS/s|$$| $$(LDFLAGS)|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MP3INFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MP3INFO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mp3info-unpack: $(MP3INFO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MP3INFO_BUILD_DIR)/.built: $(MP3INFO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) mp3info doc \
		prefix=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MP3INFO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MP3INFO_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
mp3info: $(MP3INFO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MP3INFO_BUILD_DIR)/.staged: $(MP3INFO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

mp3info-stage: $(MP3INFO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mp3info
#
$(MP3INFO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mp3info" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MP3INFO_PRIORITY)" >>$@
	@echo "Section: $(MP3INFO_SECTION)" >>$@
	@echo "Version: $(MP3INFO_VERSION)-$(MP3INFO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MP3INFO_MAINTAINER)" >>$@
	@echo "Source: $(MP3INFO_SITE)/$(MP3INFO_SOURCE)" >>$@
	@echo "Description: $(MP3INFO_DESCRIPTION)" >>$@
	@echo "Depends: $(MP3INFO_DEPENDS)" >>$@
	@echo "Suggests: $(MP3INFO_SUGGESTS)" >>$@
	@echo "Conflicts: $(MP3INFO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MP3INFO_IPK_DIR)/opt/sbin or $(MP3INFO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MP3INFO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MP3INFO_IPK_DIR)/opt/etc/mp3info/...
# Documentation files should be installed in $(MP3INFO_IPK_DIR)/opt/doc/mp3info/...
# Daemon startup scripts should be installed in $(MP3INFO_IPK_DIR)/opt/etc/init.d/S??mp3info
#
# You may need to patch your application to make it use these locations.
#
$(MP3INFO_IPK): $(MP3INFO_BUILD_DIR)/.built
	rm -rf $(MP3INFO_IPK_DIR) $(BUILD_DIR)/mp3info_*_$(TARGET_ARCH).ipk
	install -d $(MP3INFO_IPK_DIR)/opt/bin $(MP3INFO_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(<D) install-mp3info \
		prefix=$(MP3INFO_IPK_DIR)/opt \
		$(TARGET_CONFIGURE_OPTS) \
		;
#	install -d $(MP3INFO_IPK_DIR)/opt/etc/
#	install -m 644 $(MP3INFO_SOURCE_DIR)/mp3info.conf $(MP3INFO_IPK_DIR)/opt/etc/mp3info.conf
#	install -d $(MP3INFO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MP3INFO_SOURCE_DIR)/rc.mp3info $(MP3INFO_IPK_DIR)/opt/etc/init.d/SXXmp3info
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MP3INFO_IPK_DIR)/opt/etc/init.d/SXXmp3info
	$(MAKE) $(MP3INFO_IPK_DIR)/CONTROL/control
#	install -m 755 $(MP3INFO_SOURCE_DIR)/postinst $(MP3INFO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MP3INFO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MP3INFO_SOURCE_DIR)/prerm $(MP3INFO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MP3INFO_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(MP3INFO_IPK_DIR)/CONTROL/postinst $(MP3INFO_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(MP3INFO_CONFFILES) | sed -e 's/ /\n/g' > $(MP3INFO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MP3INFO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mp3info-ipk: $(MP3INFO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mp3info-clean:
	rm -f $(MP3INFO_BUILD_DIR)/.built
	-$(MAKE) -C $(MP3INFO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mp3info-dirclean:
	rm -rf $(BUILD_DIR)/$(MP3INFO_DIR) $(MP3INFO_BUILD_DIR) $(MP3INFO_IPK_DIR) $(MP3INFO_IPK)
#
#
# Some sanity check for the package.
#
mp3info-check: $(MP3INFO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MP3INFO_IPK)
