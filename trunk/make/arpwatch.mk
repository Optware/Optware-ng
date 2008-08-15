###########################################################
#
# arpwatch
#
###########################################################
#
# ARPWATCH_VERSION, ARPWATCH_SITE and ARPWATCH_SOURCE define
# the upstream location of the source code for the package.
# ARPWATCH_DIR is the directory which is created when the source
# archive is unpacked.
# ARPWATCH_UNZIP is the command used to unzip the source.
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
ARPWATCH_SITE=ftp://ftp.ee.lbl.gov
ARPWATCH_VERSION=2.1a15
ARPWATCH_SOURCE=arpwatch-$(ARPWATCH_VERSION).tar.gz
ARPWATCH_DIR=arpwatch-$(ARPWATCH_VERSION)
ARPWATCH_UNZIP=zcat
ARPWATCH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ARPWATCH_DESCRIPTION=The ethernet monitor program; for keeping track of ethernet/ip address pairings.
ARPWATCH_SECTION=net
ARPWATCH_PRIORITY=optional
ARPWATCH_DEPENDS=libpcap
ARPWATCH_SUGGESTS=
ARPWATCH_CONFLICTS=

#
# ARPWATCH_IPK_VERSION should be incremented when the ipk changes.
#
ARPWATCH_IPK_VERSION=2

#
# ARPWATCH_CONFFILES should be a list of user-editable files
#ARPWATCH_CONFFILES=/opt/etc/arpwatch.conf /opt/etc/init.d/SXXarpwatch

#
# ARPWATCH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ARPWATCH_PATCHES=$(ARPWATCH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ARPWATCH_CPPFLAGS=
ARPWATCH_LDFLAGS=

#
# ARPWATCH_BUILD_DIR is the directory in which the build is done.
# ARPWATCH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ARPWATCH_IPK_DIR is the directory in which the ipk is built.
# ARPWATCH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ARPWATCH_BUILD_DIR=$(BUILD_DIR)/arpwatch
ARPWATCH_SOURCE_DIR=$(SOURCE_DIR)/arpwatch
ARPWATCH_IPK_DIR=$(BUILD_DIR)/arpwatch-$(ARPWATCH_VERSION)-ipk
ARPWATCH_IPK=$(BUILD_DIR)/arpwatch_$(ARPWATCH_VERSION)-$(ARPWATCH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: arpwatch-source arpwatch-unpack arpwatch arpwatch-stage arpwatch-ipk arpwatch-clean arpwatch-dirclean arpwatch-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ARPWATCH_SOURCE):
	$(WGET) -P $(@D) $(ARPWATCH_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
arpwatch-source: $(DL_DIR)/$(ARPWATCH_SOURCE) $(ARPWATCH_PATCHES)

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
$(ARPWATCH_BUILD_DIR)/.configured: $(DL_DIR)/$(ARPWATCH_SOURCE) $(ARPWATCH_PATCHES) make/arpwatch.mk
	$(MAKE) libpcap-stage
	rm -rf $(BUILD_DIR)/$(ARPWATCH_DIR) $(@D)
	$(ARPWATCH_UNZIP) $(DL_DIR)/$(ARPWATCH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ARPWATCH_PATCHES)" ; \
		then cat $(ARPWATCH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ARPWATCH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ARPWATCH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(ARPWATCH_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ARPWATCH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ARPWATCH_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	sed -i	-e 's|-o bin -g bin | |' \
		-e '/CFLAGS.*LIBS/s|$$(CFLAGS)|$$(LDFLAGS) $$(CFLAGS)|' \
		-e '/^LIBS/s| ../libpcap/libpcap.a| -lpcap|' \
		-e '/^arpwatch:/s| ../libpcap/libpcap.a||' \
		$(@D)/Makefile
#	$(PATCH_LIBTOOL) $(ARPWATCH_BUILD_DIR)/libtool
	touch $@

arpwatch-unpack: $(ARPWATCH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ARPWATCH_BUILD_DIR)/.built: $(ARPWATCH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		LDFLAGS="$(STAGING_LDFLAGS) $(ARPWATCH_LDFLAGS)"
	touch $@

#
# This is the build convenience target.
#
arpwatch: $(ARPWATCH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ARPWATCH_BUILD_DIR)/.staged: $(ARPWATCH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

arpwatch-stage: $(ARPWATCH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/arpwatch
#
$(ARPWATCH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: arpwatch" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ARPWATCH_PRIORITY)" >>$@
	@echo "Section: $(ARPWATCH_SECTION)" >>$@
	@echo "Version: $(ARPWATCH_VERSION)-$(ARPWATCH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ARPWATCH_MAINTAINER)" >>$@
	@echo "Source: $(ARPWATCH_SITE)/$(ARPWATCH_SOURCE)" >>$@
	@echo "Description: $(ARPWATCH_DESCRIPTION)" >>$@
	@echo "Depends: $(ARPWATCH_DEPENDS)" >>$@
	@echo "Suggests: $(ARPWATCH_SUGGESTS)" >>$@
	@echo "Conflicts: $(ARPWATCH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ARPWATCH_IPK_DIR)/opt/sbin or $(ARPWATCH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ARPWATCH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ARPWATCH_IPK_DIR)/opt/etc/arpwatch/...
# Documentation files should be installed in $(ARPWATCH_IPK_DIR)/opt/doc/arpwatch/...
# Daemon startup scripts should be installed in $(ARPWATCH_IPK_DIR)/opt/etc/init.d/S??arpwatch
#
# You may need to patch your application to make it use these locations.
#
$(ARPWATCH_IPK): $(ARPWATCH_BUILD_DIR)/.built
	rm -rf $(ARPWATCH_IPK_DIR) $(BUILD_DIR)/arpwatch_*_$(TARGET_ARCH).ipk
	install -d $(ARPWATCH_IPK_DIR)/opt/sbin/
	$(MAKE) -C $(ARPWATCH_BUILD_DIR) DESTDIR=$(ARPWATCH_IPK_DIR) install
	for f in $(ARPWATCH_IPK_DIR)/opt/sbin/*; \
		do chmod +w $$f; $(STRIP_COMMAND) $$f; chmod -w $$f; done
	install -d $(ARPWATCH_IPK_DIR)/opt/man/man8
	$(MAKE) -C $(ARPWATCH_BUILD_DIR) DESTDIR=$(ARPWATCH_IPK_DIR) install-man
#	install -d $(ARPWATCH_IPK_DIR)/opt/etc/
#	install -m 644 $(ARPWATCH_SOURCE_DIR)/arpwatch.conf $(ARPWATCH_IPK_DIR)/opt/etc/arpwatch.conf
#	install -d $(ARPWATCH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ARPWATCH_SOURCE_DIR)/rc.arpwatch $(ARPWATCH_IPK_DIR)/opt/etc/init.d/SXXarpwatch
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXarpwatch
	$(MAKE) $(ARPWATCH_IPK_DIR)/CONTROL/control
#	install -m 755 $(ARPWATCH_SOURCE_DIR)/postinst $(ARPWATCH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ARPWATCH_SOURCE_DIR)/prerm $(ARPWATCH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(ARPWATCH_CONFFILES) | sed -e 's/ /\n/g' > $(ARPWATCH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ARPWATCH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
arpwatch-ipk: $(ARPWATCH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
arpwatch-clean:
	rm -f $(ARPWATCH_BUILD_DIR)/.built
	-$(MAKE) -C $(ARPWATCH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
arpwatch-dirclean:
	rm -rf $(BUILD_DIR)/$(ARPWATCH_DIR) $(ARPWATCH_BUILD_DIR) $(ARPWATCH_IPK_DIR) $(ARPWATCH_IPK)
#
#
# Some sanity check for the package.
#
arpwatch-check: $(ARPWATCH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ARPWATCH_IPK)
