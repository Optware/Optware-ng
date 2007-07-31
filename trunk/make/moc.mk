###########################################################
#
# moc
#
###########################################################
#
# MOC_VERSION, MOC_SITE and MOC_SOURCE define
# the upstream location of the source code for the package.
# MOC_DIR is the directory which is created when the source
# archive is unpacked.
# MOC_UNZIP is the command used to unzip the source.
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
MOC_SITE=ftp://ftp.daper.net/pub/soft/moc/stable
MOC_VERSION=2.4.3
MOC_SOURCE=moc-$(MOC_VERSION).tar.bz2
MOC_DIR=moc-$(MOC_VERSION)
MOC_UNZIP=bzcat
MOC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MOC_DESCRIPTION=MOC (music on console) is a console audio player with a simple ncurses interface in playmp3list style.
MOC_SECTION=audio
MOC_PRIORITY=optional
MOC_DEPENDS=ncursesw
MOC_SUGGESTS=flac, libcurl, libid3tag, libmad, libogg, libsndfile, libvorbis, speex, zlib
MOC_CONFLICTS=

#
# MOC_IPK_VERSION should be incremented when the ipk changes.
#
MOC_IPK_VERSION=1

#
# MOC_CONFFILES should be a list of user-editable files
#MOC_CONFFILES=/opt/etc/moc.conf /opt/etc/init.d/SXXmoc

#
# MOC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#MOC_PATCHES=$(MOC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MOC_CPPFLAGS=
MOC_LDFLAGS=

ifneq ($(TARGET_CC), $(HOSTCC))
MOC_CONFIGURE_ENV=ac_cv_func_malloc_0_nonnull=yes \
ac_cv_func_strerror_r=yes \
PATH=$(STAGING_PREFIX)/bin:$$PATH
#ac_cv_prog_CURL_CONFIG=$(STAGING_PREFIX)/bin/curl-config
endif

#
# MOC_BUILD_DIR is the directory in which the build is done.
# MOC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MOC_IPK_DIR is the directory in which the ipk is built.
# MOC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MOC_BUILD_DIR=$(BUILD_DIR)/moc
MOC_SOURCE_DIR=$(SOURCE_DIR)/moc
MOC_IPK_DIR=$(BUILD_DIR)/moc-$(MOC_VERSION)-ipk
MOC_IPK=$(BUILD_DIR)/moc_$(MOC_VERSION)-$(MOC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: moc-source moc-unpack moc moc-stage moc-ipk moc-clean moc-dirclean moc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MOC_SOURCE):
	$(WGET) -P $(DL_DIR) $(MOC_SITE)/$(MOC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(MOC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
moc-source: $(DL_DIR)/$(MOC_SOURCE) $(MOC_PATCHES)

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
$(MOC_BUILD_DIR)/.configured: $(DL_DIR)/$(MOC_SOURCE) $(MOC_PATCHES) make/moc.mk
#	$(MAKE) alsa-lib-stage
	$(MAKE) flac-stage
#	$(MAKE) ffmpeg-stage
	$(MAKE) libcurl-stage
	$(MAKE) libid3tag-stage
	$(MAKE) libmad-stage
#	$(MAKE) libmpcdec-stage
	$(MAKE) libogg-stage
	$(MAKE) libsndfile-stage
	$(MAKE) libvorbis-stage
	$(MAKE) ncursesw-stage
	$(MAKE) speex-stage
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(MOC_DIR) $(MOC_BUILD_DIR)
	$(MOC_UNZIP) $(DL_DIR)/$(MOC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MOC_PATCHES)" ; \
		then cat $(MOC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MOC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MOC_DIR)" != "$(MOC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MOC_DIR) $(MOC_BUILD_DIR) ; \
	fi
	sed -i -e '/--exists.*alsa/s/alsa /noalsa /g' $(MOC_BUILD_DIR)/configure
	(cd $(MOC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MOC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MOC_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		$(MOC_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--without-ffmpeg \
		--without-musepack \
		--with-libFLAC=$(STAGING_PREFIX) \
		$(MOC_CONFIGURE_OPTS) \
	)
	$(PATCH_LIBTOOL) $(MOC_BUILD_DIR)/libtool
	touch $@

moc-unpack: $(MOC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MOC_BUILD_DIR)/.built: $(MOC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MOC_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
moc: $(MOC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MOC_BUILD_DIR)/.staged: $(MOC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MOC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

moc-stage: $(MOC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/moc
#
$(MOC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: moc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MOC_PRIORITY)" >>$@
	@echo "Section: $(MOC_SECTION)" >>$@
	@echo "Version: $(MOC_VERSION)-$(MOC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MOC_MAINTAINER)" >>$@
	@echo "Source: $(MOC_SITE)/$(MOC_SOURCE)" >>$@
	@echo "Description: $(MOC_DESCRIPTION)" >>$@
	@echo "Depends: $(MOC_DEPENDS)" >>$@
	@echo "Suggests: $(MOC_SUGGESTS)" >>$@
	@echo "Conflicts: $(MOC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MOC_IPK_DIR)/opt/sbin or $(MOC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MOC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MOC_IPK_DIR)/opt/etc/moc/...
# Documentation files should be installed in $(MOC_IPK_DIR)/opt/doc/moc/...
# Daemon startup scripts should be installed in $(MOC_IPK_DIR)/opt/etc/init.d/S??moc
#
# You may need to patch your application to make it use these locations.
#
$(MOC_IPK): $(MOC_BUILD_DIR)/.built
	rm -rf $(MOC_IPK_DIR) $(BUILD_DIR)/moc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MOC_BUILD_DIR) DESTDIR=$(MOC_IPK_DIR) install-strip
#	install -d $(MOC_IPK_DIR)/opt/etc/
#	install -m 644 $(MOC_SOURCE_DIR)/moc.conf $(MOC_IPK_DIR)/opt/etc/moc.conf
#	install -d $(MOC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MOC_SOURCE_DIR)/rc.moc $(MOC_IPK_DIR)/opt/etc/init.d/SXXmoc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOC_IPK_DIR)/opt/etc/init.d/SXXmoc
	$(MAKE) $(MOC_IPK_DIR)/CONTROL/control
#	install -m 755 $(MOC_SOURCE_DIR)/postinst $(MOC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MOC_SOURCE_DIR)/prerm $(MOC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(MOC_IPK_DIR)/CONTROL/prerm
	echo $(MOC_CONFFILES) | sed -e 's/ /\n/g' > $(MOC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MOC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
moc-ipk: $(MOC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
moc-clean:
	rm -f $(MOC_BUILD_DIR)/.built
	-$(MAKE) -C $(MOC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
moc-dirclean:
	rm -rf $(BUILD_DIR)/$(MOC_DIR) $(MOC_BUILD_DIR) $(MOC_IPK_DIR) $(MOC_IPK)
#
#
# Some sanity check for the package.
#
moc-check: $(MOC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MOC_IPK)
