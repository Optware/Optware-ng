###########################################################
#
# p910nd
#
###########################################################
#
# P910ND_VERSION, P910ND_SITE and P910ND_SOURCE define
# the upstream location of the source code for the package.
# P910ND_DIR is the directory which is created when the source
# archive is unpacked.
# P910ND_UNZIP is the command used to unzip the source.
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
P910ND_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/p910nd
P910ND_VERSION=0.92
P910ND_SOURCE=p910nd-$(P910ND_VERSION).tar.bz2
P910ND_DIR=p910nd-$(P910ND_VERSION)
P910ND_UNZIP=bzcat
P910ND_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
P910ND_DESCRIPTION=A small printer daemon intended that does not spool to disk but passes the job directly to the printer.
P910ND_SECTION=print
P910ND_PRIORITY=optional
P910ND_DEPENDS=
P910ND_SUGGESTS=
P910ND_CONFLICTS=

#
# P910ND_IPK_VERSION should be incremented when the ipk changes.
#
P910ND_IPK_VERSION=1

#
# P910ND_CONFFILES should be a list of user-editable files
P910ND_CONFFILES=/opt/etc/p910nd /opt/etc/init.d/S95p910nd

#
# P910ND_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#P910ND_PATCHES=$(P910ND_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
P910ND_CPPFLAGS=
P910ND_LDFLAGS=

#
# P910ND_BUILD_DIR is the directory in which the build is done.
# P910ND_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# P910ND_IPK_DIR is the directory in which the ipk is built.
# P910ND_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
P910ND_BUILD_DIR=$(BUILD_DIR)/p910nd
P910ND_SOURCE_DIR=$(SOURCE_DIR)/p910nd
P910ND_IPK_DIR=$(BUILD_DIR)/p910nd-$(P910ND_VERSION)-ipk
P910ND_IPK=$(BUILD_DIR)/p910nd_$(P910ND_VERSION)-$(P910ND_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: p910nd-source p910nd-unpack p910nd p910nd-stage p910nd-ipk p910nd-clean p910nd-dirclean p910nd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(P910ND_SOURCE):
	$(WGET) -P $(@D) $(P910ND_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
p910nd-source: $(DL_DIR)/$(P910ND_SOURCE) $(P910ND_PATCHES)

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
$(P910ND_BUILD_DIR)/.configured: $(DL_DIR)/$(P910ND_SOURCE) $(P910ND_PATCHES) make/p910nd.mk
	$(MAKE) tcpwrappers-stage
	rm -rf $(BUILD_DIR)/$(P910ND_DIR) $(@D)
	$(P910ND_UNZIP) $(DL_DIR)/$(P910ND_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(P910ND_PATCHES)" ; \
		then cat $(P910ND_PATCHES) | \
		patch -d $(BUILD_DIR)/$(P910ND_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(P910ND_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(P910ND_DIR) $(@D) ; \
	fi
	sed -i -e 's|-o $$@|& $$(CPPFLAGS) $$(LDFLAGS)|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(P910ND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(P910ND_LDFLAGS)" \
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

p910nd-unpack: $(P910ND_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(P910ND_BUILD_DIR)/.built: $(P910ND_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(P910ND_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(P910ND_LDFLAGS)" \
		LIBWRAP=-lwrap \
		BINDIR=/opt/bin \
		CONFIGDIR=/opt/etc \
		SCRIPTDIR=/opt/etc/init.d \
		MANDIR=/opt/share/man/man8 \
		;
	touch $@

#
# This is the build convenience target.
#
p910nd: $(P910ND_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(P910ND_BUILD_DIR)/.staged: $(P910ND_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#p910nd-stage: $(P910ND_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/p910nd
#
$(P910ND_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: p910nd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(P910ND_PRIORITY)" >>$@
	@echo "Section: $(P910ND_SECTION)" >>$@
	@echo "Version: $(P910ND_VERSION)-$(P910ND_IPK_VERSION)" >>$@
	@echo "Maintainer: $(P910ND_MAINTAINER)" >>$@
	@echo "Source: $(P910ND_SITE)/$(P910ND_SOURCE)" >>$@
	@echo "Description: $(P910ND_DESCRIPTION)" >>$@
	@echo "Depends: $(P910ND_DEPENDS)" >>$@
	@echo "Suggests: $(P910ND_SUGGESTS)" >>$@
	@echo "Conflicts: $(P910ND_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(P910ND_IPK_DIR)/opt/sbin or $(P910ND_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(P910ND_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(P910ND_IPK_DIR)/opt/etc/p910nd/...
# Documentation files should be installed in $(P910ND_IPK_DIR)/opt/doc/p910nd/...
# Daemon startup scripts should be installed in $(P910ND_IPK_DIR)/opt/etc/init.d/S??p910nd
#
# You may need to patch your application to make it use these locations.
#
$(P910ND_IPK): $(P910ND_BUILD_DIR)/.built
	rm -rf $(P910ND_IPK_DIR) $(BUILD_DIR)/p910nd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(P910ND_BUILD_DIR) install \
		DESTDIR=$(P910ND_IPK_DIR) \
		BINDIR=/opt/bin \
		CONFIGDIR=/opt/etc \
		SCRIPTDIR=/opt/etc/init.d \
		MANDIR=/opt/share/man/man8 \
		;
	$(STRIP_COMMAND) $(P910ND_IPK_DIR)/opt/bin/p910nd
	mv $(P910ND_IPK_DIR)/opt/etc/init.d/p910nd $(P910ND_IPK_DIR)/opt/etc/init.d/S95p910nd
	$(MAKE) $(P910ND_IPK_DIR)/CONTROL/control
	echo $(P910ND_CONFFILES) | sed -e 's/ /\n/g' > $(P910ND_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(P910ND_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
p910nd-ipk: $(P910ND_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
p910nd-clean:
	rm -f $(P910ND_BUILD_DIR)/.built
	-$(MAKE) -C $(P910ND_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
p910nd-dirclean:
	rm -rf $(BUILD_DIR)/$(P910ND_DIR) $(P910ND_BUILD_DIR) $(P910ND_IPK_DIR) $(P910ND_IPK)
#
#
# Some sanity check for the package.
#
p910nd-check: $(P910ND_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(P910ND_IPK)
