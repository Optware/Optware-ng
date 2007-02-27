###########################################################
#
# nemesis
#
###########################################################
#
# NEMESIS_VERSION, NEMESIS_SITE and NEMESIS_SOURCE define
# the upstream location of the source code for the package.
# NEMESIS_DIR is the directory which is created when the source
# archive is unpacked.
# NEMESIS_UNZIP is the command used to unzip the source.
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
NEMESIS_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/nemesis
NEMESIS_VERSION=1.4
NEMESIS_SOURCE=nemesis-$(NEMESIS_VERSION).tar.gz
NEMESIS_DIR=nemesis-$(NEMESIS_VERSION)
NEMESIS_UNZIP=zcat
NEMESIS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NEMESIS_DESCRIPTION=A command-line network packet crafting and injection utility.
NEMESIS_SECTION=net
NEMESIS_PRIORITY=optional
NEMESIS_DEPENDS=
NEMESIS_SUGGESTS=
NEMESIS_CONFLICTS=

#
# NEMESIS_IPK_VERSION should be incremented when the ipk changes.
#
NEMESIS_IPK_VERSION=1

#
# NEMESIS_CONFFILES should be a list of user-editable files
#NEMESIS_CONFFILES=/opt/etc/nemesis.conf /opt/etc/init.d/SXXnemesis

#
# NEMESIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NEMESIS_PATCHES=$(NEMESIS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NEMESIS_CPPFLAGS=
NEMESIS_LDFLAGS=

#
# NEMESIS_BUILD_DIR is the directory in which the build is done.
# NEMESIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NEMESIS_IPK_DIR is the directory in which the ipk is built.
# NEMESIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NEMESIS_BUILD_DIR=$(BUILD_DIR)/nemesis
NEMESIS_SOURCE_DIR=$(SOURCE_DIR)/nemesis
NEMESIS_IPK_DIR=$(BUILD_DIR)/nemesis-$(NEMESIS_VERSION)-ipk
NEMESIS_IPK=$(BUILD_DIR)/nemesis_$(NEMESIS_VERSION)-$(NEMESIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nemesis-source nemesis-unpack nemesis nemesis-stage nemesis-ipk nemesis-clean nemesis-dirclean nemesis-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NEMESIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(NEMESIS_SITE)/$(NEMESIS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NEMESIS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nemesis-source: $(DL_DIR)/$(NEMESIS_SOURCE) $(NEMESIS_PATCHES)

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
$(NEMESIS_BUILD_DIR)/.configured: $(DL_DIR)/$(NEMESIS_SOURCE) $(NEMESIS_PATCHES) make/nemesis.mk
	$(MAKE) libnet10
	rm -rf $(BUILD_DIR)/$(NEMESIS_DIR) $(NEMESIS_BUILD_DIR)
	$(NEMESIS_UNZIP) $(DL_DIR)/$(NEMESIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NEMESIS_PATCHES)" ; \
		then cat $(NEMESIS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NEMESIS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NEMESIS_DIR)" != "$(NEMESIS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NEMESIS_DIR) $(NEMESIS_BUILD_DIR) ; \
	fi
	sed -i -e 's| -I/usr/local/include -I/sw/include||' $(NEMESIS_BUILD_DIR)/configure
	(cd $(NEMESIS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NEMESIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NEMESIS_LDFLAGS)" \
		PATH=$(LIBNET10_BUILD_DIR):$$PATH \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--with-libnet-includes=$(LIBNET10_BUILD_DIR)/include \
		--with-libnet-libraries=$(LIBNET10_BUILD_DIR)/lib \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(NEMESIS_BUILD_DIR)/libtool
	touch $@

nemesis-unpack: $(NEMESIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NEMESIS_BUILD_DIR)/.built: $(NEMESIS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NEMESIS_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
nemesis: $(NEMESIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NEMESIS_BUILD_DIR)/.staged: $(NEMESIS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NEMESIS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

nemesis-stage: $(NEMESIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nemesis
#
$(NEMESIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nemesis" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NEMESIS_PRIORITY)" >>$@
	@echo "Section: $(NEMESIS_SECTION)" >>$@
	@echo "Version: $(NEMESIS_VERSION)-$(NEMESIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NEMESIS_MAINTAINER)" >>$@
	@echo "Source: $(NEMESIS_SITE)/$(NEMESIS_SOURCE)" >>$@
	@echo "Description: $(NEMESIS_DESCRIPTION)" >>$@
	@echo "Depends: $(NEMESIS_DEPENDS)" >>$@
	@echo "Suggests: $(NEMESIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(NEMESIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NEMESIS_IPK_DIR)/opt/sbin or $(NEMESIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NEMESIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NEMESIS_IPK_DIR)/opt/etc/nemesis/...
# Documentation files should be installed in $(NEMESIS_IPK_DIR)/opt/doc/nemesis/...
# Daemon startup scripts should be installed in $(NEMESIS_IPK_DIR)/opt/etc/init.d/S??nemesis
#
# You may need to patch your application to make it use these locations.
#
$(NEMESIS_IPK): $(NEMESIS_BUILD_DIR)/.built
	rm -rf $(NEMESIS_IPK_DIR) $(BUILD_DIR)/nemesis_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NEMESIS_BUILD_DIR) DESTDIR=$(NEMESIS_IPK_DIR) install-strip
#	install -d $(NEMESIS_IPK_DIR)/opt/etc/
#	install -m 644 $(NEMESIS_SOURCE_DIR)/nemesis.conf $(NEMESIS_IPK_DIR)/opt/etc/nemesis.conf
#	install -d $(NEMESIS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NEMESIS_SOURCE_DIR)/rc.nemesis $(NEMESIS_IPK_DIR)/opt/etc/init.d/SXXnemesis
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEMESIS_IPK_DIR)/opt/etc/init.d/SXXnemesis
	$(MAKE) $(NEMESIS_IPK_DIR)/CONTROL/control
#	install -m 755 $(NEMESIS_SOURCE_DIR)/postinst $(NEMESIS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEMESIS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NEMESIS_SOURCE_DIR)/prerm $(NEMESIS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NEMESIS_IPK_DIR)/CONTROL/prerm
	echo $(NEMESIS_CONFFILES) | sed -e 's/ /\n/g' > $(NEMESIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NEMESIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nemesis-ipk: $(NEMESIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nemesis-clean:
	rm -f $(NEMESIS_BUILD_DIR)/.built
	-$(MAKE) -C $(NEMESIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nemesis-dirclean:
	rm -rf $(BUILD_DIR)/$(NEMESIS_DIR) $(NEMESIS_BUILD_DIR) $(NEMESIS_IPK_DIR) $(NEMESIS_IPK)
#
#
# Some sanity check for the package.
#
nemesis-check: $(NEMESIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NEMESIS_IPK)
