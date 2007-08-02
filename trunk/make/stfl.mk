###########################################################
#
# stfl
#
###########################################################
#
# STFL_VERSION, STFL_SITE and STFL_SOURCE define
# the upstream location of the source code for the package.
# STFL_DIR is the directory which is created when the source
# archive is unpacked.
# STFL_UNZIP is the command used to unzip the source.
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
STFL_SITE=http://www.clifford.at/stfl
STFL_VERSION=0.15
STFL_SOURCE=stfl-$(STFL_VERSION).tar.gz
STFL_DIR=stfl-$(STFL_VERSION)
STFL_UNZIP=zcat
STFL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
STFL_DESCRIPTION=Structured Terminal Forms Language/Library, a library which implements a curses-based widget set for text terminals.
STFL_SECTION=console
STFL_PRIORITY=optional
STFL_DEPENDS=
STFL_SUGGESTS=
STFL_CONFLICTS=

#
# STFL_IPK_VERSION should be incremented when the ipk changes.
#
STFL_IPK_VERSION=1

#
# STFL_CONFFILES should be a list of user-editable files
#STFL_CONFFILES=/opt/etc/stfl.conf /opt/etc/init.d/SXXstfl

#
# STFL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#STFL_PATCHES=$(STFL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
#STFL_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
STFL_CPPFLAGS=
STFL_LDFLAGS=-L.

#
# STFL_BUILD_DIR is the directory in which the build is done.
# STFL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# STFL_IPK_DIR is the directory in which the ipk is built.
# STFL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
STFL_BUILD_DIR=$(BUILD_DIR)/stfl
STFL_SOURCE_DIR=$(SOURCE_DIR)/stfl
STFL_IPK_DIR=$(BUILD_DIR)/stfl-$(STFL_VERSION)-ipk
STFL_IPK=$(BUILD_DIR)/stfl_$(STFL_VERSION)-$(STFL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: stfl-source stfl-unpack stfl stfl-stage stfl-ipk stfl-clean stfl-dirclean stfl-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(STFL_SOURCE):
	$(WGET) -P $(DL_DIR) $(STFL_SITE)/$(STFL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(STFL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
stfl-source: $(DL_DIR)/$(STFL_SOURCE) $(STFL_PATCHES)

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
$(STFL_BUILD_DIR)/.configured: $(DL_DIR)/$(STFL_SOURCE) $(STFL_PATCHES) make/stfl.mk
	$(MAKE) ncursesw-stage
	rm -rf $(BUILD_DIR)/$(STFL_DIR) $(STFL_BUILD_DIR)
	$(STFL_UNZIP) $(DL_DIR)/$(STFL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(STFL_PATCHES)" ; \
		then cat $(STFL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(STFL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(STFL_DIR)" != "$(STFL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(STFL_DIR) $(STFL_BUILD_DIR) ; \
	fi
#	(cd $(STFL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STFL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(STFL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(STFL_BUILD_DIR)/libtool
	touch $@

stfl-unpack: $(STFL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(STFL_BUILD_DIR)/.built: $(STFL_BUILD_DIR)/.configured
	rm -f $@
#		LDLIBS=-lncurses
	$(MAKE) -C $(STFL_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(STFL_CPPFLAGS)" \
		LDFLAGS="$(STFL_LDFLAGS) $(STAGING_LDFLAGS)" \
		prefix=/opt \
		;
	touch $@

#
# This is the build convenience target.
#
stfl: $(STFL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(STFL_BUILD_DIR)/.staged: $(STFL_BUILD_DIR)/.built
	rm -f $@
	rm -f $(STAGING_INCLUDE_DIR)/stfl.h
	rm -f $(STAGING_LIB_DIR)/libstfl*.a
	$(MAKE) -C $(STFL_BUILD_DIR) DESTDIR=$(STAGING_DIR) prefix=/opt install
	touch $@

stfl-stage: $(STFL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/stfl
#
$(STFL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: stfl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(STFL_PRIORITY)" >>$@
	@echo "Section: $(STFL_SECTION)" >>$@
	@echo "Version: $(STFL_VERSION)-$(STFL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(STFL_MAINTAINER)" >>$@
	@echo "Source: $(STFL_SITE)/$(STFL_SOURCE)" >>$@
	@echo "Description: $(STFL_DESCRIPTION)" >>$@
	@echo "Depends: $(STFL_DEPENDS)" >>$@
	@echo "Suggests: $(STFL_SUGGESTS)" >>$@
	@echo "Conflicts: $(STFL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(STFL_IPK_DIR)/opt/sbin or $(STFL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(STFL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(STFL_IPK_DIR)/opt/etc/stfl/...
# Documentation files should be installed in $(STFL_IPK_DIR)/opt/doc/stfl/...
# Daemon startup scripts should be installed in $(STFL_IPK_DIR)/opt/etc/init.d/S??stfl
#
# You may need to patch your application to make it use these locations.
#
$(STFL_IPK): $(STFL_BUILD_DIR)/.built
	rm -rf $(STFL_IPK_DIR) $(BUILD_DIR)/stfl_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(STFL_BUILD_DIR) DESTDIR=$(STFL_IPK_DIR) prefix=/opt install
#	install -d $(STFL_IPK_DIR)/opt/etc/
#	install -m 644 $(STFL_SOURCE_DIR)/stfl.conf $(STFL_IPK_DIR)/opt/etc/stfl.conf
#	install -d $(STFL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(STFL_SOURCE_DIR)/rc.stfl $(STFL_IPK_DIR)/opt/etc/init.d/SXXstfl
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STFL_IPK_DIR)/opt/etc/init.d/SXXstfl
	$(MAKE) $(STFL_IPK_DIR)/CONTROL/control
#	install -m 755 $(STFL_SOURCE_DIR)/postinst $(STFL_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STFL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(STFL_SOURCE_DIR)/prerm $(STFL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(STFL_IPK_DIR)/CONTROL/prerm
	echo $(STFL_CONFFILES) | sed -e 's/ /\n/g' > $(STFL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(STFL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
stfl-ipk: $(STFL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
stfl-clean:
	rm -f $(STFL_BUILD_DIR)/.built
	-$(MAKE) -C $(STFL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
stfl-dirclean:
	rm -rf $(BUILD_DIR)/$(STFL_DIR) $(STFL_BUILD_DIR) $(STFL_IPK_DIR) $(STFL_IPK)
#
#
# Some sanity check for the package.
#
stfl-check: $(STFL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(STFL_IPK)
