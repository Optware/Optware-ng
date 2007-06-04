###########################################################
#
# jabber
#
###########################################################

# You must replace "jabber" and "JABBERD" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# JABBERD_VERSION, JABBERD_SITE and JABBERD_SOURCE define
# the upstream location of the source code for the package.
# JABBERD_DIR is the directory which is created when the source
# archive is unpacked.
# JABBERD_UNZIP is the command used to unzip the source.
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
JABBERD_SITE=http://download.jabberd.org/jabberd14
JABBERD_VERSION=1.6.0
JABBERD_SOURCE=jabberd14-$(JABBERD_VERSION).tar.gz
JABBERD_DIR=jabberd14-$(JABBERD_VERSION)
JABBERD_UNZIP=zcat
JABBERD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
JABBERD_DESCRIPTION=Jabber is an open-source IM platform designed to be open, fast, and easy to use and extend.
JABBERD_SECTION=misc
JABBERD_PRIORITY=optional
JABBERD_DEPENDS=coreutils, libidn, libpth, openssl, popt, expat
JABBERD_CONFLICTS=

#
# JABBERD_IPK_VERSION should be incremented when the ipk changes.
#
JABBERD_IPK_VERSION=3

#
# JABBERD_CONFFILES should be a list of user-editable files
JABBERD_CONFFILES=/opt/etc/jabber/jabber.xml /opt/etc/jabber/jabber.conf /opt/etc/init.d/S80jabber

#
# JABBERD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# JABBERD_PATCHES=$(JABBERD_SOURCE_DIR)/Makefile.patch $(JABBERD_SOURCE_DIR)/jabber.xml.patch $(JABBERD_SOURCE_DIR)/config.c.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JABBERD_CPPFLAGS=
JABBERD_LDFLAGS=

#
# JABBERD_BUILD_DIR is the directory in which the build is done.
# JABBERD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JABBERD_IPK_DIR is the directory in which the ipk is built.
# JABBERD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JABBERD_BUILD_DIR=$(BUILD_DIR)/jabberd
JABBERD_SOURCE_DIR=$(SOURCE_DIR)/jabberd
JABBERD_IPK_DIR=$(BUILD_DIR)/jabberd-$(JABBERD_VERSION)-ipk
JABBERD_IPK=$(BUILD_DIR)/jabberd_$(JABBERD_VERSION)-$(JABBERD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: jabberd-source jabberd-unpack jabberd jabberd-stage jabberd-ipk jabberd-clean jabberd-dirclean jabberd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JABBERD_SOURCE):
	$(WGET) -P $(DL_DIR) $(JABBERD_SITE)/$(JABBERD_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jabberd-source: $(DL_DIR)/$(JABBERD_SOURCE) $(JABBERD_PATCHES)

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
$(JABBERD_BUILD_DIR)/.configured: $(DL_DIR)/$(JABBERD_SOURCE) $(JABBERD_PATCHES)
	$(MAKE) libidn-stage libpth-stage openssl-stage popt-stage expat-stage
	rm -rf $(BUILD_DIR)/$(JABBERD_DIR) $(JABBERD_BUILD_DIR)
	$(JABBERD_UNZIP) $(DL_DIR)/$(JABBERD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(JABBERD_PATCHES)"; then \
		cat $(JABBERD_PATCHES) | patch -d $(BUILD_DIR)/$(JABBERD_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(JABBERD_DIR) $(JABBERD_BUILD_DIR)
	(cd $(JABBERD_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JABBERD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JABBERD_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--sysconfdir=/opt/etc/jabber \
		--enable-debug \
		--enable-ssl \
		--without-mysql \
		--without-postgresql \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(JABBERD_BUILD_DIR)/libtool
	touch $(JABBERD_BUILD_DIR)/.configured

jabberd-unpack: $(JABBERD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JABBERD_BUILD_DIR)/.built: $(JABBERD_BUILD_DIR)/.configured
	rm -f $(JABBERD_BUILD_DIR)/.built
	$(MAKE) -C $(JABBERD_BUILD_DIR)
	touch $(JABBERD_BUILD_DIR)/.built

#
# This is the build convenience target.
#
jabberd: $(JABBERD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JABBERD_BUILD_DIR)/.staged: $(JABBERD_BUILD_DIR)/.built
	rm -f $(JABBERD_BUILD_DIR)/.staged
	$(MAKE) -C $(JABBERD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(JABBERD_BUILD_DIR)/.staged

jabberd-stage: $(JABBERD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jabberd
#
$(JABBERD_IPK_DIR)/CONTROL/control:
	@install -d $(JABBERD_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: jabberd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JABBERD_PRIORITY)" >>$@
	@echo "Section: $(JABBERD_SECTION)" >>$@
	@echo "Version: $(JABBERD_VERSION)-$(JABBERD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JABBERD_MAINTAINER)" >>$@
	@echo "Source: $(JABBERD_SITE)/$(JABBERD_SOURCE)" >>$@
	@echo "Description: $(JABBERD_DESCRIPTION)" >>$@
	@echo "Depends: $(JABBERD_DEPENDS)" >>$@
	@echo "Conflicts: $(JABBERD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JABBERD_IPK_DIR)/opt/sbin or $(JABBERD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JABBERD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JABBERD_IPK_DIR)/opt/etc/jabber/...
# Documentation files should be installed in $(JABBERD_IPK_DIR)/opt/doc/jabber/...
# Daemon startup scripts should be installed in $(JABBERD_IPK_DIR)/opt/etc/init.d/S??jabber
#
# You may need to patch your application to make it use these locations.
#
$(JABBERD_IPK): $(JABBERD_BUILD_DIR)/.built
	rm -rf $(JABBERD_IPK_DIR) $(BUILD_DIR)/jabberd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(JABBERD_BUILD_DIR) DESTDIR=$(JABBERD_IPK_DIR) install-strip
	install -m 644 $(JABBERD_SOURCE_DIR)/jabber.conf $(JABBERD_IPK_DIR)/opt/etc/jabber/jabber.conf
	install -d $(JABBERD_IPK_DIR)/opt/etc/init.d
	install -m 755 $(JABBERD_SOURCE_DIR)/rc.jabber $(JABBERD_IPK_DIR)/opt/etc/init.d/S80jabber
	$(MAKE) $(JABBERD_IPK_DIR)/CONTROL/control
	install -m 755 $(JABBERD_SOURCE_DIR)/postinst $(JABBERD_IPK_DIR)/CONTROL/postinst
	install -m 755 $(JABBERD_SOURCE_DIR)/prerm $(JABBERD_IPK_DIR)/CONTROL/prerm
ifneq ($(OPTWARE_TARGET), nslu2)
	sed -i -e '/share.hdd.conf/d' $(JABBERD_IPK_DIR)/CONTROL/postinst
endif
	echo $(JABBERD_CONFFILES) | sed -e 's/ /\n/g' > $(JABBERD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JABBERD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jabberd-ipk: $(JABBERD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jabberd-clean:
	-$(MAKE) -C $(JABBERD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jabberd-dirclean:
	rm -rf $(BUILD_DIR)/$(JABBERD_DIR) $(JABBERD_BUILD_DIR) $(JABBERD_IPK_DIR) $(JABBERD_IPK)

#
# Some sanity check for the package.
#
jabberd-check: $(JABBERD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(JABBERD_IPK)
