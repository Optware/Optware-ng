###########################################################
#
# tvision
#
###########################################################
#
# RHTVISION_VERSION, RHTVISION_SITE and RHTVISION_SOURCE define
# the upstream location of the source code for the package.
# RHTVISION_DIR is the directory which is created when the source
# archive is unpacked.
# RHTVISION_UNZIP is the command used to unzip the source.
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
RHTVISION_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tvision
RHTVISION_VERSION=2.0.3
RHTVISION_SOURCE=rhtvision-$(RHTVISION_VERSION).src.tar.gz
RHTVISION_DIR=tvision
RHTVISION_UNZIP=zcat
RHTVISION_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RHTVISION_DESCRIPTION=Turbo Vision (TVision for short) is a TUI (Text User Interface) that implements the well known CUA widgets. \
TVision was originally developed by Borland. This port is a port of the C++ version for the DOS, FreeBSD, Linux, QNX, Solaris and Win32 platforms.
RHTVISION_SECTION=lib
RHTVISION_PRIORITY=optional
RHTVISION_DEPENDS=ncurses
RHTVISION_SUGGESTS=
RHTVISION_CONFLICTS=

#
# RHTVISION_IPK_VERSION should be incremented when the ipk changes.
#
RHTVISION_IPK_VERSION=1

#
# RHTVISION_CONFFILES should be a list of user-editable files
#RHTVISION_CONFFILES=/opt/etc/rhtvision.conf /opt/etc/init.d/SXXrhtvision

#
# RHTVISION_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
RHTVISION_PATCHES=\
$(RHTVISION_SOURCE_DIR)/conflib.pl-cross.patch \
$(RHTVISION_SOURCE_DIR)/config.pl-cross.patch \
$(RHTVISION_SOURCE_DIR)/gcc4.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RHTVISION_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
RHTVISION_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
RHTVISION_LDFLAGS+=-lintl
endif

#
# RHTVISION_BUILD_DIR is the directory in which the build is done.
# RHTVISION_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RHTVISION_IPK_DIR is the directory in which the ipk is built.
# RHTVISION_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RHTVISION_BUILD_DIR=$(BUILD_DIR)/rhtvision
RHTVISION_SOURCE_DIR=$(SOURCE_DIR)/rhtvision
RHTVISION_IPK_DIR=$(BUILD_DIR)/rhtvision-$(RHTVISION_VERSION)-ipk
RHTVISION_IPK=$(BUILD_DIR)/rhtvision_$(RHTVISION_VERSION)-$(RHTVISION_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rhtvision-source rhtvision-unpack rhtvision rhtvision-stage rhtvision-ipk rhtvision-clean rhtvision-dirclean rhtvision-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RHTVISION_SOURCE):
	$(WGET) -P $(DL_DIR) $(RHTVISION_SITE)/$(RHTVISION_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(RHTVISION_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rhtvision-source: $(DL_DIR)/$(RHTVISION_SOURCE) $(RHTVISION_PATCHES)

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
$(RHTVISION_BUILD_DIR)/.configured: $(DL_DIR)/$(RHTVISION_SOURCE) $(RHTVISION_PATCHES) # make/rhtvision.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(RHTVISION_DIR) $(RHTVISION_BUILD_DIR)
	$(RHTVISION_UNZIP) $(DL_DIR)/$(RHTVISION_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RHTVISION_PATCHES)" ; \
		then cat $(RHTVISION_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(RHTVISION_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RHTVISION_DIR)" != "$(RHTVISION_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(RHTVISION_DIR) $(RHTVISION_BUILD_DIR) ; \
	fi
	(cd $(RHTVISION_BUILD_DIR); \
		if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
		then export TV_BIG_ENDIAN=yes; \
		else export TV_BIG_ENDIAN=no; \
		fi; \
		$(TARGET_CONFIGURE_OPTS) \
		GXX=$(TARGET_CXX) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RHTVISION_CPPFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(RHTVISION_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RHTVISION_LDFLAGS)" \
		TARGET_ARCH=$(TARGET_ARCH) \
		LDExtraDirs=$(STAGING_LIB_DIR) \
		./configure \
		--prefix=/opt \
		--with-debug \
	)
#		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
		--disable-static \
		;
#	$(PATCH_LIBTOOL) $(RHTVISION_BUILD_DIR)/libtool
	touch $@

rhtvision-unpack: $(RHTVISION_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RHTVISION_BUILD_DIR)/.built: $(RHTVISION_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(RHTVISION_BUILD_DIR) all examples \
		LDFLAGS="$(STAGING_LDFLAGS) $(RHTVISION_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
rhtvision: $(RHTVISION_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RHTVISION_BUILD_DIR)/.staged: $(RHTVISION_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(RHTVISION_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

rhtvision-stage: $(RHTVISION_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rhtvision
#
$(RHTVISION_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rhtvision" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RHTVISION_PRIORITY)" >>$@
	@echo "Section: $(RHTVISION_SECTION)" >>$@
	@echo "Version: $(RHTVISION_VERSION)-$(RHTVISION_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RHTVISION_MAINTAINER)" >>$@
	@echo "Source: $(RHTVISION_SITE)/$(RHTVISION_SOURCE)" >>$@
	@echo "Description: $(RHTVISION_DESCRIPTION)" >>$@
	@echo "Depends: $(RHTVISION_DEPENDS)" >>$@
	@echo "Suggests: $(RHTVISION_SUGGESTS)" >>$@
	@echo "Conflicts: $(RHTVISION_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RHTVISION_IPK_DIR)/opt/sbin or $(RHTVISION_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RHTVISION_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RHTVISION_IPK_DIR)/opt/etc/rhtvision/...
# Documentation files should be installed in $(RHTVISION_IPK_DIR)/opt/doc/rhtvision/...
# Daemon startup scripts should be installed in $(RHTVISION_IPK_DIR)/opt/etc/init.d/S??rhtvision
#
# You may need to patch your application to make it use these locations.
#
$(RHTVISION_IPK): $(RHTVISION_BUILD_DIR)/.built
	rm -rf $(RHTVISION_IPK_DIR) $(BUILD_DIR)/rhtvision_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RHTVISION_BUILD_DIR) install \
		prefix=$(RHTVISION_IPK_DIR)/opt
	rm -f $(RHTVISION_IPK_DIR)/opt/lib/librhtv.a
	install $(RHTVISION_BUILD_DIR)/examples/demo/demo.exe $(RHTVISION_IPK_DIR)/opt/bin/rhtv-demo
	$(STRIP_COMMAND) \
		$(RHTVISION_IPK_DIR)/opt/bin/rhtv-config \
		$(RHTVISION_IPK_DIR)/opt/bin/rhtv-demo \
		$(RHTVISION_IPK_DIR)/opt/lib/librhtv.so.[0-9]*.[0-9]*.[0-9]*
#	install -d $(RHTVISION_IPK_DIR)/opt/etc/
#	install -m 644 $(RHTVISION_SOURCE_DIR)/rhtvision.conf $(RHTVISION_IPK_DIR)/opt/etc/rhtvision.conf
#	install -d $(RHTVISION_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RHTVISION_SOURCE_DIR)/rc.rhtvision $(RHTVISION_IPK_DIR)/opt/etc/init.d/SXXrhtvision
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RHTVISION_IPK_DIR)/opt/etc/init.d/SXXrhtvision
	$(MAKE) $(RHTVISION_IPK_DIR)/CONTROL/control
#	install -m 755 $(RHTVISION_SOURCE_DIR)/postinst $(RHTVISION_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RHTVISION_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RHTVISION_SOURCE_DIR)/prerm $(RHTVISION_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RHTVISION_IPK_DIR)/CONTROL/prerm
	echo $(RHTVISION_CONFFILES) | sed -e 's/ /\n/g' > $(RHTVISION_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RHTVISION_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rhtvision-ipk: $(RHTVISION_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rhtvision-clean:
	rm -f $(RHTVISION_BUILD_DIR)/.built
	-$(MAKE) -C $(RHTVISION_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rhtvision-dirclean:
	rm -rf $(BUILD_DIR)/$(RHTVISION_DIR) $(RHTVISION_BUILD_DIR) $(RHTVISION_IPK_DIR) $(RHTVISION_IPK)
#
#
# Some sanity check for the package.
#
rhtvision-check: $(RHTVISION_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RHTVISION_IPK)
