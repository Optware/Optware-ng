###########################################################
#
# ink
#
###########################################################
#
# INK_VERSION, INK_SITE and INK_SOURCE define
# the upstream location of the source code for the package.
# INK_DIR is the directory which is created when the source
# archive is unpacked.
# INK_UNZIP is the command used to unzip the source.
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
INK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/ink
INK_VERSION=0.4.1
INK_SOURCE=ink-$(INK_VERSION).tar.gz
INK_DIR=ink-$(INK_VERSION)
INK_UNZIP=zcat
INK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INK_DESCRIPTION=Ink is a command line tool for checking the ink level of your locally connected printer.
INK_SECTION=print
INK_PRIORITY=optional
INK_DEPENDS=libinklevel
INK_SUGGESTS=
INK_CONFLICTS=

#
# INK_IPK_VERSION should be incremented when the ipk changes.
#
INK_IPK_VERSION=1

#
# INK_CONFFILES should be a list of user-editable files
#INK_CONFFILES=/opt/etc/ink.conf /opt/etc/init.d/SXXink

#
# INK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#INK_PATCHES=$(INK_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
INK_CPPFLAGS=
INK_LDFLAGS=-linklevel
#
# INK_BUILD_DIR is the directory in which the build is done.
# INK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# INK_IPK_DIR is the directory in which the ipk is built.
# INK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
INK_BUILD_DIR=$(BUILD_DIR)/ink
INK_SOURCE_DIR=$(SOURCE_DIR)/ink
INK_IPK_DIR=$(BUILD_DIR)/ink-$(INK_VERSION)-ipk
INK_IPK=$(BUILD_DIR)/ink_$(INK_VERSION)-$(INK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ink-source ink-unpack ink ink-stage ink-ipk ink-clean ink-dirclean ink-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(INK_SOURCE):
	$(WGET) -P $(@D) $(INK_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ink-source: $(DL_DIR)/$(INK_SOURCE) $(INK_PATCHES)

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
$(INK_BUILD_DIR)/.configured: $(DL_DIR)/$(INK_SOURCE) $(INK_PATCHES) make/ink.mk
	$(MAKE) libinklevel-stage
	rm -rf $(BUILD_DIR)/$(INK_DIR) $(@D)
	$(INK_UNZIP) $(DL_DIR)/$(INK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(INK_PATCHES)" ; \
		then cat $(INK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(INK_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(INK_DIR) $(@D) ; \
	fi
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(INK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

ink-unpack: $(INK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INK_BUILD_DIR)/.built: $(INK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		PREFIX=/opt \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(INK_CPPFLAGS)" \
		CFLAGS=-Wall \
		LDFLAGS="$(STAGING_LDFLAGS) $(INK_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
ink: $(INK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(INK_BUILD_DIR)/.staged: $(INK_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#ink-stage: $(INK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ink
#
$(INK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ink" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INK_PRIORITY)" >>$@
	@echo "Section: $(INK_SECTION)" >>$@
	@echo "Version: $(INK_VERSION)-$(INK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INK_MAINTAINER)" >>$@
	@echo "Source: $(INK_SITE)/$(INK_SOURCE)" >>$@
	@echo "Description: $(INK_DESCRIPTION)" >>$@
	@echo "Depends: $(INK_DEPENDS)" >>$@
	@echo "Suggests: $(INK_SUGGESTS)" >>$@
	@echo "Conflicts: $(INK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INK_IPK_DIR)/opt/sbin or $(INK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INK_IPK_DIR)/opt/etc/ink/...
# Documentation files should be installed in $(INK_IPK_DIR)/opt/doc/ink/...
# Daemon startup scripts should be installed in $(INK_IPK_DIR)/opt/etc/init.d/S??ink
#
# You may need to patch your application to make it use these locations.
#
$(INK_IPK): $(INK_BUILD_DIR)/.built
	rm -rf $(INK_IPK_DIR) $(BUILD_DIR)/ink_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(INK_BUILD_DIR) install DESTDIR=$(INK_IPK_DIR)/opt
	install -d $(INK_IPK_DIR)/opt/bin
	install -m 755 $(INK_BUILD_DIR)/ink $(INK_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(INK_IPK_DIR)/opt/bin/ink
	$(MAKE) $(INK_IPK_DIR)/CONTROL/control
	echo $(INK_CONFFILES) | sed -e 's/ /\n/g' > $(INK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ink-ipk: $(INK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ink-clean:
	rm -f $(INK_BUILD_DIR)/.built
	-$(MAKE) -C $(INK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ink-dirclean:
	rm -rf $(BUILD_DIR)/$(INK_DIR) $(INK_BUILD_DIR) $(INK_IPK_DIR) $(INK_IPK)
#
#
# Some sanity check for the package.
#
ink-check: $(INK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(INK_IPK)
