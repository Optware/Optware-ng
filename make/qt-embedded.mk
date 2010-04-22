###########################################################
#
# qt-embedded
#
###########################################################

#
# TODO:
# host staging - some programs need to build and execute Qt apps during build
# enable more features - glib support causes link failures on ARM, possibly
#	other targets, javascript JIT, webkit and the unixodbc driver are not
#	compiled
# split build - separate net, sql, possibly individual sql plugins from core
#	libraries, probably only core should ever need host staging
# 

#
# QT-EMBEDDED_VERSION, QT-EMBEDDED_SITE and QT-EMBEDDED_SOURCE define
# the upstream location of the source code for the package.
# QT-EMBEDDED_DIR is the directory which is created when the source
# archive is unpacked.
# QT-EMBEDDED_UNZIP is the command used to unzip the source.
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
QT-EMBEDDED_SITE=http://get.qt.nokia.com/qt/source/
QT-EMBEDDED_VERSION=4.6.2
QT-EMBEDDED_SOURCE=qt-everywhere-opensource-src-$(QT-EMBEDDED_VERSION).tar.gz
QT-EMBEDDED_DIR=qt-everywhere-opensource-src-$(QT-EMBEDDED_VERSION)
QT-EMBEDDED_UNZIP=zcat
QT-EMBEDDED_MAINTAINER=Andrew Mahone <andrew.mahone@gmail.com>
QT-EMBEDDED_DESCRIPTION=Qt library, embedded version.
QT-EMBEDDED_SECTION=libs
QT-EMBEDDED_PRIORITY=optional
QT-EMBEDDED_DEPENDS=zlib, libtiff, libjpeg, libpng
QT-EMBEDDED_SUGGESTS=openssl, mysql5, sqlite, dbus, postgresql
QT-EMBEDDED_CONFLICTS=
QT-EMBEDDED_TOOLS=lrelease qmake uic moc rcc
QT-EMBEDDED_CFLAGS=$(TARGET_CFLAGS)
QT-EMBEDDED_CFLAGS+='"-I$(STAGING_DIR)/opt/include"'
QT-EMBEDDED_CFLAGS+='"-I$(STAGING_DIR)/opt/include/mysql"'
QT-EMBEDDED_LFLAGS+='"-L$(STAGING_DIR)/opt/lib"'
QT-EMBEDDED_LFLAGS+='"-L$(STAGING_DIR)/opt/lib/mysql"'
QT-EMBEDDED_LFLAGS+='"-Wl,-rpath=/opt/lib"'
QT-EMBEDDED_LFLAGS+='"-Wl,-rpath=/opt/lib/mysql"'
QT-EMBEDDED_LFLAGS+='"-Wl,-rpath-link=$(STAGING_DIR)/opt/lib"'
QT-EMBEDDED_LFLAGS+='"-Wl,-rpath-link=$(STAGING_DIR)/opt/lib/mysql"'
ifeq (yes, $(TARGET_CC_PROBE))
QT-EMBEDDED_PLATFORM=-platform linux-g++-custom
else
QT-EMBEDDED_CROSS=$(GNU_TARGET_NAME)-
QT-EMBEDDED_PATH=PATH="$$PATH:$(TARGET_CROSS_TOP)/bin"
QT-EMBEDDED_PLATFORM=$(patsubst mips%,mips,$(patsubst arm%,arm,$(patsubst i%86,i386,$(TARGET_ARCH)))) -xplatform linux-g++-custom
endif
QT-EMBEDDED_QMAKE='include(../common/g++.conf)'
QT-EMBEDDED_QMAKE+='\ninclude(../common/linux.conf)'
QT-EMBEDDED_QMAKE+='\ninclude(../common/qws.conf)'
QT-EMBEDDED_QMAKE+='\nQMAKE_CC = $(QT-EMBEDDED_CROSS)gcc $(QT-EMBEDDED_CFLAGS)'
QT-EMBEDDED_QMAKE+='\nQMAKE_CXX = $(QT-EMBEDDED_CROSS)g++ $(QT-EMBEDDED_CFLAGS)'
QT-EMBEDDED_QMAKE+='\nQMAKE_LINK = $(QT-EMBEDDED_CROSS)g++ $(QT-EMBEDDED_LFLAGS)'
QT-EMBEDDED_QMAKE+='\nQMAKE_LINK_SHLIB = $(QT-EMBEDDED_CROSS)g++ $(QT-EMBEDDED_LFLAGS)'
QT-EMBEDDED_QMAKE+='\nQMAKE_AR = $(QT-EMBEDDED_CROSS)ar cqs'
QT-EMBEDDED_QMAKE+='\nQMAKE_OBJCOPY = $(QT-EMBEDDED_CROSS)objcopy'
QT-EMBEDDED_QMAKE+='\nQMAKE_STRIP = $(QT-EMBEDDED_CROSS)strip'
QT-EMBEDDED_QMAKE+='\nload(qt_config)'

#
# QT-EMBEDDED_IPK_VERSION should be incremented when the ipk changes.
#
QT-EMBEDDED_IPK_VERSION=1

#
# QT-EMBEDDED_CONFFILES should be a list of user-editable files
#QT-EMBEDDED_CONFFILES=/opt/etc/qt-embedded.conf /opt/etc/init.d/SXXqt-embedded

#
# QT-EMBEDDED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#QT-EMBEDDED_PATCHES=$(QT-EMBEDDED_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QT-EMBEDDED_CPPFLAGS=
QT-EMBEDDED_LDFLAGS=

#
# QT-EMBEDDED_BUILD_DIR is the directory in which the build is done.
# QT-EMBEDDED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QT-EMBEDDED_IPK_DIR is the directory in which the ipk is built.
# QT-EMBEDDED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QT-EMBEDDED_BUILD_DIR=$(BUILD_DIR)/qt-embedded
QT-EMBEDDED_SOURCE_DIR=$(SOURCE_DIR)/qt-embedded
QT-EMBEDDED_IPK_DIR=$(BUILD_DIR)/qt-embedded-$(QT-EMBEDDED_VERSION)-ipk
QT-EMBEDDED_IPK=$(BUILD_DIR)/qt-embedded_$(QT-EMBEDDED_VERSION)-$(QT-EMBEDDED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: qt-embedded-source qt-embedded-unpack qt-embedded qt-embedded-stage qt-embedded-ipk qt-embedded-clean qt-embedded-dirclean qt-embedded-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(QT-EMBEDDED_SOURCE):
	$(WGET) -P $(@D) $(QT-EMBEDDED_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qt-embedded-source: $(DL_DIR)/$(QT-EMBEDDED_SOURCE) $(QT-EMBEDDED_PATCHES)

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
$(QT-EMBEDDED_BUILD_DIR)/.configured: $(DL_DIR)/$(QT-EMBEDDED_SOURCE) $(QT-EMBEDDED_PATCHES) make/qt-embedded.mk
	$(MAKE) libjpeg-stage libpng-stage libtiff-stage zlib-stage openssl-stage dbus-stage mysql5-stage sqlite-stage postgresql-stage
	rm -rf $(BUILD_DIR)/$(QT-EMBEDDED_DIR) $(@D)
	$(QT-EMBEDDED_UNZIP) $(DL_DIR)/$(QT-EMBEDDED_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(QT-EMBEDDED_PATCHES)" ; \
		then cat $(QT-EMBEDDED_PATCHES) | \
		patch -d $(BUILD_DIR)/$(QT-EMBEDDED_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(QT-EMBEDDED_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(QT-EMBEDDED_DIR) $(@D) ; \
	fi
	(cd $(@D)/mkspecs ; \
		mkdir linux-g++-custom ; \
		cp linux-g++/qplatformdefs.h linux-g++-custom ; \
		echo $(QT-EMBEDDED_QMAKE) >linux-g++-custom/qmake.conf ; \
	)		
ifneq (yes, $(TARGET_CC_PROBE))
	cp -a $(@D)/src/tools $(@D)/src/tools-target
	cp -a $(@D)/qmake $(@D)/qmake-target
	cp -a $(@D)/tools/linguist/lrelease $(@D)/tools/linguist/lrelease-target
	sed -i 's/bin/target-bin/g' \
		$(@D)/qmake-target/qmake.pro \
		$(@D)/src/tools-target/uic/uic.pro \
		$(@D)/src/tools-target/moc/moc.pro \
		$(@D)/src/tools-target/rcc/rcc.pro \
		$(@D)/tools/linguist/lrelease-target/lrelease.pro
	sed -i 's+/tools/+/tools-target/+g' $(@D)/src/tools-target/bootstrap/bootstrap.pri $(@D)/tools/linguist/lrelease-target/lrelease.pro
	mkdir $(@D)/target-bin
endif
	+(cd $(@D); \
		cp -a src/tools src/tools-target ; \
		cp -a tools/linguist/lrelease tools/linguist/lrelease-target ; \
		cp -a qmake qmake-target ; \
		echo 'yes' | \
		$(QT-EMBEDDED_PATH) \
		PKG_CONFIG_PATH=$(STAGING_DIR)/opt/lib/pkgconfig \
		PKG_CONFIG_SYSROOT=$(STAGING_DIR) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(QT-EMBEDDED_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(QT-EMBEDDED_LDFLAGS)" \
		./configure \
		-prefix /opt \
		-force-pkg-config \
		-no-pch \
		-plugindir /opt/lib/qt4/plugins \
		-opensource \
		-plugin-sql-mysql \
		-plugin-sql-sqlite \
		-plugin-sql-psql \
		-system-sqlite \
		-no-webkit \
		-no-javascript-jit \
		-no-glib \
		-qt-libmng \
		-embedded \
		$(QT-EMBEDDED_PLATFORM) \
		-v \
		-nomake "tools examples demos docs" \
	)
ifneq (yes, $(TARGET_CC_PROBE))
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/src/tools-target/bootstrap $(@D)/src/tools-target/bootstrap/bootstrap.pro
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/qmake-target $(@D)/qmake-target/qmake.pro
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/src/tools-target/uic $(@D)/src/tools-target/uic/uic.pro
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/src/tools-target/moc $(@D)/src/tools-target/moc/moc.pro
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/src/tools-target/rcc $(@D)/src/tools-target/rcc/rcc.pro
	$(@D)/bin/qmake -spec $(@D)/mkspecs/linux-g++-custom -o $(@D)/tools/linguist/lrelease-target $(@D)/tools/linguist/lrelease-target/lrelease.pro
endif
#	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

qt-embedded-unpack: $(QT-EMBEDDED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QT-EMBEDDED_BUILD_DIR)/.built: $(QT-EMBEDDED_BUILD_DIR)/.configured
	rm -f $@
ifneq (yes, $(TARGET_CC_PROBE))
	(cd $(@D) ; for dir in qmake-target src/tools-target/bootstrap src/tools-target/uic src/tools-target/moc src/tools-target/rcc tools/linguist/lrelease-target ; do \
		$(QT-EMBEDDED_PATH) $(MAKE) -C $$dir ; done \
	)
endif
	$(QT-EMBEDDED_PATH) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
qt-embedded: $(QT-EMBEDDED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(QT-EMBEDDED_BUILD_DIR)/.staged: $(QT-EMBEDDED_BUILD_DIR)/.built
	rm -f $@
	$(QT-EMBEDDED_PATH) $(MAKE) -C $(@D) INSTALL_ROOT=$(STAGING_DIR) install
ifneq (yes, $(TARGET_CC_PROBE))
	(cd $(@D) ; \
		install -m 755 target-bin/uic target-bin/moc target-bin/rcc target-bin/lrelease target-bin/qmake $(STAGING_DIR)/opt/bin \
	)
endif
	touch $@

qt-embedded-stage: $(QT-EMBEDDED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qt-embedded
#
$(QT-EMBEDDED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: qt-embedded" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QT-EMBEDDED_PRIORITY)" >>$@
	@echo "Section: $(QT-EMBEDDED_SECTION)" >>$@
	@echo "Version: $(QT-EMBEDDED_VERSION)-$(QT-EMBEDDED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QT-EMBEDDED_MAINTAINER)" >>$@
	@echo "Source: $(QT-EMBEDDED_SITE)/$(QT-EMBEDDED_SOURCE)" >>$@
	@echo "Description: $(QT-EMBEDDED_DESCRIPTION)" >>$@
	@echo "Depends: $(QT-EMBEDDED_DEPENDS)" >>$@
	@echo "Suggests: $(QT-EMBEDDED_SUGGESTS)" >>$@
	@echo "Conflicts: $(QT-EMBEDDED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(QT-EMBEDDED_IPK_DIR)/opt/sbin or $(QT-EMBEDDED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(QT-EMBEDDED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(QT-EMBEDDED_IPK_DIR)/opt/etc/qt-embedded/...
# Documentation files should be installed in $(QT-EMBEDDED_IPK_DIR)/opt/doc/qt-embedded/...
# Daemon startup scripts should be installed in $(QT-EMBEDDED_IPK_DIR)/opt/etc/init.d/S??qt-embedded
#
# You may need to patch your application to make it use these locations.
#
$(QT-EMBEDDED_IPK): $(QT-EMBEDDED_BUILD_DIR)/.built
	rm -rf $(QT-EMBEDDED_IPK_DIR) $(BUILD_DIR)/qt-embedded_*_$(TARGET_ARCH).ipk
	$(QT-EMBEDDED_PATH) $(MAKE) -C $(QT-EMBEDDED_BUILD_DIR) INSTALL_ROOT=$(QT-EMBEDDED_IPK_DIR) install
ifneq (yes, $(TARGET_CC_PROBE))
	(cd $(QT-EMBEDDED_BUILD_DIR) ; \
		install -m 755 target-bin/uic target-bin/moc target-bin/rcc target-bin/lrelease target-bin/qmake $(QT-EMBEDDED_IPK_DIR)/opt/bin \
	)
endif
#	$(MAKE) -C $(QT-EMBEDDED_BUILD_DIR) DESTDIR=$(QT-EMBEDDED_IPK_DIR) install-strip
#	install -d $(QT-EMBEDDED_IPK_DIR)/opt/etc/
#	install -m 644 $(QT-EMBEDDED_SOURCE_DIR)/qt-embedded.conf $(QT-EMBEDDED_IPK_DIR)/opt/etc/qt-embedded.conf
#	install -d $(QT-EMBEDDED_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(QT-EMBEDDED_SOURCE_DIR)/rc.qt-embedded $(QT-EMBEDDED_IPK_DIR)/opt/etc/init.d/SXXqt-embedded
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QT-EMBEDDED_IPK_DIR)/opt/etc/init.d/SXXqt-embedded
	$(MAKE) $(QT-EMBEDDED_IPK_DIR)/CONTROL/control
#	install -m 755 $(QT-EMBEDDED_SOURCE_DIR)/postinst $(QT-EMBEDDED_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QT-EMBEDDED_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(QT-EMBEDDED_SOURCE_DIR)/prerm $(QT-EMBEDDED_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(QT-EMBEDDED_IPK_DIR)/CONTROL/prerm
#	if test -n "$(UPD-ALT_PREFIX)"; then \
		sed -i -e '/^[ 	]*update-alternatives /s|update-alternatives|$(UPD-ALT_PREFIX)/bin/&|' \
			$(QT-EMBEDDED_IPK_DIR)/CONTROL/postinst $(QT-EMBEDDED_IPK_DIR)/CONTROL/prerm; \
	fi
	echo $(QT-EMBEDDED_CONFFILES) | sed -e 's/ /\n/g' > $(QT-EMBEDDED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QT-EMBEDDED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qt-embedded-ipk: $(QT-EMBEDDED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qt-embedded-clean:
	rm -f $(QT-EMBEDDED_BUILD_DIR)/.built
	-$(MAKE) -C $(QT-EMBEDDED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qt-embedded-dirclean:
	rm -rf $(BUILD_DIR)/$(QT-EMBEDDED_DIR) $(QT-EMBEDDED_BUILD_DIR) $(QT-EMBEDDED_IPK_DIR) $(QT-EMBEDDED_IPK)
#
#
# Some sanity check for the package.
#
qt-embedded-check: $(QT-EMBEDDED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
