###########################################################
#
# tmux
#
###########################################################
#
# TMUX_VERSION, TMUX_SITE and TMUX_SOURCE define
# the upstream location of the source code for the package.
# TMUX_DIR is the directory which is created when the source
# archive is unpacked.
# TMUX_UNZIP is the command used to unzip the source.
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
TMUX_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/tmux
TMUX_VERSION=1.6
TMUX_SOURCE=tmux-$(TMUX_VERSION).tar.gz
TMUX_DIR=tmux-$(TMUX_VERSION)
TMUX_UNZIP=zcat
TMUX_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TMUX_DESCRIPTION=A terminal multiplexer.
TMUX_SECTION=utils
TMUX_PRIORITY=optional
TMUX_DEPENDS=libevent, ncurses
TMUX_SUGGESTS=
TMUX_CONFLICTS=

#
# TMUX_IPK_VERSION should be incremented when the ipk changes.
#
TMUX_IPK_VERSION=1

#
# TMUX_CONFFILES should be a list of user-editable files
#TMUX_CONFFILES=/opt/etc/tmux.conf /opt/etc/init.d/SXXtmux

#
# TMUX_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TMUX_PATCHES=$(TMUX_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TMUX_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/ncurses
ifneq (, $(filter -DPATH_MAX=4096, $(STAGING_CPPFLAGS)))
TMUX_CPPFLAGS+=-DIOV_MAX=1024
endif
TMUX_LDFLAGS=

#
# TMUX_BUILD_DIR is the directory in which the build is done.
# TMUX_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TMUX_IPK_DIR is the directory in which the ipk is built.
# TMUX_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TMUX_BUILD_DIR=$(BUILD_DIR)/tmux
TMUX_SOURCE_DIR=$(SOURCE_DIR)/tmux
TMUX_IPK_DIR=$(BUILD_DIR)/tmux-$(TMUX_VERSION)-ipk
TMUX_IPK=$(BUILD_DIR)/tmux_$(TMUX_VERSION)-$(TMUX_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tmux-source tmux-unpack tmux tmux-stage tmux-ipk tmux-clean tmux-dirclean tmux-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TMUX_SOURCE):
	$(WGET) -P $(@D) $(TMUX_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tmux-source: $(DL_DIR)/$(TMUX_SOURCE) $(TMUX_PATCHES)

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
$(TMUX_BUILD_DIR)/.configured: $(DL_DIR)/$(TMUX_SOURCE) $(TMUX_PATCHES) make/tmux.mk
	$(MAKE) libevent-stage ncurses-stage
	rm -rf $(BUILD_DIR)/$(TMUX_DIR) $(@D)
	$(TMUX_UNZIP) $(DL_DIR)/$(TMUX_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TMUX_PATCHES)" ; \
		then cat $(TMUX_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TMUX_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TMUX_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(TMUX_DIR) $(@D) ; \
	fi
	sed -i -e 's| -I/usr/local/include||' $(@D)/Makefile.in
	if test `$(TARGET_CC) -dumpversion | cut -c1` = 3; then \
	    sed -i -e 's| -I-||' $(@D)/Makefile.in; \
	fi
	sed -i -e 's|/etc/tmux.conf|/opt&|' $(@D)/tmux.h
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TMUX_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TMUX_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
	)
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

tmux-unpack: $(TMUX_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TMUX_BUILD_DIR)/.built: $(TMUX_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
tmux: $(TMUX_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TMUX_BUILD_DIR)/.staged: $(TMUX_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

tmux-stage: $(TMUX_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tmux
#
$(TMUX_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tmux" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TMUX_PRIORITY)" >>$@
	@echo "Section: $(TMUX_SECTION)" >>$@
	@echo "Version: $(TMUX_VERSION)-$(TMUX_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TMUX_MAINTAINER)" >>$@
	@echo "Source: $(TMUX_SITE)/$(TMUX_SOURCE)" >>$@
	@echo "Description: $(TMUX_DESCRIPTION)" >>$@
	@echo "Depends: $(TMUX_DEPENDS)" >>$@
	@echo "Suggests: $(TMUX_SUGGESTS)" >>$@
	@echo "Conflicts: $(TMUX_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TMUX_IPK_DIR)/opt/sbin or $(TMUX_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TMUX_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TMUX_IPK_DIR)/opt/etc/tmux/...
# Documentation files should be installed in $(TMUX_IPK_DIR)/opt/doc/tmux/...
# Daemon startup scripts should be installed in $(TMUX_IPK_DIR)/opt/etc/init.d/S??tmux
#
# You may need to patch your application to make it use these locations.
#
$(TMUX_IPK): $(TMUX_BUILD_DIR)/.built
	rm -rf $(TMUX_IPK_DIR) $(BUILD_DIR)/tmux_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TMUX_BUILD_DIR) DESTDIR=$(TMUX_IPK_DIR) install-strip
#	install -d $(TMUX_IPK_DIR)/opt/etc/
#	install -m 644 $(TMUX_SOURCE_DIR)/tmux.conf $(TMUX_IPK_DIR)/opt/etc/tmux.conf
#	install -d $(TMUX_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TMUX_SOURCE_DIR)/rc.tmux $(TMUX_IPK_DIR)/opt/etc/init.d/SXXtmux
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TMUX_IPK_DIR)/opt/etc/init.d/SXXtmux
	$(MAKE) $(TMUX_IPK_DIR)/CONTROL/control
#	install -m 755 $(TMUX_SOURCE_DIR)/postinst $(TMUX_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TMUX_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TMUX_SOURCE_DIR)/prerm $(TMUX_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(TMUX_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(TMUX_IPK_DIR)/CONTROL/postinst $(TMUX_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(TMUX_CONFFILES) | sed -e 's/ /\n/g' > $(TMUX_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TMUX_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(TMUX_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tmux-ipk: $(TMUX_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tmux-clean:
	rm -f $(TMUX_BUILD_DIR)/.built
	-$(MAKE) -C $(TMUX_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tmux-dirclean:
	rm -rf $(BUILD_DIR)/$(TMUX_DIR) $(TMUX_BUILD_DIR) $(TMUX_IPK_DIR) $(TMUX_IPK)
#
#
# Some sanity check for the package.
#
tmux-check: $(TMUX_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
