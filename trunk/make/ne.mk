###########################################################
#
# ne
#
###########################################################
#
# NE_VERSION, NE_SITE and NE_SOURCE define
# the upstream location of the source code for the package.
# NE_DIR is the directory which is created when the source
# archive is unpacked.
# NE_UNZIP is the command used to unzip the source.
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
NE_SITE=http://ne.dsi.unimi.it
NE_VERSION=1.43
NE_SOURCE=ne-$(NE_VERSION).tar.gz
NE_DIR=ne-$(NE_VERSION)
NE_UNZIP=zcat
NE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
NE_DESCRIPTION=The nice editor.
NE_SECTION=editor
NE_PRIORITY=optional
NE_DEPENDS=ncurses
NE_SUGGESTS=
NE_CONFLICTS=

#
# NE_IPK_VERSION should be incremented when the ipk changes.
#
NE_IPK_VERSION=1

#
# NE_CONFFILES should be a list of user-editable files
#NE_CONFFILES=/opt/etc/ne.conf /opt/etc/init.d/SXXne

#
# NE_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#NE_PATCHES=$(NE_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
NE_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
NE_LDFLAGS=

NE_MAKE_OPTS=
ifeq ($(OPTWARE_TARGET), wl500g)
NE_MAKE_OPTS+=NE_NOWCHAR=1
endif

#
# NE_BUILD_DIR is the directory in which the build is done.
# NE_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# NE_IPK_DIR is the directory in which the ipk is built.
# NE_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
NE_BUILD_DIR=$(BUILD_DIR)/ne
NE_SOURCE_DIR=$(SOURCE_DIR)/ne
NE_IPK_DIR=$(BUILD_DIR)/ne-$(NE_VERSION)-ipk
NE_IPK=$(BUILD_DIR)/ne_$(NE_VERSION)-$(NE_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: ne-source ne-unpack ne ne-stage ne-ipk ne-clean ne-dirclean ne-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(NE_SOURCE):
	$(WGET) -P $(DL_DIR) $(NE_SITE)/$(NE_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(NE_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ne-source: $(DL_DIR)/$(NE_SOURCE) $(NE_PATCHES)

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
$(NE_BUILD_DIR)/.configured: $(DL_DIR)/$(NE_SOURCE) $(NE_PATCHES) make/ne.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(NE_DIR) $(NE_BUILD_DIR)
	$(NE_UNZIP) $(DL_DIR)/$(NE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(NE_PATCHES)" ; \
		then cat $(NE_PATCHES) | \
		patch -d $(BUILD_DIR)/$(NE_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(NE_DIR)" != "$(NE_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(NE_DIR) $(NE_BUILD_DIR) ; \
	fi
#	(cd $(NE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NE_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(NE_BUILD_DIR)/libtool
	touch $@

ne-unpack: $(NE_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(NE_BUILD_DIR)/.built: $(NE_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(NE_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(NE_CPPFLAGS)" \
		OPTS="$(STAGING_CPPFLAGS) $(NE_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(NE_LDFLAGS)" \
		LIBS=-lncurses \
		$(NE_MAKE_OPTS) \
		;
	touch $@

#
# This is the build convenience target.
#
ne: $(NE_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(NE_BUILD_DIR)/.staged: $(NE_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(NE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

ne-stage: $(NE_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ne
#
$(NE_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ne" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(NE_PRIORITY)" >>$@
	@echo "Section: $(NE_SECTION)" >>$@
	@echo "Version: $(NE_VERSION)-$(NE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(NE_MAINTAINER)" >>$@
	@echo "Source: $(NE_SITE)/$(NE_SOURCE)" >>$@
	@echo "Description: $(NE_DESCRIPTION)" >>$@
	@echo "Depends: $(NE_DEPENDS)" >>$@
	@echo "Suggests: $(NE_SUGGESTS)" >>$@
	@echo "Conflicts: $(NE_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(NE_IPK_DIR)/opt/sbin or $(NE_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(NE_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(NE_IPK_DIR)/opt/etc/ne/...
# Documentation files should be installed in $(NE_IPK_DIR)/opt/doc/ne/...
# Daemon startup scripts should be installed in $(NE_IPK_DIR)/opt/etc/init.d/S??ne
#
# You may need to patch your application to make it use these locations.
#
$(NE_IPK): $(NE_BUILD_DIR)/.built
	rm -rf $(NE_IPK_DIR) $(BUILD_DIR)/ne_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(NE_BUILD_DIR) DESTDIR=$(NE_IPK_DIR) install-strip
	install -d $(NE_IPK_DIR)/opt/bin
	install -m 755 $(NE_BUILD_DIR)/src/ne $(NE_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(NE_IPK_DIR)/opt/bin/ne
	install -d $(NE_IPK_DIR)/opt/share/doc/ne
	cp -rp $(NE_BUILD_DIR)/doc/* $(NE_IPK_DIR)/opt/share/doc/ne
	install -d $(NE_IPK_DIR)/opt/share/man/man1
	mv $(NE_IPK_DIR)/opt/share/doc/ne/*.1 $(NE_IPK_DIR)/opt/share/man/man1/
	install -d $(NE_IPK_DIR)/opt/share/info
	mv $(NE_IPK_DIR)/opt/share/doc/ne/*.info.gz $(NE_IPK_DIR)/opt/share/info/
#	install -d $(NE_IPK_DIR)/opt/etc/
#	install -m 644 $(NE_SOURCE_DIR)/ne.conf $(NE_IPK_DIR)/opt/etc/ne.conf
#	install -d $(NE_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(NE_SOURCE_DIR)/rc.ne $(NE_IPK_DIR)/opt/etc/init.d/SXXne
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NE_IPK_DIR)/opt/etc/init.d/SXXne
	$(MAKE) $(NE_IPK_DIR)/CONTROL/control
#	install -m 755 $(NE_SOURCE_DIR)/postinst $(NE_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NE_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(NE_SOURCE_DIR)/prerm $(NE_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(NE_IPK_DIR)/CONTROL/prerm
	echo $(NE_CONFFILES) | sed -e 's/ /\n/g' > $(NE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(NE_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ne-ipk: $(NE_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ne-clean:
	rm -f $(NE_BUILD_DIR)/.built
	-$(MAKE) -C $(NE_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ne-dirclean:
	rm -rf $(BUILD_DIR)/$(NE_DIR) $(NE_BUILD_DIR) $(NE_IPK_DIR) $(NE_IPK)
#
#
# Some sanity check for the package.
#
ne-check: $(NE_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(NE_IPK)
