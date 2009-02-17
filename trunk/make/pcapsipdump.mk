###########################################################
#
# pcapsipdump
#
###########################################################
#
# PCAPSIPDUMP_VERSION, PCAPSIPDUMP_SITE and PCAPSIPDUMP_SOURCE define
# the upstream location of the source code for the package.
# PCAPSIPDUMP_DIR is the directory which is created when the source
# archive is unpacked.
# PCAPSIPDUMP_UNZIP is the command used to unzip the source.
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
PCAPSIPDUMP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/psipdump
PCAPSIPDUMP_VERSION=0.1.2
PCAPSIPDUMP_SOURCE=pcapsipdump-$(PCAPSIPDUMP_VERSION).tar.gz
PCAPSIPDUMP_DIR=pcapsipdump-$(PCAPSIPDUMP_VERSION)
PCAPSIPDUMP_UNZIP=zcat
PCAPSIPDUMP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PCAPSIPDUMP_DESCRIPTION=tool for dumping SIP sessions (+RTP traffic, if available)
PCAPSIPDUMP_SECTION=util
PCAPSIPDUMP_PRIORITY=optional
PCAPSIPDUMP_DEPENDS=libstdc++, libpcap
PCAPSIPDUMP_SUGGESTS=
PCAPSIPDUMP_CONFLICTS=

#
# PCAPSIPDUMP_IPK_VERSION should be incremented when the ipk changes.
#
PCAPSIPDUMP_IPK_VERSION=3

#
# PCAPSIPDUMP_CONFFILES should be a list of user-editable files
#PCAPSIPDUMP_CONFFILES=/opt/etc/pcapsipdump.conf /opt/etc/init.d/SXXpcapsipdump

#
# PCAPSIPDUMP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
PCAPSIPDUMP_PATCHES=$(PCAPSIPDUMP_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PCAPSIPDUMP_CPPFLAGS=-fsigned-char
PCAPSIPDUMP_LDFLAGS=

#
# PCAPSIPDUMP_BUILD_DIR is the directory in which the build is done.
# PCAPSIPDUMP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PCAPSIPDUMP_IPK_DIR is the directory in which the ipk is built.
# PCAPSIPDUMP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PCAPSIPDUMP_BUILD_DIR=$(BUILD_DIR)/pcapsipdump
PCAPSIPDUMP_SOURCE_DIR=$(SOURCE_DIR)/pcapsipdump
PCAPSIPDUMP_IPK_DIR=$(BUILD_DIR)/pcapsipdump-$(PCAPSIPDUMP_VERSION)-ipk
PCAPSIPDUMP_IPK=$(BUILD_DIR)/pcapsipdump_$(PCAPSIPDUMP_VERSION)-$(PCAPSIPDUMP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: pcapsipdump-source pcapsipdump-unpack pcapsipdump pcapsipdump-stage pcapsipdump-ipk pcapsipdump-clean pcapsipdump-dirclean pcapsipdump-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PCAPSIPDUMP_SOURCE):
	$(WGET) -P $(@D) $(PCAPSIPDUMP_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pcapsipdump-source: $(DL_DIR)/$(PCAPSIPDUMP_SOURCE) $(PCAPSIPDUMP_PATCHES)

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
$(PCAPSIPDUMP_BUILD_DIR)/.configured: $(DL_DIR)/$(PCAPSIPDUMP_SOURCE) $(PCAPSIPDUMP_PATCHES) make/pcapsipdump.mk
	$(MAKE) libpcap-stage libstdc++-stage
	rm -rf $(BUILD_DIR)/$(PCAPSIPDUMP_DIR) $(@D)
	$(PCAPSIPDUMP_UNZIP) $(DL_DIR)/$(PCAPSIPDUMP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(PCAPSIPDUMP_PATCHES)" ; \
		then cat $(PCAPSIPDUMP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PCAPSIPDUMP_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(PCAPSIPDUMP_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(PCAPSIPDUMP_DIR) $(@D) ; \
	fi
	touch $@

pcapsipdump-unpack: $(PCAPSIPDUMP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PCAPSIPDUMP_BUILD_DIR)/.built: $(PCAPSIPDUMP_BUILD_DIR)/.configured
	rm -f $@
	CC="$(TARGET_CC)" CPPFLAGS="$(STAGING_CPPFLAGS) $(PCAPSIPDUMP_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(PCAPSIPDUMP_LDFLAGS)" \
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
pcapsipdump: $(PCAPSIPDUMP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PCAPSIPDUMP_BUILD_DIR)/.staged: $(PCAPSIPDUMP_BUILD_DIR)/.built
	rm -f $@
	touch $@

pcapsipdump-stage: $(PCAPSIPDUMP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pcapsipdump
#
$(PCAPSIPDUMP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: pcapsipdump" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PCAPSIPDUMP_PRIORITY)" >>$@
	@echo "Section: $(PCAPSIPDUMP_SECTION)" >>$@
	@echo "Version: $(PCAPSIPDUMP_VERSION)-$(PCAPSIPDUMP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PCAPSIPDUMP_MAINTAINER)" >>$@
	@echo "Source: $(PCAPSIPDUMP_SITE)/$(PCAPSIPDUMP_SOURCE)" >>$@
	@echo "Description: $(PCAPSIPDUMP_DESCRIPTION)" >>$@
	@echo "Depends: $(PCAPSIPDUMP_DEPENDS)" >>$@
	@echo "Suggests: $(PCAPSIPDUMP_SUGGESTS)" >>$@
	@echo "Conflicts: $(PCAPSIPDUMP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PCAPSIPDUMP_IPK_DIR)/opt/sbin or $(PCAPSIPDUMP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PCAPSIPDUMP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PCAPSIPDUMP_IPK_DIR)/opt/etc/pcapsipdump/...
# Documentation files should be installed in $(PCAPSIPDUMP_IPK_DIR)/opt/doc/pcapsipdump/...
# Daemon startup scripts should be installed in $(PCAPSIPDUMP_IPK_DIR)/opt/etc/init.d/S??pcapsipdump
#
# You may need to patch your application to make it use these locations.
#
$(PCAPSIPDUMP_IPK): $(PCAPSIPDUMP_BUILD_DIR)/.built
	rm -rf $(PCAPSIPDUMP_IPK_DIR) $(BUILD_DIR)/pcapsipdump_*_$(TARGET_ARCH).ipk
	#$(MAKE) -C $(PCAPSIPDUMP_BUILD_DIR) DESTDIR=$(PCAPSIPDUMP_IPK_DIR) install-strip
	$(STRIP_COMMAND) $(PCAPSIPDUMP_BUILD_DIR)/pcapsipdump
	install -d $(PCAPSIPDUMP_IPK_DIR)/opt/sbin/
	install -m 755 $(PCAPSIPDUMP_BUILD_DIR)/pcapsipdump $(PCAPSIPDUMP_IPK_DIR)/opt/sbin/
	$(MAKE) $(PCAPSIPDUMP_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PCAPSIPDUMP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pcapsipdump-ipk: $(PCAPSIPDUMP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pcapsipdump-clean:
	rm -f $(PCAPSIPDUMP_BUILD_DIR)/.built
	-$(MAKE) -C $(PCAPSIPDUMP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pcapsipdump-dirclean:
	rm -rf $(BUILD_DIR)/$(PCAPSIPDUMP_DIR) $(PCAPSIPDUMP_BUILD_DIR) $(PCAPSIPDUMP_IPK_DIR) $(PCAPSIPDUMP_IPK)
#
#
# Some sanity check for the package.
#
pcapsipdump-check: $(PCAPSIPDUMP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
