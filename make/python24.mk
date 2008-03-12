###########################################################
#
# python24
#
###########################################################

#
# PYTHON24_VERSION, PYTHON24_SITE and PYTHON24_SOURCE define
# the upstream location of the source code for the package.
# PYTHON24_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON24_UNZIP is the command used to unzip the source.
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
PYTHON24_VERSION=2.4.5
PYTHON24_VERSION_MAJOR=2.4
PYTHON24_SITE=http://python.org/ftp/python/$(PYTHON24_VERSION)
PYTHON24_SOURCE=Python-$(PYTHON24_VERSION).tgz
PYTHON24_DIR=Python-$(PYTHON24_VERSION)
PYTHON24_UNZIP=zcat

PYTHON24_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON24_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON24_SECTION=misc
PYTHON24_PRIORITY=optional
PYTHON24_DEPENDS=readline, bzip2, openssl, libdb, zlib
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PYTHON24_DEPENDS+=, libstdc++
endif
PYTHON24_DEPENDS+=, $(NCURSES_FOR_OPTWARE_TARGET)
PYTHON24_SUGGESTS=

#
# PYTHON24_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON24_IPK_VERSION=1

#
# PYTHON24_CONFFILES should be a list of user-editable files
#PYTHON24_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON24_CPPFLAGS=
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(LIBC_STYLE),uclibc)
PYTHON24_LDFLAGS=-lbz2 -lcrypt -ldb-$(LIBDB_LIB_VERSION) -lncurses -lreadline -lssl -lz
else
PYTHON24_LDFLAGS=
endif

#
# PYTHON24_BUILD_DIR is the directory in which the build is done.
# PYTHON24_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON24_IPK_DIR is the directory in which the ipk is built.
# PYTHON24_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON24_BUILD_DIR=$(BUILD_DIR)/python24
PYTHON24_SOURCE_DIR=$(SOURCE_DIR)/python24
PYTHON24_IPK_DIR=$(BUILD_DIR)/python24-$(PYTHON24_VERSION)-ipk
PYTHON24_IPK=$(BUILD_DIR)/python24_$(PYTHON24_VERSION)-$(PYTHON24_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# PYTHON24_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON24_PATCHES=\
	$(PYTHON24_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON24_SOURCE_DIR)/README.patch \
	$(PYTHON24_SOURCE_DIR)/config.guess.patch \
	$(PYTHON24_SOURCE_DIR)/config.sub.patch \
	$(PYTHON24_SOURCE_DIR)/configure.in.patch \
	$(PYTHON24_SOURCE_DIR)/setup.py.patch \
	$(PYTHON24_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON24_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \

ifeq ($(NCURSES_FOR_OPTWARE_TARGET), ncurses)
PYTHON24_PATCHES+= $(PYTHON24_SOURCE_DIR)/disable-ncursesw.patch
endif

.PHONY: python24-source python24-unpack python24 python24-stage python24-ipk python24-clean python24-dirclean python24-check python24-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON24_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYTHON24_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python24-source: $(DL_DIR)/$(PYTHON24_SOURCE) $(PYTHON24_PATCHES)

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
$(PYTHON24_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON24_SOURCE) $(PYTHON24_PATCHES) make/python24.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) bzip2-stage readline-stage openssl-stage libdb-stage zlib-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(PYTHON24_DIR) $(PYTHON24_BUILD_DIR)
	$(PYTHON24_UNZIP) $(DL_DIR)/$(PYTHON24_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cat $(PYTHON24_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON24_DIR) -p1
	cd $(BUILD_DIR)/$(PYTHON24_DIR); autoconf configure.in > configure
	mkdir $(PYTHON24_BUILD_DIR)
	(cd $(PYTHON24_BUILD_DIR); \
	( \
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > setup.cfg; \
	\
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON24_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON24_LDFLAGS)" \
		ac_cv_sizeof_off_t=8 \
		ac_cv_header_bluetooth_bluetooth_h=no \
		ac_cv_header_bluetooth_h=no \
		../$(PYTHON24_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--enable-shared \
		--enable-unicode=ucs4 \
	)
	touch $@

python24-unpack: $(PYTHON24_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON24_BUILD_DIR)/.built: $(PYTHON24_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
python24: $(PYTHON24_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON24_BUILD_DIR)/.staged: $(PYTHON24_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	install $(@D)/buildpython/python $(STAGING_DIR)/opt/bin/
	touch $@

python24-stage: $(PYTHON24_BUILD_DIR)/.staged

$(HOST_STAGING_PREFIX)/bin/python2.4: host/.configured make/python24.mk
	$(MAKE) $(PYTHON24_BUILD_DIR)/.built
	$(MAKE) -C $(PYTHON24_BUILD_DIR)/buildpython DESTDIR=$(HOST_STAGING_DIR) install
	rm -f $(@D)/python

python24-host-stage: $(HOST_STAGING_PREFIX)/bin/python2.4

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON24_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: python24" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON24_PRIORITY)" >>$@
	@echo "Section: $(PYTHON24_SECTION)" >>$@
	@echo "Version: $(PYTHON24_VERSION)-$(PYTHON24_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON24_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON24_SITE)/$(PYTHON24_SOURCE)" >>$@
	@echo "Description: $(PYTHON24_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON24_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON24_IPK_DIR)/opt/sbin or $(PYTHON24_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON24_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON24_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON24_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON24_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON24_IPK): $(PYTHON24_BUILD_DIR)/.built
	rm -rf $(PYTHON24_IPK_DIR) $(BUILD_DIR)/python24_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PYTHON24_BUILD_DIR) DESTDIR=$(PYTHON24_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON24_IPK_DIR)/opt/bin/python$(PYTHON24_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON24_IPK_DIR)/opt/lib/python$(PYTHON24_VERSION_MAJOR)/lib-dynload/*.so
	chmod 755 $(PYTHON24_IPK_DIR)/opt/lib/libpython$(PYTHON24_VERSION_MAJOR).so.1.0
	$(STRIP_COMMAND) $(PYTHON24_IPK_DIR)/opt/lib/libpython$(PYTHON24_VERSION_MAJOR).so.1.0
	chmod 555 $(PYTHON24_IPK_DIR)/opt/lib/libpython$(PYTHON24_VERSION_MAJOR).so.1.0
	(cd $(PYTHON24_IPK_DIR)/opt/bin; \
		mv idle idle$(PYTHON24_VERSION_MAJOR); \
		mv pydoc pydoc$(PYTHON24_VERSION_MAJOR); \
		mv smtpd.py smtpd$(PYTHON24_VERSION_MAJOR).py; \
	)
	rm $(PYTHON24_IPK_DIR)/opt/bin/python
	install -d $(PYTHON24_IPK_DIR)/opt/local/bin
	install -d $(PYTHON24_IPK_DIR)/opt/local/lib/python$(PYTHON24_VERSION_MAJOR)/site-packages
	sed -i -e 's|$(TARGET_CROSS)|/opt/bin/|g' \
	       -e 's|$(STAGING_INCLUDE_DIR)|/opt/include|g' \
	       -e 's|$(STAGING_LIB_DIR)|/opt/lib|g' \
	       -e '/^RUNSHARED=/s|=.*|=|' \
	       $(PYTHON24_IPK_DIR)/opt/lib/python2.4/config/Makefile
	$(MAKE) $(PYTHON24_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON24_SOURCE_DIR)/postinst $(PYTHON24_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON24_SOURCE_DIR)/prerm $(PYTHON24_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON24_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python24-ipk: $(PYTHON24_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python24-clean:
	-$(MAKE) -C $(PYTHON24_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python24-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON24_DIR) $(PYTHON24_BUILD_DIR) $(PYTHON24_IPK_DIR) $(PYTHON24_IPK)

#
# Some sanity check for the package.
#
python24-check: $(PYTHON24_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PYTHON24_IPK)
