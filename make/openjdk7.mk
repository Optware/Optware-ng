###########################################################
#
# openjdk7
#
###########################################################
#
# OPENJDK7_VERSION, OPENJDK7_SITE and OPENJDK7_SOURCE define
# the upstream location of the source code for the package.
# OPENJDK7_DIR is the directory which is created when the source
# archive is unpacked.
# OPENJDK7_UNZIP is the command used to unzip the source.
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
OPENJDK7_HG=http://hg.openjdk.java.net/jdk7u/jdk7u
OPENJDK7_ICEDTEA_HG=http://icedtea.classpath.org/hg
OPENJDK7_SITE=http://icedtea.wildebeest.org/download
OPENJDK7_UPDATE_VERSION=99
OPENJDK7_BUILD_NUMBER=b00
OPENJDK7_VERSION=7u$(OPENJDK7_UPDATE_VERSION)-$(OPENJDK7_BUILD_NUMBER)
OPENJDK7_SOURCE=jdk$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_ICEDTEA_TAG=icedtea-2.7.0pre05
OPENJDK7_FOREST7_SOURCE=$(OPENJDK7_ICEDTEA_TAG).tar.bz2
OPENJDK7_CORBA_SOURCE=openjdk7u-corba-$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_HOTSPOT_SOURCE=openjdk7u-hotspot-$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_JAXP_SOURCE=openjdk7u-jaxp-$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_JAXWS_SOURCE=openjdk7u-jaxws-$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_JDK_SOURCE=openjdk7u-jdk-$(OPENJDK7_VERSION).tar.bz2
OPENJDK7_LANGTOOLS_SOURCE=openjdk7u-langtools-$(OPENJDK7_VERSION).tar.bz2

#OPENJDK7_DIR=openjdk7-$(OPENJDK7_VERSION)
OPENJDK7_UNZIP=bzcat
OPENJDK7_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENJDK7_JDK_DESCRIPTION=OpenJDK Java development environment. The packages are built using patches from the IcedTea project.
OPENJDK7_JRE_DESCRIPTION=Full OpenJDK Java runtime, using Zero VM. The packages are built using patches from the IcedTea project.
OPENJDK7_JRE_HEADLESS_DESCRIPTION=Minimal Java runtime - needed for executing non GUI Java programs, using Zero VM. The packages are built using patches from the IcedTea project.
OPENJDK7_SECTION=language
OPENJDK7_PRIORITY=optional
OPENJDK7_JRE_HEADLESS_DEPENDS=libstdc++, freetype, fontconfig, libffi, glib, libcups
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
OPENJDK7_JRE_HEADLESS_DEPENDS+=, libiconv
endif
OPENJDK7_JRE_DEPENDS=openjdk7-jre-headless, x11, xinerama, xrender, libxcomposite, gtk2, alsa-lib, xi, xtst
OPENJDK7_JDK_DEPENDS=openjdk7-jre

OPENJDK7_JRE_HEADLESS_SUGGESTS=
OPENJDK7_JRE_HEADLESS_CONFLICTS=

OPENJDK7_JRE_SUGGESTS=
OPENJDK7_JRE_CONFLICTS=

OPENJDK7_JDK_SUGGESTS=
OPENJDK7_JDK_CONFLICTS=

#
# OPENJDK7_IPK_VERSION should be incremented when the ipk changes.
#
OPENJDK7_IPK_VERSION=7

#
# OPENJDK7_JRE_HEADLESS_CONFFILES should be a list of user-editable files
OPENJDK7_JRE_HEADLESS_CONFFILES=\
$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/lib/$(OPENJDK7_LIBARCH)/jvm.cfg \
$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/lib/$(OPENJDK7_LIBARCH)/server/Xusage.txt \
$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/lib/security/cacerts \

OPENJDK7_JRE_HEADLESS_FILES=\
jre/ASSEMBLY_EXCEPTION \
jre/THIRD_PARTY_README \
jre/bin/java \
jre/bin/keytool \
jre/lib/$(OPENJDK7_LIBARCH)/headless/libmawt.so \
jre/lib/$(OPENJDK7_LIBARCH)/jli/libjli.so \
jre/lib/$(OPENJDK7_LIBARCH)/jvm.cfg \
jre/lib/$(OPENJDK7_LIBARCH)/libattach.so \
jre/lib/$(OPENJDK7_LIBARCH)/libawt.so \
jre/lib/$(OPENJDK7_LIBARCH)/libdt_socket.so \
jre/lib/$(OPENJDK7_LIBARCH)/libfontmanager.so \
jre/lib/$(OPENJDK7_LIBARCH)/libhprof.so \
jre/lib/$(OPENJDK7_LIBARCH)/libinstrument.so \
jre/lib/$(OPENJDK7_LIBARCH)/libj2gss.so \
jre/lib/$(OPENJDK7_LIBARCH)/libj2pcsc.so \
jre/lib/$(OPENJDK7_LIBARCH)/libj2pkcs11.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjaas_unix.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjava.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjava_crw_demo.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjawt.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjdwp.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjpeg.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjsdt.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjsig.so \
jre/lib/$(OPENJDK7_LIBARCH)/libjsound.so \
jre/lib/$(OPENJDK7_LIBARCH)/liblcms.so \
jre/lib/$(OPENJDK7_LIBARCH)/libmanagement.so \
jre/lib/$(OPENJDK7_LIBARCH)/libmlib_image.so \
jre/lib/$(OPENJDK7_LIBARCH)/libnet.so \
jre/lib/$(OPENJDK7_LIBARCH)/libnio.so \
jre/lib/$(OPENJDK7_LIBARCH)/libnpt.so \
jre/lib/$(OPENJDK7_LIBARCH)/libsctp.so \
jre/lib/$(OPENJDK7_LIBARCH)/libunpack.so \
jre/lib/$(OPENJDK7_LIBARCH)/libverify.so \
jre/lib/$(OPENJDK7_LIBARCH)/libzip.so \
jre/lib/$(OPENJDK7_LIBARCH)/server/Xusage.txt \
jre/lib/$(OPENJDK7_LIBARCH)/server/libjsig.so \
jre/lib/$(OPENJDK7_LIBARCH)/server/libjvm.so \
jre/lib/calendars.properties \
jre/lib/charsets.jar \
jre/lib/classlist \
jre/lib/cmm/CIEXYZ.pf \
jre/lib/cmm/GRAY.pf \
jre/lib/cmm/LINEAR_RGB.pf \
jre/lib/cmm/PYCC.pf \
jre/lib/cmm/sRGB.pf \
jre/lib/content-types.properties \
jre/lib/currency.data \
jre/lib/ext/dnsns.jar \
jre/lib/ext/localedata.jar \
jre/lib/ext/sunjce_provider.jar \
jre/lib/ext/sunpkcs11.jar \
jre/lib/ext/zipfs.jar \
jre/lib/flavormap.properties \
jre/lib/images/cursors/cursors.properties \
jre/lib/images/cursors/invalid32x32.gif \
jre/lib/images/cursors/motif_CopyDrop32x32.gif \
jre/lib/images/cursors/motif_CopyNoDrop32x32.gif \
jre/lib/images/cursors/motif_LinkDrop32x32.gif \
jre/lib/images/cursors/motif_LinkNoDrop32x32.gif \
jre/lib/images/cursors/motif_MoveDrop32x32.gif \
jre/lib/images/cursors/motif_MoveNoDrop32x32.gif \
jre/lib/jce.jar \
jre/lib/jexec \
jre/lib/jsse.jar \
jre/lib/jvm.hprof.txt \
jre/lib/logging.properties \
jre/lib/management-agent.jar \
jre/lib/management/jmxremote.access \
jre/lib/management/management.properties \
jre/lib/meta-index \
jre/lib/net.properties \
jre/lib/psfont.properties.ja \
jre/lib/psfontj2d.properties \
jre/lib/resources.jar \
jre/lib/rt.jar \
jre/lib/security/US_export_policy.jar \
jre/lib/security/cacerts \
jre/lib/security/java.policy \
jre/lib/security/java.security \
jre/lib/security/local_policy.jar \
jre/lib/sound.properties \
jre/lib/tz.properties \
jre/lib/zi \
release \



#
# OPENJDK7_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OPENJDK7_PATCHES=\
$(OPENJDK7_SOURCE_DIR)/skip_extract_openjdk.patch \
$(OPENJDK7_SOURCE_DIR)/fonts.patch \
$(OPENJDK7_SOURCE_DIR)/no-ecj-stringswitch.patch.patch \
$(OPENJDK7_SOURCE_DIR)/milestone.patch \
$(OPENJDK7_SOURCE_DIR)/jdk_build_version.patch \
$(OPENJDK7_SOURCE_DIR)/disable_cryptocheck.patch \
$(OPENJDK7_SOURCE_DIR)/remove-intree-libraries.patch \
$(OPENJDK7_SOURCE_DIR)/ant-javac.patch.patch \
$(OPENJDK7_SOURCE_DIR)/revert-6973616.patch.patch \
$(OPENJDK7_SOURCE_DIR)/revert-6941137.patch.patch \
$(OPENJDK7_SOURCE_DIR)/ecj-trywithresources.patch.patch \

OPENJDK7_OPENJDK_PATCHES=\
$(OPENJDK7_SOURCE_DIR)/openjdk/gcc_definitions.uclibc.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/os_linux.uclibc.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/xtoolkit.uclibc.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/fix-ipv6-init.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/rhbz1206656_fix_current_stack_pointer.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/os_linux.fix-i386-zero-build.patch \
$(OPENJDK7_SOURCE_DIR)/openjdk/hotspot-powerpcspe.diff \
$(OPENJDK7_SOURCE_DIR)/openjdk/hotspot-no-march-i586.diff \
$(OPENJDK7_SOURCE_DIR)/openjdk/native_jni_return_null_not_false.patch \

#
# OpenJDK used for bootstrap. Will check OpenJDK7 Ubuntu standart location
#

ifneq ($(shell ls /usr/lib/jvm/java-7-openjdk-*/bin/java 2> /dev/null), )
OPENJDK7_BOOSTSTRAPJDK=$(shell cd `dirname $$(ls /usr/lib/jvm/java-7-openjdk-*/bin/java|head -1)`/.. && pwd)
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#

OPENJDK7_CPPFLAGS=-DJDK_MAJOR_VERSION=\"1\" -DJDK_MINOR_VERSION=\"7\" -DJDK_MICRO_VERSION=\"0\" \
-DJDK_UPDATE_VERSION=\"$(OPENJDK7_UPDATE_VERSION)\" -DJDK_BUILD_NUMBER=\"$(OPENJDK7_BUILD_NUMBER)\" \
-D__sun_jdk -DMLIB_NO_LIBSUNMATH \
-g3 -I$(OPENJDK7_BUILD_DIR)/openjdk/jdk/src/share/npt \
-I$(OPENJDK7_BUILD_DIR)/openjdk/jdk/src/share/native/sun/awt/image/jpeg \
-I$(OPENJDK7_BUILD_DIR)/openjdk/jdk/src/share/native/sun/awt/libpng \
-I$(OPENJDK7_BUILD_DIR)/openjdk/jdk/src/share/native/sun/java2d/cmm/lcms \
$(STAGING_CPPFLAGS)
# commas in LDFLAGS cause make functions parse errors
OPENJDK7_LDFLAGS=-L$(OPENJDK7_BUILD_DIR)/openjdk.build/lib/$(OPENJDK7_LIBARCH) \
-L$(OPENJDK7_BUILD_DIR)/openjdk.build/lib/$(OPENJDK7_LIBARCH)/server \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk7/$(OPENJDK7_LIBARCH)/server \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk7/$(OPENJDK7_LIBARCH)/jli \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk7/$(OPENJDK7_LIBARCH) \
$(TARGET_LDFLAGS) -L$(STAGING_LIB_DIR) -Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib \
-Xlinker -rpath-link -Xlinker $(STAGING_LIB_DIR) \
-lm -ldl -lz
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
OPENJDK7_LDFLAGS += -liconv
endif

OPENJDK7_MAKE_ARGS=\
		$(TARGET_CONFIGURE_OPTS) \
		CXX="$(TARGET_CXX) -std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		CC="$(TARGET_CC) -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		LD=$(TARGET_CC) \
		OBJCOPY=$(TARGET_CROSS)objcopy \
		NIO_CC=$(HOSTCC) \
		$(strip $(if $(MAKE_JOBS), PARALLEL_COMPILE_JOBS=$(MAKE_JOBS))) \
		CC_HIGHEST_OPT=$(strip $(if $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)), -O2, -O3)) \
		CC_HIGHER_OPT=$(strip $(if $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)), -O2, -O3)) \
		CC_LOWER_OPT=-O2 \
		ALT_OPENWIN_HOME=$(STAGING_PREFIX) \
		ALT_CUPS_HEADERS_PATH=$(STAGING_INCLUDE_DIR) \
		ALT_FREETYPE_HEADERS_PATH=$(STAGING_INCLUDE_DIR) \
		OTHER_CFLAGS='$(OPENJDK7_CPPFLAGS) $(TARGET_CPPFLAGS) $(OPENJDK7_LDFLAGS)' \
		OTHER_CXXFLAGS='$(OPENJDK7_CPPFLAGS) $(OPENJDK7_LDFLAGS)' \
		OTHER_LDFLAGS='$(OPENJDK7_LDFLAGS)' \
		LFLAGS_LAUNCHER='-L`pwd` $(OPENJDK7_LDFLAGS)' \
		ALSA_VERSION=$(ALSA-LIB_VERSION) \
		GCC_HONOUR_COPTS=s CROSS_COMPILE_ARCH=$(OPENJDK7_ARCH) LIBARCH=$(OPENJDK7_LIBARCH) \
		WARNINGS_ARE_ERRORS='' \
		LANG_ALL=C \
		JDK_UPDATE_VERSION=$(OPENJDK7_UPDATE_VERSION) \
		JDK_BUILD_VERSION=$(OPENJDK7_BUILD_NUMBER)

OPENJDK7_ARCH=$(strip \
	$(if $(filter powerpc, $(TARGET_ARCH)), ppc, \
	$(if $(filter arm64, $(TARGET_ARCH)), aarch64, \
	$(if $(filter arm64eb, $(TARGET_ARCH)), aarch64eb, \
	$(if $(filter i386 i686, $(TARGET_ARCH)), x86, \
	$(if $(filter amd64, $(TARGET_ARCH)), x86_64, \
	$(TARGET_ARCH)))))))

OPENJDK7_LIBARCH=$(strip \
	$(if $(filter x86, $(OPENJDK7_ARCH)), i386, \
	$(if $(filter x86_64, $(OPENJDK7_ARCH)), amd64, \
	$(OPENJDK7_ARCH))))

OPENJDK7_JDK_IMAGE_DIR=$(OPENJDK7_BUILD_DIR)/openjdk.build/j2sdk-image

#
# OPENJDK7_BUILD_DIR is the directory in which the build is done.
# OPENJDK7_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENJDK7_IPK_DIR is the directory in which the ipk is built.
# OPENJDK7_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENJDK7_BUILD_DIR=$(BUILD_DIR)/openjdk7
OPENJDK7_SOURCE_DIR=$(SOURCE_DIR)/openjdk7

OPENJDK7_JRE_HEADLESS_IPK_DIR=$(BUILD_DIR)/openjdk7-jre-headless-$(OPENJDK7_VERSION)-ipk
OPENJDK7_JRE_HEADLESS_IPK=$(BUILD_DIR)/openjdk7-jre-headless_$(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENJDK7_JRE_IPK_DIR=$(BUILD_DIR)/openjdk7-jre-$(OPENJDK7_VERSION)-ipk
OPENJDK7_JRE_IPK=$(BUILD_DIR)/openjdk7-jre_$(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENJDK7_JDK_IPK_DIR=$(BUILD_DIR)/openjdk7-jdk-$(OPENJDK7_VERSION)-ipk
OPENJDK7_JDK_IPK=$(BUILD_DIR)/openjdk7-jdk_$(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openjdk7-source openjdk7-unpack openjdk7 openjdk7-stage openjdk7-ipk openjdk7-clean openjdk7-dirclean openjdk7-check

OPENJDK7_SOURCES=\
$(addprefix $(DL_DIR)/,\
$(OPENJDK7_SOURCE) \
$(OPENJDK7_FOREST7_SOURCE) \
$(OPENJDK7_CORBA_SOURCE) \
$(OPENJDK7_HOTSPOT_SOURCE) \
$(OPENJDK7_JAXP_SOURCE) \
$(OPENJDK7_JAXWS_SOURCE) \
$(OPENJDK7_JDK_SOURCE) \
$(OPENJDK7_LANGTOOLS_SOURCE))

$(DL_DIR)/$(OPENJDK7_SOURCE):
	$(WGET) -O $@ $(OPENJDK7_HG)/archive/jdk$(OPENJDK7_VERSION).tar.bz2 || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(OPENJDK7_FOREST7_SOURCE):
	$(WGET) -O $@ $(OPENJDK7_ICEDTEA_HG)/icedtea7/archive/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/openjdk7u-%-$(OPENJDK7_VERSION).tar.bz2:
	$(WGET) -O $@ $(OPENJDK7_HG)/$*/archive/jdk$(OPENJDK7_VERSION).tar.bz2 || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openjdk7-source: $(OPENJDK7_SOURCES) $(OPENJDK7_PATCHES)

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
$(OPENJDK7_BUILD_DIR)/.configured: $(OPENJDK7_SOURCES) $(OPENJDK7_PATCHES) \
		$(OPENJDK7_OPENJDK_PATCHES) make/openjdk7.mk
	$(MAKE) libstdc++-stage freetype-stage x11-stage xinerama-stage xrender-stage libxcomposite-stage libffi-stage cups-stage \
		gtk2-stage glib-stage fontconfig-stage alsa-lib-stage jre-cacerts xi-stage xtst-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_FOREST7_SOURCE) | tar -C $(@D) -xvf - --strip-components=1
	if test -n "$(OPENJDK7_PATCHES)" ; \
		then cat $(OPENJDK7_PATCHES) | \
		$(PATCH) -d $(@D) -p1 ; \
	fi
# unpack OpenJDK
	rm -rf $(@D)/openjdk
	mkdir -p $(addprefix $(@D)/openjdk/,corba jaxp jaxws jdk langtools hotspot)
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_SOURCE) | tar -C $(@D)/openjdk -xf - --strip-components=1
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_CORBA_SOURCE) | tar -C $(@D)/openjdk/corba -xf - --strip-components=1
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_JAXP_SOURCE) | tar -C $(@D)/openjdk/jaxp -xf - --strip-components=1
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_JAXWS_SOURCE) | tar -C $(@D)/openjdk/jaxws -xf - --strip-components=1
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_JDK_SOURCE) | tar -C $(@D)/openjdk/jdk -xf - --strip-components=1
	cp -af $(JRE_CACERTS_BUILD_DIR)/jre-cacerts $(@D)/openjdk/jdk/src/share/lib/security/cacerts
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_LANGTOOLS_SOURCE) | tar -C $(@D)/openjdk/langtools -xf - --strip-components=1
	$(OPENJDK7_UNZIP) $(DL_DIR)/$(OPENJDK7_HOTSPOT_SOURCE) | tar -C $(@D)/openjdk/hotspot -xf - --strip-components=1
# apply additional patches to OpenJDK
	if test -n "$(OPENJDK7_OPENJDK_PATCHES)" ; \
		then cat $(OPENJDK7_OPENJDK_PATCHES) | \
		$(PATCH) -d $(@D)/openjdk -p1 ; \
	fi
# configure OpenJDK
	$(AUTORECONF1.14) -vif $(@D)
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CXX="$(TARGET_CXX) -std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		CC="$(TARGET_CC) -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		CPPFLAGS='$(OPENJDK7_CPPFLAGS)' \
		LDFLAGS="$(OPENJDK7_LDFLAGS)" \
		ZLIB_CFLAGS='$(OPENJDK7_CPPFLAGS)' \
		ZLIB_LIBS="$(OPENJDK7_LDFLAGS)" \
		PKG_CONFIG_PATH="$(STAGING_LIB_DIR)/pkgconfig" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		$(strip $(if $(OPENJDK7_BOOSTSTRAPJDK), \
		--with-jdk-home=$(OPENJDK7_BOOSTSTRAPJDK) \
		--with-java=$(OPENJDK7_BOOSTSTRAPJDK)/bin/java \
		--with-javac=$(OPENJDK7_BOOSTSTRAPJDK)/bin/javac \
		--with-javah=$(OPENJDK7_BOOSTSTRAPJDK)/bin/javah \
		--with-jar=$(OPENJDK7_BOOSTSTRAPJDK)/bin/jar \
		--with-rmic=$(OPENJDK7_BOOSTSTRAPJDK)/bin/rmic \
		--with-native2ascii=$(OPENJDK7_BOOSTSTRAPJDK)/bin/native2ascii)) \
		--enable-zero \
		--disable-docs \
		--without-gcj \
		--without-hotspot-build \
		--disable-nss \
		--enable-system-zlib \
		--disable-system-jpeg \
		--disable-system-png \
		--disable-system-gif \
		--enable-system-gtk \
		--enable-system-gio \
		--enable-system-fontconfig \
		--disable-system-gconf \
		--disable-system-sctp \
		--disable-system-pcsc \
		--disable-system-lcms \
		--disable-system-kerberos \
		--disable-compile-against-syscalls \
		--without-rhino \
		--disable-bootstrap \
	)
	touch $@

openjdk7-unpack: $(OPENJDK7_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENJDK7_BUILD_DIR)/.built: $(OPENJDK7_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) $(OPENJDK7_MAKE_ARGS) -j1 -C $(@D)
	touch $@

#
# This is the build convenience target.
#
openjdk7: $(OPENJDK7_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENJDK7_BUILD_DIR)/.staged: $(OPENJDK7_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

openjdk7-stage: $(OPENJDK7_BUILD_DIR)/.staged

#
# This rules create control files for ipkg
#

$(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk7-jre-headless" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK7_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK7_SECTION)" >>$@
	@echo "Version: $(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK7_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK7_HG)" >>$@
	@echo "Description: $(OPENJDK7_JRE_HEADLESS_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK7_JRE_HEADLESS_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK7_JRE_HEADLESS_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK7_JRE_HEADLESS_CONFLICTS)" >>$@

$(OPENJDK7_JRE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk7-jre" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK7_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK7_SECTION)" >>$@
	@echo "Version: $(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK7_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK7_HG)" >>$@
	@echo "Description: $(OPENJDK7_JRE_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK7_JRE_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK7_JRE_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK7_JRE_CONFLICTS)" >>$@

$(OPENJDK7_JDK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk7-jdk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK7_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK7_SECTION)" >>$@
	@echo "Version: $(OPENJDK7_VERSION)-$(OPENJDK7_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK7_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK7_HG)" >>$@
	@echo "Description: $(OPENJDK7_JDK_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK7_JDK_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK7_JDK_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK7_JDK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/sbin or $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/etc/openjdk7/...
# Documentation files should be installed in $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/doc/openjdk7/...
# Daemon startup scripts should be installed in $(OPENJDK7_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??openjdk7
#
# You may need to patch your application to make it use these locations.
#
$(OPENJDK7_JRE_HEADLESS_IPK): $(OPENJDK7_BUILD_DIR)/.built
	rm -rf $(OPENJDK7_JRE_HEADLESS_IPK_DIR) $(BUILD_DIR)/openjdk7-jre-headless_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
	cd $(OPENJDK7_JDK_IMAGE_DIR); \
		cp -af --parents $(OPENJDK7_JRE_HEADLESS_FILES) $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
	$(INSTALL) -m 644 $(OPENJDK7_SOURCE_DIR)/nss.cfg $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/lib/security/nss.cfg
	ln -sf jvm/openjdk7/jre/lib $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/openjdk7
	find $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/postinst $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/prerm $(OPENJDK7_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK7_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin/$$l 65" \
			>> $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin/$$l" \
			>> $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK7_JRE_HEADLESS_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK7_JRE_HEADLESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK7_JRE_HEADLESS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK7_JRE_HEADLESS_IPK_DIR)

$(OPENJDK7_JRE_IPK): $(OPENJDK7_BUILD_DIR)/.built
	rm -rf $(OPENJDK7_JRE_IPK_DIR) $(BUILD_DIR)/openjdk7-jre_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
	cp -af $(OPENJDK7_JDK_IMAGE_DIR)/jre $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
#	remove files that are provided by openjdk7-jre-headless package
	cd $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7; rm -rf $(OPENJDK7_JRE_HEADLESS_FILES)
	rmdir `find $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type d -empty`
#
	find $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK7_JRE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/postinst $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/prerm $(OPENJDK7_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK7_JRE_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK7_JRE_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK7_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin/$$l 65" \
			>> $(OPENJDK7_JRE_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/jre/bin/$$l" \
			>> $(OPENJDK7_JRE_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK7_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JRE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK7_JRE_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK7_JRE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK7_JRE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK7_JRE_IPK_DIR)

$(OPENJDK7_JDK_IPK): $(OPENJDK7_BUILD_DIR)/.built
	rm -rf $(OPENJDK7_JDK_IPK_DIR) $(BUILD_DIR)/openjdk7-jdk_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
	cp -af $(OPENJDK7_JDK_IMAGE_DIR)/* $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7
#	remove files that are provided by openjdk7-jre-headless and openjdk7-jre packages
	rm -rf  $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/jre \
		$(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/release
#
	find $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK7_JDK_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/postinst $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK7_SOURCE_DIR)/prerm $(OPENJDK7_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK7_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK7_JDK_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK7_JDK_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK7_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk7/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/bin/$$l 70" \
			>> $(OPENJDK7_JDK_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk7/bin/$$l" \
			>> $(OPENJDK7_JDK_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JDK_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK7_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JDK_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK7_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK7_JDK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK7_JDK_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK7_JDK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK7_JDK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK7_JDK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openjdk7-ipk: $(OPENJDK7_JRE_HEADLESS_IPK) $(OPENJDK7_JRE_IPK) $(OPENJDK7_JDK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openjdk7-clean:
	rm -f $(OPENJDK7_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENJDK7_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openjdk7-dirclean:
	rm -rf $(OPENJDK7_BUILD_DIR) \
	$(OPENJDK7_JRE_HEADLESS_IPK_DIR) $(OPENJDK7_JRE_HEADLESS_IPK) \
	$(OPENJDK7_JRE_IPK_DIR) $(OPENJDK7_JRE_IPK) \
	$(OPENJDK7_JDK_IPK_DIR) $(OPENJDK7_JDK_IPK) \
#
#
# Some sanity check for the package.
#
openjdk7-check: $(OPENJDK7_JRE_HEADLESS_IPK) $(OPENJDK7_JRE_IPK) $(OPENJDK7_JDK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
