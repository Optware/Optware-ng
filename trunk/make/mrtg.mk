###########################################################
#
# mrtg
#
###########################################################

#
# MRTG_VERSION, MRTG_SITE and MRTG_SOURCE define
# the upstream location of the source code for the package.
# MRTG_DIR is the directory which is created when the source
# archive is unpacked.
# MRTG_UNZIP is the command used to unzip the source.
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
MRTG_SITE=http://oss.oetiker.ch/mrtg/pub/
MRTG_VERSION=2.15.2
MRTG_SOURCE=mrtg-$(MRTG_VERSION).tar.gz
MRTG_DIR=mrtg-$(MRTG_VERSION)
MRTG_UNZIP=zcat
MRTG_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MRTG_DESCRIPTION=Multi Router Traffic Grapher
MRTG_SECTION=admin
MRTG_PRIORITY=optional
MRTG_DEPENDS=libgd, perl
MRTG_SUGGESTS=
MRTG_CONFLICTS=

#
# MRTG_IPK_VERSION should be incremented when the ipk changes.
#
MRTG_IPK_VERSION=1

#
# MRTG_CONFFILES should be a list of user-editable files
MRTG_CONFFILES=

#
# MRTG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
MRTG_PATCHES=$(MRTG_SOURCE_DIR)/configure.in.patch $(MRTG_SOURCE_DIR)/Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MRTG_CPPFLAGS=
MRTG_LDFLAGS=

#
# MRTG_BUILD_DIR is the directory in which the build is done.
# MRTG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MRTG_IPK_DIR is the directory in which the ipk is built.
# MRTG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MRTG_BUILD_DIR=$(BUILD_DIR)/mrtg
MRTG_SOURCE_DIR=$(SOURCE_DIR)/mrtg
MRTG_IPK_DIR=$(BUILD_DIR)/mrtg-$(MRTG_VERSION)-ipk
MRTG_IPK=$(BUILD_DIR)/mrtg_$(MRTG_VERSION)-$(MRTG_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MRTG_SOURCE):
	$(WGET) -P $(DL_DIR) $(MRTG_SITE)/$(MRTG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mrtg-source: $(DL_DIR)/$(MRTG_SOURCE) $(MRTG_PATCHES)

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
$(MRTG_BUILD_DIR)/.configured: $(DL_DIR)/$(MRTG_SOURCE) $(MRTG_PATCHES)
	$(MAKE) libgd-stage
	rm -rf $(BUILD_DIR)/$(MRTG_DIR) $(MRTG_BUILD_DIR)
	$(MRTG_UNZIP) $(DL_DIR)/$(MRTG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MRTG_PATCHES)" ; \
		then cat $(MRTG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MRTG_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(MRTG_DIR)" != "$(MRTG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MRTG_DIR) $(MRTG_BUILD_DIR) ; \
	fi
	(cd $(MRTG_BUILD_DIR); \
		autoconf ;\
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MRTG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MRTG_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(MRTG_BUILD_DIR)/libtool
	touch $(MRTG_BUILD_DIR)/.configured

mrtg-unpack: $(MRTG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MRTG_BUILD_DIR)/.built: $(MRTG_BUILD_DIR)/.configured
	rm -f $(MRTG_BUILD_DIR)/.built
	$(MAKE) -C $(MRTG_BUILD_DIR) TARGET_PERL="/opt/bin/perl"
	touch $(MRTG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
mrtg: $(MRTG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MRTG_BUILD_DIR)/.staged: $(MRTG_BUILD_DIR)/.built
	rm -f $(MRTG_BUILD_DIR)/.staged
	$(MAKE) -C $(MRTG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(MRTG_BUILD_DIR)/.staged

mrtg-stage: $(MRTG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mrtg
#
$(MRTG_IPK_DIR)/CONTROL/control:
	@install -d $(MRTG_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: mrtg" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MRTG_PRIORITY)" >>$@
	@echo "Section: $(MRTG_SECTION)" >>$@
	@echo "Version: $(MRTG_VERSION)-$(MRTG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MRTG_MAINTAINER)" >>$@
	@echo "Source: $(MRTG_SITE)/$(MRTG_SOURCE)" >>$@
	@echo "Description: $(MRTG_DESCRIPTION)" >>$@
	@echo "Depends: $(MRTG_DEPENDS)" >>$@
	@echo "Suggests: $(MRTG_SUGGESTS)" >>$@
	@echo "Conflicts: $(MRTG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MRTG_IPK_DIR)/opt/sbin or $(MRTG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MRTG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MRTG_IPK_DIR)/opt/etc/mrtg/...
# Documentation files should be installed in $(MRTG_IPK_DIR)/opt/doc/mrtg/...
# Daemon startup scripts should be installed in $(MRTG_IPK_DIR)/opt/etc/init.d/S??mrtg
#
# You may need to patch your application to make it use these locations.
#
$(MRTG_IPK): $(MRTG_BUILD_DIR)/.built
	rm -rf $(MRTG_IPK_DIR) $(BUILD_DIR)/mrtg_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MRTG_BUILD_DIR) TARGET_PERL="/opt/bin/perl" DESTDIR=$(MRTG_IPK_DIR) install
	$(STRIP_COMMAND) $(MRTG_IPK_DIR)/opt/bin/rateup
#	install -d $(MRTG_IPK_DIR)/opt/etc/
#	install -m 644 $(MRTG_SOURCE_DIR)/mrtg.conf $(MRTG_IPK_DIR)/opt/etc/mrtg.conf
#	install -d $(MRTG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MRTG_SOURCE_DIR)/rc.mrtg $(MRTG_IPK_DIR)/opt/etc/init.d/SXXmrtg
	$(MAKE) $(MRTG_IPK_DIR)/CONTROL/control
	install -m 755 $(MRTG_SOURCE_DIR)/postinst $(MRTG_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MRTG_SOURCE_DIR)/prerm $(MRTG_IPK_DIR)/CONTROL/prerm
	echo $(MRTG_CONFFILES) | sed -e 's/ /\n/g' > $(MRTG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MRTG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mrtg-ipk: $(MRTG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mrtg-clean:
	rm -f $(MRTG_BUILD_DIR)/.built
	-$(MAKE) -C $(MRTG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mrtg-dirclean:
	rm -rf $(BUILD_DIR)/$(MRTG_DIR) $(MRTG_BUILD_DIR) $(MRTG_IPK_DIR) $(MRTG_IPK)

#
# Some sanity check for the package.
#
mrtg-check: $(MRTG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MRTG_IPK)
