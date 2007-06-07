###########################################################
#
# util-linux
#
###########################################################
#
# UTIL_LINUX_VERSION, UTIL_LINUX_SITE and UTIL_LINUX_SOURCE define
# the upstream location of the source code for the package.
# UTIL_LINUX_DIR is the directory which is created when the source
# archive is unpacked.
# UTIL_LINUX_UNZIP is the command used to unzip the source.
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
UTIL_LINUX_SITE=ftp://ftp.kernel.org/pub/linux/utils/util-linux
UTIL_LINUX_VERSION=2.12r
UTIL_LINUX_SOURCE=util-linux-$(UTIL_LINUX_VERSION).tar.gz
UTIL_LINUX_DIR=util-linux-$(UTIL_LINUX_VERSION)
UTIL_LINUX_UNZIP=zcat
UTIL_LINUX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UTIL_LINUX_DESCRIPTION=A suite of essential utilities for any Linux system.
UTIL_LINUX_SECTION=misc
UTIL_LINUX_PRIORITY=optional
UTIL_LINUX_DEPENDS=
UTIL_LINUX_SUGGESTS=ncurses, zlib
UTIL_LINUX_CONFLICTS=

#
# UTIL_LINUX_IPK_VERSION should be incremented when the ipk changes.
#
UTIL_LINUX_IPK_VERSION=2

#
# UTIL_LINUX_CONFFILES should be a list of user-editable files
#UTIL_LINUX_CONFFILES=/opt/etc/util-linux.conf /opt/etc/init.d/SXXutil-linux

#
# UTIL_LINUX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UTIL_LINUX_PATCHES=$(UTIL_LINUX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UTIL_LINUX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
UTIL_LINUX_LDFLAGS=

#
# UTIL_LINUX_BUILD_DIR is the directory in which the build is done.
# UTIL_LINUX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UTIL_LINUX_IPK_DIR is the directory in which the ipk is built.
# UTIL_LINUX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UTIL_LINUX_BUILD_DIR=$(BUILD_DIR)/util-linux
UTIL_LINUX_SOURCE_DIR=$(SOURCE_DIR)/util-linux
UTIL_LINUX_IPK_DIR=$(BUILD_DIR)/util-linux-$(UTIL_LINUX_VERSION)-ipk
UTIL_LINUX_IPK=$(BUILD_DIR)/util-linux_$(UTIL_LINUX_VERSION)-$(UTIL_LINUX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: util-linux-source util-linux-unpack util-linux util-linux-stage util-linux-ipk util-linux-clean util-linux-dirclean util-linux-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UTIL_LINUX_SOURCE):
	$(WGET) -P $(DL_DIR) $(UTIL_LINUX_SITE)/$(UTIL_LINUX_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UTIL_LINUX_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
util-linux-source: $(DL_DIR)/$(UTIL_LINUX_SOURCE) $(UTIL_LINUX_PATCHES)

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
$(UTIL_LINUX_BUILD_DIR)/.configured: $(DL_DIR)/$(UTIL_LINUX_SOURCE) $(UTIL_LINUX_PATCHES) make/util-linux.mk
	$(MAKE) ncurses-stage zlib-stage
	rm -rf $(BUILD_DIR)/$(UTIL_LINUX_DIR) $(UTIL_LINUX_BUILD_DIR)
	$(UTIL_LINUX_UNZIP) $(DL_DIR)/$(UTIL_LINUX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UTIL_LINUX_PATCHES)" ; \
		then cat $(UTIL_LINUX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UTIL_LINUX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UTIL_LINUX_DIR)" != "$(UTIL_LINUX_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UTIL_LINUX_DIR) $(UTIL_LINUX_BUILD_DIR) ; \
	fi
ifeq ($(OPTWARE_TARGET), slugosbe)
	sed -i -e 's/^static int umount2/int umount2/' $(UTIL_LINUX_BUILD_DIR)/mount/umount.c
endif
	(cd $(UTIL_LINUX_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UTIL_LINUX_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(UTIL_LINUX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UTIL_LINUX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i -e 's|-I/usr/include/ncurses ||g' \
	       -e 's|HAVE_ZLIB=no|HAVE_ZLIB=yes|g' \
		$(UTIL_LINUX_BUILD_DIR)/make_include
#	$(PATCH_LIBTOOL) $(UTIL_LINUX_BUILD_DIR)/libtool
	touch $@

util-linux-unpack: $(UTIL_LINUX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UTIL_LINUX_BUILD_DIR)/.built: $(UTIL_LINUX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UTIL_LINUX_BUILD_DIR) \
		DISABLE_NLS=yes \
		HAVE_SYSVINIT_UTILS=no \
		USE_TTY_GROUP=no \
		ARCH=$(TARGET_ARCH) \
		SBIN_DIR=/opt/sbin \
		BIN_DIR=/opt/bin \
		ETC_DIR=/opt/etc \
		USRSBIN_DIR=/opt/sbin \
		USRBIN_DIR=/opt/bin \
		USRLIB_DIR=/opt/lib \
		MAN_DIR=/opt/share/man \
		INFO_DIR=/opt/share/info \
		USRSHAREMISC_DIR=/opt/share/misc \
		LOCALEDIR=/opt/share/locale \
		;
	touch $@

#
# This is the build convenience target.
#
util-linux: $(UTIL_LINUX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UTIL_LINUX_BUILD_DIR)/.staged: $(UTIL_LINUX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(UTIL_LINUX_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

util-linux-stage: $(UTIL_LINUX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/util-linux
#
$(UTIL_LINUX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: util-linux" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UTIL_LINUX_PRIORITY)" >>$@
	@echo "Section: $(UTIL_LINUX_SECTION)" >>$@
	@echo "Version: $(UTIL_LINUX_VERSION)-$(UTIL_LINUX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UTIL_LINUX_MAINTAINER)" >>$@
	@echo "Source: $(UTIL_LINUX_SITE)/$(UTIL_LINUX_SOURCE)" >>$@
	@echo "Description: $(UTIL_LINUX_DESCRIPTION)" >>$@
	@echo "Depends: $(UTIL_LINUX_DEPENDS)" >>$@
	@echo "Suggests: $(UTIL_LINUX_SUGGESTS)" >>$@
	@echo "Conflicts: $(UTIL_LINUX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UTIL_LINUX_IPK_DIR)/opt/sbin or $(UTIL_LINUX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UTIL_LINUX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UTIL_LINUX_IPK_DIR)/opt/etc/util-linux/...
# Documentation files should be installed in $(UTIL_LINUX_IPK_DIR)/opt/doc/util-linux/...
# Daemon startup scripts should be installed in $(UTIL_LINUX_IPK_DIR)/opt/etc/init.d/S??util-linux
#
# You may need to patch your application to make it use these locations.
#
$(UTIL_LINUX_IPK): $(UTIL_LINUX_BUILD_DIR)/.built
	rm -rf $(UTIL_LINUX_IPK_DIR) $(BUILD_DIR)/util-linux_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UTIL_LINUX_BUILD_DIR) install \
		DESTDIR=$(UTIL_LINUX_IPK_DIR) \
		INSTALLSUID="$$(INSTALL) -m $$(SUIDMODE)" \
		\
		ARCH=$(TARGET_ARCH) \
		DISABLE_NLS=yes \
		HAVE_SYSVINIT_UTILS=no \
		USE_TTY_GROUP=no \
		SBIN_DIR=/opt/sbin \
		BIN_DIR=/opt/bin \
		ETC_DIR=/opt/etc \
		USRSBIN_DIR=/opt/sbin \
		USRBIN_DIR=/opt/bin \
		USRLIB_DIR=/opt/lib \
		MAN_DIR=/opt/share/man \
		INFO_DIR=/opt/share/info \
		USRSHAREMISC_DIR=/opt/share/misc \
		LOCALEDIR=/opt/share/locale \
		;
	$(STRIP_COMMAND) `ls $(UTIL_LINUX_IPK_DIR)/opt/bin/* | grep -v chkdupexe`
	rm -f $(UTIL_LINUX_IPK_DIR)/opt/sbin/swapoff
	$(STRIP_COMMAND) $(UTIL_LINUX_IPK_DIR)/opt/sbin/*
	for d in /opt/sbin /opt/bin /opt/share/man; do \
	    for f in `find $(UTIL_LINUX_IPK_DIR)/$$d -type f`; do \
		mv `dirname $$f`/`basename $$f` `dirname $$f`/util-linux-`basename $$f`; \
	    done; \
	done
	cd $(UTIL_LINUX_IPK_DIR)/opt/sbin; ln -sf util-linux-swapon util-linux-swapoff
#	install -d $(UTIL_LINUX_IPK_DIR)/opt/etc/
#	install -m 644 $(UTIL_LINUX_SOURCE_DIR)/util-linux.conf $(UTIL_LINUX_IPK_DIR)/opt/etc/util-linux.conf
#	install -d $(UTIL_LINUX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UTIL_LINUX_SOURCE_DIR)/rc.util-linux $(UTIL_LINUX_IPK_DIR)/opt/etc/init.d/SXXutil-linux
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UTIL_LINUX_IPK_DIR)/opt/etc/init.d/SXXutil-linux
	$(MAKE) $(UTIL_LINUX_IPK_DIR)/CONTROL/control
#	install -m 755 $(UTIL_LINUX_SOURCE_DIR)/postinst $(UTIL_LINUX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UTIL_LINUX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UTIL_LINUX_SOURCE_DIR)/prerm $(UTIL_LINUX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UTIL_LINUX_IPK_DIR)/CONTROL/prerm
	echo $(UTIL_LINUX_CONFFILES) | sed -e 's/ /\n/g' > $(UTIL_LINUX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UTIL_LINUX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
util-linux-ipk: $(UTIL_LINUX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
util-linux-clean:
	rm -f $(UTIL_LINUX_BUILD_DIR)/.built
	-$(MAKE) -C $(UTIL_LINUX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
util-linux-dirclean:
	rm -rf $(BUILD_DIR)/$(UTIL_LINUX_DIR) $(UTIL_LINUX_BUILD_DIR) $(UTIL_LINUX_IPK_DIR) $(UTIL_LINUX_IPK)
#
#
# Some sanity check for the package.
#
util-linux-check: $(UTIL_LINUX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UTIL_LINUX_IPK)
