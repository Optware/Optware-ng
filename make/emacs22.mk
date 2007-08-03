###########################################################
#
# emacs22
#
###########################################################
#
# EMACS22_VERSION, EMACS22_SITE and EMACS22_SOURCE define
# the upstream location of the source code for the package.
# EMACS22_DIR is the directory which is created when the source
# archive is unpacked.
# EMACS22_UNZIP is the command used to unzip the source.
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
EMACS22_SITE=http://ftp.gnu.org/pub/gnu/emacs
EMACS22_VERSION=22.1
EMACS22_SOURCE=emacs-$(EMACS22_VERSION).tar.gz
EMACS22_DIR=emacs-$(EMACS22_VERSION)
EMACS22_UNZIP=zcat
EMACS22_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EMACS22_DESCRIPTION=Emacs is the extensible, customizable, self-documenting real-time display editor.
EMACS22_SECTION=editor
EMACS22_PRIORITY=optional
EMACS22_DEPENDS=ncurses
EMACS22_SUGGESTS=
ifeq ($(OPTWARE_TARGET), nslu2)
EMACS22_CONFLICTS=emacs
else
EMACS22_CONFLICTS=
endif

#
# EMACS22_IPK_VERSION should be incremented when the ipk changes.
#
EMACS22_IPK_VERSION=1

#
# EMACS22_CONFFILES should be a list of user-editable files
#EMACS22_CONFFILES=/opt/etc/emacs22.conf /opt/etc/init.d/SXXemacs22

#
# EMACS22_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EMACS22_PATCHES=
ifneq ($(HOSTCC), $(TARGET_CC))
EMACS22_PATCHES+=\
$(EMACS22_SOURCE_DIR)/PATH_DUMPLOADSEARCH.patch \
$(EMACS22_SOURCE_DIR)/lib-src-Makefile.in.patch \
$(EMACS22_SOURCE_DIR)/src-Makefile.in.patch
endif
ifeq ($(LIBC_STYLE), uclibc)
EMACS22_PATCHES+=$(EMACS22_SOURCE_DIR)/uclibc.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
EMACS22_CPPFLAGS=
EMACS22_LDFLAGS=

#
# EMACS22_BUILD_DIR is the directory in which the build is done.
# EMACS22_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EMACS22_IPK_DIR is the directory in which the ipk is built.
# EMACS22_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EMACS22_SOURCE_DIR=$(SOURCE_DIR)/emacs22
EMACS22_BUILD_DIR=$(BUILD_DIR)/emacs22
EMACS22_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/emacs22

EMACS22_IPK_DIR=$(BUILD_DIR)/emacs22-$(EMACS22_VERSION)-ipk
EMACS22_IPK=$(BUILD_DIR)/emacs22_$(EMACS22_VERSION)-$(EMACS22_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: emacs22-source emacs22-unpack emacs22 emacs22-stage emacs22-ipk emacs22-clean emacs22-dirclean emacs22-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EMACS22_SOURCE):
	$(WGET) -P $(DL_DIR) $(EMACS22_SITE)/$(EMACS22_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(EMACS22_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
emacs22-source: $(DL_DIR)/$(EMACS22_SOURCE) $(EMACS22_PATCHES)

$(EMACS22_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(EMACS22_SOURCE) # $(EMACS22_PATCHES) make/emacs22.mk
	rm -rf $(HOST_BUILD_DIR)/$(EMACS22_DIR) $(EMACS22_HOST_BUILD_DIR)
	$(EMACS22_UNZIP) $(DL_DIR)/$(EMACS22_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(EMACS22_DIR)" != "$(HOST_EMACS22_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(EMACS22_DIR) $(EMACS22_HOST_BUILD_DIR) ; \
	fi
	(cd $(EMACS22_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--without-x \
		--without-sound \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(EMACS22_HOST_BUILD_DIR)
	touch $@

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(EMACS22_BUILD_DIR)/.configured: $(DL_DIR)/$(EMACS22_SOURCE) $(EMACS22_PATCHES) make/emacs22.mk
else
$(EMACS22_BUILD_DIR)/.configured: $(EMACS22_HOST_BUILD_DIR)/.built
endif
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(EMACS22_DIR) $(EMACS22_BUILD_DIR)
	$(EMACS22_UNZIP) $(DL_DIR)/$(EMACS22_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(EMACS22_PATCHES)" ; \
		then cat $(EMACS22_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(EMACS22_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(EMACS22_DIR)" != "$(EMACS22_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(EMACS22_DIR) $(EMACS22_BUILD_DIR) ; \
	fi
	(cd $(EMACS22_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EMACS22_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EMACS22_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--without-x \
		--without-sound \
		--disable-nls \
		--disable-static \
	)
	touch $@

emacs22-unpack: $(EMACS22_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EMACS22_BUILD_DIR)/.built: $(EMACS22_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(EMACS22_BUILD_DIR) \
		EMACS22_HOST_BUILD_DIR=$(EMACS22_HOST_BUILD_DIR) \
		EMACS=$(EMACS22_HOST_BUILD_DIR)/src/emacs \
		BUILT-EMACS=$(EMACS22_HOST_BUILD_DIR)/src/emacs \
		TARGET_LIBDIR=$(TARGET_USRLIBDIR) \
		;
	touch $@

#
# This is the build convenience target.
#
emacs22: $(EMACS22_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(EMACS22_BUILD_DIR)/.staged: $(EMACS22_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(EMACS22_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

emacs22-stage: $(EMACS22_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/emacs22
#
$(EMACS22_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: emacs22" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EMACS22_PRIORITY)" >>$@
	@echo "Section: $(EMACS22_SECTION)" >>$@
	@echo "Version: $(EMACS22_VERSION)-$(EMACS22_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EMACS22_MAINTAINER)" >>$@
	@echo "Source: $(EMACS22_SITE)/$(EMACS22_SOURCE)" >>$@
	@echo "Description: $(EMACS22_DESCRIPTION)" >>$@
	@echo "Depends: $(EMACS22_DEPENDS)" >>$@
	@echo "Suggests: $(EMACS22_SUGGESTS)" >>$@
	@echo "Conflicts: $(EMACS22_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(EMACS22_IPK_DIR)/opt/sbin or $(EMACS22_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(EMACS22_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(EMACS22_IPK_DIR)/opt/etc/emacs22/...
# Documentation files should be installed in $(EMACS22_IPK_DIR)/opt/doc/emacs22/...
# Daemon startup scripts should be installed in $(EMACS22_IPK_DIR)/opt/etc/init.d/S??emacs22
#
# You may need to patch your application to make it use these locations.
#
$(EMACS22_IPK): $(EMACS22_BUILD_DIR)/.built
	rm -rf $(EMACS22_IPK_DIR) $(BUILD_DIR)/emacs22_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(EMACS22_BUILD_DIR) DESTDIR=$(EMACS22_IPK_DIR) install \
		EMACS22_HOST_BUILD_DIR=$(EMACS22_HOST_BUILD_DIR) \
		EMACS=$(EMACS22_HOST_BUILD_DIR)/src/emacs \
		BUILT-EMACS=$(EMACS22_HOST_BUILD_DIR)/src/emacs \
		TARGET_LIBDIR=$(TARGET_USRLIBDIR) \
		;
	mv $(EMACS22_IPK_DIR)/opt/bin/ctags $(EMACS22_IPK_DIR)/opt/bin/ctags-emacs
	mv $(EMACS22_IPK_DIR)/opt/share/man/man1/ctags.1 $(EMACS22_IPK_DIR)/opt/share/man/man1/ctags-emacs.1
	$(STRIP_COMMAND) `echo \
		$(EMACS22_IPK_DIR)/opt/bin/* \
		$(EMACS22_IPK_DIR)/opt/libexec/emacs/$(EMACS22_VERSION)/$(GNU_TARGET_NAME)/* \
		| tr ' ' '\n' \
		| egrep -v '/grep-changelog$$|/rcs-checkin$$|/rcs2log$$|/vcdiff$$'`
	mv $(EMACS22_IPK_DIR)/opt/bin/emacs-$(EMACS22_VERSION) $(EMACS22_IPK_DIR)/opt/share/emacs/$(EMACS22_VERSION)/lisp/temacs
	rm -rf $(EMACS22_IPK_DIR)/opt/share/info/dir*
	rm -rf $(EMACS22_IPK_DIR)/opt/share/emacs/$(EMACS22_VERSION)/etc/images
	rm -rf $(EMACS22_IPK_DIR)/opt/share/emacs/$(EMACS22_VERSION)/etc/tree-widget
	rm -rf $(EMACS22_IPK_DIR)/opt/share/emacs/$(EMACS22_VERSION)/lisp/obsolete
	$(MAKE) $(EMACS22_IPK_DIR)/CONTROL/control
	install -m 644 $(EMACS22_SOURCE_DIR)/postinst $(EMACS22_IPK_DIR)/CONTROL/
	sed -i -e 's/$${EMACS_VERSION}/$(EMACS22_VERSION)/g' $(EMACS22_IPK_DIR)/CONTROL/postinst
	install -m 644 $(EMACS22_SOURCE_DIR)/prerm $(EMACS22_IPK_DIR)/CONTROL/
	sed -i -e 's/$${EMACS_VERSION}/$(EMACS22_VERSION)/g' $(EMACS22_IPK_DIR)/CONTROL/prerm
	echo $(EMACS22_CONFFILES) | sed -e 's/ /\n/g' > $(EMACS22_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EMACS22_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
emacs22-ipk: $(EMACS22_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
emacs22-clean:
	rm -f $(EMACS22_BUILD_DIR)/.built
	-$(MAKE) -C $(EMACS22_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
emacs22-dirclean:
	rm -rf $(BUILD_DIR)/$(EMACS22_DIR) $(EMACS22_BUILD_DIR) $(EMACS22_IPK_DIR) $(EMACS22_IPK)
#
#
# Some sanity check for the package.
#
emacs22-check: $(EMACS22_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(EMACS22_IPK)
