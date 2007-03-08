###########################################################
#
# fuppes
#
###########################################################
#
# FUPPES_VERSION, FUPPES_SITE and FUPPES_SOURCE define
# the upstream location of the source code for the package.
# FUPPES_DIR is the directory which is created when the source
# archive is unpacked.
# FUPPES_UNZIP is the command used to unzip the source.
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
FUPPES_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/fuppes
FUPPES_VERSION=0.7.1
FUPPES_SOURCE=fuppes-$(FUPPES_VERSION).tar.gz
FUPPES_DIR=fuppes-$(FUPPES_VERSION)
FUPPES_UNZIP=zcat
FUPPES_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FUPPES_DESCRIPTION=FUPPES is a free, multiplatform UPnP (TM) A/V MediaServer, \
with optional on-the-fly audio transcondig from ogg/vorbis, mpc/musepack and FLAC to mp3.
FUPPES_SECTION=audio
FUPPES_PRIORITY=optional
FUPPES_DEPENDS=e2fsprogs, libxml2, pcre, sqlite
ifeq (taglib, $(filter taglib, $(PACKAGES)))
FUPPES_DEPENDS+=, taglib
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FUPPES_DEPENDS+=, libiconv
endif
FUPPES_SUGGESTS=
FUPPES_CONFLICTS=

#
# FUPPES_IPK_VERSION should be incremented when the ipk changes.
#
FUPPES_IPK_VERSION=1

#
# FUPPES_CONFFILES should be a list of user-editable files
#FUPPES_CONFFILES=/opt/etc/fuppes.conf /opt/etc/init.d/SXXfuppes

#
# FUPPES_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FUPPES_PATCHES=$(FUPPES_SOURCE_DIR)/libiconv.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FUPPES_CPPFLAGS=
FUPPES_LDFLAGS=
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
FUPPES_LDFLAGS+=-liconv
endif

#
# FUPPES_BUILD_DIR is the directory in which the build is done.
# FUPPES_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FUPPES_IPK_DIR is the directory in which the ipk is built.
# FUPPES_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FUPPES_BUILD_DIR=$(BUILD_DIR)/fuppes
FUPPES_SOURCE_DIR=$(SOURCE_DIR)/fuppes
FUPPES_IPK_DIR=$(BUILD_DIR)/fuppes-$(FUPPES_VERSION)-ipk
FUPPES_IPK=$(BUILD_DIR)/fuppes_$(FUPPES_VERSION)-$(FUPPES_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq (taglib, $(filter taglib, $(PACKAGES)))
FUPPES_WITH_TAGLIB=TAGLIB_CONFIG=$(STAGING_PREFIX)/bin/taglib-config
else
FUPPES_WITH_TAGLIB=ac_cv_path_TAGLIB_CONFIG=no
endif

.PHONY: fuppes-source fuppes-unpack fuppes fuppes-stage fuppes-ipk fuppes-clean fuppes-dirclean fuppes-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FUPPES_SOURCE):
	$(WGET) -P $(DL_DIR) $(FUPPES_SITE)/$(FUPPES_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(FUPPES_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
fuppes-source: $(DL_DIR)/$(FUPPES_SOURCE) $(FUPPES_PATCHES)

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
$(FUPPES_BUILD_DIR)/.configured: $(DL_DIR)/$(FUPPES_SOURCE) $(FUPPES_PATCHES) make/fuppes.mk
	$(MAKE) e2fsprogs-stage
	$(MAKE) libxml2-stage
	$(MAKE) pcre-stage
	$(MAKE) sqlite-stage
ifeq (taglib, $(filter taglib, $(PACKAGES)))
	$(MAKE) taglib-stage
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(FUPPES_DIR) $(FUPPES_BUILD_DIR)
	$(FUPPES_UNZIP) $(DL_DIR)/$(FUPPES_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(FUPPES_PATCHES)" ; \
		then cat $(FUPPES_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FUPPES_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FUPPES_DIR)" != "$(FUPPES_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FUPPES_DIR) $(FUPPES_BUILD_DIR) ; \
	fi
	(cd $(FUPPES_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(FUPPES_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(FUPPES_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(FUPPES_WITH_TAGLIB) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-lame \
		--disable-twolame \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(FUPPES_BUILD_DIR)/libtool
	touch $@

fuppes-unpack: $(FUPPES_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FUPPES_BUILD_DIR)/.built: $(FUPPES_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(FUPPES_BUILD_DIR) UUID_LIBS=$(STAGING_LIB_DIR)/libuuid.a
	$(MAKE) -C $(FUPPES_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
fuppes: $(FUPPES_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FUPPES_BUILD_DIR)/.staged: $(FUPPES_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(FUPPES_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

fuppes-stage: $(FUPPES_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/fuppes
#
$(FUPPES_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: fuppes" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FUPPES_PRIORITY)" >>$@
	@echo "Section: $(FUPPES_SECTION)" >>$@
	@echo "Version: $(FUPPES_VERSION)-$(FUPPES_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FUPPES_MAINTAINER)" >>$@
	@echo "Source: $(FUPPES_SITE)/$(FUPPES_SOURCE)" >>$@
	@echo "Description: $(FUPPES_DESCRIPTION)" >>$@
	@echo "Depends: $(FUPPES_DEPENDS)" >>$@
	@echo "Suggests: $(FUPPES_SUGGESTS)" >>$@
	@echo "Conflicts: $(FUPPES_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FUPPES_IPK_DIR)/opt/sbin or $(FUPPES_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FUPPES_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FUPPES_IPK_DIR)/opt/etc/fuppes/...
# Documentation files should be installed in $(FUPPES_IPK_DIR)/opt/doc/fuppes/...
# Daemon startup scripts should be installed in $(FUPPES_IPK_DIR)/opt/etc/init.d/S??fuppes
#
# You may need to patch your application to make it use these locations.
#
$(FUPPES_IPK): $(FUPPES_BUILD_DIR)/.built
	rm -rf $(FUPPES_IPK_DIR) $(BUILD_DIR)/fuppes_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(FUPPES_BUILD_DIR) DESTDIR=$(FUPPES_IPK_DIR) install-strip
#	install -d $(FUPPES_IPK_DIR)/opt/etc/
#	install -m 644 $(FUPPES_SOURCE_DIR)/fuppes.conf $(FUPPES_IPK_DIR)/opt/etc/fuppes.conf
#	install -d $(FUPPES_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FUPPES_SOURCE_DIR)/rc.fuppes $(FUPPES_IPK_DIR)/opt/etc/init.d/SXXfuppes
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUPPES_IPK_DIR)/opt/etc/init.d/SXXfuppes
	$(MAKE) $(FUPPES_IPK_DIR)/CONTROL/control
#	install -m 755 $(FUPPES_SOURCE_DIR)/postinst $(FUPPES_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUPPES_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FUPPES_SOURCE_DIR)/prerm $(FUPPES_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(FUPPES_IPK_DIR)/CONTROL/prerm
	echo $(FUPPES_CONFFILES) | sed -e 's/ /\n/g' > $(FUPPES_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FUPPES_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
fuppes-ipk: $(FUPPES_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
fuppes-clean:
	rm -f $(FUPPES_BUILD_DIR)/.built
	-$(MAKE) -C $(FUPPES_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
fuppes-dirclean:
	rm -rf $(BUILD_DIR)/$(FUPPES_DIR) $(FUPPES_BUILD_DIR) $(FUPPES_IPK_DIR) $(FUPPES_IPK)
#
#
# Some sanity check for the package.
#
fuppes-check: $(FUPPES_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(FUPPES_IPK)
