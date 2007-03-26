###########################################################
#
# fish
#
###########################################################
#
# FISH_VERSION, FISH_SITE and FISH_SOURCE define
# the upstream location of the source code for the package.
# FISH_DIR is the directory which is created when the source
# archive is unpacked.
# FISH_UNZIP is the command used to unzip the source.
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
FISH_VERSION=1.22.3
FISH_SITE=http://fishshell.org/files/$(FISH_VERSION)
FISH_SOURCE=fish-$(FISH_VERSION).tar.bz2
FISH_DIR=fish-$(FISH_VERSION)
FISH_UNZIP=bzcat
FISH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FISH_DESCRIPTION=A user friendly command line shell for UNIX-like operating systems such as Linux.
FISH_SECTION=shell
FISH_PRIORITY=optional
FISH_DEPENDS=ncurses
FISH_SUGGESTS=
FISH_CONFLICTS=

#
# FISH_IPK_VERSION should be incremented when the ipk changes.
#
FISH_IPK_VERSION=1

#
# FISH_CONFFILES should be a list of user-editable files
#FISH_CONFFILES=/opt/etc/fish.conf /opt/etc/init.d/SXXfish

#
# FISH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
FISH_PATCHES=$(FISH_SOURCE_DIR)/configure.ac.patch
FISH_CONFIGURE_ENV= \
		LIBC_STYLE=$(LIBC_STYLE) \
		local_cv_has__std_c99=yes \
		ac_cv_file__proc_self_stat=yes
else
FISH_PATCHES=
FISH_CONFIGURE_ENV=
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FISH_CPPFLAGS=
FISH_LDFLAGS=

#
# FISH_BUILD_DIR is the directory in which the build is done.
# FISH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FISH_IPK_DIR is the directory in which the ipk is built.
# FISH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FISH_BUILD_DIR=$(BUILD_DIR)/fish
FISH_SOURCE_DIR=$(SOURCE_DIR)/fish
FISH_IPK_DIR=$(BUILD_DIR)/fish-$(FISH_VERSION)-ipk
FISH_IPK=$(BUILD_DIR)/fish_$(FISH_VERSION)-$(FISH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fish-source fish-unpack fish fish-stage fish-ipk fish-clean fish-dirclean fish-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FISH_SOURCE):
	$(WGET) -P $(DL_DIR) $(FISH_SITE)/$(FISH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fish-source: $(DL_DIR)/$(FISH_SOURCE) $(FISH_PATCHES)

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
$(FISH_BUILD_DIR)/.configured: $(DL_DIR)/$(FISH_SOURCE) $(FISH_PATCHES) make/fish.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(FISH_DIR) $(FISH_BUILD_DIR)
	$(FISH_UNZIP) $(DL_DIR)/$(FISH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FISH_PATCHES)" ; \
		then cat $(FISH_PATCHES) | patch -bd $(BUILD_DIR)/$(FISH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FISH_DIR)" != "$(FISH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FISH_DIR) $(FISH_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	cd $(FISH_BUILD_DIR); autoreconf
endif
	(cd $(FISH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FISH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FISH_LDFLAGS)" \
		$(FISH_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-xsel \
		--disable-nls \
		--disable-static \
	)
	sed -ie '/^all:/s/user_doc //' $(FISH_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(FISH_BUILD_DIR)/libtool
	touch $(FISH_BUILD_DIR)/.configured

fish-unpack: $(FISH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FISH_BUILD_DIR)/.built: $(FISH_BUILD_DIR)/.configured
	rm -f $(FISH_BUILD_DIR)/.built
	$(MAKE) -C $(FISH_BUILD_DIR)
	touch $(FISH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
fish: $(FISH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FISH_BUILD_DIR)/.staged: $(FISH_BUILD_DIR)/.built
	rm -f $(FISH_BUILD_DIR)/.staged
	$(MAKE) -C $(FISH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FISH_BUILD_DIR)/.staged

fish-stage: $(FISH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fish
#
$(FISH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fish" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FISH_PRIORITY)" >>$@
	@echo "Section: $(FISH_SECTION)" >>$@
	@echo "Version: $(FISH_VERSION)-$(FISH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FISH_MAINTAINER)" >>$@
	@echo "Source: $(FISH_SITE)/$(FISH_SOURCE)" >>$@
	@echo "Description: $(FISH_DESCRIPTION)" >>$@
	@echo "Depends: $(FISH_DEPENDS)" >>$@
	@echo "Suggests: $(FISH_SUGGESTS)" >>$@
	@echo "Conflicts: $(FISH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FISH_IPK_DIR)/opt/sbin or $(FISH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FISH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FISH_IPK_DIR)/opt/etc/fish/...
# Documentation files should be installed in $(FISH_IPK_DIR)/opt/doc/fish/...
# Daemon startup scripts should be installed in $(FISH_IPK_DIR)/opt/etc/init.d/S??fish
#
# You may need to patch your application to make it use these locations.
#
$(FISH_IPK): $(FISH_BUILD_DIR)/.built
	rm -rf $(FISH_IPK_DIR) $(BUILD_DIR)/fish_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FISH_BUILD_DIR) DESTDIR=$(FISH_IPK_DIR) install
	$(STRIP_COMMAND) $(FISH_IPK_DIR)/opt/bin/*
#	install -d $(FISH_IPK_DIR)/opt/etc/
#	install -m 644 $(FISH_SOURCE_DIR)/fish.conf $(FISH_IPK_DIR)/opt/etc/fish.conf
#	install -d $(FISH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FISH_SOURCE_DIR)/rc.fish $(FISH_IPK_DIR)/opt/etc/init.d/SXXfish
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXfish
	$(MAKE) $(FISH_IPK_DIR)/CONTROL/control
#	install -m 755 $(FISH_SOURCE_DIR)/postinst $(FISH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FISH_SOURCE_DIR)/prerm $(FISH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(FISH_CONFFILES) | sed -e 's/ /\n/g' > $(FISH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FISH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fish-ipk: $(FISH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fish-clean:
	rm -f $(FISH_BUILD_DIR)/.built
	-$(MAKE) -C $(FISH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fish-dirclean:
	rm -rf $(BUILD_DIR)/$(FISH_DIR) $(FISH_BUILD_DIR) $(FISH_IPK_DIR) $(FISH_IPK)
#
#
# Some sanity check for the package.
#
fish-check: $(FISH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FISH_IPK)
