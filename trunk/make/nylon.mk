###########################################################
#
# nylon
#
###########################################################

# You must replace "nylon" and "NYLON" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# NYLON_VERSION, NYLON_SITE and NYLON_SOURCE define
# the upstream location of the source code for the package.
# NYLON_DIR is the directory which is created when the source
# archive is unpacked.
# NYLON_UNZIP is the command used to unzip the source.
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
NYLON_SITE=http://monkey.org/~marius/nylon
NYLON_VERSION=1.21
NYLON_SOURCE=nylon-$(NYLON_VERSION).tar.gz
NYLON_DIR=nylon-$(NYLON_VERSION)
NYLON_UNZIP=zcat
NYLON_MAINTAINER=Jean-Fabrice <jeanfabrice@users.sourceforge.net>
NYLON_DESCRIPTION=Nylon is a small socks4/socks5 proxy server
NYLON_SECTION=misc
NYLON_PRIORITY=optional
NYLON_DEPENDS=libevent (>=1.4)
NYLON_CONFLICTS=

#
# NYLON_IPK_VERSION should be incremented when the ipk changes.
#
NYLON_IPK_VERSION=3

#
# NYLON_CONFFILES should be a list of user-editable files
NYLON_CONFFILES=/opt/etc/nylon.conf

#
# NYLON_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# NYLON_PATCHES=$(NYLON_SOURCE_DIR)/nylon.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NYLON_CPPFLAGS=
NYLON_LDFLAGS=

#
# NYLON_BUILD_DIR is the directory in which the build is done.
# NYLON_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NYLON_IPK_DIR is the directory in which the ipk is built.
# NYLON_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NYLON_BUILD_DIR=$(BUILD_DIR)/nylon
NYLON_SOURCE_DIR=$(SOURCE_DIR)/nylon
NYLON_IPK_DIR=$(BUILD_DIR)/nylon-$(NYLON_VERSION)-ipk
NYLON_IPK=$(BUILD_DIR)/nylon_$(NYLON_VERSION)-$(NYLON_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: nylon-source nylon-unpack nylon nylon-stage nylon-ipk nylon-clean nylon-dirclean nylon-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NYLON_SOURCE):
	$(WGET) -P $(@D) $(NYLON_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
nylon-source: $(DL_DIR)/$(NYLON_SOURCE) 

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
$(NYLON_BUILD_DIR)/.configured: $(DL_DIR)/$(NYLON_SOURCE)
	$(MAKE) libevent-stage
	rm -rf $(BUILD_DIR)/$(NYLON_DIR) $(@D)
	$(NYLON_UNZIP) $(DL_DIR)/$(NYLON_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(NYLON_PATCHES) | patch -d $(BUILD_DIR)/$(NYLON_DIR) -p1
	mv $(BUILD_DIR)/$(NYLON_DIR) $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NYLON_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NYLON_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--with-libevent=$(STAGING_PREFIX) \
	)
	touch $@

nylon-unpack: $(NYLON_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NYLON_BUILD_DIR)/.built: $(NYLON_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
nylon: $(NYLON_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(NYLON_BUILD_DIR)/.staged: $(NYLON_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#nylon-stage: $(NYLON_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/nylon
#
$(NYLON_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: nylon" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NYLON_PRIORITY)" >>$@
	@echo "Section: $(NYLON_SECTION)" >>$@
	@echo "Version: $(NYLON_VERSION)-$(NYLON_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NYLON_MAINTAINER)" >>$@
	@echo "Source: $(NYLON_SITE)/$(NYLON_SOURCE)" >>$@
	@echo "Description: $(NYLON_DESCRIPTION)" >>$@
	@echo "Depends: $(NYLON_DEPENDS)" >>$@
	@echo "Conflicts: $(NYLON_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NYLON_IPK_DIR)/opt/sbin or $(NYLON_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NYLON_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NYLON_IPK_DIR)/opt/etc/nylon/...
# Documentation files should be installed in $(NYLON_IPK_DIR)/opt/doc/nylon/...
# Daemon startup scripts should be installed in $(NYLON_IPK_DIR)/opt/etc/init.d/S??nylon
#
# You may need to patch your application to make it use these locations.
#
$(NYLON_IPK): $(NYLON_BUILD_DIR)/.built
	rm -rf $(NYLON_IPK_DIR) $(BUILD_DIR)/nylon_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(NYLON_BUILD_DIR) DESTDIR=$(NYLON_IPK_DIR) install
	$(STRIP_COMMAND) $(NYLON_IPK_DIR)/opt/bin/nylon
	install -d $(NYLON_IPK_DIR)/opt/var/run
	install -d $(NYLON_IPK_DIR)/opt/etc
	install -m 644 $(NYLON_SOURCE_DIR)/nylon.conf $(NYLON_IPK_DIR)/opt/etc/nylon.conf
	install -d $(NYLON_IPK_DIR)/opt/etc/init.d
	install -m 755 $(NYLON_SOURCE_DIR)/rc.nylon $(NYLON_IPK_DIR)/opt/etc/init.d/S10nylon
	$(MAKE) $(NYLON_IPK_DIR)/CONTROL/control
	install -m 755 $(NYLON_SOURCE_DIR)/postinst $(NYLON_IPK_DIR)/CONTROL/postinst
	install -m 755 $(NYLON_SOURCE_DIR)/prerm $(NYLON_IPK_DIR)/CONTROL/prerm
	echo $(NYLON_CONFFILES) | sed -e 's/ /\n/g' > $(NYLON_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NYLON_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
nylon-ipk: $(NYLON_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
nylon-clean:
	-$(MAKE) -C $(NYLON_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
nylon-dirclean:
	rm -rf $(BUILD_DIR)/$(NYLON_DIR) $(NYLON_BUILD_DIR) $(NYLON_IPK_DIR) $(NYLON_IPK)

#
# Some sanity check for the package.
#
nylon-check: $(NYLON_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NYLON_IPK)
