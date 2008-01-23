###########################################################
#
# asterisk14-core-sounds-en-ulaw
#
###########################################################
#
# ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION, ASTERISK14_CORE_SOUNDS_EN_ULAW_SITE and ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK14_CORE_SOUNDS_EN_ULAW_UNZIP is the command used to unzip the source.
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
ASTERISK14_CORE_SOUNDS_EN_ULAW_SITE=http://ftp.digium.com/pub/telephony/sounds/releases
ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION=1.4.8
ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE=asterisk-core-sounds-en-ulaw-$(ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION).tar.gz
ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR=asterisk-core-sounds-en-ulaw-$(ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION)
ASTERISK14_CORE_SOUNDS_EN_ULAW_UNZIP=zcat
ASTERISK14_CORE_SOUNDS_EN_ULAW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK14_CORE_SOUNDS_EN_ULAW_DESCRIPTION=asterisk-core-sounds-en-ulaw
ASTERISK14_CORE_SOUNDS_EN_ULAW_SECTION=misc
ASTERISK14_CORE_SOUNDS_EN_ULAW_PRIORITY=optional
ASTERISK14_CORE_SOUNDS_EN_ULAW_DEPENDS=
ASTERISK14_CORE_SOUNDS_EN_ULAW_SUGGESTS=
ASTERISK14_CORE_SOUNDS_EN_ULAW_CONFLICTS=asterisk-sounds

#
# ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_VERSION=1

#
# ASTERISK14_CORE_SOUNDS_EN_ULAW_CONFFILES should be a list of user-editable files
#ASTERISK14_CORE_SOUNDS_EN_ULAW_CONFFILES=/opt/etc/asterisk14-core-sounds-en-ulaw.conf /opt/etc/init.d/SXXasterisk14-core-sounds-en-ulaw

#
# ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES=$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK14_CORE_SOUNDS_EN_ULAW_CPPFLAGS=
ASTERISK14_CORE_SOUNDS_EN_ULAW_LDFLAGS=

#
# ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR is the directory in which the build is done.
# ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR is the directory in which the ipk is built.
# ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR=$(BUILD_DIR)/asterisk14-core-sounds-en-ulaw
ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE_DIR=$(SOURCE_DIR)/asterisk14-core-sounds-en-ulaw
ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR=$(BUILD_DIR)/asterisk14-core-sounds-en-ulaw-$(ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION)-ipk
ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK=$(BUILD_DIR)/asterisk14-core-sounds-en-ulaw_$(ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION)-$(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: asterisk14-core-sounds-en-ulaw-source asterisk14-core-sounds-en-ulaw-unpack asterisk14-core-sounds-en-ulaw asterisk14-core-sounds-en-ulaw-stage asterisk14-core-sounds-en-ulaw-ipk asterisk14-core-sounds-en-ulaw-clean asterisk14-core-sounds-en-ulaw-dirclean asterisk14-core-sounds-en-ulaw-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
#asterisk14-core-sounds-en-ulaw-source: $(DL_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES)

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
$(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES) make/asterisk14-core-sounds-en-ulaw.mk
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR); $(ASTERISK14_CORE_SOUNDS_EN_ULAW_UNZIP) $(DL_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE) | tar -C $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR) -xvf -
	if test -n "$(ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES)" ; \
		then cat $(ASTERISK14_CORE_SOUNDS_EN_ULAW_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR)" != "$(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR) ; \
	fi
	touch $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.configured

asterisk14-core-sounds-en-ulaw-unpack: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.configured
	rm -f $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built
	touch $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk14-core-sounds-en-ulaw: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.staged: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built
	rm -f $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.staged
	touch $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.staged

asterisk14-core-sounds-en-ulaw-stage: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk14-core-sounds-en-ulaw
#
$(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: asterisk14-core-sounds-en-ulaw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_SECTION)" >>$@
	@echo "Version: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_VERSION)-$(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_SITE)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_SOURCE)" >>$@
	@echo "Description: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/sbin or $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/etc/asterisk14-core-sounds-en-ulaw/...
# Documentation files should be installed in $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/doc/asterisk14-core-sounds-en-ulaw/...
# Daemon startup scripts should be installed in $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/etc/init.d/S??asterisk14-core-sounds-en-ulaw
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK): $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built
	rm -rf $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR) $(BUILD_DIR)/asterisk14-core-sounds-en-ulaw_*_$(TARGET_ARCH).ipk
	$(MAKE) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/CONTROL/control
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/dictate
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/dictate/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/dictate
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/digits
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/digits/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/digits
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/followme
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/followme/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/followme
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/letters
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/letters/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/letters
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/phonetic
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/phonetic/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/phonetic
	install -d $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/silence
	install -m 644 $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/silence/*.ulaw $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)/opt/var/lib/asterisk/sounds/silence
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk14-core-sounds-en-ulaw-ipk: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk14-core-sounds-en-ulaw-clean:
	rm -f $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR)/.built

#
# This is called from the top level makefile to clean all dynamically created
# directories.
asterisk14-core-sounds-en-ulaw-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK14_CORE_SOUNDS_EN_ULAW_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_BUILD_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK_DIR) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK)
#
#
# Some sanity check for the package.
#
asterisk14-core-sounds-en-ulaw-check: $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASTERISK14_CORE_SOUNDS_EN_ULAW_IPK)
