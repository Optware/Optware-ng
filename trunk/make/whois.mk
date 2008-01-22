###########################################################
#
# whois
#
###########################################################

#
# WHOIS_VERSION, WHOIS_SITE and WHOIS_SOURCE define
# the upstream location of the source code for the package.
# WHOIS_DIR is the directory which is created when the source
# archive is unpacked.
# WHOIS_UNZIP is the command used to unzip the source.
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
WHOIS_SITE=http://ftp.debian.org/debian/pool/main/w/whois/
WHOIS_VERSION=4.7.22
WHOIS_SOURCE=whois_$(WHOIS_VERSION).tar.gz
WHOIS_DIR=whois-$(WHOIS_VERSION)
WHOIS_UNZIP=zcat
WHOIS_MAINTAINER=Adam Baker <slug@baker-net.org.uk>
WHOIS_DESCRIPTION=Perform whois lookups to identify site owners
WHOIS_SECTION=net
WHOIS_PRIORITY=optional
WHOIS_DEPENDS=
WHOIS_SUGGESTS=
WHOIS_CONFLICTS=

#
# WHOIS_IPK_VERSION should be incremented when the ipk changes.
#
WHOIS_IPK_VERSION=1

#
# WHOIS_CONFFILES should be a list of user-editable files
WHOIS_CONFFILES=

#
# WHOIS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
WHOIS_PATCHES=$(WHOIS_SOURCE_DIR)/config.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
WHOIS_CPPFLAGS=
WHOIS_LDFLAGS=

#
# WHOIS_BUILD_DIR is the directory in which the build is done.
# WHOIS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# WHOIS_IPK_DIR is the directory in which the ipk is built.
# WHOIS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
WHOIS_BUILD_DIR=$(BUILD_DIR)/whois
WHOIS_SOURCE_DIR=$(SOURCE_DIR)/whois
WHOIS_IPK_DIR=$(BUILD_DIR)/whois-$(WHOIS_VERSION)-ipk
WHOIS_IPK=$(BUILD_DIR)/whois_$(WHOIS_VERSION)-$(WHOIS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: whois-source whois-unpack whois whois-stage whois-ipk whois-clean whois-dirclean whois-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(WHOIS_SOURCE):
	$(WGET) -P $(DL_DIR) $(WHOIS_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
whois-source: $(DL_DIR)/$(WHOIS_SOURCE) $(WHOIS_PATCHES)

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
$(WHOIS_BUILD_DIR)/.configured: $(DL_DIR)/$(WHOIS_SOURCE) $(WHOIS_PATCHES)
	rm -rf $(BUILD_DIR)/$(WHOIS_DIR) $(WHOIS_BUILD_DIR)
	$(WHOIS_UNZIP) $(DL_DIR)/$(WHOIS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(WHOIS_PATCHES)"; \
		then cat $(WHOIS_PATCHES) | patch -bd $(BUILD_DIR)/$(WHOIS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(WHOIS_DIR) $(WHOIS_BUILD_DIR)
	(cd $(WHOIS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(WHOIS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(WHOIS_LDFLAGS)" \
	)
	sed -ie 's|$$(BASEDIR)/usr/share|$$(BASEDIR)/opt/share|' $(WHOIS_BUILD_DIR)/po/Makefile
	touch $(WHOIS_BUILD_DIR)/.configured

#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \

whois-unpack: $(WHOIS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(WHOIS_BUILD_DIR)/.built: $(WHOIS_BUILD_DIR)/.configured
	rm -f $(WHOIS_BUILD_DIR)/.built
	$(MAKE) CC=$(TARGET_CC) -C $(WHOIS_BUILD_DIR) prefix=/opt
	touch $(WHOIS_BUILD_DIR)/.built

#
# This is the build convenience target.
#
whois: $(WHOIS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(WHOIS_BUILD_DIR)/.staged: $(WHOIS_BUILD_DIR)/.built
	rm -f $(WHOIS_BUILD_DIR)/.staged
	$(MAKE) -C $(WHOIS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(WHOIS_BUILD_DIR)/.staged

whois-stage: $(WHOIS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/whois
#
$(WHOIS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: whois" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(WHOIS_PRIORITY)" >>$@
	@echo "Section: $(WHOIS_SECTION)" >>$@
	@echo "Version: $(WHOIS_VERSION)-$(WHOIS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(WHOIS_MAINTAINER)" >>$@
	@echo "Source: $(WHOIS_SITE)/$(WHOIS_SOURCE)" >>$@
	@echo "Description: $(WHOIS_DESCRIPTION)" >>$@
	@echo "Depends: $(WHOIS_DEPENDS)" >>$@
	@echo "Suggests: $(WHOIS_SUGGESTS)" >>$@
	@echo "Conflicts: $(WHOIS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(WHOIS_IPK_DIR)/opt/sbin or $(WHOIS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(WHOIS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(WHOIS_IPK_DIR)/opt/etc/whois/...
# Documentation files should be installed in $(WHOIS_IPK_DIR)/opt/doc/whois/...
# Daemon startup scripts should be installed in $(WHOIS_IPK_DIR)/opt/etc/init.d/S??whois
#
# You may need to patch your application to make it use these locations.
#
$(WHOIS_IPK): $(WHOIS_BUILD_DIR)/.built
	rm -rf $(WHOIS_IPK_DIR) $(BUILD_DIR)/whois_*_$(TARGET_ARCH).ipk
	install -d $(WHOIS_IPK_DIR)/opt/bin/
	install -d $(WHOIS_IPK_DIR)/opt/share/man/man1
	$(MAKE) -C $(WHOIS_BUILD_DIR) BASEDIR=$(WHOIS_IPK_DIR) prefix=/opt install
	$(STRIP_COMMAND) $(WHOIS_IPK_DIR)/opt/bin/whois
#	install -d $(WHOIS_IPK_DIR)/opt/etc/init.d
	$(MAKE) $(WHOIS_IPK_DIR)/CONTROL/control
	echo $(WHOIS_CONFFILES) | sed -e 's/ /\n/g' > $(WHOIS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(WHOIS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
whois-ipk: $(WHOIS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
whois-clean:
	-$(MAKE) -C $(WHOIS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
whois-dirclean:
	rm -rf $(BUILD_DIR)/$(WHOIS_DIR) $(WHOIS_BUILD_DIR) $(WHOIS_IPK_DIR) $(WHOIS_IPK)

#
# Some sanity check for the package.
#
whois-check: $(WHOIS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(WHOIS_IPK)
