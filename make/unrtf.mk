###########################################################
#
# unrtf
#
###########################################################
#
# UNRTF_VERSION, UNRTF_SITE and UNRTF_SOURCE define
# the upstream location of the source code for the package.
# UNRTF_DIR is the directory which is created when the source
# archive is unpacked.
# UNRTF_UNZIP is the command used to unzip the source.
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
UNRTF_SITE=http://ftp.gnu.org/gnu/unrtf
UNRTF_VERSION=0.20.5
UNRTF_SOURCE=unrtf-$(UNRTF_VERSION).tar.gz
UNRTF_DIR=unrtf-$(UNRTF_VERSION)
UNRTF_UNZIP=zcat
UNRTF_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UNRTF_DESCRIPTION=A command-line program written in C which converts documents in Rich Text Format (.rtf) to HTML, LaTeX, PostScript, and other formats.
UNRTF_SECTION=utils
UNRTF_PRIORITY=optional
UNRTF_DEPENDS=
UNRTF_SUGGESTS=
UNRTF_CONFLICTS=

#
# UNRTF_IPK_VERSION should be incremented when the ipk changes.
#
UNRTF_IPK_VERSION=1

#
# UNRTF_CONFFILES should be a list of user-editable files
#UNRTF_CONFFILES=/opt/etc/unrtf.conf /opt/etc/init.d/SXXunrtf

#
# UNRTF_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#UNRTF_PATCHES=$(UNRTF_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UNRTF_CPPFLAGS=
UNRTF_LDFLAGS=

#
# UNRTF_BUILD_DIR is the directory in which the build is done.
# UNRTF_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UNRTF_IPK_DIR is the directory in which the ipk is built.
# UNRTF_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UNRTF_BUILD_DIR=$(BUILD_DIR)/unrtf
UNRTF_SOURCE_DIR=$(SOURCE_DIR)/unrtf
UNRTF_IPK_DIR=$(BUILD_DIR)/unrtf-$(UNRTF_VERSION)-ipk
UNRTF_IPK=$(BUILD_DIR)/unrtf_$(UNRTF_VERSION)-$(UNRTF_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: unrtf-source unrtf-unpack unrtf unrtf-stage unrtf-ipk unrtf-clean unrtf-dirclean unrtf-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UNRTF_SOURCE):
	$(WGET) -P $(DL_DIR) $(UNRTF_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
unrtf-source: $(DL_DIR)/$(UNRTF_SOURCE) $(UNRTF_PATCHES)

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
$(UNRTF_BUILD_DIR)/.configured: $(DL_DIR)/$(UNRTF_SOURCE) $(UNRTF_PATCHES) make/unrtf.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(UNRTF_DIR) $(@D)
	$(UNRTF_UNZIP) $(DL_DIR)/$(UNRTF_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UNRTF_PATCHES)" ; \
		then cat $(UNRTF_PATCHES) | \
		patch -d $(BUILD_DIR)/$(UNRTF_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UNRTF_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(UNRTF_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UNRTF_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UNRTF_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
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

unrtf-unpack: $(UNRTF_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UNRTF_BUILD_DIR)/.built: $(UNRTF_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
unrtf: $(UNRTF_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UNRTF_BUILD_DIR)/.staged: $(UNRTF_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

unrtf-stage: $(UNRTF_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/unrtf
#
$(UNRTF_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: unrtf" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UNRTF_PRIORITY)" >>$@
	@echo "Section: $(UNRTF_SECTION)" >>$@
	@echo "Version: $(UNRTF_VERSION)-$(UNRTF_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UNRTF_MAINTAINER)" >>$@
	@echo "Source: $(UNRTF_SITE)/$(UNRTF_SOURCE)" >>$@
	@echo "Description: $(UNRTF_DESCRIPTION)" >>$@
	@echo "Depends: $(UNRTF_DEPENDS)" >>$@
	@echo "Suggests: $(UNRTF_SUGGESTS)" >>$@
	@echo "Conflicts: $(UNRTF_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UNRTF_IPK_DIR)/opt/sbin or $(UNRTF_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UNRTF_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UNRTF_IPK_DIR)/opt/etc/unrtf/...
# Documentation files should be installed in $(UNRTF_IPK_DIR)/opt/doc/unrtf/...
# Daemon startup scripts should be installed in $(UNRTF_IPK_DIR)/opt/etc/init.d/S??unrtf
#
# You may need to patch your application to make it use these locations.
#
$(UNRTF_IPK): $(UNRTF_BUILD_DIR)/.built
	rm -rf $(UNRTF_IPK_DIR) $(BUILD_DIR)/unrtf_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(UNRTF_BUILD_DIR) DESTDIR=$(UNRTF_IPK_DIR) install-strip
#	install -d $(UNRTF_IPK_DIR)/opt/etc/
#	install -m 644 $(UNRTF_SOURCE_DIR)/unrtf.conf $(UNRTF_IPK_DIR)/opt/etc/unrtf.conf
#	install -d $(UNRTF_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UNRTF_SOURCE_DIR)/rc.unrtf $(UNRTF_IPK_DIR)/opt/etc/init.d/SXXunrtf
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNRTF_IPK_DIR)/opt/etc/init.d/SXXunrtf
	$(MAKE) $(UNRTF_IPK_DIR)/CONTROL/control
#	install -m 755 $(UNRTF_SOURCE_DIR)/postinst $(UNRTF_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNRTF_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UNRTF_SOURCE_DIR)/prerm $(UNRTF_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UNRTF_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(UNRTF_IPK_DIR)/CONTROL/postinst $(UNRTF_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(UNRTF_CONFFILES) | sed -e 's/ /\n/g' > $(UNRTF_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UNRTF_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
unrtf-ipk: $(UNRTF_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
unrtf-clean:
	rm -f $(UNRTF_BUILD_DIR)/.built
	-$(MAKE) -C $(UNRTF_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
unrtf-dirclean:
	rm -rf $(BUILD_DIR)/$(UNRTF_DIR) $(UNRTF_BUILD_DIR) $(UNRTF_IPK_DIR) $(UNRTF_IPK)
#
#
# Some sanity check for the package.
#
unrtf-check: $(UNRTF_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UNRTF_IPK)
