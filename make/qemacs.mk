###########################################################
#
# qemacs
#
###########################################################
#
# QEMACS_VERSION, QEMACS_SITE and QEMACS_SOURCE define
# the upstream location of the source code for the package.
# QEMACS_DIR is the directory which is created when the source
# archive is unpacked.
# QEMACS_UNZIP is the command used to unzip the source.
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
QEMACS_SITE=http://fabrice.bellard.free.fr/qemacs
QEMACS_VERSION=0.3.1
QEMACS_SOURCE=qemacs-$(QEMACS_VERSION).tar.gz
QEMACS_DIR=qemacs-$(QEMACS_VERSION)
QEMACS_UNZIP=zcat
QEMACS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
QEMACS_DESCRIPTION=QEmacs (for Quick Emacs) is a very small but powerful UNIX editor.
QEMACS_SECTION=editor
QEMACS_PRIORITY=optional
QEMACS_DEPENDS=
QEMACS_SUGGESTS=
QEMACS_CONFLICTS=

#
# QEMACS_IPK_VERSION should be incremented when the ipk changes.
#
QEMACS_IPK_VERSION=1

#
# QEMACS_CONFFILES should be a list of user-editable files
#QEMACS_CONFFILES=/opt/etc/qemacs.conf /opt/etc/init.d/SXXqemacs

#
# QEMACS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
QEMACS_PATCHES=$(QEMACS_SOURCE_DIR)/gcc4.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QEMACS_CPPFLAGS=-fno-strict-aliasing
QEMACS_LDFLAGS=

#
# QEMACS_BUILD_DIR is the directory in which the build is done.
# QEMACS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QEMACS_IPK_DIR is the directory in which the ipk is built.
# QEMACS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QEMACS_BUILD_DIR=$(BUILD_DIR)/qemacs
QEMACS_SOURCE_DIR=$(SOURCE_DIR)/qemacs
QEMACS_IPK_DIR=$(BUILD_DIR)/qemacs-$(QEMACS_VERSION)-ipk
QEMACS_IPK=$(BUILD_DIR)/qemacs_$(QEMACS_VERSION)-$(QEMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: qemacs-source qemacs-unpack qemacs qemacs-stage qemacs-ipk qemacs-clean qemacs-dirclean qemacs-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QEMACS_SOURCE):
	$(WGET) -P $(DL_DIR) $(QEMACS_SITE)/$(QEMACS_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(QEMACS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qemacs-source: $(DL_DIR)/$(QEMACS_SOURCE) $(QEMACS_PATCHES)

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
$(QEMACS_BUILD_DIR)/.configured: $(DL_DIR)/$(QEMACS_SOURCE) $(QEMACS_PATCHES) make/qemacs.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(QEMACS_DIR) $(QEMACS_BUILD_DIR)
	$(QEMACS_UNZIP) $(DL_DIR)/$(QEMACS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QEMACS_PATCHES)" ; \
		then cat $(QEMACS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(QEMACS_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(QEMACS_DIR)" != "$(QEMACS_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(QEMACS_DIR) $(QEMACS_BUILD_DIR) ; \
	fi
	(cd $(QEMACS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QEMACS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QEMACS_LDFLAGS)" \
		CFLAGS="$(STAGING_CPPFLAGS) $(QEMACS_CPPFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-x11 \
		--disable-xv \
		--disable-xrender \
		--disable-html \
		--disable-png \
		--cc=$(TARGET_CC) \
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/QE_VERSION/s|$$|\\|' $(QEMACS_BUILD_DIR)/config.h
ifeq ($(OPTWARE_TARGET), $(filter slugosbe, $(OPTWARE_TARGET)))
# optimization causes segfault
	sed -i -e 's/-O2/-O0/' $(QEMACS_BUILD_DIR)/config.mak
endif
	sed -i \
		-e '/^install:/s| html2png||' \
		-e '/install.*html2png/s|^|#|' \
		$(QEMACS_BUILD_DIR)/Makefile
#	$(PATCH_LIBTOOL) $(QEMACS_BUILD_DIR)/libtool
	touch $@

qemacs-unpack: $(QEMACS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QEMACS_BUILD_DIR)/.built: $(QEMACS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(QEMACS_BUILD_DIR) STRIP="$(STRIP_COMMAND)" all
	touch $@

#
# This is the build convenience target.
#
qemacs: $(QEMACS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QEMACS_BUILD_DIR)/.staged: $(QEMACS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(QEMACS_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

qemacs-stage: $(QEMACS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qemacs
#
$(QEMACS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: qemacs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QEMACS_PRIORITY)" >>$@
	@echo "Section: $(QEMACS_SECTION)" >>$@
	@echo "Version: $(QEMACS_VERSION)-$(QEMACS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QEMACS_MAINTAINER)" >>$@
	@echo "Source: $(QEMACS_SITE)/$(QEMACS_SOURCE)" >>$@
	@echo "Description: $(QEMACS_DESCRIPTION)" >>$@
	@echo "Depends: $(QEMACS_DEPENDS)" >>$@
	@echo "Suggests: $(QEMACS_SUGGESTS)" >>$@
	@echo "Conflicts: $(QEMACS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QEMACS_IPK_DIR)/opt/sbin or $(QEMACS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QEMACS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(QEMACS_IPK_DIR)/opt/etc/qemacs/...
# Documentation files should be installed in $(QEMACS_IPK_DIR)/opt/doc/qemacs/...
# Daemon startup scripts should be installed in $(QEMACS_IPK_DIR)/opt/etc/init.d/S??qemacs
#
# You may need to patch your application to make it use these locations.
#
$(QEMACS_IPK): $(QEMACS_BUILD_DIR)/.built
	rm -rf $(QEMACS_IPK_DIR) $(BUILD_DIR)/qemacs_*_$(TARGET_ARCH).ipk
	install -d $(QEMACS_IPK_DIR)/opt/bin/ $(QEMACS_IPK_DIR)/opt/share/ $(QEMACS_IPK_DIR)/opt/man/man1
	$(MAKE) -C $(QEMACS_BUILD_DIR) install \
		DESTDIR=$(QEMACS_IPK_DIR) \
		prefix=$(QEMACS_IPK_DIR)/opt \
		;
#	install -d $(QEMACS_IPK_DIR)/opt/etc/
#	install -m 644 $(QEMACS_SOURCE_DIR)/qemacs.conf $(QEMACS_IPK_DIR)/opt/etc/qemacs.conf
#	install -d $(QEMACS_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(QEMACS_SOURCE_DIR)/rc.qemacs $(QEMACS_IPK_DIR)/opt/etc/init.d/SXXqemacs
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QEMACS_IPK_DIR)/opt/etc/init.d/SXXqemacs
	$(MAKE) $(QEMACS_IPK_DIR)/CONTROL/control
#	install -m 755 $(QEMACS_SOURCE_DIR)/postinst $(QEMACS_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QEMACS_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(QEMACS_SOURCE_DIR)/prerm $(QEMACS_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QEMACS_IPK_DIR)/CONTROL/prerm
	echo $(QEMACS_CONFFILES) | sed -e 's/ /\n/g' > $(QEMACS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMACS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qemacs-ipk: $(QEMACS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qemacs-clean:
	rm -f $(QEMACS_BUILD_DIR)/.built
	-$(MAKE) -C $(QEMACS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qemacs-dirclean:
	rm -rf $(BUILD_DIR)/$(QEMACS_DIR) $(QEMACS_BUILD_DIR) $(QEMACS_IPK_DIR) $(QEMACS_IPK)
#
#
# Some sanity check for the package.
#
qemacs-check: $(QEMACS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(QEMACS_IPK)
