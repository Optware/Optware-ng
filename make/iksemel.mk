###########################################################
#
# iksemel
#
###########################################################
#
# IKSEMEL_VERSION, IKSEMEL_SITE and IKSEMEL_SOURCE define
# the upstream location of the source code for the package.
# IKSEMEL_DIR is the directory which is created when the source
# archive is unpacked.
# IKSEMEL_UNZIP is the command used to unzip the source.
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
IKSEMEL_SITE=http://jabberstudio.rediris.es/iksemel
IKSEMEL_VERSION=1.2
IKSEMEL_SOURCE=iksemel-$(IKSEMEL_VERSION).tar.gz
IKSEMEL_DIR=iksemel-$(IKSEMEL_VERSION)
IKSEMEL_UNZIP=zcat
IKSEMEL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
IKSEMEL_DESCRIPTION=iksemel is an XML (eXtensible Markup Language) \
parser library designed for Jabber applications
IKSEMEL_SECTION=lib
IKSEMEL_PRIORITY=optional
IKSEMEL_DEPENDS=gnutls
IKSEMEL_SUGGESTS=
IKSEMEL_CONFLICTS=

#
# IKSEMEL_IPK_VERSION should be incremented when the ipk changes.
#
IKSEMEL_IPK_VERSION=3

#
# IKSEMEL_CONFFILES should be a list of user-editable files
#IKSEMEL_CONFFILES=/opt/etc/iksemel.conf /opt/etc/init.d/SXXiksemel

#
# IKSEMEL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#IKSEMEL_PATCHES=$(IKSEMEL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
IKSEMEL_CPPFLAGS=
IKSEMEL_LDFLAGS=

#
# IKSEMEL_BUILD_DIR is the directory in which the build is done.
# IKSEMEL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# IKSEMEL_IPK_DIR is the directory in which the ipk is built.
# IKSEMEL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
IKSEMEL_BUILD_DIR=$(BUILD_DIR)/iksemel
IKSEMEL_SOURCE_DIR=$(SOURCE_DIR)/iksemel
IKSEMEL_IPK_DIR=$(BUILD_DIR)/iksemel-$(IKSEMEL_VERSION)-ipk
IKSEMEL_IPK=$(BUILD_DIR)/iksemel_$(IKSEMEL_VERSION)-$(IKSEMEL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: iksemel-source iksemel-unpack iksemel iksemel-stage iksemel-ipk iksemel-clean iksemel-dirclean iksemel-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(IKSEMEL_SOURCE):
	$(WGET) -P $(DL_DIR) $(IKSEMEL_SITE)/$(IKSEMEL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
iksemel-source: $(DL_DIR)/$(IKSEMEL_SOURCE) $(IKSEMEL_PATCHES)

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
$(IKSEMEL_BUILD_DIR)/.configured: $(DL_DIR)/$(IKSEMEL_SOURCE) $(IKSEMEL_PATCHES) make/iksemel.mk
	$(MAKE) gnutls-stage
	rm -rf $(BUILD_DIR)/$(IKSEMEL_DIR) $(IKSEMEL_BUILD_DIR)
	$(IKSEMEL_UNZIP) $(DL_DIR)/$(IKSEMEL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(IKSEMEL_PATCHES)" ; \
		then cat $(IKSEMEL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(IKSEMEL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(IKSEMEL_DIR)" != "$(IKSEMEL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(IKSEMEL_DIR) $(IKSEMEL_BUILD_DIR) ; \
	fi
	(cd $(IKSEMEL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(IKSEMEL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(IKSEMEL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-libgnutls-prefix=$(STAGING_PREFIX) \
	)
	$(PATCH_LIBTOOL) $(IKSEMEL_BUILD_DIR)/libtool
	touch $(IKSEMEL_BUILD_DIR)/.configured

iksemel-unpack: $(IKSEMEL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(IKSEMEL_BUILD_DIR)/.built: $(IKSEMEL_BUILD_DIR)/.configured
	rm -f $(IKSEMEL_BUILD_DIR)/.built
	$(MAKE) -C $(IKSEMEL_BUILD_DIR)
	touch $(IKSEMEL_BUILD_DIR)/.built

#
# This is the build convenience target.
#
iksemel: $(IKSEMEL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(IKSEMEL_BUILD_DIR)/.staged: $(IKSEMEL_BUILD_DIR)/.built
	rm -f $(IKSEMEL_BUILD_DIR)/.staged
	$(MAKE) -C $(IKSEMEL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(IKSEMEL_BUILD_DIR)/.staged

iksemel-stage: $(IKSEMEL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/iksemel
#
$(IKSEMEL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: iksemel" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(IKSEMEL_PRIORITY)" >>$@
	@echo "Section: $(IKSEMEL_SECTION)" >>$@
	@echo "Version: $(IKSEMEL_VERSION)-$(IKSEMEL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(IKSEMEL_MAINTAINER)" >>$@
	@echo "Source: $(IKSEMEL_SITE)/$(IKSEMEL_SOURCE)" >>$@
	@echo "Description: $(IKSEMEL_DESCRIPTION)" >>$@
	@echo "Depends: $(IKSEMEL_DEPENDS)" >>$@
	@echo "Suggests: $(IKSEMEL_SUGGESTS)" >>$@
	@echo "Conflicts: $(IKSEMEL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(IKSEMEL_IPK_DIR)/opt/sbin or $(IKSEMEL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(IKSEMEL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(IKSEMEL_IPK_DIR)/opt/etc/iksemel/...
# Documentation files should be installed in $(IKSEMEL_IPK_DIR)/opt/doc/iksemel/...
# Daemon startup scripts should be installed in $(IKSEMEL_IPK_DIR)/opt/etc/init.d/S??iksemel
#
# You may need to patch your application to make it use these locations.
#
$(IKSEMEL_IPK): $(IKSEMEL_BUILD_DIR)/.built
	rm -rf $(IKSEMEL_IPK_DIR) $(BUILD_DIR)/iksemel_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(IKSEMEL_BUILD_DIR) DESTDIR=$(IKSEMEL_IPK_DIR) install
	$(MAKE) $(IKSEMEL_IPK_DIR)/CONTROL/control
	for filetostrip in $(IKSEMEL_IPK_DIR)/opt/bin/ikslint \
				$(IKSEMEL_IPK_DIR)/opt/bin/iksperf \
				$(IKSEMEL_IPK_DIR)/opt/bin/iksroster \
				$(IKSEMEL_IPK_DIR)/opt/lib/libiksemel.so.* ; do \
		$(STRIP_COMMAND) $$filetostrip; \
	done
	cd $(BUILD_DIR); $(IPKG_BUILD) $(IKSEMEL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
iksemel-ipk: $(IKSEMEL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
iksemel-clean:
	rm -f $(IKSEMEL_BUILD_DIR)/.built
	-$(MAKE) -C $(IKSEMEL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
iksemel-dirclean:
	rm -rf $(BUILD_DIR)/$(IKSEMEL_DIR) $(IKSEMEL_BUILD_DIR) $(IKSEMEL_IPK_DIR) $(IKSEMEL_IPK)
#
#
# Some sanity check for the package.
#
iksemel-check: $(IKSEMEL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(IKSEMEL_IPK)
