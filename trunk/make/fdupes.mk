###########################################################
#
# fdupes
#
###########################################################
#
# FDUPES_VERSION, FDUPES_SITE and FDUPES_SOURCE define
# the upstream location of the source code for the package.
# FDUPES_DIR is the directory which is created when the source
# archive is unpacked.
# FDUPES_UNZIP is the command used to unzip the source.
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
FDUPES_SITE=http://netdial.caribe.net/~adrian2/programs
FDUPES_VERSION=1.40
FDUPES_SOURCE=fdupes-$(FDUPES_VERSION).tar.gz
FDUPES_DIR=fdupes-$(FDUPES_VERSION)
FDUPES_UNZIP=zcat
FDUPES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FDUPES_DESCRIPTION=FDUPES is a program for identifying or deleting duplicate files residing within specified directories.
FDUPES_SECTION=utils
FDUPES_PRIORITY=optional
FDUPES_DEPENDS=
FDUPES_SUGGESTS=
FDUPES_CONFLICTS=

#
# FDUPES_IPK_VERSION should be incremented when the ipk changes.
#
FDUPES_IPK_VERSION=1

#
# FDUPES_CONFFILES should be a list of user-editable files
#FDUPES_CONFFILES=/opt/etc/fdupes.conf /opt/etc/init.d/SXXfdupes

#
# FDUPES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FDUPES_PATCHES=$(FDUPES_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FDUPES_CPPFLAGS=
FDUPES_LDFLAGS=

#
# FDUPES_BUILD_DIR is the directory in which the build is done.
# FDUPES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FDUPES_IPK_DIR is the directory in which the ipk is built.
# FDUPES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FDUPES_BUILD_DIR=$(BUILD_DIR)/fdupes
FDUPES_SOURCE_DIR=$(SOURCE_DIR)/fdupes
FDUPES_IPK_DIR=$(BUILD_DIR)/fdupes-$(FDUPES_VERSION)-ipk
FDUPES_IPK=$(BUILD_DIR)/fdupes_$(FDUPES_VERSION)-$(FDUPES_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: fdupes-source fdupes-unpack fdupes fdupes-stage fdupes-ipk fdupes-clean fdupes-dirclean fdupes-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FDUPES_SOURCE):
	$(WGET) -P $(@D) $(FDUPES_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fdupes-source: $(DL_DIR)/$(FDUPES_SOURCE) $(FDUPES_PATCHES)

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
$(FDUPES_BUILD_DIR)/.configured: $(DL_DIR)/$(FDUPES_SOURCE) $(FDUPES_PATCHES) make/fdupes.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FDUPES_DIR) $(@D)
	$(FDUPES_UNZIP) $(DL_DIR)/$(FDUPES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FDUPES_PATCHES)" ; \
		then cat $(FDUPES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FDUPES_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FDUPES_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(FDUPES_DIR) $(@D) ; \
	fi
	sed -i -e 's|gcc|$$(CC)|' $(@D)/Makefile
#	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FDUPES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FDUPES_LDFLAGS)" \
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

fdupes-unpack: $(FDUPES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FDUPES_BUILD_DIR)/.built: $(FDUPES_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) fdupes \
		$(TARGET_CONFIGURE_OPTS) \
		INSTALLDIR=/opt/bin \
		MANPAGEDIR=/opt/man \
		;
	touch $@

#
# This is the build convenience target.
#
fdupes: $(FDUPES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FDUPES_BUILD_DIR)/.staged: $(FDUPES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

fdupes-stage: $(FDUPES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fdupes
#
$(FDUPES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fdupes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FDUPES_PRIORITY)" >>$@
	@echo "Section: $(FDUPES_SECTION)" >>$@
	@echo "Version: $(FDUPES_VERSION)-$(FDUPES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FDUPES_MAINTAINER)" >>$@
	@echo "Source: $(FDUPES_SITE)/$(FDUPES_SOURCE)" >>$@
	@echo "Description: $(FDUPES_DESCRIPTION)" >>$@
	@echo "Depends: $(FDUPES_DEPENDS)" >>$@
	@echo "Suggests: $(FDUPES_SUGGESTS)" >>$@
	@echo "Conflicts: $(FDUPES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FDUPES_IPK_DIR)/opt/sbin or $(FDUPES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FDUPES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FDUPES_IPK_DIR)/opt/etc/fdupes/...
# Documentation files should be installed in $(FDUPES_IPK_DIR)/opt/doc/fdupes/...
# Daemon startup scripts should be installed in $(FDUPES_IPK_DIR)/opt/etc/init.d/S??fdupes
#
# You may need to patch your application to make it use these locations.
#
$(FDUPES_IPK): $(FDUPES_BUILD_DIR)/.built
	rm -rf $(FDUPES_IPK_DIR) $(BUILD_DIR)/fdupes_*_$(TARGET_ARCH).ipk
	install -d $(FDUPES_IPK_DIR)/opt/bin $(FDUPES_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(FDUPES_BUILD_DIR) install \
		INSTALLDIR=$(FDUPES_IPK_DIR)/opt/bin \
		MANPAGEDIR=$(FDUPES_IPK_DIR)/opt/man \
		;
	$(STRIP_COMMAND) $(FDUPES_IPK_DIR)/opt/bin/*
	install -d $(FDUPES_IPK_DIR)/opt/share/doc/fdupes
	install -m644 $(FDUPES_BUILD_DIR)/[CIRT]* $(FDUPES_IPK_DIR)/opt/share/doc/fdupes/
#	install -m 644 $(FDUPES_SOURCE_DIR)/fdupes.conf $(FDUPES_IPK_DIR)/opt/etc/fdupes.conf
#	install -d $(FDUPES_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FDUPES_SOURCE_DIR)/rc.fdupes $(FDUPES_IPK_DIR)/opt/etc/init.d/SXXfdupes
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FDUPES_IPK_DIR)/opt/etc/init.d/SXXfdupes
	$(MAKE) $(FDUPES_IPK_DIR)/CONTROL/control
#	install -m 755 $(FDUPES_SOURCE_DIR)/postinst $(FDUPES_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FDUPES_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FDUPES_SOURCE_DIR)/prerm $(FDUPES_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FDUPES_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(FDUPES_IPK_DIR)/CONTROL/postinst $(FDUPES_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(FDUPES_CONFFILES) | sed -e 's/ /\n/g' > $(FDUPES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FDUPES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fdupes-ipk: $(FDUPES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fdupes-clean:
	rm -f $(FDUPES_BUILD_DIR)/.built
	-$(MAKE) -C $(FDUPES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fdupes-dirclean:
	rm -rf $(BUILD_DIR)/$(FDUPES_DIR) $(FDUPES_BUILD_DIR) $(FDUPES_IPK_DIR) $(FDUPES_IPK)
#
#
# Some sanity check for the package.
#
fdupes-check: $(FDUPES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FDUPES_IPK)
