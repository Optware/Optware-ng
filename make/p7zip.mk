###########################################################
#
# p7zip
#
###########################################################
#
# P7ZIP_VERSION, P7ZIP_SITE and P7ZIP_SOURCE define
# the upstream location of the source code for the package.
# P7ZIP_DIR is the directory which is created when the source
# archive is unpacked.
# P7ZIP_UNZIP is the command used to unzip the source.
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
P7ZIP_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/p7zip
P7ZIP_VERSION=4.44
P7ZIP_SOURCE=p7zip_$(P7ZIP_VERSION)_src_all.tar.bz2
P7ZIP_DIR=p7zip_$(P7ZIP_VERSION)
P7ZIP_UNZIP=bzcat
P7ZIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
P7ZIP_DESCRIPTION=Command line version of 7-zip for POSIX systems.
P7ZIP_SECTION=compression
P7ZIP_PRIORITY=optional
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
P7ZIP_DEPENDS=libstdc++
endif
P7ZIP_SUGGESTS=
P7ZIP_CONFLICTS=

#
# P7ZIP_IPK_VERSION should be incremented when the ipk changes.
#
P7ZIP_IPK_VERSION=1

#
# P7ZIP_CONFFILES should be a list of user-editable files
#P7ZIP_CONFFILES=/opt/etc/p7zip.conf /opt/etc/init.d/SXXp7zip

#
# P7ZIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#P7ZIP_PATCHES=$(P7ZIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
P7ZIP_CPPFLAGS=
P7ZIP_LDFLAGS=

#
# P7ZIP_BUILD_DIR is the directory in which the build is done.
# P7ZIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# P7ZIP_IPK_DIR is the directory in which the ipk is built.
# P7ZIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
P7ZIP_BUILD_DIR=$(BUILD_DIR)/p7zip
P7ZIP_SOURCE_DIR=$(SOURCE_DIR)/p7zip
P7ZIP_IPK_DIR=$(BUILD_DIR)/p7zip-$(P7ZIP_VERSION)-ipk
P7ZIP_IPK=$(BUILD_DIR)/p7zip_$(P7ZIP_VERSION)-$(P7ZIP_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: p7zip-source p7zip-unpack p7zip p7zip-stage p7zip-ipk p7zip-clean p7zip-dirclean p7zip-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(P7ZIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(P7ZIP_SITE)/$(P7ZIP_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(P7ZIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
p7zip-source: $(DL_DIR)/$(P7ZIP_SOURCE) $(P7ZIP_PATCHES)

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
$(P7ZIP_BUILD_DIR)/.configured: $(DL_DIR)/$(P7ZIP_SOURCE) $(P7ZIP_PATCHES) make/p7zip.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	rm -rf $(BUILD_DIR)/$(P7ZIP_DIR) $(P7ZIP_BUILD_DIR)
	$(P7ZIP_UNZIP) $(DL_DIR)/$(P7ZIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(P7ZIP_PATCHES)" ; \
		then cat $(P7ZIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(P7ZIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(P7ZIP_DIR)" != "$(P7ZIP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(P7ZIP_DIR) $(P7ZIP_BUILD_DIR) ; \
	fi
	sed -i.orig -e '/DEST_.*DEST_.*DEST_/s|$$| $$(DEST_DIR)|' $(P7ZIP_BUILD_DIR)/makefile
	sed -i.orig -e 's|^DEST_HOME=.*|DEST_HOME=/opt|' $(P7ZIP_BUILD_DIR)/install.sh
#	(cd $(P7ZIP_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(P7ZIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(P7ZIP_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(P7ZIP_BUILD_DIR)/libtool
	touch $@

p7zip-unpack: $(P7ZIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(P7ZIP_BUILD_DIR)/.built: $(P7ZIP_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(P7ZIP_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(P7ZIP_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(P7ZIP_LDFLAGS)" \
		CXX='$(TARGET_CXX) $$(ALLFLAGS)' \
		CC='$(TARGET_CC) $$(ALLFLAGS)' \
		;
	touch $@

#
# This is the build convenience target.
#
p7zip: $(P7ZIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(P7ZIP_BUILD_DIR)/.staged: $(P7ZIP_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(P7ZIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

p7zip-stage: $(P7ZIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/p7zip
#
$(P7ZIP_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: p7zip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(P7ZIP_PRIORITY)" >>$@
	@echo "Section: $(P7ZIP_SECTION)" >>$@
	@echo "Version: $(P7ZIP_VERSION)-$(P7ZIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(P7ZIP_MAINTAINER)" >>$@
	@echo "Source: $(P7ZIP_SITE)/$(P7ZIP_SOURCE)" >>$@
	@echo "Description: $(P7ZIP_DESCRIPTION)" >>$@
	@echo "Depends: $(P7ZIP_DEPENDS)" >>$@
	@echo "Suggests: $(P7ZIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(P7ZIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(P7ZIP_IPK_DIR)/opt/sbin or $(P7ZIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(P7ZIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(P7ZIP_IPK_DIR)/opt/etc/p7zip/...
# Documentation files should be installed in $(P7ZIP_IPK_DIR)/opt/doc/p7zip/...
# Daemon startup scripts should be installed in $(P7ZIP_IPK_DIR)/opt/etc/init.d/S??p7zip
#
# You may need to patch your application to make it use these locations.
#
$(P7ZIP_IPK): $(P7ZIP_BUILD_DIR)/.built
	rm -rf $(P7ZIP_IPK_DIR) $(BUILD_DIR)/p7zip_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(P7ZIP_BUILD_DIR) install \
		DEST_DIR=$(P7ZIP_IPK_DIR) \
		DEST_BIN=/opt/bin \
		DEST_BIN=/opt/bin \
		DEST_SHARE=/opt/lib/p7zip \
		DEST_MAN=/opt/man \
	;
	chmod -R +w $(P7ZIP_IPK_DIR)/opt
#	install -d $(P7ZIP_IPK_DIR)/opt/etc/
#	install -m 644 $(P7ZIP_SOURCE_DIR)/p7zip.conf $(P7ZIP_IPK_DIR)/opt/etc/p7zip.conf
#	install -d $(P7ZIP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(P7ZIP_SOURCE_DIR)/rc.p7zip $(P7ZIP_IPK_DIR)/opt/etc/init.d/SXXp7zip
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(P7ZIP_IPK_DIR)/opt/etc/init.d/SXXp7zip
	$(MAKE) $(P7ZIP_IPK_DIR)/CONTROL/control
#	install -m 755 $(P7ZIP_SOURCE_DIR)/postinst $(P7ZIP_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(P7ZIP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(P7ZIP_SOURCE_DIR)/prerm $(P7ZIP_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(P7ZIP_IPK_DIR)/CONTROL/prerm
	echo $(P7ZIP_CONFFILES) | sed -e 's/ /\n/g' > $(P7ZIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(P7ZIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
p7zip-ipk: $(P7ZIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
p7zip-clean:
	rm -f $(P7ZIP_BUILD_DIR)/.built
	-$(MAKE) -C $(P7ZIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
p7zip-dirclean:
	rm -rf $(BUILD_DIR)/$(P7ZIP_DIR) $(P7ZIP_BUILD_DIR) $(P7ZIP_IPK_DIR) $(P7ZIP_IPK)
#
#
# Some sanity check for the package.
#
p7zip-check: $(P7ZIP_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(P7ZIP_IPK)
