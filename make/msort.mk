###########################################################
#
# msort
#
###########################################################
#
# MSORT_VERSION, MSORT_SITE and MSORT_SOURCE define
# the upstream location of the source code for the package.
# MSORT_DIR is the directory which is created when the source
# archive is unpacked.
# MSORT_UNZIP is the command used to unzip the source.
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
MSORT_SITE=http://billposer.org/Software/Downloads
MSORT_VERSION=8.46
MSORT_SOURCE=msort-$(MSORT_VERSION).tar.bz2
MSORT_DIR=msort-$(MSORT_VERSION)
MSORT_UNZIP=bzcat
MSORT_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MSORT_DESCRIPTION=Msort sorts files in sophisticated ways.
MSORT_SECTION=utils
MSORT_PRIORITY=optional
MSORT_DEPENDS=tre, utf8proc
ifeq ($(GETTEXT_NLS), enable)
MSORT_DEPENDS+=, gettext
endif
MSORT_SUGGESTS=
MSORT_CONFLICTS=

#
# MSORT_IPK_VERSION should be incremented when the ipk changes.
#
MSORT_IPK_VERSION=1

#
# MSORT_CONFFILES should be a list of user-editable files
#MSORT_CONFFILES=/opt/etc/msort.conf /opt/etc/init.d/SXXmsort

#
# MSORT_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MSORT_PATCHES=$(MSORT_SOURCE_DIR)/uninum.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MSORT_CPPFLAGS=
MSORT_LDFLAGS=
ifeq ($(LIBC_STYLE), uclibc)
MSORT_LDFLAGS+=-lintl
endif

#
# MSORT_BUILD_DIR is the directory in which the build is done.
# MSORT_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MSORT_IPK_DIR is the directory in which the ipk is built.
# MSORT_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MSORT_BUILD_DIR=$(BUILD_DIR)/msort
MSORT_SOURCE_DIR=$(SOURCE_DIR)/msort
MSORT_IPK_DIR=$(BUILD_DIR)/msort-$(MSORT_VERSION)-ipk
MSORT_IPK=$(BUILD_DIR)/msort_$(MSORT_VERSION)-$(MSORT_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: msort-source msort-unpack msort msort-stage msort-ipk msort-clean msort-dirclean msort-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MSORT_SOURCE):
	$(WGET) -P $(@D) $(MSORT_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
msort-source: $(DL_DIR)/$(MSORT_SOURCE) $(MSORT_PATCHES)

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
$(MSORT_BUILD_DIR)/.configured: $(DL_DIR)/$(MSORT_SOURCE) $(MSORT_PATCHES) make/msort.mk
	$(MAKE) tre-stage utf8proc-stage
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	rm -rf $(BUILD_DIR)/$(MSORT_DIR) $(MSORT_BUILD_DIR)
	$(MSORT_UNZIP) $(DL_DIR)/$(MSORT_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MSORT_PATCHES)" ; \
		then cat $(MSORT_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MSORT_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MSORT_DIR)" != "$(MSORT_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MSORT_DIR) $(MSORT_BUILD_DIR) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MSORT_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MSORT_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-uninum \
		--disable-nls \
		--disable-static \
	)
	touch $@

msort-unpack: $(MSORT_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MSORT_BUILD_DIR)/.built: $(MSORT_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
msort: $(MSORT_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MSORT_BUILD_DIR)/.staged: $(MSORT_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

msort-stage: $(MSORT_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/msort
#
$(MSORT_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: msort" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MSORT_PRIORITY)" >>$@
	@echo "Section: $(MSORT_SECTION)" >>$@
	@echo "Version: $(MSORT_VERSION)-$(MSORT_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MSORT_MAINTAINER)" >>$@
	@echo "Source: $(MSORT_SITE)/$(MSORT_SOURCE)" >>$@
	@echo "Description: $(MSORT_DESCRIPTION)" >>$@
	@echo "Depends: $(MSORT_DEPENDS)" >>$@
	@echo "Suggests: $(MSORT_SUGGESTS)" >>$@
	@echo "Conflicts: $(MSORT_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MSORT_IPK_DIR)/opt/sbin or $(MSORT_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MSORT_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MSORT_IPK_DIR)/opt/etc/msort/...
# Documentation files should be installed in $(MSORT_IPK_DIR)/opt/doc/msort/...
# Daemon startup scripts should be installed in $(MSORT_IPK_DIR)/opt/etc/init.d/S??msort
#
# You may need to patch your application to make it use these locations.
#
$(MSORT_IPK): $(MSORT_BUILD_DIR)/.built
	rm -rf $(MSORT_IPK_DIR) $(BUILD_DIR)/msort_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MSORT_BUILD_DIR) DESTDIR=$(MSORT_IPK_DIR) install-strip
#	install -d $(MSORT_IPK_DIR)/opt/etc/
#	install -m 644 $(MSORT_SOURCE_DIR)/msort.conf $(MSORT_IPK_DIR)/opt/etc/msort.conf
#	install -d $(MSORT_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MSORT_SOURCE_DIR)/rc.msort $(MSORT_IPK_DIR)/opt/etc/init.d/SXXmsort
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSORT_IPK_DIR)/opt/etc/init.d/SXXmsort
	$(MAKE) $(MSORT_IPK_DIR)/CONTROL/control
#	install -m 755 $(MSORT_SOURCE_DIR)/postinst $(MSORT_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSORT_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MSORT_SOURCE_DIR)/prerm $(MSORT_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MSORT_IPK_DIR)/CONTROL/prerm
	echo $(MSORT_CONFFILES) | sed -e 's/ /\n/g' > $(MSORT_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MSORT_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
msort-ipk: $(MSORT_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
msort-clean:
	rm -f $(MSORT_BUILD_DIR)/.built
	-$(MAKE) -C $(MSORT_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
msort-dirclean:
	rm -rf $(BUILD_DIR)/$(MSORT_DIR) $(MSORT_BUILD_DIR) $(MSORT_IPK_DIR) $(MSORT_IPK)
#
#
# Some sanity check for the package.
#
msort-check: $(MSORT_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MSORT_IPK)
