###########################################################
#
# ggrab
#
###########################################################
#
# $Id$
#
# Added on reqeust of "rrarr2003 <fw.unt@sunnymail.ch>"
# See:
#	http://tech.groups.yahoo.com/group/nslu2-linux/message/17112
#
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.
#
GGRAB_SITE=http://webmail.mw-itcon.de/ggrab
GGRAB_VERSION=0.22a
GGRAB_SOURCE=ggrab-$(GGRAB_VERSION)-linux.tgz
GGRAB_DIR=ggrab-$(GGRAB_VERSION)
GGRAB_UNZIP=zcat
GGRAB_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GGRAB_DESCRIPTION=Grabbing and streaming of mpeg2 streams to/from NSLU2. Good with dreambox.
GGRAB_SECTION=misc
GGRAB_PRIORITY=optional
GGRAB_DEPENDS=libstdc++
GGRAB_SUGGESTS=
GGRAB_CONFLICTS=

#
# GGRAB_IPK_VERSION should be incremented when the ipk changes.
#
GGRAB_IPK_VERSION=1

#
# GGRAB_CONFFILES should be a list of user-editable files
GGRAB_CONFFILES=

#
# GGRAB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GGRAB_PATCHES=$(GGRAB_SOURCE_DIR)/Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GGRAB_CPPFLAGS=-DREENTRANT -D_LARGEFILE64_SOURCE
GGRAB_LDFLAGS=-s

#
# GGRAB_BUILD_DIR is the directory in which the build is done.
# GGRAB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GGRAB_IPK_DIR is the directory in which the ipk is built.
# GGRAB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GGRAB_BUILD_DIR=$(BUILD_DIR)/ggrab
GGRAB_SOURCE_DIR=$(SOURCE_DIR)/ggrab
GGRAB_IPK_DIR=$(BUILD_DIR)/ggrab-$(GGRAB_VERSION)-ipk
GGRAB_IPK=$(BUILD_DIR)/ggrab_$(GGRAB_VERSION)-$(GGRAB_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ggrab-source ggrab-unpack ggrab ggrab-stage ggrab-ipk ggrab-clean ggrab-dirclean ggrab-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GGRAB_SOURCE):
	$(WGET) -P $(DL_DIR) $(GGRAB_SITE)/$(GGRAB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ggrab-source: $(DL_DIR)/$(GGRAB_SOURCE) $(GGRAB_PATCHES)

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
$(GGRAB_BUILD_DIR)/.configured: $(DL_DIR)/$(GGRAB_SOURCE) $(GGRAB_PATCHES)
	$(MAKE) libstdc++-stage
	rm -rf $(BUILD_DIR)/$(GGRAB_DIR) $(GGRAB_BUILD_DIR)
	$(GGRAB_UNZIP) $(DL_DIR)/$(GGRAB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GGRAB_PATCHES)" ; \
		then cat $(GGRAB_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GGRAB_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GGRAB_DIR)" != "$(GGRAB_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GGRAB_DIR) $(GGRAB_BUILD_DIR) ; \
	fi
#	(cd $(GGRAB_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(GGRAB_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(GGRAB_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
#		--disable-static \
#	)
#	$(PATCH_LIBTOOL) $(GGRAB_BUILD_DIR)/libtool
	touch $(GGRAB_BUILD_DIR)/.configured

ggrab-unpack: $(GGRAB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GGRAB_BUILD_DIR)/.built: $(GGRAB_BUILD_DIR)/.configured
	rm -f $(GGRAB_BUILD_DIR)/.built
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GGRAB_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GGRAB_LDFLAGS)" \
	$(MAKE) -C $(GGRAB_BUILD_DIR)
	touch $(GGRAB_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ggrab: $(GGRAB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GGRAB_BUILD_DIR)/.staged: $(GGRAB_BUILD_DIR)/.built
	rm -f $(GGRAB_BUILD_DIR)/.staged
	$(MAKE) -C $(GGRAB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(GGRAB_BUILD_DIR)/.staged

ggrab-stage: $(GGRAB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ggrab
#
$(GGRAB_IPK_DIR)/CONTROL/control:
	@install -d $(GGRAB_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ggrab" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GGRAB_PRIORITY)" >>$@
	@echo "Section: $(GGRAB_SECTION)" >>$@
	@echo "Version: $(GGRAB_VERSION)-$(GGRAB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GGRAB_MAINTAINER)" >>$@
	@echo "Source: $(GGRAB_SITE)/$(GGRAB_SOURCE)" >>$@
	@echo "Description: $(GGRAB_DESCRIPTION)" >>$@
	@echo "Depends: $(GGRAB_DEPENDS)" >>$@
	@echo "Suggests: $(GGRAB_SUGGESTS)" >>$@
	@echo "Conflicts: $(GGRAB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GGRAB_IPK_DIR)/opt/sbin or $(GGRAB_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GGRAB_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GGRAB_IPK_DIR)/opt/etc/ggrab/...
# Documentation files should be installed in $(GGRAB_IPK_DIR)/opt/doc/ggrab/...
# Daemon startup scripts should be installed in $(GGRAB_IPK_DIR)/opt/etc/init.d/S??ggrab
#
# You may need to patch your application to make it use these locations.
#
$(GGRAB_IPK): $(GGRAB_BUILD_DIR)/.built
	rm -rf $(GGRAB_IPK_DIR) $(BUILD_DIR)/ggrab_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(GGRAB_BUILD_DIR) DESTDIR=$(GGRAB_IPK_DIR) install-strip
	install -d $(GGRAB_IPK_DIR)/opt/bin
	install -m 755 $(GGRAB_BUILD_DIR)/ggrab $(GGRAB_IPK_DIR)/opt/bin/ggrab
	install -m 755 $(GGRAB_BUILD_DIR)/sserver $(GGRAB_IPK_DIR)/opt/bin/sserver
#	install -d $(GGRAB_IPK_DIR)/opt/etc/
#	install -m 644 $(GGRAB_SOURCE_DIR)/ggrab.conf $(GGRAB_IPK_DIR)/opt/etc/ggrab.conf
#	install -d $(GGRAB_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(GGRAB_SOURCE_DIR)/rc.ggrab $(GGRAB_IPK_DIR)/opt/etc/init.d/SXXggrab
	$(MAKE) $(GGRAB_IPK_DIR)/CONTROL/control
#	install -m 755 $(GGRAB_SOURCE_DIR)/postinst $(GGRAB_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GGRAB_SOURCE_DIR)/prerm $(GGRAB_IPK_DIR)/CONTROL/prerm
	echo $(GGRAB_CONFFILES) | sed -e 's/ /\n/g' > $(GGRAB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GGRAB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ggrab-ipk: $(GGRAB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ggrab-clean:
	rm -f $(GGRAB_BUILD_DIR)/.built
	-$(MAKE) -C $(GGRAB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ggrab-dirclean:
	rm -rf $(BUILD_DIR)/$(GGRAB_DIR) $(GGRAB_BUILD_DIR) $(GGRAB_IPK_DIR) $(GGRAB_IPK)
#
#
# Some sanity check for the package.
#
ggrab-check: $(GGRAB_IPK)
        perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GGRAB_IPK)
