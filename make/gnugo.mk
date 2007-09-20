###########################################################
#
# gnugo
#
###########################################################
#
# GNUGO_VERSION, GNUGO_SITE and GNUGO_SOURCE define
# the upstream location of the source code for the package.
# GNUGO_DIR is the directory which is created when the source
# archive is unpacked.
# GNUGO_UNZIP is the command used to unzip the source.
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
GNUGO_SITE=http://ftp.gnu.org/gnu/gnugo
GNUGO_VERSION=3.6
GNUGO_SOURCE=gnugo-$(GNUGO_VERSION).tar.gz
GNUGO_DIR=gnugo-$(GNUGO_VERSION)
GNUGO_UNZIP=zcat
GNUGO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNUGO_DESCRIPTION=A free program that plays the game of Go.
GNUGO_SECTION=games
GNUGO_PRIORITY=optional
GNUGO_DEPENDS=ncurses
GNUGO_SUGGESTS=
GNUGO_CONFLICTS=

#
# GNUGO_IPK_VERSION should be incremented when the ipk changes.
#
GNUGO_IPK_VERSION=2

#
# GNUGO_CONFFILES should be a list of user-editable files
#GNUGO_CONFFILES=/opt/etc/gnugo.conf /opt/etc/init.d/SXXgnugo

#
# GNUGO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#GNUGO_PATCHES=$(GNUGO_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNUGO_CPPFLAGS=
ifeq (true,$(NO_BUILTIN_MATH))
GNUGO_CPPFLAGS+= -fno-builtin-ceil
endif
GNUGO_LDFLAGS=

#
# GNUGO_BUILD_DIR is the directory in which the build is done.
# GNUGO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNUGO_IPK_DIR is the directory in which the ipk is built.
# GNUGO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNUGO_BUILD_DIR=$(BUILD_DIR)/gnugo
GNUGO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gnugo

GNUGO_SOURCE_DIR=$(SOURCE_DIR)/gnugo
GNUGO_IPK_DIR=$(BUILD_DIR)/gnugo-$(GNUGO_VERSION)-ipk
GNUGO_IPK=$(BUILD_DIR)/gnugo_$(GNUGO_VERSION)-$(GNUGO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnugo-source gnugo-unpack gnugo gnugo-stage gnugo-ipk gnugo-clean gnugo-dirclean gnugo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNUGO_SOURCE):
	$(WGET) -P $(DL_DIR) $(GNUGO_SITE)/$(GNUGO_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GNUGO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnugo-source: $(DL_DIR)/$(GNUGO_SOURCE) $(GNUGO_PATCHES)

$(GNUGO_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GNUGO_SOURCE) make/gnugo.mk
	rm -rf $@
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(HOST_BUILD_DIR)/$(GNUGO_DIR) $(GNUGO_HOST_BUILD_DIR)
	$(GNUGO_UNZIP) $(DL_DIR)/$(GNUGO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(GNUGO_PATCHES)" ; \
		then cat $(GNUGO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNUGO_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(GNUGO_DIR)" != "$(GNUGO_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(GNUGO_DIR) $(GNUGO_HOST_BUILD_DIR) ; \
	fi
	(cd $(GNUGO_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(GNUGO_HOST_BUILD_DIR)
	touch $@

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(GNUGO_BUILD_DIR)/.configured: $(DL_DIR)/$(GNUGO_SOURCE) $(GNUGO_PATCHES) make/gnugo.mk
else
$(GNUGO_BUILD_DIR)/.configured: $(GNUGO_PATCHES) $(GNUGO_HOST_BUILD_DIR)/.built
endif
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(GNUGO_DIR) $(GNUGO_BUILD_DIR)
	$(GNUGO_UNZIP) $(DL_DIR)/$(GNUGO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNUGO_PATCHES)" ; \
		then cat $(GNUGO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNUGO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GNUGO_DIR)" != "$(GNUGO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GNUGO_DIR) $(GNUGO_BUILD_DIR) ; \
	fi
ifneq ($(HOSTCC), $(TARGET_CC))
	sed -ie 's|^	\./|	$(GNUGO_HOST_BUILD_DIR)/patterns/|' $(GNUGO_BUILD_DIR)/patterns/Makefile.in
endif
	(cd $(GNUGO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNUGO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNUGO_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(GNUGO_BUILD_DIR)/libtool
	touch $@

gnugo-unpack: $(GNUGO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNUGO_BUILD_DIR)/.built: $(GNUGO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GNUGO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gnugo: $(GNUGO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNUGO_BUILD_DIR)/.staged: $(GNUGO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(GNUGO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

gnugo-stage: $(GNUGO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnugo
#
$(GNUGO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnugo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNUGO_PRIORITY)" >>$@
	@echo "Section: $(GNUGO_SECTION)" >>$@
	@echo "Version: $(GNUGO_VERSION)-$(GNUGO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNUGO_MAINTAINER)" >>$@
	@echo "Source: $(GNUGO_SITE)/$(GNUGO_SOURCE)" >>$@
	@echo "Description: $(GNUGO_DESCRIPTION)" >>$@
	@echo "Depends: $(GNUGO_DEPENDS)" >>$@
	@echo "Suggests: $(GNUGO_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNUGO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNUGO_IPK_DIR)/opt/sbin or $(GNUGO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNUGO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNUGO_IPK_DIR)/opt/etc/gnugo/...
# Documentation files should be installed in $(GNUGO_IPK_DIR)/opt/doc/gnugo/...
# Daemon startup scripts should be installed in $(GNUGO_IPK_DIR)/opt/etc/init.d/S??gnugo
#
# You may need to patch your application to make it use these locations.
#
$(GNUGO_IPK): $(GNUGO_BUILD_DIR)/.built
	rm -rf $(GNUGO_IPK_DIR) $(BUILD_DIR)/gnugo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNUGO_BUILD_DIR) DESTDIR=$(GNUGO_IPK_DIR) install
	$(STRIP_COMMAND) $(GNUGO_IPK_DIR)/opt/bin/gnugo
	rm -f $(GNUGO_IPK_DIR)/opt/info/dir $(GNUGO_IPK_DIR)/opt/info/dir.old
#	install -d $(GNUGO_IPK_DIR)/opt/etc/
#	install -m 644 $(GNUGO_SOURCE_DIR)/gnugo.conf $(GNUGO_IPK_DIR)/opt/etc/gnugo.conf
#	install -d $(GNUGO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GNUGO_SOURCE_DIR)/rc.gnugo $(GNUGO_IPK_DIR)/opt/etc/init.d/SXXgnugo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNUGO_IPK_DIR)/opt/etc/init.d/SXXgnugo
	$(MAKE) $(GNUGO_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNUGO_SOURCE_DIR)/postinst $(GNUGO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNUGO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNUGO_SOURCE_DIR)/prerm $(GNUGO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNUGO_IPK_DIR)/CONTROL/prerm
	echo $(GNUGO_CONFFILES) | sed -e 's/ /\n/g' > $(GNUGO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNUGO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnugo-ipk: $(GNUGO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnugo-clean:
	rm -f $(GNUGO_BUILD_DIR)/.built
	-$(MAKE) -C $(GNUGO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnugo-dirclean:
	rm -rf $(BUILD_DIR)/$(GNUGO_DIR) $(GNUGO_BUILD_DIR) $(GNUGO_IPK_DIR) $(GNUGO_IPK)
#
#
# Some sanity check for the package.
#
gnugo-check: $(GNUGO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNUGO_IPK)
