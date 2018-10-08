###########################################################
#
# bsdgames
#
###########################################################
#
# BSDGAMES_VERSION, BSDGAMES_SITE and BSDGAMES_SOURCE define
# the upstream location of the source code for the package.
# BSDGAMES_DIR is the directory which is created when the source
# archive is unpacked.
# BSDGAMES_UNZIP is the command used to unzip the source.
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
BSDGAMES_SITE=http://pkgs.fedoraproject.org/repo/pkgs/bsd-games/$(BSDGAMES_SOURCE)/238a38a3a017ca9b216fc42bde405639
BSDGAMES_VERSION=2.17
BSDGAMES_SOURCE=bsd-games-$(BSDGAMES_VERSION).tar.gz
BSDGAMES_DIR=bsd-games-$(BSDGAMES_VERSION)
BSDGAMES_UNZIP=zcat
BSDGAMES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
BSDGAMES_DESCRIPTION=A collection of classic textual Unix games.
BSDGAMES_SECTION=games
BSDGAMES_PRIORITY=optional
BSDGAMES_DEPENDS=ncurses
BSDGAMES_SUGGESTS=less, miscfiles, openssl
BSDGAMES_CONFLICTS=

#
# BSDGAMES_IPK_VERSION should be incremented when the ipk changes.
#
BSDGAMES_IPK_VERSION=6

#
# BSDGAMES_CONFFILES should be a list of user-editable files
#BSDGAMES_CONFFILES=$(TARGET_PREFIX)/etc/bsdgames.conf $(TARGET_PREFIX)/etc/init.d/SXXbsdgames

#
# BSDGAMES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BSDGAMES_PATCHES=$(BSDGAMES_SOURCE_DIR)/replace-getline.patch \
$(BSDGAMES_SOURCE_DIR)/quiz-presidents.patch \
$(BSDGAMES_SOURCE_DIR)/add-acronyms.patch \
$(BSDGAMES_SOURCE_DIR)/sort-acronyms.comp.patch \
$(BSDGAMES_SOURCE_DIR)/refresh-robots-screen.patch \
$(BSDGAMES_SOURCE_DIR)/anne-boleyn.patch \
$(BSDGAMES_SOURCE_DIR)/capitals.patch \
$(BSDGAMES_SOURCE_DIR)/define-dead.patch \
$(BSDGAMES_SOURCE_DIR)/wump-update.patch \
$(BSDGAMES_SOURCE_DIR)/debian-changes-2.17-19.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BSDGAMES_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
BSDGAMES_LDFLAGS=

#
# BSDGAMES_BUILD_DIR is the directory in which the build is done.
# BSDGAMES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BSDGAMES_IPK_DIR is the directory in which the ipk is built.
# BSDGAMES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BSDGAMES_BUILD_DIR=$(BUILD_DIR)/bsdgames
BSDGAMES_SOURCE_DIR=$(SOURCE_DIR)/bsdgames
BSDGAMES_IPK_DIR=$(BUILD_DIR)/bsdgames-$(BSDGAMES_VERSION)-ipk
BSDGAMES_IPK=$(BUILD_DIR)/bsdgames_$(BSDGAMES_VERSION)-$(BSDGAMES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: bsdgames-source bsdgames-unpack bsdgames bsdgames-stage bsdgames-ipk bsdgames-clean bsdgames-dirclean bsdgames-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BSDGAMES_SOURCE):
	$(WGET) -P $(DL_DIR) $(BSDGAMES_SITE)/$(BSDGAMES_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(BSDGAMES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bsdgames-source: $(DL_DIR)/$(BSDGAMES_SOURCE) $(BSDGAMES_PATCHES)

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
$(BSDGAMES_BUILD_DIR)/.configured: $(DL_DIR)/$(BSDGAMES_SOURCE) $(BSDGAMES_PATCHES) make/bsdgames.mk
	$(MAKE) flex-stage ncurses-host-stage ncurses-stage openssl-host-stage openssl-stage
	rm -rf $(BUILD_DIR)/$(BSDGAMES_DIR) $(@D)
	$(BSDGAMES_UNZIP) $(DL_DIR)/$(BSDGAMES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BSDGAMES_PATCHES)" ; \
		then cat $(BSDGAMES_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(BSDGAMES_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(BSDGAMES_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(BSDGAMES_DIR) $(@D) ; \
	fi
	sed -i -e 's|strfile -rs|strfile.host -rs|g' \
		$(@D)/fortune/datfiles/Makefrag
	$(INSTALL) -m 644 $(BSDGAMES_SOURCE_DIR)/config.params $(@D)/config.params
ifneq (, $(filter buildroot-x86_64 uclibc, $(OPTWARE_TARGET) $(LIBC_STYLE)))
	sed -i -e "/bsd_games_cfg_no_build_dirs/s/='/='dm /" $(@D)/config.params
endif
	sed -i -e 's|/usr/share/games|$$(SHAREDIR)|' $(@D)/*/Makefrag
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BSDGAMES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BSDGAMES_LDFLAGS)" \
		bsd_games_cfg_install_prefix=$(BSDGAMES_IPK_DIR) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	touch $@

bsdgames-unpack: $(BSDGAMES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BSDGAMES_BUILD_DIR)/.built: $(BSDGAMES_BUILD_DIR)/.configured
	rm -f $@
#		phantasia/setup \
		boggle/mkdict/mkdict \
		boggle/mkindex/mkindex \
		;
	$(MAKE) -C $(@D) \
		CC=$(HOSTCC) \
		OPTIMIZE="-O2 -I$(HOST_STAGING_INCLUDE_DIR) -I$(HOST_STAGING_INCLUDE_DIR)/ncurses" \
		hack/makedefs \
		fortune/strfile/strfile \
		monop/initdeck \
		;
	mv $(@D)/fortune/strfile/strfile $(@D)/fortune/strfile/strfile.host
	$(MAKE) -C $(@D) fortune_strfile_clean
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		OPTIMIZE="$(STAGING_CPPFLAGS) $(BSDGAMES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BSDGAMES_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
bsdgames: $(BSDGAMES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BSDGAMES_BUILD_DIR)/.staged: $(BSDGAMES_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

bsdgames-stage: $(BSDGAMES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bsdgames
#
$(BSDGAMES_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: bsdgames" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BSDGAMES_PRIORITY)" >>$@
	@echo "Section: $(BSDGAMES_SECTION)" >>$@
	@echo "Version: $(BSDGAMES_VERSION)-$(BSDGAMES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BSDGAMES_MAINTAINER)" >>$@
	@echo "Source: $(BSDGAMES_SITE)/$(BSDGAMES_SOURCE)" >>$@
	@echo "Description: $(BSDGAMES_DESCRIPTION)" >>$@
	@echo "Depends: $(BSDGAMES_DEPENDS)" >>$@
	@echo "Suggests: $(BSDGAMES_SUGGESTS)" >>$@
	@echo "Conflicts: $(BSDGAMES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/sbin or $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/etc/bsdgames/...
# Documentation files should be installed in $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/doc/bsdgames/...
# Daemon startup scripts should be installed in $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??bsdgames
#
# You may need to patch your application to make it use these locations.
#
$(BSDGAMES_IPK): $(BSDGAMES_BUILD_DIR)/.built
	rm -rf $(BSDGAMES_IPK_DIR) $(BUILD_DIR)/bsdgames_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BSDGAMES_BUILD_DIR) install \
		INSTALL_PREFIX=$(BSDGAMES_IPK_DIR) \
		;
	$(STRIP_COMMAND) \
		$(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/bin/strfile \
		`ls $(BSDGAMES_IPK_DIR)$(TARGET_PREFIX)/games/* | egrep -v '/countmail|/rot13|/wargames|/wtf'`
	$(MAKE) $(BSDGAMES_IPK_DIR)/CONTROL/control
	echo $(BSDGAMES_CONFFILES) | sed -e 's/ /\n/g' > $(BSDGAMES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BSDGAMES_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(BSDGAMES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
bsdgames-ipk: $(BSDGAMES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
bsdgames-clean:
	rm -f $(BSDGAMES_BUILD_DIR)/.built
	-$(MAKE) -C $(BSDGAMES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
bsdgames-dirclean:
	rm -rf $(BUILD_DIR)/$(BSDGAMES_DIR) $(BSDGAMES_BUILD_DIR) $(BSDGAMES_IPK_DIR) $(BSDGAMES_IPK)
#
#
# Some sanity check for the package.
#
bsdgames-check: $(BSDGAMES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
