###########################################################
#
# owwlog
#
###########################################################

# You must replace "owwlog" and "OWWLOG" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# OWWLOG_VERSION, OWWLOG_SITE and OWWLOG_SOURCE define
# the upstream location of the source code for the package.
# OWWLOG_DIR is the directory which is created when the source
# archive is unpacked.
# OWWLOG_UNZIP is the command used to unzip the source.
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
OWWLOG_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/oww
#OWWLOG_VERSION=0.3.12
#OWWLOG_SITE=http://localhost/~sjm/owwlog
OWWLOG_VERSION=0.3.15
OWWLOG_SOURCE=owwlog-$(OWWLOG_VERSION).tar.gz
OWWLOG_DIR=owwlog-$(OWWLOG_VERSION)
OWWLOG_UNZIP=zcat
OWWLOG_MAINTAINER=Simon Melhuish - simon@melhuish.info
OWWLOG_DESCRIPTION=Owwlog logs data from Owwl protocol servers, such as oww.
OWWLOG_SECTION=extras
OWWLOG_PRIORITY=optional
OWWLOG_DEPENDS=gsl, popt
OWWLOG_SUGGESTS=
OWWLOG_CONFLICTS=

#
# OWWLOG_IPK_VERSION should be incremented when the ipk changes.
#
OWWLOG_IPK_VERSION=1

#
# OWWLOG_CONFFILES should be a list of user-editable files
#OWWLOG_CONFFILES=/opt/etc/owwlog.conf /opt/etc/init.d/SXXowwlog

#
# OWWLOG_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OWWLOG_PATCHES=$(OWWLOG_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OWWLOG_CPPFLAGS=
OWWLOG_LDFLAGS=

#
# OWWLOG_BUILD_DIR is the directory in which the build is done.
# OWWLOG_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OWWLOG_IPK_DIR is the directory in which the ipk is built.
# OWWLOG_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OWWLOG_BUILD_DIR=$(BUILD_DIR)/owwlog
OWWLOG_SOURCE_DIR=$(SOURCE_DIR)/owwlog
OWWLOG_IPK_DIR=$(BUILD_DIR)/owwlog-$(OWWLOG_VERSION)-ipk
OWWLOG_IPK=$(BUILD_DIR)/owwlog_$(OWWLOG_VERSION)-$(OWWLOG_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: owwlog-source owwlog-unpack owwlog owwlog-stage owwlog-ipk owwlog-clean owwlog-dirclean owwlog-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OWWLOG_SOURCE):
	$(WGET) -P $(DL_DIR) $(OWWLOG_SITE)/$(OWWLOG_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
owwlog-source: $(DL_DIR)/$(OWWLOG_SOURCE) $(OWWLOG_PATCHES)

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
$(OWWLOG_BUILD_DIR)/.configured: $(DL_DIR)/$(OWWLOG_SOURCE) $(OWWLOG_PATCHES) make/owwlog.mk
	$(MAKE) gsl-stage popt-stage
	rm -rf $(BUILD_DIR)/$(OWWLOG_DIR) $(OWWLOG_BUILD_DIR)
	$(OWWLOG_UNZIP) $(DL_DIR)/$(OWWLOG_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OWWLOG_PATCHES)" ; \
		then cat $(OWWLOG_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OWWLOG_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OWWLOG_DIR)" != "$(OWWLOG_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OWWLOG_DIR) $(OWWLOG_BUILD_DIR) ; \
	fi
	(cd $(OWWLOG_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OWWLOG_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OWWLOG_LDFLAGS)" \
		GSL_CONFIG="$(STAGING_DIR)/opt/bin/gsl-config" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(OWWLOG_BUILD_DIR)/libtool
	touch $(OWWLOG_BUILD_DIR)/.configured

owwlog-unpack: $(OWWLOG_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OWWLOG_BUILD_DIR)/.built: $(OWWLOG_BUILD_DIR)/.configured
	rm -f $(OWWLOG_BUILD_DIR)/.built
	$(MAKE) -C $(OWWLOG_BUILD_DIR)
	touch $(OWWLOG_BUILD_DIR)/.built

#
# This is the build convenience target.
#
owwlog: $(OWWLOG_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OWWLOG_BUILD_DIR)/.staged: $(OWWLOG_BUILD_DIR)/.built
	rm -f $(OWWLOG_BUILD_DIR)/.staged
	$(MAKE) -C $(OWWLOG_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(OWWLOG_BUILD_DIR)/.staged

owwlog-stage: $(OWWLOG_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/owwlog
#
$(OWWLOG_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: owwlog" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OWWLOG_PRIORITY)" >>$@
	@echo "Section: $(OWWLOG_SECTION)" >>$@
	@echo "Version: $(OWWLOG_VERSION)-$(OWWLOG_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OWWLOG_MAINTAINER)" >>$@
	@echo "Source: $(OWWLOG_SITE)/$(OWWLOG_SOURCE)" >>$@
	@echo "Description: $(OWWLOG_DESCRIPTION)" >>$@
	@echo "Depends: $(OWWLOG_DEPENDS)" >>$@
	@echo "Suggests: $(OWWLOG_SUGGESTS)" >>$@
	@echo "Conflicts: $(OWWLOG_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OWWLOG_IPK_DIR)/opt/sbin or $(OWWLOG_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OWWLOG_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OWWLOG_IPK_DIR)/opt/etc/owwlog/...
# Documentation files should be installed in $(OWWLOG_IPK_DIR)/opt/doc/owwlog/...
# Daemon startup scripts should be installed in $(OWWLOG_IPK_DIR)/opt/etc/init.d/S??owwlog
#
# You may need to patch your application to make it use these locations.
#
$(OWWLOG_IPK): $(OWWLOG_BUILD_DIR)/.built
	rm -rf $(OWWLOG_IPK_DIR) $(BUILD_DIR)/owwlog_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OWWLOG_BUILD_DIR) DESTDIR=$(OWWLOG_IPK_DIR) install-strip
#	install -d $(OWWLOG_IPK_DIR)/opt/etc/
#	install -m 644 $(OWWLOG_SOURCE_DIR)/owwlog.conf $(OWWLOG_IPK_DIR)/opt/etc/owwlog.conf
#	install -d $(OWWLOG_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OWWLOG_SOURCE_DIR)/rc.owwlog $(OWWLOG_IPK_DIR)/opt/etc/init.d/SXXowwlog
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXowwlog
	$(MAKE) $(OWWLOG_IPK_DIR)/CONTROL/control
#	install -m 755 $(OWWLOG_SOURCE_DIR)/postinst $(OWWLOG_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OWWLOG_SOURCE_DIR)/prerm $(OWWLOG_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(OWWLOG_CONFFILES) | sed -e 's/ /\n/g' > $(OWWLOG_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OWWLOG_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
owwlog-ipk: $(OWWLOG_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
owwlog-clean:
	rm -f $(OWWLOG_BUILD_DIR)/.built
	-$(MAKE) -C $(OWWLOG_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
owwlog-dirclean:
	rm -rf $(BUILD_DIR)/$(OWWLOG_DIR) $(OWWLOG_BUILD_DIR) $(OWWLOG_IPK_DIR) $(OWWLOG_IPK)
#
#
# Some sanity check for the package.
#
owwlog-check: $(OWWLOG_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OWWLOG_IPK)
