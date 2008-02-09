###########################################################
#
# rssh
#
###########################################################
#
# RSSH_VERSION, RSSH_SITE and RSSH_SOURCE define
# the upstream location of the source code for the package.
# RSSH_DIR is the directory which is created when the source
# archive is unpacked.
# RSSH_UNZIP is the command used to unzip the source.
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
RSSH_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/rssh
RSSH_VERSION=2.3.2
RSSH_SOURCE=rssh-$(RSSH_VERSION).tar.gz
RSSH_DIR=rssh-$(RSSH_VERSION)
RSSH_UNZIP=zcat
RSSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
RSSH_DESCRIPTION=Rrestricted shell allowing only scp and/or sftp.
RSSH_SECTION=net
RSSH_PRIORITY=optional
RSSH_DEPENDS=openssh
RSSH_SUGGESTS=openssh-sftp-server, rsync
RSSH_CONFLICTS=

#
# RSSH_IPK_VERSION should be incremented when the ipk changes.
#
RSSH_IPK_VERSION=1

#
# RSSH_CONFFILES should be a list of user-editable files
RSSH_CONFFILES=/opt/etc/rssh.conf
#/opt/etc/init.d/SXXrssh

#
# RSSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#RSSH_PATCHES=$(RSSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
RSSH_CPPFLAGS=
RSSH_LDFLAGS=

#
# RSSH_BUILD_DIR is the directory in which the build is done.
# RSSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# RSSH_IPK_DIR is the directory in which the ipk is built.
# RSSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
RSSH_BUILD_DIR=$(BUILD_DIR)/rssh
RSSH_SOURCE_DIR=$(SOURCE_DIR)/rssh
RSSH_IPK_DIR=$(BUILD_DIR)/rssh-$(RSSH_VERSION)-ipk
RSSH_IPK=$(BUILD_DIR)/rssh_$(RSSH_VERSION)-$(RSSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: rssh-source rssh-unpack rssh rssh-stage rssh-ipk rssh-clean rssh-dirclean rssh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(RSSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(RSSH_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
rssh-source: $(DL_DIR)/$(RSSH_SOURCE) $(RSSH_PATCHES)

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
$(RSSH_BUILD_DIR)/.configured: $(DL_DIR)/$(RSSH_SOURCE) $(RSSH_PATCHES) make/rssh.mk
	$(MAKE) openssh-stage 
	rm -rf $(BUILD_DIR)/$(RSSH_DIR) $(@D)
	$(RSSH_UNZIP) $(DL_DIR)/$(RSSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(RSSH_PATCHES)" ; \
		then cat $(RSSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(RSSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(RSSH_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(RSSH_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		sed -i -e 's,(\$$\(DESTDIR\)\$$\(sysconfdir\)/\$$\$$f),\1.dist,g' \
			-e 's|$$(libexecdir)/rssh_chroot_helper|$${DESTDIR}/$$(libexecdir)/rssh_chroot_helper|' \
		Makefile.in ;\
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(RSSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(RSSH_LDFLAGS)" \
		ac_cv_func_malloc_0_nonnull=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--with-rsync=/opt/bin/rsync \
		--with-scp=/opt/bin/scp \
		--with-cvs=/opt/bin/cvs \
		--with-sftp-server=/opt/libexec/sftp-server \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

rssh-unpack: $(RSSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(RSSH_BUILD_DIR)/.built: $(RSSH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
rssh: $(RSSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(RSSH_BUILD_DIR)/.staged: $(RSSH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

rssh-stage: $(RSSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/rssh
#
$(RSSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: rssh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(RSSH_PRIORITY)" >>$@
	@echo "Section: $(RSSH_SECTION)" >>$@
	@echo "Version: $(RSSH_VERSION)-$(RSSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(RSSH_MAINTAINER)" >>$@
	@echo "Source: $(RSSH_SITE)/$(RSSH_SOURCE)" >>$@
	@echo "Description: $(RSSH_DESCRIPTION)" >>$@
	@echo "Depends: $(RSSH_DEPENDS)" >>$@
	@echo "Suggests: $(RSSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(RSSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(RSSH_IPK_DIR)/opt/sbin or $(RSSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(RSSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(RSSH_IPK_DIR)/opt/etc/rssh/...
# Documentation files should be installed in $(RSSH_IPK_DIR)/opt/doc/rssh/...
# Daemon startup scripts should be installed in $(RSSH_IPK_DIR)/opt/etc/init.d/S??rssh
#
# You may need to patch your application to make it use these locations.
#
$(RSSH_IPK): $(RSSH_BUILD_DIR)/.built
	rm -rf $(RSSH_IPK_DIR) $(BUILD_DIR)/rssh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(RSSH_BUILD_DIR) DESTDIR=$(RSSH_IPK_DIR) install-strip
#	install -d $(RSSH_IPK_DIR)/opt/etc/
#	install -m 644 $(RSSH_SOURCE_DIR)/rssh.conf $(RSSH_IPK_DIR)/opt/etc/rssh.conf
#	install -d $(RSSH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(RSSH_SOURCE_DIR)/rc.rssh $(RSSH_IPK_DIR)/opt/etc/init.d/SXXrssh
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RSSH_IPK_DIR)/opt/etc/init.d/SXXrssh
	$(MAKE) $(RSSH_IPK_DIR)/CONTROL/control
#	install -m 755 $(RSSH_SOURCE_DIR)/postinst $(RSSH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RSSH_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(RSSH_SOURCE_DIR)/prerm $(RSSH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(RSSH_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(RSSH_IPK_DIR)/CONTROL/postinst $(RSSH_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(RSSH_CONFFILES) | sed -e 's/ /\n/g' > $(RSSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(RSSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
rssh-ipk: $(RSSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
rssh-clean:
	rm -f $(RSSH_BUILD_DIR)/.built
	-$(MAKE) -C $(RSSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
rssh-dirclean:
	rm -rf $(BUILD_DIR)/$(RSSH_DIR) $(RSSH_BUILD_DIR) $(RSSH_IPK_DIR) $(RSSH_IPK)
#
#
# Some sanity check for the package.
#
rssh-check: $(RSSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(RSSH_IPK)
