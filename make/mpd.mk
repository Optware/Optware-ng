###########################################################
#
# mpd
#
###########################################################
#
# MPD_VERSION, MPD_SITE and MPD_SOURCE define
# the upstream location of the source code for the package.
# MPD_DIR is the directory which is created when the source
# archive is unpacked.
# MPD_UNZIP is the command used to unzip the source.
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
MPD_SITE=http://www.musicpd.org/uploads/files
#MPD_SVN_REPO=https://svn.musicpd.org/mpd/trunk
#MPD_SVN_REV=5324
MPD_VERSION=0.13.2
MPD_SOURCE=mpd-$(MPD_VERSION).tar.bz2
MPD_DIR=mpd-$(MPD_VERSION)
MPD_UNZIP=bzcat
MPD_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
MPD_DESCRIPTION=Music Player Daemon (MPD) allows remote access for playing music.
MPD_SECTION=audio
MPD_PRIORITY=optional
MPD_DEPENDS=audiofile, faad2, flac, libao, libid3tag, libmad, libmpcdec, libvorbisidec
ifeq (avahi, $(filter avahi, $(PACKAGES)))
MPD_DEPENDS+=, avahi
endif
MPD_SUGGESTS=
MPD_CONFLICTS=

#
# MPD_IPK_VERSION should be incremented when the ipk changes.
#
MPD_IPK_VERSION=1

#
# MPD_CONFFILES should be a list of user-editable files
#MPD_CONFFILES=/opt/etc/mpd.conf /opt/etc/init.d/SXXmpd

#
# MPD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# MPD_PATCHES=$(MPD_SOURCE_DIR)/flac-1.1.3.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
MPD_CPPFLAGS=
MPD_LDFLAGS=

ifeq (avahi, $(filter avahi, $(PACKAGES)))
MPD_CONFIGURE_OPTIONS=--with-zeroconf=avahi
else
MPD_CONFIGURE_OPTIONS=--without-zeroconf
endif

ifeq (no, $(IPV6))
MPD_CONFIGURE_OPTIONS+=--disable-ipv6
else
MPD_CONFIGURE_OPTIONS+=--enable-ipv6
endif

#
# MPD_BUILD_DIR is the directory in which the build is done.
# MPD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# MPD_IPK_DIR is the directory in which the ipk is built.
# MPD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
MPD_BUILD_DIR=$(BUILD_DIR)/mpd
MPD_SOURCE_DIR=$(SOURCE_DIR)/mpd
MPD_IPK_DIR=$(BUILD_DIR)/mpd-$(MPD_VERSION)-ipk
MPD_IPK=$(BUILD_DIR)/mpd_$(MPD_VERSION)-$(MPD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: mpd-source mpd-unpack mpd mpd-stage mpd-ipk mpd-clean mpd-dirclean mpd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(MPD_SOURCE):
ifndef MPD_SVN_REV
	$(WGET) -P $(DL_DIR) $(MPD_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(MPD_DIR) && \
		svn co -r$(MPD_SVN_REV) $(MPD_SVN_REPO) $(MPD_DIR) && \
		tar -cjf $@ $(MPD_DIR) && \
		rm -rf $(MPD_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
mpd-source: $(DL_DIR)/$(MPD_SOURCE) $(MPD_PATCHES)

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
$(MPD_BUILD_DIR)/.configured: $(DL_DIR)/$(MPD_SOURCE) $(MPD_PATCHES) make/mpd.mk
	$(MAKE) audiofile-stage
ifeq (avahi, $(filter avahi, $(PACKAGES)))
	$(MAKE) avahi-stage
endif
	$(MAKE) faad2-stage
	$(MAKE) flac-stage
	$(MAKE) libao-stage
	$(MAKE) libid3tag-stage
	$(MAKE) libmad-stage
	$(MAKE) libmpcdec-stage
	$(MAKE) libvorbisidec-stage
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR)
	$(MPD_UNZIP) $(DL_DIR)/$(MPD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(MPD_PATCHES)" ; \
		then cat $(MPD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(MPD_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(MPD_DIR)" != "$(MPD_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR) ; \
	fi
#	ACLOCAL="aclocal-1.9 -I m4" AUTOMAKE=automake-1.9 autoreconf -vif $(@D)
#	sed -i -e '/LIBFLAC_LIBS="$$LIBFLAC_LIBS/s|-lFLAC|-lFLAC -logg|' $(@D)/configure
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(MPD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(MPD_LDFLAGS)" \
		PKG_CONFIG_PATH=$(STAGING_LIB_DIR)/pkgconfig \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		\
		--enable-aac \
		--enable-ao \
		--enable-audiofile \
		--enable-flac \
		--enable-id3 \
		--enable-mp3 \
		--enable-mpc \
		--enable-oggvorbis \
		$(MPD_CONFIGURE_OPTIONS) \
		\
		--with-ao=$(STAGING_PREFIX) \
		--with-audiofile-prefix=$(STAGING_PREFIX) \
		--with-faad=$(STAGING_PREFIX) \
		--with-id3tag=$(STAGING_PREFIX) \
		--with-libFLAC=$(STAGING_PREFIX) \
		--with-mad=$(STAGING_PREFIX) \
		--with-flac=$(STAGING_PREFIX) \
		--with-tremor=$(STAGING_PREFIX) \
		\
		--disable-nls \
		--disable-static \
	)
	sed -i -e '/^MPD_CFLAGS/s| -I$${prefix}/include||g;' \
		$(@D)/src/Makefile \
		$(@D)/src/*/Makefile
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

mpd-unpack: $(MPD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(MPD_BUILD_DIR)/.built: $(MPD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(MPD_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
mpd: $(MPD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(MPD_BUILD_DIR)/.staged: $(MPD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(MPD_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

mpd-stage: $(MPD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/mpd
#
$(MPD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: mpd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(MPD_PRIORITY)" >>$@
	@echo "Section: $(MPD_SECTION)" >>$@
	@echo "Version: $(MPD_VERSION)-$(MPD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(MPD_MAINTAINER)" >>$@
ifdef MPD_SVN_REV
	@echo "Source: $(MPD_SVN_REPO)" >>$@
else
	@echo "Source: $(MPD_SITE)" >>$@
endif
	@echo "Description: $(MPD_DESCRIPTION)" >>$@
	@echo "Depends: $(MPD_DEPENDS)" >>$@
	@echo "Suggests: $(MPD_SUGGESTS)" >>$@
	@echo "Conflicts: $(MPD_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(MPD_IPK_DIR)/opt/sbin or $(MPD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(MPD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(MPD_IPK_DIR)/opt/etc/mpd/...
# Documentation files should be installed in $(MPD_IPK_DIR)/opt/doc/mpd/...
# Daemon startup scripts should be installed in $(MPD_IPK_DIR)/opt/etc/init.d/S??mpd
#
# You may need to patch your application to make it use these locations.
#
$(MPD_IPK): $(MPD_BUILD_DIR)/.built
	rm -rf $(MPD_IPK_DIR) $(BUILD_DIR)/mpd_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(MPD_BUILD_DIR) DESTDIR=$(MPD_IPK_DIR) install-strip
#	install -d $(MPD_IPK_DIR)/opt/etc/
#	install -m 644 $(MPD_SOURCE_DIR)/mpd.conf $(MPD_IPK_DIR)/opt/etc/mpd.conf
#	install -d $(MPD_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(MPD_SOURCE_DIR)/rc.mpd $(MPD_IPK_DIR)/opt/etc/init.d/SXXmpd
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXmpd
	$(MAKE) $(MPD_IPK_DIR)/CONTROL/control
#	install -m 755 $(MPD_SOURCE_DIR)/postinst $(MPD_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(MPD_SOURCE_DIR)/prerm $(MPD_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
#	echo $(MPD_CONFFILES) | sed -e 's/ /\n/g' > $(MPD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(MPD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
mpd-ipk: $(MPD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
mpd-clean:
	rm -f $(MPD_BUILD_DIR)/.built
	-$(MAKE) -C $(MPD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
mpd-dirclean:
	rm -rf $(BUILD_DIR)/$(MPD_DIR) $(MPD_BUILD_DIR) $(MPD_IPK_DIR) $(MPD_IPK)
#
#
# Some sanity check for the package.
#
mpd-check: $(MPD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(MPD_IPK)
