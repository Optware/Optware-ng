###########################################################
#
# openjdk8
#
###########################################################
#
# OPENJDK8_VERSION, OPENJDK8_SITE and OPENJDK8_SOURCE define
# the upstream location of the source code for the package.
# OPENJDK8_DIR is the directory which is created when the source
# archive is unpacked.
# OPENJDK8_UNZIP is the command used to unzip the source.
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
OPENJDK8_HG=http://hg.openjdk.java.net/jdk8u/jdk8u
OPENJDK8_ICEDTEA_HG=http://icedtea.classpath.org/hg
OPENJDK8_SITE=http://icedtea.wildebeest.org/download
OPENJDK8_UPDATE_VERSION=102
OPENJDK8_BUILD_NUMBER=b02
OPENJDK8_VERSION=8u$(OPENJDK8_UPDATE_VERSION)-$(OPENJDK8_BUILD_NUMBER)
OPENJDK8_SOURCE=jdk$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_ICEDTEA_TAG=icedtea-3.0.0pre06
OPENJDK8_FOREST8_SOURCE=$(OPENJDK8_ICEDTEA_TAG).tar.bz2
OPENJDK8_CORBA_SOURCE=openjdk8u-corba-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_HOTSPOT_SOURCE=openjdk8u-hotspot-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_JAXP_SOURCE=openjdk8u-jaxp-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_JAXWS_SOURCE=openjdk8u-jaxws-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_JDK_SOURCE=openjdk8u-jdk-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_LANGTOOLS_SOURCE=openjdk8u-langtools-$(OPENJDK8_VERSION).tar.bz2
OPENJDK8_NASHORN_SOURCE=openjdk8u-nashorn-$(OPENJDK8_VERSION).tar.bz2

OPENJDK8_JAMVM_SOURCE=jamvm-2.0.0.tar.gz

#OPENJDK8_DIR=openjdk8-$(OPENJDK8_VERSION)
OPENJDK8_UNZIP=bzcat
OPENJDK8_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OPENJDK8_JDK_DESCRIPTION=OpenJDK Java development environment. The packages are built using patches from the IcedTea project and Debian.
OPENJDK8_JRE_DESCRIPTION=Full OpenJDK Java runtime, using Zero VM. The packages are built using patches from the IcedTea project and Debian.
OPENJDK8_JRE_HEADLESS_DESCRIPTION=Minimal Java runtime - needed for executing non GUI Java programs, using Zero VM. The packages are built using patches from the IcedTea project and Debian.
OPENJDK8_SECTION=language
OPENJDK8_PRIORITY=optional
OPENJDK8_JRE_HEADLESS_DEPENDS=libstdc++, freetype, libffi
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
OPENJDK8_JRE_HEADLESS_DEPENDS+=, libiconv
endif
OPENJDK8_JRE_DEPENDS=openjdk8-jre-headless, x11, alsa-lib, xext, xi, xrender, xtst
OPENJDK8_JDK_DEPENDS=openjdk8-jre, x11

OPENJDK8_JRE_HEADLESS_SUGGESTS=
OPENJDK8_JRE_HEADLESS_CONFLICTS=

OPENJDK8_JRE_SUGGESTS=
OPENJDK8_JRE_CONFLICTS=

OPENJDK8_JDK_SUGGESTS=
OPENJDK8_JDK_CONFLICTS=

#
# OPENJDK8_IPK_VERSION should be incremented when the ipk changes.
#
OPENJDK8_IPK_VERSION=4

#
# OPENJDK8_JRE_HEADLESS_CONFFILES should be a list of user-editable files
OPENJDK8_JRE_HEADLESS_CONFFILES=\
$(TARGET_PREFIX)/lib/jvm/openjdk8/jre/lib/$(OPENJDK8_LIBARCH)/jvm.cfg \
$(TARGET_PREFIX)/lib/jvm/openjdk8/jre/lib/$(OPENJDK8_LIBARCH)/server/Xusage.txt \
$(TARGET_PREFIX)/lib/jvm/openjdk8/jre/lib/security/cacerts \

OPENJDK8_JRE_HEADLESS_FILES=\
jre/bin/java \
jre/bin/keytool \
jre/lib/$(OPENJDK8_LIBARCH)/jli/libjli.so \
jre/lib/$(OPENJDK8_LIBARCH)/jvm.cfg \
jre/lib/$(OPENJDK8_LIBARCH)/libj2pkcs11.so \
jre/lib/$(OPENJDK8_LIBARCH)/libjava.so \
jre/lib/$(OPENJDK8_LIBARCH)/libnet.so \
jre/lib/$(OPENJDK8_LIBARCH)/libnio.so \
jre/lib/$(OPENJDK8_LIBARCH)/libjsig.so  \
jre/lib/$(OPENJDK8_LIBARCH)/libverify.so \
jre/lib/$(OPENJDK8_LIBARCH)/libzip.so \
jre/lib/$(OPENJDK8_LIBARCH)/server/libjvm.so \
jre/lib/$(OPENJDK8_LIBARCH)/server/Xusage.txt \
jre/lib/calendars.properties \
jre/lib/classlist \
jre/lib/content-types.properties \
jre/lib/currency.data \
jre/lib/ext/localedata.jar \
jre/lib/ext/meta-index \
jre/lib/ext/sunec.jar \
jre/lib/ext/sunjce_provider.jar \
jre/lib/ext/sunpkcs11.jar \
jre/lib/hijrah-config-umalqura.properties \
jre/lib/jce.jar \
jre/lib/jsse.jar \
jre/lib/logging.properties \
jre/lib/meta-index \
jre/lib/net.properties \
jre/lib/resources.jar \
jre/lib/rt.jar \
jre/lib/security/cacerts \
jre/lib/security/java.policy \
jre/lib/security/java.security \
jre/lib/security/local_policy.jar \
jre/lib/security/US_export_policy.jar \
jre/lib/tzdb.dat \
release \



#
# OPENJDK8_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#OPENJDK8_PATCHES=$(OPENJDK8_SOURCE_DIR)/configure.patch

OPENJDK8_OPENJDK_PATCHES=\
$(OPENJDK8_SOURCE_DIR)/openjdk/toolchain.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/gcc_definitions.uclibc.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/hotspot-mips-align.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/hotspot-no-march-i586.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/hotspot-powerpcspe.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/hotspot-set-compiler.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/os_linux.uclibc.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/os_linux.fix-i386-zero-build.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/xtoolkit.uclibc.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/zero-architectures.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/zero-fpu-control-is-noop.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/zero-missing-headers.diff \
$(OPENJDK8_SOURCE_DIR)/openjdk/fix-ipv6-init.patch \
$(OPENJDK8_SOURCE_DIR)/openjdk/native_jni_return_null_not_false.patch \

OPENJDK8_JAMVM_PATCHES=\
$(OPENJDK8_SOURCE_DIR)/jamvm/jamvm-fix.diff \
$(OPENJDK8_SOURCE_DIR)/jamvm/URLClassPath.stub.diff \

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
OPENJDK8_CPPFLAGS=
OPENJDK8_LDFLAGS=

OPENJDK8_DEBUG_LEVEL=release

OPENJDK8_CPPFLAGS=-g3 -I$(OPENJDK8_BUILD_DIR)/openjdk/jdk/src/share/npt \
-I$(OPENJDK8_BUILD_DIR)/openjdk/jdk/src/share/native/sun/awt/image/jpeg \
-I$(OPENJDK8_BUILD_DIR)/jamvm/install/include \
$(STAGING_CPPFLAGS)
# commas in LDFLAGS cause make functions parse errors
OPENJDK8_LDFLAGS=-L$(OPENJDK8_BUILD_DIR)/openjdk/build/linux-$(OPENJDK8_ARCH)-normal-zero-$(OPENJDK8_DEBUG_LEVEL)/jdk/lib/$(OPENJDK8_LIBARCH) \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH)/jli \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH)/server \
-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH) \
$(shell echo $(STAGING_LDFLAGS) | sed -e 's/-Wl,/-Xlinker /g' -e 's/\(-rpath\|-rpath-link\),/\1 -Xlinker /g') -lm -ldl
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
OPENJDK8_LDFLAGS += -liconv
endif

OPENJDK8_MAKE_ARGS=\
		$(TARGET_CONFIGURE_OPTS) \
		CXX="$(TARGET_CXX) -std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		CC="$(TARGET_CC) -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		LD=$(TARGET_CC) \
		BUILD_CC=$(HOSTCC) \
		BUILD_LD=$(HOSTCC) \
		WARNINGS_ARE_ERRORS='' \
		LOG=debug \
		CONF=linux-$(OPENJDK8_ARCH)-normal-zero-$(OPENJDK8_DEBUG_LEVEL)

OPENJDK8_ARCH=$(strip \
	$(if $(filter powerpc, $(TARGET_ARCH)), ppc, \
	$(if $(filter arm64, $(TARGET_ARCH)), aarch64, \
	$(if $(filter arm64eb, $(TARGET_ARCH)), aarch64eb, \
	$(if $(filter i386 i686, $(TARGET_ARCH)), x86, \
	$(if $(filter amd64, $(TARGET_ARCH)), x86_64, \
	$(TARGET_ARCH)))))))

OPENJDK8_LIBARCH=$(strip \
	$(if $(filter x86, $(OPENJDK8_ARCH)), i386, \
	$(if $(filter x86_64, $(OPENJDK8_ARCH)), amd64, \
	$(OPENJDK8_ARCH))))

OPENJDK8_JDK_IMAGE_DIR=$(OPENJDK8_BUILD_DIR)/openjdk/build/linux-$(OPENJDK8_ARCH)-normal-zero-$(OPENJDK8_DEBUG_LEVEL)/images/j2sdk-image

#
# OPENJDK8_BUILD_DIR is the directory in which the build is done.
# OPENJDK8_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# OPENJDK8_IPK_DIR is the directory in which the ipk is built.
# OPENJDK8_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
OPENJDK8_BUILD_DIR=$(BUILD_DIR)/openjdk8
OPENJDK8_SOURCE_DIR=$(SOURCE_DIR)/openjdk8

OPENJDK8_JRE_HEADLESS_IPK_DIR=$(BUILD_DIR)/openjdk8-jre-headless-$(OPENJDK8_VERSION)-ipk
OPENJDK8_JRE_HEADLESS_IPK=$(BUILD_DIR)/openjdk8-jre-headless_$(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENJDK8_JRE_IPK_DIR=$(BUILD_DIR)/openjdk8-jre-$(OPENJDK8_VERSION)-ipk
OPENJDK8_JRE_IPK=$(BUILD_DIR)/openjdk8-jre_$(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)_$(TARGET_ARCH).ipk

OPENJDK8_JDK_IPK_DIR=$(BUILD_DIR)/openjdk8-jdk-$(OPENJDK8_VERSION)-ipk
OPENJDK8_JDK_IPK=$(BUILD_DIR)/openjdk8-jdk_$(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: openjdk8-source openjdk8-unpack openjdk8 openjdk8-stage openjdk8-ipk openjdk8-clean openjdk8-dirclean openjdk8-check

OPENJDK8_SOURCES=\
$(addprefix $(DL_DIR)/,\
$(OPENJDK8_SOURCE) \
$(OPENJDK8_FOREST8_SOURCE) \
$(OPENJDK8_CORBA_SOURCE) \
$(OPENJDK8_HOTSPOT_SOURCE) \
$(OPENJDK8_JAXP_SOURCE) \
$(OPENJDK8_JAXWS_SOURCE) \
$(OPENJDK8_JDK_SOURCE) \
$(OPENJDK8_LANGTOOLS_SOURCE) \
$(OPENJDK8_NASHORN_SOURCE))
# \
$(OPENJDK8_JAMVM_SOURCE))

$(DL_DIR)/$(OPENJDK8_SOURCE):
	$(WGET) -O $@ $(OPENJDK8_HG)/archive/jdk$(OPENJDK8_VERSION).tar.bz2 || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/$(OPENJDK8_FOREST8_SOURCE):
	$(WGET) -O $@ $(OPENJDK8_ICEDTEA_HG)/icedtea/archive/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

$(DL_DIR)/openjdk8u-%-$(OPENJDK8_VERSION).tar.bz2:
	$(WGET) -O $@ $(OPENJDK8_HG)/$*/archive/jdk$(OPENJDK8_VERSION).tar.bz2 || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ifneq (2.0.0,$(JAMVM_VERSION))
$(DL_DIR)/$(OPENJDK8_JAMVM_SOURCE):
	$(WGET) -O $@ $(OPENJDK8_SITE)/drops/jamvm/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
openjdk8-source: $(OPENJDK8_SOURCES) $(OPENJDK8_PATCHES)

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
$(OPENJDK8_BUILD_DIR)/.configured: $(OPENJDK8_SOURCES) $(OPENJDK8_PATCHES) \
		$(OPENJDK8_JAMVM_PATCHES) $(OPENJDK8_OPENJDK_PATCHES) make/openjdk8.mk
	$(MAKE) libstdc++-stage freetype-stage x11-stage autoconf-host-stage libffi-stage \
		jre-cacerts alsa-lib-stage xext-stage xi-stage xrender-stage xtst-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(@D)
	$(INSTALL) -d $(@D)
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_FOREST8_SOURCE) | tar -C $(@D) -xvf - --strip-components=1
	if test -n "$(OPENJDK8_PATCHES)" ; \
		then cat $(OPENJDK8_PATCHES) | \
		$(PATCH) -d $(@D) -p0 ; \
	fi
	sed -e 's|@abs_top_srcdir@|$(@D)|g' $(@D)/fsg.sh.in > $(@D)/fsg.sh
	chmod +x $(@D)/fsg.sh
# unpack OpenJDK
	rm -rf $(@D)/openjdk
	mkdir -p $(addprefix $(@D)/openjdk/,corba jaxp jaxws jdk langtools hotspot nashorn)
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_SOURCE) | tar -C $(@D)/openjdk -xf - --strip-components=1
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_CORBA_SOURCE) | tar -C $(@D)/openjdk/corba -xf - --strip-components=1
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_JAXP_SOURCE) | tar -C $(@D)/openjdk/jaxp -xf - --strip-components=1
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_JAXWS_SOURCE) | tar -C $(@D)/openjdk/jaxws -xf - --strip-components=1
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_JDK_SOURCE) | tar -C $(@D)/openjdk/jdk -xf - --strip-components=1
	cp -af $(JRE_CACERTS_BUILD_DIR)/jre-cacerts $(@D)/openjdk/jdk/src/share/lib/security/cacerts
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_LANGTOOLS_SOURCE) | tar -C $(@D)/openjdk/langtools -xf - --strip-components=1
	rm -rf $(@D)/openjdk/jdk/make/tools/src/build/tools/javazic
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_HOTSPOT_SOURCE) | tar -C $(@D)/openjdk/hotspot -xf - --strip-components=1
	$(OPENJDK8_UNZIP) $(DL_DIR)/$(OPENJDK8_NASHORN_SOURCE) | tar -C $(@D)/openjdk/nashorn -xf - --strip-components=1
# sanitize OpenJDK
	chmod -R ug+w $(@D)/openjdk 
	cd $(@D); sh $(@D)/fsg.sh
# apply additional patches to OpenJDK
	if test -n "$(OPENJDK8_OPENJDK_PATCHES)" ; \
		then cat $(OPENJDK8_OPENJDK_PATCHES) | \
		$(PATCH) -d $(@D)/openjdk -p1 ; \
	fi
ifeq (0,1)
# unpack, patch and stage jamvm
	rm -rf $(@D)/jamvm
	mkdir -p $(@D)/jamvm/jamvm
	zcat $(DL_DIR)/$(OPENJDK8_JAMVM_SOURCE) | tar -C $(@D)/jamvm/jamvm -xf - --strip-components=1
	if test -n "$(OPENJDK8_JAMVM_PATCHES)" ; \
		then cat $(OPENJDK8_JAMVM_PATCHES) | \
		$(PATCH) -d $(@D) -p0 ; \
	fi
	ln -s . $(@D)/jamvm/jamvm/m4
	$(AUTORECONF1.14) -vif $(@D)/jamvm/jamvm
	(cd $(@D)/jamvm/jamvm; \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="-I$(@D)/jamvm/jamvm/src $(STAGING_CPPFLAGS)" \
		LDFLAGS="-Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH)/jli \
			 -Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH)/server \
			 -Xlinker -rpath -Xlinker $(TARGET_PREFIX)/lib/openjdk8/$(OPENJDK8_LIBARCH) $(STAGING_LDFLAGS)" \
		./configure \
		--with-java-runtime-library=openjdk8 \
		--prefix=$(@D)/jamvm/install \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--disable-nls \
	)
	$(MAKE) -C $(@D)/jamvm/jamvm
	$(MAKE) -C $(@D)/jamvm/jamvm install
	mkdir -p $(@D)/jamvm/install/hotspot/lib
	touch $(@D)/jamvm/install/hotspot/lib/sa-jdi.jar
	mkdir -p $(@D)/jamvm/install/hotspot/jre/lib/$(OPENJDK8_LIBARCH)/server
	cp $(@D)/jamvm/install/lib/libjvm.so $(@D)/jamvm/install/hotspot/jre/lib/$(OPENJDK8_LIBARCH)/server
	ln -sf server $(@D)/jamvm/install/hotspot/jre/lib/$(OPENJDK8_LIBARCH)/client
	touch $(@D)/jamvm/install/hotspot/jre/lib/$(OPENJDK8_LIBARCH)/server/Xusage.txt
	ln -sf libjvm.so $(@D)/jamvm/install/hotspot/jre/lib/$(OPENJDK8_LIBARCH)/client/libjsig.so
endif
# finally configure OpenJDK
ifeq ($(OPTWARE_TARGET), $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
	# doesn't build with -O3
	sed -i -e 's/-O3/-O2/g' $(@D)/openjdk/common/autoconf/toolchain.m4
endif
	cat $(@D)/openjdk/common/autoconf/configure.ac  | sed -e "s|@DATE_WHEN_GENERATED@|`LC_ALL=C date +%s`|" | $(HOST_STAGING_PREFIX)/bin/autoconf \
		-W all -I$(@D)/openjdk/common/autoconf - > $(@D)/openjdk/common/autoconf/generated-configure.sh
	(cd $(@D)/openjdk; \
		chmod +x configure; \
		$(TARGET_CONFIGURE_OPTS) \
		CXX="$(TARGET_CXX) -std=c++98 -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		CC="$(TARGET_CC) -fno-delete-null-pointer-checks -fno-lifetime-dse" \
		OBJDUMP=$(TARGET_CROSS)objdump \
		OBJCOPY=$(TARGET_CROSS)objcopy \
		LD=$(TARGET_CC) \
		ac_cv_path_POTENTIAL_CC=$(TARGET_CC) \
		ac_cv_path_POTENTIAL_CXX=$(TARGET_CXX) \
		BUILD_CC=$(HOSTCC) \
		BUILD_LD=$(HOSTCC) \
		CPPFLAGS="$(OPENJDK8_CPPFLAGS)" \
		LDFLAGS="$(OPENJDK8_LDFLAGS)" \
		LIBFFI_CFLAGS="$(STAGING_CPPFLAGS)" \
		LIBFFI_LIBS="$(STAGING_LDFLAGS) -lffi" \
		./configure \
		--openjdk-target=$(OPENJDK8_ARCH)-linux \
		--enable-unlimited-crypto \
		--with-stdc++lib=dynamic \
		--with-update-version=$(OPENJDK8_UPDATE_VERSION) \
		--with-build-number=$(OPENJDK8_BUILD_NUMBER) \
		--with-milestone=Optware-ng \
		--with-jvm-variants=zero \
		--disable-freetype-bundling \
		--with-extra-cflags="$(OPENJDK8_CPPFLAGS)" \
		--with-extra-cxxflags="$(OPENJDK8_CPPFLAGS)" \
		--with-extra-ldflags="$(OPENJDK8_LDFLAGS)" \
		--with-freetype-include=$(STAGING_INCLUDE_DIR)/freetype2 \
		--with-freetype-lib=$(STAGING_LIB_DIR) \
		--with-freetype=$(STAGING_PREFIX) \
		--with-x=$(STAGING_PREFIX) \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--prefix=$(TARGET_PREFIX) \
		--enable-debug-symbols \
		--enable-zip-debug-info \
		--with-debug-level=$(OPENJDK8_DEBUG_LEVEL) \
		--enable-unlimited-crypto \
		--with-stdc++lib=dynamic \
		--with-extra-cflags="$(OPENJDK8_CPPFLAGS)" \
		--with-extra-cxxflags="$(OPENJDK8_CPPFLAGS)" \
		--with-extra-ldflags="$(OPENJDK8_LDFLAGS)"  \
		--with-zlib=system \
		--with-giflib=bundled \
	)
	sed -i 	-e 's/@OPENJDK_TARGET_OS_ENV@/linux/g' -e 's|@THEPWDCMD@|$(shell which pwd)|g' \
		-e 's/@ENABLE_JFR@/no/g' $(@D)/openjdk/build/linux-$(OPENJDK8_ARCH)-normal-zero-$(OPENJDK8_DEBUG_LEVEL)/spec.gmk
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

openjdk8-unpack: $(OPENJDK8_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(OPENJDK8_BUILD_DIR)/.built: $(OPENJDK8_BUILD_DIR)/.configured
	rm -f $@
ifneq ($(MAKE_JOBS), )
	$(MAKE) -C $(@D)/openjdk $(OPENJDK8_MAKE_ARGS) images -j1 JOBS=$(MAKE_JOBS)
else
	$(MAKE) -C $(@D)/openjdk $(OPENJDK8_MAKE_ARGS) images -j1
endif
#	printf -- '-jamvm ALIASED_TO -server\n' >> $(OPENJDK8_JDK_IMAGE_DIR)/jre/lib/$(OPENJDK8_LIBARCH)/jvm.cfg
	touch $@

#
# This is the build convenience target.
#
openjdk8: $(OPENJDK8_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(OPENJDK8_BUILD_DIR)/.staged: $(OPENJDK8_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

openjdk8-stage: $(OPENJDK8_BUILD_DIR)/.staged

#
# This rules create control files for ipkg
#

$(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk8-jre-headless" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK8_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK8_SECTION)" >>$@
	@echo "Version: $(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK8_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK8_HG)" >>$@
	@echo "Description: $(OPENJDK8_JRE_HEADLESS_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK8_JRE_HEADLESS_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK8_JRE_HEADLESS_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK8_JRE_HEADLESS_CONFLICTS)" >>$@

$(OPENJDK8_JRE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk8-jre" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK8_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK8_SECTION)" >>$@
	@echo "Version: $(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK8_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK8_HG)" >>$@
	@echo "Description: $(OPENJDK8_JRE_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK8_JRE_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK8_JRE_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK8_JRE_CONFLICTS)" >>$@

$(OPENJDK8_JDK_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: openjdk8-jdk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OPENJDK8_PRIORITY)" >>$@
	@echo "Section: $(OPENJDK8_SECTION)" >>$@
	@echo "Version: $(OPENJDK8_VERSION)-$(OPENJDK8_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OPENJDK8_MAINTAINER)" >>$@
	@echo "Source: $(OPENJDK8_HG)" >>$@
	@echo "Description: $(OPENJDK8_JDK_DESCRIPTION)" >>$@
	@echo "Depends: $(OPENJDK8_JDK_DEPENDS)" >>$@
	@echo "Suggests: $(OPENJDK8_JDK_SUGGESTS)" >>$@
	@echo "Conflicts: $(OPENJDK8_JDK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/sbin or $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/etc/openjdk8/...
# Documentation files should be installed in $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/doc/openjdk8/...
# Daemon startup scripts should be installed in $(OPENJDK8_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??openjdk8
#
# You may need to patch your application to make it use these locations.
#
$(OPENJDK8_JRE_HEADLESS_IPK): $(OPENJDK8_BUILD_DIR)/.built
	rm -rf $(OPENJDK8_JRE_HEADLESS_IPK_DIR) $(BUILD_DIR)/openjdk8-jre-headless_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
	cd $(OPENJDK8_JDK_IMAGE_DIR); \
		cp -af --parents $(OPENJDK8_JRE_HEADLESS_FILES) $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
	ln -sf jvm/openjdk8/jre/lib $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/openjdk8
	find $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/postinst $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/prerm $(OPENJDK8_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK8_JRE_HEADLESS_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin/$$l 75" \
			>> $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin/$$l" \
			>> $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK8_JRE_HEADLESS_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK8_JRE_HEADLESS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK8_JRE_HEADLESS_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK8_JRE_HEADLESS_IPK_DIR)

$(OPENJDK8_JRE_IPK): $(OPENJDK8_BUILD_DIR)/.built
	rm -rf $(OPENJDK8_JRE_IPK_DIR) $(BUILD_DIR)/openjdk8-jre_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
	cp -af $(OPENJDK8_JDK_IMAGE_DIR)/jre $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
#	remove files that are provided by openjdk8-jre-headless package
	cd $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8; rm -f $(OPENJDK8_JRE_HEADLESS_FILES)
	rmdir `find $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type d -empty`
#
	find $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK8_JRE_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/postinst $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/prerm $(OPENJDK8_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK8_JRE_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK8_JRE_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK8_JRE_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin/$$l 75" \
			>> $(OPENJDK8_JRE_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/jre/bin/$$l" \
			>> $(OPENJDK8_JRE_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK8_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JRE_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JRE_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK8_JRE_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK8_JRE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK8_JRE_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK8_JRE_IPK_DIR)

$(OPENJDK8_JDK_IPK): $(OPENJDK8_BUILD_DIR)/.built
	rm -rf $(OPENJDK8_JDK_IPK_DIR) $(BUILD_DIR)/openjdk8-jdk_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
	cp -af $(OPENJDK8_JDK_IMAGE_DIR)/* $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8
#	remove files that are provided by openjdk8-jre-headless and openjdk8-jre packages
	rm -rf  $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8/jre \
		$(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8/release
#
	find $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f -name '*.diz' -exec rm -f {} \;
	-$(STRIP_COMMAND) `find $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8 -type f` 2>/dev/null
	$(MAKE) $(OPENJDK8_JDK_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/postinst $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(OPENJDK8_SOURCE_DIR)/prerm $(OPENJDK8_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(OPENJDK8_IPK_DIR)/CONTROL/prerm
	echo "#!/bin/sh" > $(OPENJDK8_JDK_IPK_DIR)/CONTROL/postinst
	echo "#!/bin/sh" > $(OPENJDK8_JDK_IPK_DIR)/CONTROL/prerm
	for l in `cd $(OPENJDK8_JDK_IPK_DIR)$(TARGET_PREFIX)/lib/jvm/openjdk8/bin; ls *`; do \
		echo "update-alternatives --install '$(TARGET_PREFIX)/bin/$$l' '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/bin/$$l 80" \
			>> $(OPENJDK8_JDK_IPK_DIR)/CONTROL/postinst; \
		echo "update-alternatives --remove '$$l' $(TARGET_PREFIX)/lib/jvm/openjdk8/bin/$$l" \
			>> $(OPENJDK8_JDK_IPK_DIR)/CONTROL/prerm; \
	done
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JDK_IPK_DIR)/CONTROL/prerm; \
	fi
	chmod 755 $(OPENJDK8_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JDK_IPK_DIR)/CONTROL/prerm
	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(OPENJDK8_JDK_IPK_DIR)/CONTROL/postinst $(OPENJDK8_JDK_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(OPENJDK8_JDK_CONFFILES) | sed -e 's/ /\n/g' > $(OPENJDK8_JDK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OPENJDK8_JDK_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(OPENJDK8_JDK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
openjdk8-ipk: $(OPENJDK8_JRE_HEADLESS_IPK) $(OPENJDK8_JRE_IPK) $(OPENJDK8_JDK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
openjdk8-clean:
	rm -f $(OPENJDK8_BUILD_DIR)/.built
	-$(MAKE) -C $(OPENJDK8_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
openjdk8-dirclean:
	rm -rf $(OPENJDK8_BUILD_DIR) \
	$(OPENJDK8_JRE_HEADLESS_IPK_DIR) $(OPENJDK8_JRE_HEADLESS_IPK) \
	$(OPENJDK8_JRE_IPK_DIR) $(OPENJDK8_JRE_IPK) \
	$(OPENJDK8_JDK_IPK_DIR) $(OPENJDK8_JDK_IPK) \
#
#
# Some sanity check for the package.
#
openjdk8-check: $(OPENJDK8_JRE_HEADLESS_IPK) $(OPENJDK8_JRE_IPK) $(OPENJDK8_JDK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
