###########################################################
#
# clinkcc
#
###########################################################

# You must replace "clinkcc" and "CLINKCC" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# CLINKCC_VERSION, CLINKCC_SITE and CLINKCC_SOURCE define
# the upstream location of the source code for the package.
# CLINKCC_DIR is the directory which is created when the source
# archive is unpacked.
# CLINKCC_UNZIP is the command used to unzip the source.
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
CLINKCC_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/clinkcc
CLINKCC_VERSION=1.7.1
CLINKCC_SOURCE=clinkcc171.tar.gz
CLINKCC_DIR=CyberLink
CLINKCC_UNZIP=zcat
CLINKCC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CLINKCC_DESCRIPTION=CyberLink for C++ is a development package for UPnP programmers. Using the package, you can create UPnP devices and control points easily.
CLINKCC_SECTION=net
CLINKCC_PRIORITY=optional
CLINKCC_DEPENDS=xerces-c
ifeq (uclibc, $(LIBC_STYLE))
	CLINKCC_DEPENDS+=, libiconv
endif
CLINKCC_SUGGESTS=
CLINKCC_CONFLICTS=

#
# CLINKCC_IPK_VERSION should be incremented when the ipk changes.
#
CLINKCC_IPK_VERSION=1

#
# CLINKCC_CONFFILES should be a list of user-editable files
#CLINKCC_CONFFILES=/opt/etc/clinkcc.conf /opt/etc/init.d/SXXclinkcc

#
# CLINKCC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CLINKCC_PATCHES=$(CLINKCC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CLINKCC_CPPFLAGS=
CLINKCC_LDFLAGS=

#
# CLINKCC_BUILD_DIR is the directory in which the build is done.
# CLINKCC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CLINKCC_IPK_DIR is the directory in which the ipk is built.
# CLINKCC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CLINKCC_BUILD_DIR=$(BUILD_DIR)/clinkcc
CLINKCC_SOURCE_DIR=$(SOURCE_DIR)/clinkcc
CLINKCC_IPK_DIR=$(BUILD_DIR)/clinkcc-$(CLINKCC_VERSION)-ipk
CLINKCC_IPK=$(BUILD_DIR)/clinkcc_$(CLINKCC_VERSION)-$(CLINKCC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: clinkcc-source clinkcc-unpack clinkcc clinkcc-stage clinkcc-ipk clinkcc-clean clinkcc-dirclean clinkcc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CLINKCC_SOURCE):
	$(WGET) -P $(@D) $(CLINKCC_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
clinkcc-source: $(DL_DIR)/$(CLINKCC_SOURCE) $(CLINKCC_PATCHES)

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
$(CLINKCC_BUILD_DIR)/.configured: $(DL_DIR)/$(CLINKCC_SOURCE) $(CLINKCC_PATCHES) make/clinkcc.mk
	$(MAKE) xerces-c-stage
ifeq (uclibc, $(LIBC_STYLE))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(CLINKCC_DIR) $(@D)
	$(CLINKCC_UNZIP) $(DL_DIR)/$(CLINKCC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CLINKCC_PATCHES)" ; \
		then cat $(CLINKCC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CLINKCC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CLINKCC_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(CLINKCC_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CLINKCC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CLINKCC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

clinkcc-unpack: $(CLINKCC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CLINKCC_BUILD_DIR)/.built: $(CLINKCC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	chmod +x $(@D)/config/install-sh
	touch $@

#
# This is the build convenience target.
#
clinkcc: $(CLINKCC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CLINKCC_BUILD_DIR)/.staged: $(CLINKCC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

clinkcc-stage: $(CLINKCC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/clinkcc
#
$(CLINKCC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: clinkcc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CLINKCC_PRIORITY)" >>$@
	@echo "Section: $(CLINKCC_SECTION)" >>$@
	@echo "Version: $(CLINKCC_VERSION)-$(CLINKCC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CLINKCC_MAINTAINER)" >>$@
	@echo "Source: $(CLINKCC_SITE)/$(CLINKCC_SOURCE)" >>$@
	@echo "Description: $(CLINKCC_DESCRIPTION)" >>$@
	@echo "Depends: $(CLINKCC_DEPENDS)" >>$@
	@echo "Suggests: $(CLINKCC_SUGGESTS)" >>$@
	@echo "Conflicts: $(CLINKCC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CLINKCC_IPK_DIR)/opt/sbin or $(CLINKCC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CLINKCC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CLINKCC_IPK_DIR)/opt/etc/clinkcc/...
# Documentation files should be installed in $(CLINKCC_IPK_DIR)/opt/doc/clinkcc/...
# Daemon startup scripts should be installed in $(CLINKCC_IPK_DIR)/opt/etc/init.d/S??clinkcc
#
# You may need to patch your application to make it use these locations.
#
$(CLINKCC_IPK): $(CLINKCC_BUILD_DIR)/.built
	rm -rf $(CLINKCC_IPK_DIR) $(BUILD_DIR)/clinkcc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CLINKCC_BUILD_DIR) DESTDIR=$(CLINKCC_IPK_DIR) install-strip
#	install -d $(CLINKCC_IPK_DIR)/opt/etc/
#	install -m 644 $(CLINKCC_SOURCE_DIR)/clinkcc.conf $(CLINKCC_IPK_DIR)/opt/etc/clinkcc.conf
#	install -d $(CLINKCC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CLINKCC_SOURCE_DIR)/rc.clinkcc $(CLINKCC_IPK_DIR)/opt/etc/init.d/SXXclinkcc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLINKCC_IPK_DIR)/opt/etc/init.d/SXXclinkcc
	$(MAKE) $(CLINKCC_IPK_DIR)/CONTROL/control
#	install -m 755 $(CLINKCC_SOURCE_DIR)/postinst $(CLINKCC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLINKCC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CLINKCC_SOURCE_DIR)/prerm $(CLINKCC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CLINKCC_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(CLINKCC_IPK_DIR)/CONTROL/postinst $(CLINKCC_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(CLINKCC_CONFFILES) | sed -e 's/ /\n/g' > $(CLINKCC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CLINKCC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
clinkcc-ipk: $(CLINKCC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
clinkcc-clean:
	rm -f $(CLINKCC_BUILD_DIR)/.built
	-$(MAKE) -C $(CLINKCC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
clinkcc-dirclean:
	rm -rf $(BUILD_DIR)/$(CLINKCC_DIR) $(CLINKCC_BUILD_DIR) $(CLINKCC_IPK_DIR) $(CLINKCC_IPK)
#
#
# Some sanity check for the package.
#
clinkcc-check: $(CLINKCC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
