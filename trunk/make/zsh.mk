###########################################################
#
# zsh
#
###########################################################
#
# ZSH_VERSION, ZSH_SITE and ZSH_SOURCE define
# the upstream location of the source code for the package.
# ZSH_DIR is the directory which is created when the source
# archive is unpacked.
# ZSH_UNZIP is the command used to unzip the source.
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
ZSH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/zsh
ZSH_VERSION=4.3.2
ZSH_SOURCE=zsh-$(ZSH_VERSION).tar.gz
ZSH_DIR=zsh-$(ZSH_VERSION)
ZSH_UNZIP=zcat
ZSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ZSH_DESCRIPTION=Zsh is a shell designed for interactive use.
ZSH_SECTION=shell
ZSH_PRIORITY=optional
ZSH_DEPENDS=ncurses, termcap
ZSH_SUGGESTS=
ZSH_CONFLICTS=

#
# ZSH_IPK_VERSION should be incremented when the ipk changes.
#
ZSH_IPK_VERSION=1

#
# ZSH_CONFFILES should be a list of user-editable files
#ZSH_CONFFILES=/opt/etc/zsh.conf /opt/etc/init.d/SXXzsh

#
# ZSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ZSH_PATCHES=$(ZSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ZSH_CPPFLAGS=
ZSH_LDFLAGS=

#
# ZSH_BUILD_DIR is the directory in which the build is done.
# ZSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ZSH_IPK_DIR is the directory in which the ipk is built.
# ZSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ZSH_BUILD_DIR=$(BUILD_DIR)/zsh
ZSH_SOURCE_DIR=$(SOURCE_DIR)/zsh
ZSH_IPK_DIR=$(BUILD_DIR)/zsh-$(ZSH_VERSION)-ipk
ZSH_IPK=$(BUILD_DIR)/zsh_$(ZSH_VERSION)-$(ZSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: zsh-source zsh-unpack zsh zsh-stage zsh-ipk zsh-clean zsh-dirclean zsh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ZSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(ZSH_SITE)/$(ZSH_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
zsh-source: $(DL_DIR)/$(ZSH_SOURCE) $(ZSH_PATCHES)

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
$(ZSH_BUILD_DIR)/.configured: $(DL_DIR)/$(ZSH_SOURCE) $(ZSH_PATCHES) # make/zsh.mk
	$(MAKE) ncurses-stage
	$(MAKE) termcap-stage
	rm -rf $(BUILD_DIR)/$(ZSH_DIR) $(ZSH_BUILD_DIR)
	$(ZSH_UNZIP) $(DL_DIR)/$(ZSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ZSH_PATCHES)" ; \
		then cat $(ZSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ZSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ZSH_DIR)" != "$(ZSH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ZSH_DIR) $(ZSH_BUILD_DIR) ; \
	fi
	(cd $(ZSH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(ZSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ZSH_LDFLAGS)" \
		zsh_cv_sys_nis=no \
		zsh_cv_sys_nis_plus=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)

ifneq ($(HOSTCC), $(TARGET_CC))
	cp $(ZSH_SOURCE_DIR)/native-config.h $(ZSH_BUILD_DIR)
endif
#	$(PATCH_LIBTOOL) $(ZSH_BUILD_DIR)/libtool
	touch $(ZSH_BUILD_DIR)/.configured

zsh-unpack: $(ZSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ZSH_BUILD_DIR)/.built: $(ZSH_BUILD_DIR)/.configured
	rm -f $(ZSH_BUILD_DIR)/.built
	$(MAKE) -C $(ZSH_BUILD_DIR)
	touch $(ZSH_BUILD_DIR)/.built

#
# This is the build convenience target.
#
zsh: $(ZSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ZSH_BUILD_DIR)/.staged: $(ZSH_BUILD_DIR)/.built
	rm -f $(ZSH_BUILD_DIR)/.staged
	$(MAKE) -C $(ZSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(ZSH_BUILD_DIR)/.staged

zsh-stage: $(ZSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/zsh
#
$(ZSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: zsh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ZSH_PRIORITY)" >>$@
	@echo "Section: $(ZSH_SECTION)" >>$@
	@echo "Version: $(ZSH_VERSION)-$(ZSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ZSH_MAINTAINER)" >>$@
	@echo "Source: $(ZSH_SITE)/$(ZSH_SOURCE)" >>$@
	@echo "Description: $(ZSH_DESCRIPTION)" >>$@
	@echo "Depends: $(ZSH_DEPENDS)" >>$@
	@echo "Suggests: $(ZSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(ZSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ZSH_IPK_DIR)/opt/sbin or $(ZSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ZSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ZSH_IPK_DIR)/opt/etc/zsh/...
# Documentation files should be installed in $(ZSH_IPK_DIR)/opt/doc/zsh/...
# Daemon startup scripts should be installed in $(ZSH_IPK_DIR)/opt/etc/init.d/S??zsh
#
# You may need to patch your application to make it use these locations.
#
$(ZSH_IPK): $(ZSH_BUILD_DIR)/.built
	rm -rf $(ZSH_IPK_DIR) $(BUILD_DIR)/zsh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ZSH_BUILD_DIR) DESTDIR=$(ZSH_IPK_DIR) install
	rm -f $(ZSH_IPK_DIR)/opt/bin/zsh-[0-9]*
	$(STRIP_COMMAND) $(ZSH_IPK_DIR)/opt/bin/zsh
	install -d $(ZSH_IPK_DIR)/opt/etc/
#	install -m 644 $(ZSH_SOURCE_DIR)/zsh.conf $(ZSH_IPK_DIR)/opt/etc/zsh.conf
#	install -d $(ZSH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ZSH_SOURCE_DIR)/rc.zsh $(ZSH_IPK_DIR)/opt/etc/init.d/SXXzsh
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXzsh
	$(MAKE) $(ZSH_IPK_DIR)/CONTROL/control
#	install -m 755 $(ZSH_SOURCE_DIR)/postinst $(ZSH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ZSH_SOURCE_DIR)/prerm $(ZSH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(ZSH_CONFFILES) | sed -e 's/ /\n/g' > $(ZSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ZSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
zsh-ipk: $(ZSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
zsh-clean:
	rm -f $(ZSH_BUILD_DIR)/.built
	-$(MAKE) -C $(ZSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
zsh-dirclean:
	rm -rf $(BUILD_DIR)/$(ZSH_DIR) $(ZSH_BUILD_DIR) $(ZSH_IPK_DIR) $(ZSH_IPK)
#
#
# Some sanity check for the package.
#
zsh-check: $(ZSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ZSH_IPK)
