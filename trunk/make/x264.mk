###########################################################
#
# x264
#
###########################################################

#
# X264_REPOSITORY defines the upstream location of the source code
# for the package.  X264_DIR is the directory which is created when
# this cvs module is checked out.
#

X264_REPOSITORY=svn://svn.videolan.org/x264/trunk
X264_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
X264_DESCRIPTION=A free library for encoding H264/AVC video streams.
X264_SECTION=video
X264_PRIORITY=optional
X264_DEPENDS=
X264_SUGGESTS=
X264_CONFLICTS=

#
# Software downloaded from SVN repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#

#
# If you want to use a date, uncomment the variables below and modify
# X264_SVN_DATE
#

#X264_SVN_DATE=20050201
#X264_VERSION=cvs$(X264_SVN_DATE)
#X264_SVN_OPTS=-D $(X264_SVN_DATE)

#
# If you want to use a tag, uncomment the variables below and modify
# X264_SVN_TAG and X264_SVN_VERSION
#

#X264_SVN_TAG=version_1_2_3
#X264_SVN_REV=622
ifdef X264_SVN_REV
X264_VERSION=0.0+svn$(X264_SVN_REV)
X264_SOURCE=x264-$(X264_VERSION).tar.gz
X264_DIR=x264
else
X264_SITE=ftp://ftp.videolan.org/pub/videolan/x264/snapshots
X264_UPSTREAM_VERSION ?= snapshot-20090220-2245
X264_DIR=x264-$(X264_UPSTREAM_VERSION)
X264_SOURCE=x264-$(X264_UPSTREAM_VERSION).tar.bz2
X264_VERSION ?= 0.0.20090220-svn2245
X264_UNZIP=bzcat
endif
#X264_SVN_OPTS=-r $(X264_SVN_TAG)


#
# X264_IPK_VERSION should be incremented when the ipk changes.
#
X264_IPK_VERSION=1

#
# X264_CONFFILES should be a list of user-editable files
X264_CONFFILES=

#
# X264_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#

ifeq (snapshot-20081231-2245, $(X264_UPSTREAM_VERSION))
X264_PATCHES=$(X264_SOURCE_DIR)/common-cpu.c-2008.patch
else
X264_PATCHES=$(X264_SOURCE_DIR)/common-cpu.c.patch
endif


ifeq (uclibc, $(LIBC_STYLE))
X264_PATCHES += $(X264_SOURCE_DIR)/encoder-analyse.c.patch
endif

#$(X264_SOURCE_DIR)/common-ppc-ppccommon.h.patch \
$(X264_SOURCE_DIR)/common-ppc-dct.c.patch \

ifeq ($(OPTWARE_TARGET), $(filter openwrt-ixp4xx ts101, $(OPTWARE_TARGET)))
X264_PATCHES+=$(X264_SOURCE_DIR)/logf-wrapper.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
X264_CPPFLAGS=
X264_LDFLAGS=

#
# X264_BUILD_DIR is the directory in which the build is done.
# X264_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# X264_IPK_DIR is the directory in which the ipk is built.
# X264_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
X264_BUILD_DIR=$(BUILD_DIR)/x264
X264_SOURCE_DIR=$(SOURCE_DIR)/x264
X264_IPK_DIR=$(BUILD_DIR)/x264-$(X264_VERSION)-ipk
X264_IPK=$(BUILD_DIR)/x264_$(X264_VERSION)-$(X264_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: x264-source x264-unpack x264 x264-stage x264-ipk x264-clean x264-dirclean x264-check

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with SVN
#
$(DL_DIR)/$(X264_SOURCE):
ifdef X264_SVN_REV
	( cd $(BUILD_DIR) ; \
		rm -rf $(X264_DIR) && \
		svn co -r $(X264_SVN_REV) $(X264_REPOSITORY) $(X264_DIR) && \
		tar -czf $@ $(X264_DIR) && \
		rm -rf $(X264_DIR) \
	)
else
	$(WGET) -P $(@D) $(X264_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

x264-source: $(DL_DIR)/$(X264_SOURCE)

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(X264_BUILD_DIR)/.configured: $(DL_DIR)/$(X264_SOURCE) make/x264.mk
ifeq ($(TARGET_ARCH), $(filter i686 x86_64, $(TARGET_ARCH)))
	$(MAKE) yasm-host-stage
endif
	rm -rf $(BUILD_DIR)/$(X264_DIR) $(@D)
	$(X264_UNZIP) $(DL_DIR)/$(X264_SOURCE) | tar -C $(BUILD_DIR) -xf -
	if test -n "$(X264_PATCHES)" ; \
		then cat $(X264_PATCHES) | \
		patch -d $(BUILD_DIR)/$(X264_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(X264_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(X264_DIR) $(@D) ; \
	fi
	sed -i -e '/MACHINE=/s|$$(./config.guess)|$(TARGET_ARCH)-unknown-linux-gnu|' $(@D)/configure
ifeq ($(TARGET_ARCH), $(filter i686 x86_64, $(TARGET_ARCH)))
	sed -i -e 's|AS="yasm"|AS="$(HOST_STAGING_PREFIX)/bin/yasm"|' $(@D)/configure
endif
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		AS="$(TARGET_CC)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(X264_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(X264_LDFLAGS)" \
		./configure \
		--host=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--enable-shared \
	)
#		--build=$(GNU_HOST_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-asm \
		--disable-nls \
		;
	touch $@

x264-unpack: $(X264_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(X264_BUILD_DIR)/.built: $(X264_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
x264: $(X264_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(X264_BUILD_DIR)/.staged: $(X264_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	sed -i -e 's|^prefix=.*|prefix=$(STAGING_PREFIX)|' $(STAGING_LIB_DIR)/pkgconfig/x264.pc
	touch $@

x264-stage: $(X264_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/x264
#
$(X264_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: x264" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(X264_PRIORITY)" >>$@
	@echo "Section: $(X264_SECTION)" >>$@
	@echo "Version: $(X264_VERSION)-$(X264_IPK_VERSION)" >>$@
	@echo "Maintainer: $(X264_MAINTAINER)" >>$@
	@echo "Source: $(X264_REPOSITORY)" >>$@
	@echo "Description: $(X264_DESCRIPTION)" >>$@
	@echo "Depends: $(X264_DEPENDS)" >>$@
	@echo "Suggests: $(X264_SUGGESTS)" >>$@
	@echo "Conflicts: $(X264_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(X264_IPK_DIR)/opt/sbin or $(X264_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(X264_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(X264_IPK_DIR)/opt/etc/x264/...
# Documentation files should be installed in $(X264_IPK_DIR)/opt/doc/x264/...
# Daemon startup scripts should be installed in $(X264_IPK_DIR)/opt/etc/init.d/S??x264
#
# You may need to patch your application to make it use these locations.
#
$(X264_IPK): $(X264_BUILD_DIR)/.built
	rm -rf $(X264_IPK_DIR) $(BUILD_DIR)/x264_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(X264_BUILD_DIR) DESTDIR=$(X264_IPK_DIR) install
	rm -f $(X264_IPK_DIR)/opt/lib/libx264.a
#	install -d $(X264_IPK_DIR)/opt/etc/
#	install -m 644 $(X264_SOURCE_DIR)/x264.conf $(X264_IPK_DIR)/opt/etc/x264.conf
#	install -d $(X264_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(X264_SOURCE_DIR)/rc.x264 $(X264_IPK_DIR)/opt/etc/init.d/SXXx264
	$(MAKE) $(X264_IPK_DIR)/CONTROL/control
#	install -m 755 $(X264_SOURCE_DIR)/postinst $(X264_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(X264_SOURCE_DIR)/prerm $(X264_IPK_DIR)/CONTROL/prerm
	echo $(X264_CONFFILES) | sed -e 's/ /\n/g' > $(X264_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(X264_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
x264-ipk: $(X264_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
x264-clean:
	rm -f $(X264_BUILD_DIR)/.built
	-$(MAKE) -C $(X264_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
x264-dirclean:
	rm -rf $(BUILD_DIR)/$(X264_DIR) $(X264_BUILD_DIR) $(X264_IPK_DIR) $(X264_IPK)

#
# Some sanity check for the package.
#
x264-check: $(X264_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
