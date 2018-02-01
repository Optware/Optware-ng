###########################################################
#
# libc-dev
#
###########################################################
#
# LIBC-DEV_VERSION, LIBC-DEV_SITE and LIBC-DEV_SOURCE define
# the upstream location of the source code for the package.
# LIBC-DEV_DIR is the directory which is created when the source
# archive is unpacked.
# LIBC-DEV_UNZIP is the command used to unzip the source.
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
#LIBC-DEV_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/libc-dev
LIBC-DEV_VERSION=$(LIBNSL_VERSION)
#LIBC-DEV_SOURCE=libc-dev-$(LIBC-DEV_VERSION).tar.gz
LIBC-DEV_DIR=libc-dev-$(LIBC-DEV_VERSION)
#LIBC-DEV_UNZIP=zcat
LIBC-DEV_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LIBC-DEV_DESCRIPTION=libc development files.
LIBC-DEV_SECTION=devel
LIBC-DEV_PRIORITY=optional
LIBC-DEV_DEPENDS=libstdc++
LIBC-DEV_SUGGESTS=
LIBC-DEV_CONFLICTS=

LIBC-DEV_IPK_VERSION?=8

ifeq (uclibc, $(LIBC_STYLE))
LIBC-DEV_VERSION = $(CROSS_CONFIGURATION_UCLIBC_VERSION)
else
LIBC-DEV_VERSION = $(CROSS_CONFIGURATION_GLIBC_VERSION)
endif

LIBC-DEV_SOURCE_DIR=$(SOURCE_DIR)/libc-dev

ifdef TARGET_USRLIBDIR
LIBC-DEV_USRLIBDIR=$(TARGET_USRLIBDIR)
else
LIBC-DEV_USRLIBDIR=$(TARGET_LIBDIR)
endif

ifdef TARGET_LIBC_LIBDIR
LIBC-DEV_LIBDIR=$(TARGET_LIBC_LIBDIR)
else
LIBC-DEV_LIBDIR=$(TARGET_LIBDIR)
endif

LIBC-DEV_CRT_DIR ?= $(TARGET_PREFIX)/`$(TARGET_CC) -dumpmachine`/lib
LIBC-DEV_LIBC_SO_DIR ?= $(LIBC-DEV_USRLIBDIR)
LIBC-DEV_NONSHARED_LIB_DIR ?= $(LIBC-DEV_LIBC_SO_DIR)

LIBC-DEV_UCLIBC_STATIC_LIBS ?= libc.a libc_pic.a libcrypt.a libcrypt_pic.a libdl.a \
libdl_pic.a libm.a libm_pic.a libnsl.a libnsl_pic.a libpthread.a libpthread_pic.a libresolv.a \
libresolv_pic.a librt.a librt_pic.a libstdc++.a libthread_db.a libthread_db_pic.a libutil.a \
libutil_pic.a uclibc_nonshared.a libpthread_nonshared.a

LIBC-DEV_GLIBC_STATIC_LIBS ?= libc.a libg.a libm.a libdl.a librt.a libanl.a libnsl.a \
libieee.a libutil.a libcrypt.a libmcheck.a libresolv.a librpcsvc.a libstdc++*.a libpthread.a \
libc_nonshared.a libBrokenLocale.a libpthread_nonshared.a

LIBC-DEV_GLIBC-SYMLINK ?= ln -s libanl.so.1 libanl.so; \
ln -s libBrokenLocale.so.1 libBrokenLocale.so; \
ln -s libc.so.6 libc.so; \
ln -s libcidn.so.1 libcidn.so; \
ln -s libcrypt.so.1 libcrypt.so; \
ln -s libdl.so.2 libdl.so; \
ln -s libm.so.6 libm.so; \
ln -s libnss_compat.so.2 libnss_compat.so; \
ln -s libnss_dns.so.2 libnss_dns.so; \
ln -s libnss_files.so.2 libnss_files.so; \
ln -s libnss_hesiod.so.2 libnss_hesiod.so; \
ln -s libnss_nis.so.2 libnss_nis.so; \
ln -s libnss_nisplus.so.2 libnss_nisplus.so; \
ln -s libpthread.so.0 libpthread.so; \
ln -s libresolv.so.2 libresolv.so; \
ln -s librt.so.1 librt.so; \
ln -s libthread_db.so.1 libthread_db.so; \
ln -s libutil.so.1 libutil.so

LIBC-DEV_LIBGCC_STATIC ?= $(shell find $(TARGET_CROSS_TOP) -type f -name libgcc.a | head -1)

#
# LIBC-DEV_CONFFILES should be a list of user-editable files
#LIBC-DEV_CONFFILES=$(TARGET_PREFIX)/etc/libc-dev.conf $(TARGET_PREFIX)/etc/init.d/SXXlibc-dev

#
# LIBC-DEV_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LIBC-DEV_PATCHES=$(LIBC-DEV_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LIBC-DEV_CPPFLAGS=
LIBC-DEV_LDFLAGS=

#
# LIBC-DEV_BUILD_DIR is the directory in which the build is done.
# LIBC-DEV_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LIBC-DEV_IPK_DIR is the directory in which the ipk is built.
# LIBC-DEV_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LIBC-DEV_BUILD_DIR=$(BUILD_DIR)/libc-dev
LIBC-DEV_SOURCE_DIR=$(SOURCE_DIR)/libc-dev
LIBC-DEV_IPK_DIR=$(BUILD_DIR)/libc-dev-$(LIBC-DEV_VERSION)-ipk
LIBC-DEV_IPK=$(BUILD_DIR)/libc-dev_$(LIBC-DEV_VERSION)-$(LIBC-DEV_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: libc-dev-source libc-dev-unpack libc-dev libc-dev-stage libc-dev-ipk libc-dev-clean libc-dev-dirclean libc-dev-check

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/libc-dev
#
$(BUILD_DIR)/libc-dev-$(LIBC-DEV_VERSION)-ipk/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: libc-dev" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LIBC-DEV_PRIORITY)" >>$@
	@echo "Section: $(LIBC-DEV_SECTION)" >>$@
	@echo "Version: $(LIBC-DEV_VERSION)-$(LIBC-DEV_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LIBC-DEV_MAINTAINER)" >>$@
	@echo "Source: $(LIBC-DEV_SITE)/$(LIBC-DEV_SOURCE)" >>$@
	@echo "Description: $(LIBC-DEV_DESCRIPTION)" >>$@
	@echo "Depends: $(LIBC-DEV_DEPENDS)" >>$@
	@echo "Suggests: $(LIBC-DEV_SUGGESTS)" >>$@
	@echo "Conflicts: $(LIBC-DEV_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/sbin or $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/etc/libc-dev/...
# Documentation files should be installed in $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/doc/libc-dev/...
# Daemon startup scripts should be installed in $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??libc-dev
#
# You may need to patch your application to make it use these locations.
#
$(LIBC-DEV_IPK): make/libc-dev.mk
	rm -rf $(LIBC-DEV_IPK_DIR) $(BUILD_DIR)/libc-dev_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	-rsync  -rlpgoD --copy-unsafe-links $(TARGET_INCDIR) $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/
	cp -f $(LIBC-DEV_LIBGCC_STATIC) $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	rm -rf $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/zlib.h \
		$(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/zconf.h \
		$(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/libintl.h \
		$(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/openssl
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	rm -f $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/iconv.h
endif
	$(INSTALL) -d $(LIBC-DEV_IPK_DIR)/$(LIBC-DEV_CRT_DIR)
	rsync -l $(LIBC-DEV_USRLIBDIR)/*crt*.o $(LIBC-DEV_IPK_DIR)/$(LIBC-DEV_CRT_DIR)
	cp -af $(LIBC-DEV_SOURCE_DIR)/libgcc_s.so $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib/
	$(INSTALL) -d $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib/
ifeq (uclibc, $(LIBC_STYLE))
	# static libs
	cp -af $(addprefix $(LIBC-DEV_NONSHARED_LIB_DIR)/, $(LIBC-DEV_UCLIBC_STATIC_LIBS)) \
								$(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	# shared libs links
	cd $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib; \
		for f in libc.so libcrypt.so libdl.so libm.so libpthread.so libresolv.so librt.so libutil.so; do \
			if [ -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/$${f}.1 ]; then \
				ln -s $${f}.1 $${f}; \
			elif [ -f $(UCLIBC-OPT_LIBS_SOURCE_DIR)/$${f}.0 ]; then \
				ln -s $${f}.0 $${f}; \
			else \
				: do nothing; \
			fi \
		done
else
	# static libs
	cp -af $(addprefix $(LIBC-DEV_NONSHARED_LIB_DIR)/, $(LIBC-DEV_GLIBC_STATIC_LIBS)) \
								$(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib
	# shared libs links
	cd $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib; \
		$(LIBC-DEV_GLIBC-SYMLINK)
endif
	if [ -f $(SOURCE_DIR)/$(OPTWARE_TARGET)/libc.so ]; then \
		rm -f $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib/libc.so; \
		$(INSTALL) -m 644 $(SOURCE_DIR)/$(OPTWARE_TARGET)/libc.so $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/lib; \
	fi
	rm -rf $(LIBC-DEV_IPK_DIR)$(TARGET_PREFIX)/include/c++
	$(MAKE) $(LIBC-DEV_IPK_DIR)/CONTROL/control
	echo $(LIBC-DEV_CONFFILES) | sed -e 's/ /\n/g' > $(LIBC-DEV_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LIBC-DEV_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(LIBC-DEV_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
libc-dev-ipk: $(LIBC-DEV_IPK)

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
libc-dev-dirclean:
	rm -rf $(BUILD_DIR)/$(LIBC-DEV_DIR) $(LIBC-DEV_BUILD_DIR) $(LIBC-DEV_IPK_DIR) $(LIBC-DEV_IPK)
#
#
# Some sanity check for the package.
#
libc-dev-check: $(LIBC-DEV_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LIBC-DEV_IPK)
