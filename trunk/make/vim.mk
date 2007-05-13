###########################################################
#
# vim
#
###########################################################

# You must replace "vim" and "VIM" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# VIM_VERSION, VIM_SITE and VIM_SOURCE define
# the upstream location of the source code for the package.
# VIM_DIR is the directory which is created when the source
# archive is unpacked.
# VIM_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
VIM_SITE=http://ftp.vim.org/pub/vim/unix
VIM_VERSION_MAJOR=7
VIM_VERSION_MINOR=1
VIM_VERSION=$(VIM_VERSION_MAJOR).$(VIM_VERSION_MINOR)
VIM_SOURCE=vim-$(VIM_VERSION).tar.bz2
VIM_DIR=vim$(VIM_VERSION_MAJOR)$(VIM_VERSION_MINOR)
VIM_UNZIP=bzcat
VIM_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
VIM_DESCRIPTION=Yet another version of the vi editor.
VIM_SECTION=util
VIM_PRIORITY=optional
VIM_DEPENDS=ncurses

#
# VIM_IPK_VERSION should be incremented when the ipk changes.
#
VIM_IPK_VERSION=1

#
# VIM_CONFFILES should be a list of user-editable files
#VIM_CONFFILES=/opt/etc/vim.conf /opt/etc/init.d/SXXvim
VIM_CONFFILES=

#
# VIM_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
VIM_PATCHES=$(VIM_SOURCE_DIR)/configure.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
VIM_CPPFLAGS=
VIM_LDFLAGS=-lncurses 

#
# VIM_BUILD_DIR is the directory in which the build is done.
# VIM_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# VIM_IPK_DIR is the directory in which the ipk is built.
# VIM_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
VIM_BUILD_DIR=$(BUILD_DIR)/vim
VIM_SOURCE_DIR=$(SOURCE_DIR)/vim
VIM_IPK_DIR=$(BUILD_DIR)/vim-$(VIM_VERSION)-ipk
VIM_IPK=$(BUILD_DIR)/vim_$(VIM_VERSION)-$(VIM_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(VIM_SOURCE):
	$(WGET) -P $(DL_DIR) $(VIM_SITE)/$(VIM_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
vim-source: $(DL_DIR)/$(VIM_SOURCE) $(VIM_PATCHES)

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
$(VIM_BUILD_DIR)/.configured: $(DL_DIR)/$(VIM_SOURCE) $(VIM_PATCHES)
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(VIM_DIR) $(VIM_BUILD_DIR)
	$(VIM_UNZIP) $(DL_DIR)/$(VIM_SOURCE) | tar -C $(BUILD_DIR) -xvf -
ifneq ($(HOSTCC), $(TARGET_CC))
	cat $(VIM_PATCHES) | patch -d $(BUILD_DIR)/$(VIM_DIR) -p1
endif
	mv $(BUILD_DIR)/$(VIM_DIR) $(VIM_BUILD_DIR)
ifneq ($(HOSTCC), $(TARGET_CC))
	(cd $(VIM_BUILD_DIR); \
		autoconf src/configure.in > src/auto/configure; \
	)
endif
	(cd $(VIM_BUILD_DIR)/src; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(VIM_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(VIM_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(VIM_LDFLAGS)" \
		LIBS="$(STAGING_LDFLAGS) $(VIM_LDFLAGS)" \
		ac_cv_sizeof_int=4 \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-gui=no \
		--without-x \
		--disable-nls \
	)
	touch $(VIM_BUILD_DIR)/.configured

vim-unpack: $(VIM_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(VIM_BUILD_DIR)/.built: $(VIM_BUILD_DIR)/.configured
	rm -f $(VIM_BUILD_DIR)/.built
	$(MAKE) -C $(VIM_BUILD_DIR)
	touch $(VIM_BUILD_DIR)/.built

#
# This is the build convenience target.
#
vim: $(VIM_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(VIM_BUILD_DIR)/.staged: $(VIM_BUILD_DIR)/.built
	rm -f $(VIM_BUILD_DIR)/.staged
	$(MAKE) -C $(VIM_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(VIM_BUILD_DIR)/.staged

vim-stage: $(VIM_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/vim
#
$(VIM_IPK_DIR)/CONTROL/control:
	@install -d $(VIM_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: vim" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(VIM_PRIORITY)" >>$@
	@echo "Section: $(VIM_SECTION)" >>$@
	@echo "Version: $(VIM_VERSION)-$(VIM_IPK_VERSION)" >>$@
	@echo "Maintainer: $(VIM_MAINTAINER)" >>$@
	@echo "Source: $(VIM_SITE)/$(VIM_SOURCE)" >>$@
	@echo "Description: $(VIM_DESCRIPTION)" >>$@
	@echo "Depends: $(VIM_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(VIM_IPK_DIR)/opt/sbin or $(VIM_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(VIM_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(VIM_IPK_DIR)/opt/etc/vim/...
# Documentation files should be installed in $(VIM_IPK_DIR)/opt/doc/vim/...
# Daemon startup scripts should be installed in $(VIM_IPK_DIR)/opt/etc/init.d/S??vim
#
# You may need to patch your application to make it use these locations.
#
$(VIM_IPK): $(VIM_BUILD_DIR)/.built
	rm -rf $(VIM_IPK_DIR) $(BUILD_DIR)/vim_*_$(TARGET_ARCH).ipk
	cd $(VIM_BUILD_DIR)/src
	$(MAKE) -C $(VIM_BUILD_DIR) DESTDIR=$(VIM_IPK_DIR) install
#	Fix the $VIM directory
	mv $(VIM_IPK_DIR)/opt/share/vim $(VIM_IPK_DIR)/opt/share/vim-temp
	mv $(VIM_IPK_DIR)/opt/share/vim-temp/vim* $(VIM_IPK_DIR)/opt/share/vim
	rm -rf $(VIM_IPK_DIR)/opt/share/vim-temp
	$(MAKE) $(VIM_IPK_DIR)/CONTROL/control
#	install -m 644 $(VIM_SOURCE_DIR)/prerm $(VIM_IPK_DIR)/CONTROL/prerm
#	install -m 644 $(VIM_SOURCE_DIR)/postinst $(VIM_IPK_DIR)/CONTROL/postinst
	echo $(VIM_CONFFILES) | sed -e 's/ /\n/g' > $(VIM_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(VIM_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
vim-ipk: $(VIM_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
vim-clean:
	-$(MAKE) -C $(VIM_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
vim-dirclean:
	rm -rf $(BUILD_DIR)/$(VIM_DIR) $(VIM_BUILD_DIR) $(VIM_IPK_DIR) $(VIM_IPK)

#
# Some sanity check for the package.
#
vim-check: $(VIM_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(VIM_IPK)
