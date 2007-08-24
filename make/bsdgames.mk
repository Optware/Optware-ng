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
BSDGAMES_SITE=ftp://metalab.unc.edu/pub/Linux/games
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
BSDGAMES_IPK_VERSION=1

#
# BSDGAMES_CONFFILES should be a list of user-editable files
#BSDGAMES_CONFFILES=/opt/etc/bsdgames.conf /opt/etc/init.d/SXXbsdgames

#
# BSDGAMES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BSDGAMES_PATCHES=$(BSDGAMES_SOURCE_DIR)/configure.patch

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
	$(MAKE) flex-stage
	$(MAKE) ncurses-stage
	$(MAKE) openssl-host-stage
	$(MAKE) openssl-stage
	rm -rf $(BUILD_DIR)/$(BSDGAMES_DIR) $(BSDGAMES_BUILD_DIR)
	$(BSDGAMES_UNZIP) $(DL_DIR)/$(BSDGAMES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BSDGAMES_PATCHES)" ; \
		then cat $(BSDGAMES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BSDGAMES_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BSDGAMES_DIR)" != "$(BSDGAMES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BSDGAMES_DIR) $(BSDGAMES_BUILD_DIR) ; \
	fi
	sed -i -e 's|strfile -rs|strfile.host -rs|g' \
		$(BSDGAMES_BUILD_DIR)/fortune/datfiles/Makefrag
	cp $(BSDGAMES_SOURCE_DIR)/config.params $(BSDGAMES_BUILD_DIR)/
ifeq (uclibc, $(LIBC_STYLE))
	sed -i -e "/bsd_games_cfg_no_build_dirs/s/='/='dm /" $(BSDGAMES_BUILD_DIR)/config.params
endif
	(cd $(BSDGAMES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BSDGAMES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BSDGAMES_LDFLAGS)" \
		bsd_games_cfg_install_prefix=$(BSDGAMES_IPK_DIR) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
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
	$(MAKE) -C $(BSDGAMES_BUILD_DIR) \
		CC=$(HOSTCC) \
		OPTIMIZE="-O2 -I$(HOST_STAGING_INCLUDE_DIR)" \
		hack/makedefs \
		fortune/strfile/strfile \
		monop/initdeck \
		;
	mv $(BSDGAMES_BUILD_DIR)/fortune/strfile/strfile{,.host}
	$(MAKE) -C $(BSDGAMES_BUILD_DIR) fortune_strfile_clean
	$(MAKE) -C $(BSDGAMES_BUILD_DIR) \
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
#	$(MAKE) -C $(BSDGAMES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

bsdgames-stage: $(BSDGAMES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bsdgames
#
$(BSDGAMES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
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
# Binaries should be installed into $(BSDGAMES_IPK_DIR)/opt/sbin or $(BSDGAMES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BSDGAMES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BSDGAMES_IPK_DIR)/opt/etc/bsdgames/...
# Documentation files should be installed in $(BSDGAMES_IPK_DIR)/opt/doc/bsdgames/...
# Daemon startup scripts should be installed in $(BSDGAMES_IPK_DIR)/opt/etc/init.d/S??bsdgames
#
# You may need to patch your application to make it use these locations.
#
$(BSDGAMES_IPK): $(BSDGAMES_BUILD_DIR)/.built
	rm -rf $(BSDGAMES_IPK_DIR) $(BUILD_DIR)/bsdgames_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(BSDGAMES_BUILD_DIR) install \
		INSTALL_PREFIX=$(BSDGAMES_IPK_DIR) \
		;
	$(STRIP_COMMAND) \
		$(BSDGAMES_IPK_DIR)/opt/bin/strfile \
		`ls $(BSDGAMES_IPK_DIR)/opt/games/* | egrep -v '/countmail|/rot13|/wargames|/wtf'`
	$(MAKE) $(BSDGAMES_IPK_DIR)/CONTROL/control
	echo $(BSDGAMES_CONFFILES) | sed -e 's/ /\n/g' > $(BSDGAMES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BSDGAMES_IPK_DIR)

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
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BSDGAMES_IPK)
