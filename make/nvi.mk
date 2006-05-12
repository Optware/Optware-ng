###########################################################
#
# nvi
#
###########################################################

# You must replace "nvi" and "NVI" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NVI_VERSION, NVI_SITE and NVI_SOURCE define
# the upstream location of the source code for the package.
# NVI_DIR is the directory which is created when the source
# archive is unpacked.
# NVI_UNZIP is the command used to unzip the source.
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
NVI_SITE=ftp://ftp.sleepycat.com/pub
NVI_VERSION=1.79
NVI_SOURCE=nvi-$(NVI_VERSION).tar.gz
NVI_DIR=nvi-$(NVI_VERSION)
NVI_UNZIP=zcat
NVI_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NVI_DESCRIPTION=The original Berkeley Vi.
NVI_SECTION=editor
NVI_PRIORITY=optional
NVI_DEPENDS=
NVI_SUGGESTS=
NVI_CONFLICTS=

#
# NVI_IPK_VERSION should be incremented when the ipk changes.
#
NVI_IPK_VERSION=1

#
# NVI_CONFFILES should be a list of user-editable files
#NVI_CONFFILES=/opt/etc/nvi.conf /opt/etc/init.d/SXXnvi

#
# NVI_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NVI_PATCHES=$(NVI_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NVI_CPPFLAGS=
NVI_LDFLAGS=-lncurses

#
# NVI_BUILD_DIR is the directory in which the build is done.
# NVI_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NVI_IPK_DIR is the directory in which the ipk is built.
# NVI_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NVI_BUILD_DIR=$(BUILD_DIR)/nvi
NVI_SOURCE_DIR=$(SOURCE_DIR)/nvi
NVI_IPK_DIR=$(BUILD_DIR)/nvi-$(NVI_VERSION)-ipk
NVI_IPK=$(BUILD_DIR)/nvi_$(NVI_VERSION)-$(NVI_IPK_VERSION)_$(TARGET_ARCH).ipk

ifneq ($(HOSTCC),$(TARGET_CC))
NVI_CROSS_AC_PARAM=vi_cv_sprintf_count=yes
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NVI_SOURCE):
	$(WGET) -P $(DL_DIR) $(NVI_SITE)/$(NVI_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nvi-source: $(DL_DIR)/$(NVI_SOURCE) $(NVI_PATCHES)

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
$(NVI_BUILD_DIR)/.configured: $(DL_DIR)/$(NVI_SOURCE) $(NVI_PATCHES) # make/nvi.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NVI_DIR) $(NVI_BUILD_DIR)
	$(NVI_UNZIP) $(DL_DIR)/$(NVI_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NVI_PATCHES)" ; \
		then cat $(NVI_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NVI_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NVI_DIR)" != "$(NVI_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NVI_DIR) $(NVI_BUILD_DIR) ; \
	fi
	(cd $(NVI_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NVI_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NVI_LDFLAGS)" \
		$(NVI_CROSS_AC_PARAM) \
		./build/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	sed -i -e 's/VI.pm)$$/VI.pm/' $(NVI_BUILD_DIR)/Makefile
	sed -i -e '/vi\/perl/d' -e '/vi\/tcl/d' $(NVI_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(NVI_BUILD_DIR)/libtool
	touch $(NVI_BUILD_DIR)/.configured

nvi-unpack: $(NVI_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NVI_BUILD_DIR)/.built: $(NVI_BUILD_DIR)/.configured
	rm -f $(NVI_BUILD_DIR)/.built
	$(MAKE) -C $(NVI_BUILD_DIR)
	touch $(NVI_BUILD_DIR)/.built

#
# This is the build convenience target.
#
nvi: $(NVI_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NVI_BUILD_DIR)/.staged: $(NVI_BUILD_DIR)/.built
	rm -f $(NVI_BUILD_DIR)/.staged
	$(MAKE) -C $(NVI_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(NVI_BUILD_DIR)/.staged

nvi-stage: $(NVI_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nvi
#
$(NVI_IPK_DIR)/CONTROL/control:
	@install -d $(NVI_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: nvi" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NVI_PRIORITY)" >>$@
	@echo "Section: $(NVI_SECTION)" >>$@
	@echo "Version: $(NVI_VERSION)-$(NVI_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NVI_MAINTAINER)" >>$@
	@echo "Source: $(NVI_SITE)/$(NVI_SOURCE)" >>$@
	@echo "Description: $(NVI_DESCRIPTION)" >>$@
	@echo "Depends: $(NVI_DEPENDS)" >>$@
	@echo "Suggests: $(NVI_SUGGESTS)" >>$@
	@echo "Conflicts: $(NVI_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NVI_IPK_DIR)/opt/sbin or $(NVI_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NVI_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NVI_IPK_DIR)/opt/etc/nvi/...
# Documentation files should be installed in $(NVI_IPK_DIR)/opt/doc/nvi/...
# Daemon startup scripts should be installed in $(NVI_IPK_DIR)/opt/etc/init.d/S??nvi
#
# You may need to patch your application to make it use these locations.
#
$(NVI_IPK): $(NVI_BUILD_DIR)/.built
	rm -rf $(NVI_IPK_DIR) $(BUILD_DIR)/nvi_*_$(TARGET_ARCH).ipk
	install -d $(NVI_IPK_DIR)/opt
	$(MAKE) -C $(NVI_BUILD_DIR) prefix=$(NVI_IPK_DIR)/opt transform=s/^/n/ strip=$(TARGET_STRIP) install
	mv $(NVI_IPK_DIR)/opt/share/vi $(NVI_IPK_DIR)/opt/share/nvi
	$(MAKE) $(NVI_IPK_DIR)/CONTROL/control
	echo $(NVI_CONFFILES) | sed -e 's/ /\n/g' > $(NVI_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NVI_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nvi-ipk: $(NVI_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nvi-clean:
	rm -f $(NVI_BUILD_DIR)/.built
	-$(MAKE) -C $(NVI_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nvi-dirclean:
	rm -rf $(BUILD_DIR)/$(NVI_DIR) $(NVI_BUILD_DIR) $(NVI_IPK_DIR) $(NVI_IPK)
