###########################################################
#
# iftop
#
###########################################################
#
# IFTOP_VERSION, IFTOP_SITE and IFTOP_SOURCE define
# the upstream location of the source code for the package.
# IFTOP_DIR is the directory which is created when the source
# archive is unpacked.
# IFTOP_UNZIP is the command used to unzip the source.
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
IFTOP_SITE=http://www.ex-parrot.com/~pdw/iftop/download
IFTOP_VERSION=0.17
IFTOP_SOURCE=iftop-$(IFTOP_VERSION).tar.gz
IFTOP_DIR=iftop-$(IFTOP_VERSION)
IFTOP_UNZIP=zcat
IFTOP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IFTOP_DESCRIPTION=Display bandwidth usage on an interface by host
IFTOP_SECTION=net
IFTOP_PRIORITY=optional
IFTOP_DEPENDS=libpcap
IFTOP_SUGGESTS=
IFTOP_CONFLICTS=

#
# IFTOP_IPK_VERSION should be incremented when the ipk changes.
#
IFTOP_IPK_VERSION=1

#
# IFTOP_CONFFILES should be a list of user-editable files
IFTOP_CONFFILES=/opt/etc/iftop.conf /opt/etc/init.d/SXXiftop

#
# IFTOP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IFTOP_PATCHES=$(IFTOP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IFTOP_CPPFLAGS=
IFTOP_LDFLAGS=

#
# IFTOP_BUILD_DIR is the directory in which the build is done.
# IFTOP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IFTOP_IPK_DIR is the directory in which the ipk is built.
# IFTOP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IFTOP_BUILD_DIR=$(BUILD_DIR)/iftop
IFTOP_SOURCE_DIR=$(SOURCE_DIR)/iftop
IFTOP_IPK_DIR=$(BUILD_DIR)/iftop-$(IFTOP_VERSION)-ipk
IFTOP_IPK=$(BUILD_DIR)/iftop_$(IFTOP_VERSION)-$(IFTOP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iftop-source iftop-unpack iftop iftop-stage iftop-ipk iftop-clean iftop-dirclean iftop-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IFTOP_SOURCE):
	$(WGET) -P $(DL_DIR) $(IFTOP_SITE)/$(IFTOP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(IFTOP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iftop-source: $(DL_DIR)/$(IFTOP_SOURCE) $(IFTOP_PATCHES)

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
$(IFTOP_BUILD_DIR)/.configured: $(DL_DIR)/$(IFTOP_SOURCE) $(IFTOP_PATCHES) make/iftop.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(IFTOP_DIR) $(IFTOP_BUILD_DIR)
	$(IFTOP_UNZIP) $(DL_DIR)/$(IFTOP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IFTOP_PATCHES)" ; \
		then cat $(IFTOP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IFTOP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IFTOP_DIR)" != "$(IFTOP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IFTOP_DIR) $(IFTOP_BUILD_DIR) ; \
	fi
	(cd $(IFTOP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IFTOP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IFTOP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(IFTOP_BUILD_DIR)/libtool
	touch $@

iftop-unpack: $(IFTOP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IFTOP_BUILD_DIR)/.built: $(IFTOP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(IFTOP_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
iftop: $(IFTOP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IFTOP_BUILD_DIR)/.staged: $(IFTOP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(IFTOP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

iftop-stage: $(IFTOP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iftop
#
$(IFTOP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iftop" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IFTOP_PRIORITY)" >>$@
	@echo "Section: $(IFTOP_SECTION)" >>$@
	@echo "Version: $(IFTOP_VERSION)-$(IFTOP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IFTOP_MAINTAINER)" >>$@
	@echo "Source: $(IFTOP_SITE)/$(IFTOP_SOURCE)" >>$@
	@echo "Description: $(IFTOP_DESCRIPTION)" >>$@
	@echo "Depends: $(IFTOP_DEPENDS)" >>$@
	@echo "Suggests: $(IFTOP_SUGGESTS)" >>$@
	@echo "Conflicts: $(IFTOP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IFTOP_IPK_DIR)/opt/sbin or $(IFTOP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IFTOP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IFTOP_IPK_DIR)/opt/etc/iftop/...
# Documentation files should be installed in $(IFTOP_IPK_DIR)/opt/doc/iftop/...
# Daemon startup scripts should be installed in $(IFTOP_IPK_DIR)/opt/etc/init.d/S??iftop
#
# You may need to patch your application to make it use these locations.
#
$(IFTOP_IPK): $(IFTOP_BUILD_DIR)/.built
	rm -rf $(IFTOP_IPK_DIR) $(BUILD_DIR)/iftop_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IFTOP_BUILD_DIR) DESTDIR=$(IFTOP_IPK_DIR) install-strip
	install -d $(IFTOP_IPK_DIR)/opt/etc/
#	install -m 644 $(IFTOP_SOURCE_DIR)/iftop.conf $(IFTOP_IPK_DIR)/opt/etc/iftop.conf
	install -d $(IFTOP_IPK_DIR)/opt/man/man8
	install -m 644 $(IFTOP_BUILD_DIR)/iftop.8 $(IFTOP_IPK_DIR)/opt/man/man8
#	install -m 755 $(IFTOP_SOURCE_DIR)/rc.iftop $(IFTOP_IPK_DIR)/opt/etc/init.d/SXXiftop
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IFTOP_IPK_DIR)/opt/etc/init.d/SXXiftop
	$(MAKE) $(IFTOP_IPK_DIR)/CONTROL/control
#	install -m 755 $(IFTOP_SOURCE_DIR)/postinst $(IFTOP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IFTOP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(IFTOP_SOURCE_DIR)/prerm $(IFTOP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(IFTOP_IPK_DIR)/CONTROL/prerm
#	echo $(IFTOP_CONFFILES) | sed -e 's/ /\n/g' > $(IFTOP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IFTOP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iftop-ipk: $(IFTOP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iftop-clean:
	rm -f $(IFTOP_BUILD_DIR)/.built
	-$(MAKE) -C $(IFTOP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iftop-dirclean:
	rm -rf $(BUILD_DIR)/$(IFTOP_DIR) $(IFTOP_BUILD_DIR) $(IFTOP_IPK_DIR) $(IFTOP_IPK)
#
#
# Some sanity check for the package.
#
iftop-check: $(IFTOP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IFTOP_IPK)
