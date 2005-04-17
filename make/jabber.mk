###########################################################
#
# jabber
#
###########################################################

# You must replace "jabber" and "JABBER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# JABBER_VERSION, JABBER_SITE and JABBER_SOURCE define
# the upstream location of the source code for the package.
# JABBER_DIR is the directory which is created when the source
# archive is unpacked.
# JABBER_UNZIP is the command used to unzip the source.
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
JABBER_SITE=http://jabberd.jabberstudio.org/1.4/dist
JABBER_VERSION=1.4.2
JABBER_SOURCE=jabber-$(JABBER_VERSION).tar.gz
JABBER_DIR=jabber-$(JABBER_VERSION)
JABBER_UNZIP=zcat
JABBER_MAINTAINER=Brian Zhou <bzhou@users.sf.net>
JABBER_DESCRIPTION=Jabber is an open-source IM platform designed to be open, fast, and easy to use and extend.
JABBER_SECTION=misc
JABBER_PRIORITY=optional
JABBER_DEPENDS=coreutils
JABBER_CONFLICTS=

#
# JABBER_IPK_VERSION should be incremented when the ipk changes.
#
JABBER_IPK_VERSION=1

#
# JABBER_CONFFILES should be a list of user-editable files
JABBER_CONFFILES=/opt/etc/jabber/jabber.xml /opt/etc/jabber/jabber.conf /opt/etc/init.d/S80jabber

#
# JABBER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
JABBER_PATCHES=$(JABBER_SOURCE_DIR)/Makefile.patch $(JABBER_SOURCE_DIR)/jabber.xml.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
JABBER_CPPFLAGS=
JABBER_LDFLAGS=

#
# JABBER_BUILD_DIR is the directory in which the build is done.
# JABBER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# JABBER_IPK_DIR is the directory in which the ipk is built.
# JABBER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
JABBER_BUILD_DIR=$(BUILD_DIR)/jabber
JABBER_SOURCE_DIR=$(SOURCE_DIR)/jabber
JABBER_IPK_DIR=$(BUILD_DIR)/jabber-$(JABBER_VERSION)-ipk
JABBER_IPK=$(BUILD_DIR)/jabber_$(JABBER_VERSION)-$(JABBER_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(JABBER_SOURCE):
	$(WGET) -P $(DL_DIR) $(JABBER_SITE)/$(JABBER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
jabber-source: $(DL_DIR)/$(JABBER_SOURCE) $(JABBER_PATCHES)

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
$(JABBER_BUILD_DIR)/.configured: $(DL_DIR)/$(JABBER_SOURCE) $(JABBER_PATCHES)
	#$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(JABBER_DIR) $(JABBER_BUILD_DIR)
	$(JABBER_UNZIP) $(DL_DIR)/$(JABBER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(JABBER_PATCHES) | patch -d $(BUILD_DIR)/$(JABBER_DIR) -p1
	mv $(BUILD_DIR)/$(JABBER_DIR) $(JABBER_BUILD_DIR)
	(cd $(JABBER_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(JABBER_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(JABBER_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
	touch $(JABBER_BUILD_DIR)/.configured

jabber-unpack: $(JABBER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(JABBER_BUILD_DIR)/.built: $(JABBER_BUILD_DIR)/.configured
	rm -f $(JABBER_BUILD_DIR)/.built
	$(MAKE) -C $(JABBER_BUILD_DIR)
	touch $(JABBER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
jabber: $(JABBER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(JABBER_BUILD_DIR)/.staged: $(JABBER_BUILD_DIR)/.built
	rm -f $(JABBER_BUILD_DIR)/.staged
	$(MAKE) -C $(JABBER_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(JABBER_BUILD_DIR)/.staged

jabber-stage: $(JABBER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/jabber
#
$(JABBER_IPK_DIR)/CONTROL/control:
	@install -d $(JABBER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: jabber" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(JABBER_PRIORITY)" >>$@
	@echo "Section: $(JABBER_SECTION)" >>$@
	@echo "Version: $(JABBER_VERSION)-$(JABBER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(JABBER_MAINTAINER)" >>$@
	@echo "Source: $(JABBER_SITE)/$(JABBER_SOURCE)" >>$@
	@echo "Description: $(JABBER_DESCRIPTION)" >>$@
	@echo "Depends: $(JABBER_DEPENDS)" >>$@
	@echo "Conflicts: $(JABBER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(JABBER_IPK_DIR)/opt/sbin or $(JABBER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(JABBER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(JABBER_IPK_DIR)/opt/etc/jabber/...
# Documentation files should be installed in $(JABBER_IPK_DIR)/opt/doc/jabber/...
# Daemon startup scripts should be installed in $(JABBER_IPK_DIR)/opt/etc/init.d/S??jabber
#
# You may need to patch your application to make it use these locations.
#
$(JABBER_IPK): $(JABBER_BUILD_DIR)/.built
	rm -rf $(JABBER_IPK_DIR) $(BUILD_DIR)/jabber_*_$(TARGET_ARCH).ipk
	install -d $(JABBER_IPK_DIR)/opt/etc/jabber
	$(MAKE) -C $(JABBER_BUILD_DIR) DESTDIR="$(JABBER_IPK_DIR)/opt" STRIP_COMMAND="$(STRIP_COMMAND)" install
	install -m 644 $(JABBER_SOURCE_DIR)/jabber.conf $(JABBER_IPK_DIR)/opt/etc/jabber/jabber.conf
	install -d $(JABBER_IPK_DIR)/opt/etc/init.d
	install -m 755 $(JABBER_SOURCE_DIR)/rc.jabber $(JABBER_IPK_DIR)/opt/etc/init.d/S80jabber
	$(MAKE) $(JABBER_IPK_DIR)/CONTROL/control
	install -m 755 $(JABBER_SOURCE_DIR)/postinst $(JABBER_IPK_DIR)/CONTROL/postinst
	install -m 755 $(JABBER_SOURCE_DIR)/prerm $(JABBER_IPK_DIR)/CONTROL/prerm
	echo $(JABBER_CONFFILES) | sed -e 's/ /\n/g' > $(JABBER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(JABBER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
jabber-ipk: $(JABBER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
jabber-clean:
	-$(MAKE) -C $(JABBER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
jabber-dirclean:
	rm -rf $(BUILD_DIR)/$(JABBER_DIR) $(JABBER_BUILD_DIR) $(JABBER_IPK_DIR) $(JABBER_IPK)
