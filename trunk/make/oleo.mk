###########################################################
#
# oleo
#
###########################################################
#
# OLEO_VERSION, OLEO_SITE and OLEO_SOURCE define
# the upstream location of the source code for the package.
# OLEO_DIR is the directory which is created when the source
# archive is unpacked.
# OLEO_UNZIP is the command used to unzip the source.
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
OLEO_SITE=ftp://ftp.gnu.org/pub/gnu/oleo
OLEO_VERSION=1.99.16
OLEO_SOURCE=oleo-$(OLEO_VERSION).tar.gz
OLEO_DIR=oleo-$(OLEO_VERSION)
OLEO_UNZIP=zcat
OLEO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OLEO_DESCRIPTION=GNU Oleo is a lightweight spreadsheet application.
OLEO_SECTION=misc
OLEO_PRIORITY=optional
OLEO_DEPENDS=ncurses
OLEO_SUGGESTS=
OLEO_CONFLICTS=

#
# OLEO_IPK_VERSION should be incremented when the ipk changes.
#
OLEO_IPK_VERSION=2

#
# OLEO_CONFFILES should be a list of user-editable files
#OLEO_CONFFILES=/opt/etc/oleo.conf /opt/etc/init.d/SXXoleo

#
# OLEO_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OLEO_PATCHES=$(OLEO_SOURCE_DIR)/errno.patch \
$(OLEO_SOURCE_DIR)/cmd_funcs.patch \
$(OLEO_SOURCE_DIR)/invalid-lvalue.patch \
$(OLEO_SOURCE_DIR)/non-static-decl.patch \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OLEO_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
OLEO_LDFLAGS=

#
# OLEO_BUILD_DIR is the directory in which the build is done.
# OLEO_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OLEO_IPK_DIR is the directory in which the ipk is built.
# OLEO_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OLEO_BUILD_DIR=$(BUILD_DIR)/oleo
OLEO_SOURCE_DIR=$(SOURCE_DIR)/oleo
OLEO_IPK_DIR=$(BUILD_DIR)/oleo-$(OLEO_VERSION)-ipk
OLEO_IPK=$(BUILD_DIR)/oleo_$(OLEO_VERSION)-$(OLEO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: oleo-source oleo-unpack oleo oleo-stage oleo-ipk oleo-clean oleo-dirclean oleo-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(OLEO_SOURCE):
	$(WGET) -P $(DL_DIR) $(OLEO_SITE)/$(OLEO_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(OLEO_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
oleo-source: $(DL_DIR)/$(OLEO_SOURCE) $(OLEO_PATCHES)

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
$(OLEO_BUILD_DIR)/.configured: $(DL_DIR)/$(OLEO_SOURCE) $(OLEO_PATCHES) make/oleo.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(OLEO_DIR) $(OLEO_BUILD_DIR)
	$(OLEO_UNZIP) $(DL_DIR)/$(OLEO_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OLEO_PATCHES)" ; \
		then cat $(OLEO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(OLEO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(OLEO_DIR)" != "$(OLEO_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(OLEO_DIR) $(OLEO_BUILD_DIR) ; \
	fi
	(cd $(OLEO_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OLEO_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OLEO_LDFLAGS)" \
		ac_cv_lib_cups_cupsGetPrinters=no \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(OLEO_BUILD_DIR)/libtool
	touch $@

oleo-unpack: $(OLEO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OLEO_BUILD_DIR)/.built: $(OLEO_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(OLEO_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
oleo: $(OLEO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OLEO_BUILD_DIR)/.staged: $(OLEO_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(OLEO_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

oleo-stage: $(OLEO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/oleo
#
$(OLEO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: oleo" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OLEO_PRIORITY)" >>$@
	@echo "Section: $(OLEO_SECTION)" >>$@
	@echo "Version: $(OLEO_VERSION)-$(OLEO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OLEO_MAINTAINER)" >>$@
	@echo "Source: $(OLEO_SITE)/$(OLEO_SOURCE)" >>$@
	@echo "Description: $(OLEO_DESCRIPTION)" >>$@
	@echo "Depends: $(OLEO_DEPENDS)" >>$@
	@echo "Suggests: $(OLEO_SUGGESTS)" >>$@
	@echo "Conflicts: $(OLEO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OLEO_IPK_DIR)/opt/sbin or $(OLEO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OLEO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(OLEO_IPK_DIR)/opt/etc/oleo/...
# Documentation files should be installed in $(OLEO_IPK_DIR)/opt/doc/oleo/...
# Daemon startup scripts should be installed in $(OLEO_IPK_DIR)/opt/etc/init.d/S??oleo
#
# You may need to patch your application to make it use these locations.
#
$(OLEO_IPK): $(OLEO_BUILD_DIR)/.built
	rm -rf $(OLEO_IPK_DIR) $(BUILD_DIR)/oleo_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OLEO_BUILD_DIR) prefix=$(OLEO_IPK_DIR)/opt install
	$(STRIP_COMMAND) $(OLEO_IPK_DIR)/opt/bin/oleo
#	install -d $(OLEO_IPK_DIR)/opt/etc/
#	install -m 644 $(OLEO_SOURCE_DIR)/oleo.conf $(OLEO_IPK_DIR)/opt/etc/oleo.conf
#	install -d $(OLEO_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(OLEO_SOURCE_DIR)/rc.oleo $(OLEO_IPK_DIR)/opt/etc/init.d/SXXoleo
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OLEO_IPK_DIR)/opt/etc/init.d/SXXoleo
	$(MAKE) $(OLEO_IPK_DIR)/CONTROL/control
#	install -m 755 $(OLEO_SOURCE_DIR)/postinst $(OLEO_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OLEO_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(OLEO_SOURCE_DIR)/prerm $(OLEO_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OLEO_IPK_DIR)/CONTROL/prerm
	echo $(OLEO_CONFFILES) | sed -e 's/ /\n/g' > $(OLEO_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OLEO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
oleo-ipk: $(OLEO_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
oleo-clean:
	rm -f $(OLEO_BUILD_DIR)/.built
	-$(MAKE) -C $(OLEO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
oleo-dirclean:
	rm -rf $(BUILD_DIR)/$(OLEO_DIR) $(OLEO_BUILD_DIR) $(OLEO_IPK_DIR) $(OLEO_IPK)
#
#
# Some sanity check for the package.
#
oleo-check: $(OLEO_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OLEO_IPK)
