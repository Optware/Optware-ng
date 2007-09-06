###########################################################
#
# weechat
#
###########################################################
#
# WEECHAT_VERSION, WEECHAT_SITE and WEECHAT_SOURCE define
# the upstream location of the source code for the package.
# WEECHAT_DIR is the directory which is created when the source
# archive is unpacked.
# WEECHAT_UNZIP is the command used to unzip the source.
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
WEECHAT_SITE=http://weechat.flashtux.org/download
WEECHAT_VERSION=0.2.6
WEECHAT_SOURCE=weechat-$(WEECHAT_VERSION).tar.bz2
WEECHAT_DIR=weechat-$(WEECHAT_VERSION)
WEECHAT_UNZIP=bzcat
WEECHAT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
WEECHAT_DESCRIPTION=(Wee Enhanced Environment for Chat) is a fast and light IRC client.
WEECHAT_SECTION=irc
WEECHAT_PRIORITY=optional
WEECHAT_DEPENDS=gnutls, $(NCURSES_FOR_OPTWARE_TARGET)
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
WEECHAT_DEPENDS+=, libiconv
endif
WEECHAT_SUGGESTS=
WEECHAT_CONFLICTS=

#
# WEECHAT_IPK_VERSION should be incremented when the ipk changes.
#
WEECHAT_IPK_VERSION=1

#
# WEECHAT_CONFFILES should be a list of user-editable files
#WEECHAT_CONFFILES=/opt/etc/weechat.conf /opt/etc/init.d/SXXweechat

#
# WEECHAT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifneq ($(HOSTCC), $(TARGET_CC))
WEECHAT_PATCHES=$(WEECHAT_SOURCE_DIR)/configure.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WEECHAT_CPPFLAGS=
WEECHAT_LDFLAGS=

#
# WEECHAT_BUILD_DIR is the directory in which the build is done.
# WEECHAT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WEECHAT_IPK_DIR is the directory in which the ipk is built.
# WEECHAT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WEECHAT_BUILD_DIR=$(BUILD_DIR)/weechat
WEECHAT_SOURCE_DIR=$(SOURCE_DIR)/weechat
WEECHAT_IPK_DIR=$(BUILD_DIR)/weechat-$(WEECHAT_VERSION)-ipk
WEECHAT_IPK=$(BUILD_DIR)/weechat_$(WEECHAT_VERSION)-$(WEECHAT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: weechat-source weechat-unpack weechat weechat-stage weechat-ipk weechat-clean weechat-dirclean weechat-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WEECHAT_SOURCE):
	$(WGET) -P $(DL_DIR) $(WEECHAT_SITE)/$(WEECHAT_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(WEECHAT_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
weechat-source: $(DL_DIR)/$(WEECHAT_SOURCE) $(WEECHAT_PATCHES)

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
$(WEECHAT_BUILD_DIR)/.configured: $(DL_DIR)/$(WEECHAT_SOURCE) $(WEECHAT_PATCHES) make/weechat.mk
	$(MAKE) gnutls-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(WEECHAT_DIR) $(WEECHAT_BUILD_DIR)
	$(WEECHAT_UNZIP) $(DL_DIR)/$(WEECHAT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WEECHAT_PATCHES)" ; \
		then cat $(WEECHAT_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(WEECHAT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(WEECHAT_DIR)" != "$(WEECHAT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(WEECHAT_DIR) $(WEECHAT_BUILD_DIR) ; \
	fi
	(cd $(WEECHAT_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WEECHAT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WEECHAT_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-gtk \
		--disable-qt \
		--disable-wxwidgets \
		--disable-aspell \
		--enable-gnutls \
		--disable-lua \
		--disable-perl \
		--disable-python \
		--disable-ruby \
		--with-libgnutls-prefix=$(STAGING_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(WEECHAT_BUILD_DIR)/libtool
	touch $@

weechat-unpack: $(WEECHAT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WEECHAT_BUILD_DIR)/.built: $(WEECHAT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(WEECHAT_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
weechat: $(WEECHAT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WEECHAT_BUILD_DIR)/.staged: $(WEECHAT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(WEECHAT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

weechat-stage: $(WEECHAT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/weechat
#
$(WEECHAT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: weechat" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WEECHAT_PRIORITY)" >>$@
	@echo "Section: $(WEECHAT_SECTION)" >>$@
	@echo "Version: $(WEECHAT_VERSION)-$(WEECHAT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WEECHAT_MAINTAINER)" >>$@
	@echo "Source: $(WEECHAT_SITE)/$(WEECHAT_SOURCE)" >>$@
	@echo "Description: $(WEECHAT_DESCRIPTION)" >>$@
	@echo "Depends: $(WEECHAT_DEPENDS)" >>$@
	@echo "Suggests: $(WEECHAT_SUGGESTS)" >>$@
	@echo "Conflicts: $(WEECHAT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WEECHAT_IPK_DIR)/opt/sbin or $(WEECHAT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WEECHAT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WEECHAT_IPK_DIR)/opt/etc/weechat/...
# Documentation files should be installed in $(WEECHAT_IPK_DIR)/opt/doc/weechat/...
# Daemon startup scripts should be installed in $(WEECHAT_IPK_DIR)/opt/etc/init.d/S??weechat
#
# You may need to patch your application to make it use these locations.
#
$(WEECHAT_IPK): $(WEECHAT_BUILD_DIR)/.built
	rm -rf $(WEECHAT_IPK_DIR) $(BUILD_DIR)/weechat_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(WEECHAT_BUILD_DIR) DESTDIR=$(WEECHAT_IPK_DIR) install-strip
#	install -d $(WEECHAT_IPK_DIR)/opt/etc/
#	install -m 644 $(WEECHAT_SOURCE_DIR)/weechat.conf $(WEECHAT_IPK_DIR)/opt/etc/weechat.conf
#	install -d $(WEECHAT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(WEECHAT_SOURCE_DIR)/rc.weechat $(WEECHAT_IPK_DIR)/opt/etc/init.d/SXXweechat
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WEECHAT_IPK_DIR)/opt/etc/init.d/SXXweechat
	$(MAKE) $(WEECHAT_IPK_DIR)/CONTROL/control
#	install -m 755 $(WEECHAT_SOURCE_DIR)/postinst $(WEECHAT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WEECHAT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(WEECHAT_SOURCE_DIR)/prerm $(WEECHAT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(WEECHAT_IPK_DIR)/CONTROL/prerm
	echo $(WEECHAT_CONFFILES) | sed -e 's/ /\n/g' > $(WEECHAT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WEECHAT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
weechat-ipk: $(WEECHAT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
weechat-clean:
	rm -f $(WEECHAT_BUILD_DIR)/.built
	-$(MAKE) -C $(WEECHAT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
weechat-dirclean:
	rm -rf $(BUILD_DIR)/$(WEECHAT_DIR) $(WEECHAT_BUILD_DIR) $(WEECHAT_IPK_DIR) $(WEECHAT_IPK)
#
#
# Some sanity check for the package.
#
weechat-check: $(WEECHAT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WEECHAT_IPK)
