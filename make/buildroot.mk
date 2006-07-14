##########################################################
#
# buildroot
#
###########################################################
#
# BUILDROOT_VERSION, BUILDROOT_SITE and BUILDROOT_SOURCE define
# the upstream location of the source code for the package.
# BUILDROOT_DIR is the directory which is created when the source
# archive is unpacked.
# BUILDROOT_UNZIP is the command used to unzip the source.
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
BUILDROOT_GCC=3.4.6
BUILDROOT_BINUTILS=2.16.1
BUILDROOT_UCLIBC=0.9.28

BUILDROOT_VERSION=$(BUILDROOT_GCC)
BUILDROOT_SVN=svn://uclibc.org/trunk/buildroot
BUILDROOT_SVN_REV=15597
BUILDROOT_SOURCE=buildroot-svn-$(BUILDROOT_SVN_REV).tar.gz
BUILDROOT_DIR=buildroot
BUILDROOT_UNZIP=zcat
BUILDROOT_MAINTAINER=Leon Kos <oleo@email.si>
BUILDROOT_DESCRIPTION=uClibc compilation toolchain
BUILDROOT_SECTION=devel
BUILDROOT_PRIORITY=optional
BUILDROOT_DEPENDS=
BUILDROOT_SUGGESTS=
BUILDROOT_CONFLICTS=


#
# BUILDROOT_IPK_VERSION should be incremented when the ipk changes.
#
BUILDROOT_IPK_VERSION=1

#
# BUILDROOT_CONFFILES should be a list of user-editable files
# BUILDROOT_CONFFILES=/opt/etc/buildroot.conf /opt/etc/init.d/SXXbuildroot

#
# BUILDROOT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
BUILDROOT_PATCHES=$(BUILDROOT_SOURCE_DIR)/uclibc.mk.patch \
		$(BUILDROOT_SOURCE_DIR)/uClibc.config.patch \
		$(BUILDROOT_SOURCE_DIR)/gcc-uclibc-3.x.mk.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BUILDROOT_CPPFLAGS=
BUILDROOT_LDFLAGS=

#
# BUILDROOT_BUILD_DIR is the directory in which the build is done.
# BUILDROOT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BUILDROOT_IPK_DIR is the directory in which the ipk is built.
# BUILDROOT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BUILDROOT_BUILD_DIR=$(TOOL_BUILD_DIR)/buildroot
BUILDROOT_SOURCE_DIR=$(SOURCE_DIR)/buildroot
BUILDROOT_IPK_DIR=$(BUILD_DIR)/buildroot-$(BUILDROOT_VERSION)-ipk
BUILDROOT_IPK=$(BUILD_DIR)/buildroot_$(BUILDROOT_VERSION)-$(BUILDROOT_IPK_VERSION)_$(TARGET_ARCH).ipk

BUILDROOT_TOOLS_MK= $(BUILDROOT_BUILD_DIR)/toolchain/binutils/binutils.mk 

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(BUILDROOT_SOURCE):
#	$(WGET) -P $(DL_DIR) $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)

$(DL_DIR)/$(BUILDROOT_SOURCE):
	( cd $(BUILD_DIR) ; \
		rm -rf $(BUILDROOT_DIR) && \
		svn co -r $(BUILDROOT_SVN_REV) $(BUILDROOT_SVN) && \
		tar -czf $@ $(BUILDROOT_DIR) && \
		rm -rf $(BUILDROOT_DIR) \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
buildroot-source: $(DL_DIR)/$(BUILDROOT_SOURCE) $(BUILDROOT_PATCHES)

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
$(BUILDROOT_BUILD_DIR)/.configured: $(DL_DIR)/$(BUILDROOT_SOURCE) $(BUILDROOT_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR)
	$(BUILDROOT_UNZIP) $(DL_DIR)/$(BUILDROOT_SOURCE) | tar -C $(TOOL_BUILD_DIR) -xvf -
	if test -n "$(BUILDROOT_PATCHES)" ; \
		then cat $(BUILDROOT_PATCHES) | \
		patch -d $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) -p1 ; \
	fi
	if test "$(TOOL_BUILD_DIR)/$(BUILDROOT_DIR)" != "$(BUILDROOT_BUILD_DIR)" ; \
		then mv $(TOOL_BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) ; \
	fi
	cp $(BUILDROOT_SOURCE_DIR)/buildroot.config $(BUILDROOT_BUILD_DIR)/.config
	(cd $(BUILDROOT_BUILD_DIR); \
		make oldconfig \
	)
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/gcc/$(BUILDROOT_GCC)/100-uclibc-conf.patch
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/100-uclibc-conf.patch
	sed -i.orig -e '/^+/s|/lib/|/opt/lib/|g' $(BUILDROOT_BUILD_DIR)/toolchain/binutils/$(BUILDROOT_BINUTILS)/110-uclibc-libtool-conf.patch
	sed -i.orig.0 -e 's|(TARGET_DIR)/lib|(TARGET_DIR)/opt/lib|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.1 -e 's|(TARGET_DIR)/usr|(TARGET_DIR)/opt|g' $(BUILDROOT_TOOLS_MK)
	sed -i.orig.2 -e 's|=/usr|=/opt|g;s|=\\"/lib|=\\"/opt/lib|g;s|=\\"/usr|=\\"/opt|g' $(BUILDROOT_TOOLS_MK)
	touch $(BUILDROOT_BUILD_DIR)/.configured

buildroot-unpack: $(BUILDROOT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BUILDROOT_BUILD_DIR)/.built: $(BUILDROOT_BUILD_DIR)/.configured
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	GCC="ccache gcc" $(MAKE) -C $(BUILDROOT_BUILD_DIR)
	touch $(BUILDROOT_BUILD_DIR)/.built

#
# This is the build convenience target.
#
buildroot: $(BUILDROOT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(BUILDROOT_BUILD_DIR)/.staged: $(BUILDROOT_BUILD_DIR)/.built
	rm -f $(BUILDROOT_BUILD_DIR)/.staged
	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(BUILDROOT_BUILD_DIR)/.staged

buildroot-stage: $(BUILDROOT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/buildroot
#
$(BUILDROOT_IPK_DIR)/CONTROL/control:
	@install -d $(BUILDROOT_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: buildroot" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BUILDROOT_PRIORITY)" >>$@
	@echo "Section: $(BUILDROOT_SECTION)" >>$@
	@echo "Version: $(BUILDROOT_VERSION)-$(BUILDROOT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BUILDROOT_MAINTAINER)" >>$@
	@echo "Source: $(BUILDROOT_SITE)/$(BUILDROOT_SOURCE)" >>$@
	@echo "Description: $(BUILDROOT_DESCRIPTION)" >>$@
	@echo "Depends: $(BUILDROOT_DEPENDS)" >>$@
	@echo "Suggests: $(BUILDROOT_SUGGESTS)" >>$@
	@echo "Conflicts: $(BUILDROOT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BUILDROOT_IPK_DIR)/opt/sbin or $(BUILDROOT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BUILDROOT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BUILDROOT_IPK_DIR)/opt/etc/buildroot/...
# Documentation files should be installed in $(BUILDROOT_IPK_DIR)/opt/doc/buildroot/...
# Daemon startup scripts should be installed in $(BUILDROOT_IPK_DIR)/opt/etc/init.d/S??buildroot
#
# You may need to patch your application to make it use these locations.
#
$(BUILDROOT_IPK): $(BUILDROOT_BUILD_DIR)/.built
	rm -rf $(BUILDROOT_IPK_DIR) $(BUILD_DIR)/buildroot_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(BUILDROOT_BUILD_DIR) DESTDIR=$(BUILDROOT_IPK_DIR) install-strip
	install -d $(BUILDROOT_IPK_DIR)
#	install -m 644 $(BUILDROOT_SOURCE_DIR)/buildroot.conf $(BUILDROOT_IPK_DIR)/opt/etc/buildroot.conf
#	install -d $(BUILDROOT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/rc.buildroot $(BUILDROOT_IPK_DIR)/opt/etc/init.d/SXXbuildroot
	tar -xv -C $(BUILDROOT_IPK_DIR) -f $(BUILDROOT_BUILD_DIR)/rootfs.mipsel.tar ./opt
	$(MAKE) $(BUILDROOT_IPK_DIR)/CONTROL/control
	install -m 755 $(BUILDROOT_SOURCE_DIR)/postinst $(BUILDROOT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(BUILDROOT_SOURCE_DIR)/prerm $(BUILDROOT_IPK_DIR)/CONTROL/prerm
	echo $(BUILDROOT_CONFFILES) | sed -e 's/ /\n/g' > $(BUILDROOT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BUILDROOT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
buildroot-ipk: $(BUILDROOT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
buildroot-clean:
	rm -f $(BUILDROOT_BUILD_DIR)/.built
	-$(MAKE) -C $(BUILDROOT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
buildroot-dirclean:
	rm -rf $(BUILD_DIR)/$(BUILDROOT_DIR) $(BUILDROOT_BUILD_DIR) $(BUILDROOT_IPK_DIR) $(BUILDROOT_IPK)

#
# create patches
# diff -u buildroot.r15597/toolchain/uClibc/uclibc.mk buildroot/toolchain/uClibc/uclibc.mk > ../sources/buildroot/uclibc.mk.patch
#  diff -u buildroot.r15597/toolchain/gcc/gcc-uclibc-3.x.mk buildroot/toolchain/gcc/gcc-uclibc-3.x.mk > ../sources/buildroot/gcc-uclibc-3.x.mk.patch 
# rebuilding uClibc by hand:
# rm -rf rm -rf toolchain_build_mipsel/uClibc-0.*
# make uclibc-configured 
# make uclibc
# make uclibc_target
# make
# 
# Creating uClibc.config patch
# make uclibc-dirclean
# make uclibc-configured
# manually add/change missing configs from buildroot/toolchain_build_mipsel/uClibc-0.9.28/.config
# create diff to vanilla uClibc.conf 
# diff -u ../builds/buildroot-vanilla/toolchain/uClibc/uClibc.config buildroot/toolchain/uClibc/uClibc.config > ../sources/buildroot/uClibc.config.patch
# same procedure for uClibc.config-locale
#
# Reconfiguring buildroot
# cd builroodt ; make menuconfig
# cp .config ../../sources/buildroot.config
#
