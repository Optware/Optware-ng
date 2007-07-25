###########################################################
#
# uemacs
#
###########################################################
#
# UEMACS_VERSION, UEMACS_SITE and UEMACS_SOURCE define
# the upstream location of the source code for the package.
# UEMACS_DIR is the directory which is created when the source
# archive is unpacked.
# UEMACS_UNZIP is the command used to unzip the source.
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
UEMACS_SITE=http://www.kernel.org/pub/linux/kernel/uemacs
UEMACS_VERSION=4.0.15
UEMACS_SOURCE=em-$(UEMACS_VERSION)-lt.tar.gz
UEMACS_DIR=em-$(UEMACS_VERSION)-lt
UEMACS_UNZIP=zcat
UEMACS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
UEMACS_DESCRIPTION=uEmacs/PK, Full screen editor based on MicroEMACS 3.9e.
UEMACS_SECTION=editor
UEMACS_PRIORITY=optional
UEMACS_DEPENDS=ncurses
UEMACS_SUGGESTS=
UEMACS_CONFLICTS=

#
# UEMACS_IPK_VERSION should be incremented when the ipk changes.
#
UEMACS_IPK_VERSION=1

#
# UEMACS_CONFFILES should be a list of user-editable files
UEMACS_CONFFILES=/opt/etc/.uemacsrc

#
# UEMACS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
UEMACS_PATCHES=$(UEMACS_SOURCE_DIR)/epath.h.patch $(UEMACS_SOURCE_DIR)/static-forward-decl.patch
ifeq (wl500g, $(OPTWARE_TARGET))
UEMACS_PATCHES+=$(UEMACS_SOURCE_DIR)/cuserid.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
UEMACS_CPPFLAGS=-include $(TARGET_INCDIR)/errno.h
UEMACS_LDFLAGS=

#
# UEMACS_BUILD_DIR is the directory in which the build is done.
# UEMACS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# UEMACS_IPK_DIR is the directory in which the ipk is built.
# UEMACS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
UEMACS_BUILD_DIR=$(BUILD_DIR)/uemacs
UEMACS_SOURCE_DIR=$(SOURCE_DIR)/uemacs
UEMACS_IPK_DIR=$(BUILD_DIR)/uemacs-$(UEMACS_VERSION)-ipk
UEMACS_IPK=$(BUILD_DIR)/uemacs_$(UEMACS_VERSION)-$(UEMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: uemacs-source uemacs-unpack uemacs uemacs-stage uemacs-ipk uemacs-clean uemacs-dirclean uemacs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(UEMACS_SOURCE):
	$(WGET) -P $(DL_DIR) $(UEMACS_SITE)/$(UEMACS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(UEMACS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
uemacs-source: $(DL_DIR)/$(UEMACS_SOURCE) $(UEMACS_PATCHES)

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
$(UEMACS_BUILD_DIR)/.configured: $(DL_DIR)/$(UEMACS_SOURCE) $(UEMACS_PATCHES) make/uemacs.mk
	$(MAKE) ncurses-stage
	rm -rf $(BUILD_DIR)/$(UEMACS_DIR) $(UEMACS_BUILD_DIR)
	$(UEMACS_UNZIP) $(DL_DIR)/$(UEMACS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(UEMACS_PATCHES)" ; \
		then cat $(UEMACS_PATCHES) | \
		patch -bd $(BUILD_DIR)/$(UEMACS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(UEMACS_DIR)" != "$(UEMACS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(UEMACS_DIR) $(UEMACS_BUILD_DIR) ; \
	fi
	sed -i -e 's|strip|$(STRIP_COMMAND)|' $(UEMACS_BUILD_DIR)/makefile
#	(cd $(UEMACS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(UEMACS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(UEMACS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(UEMACS_BUILD_DIR)/libtool
	touch $@

uemacs-unpack: $(UEMACS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(UEMACS_BUILD_DIR)/.built: $(UEMACS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(UEMACS_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS) $(UEMACS_CPPFLAGS)" \
		LIBS="-lncurses $(STAGING_LDFLAGS) $(UEMACS_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
uemacs: $(UEMACS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(UEMACS_BUILD_DIR)/.staged: $(UEMACS_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(UEMACS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

uemacs-stage: $(UEMACS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/uemacs
#
$(UEMACS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: uemacs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(UEMACS_PRIORITY)" >>$@
	@echo "Section: $(UEMACS_SECTION)" >>$@
	@echo "Version: $(UEMACS_VERSION)-$(UEMACS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(UEMACS_MAINTAINER)" >>$@
	@echo "Source: $(UEMACS_SITE)/$(UEMACS_SOURCE)" >>$@
	@echo "Description: $(UEMACS_DESCRIPTION)" >>$@
	@echo "Depends: $(UEMACS_DEPENDS)" >>$@
	@echo "Suggests: $(UEMACS_SUGGESTS)" >>$@
	@echo "Conflicts: $(UEMACS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(UEMACS_IPK_DIR)/opt/sbin or $(UEMACS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(UEMACS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(UEMACS_IPK_DIR)/opt/etc/uemacs/...
# Documentation files should be installed in $(UEMACS_IPK_DIR)/opt/doc/uemacs/...
# Daemon startup scripts should be installed in $(UEMACS_IPK_DIR)/opt/etc/init.d/S??uemacs
#
# You may need to patch your application to make it use these locations.
#
$(UEMACS_IPK): $(UEMACS_BUILD_DIR)/.built
	rm -rf $(UEMACS_IPK_DIR) $(BUILD_DIR)/uemacs_*_$(TARGET_ARCH).ipk
	install -d $(UEMACS_IPK_DIR)/opt/bin $(UEMACS_IPK_DIR)/opt/etc
	$(MAKE) -C $(UEMACS_BUILD_DIR) \
		BINDIR=$(UEMACS_IPK_DIR)/opt/bin \
		LIBDIR=$(UEMACS_IPK_DIR)/opt/etc \
		install
	cd $(UEMACS_IPK_DIR)/opt/bin; ln -s em uemacs
	mv $(UEMACS_IPK_DIR)/opt/etc/.emacsrc $(UEMACS_IPK_DIR)/opt/etc/.uemacsrc
	mv $(UEMACS_IPK_DIR)/opt/etc/emacs.hlp $(UEMACS_IPK_DIR)/opt/etc/uemacs.hlp
#	install -d $(UEMACS_IPK_DIR)/opt/etc/
#	install -m 644 $(UEMACS_SOURCE_DIR)/uemacs.conf $(UEMACS_IPK_DIR)/opt/etc/uemacs.conf
#	install -d $(UEMACS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(UEMACS_SOURCE_DIR)/rc.uemacs $(UEMACS_IPK_DIR)/opt/etc/init.d/SXXuemacs
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UEMACS_IPK_DIR)/opt/etc/init.d/SXXuemacs
	$(MAKE) $(UEMACS_IPK_DIR)/CONTROL/control
#	install -m 755 $(UEMACS_SOURCE_DIR)/postinst $(UEMACS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UEMACS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(UEMACS_SOURCE_DIR)/prerm $(UEMACS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(UEMACS_IPK_DIR)/CONTROL/prerm
	echo $(UEMACS_CONFFILES) | sed -e 's/ /\n/g' > $(UEMACS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(UEMACS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
uemacs-ipk: $(UEMACS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
uemacs-clean:
	rm -f $(UEMACS_BUILD_DIR)/.built
	-$(MAKE) -C $(UEMACS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
uemacs-dirclean:
	rm -rf $(BUILD_DIR)/$(UEMACS_DIR) $(UEMACS_BUILD_DIR) $(UEMACS_IPK_DIR) $(UEMACS_IPK)
#
#
# Some sanity check for the package.
#
uemacs-check: $(UEMACS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(UEMACS_IPK)
