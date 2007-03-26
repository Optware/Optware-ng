###########################################################
#
# aspell
#
###########################################################
#
# ASPELL_VERSION, ASPELL_SITE and ASPELL_SOURCE define
# the upstream location of the source code for the package.
# ASPELL_DIR is the directory which is created when the source
# archive is unpacked.
# ASPELL_UNZIP is the command used to unzip the source.
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
# http://aspell.net/
# dictionaries at ftp://ftp.gnu.org/gnu/aspell/dict/0index.html
#
ASPELL_SITE=ftp://ftp.gnu.org/gnu/aspell
ASPELL_VERSION=0.60.5
ASPELL_SOURCE=aspell-$(ASPELL_VERSION).tar.gz
ASPELL_DIR=aspell-$(ASPELL_VERSION)
ASPELL_UNZIP=zcat
ASPELL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASPELL_DESCRIPTION=Spell checker
ASPELL_SECTION=text
ASPELL_PRIORITY=optional
ASPELL_DEPENDS=$(NCURSES_FOR_OPTWARE_TARGET),libstdc++
ASPELL_SUGGESTS=make
ASPELL_CONFLICTS=

#
# ASPELL_IPK_VERSION should be incremented when the ipk changes.
#
ASPELL_IPK_VERSION=1

#
# ASPELL_CONFFILES should be a list of user-editable files
ASPELL_CONFFILES=/opt/etc/aspell.conf

#
# ASPELL_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#ASPELL_PATCHES=$(ASPELL_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASPELL_CPPFLAGS=
ASPELL_LDFLAGS=-lm

#
# ASPELL_BUILD_DIR is the directory in which the build is done.
# ASPELL_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASPELL_IPK_DIR is the directory in which the ipk is built.
# ASPELL_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASPELL_BUILD_DIR=$(BUILD_DIR)/aspell
ASPELL_SOURCE_DIR=$(SOURCE_DIR)/aspell
ASPELL_IPK_DIR=$(BUILD_DIR)/aspell-$(ASPELL_VERSION)-ipk
ASPELL_IPK=$(BUILD_DIR)/aspell_$(ASPELL_VERSION)-$(ASPELL_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: aspell-source aspell-unpack aspell aspell-stage aspell-ipk aspell-clean aspell-dirclean aspell-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASPELL_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASPELL_SITE)/$(ASPELL_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(ASPELL_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
aspell-source: $(DL_DIR)/$(ASPELL_SOURCE) $(ASPELL_PATCHES)

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
$(ASPELL_BUILD_DIR)/.configured: $(DL_DIR)/$(ASPELL_SOURCE) $(ASPELL_PATCHES) make/aspell.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(ASPELL_DIR) $(ASPELL_BUILD_DIR)
	$(ASPELL_UNZIP) $(DL_DIR)/$(ASPELL_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASPELL_PATCHES)" ; \
		then cat $(ASPELL_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASPELL_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(ASPELL_DIR)" != "$(ASPELL_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASPELL_DIR) $(ASPELL_BUILD_DIR) ; \
	fi
	(cd $(ASPELL_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(ASPELL_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(ASPELL_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--program-transform-name='' \
	)
	$(PATCH_LIBTOOL) $(ASPELL_BUILD_DIR)/libtool
	touch $@

aspell-unpack: $(ASPELL_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASPELL_BUILD_DIR)/.built: $(ASPELL_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(ASPELL_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
aspell: $(ASPELL_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASPELL_BUILD_DIR)/.staged: $(ASPELL_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(ASPELL_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

aspell-stage: $(ASPELL_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/aspell
#
$(ASPELL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: aspell" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASPELL_PRIORITY)" >>$@
	@echo "Section: $(ASPELL_SECTION)" >>$@
	@echo "Version: $(ASPELL_VERSION)-$(ASPELL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASPELL_MAINTAINER)" >>$@
	@echo "Source: $(ASPELL_SITE)/$(ASPELL_SOURCE)" >>$@
	@echo "Description: $(ASPELL_DESCRIPTION)" >>$@
	@echo "Depends: $(ASPELL_DEPENDS)" >>$@
	@echo "Suggests: $(ASPELL_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASPELL_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASPELL_IPK_DIR)/opt/sbin or $(ASPELL_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASPELL_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASPELL_IPK_DIR)/opt/etc/aspell/...
# Documentation files should be installed in $(ASPELL_IPK_DIR)/opt/doc/aspell/...
# Daemon startup scripts should be installed in $(ASPELL_IPK_DIR)/opt/etc/init.d/S??aspell
#
# You may need to patch your application to make it use these locations.
#
$(ASPELL_IPK): $(ASPELL_BUILD_DIR)/.built
	rm -rf $(ASPELL_IPK_DIR) $(BUILD_DIR)/aspell_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASPELL_BUILD_DIR) DESTDIR=$(ASPELL_IPK_DIR) install-strip
	install -d $(ASPELL_IPK_DIR)/opt/etc/
	install -m 644 $(ASPELL_SOURCE_DIR)/aspell.conf $(ASPELL_IPK_DIR)/opt/etc/aspell.conf
#	install -d $(ASPELL_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(ASPELL_SOURCE_DIR)/rc.aspell $(ASPELL_IPK_DIR)/opt/etc/init.d/SXXaspell
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ASPELL_IPK_DIR)/opt/etc/init.d/SXXaspell
	$(MAKE) $(ASPELL_IPK_DIR)/CONTROL/control
	install -m 755 $(ASPELL_SOURCE_DIR)/postinst $(ASPELL_IPK_DIR)/CONTROL/postinst
	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ASPELL_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(ASPELL_SOURCE_DIR)/prerm $(ASPELL_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(ASPELL_IPK_DIR)/CONTROL/prerm
	echo $(ASPELL_CONFFILES) | sed -e 's/ /\n/g' > $(ASPELL_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASPELL_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
aspell-ipk: $(ASPELL_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
aspell-clean:
	rm -f $(ASPELL_BUILD_DIR)/.built
	-$(MAKE) -C $(ASPELL_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
aspell-dirclean:
	rm -rf $(BUILD_DIR)/$(ASPELL_DIR) $(ASPELL_BUILD_DIR) $(ASPELL_IPK_DIR) $(ASPELL_IPK)
#
#
# Some sanity check for the package.
#
aspell-check: $(ASPELL_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(ASPELL_IPK)
