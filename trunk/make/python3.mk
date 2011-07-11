###########################################################
#
# python3
#
###########################################################

#
# PYTHON3_VERSION, PYTHON3_SITE and PYTHON3_SOURCE define
# the upstream location of the source code for the package.
# PYTHON3_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON3_UNZIP is the command used to unzip the source.
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
PYTHON3_VERSION=3.2.1
PYTHON3_VERSION_MAJOR=3.2
PYTHON3_SITE=http://www.python.org/ftp/python/$(PYTHON3_VERSION)
PYTHON3_SOURCE=Python-$(PYTHON3_VERSION).tgz
PYTHON3_DIR=Python-$(PYTHON3_VERSION)
PYTHON3_UNZIP=zcat

PYTHON3_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON3_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON3_SECTION=misc
PYTHON3_PRIORITY=optional
PYTHON3_DEPENDS=readline, bzip2, openssl, libdb, zlib, sqlite
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PYTHON3_DEPENDS+=, libstdc++
endif
PYTHON3_DEPENDS+=, $(NCURSES_FOR_OPTWARE_TARGET)
PYTHON3_SUGGESTS=

#
# PYTHON3_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON3_IPK_VERSION=1

#
# PYTHON3_CONFFILES should be a list of user-editable files
#PYTHON3_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON3_CPPFLAGS=
ifeq (vt4, $(OPTWARE_TARGET))
PYTHON3_CPPFLAGS+=-DPATH_MAX=4096
endif
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(LIBC_STYLE),uclibc)
PYTHON3_LDFLAGS=-lbz2 -lcrypt -ldb-$(LIBDB_LIB_VERSION) -lncurses -lreadline -lssl -lz
else
PYTHON3_LDFLAGS=
endif

#
# PYTHON3_BUILD_DIR is the directory in which the build is done.
# PYTHON3_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON3_IPK_DIR is the directory in which the ipk is built.
# PYTHON3_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON3_BUILD_DIR=$(BUILD_DIR)/python3
PYTHON3_SOURCE_DIR=$(SOURCE_DIR)/python3
PYTHON3_IPK_DIR=$(BUILD_DIR)/python3-$(PYTHON3_VERSION)-ipk
PYTHON3_IPK=$(BUILD_DIR)/python3_$(PYTHON3_VERSION)-$(PYTHON3_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# PYTHON3_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON3_PATCHES=\
	$(PYTHON3_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON3_SOURCE_DIR)/README.patch \
	$(PYTHON3_SOURCE_DIR)/config.guess.patch \
	$(PYTHON3_SOURCE_DIR)/config.sub.patch \
	$(PYTHON3_SOURCE_DIR)/configure.in.patch \
	$(PYTHON3_SOURCE_DIR)/setup.py.patch \
	$(PYTHON3_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON3_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \
	$(PYTHON3_SOURCE_DIR)/with-libintl.patch \

ifeq ($(NCURSES_FOR_OPTWARE_TARGET), ncurses)
PYTHON3_PATCHES+= $(PYTHON3_SOURCE_DIR)/disable-ncursesw.patch
endif

.PHONY: python3-source python3-unpack python3 python3-stage python3-ipk python3-clean python3-dirclean python3-check python3-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON3_SOURCE):
	$(WGET) -P $(@D) $(PYTHON3_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python3-source: $(DL_DIR)/$(PYTHON3_SOURCE) $(PYTHON3_PATCHES)

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
$(PYTHON3_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON3_SOURCE) $(PYTHON3_PATCHES) make/python3.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
ifeq (enable, $(GETTEXT_NLS))
	$(MAKE) gettext-stage
endif
	$(MAKE) bzip2-stage readline-stage openssl-stage libdb-stage sqlite-stage zlib-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	$(MAKE) autoconf-host-stage
	rm -rf $(BUILD_DIR)/$(PYTHON3_DIR) $(@D)
	$(PYTHON3_UNZIP) $(DL_DIR)/$(PYTHON3_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cat $(PYTHON3_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON3_DIR) -p1
	sed -i -e 's/MIPS_LINUX/MIPS/' $(BUILD_DIR)/$(PYTHON3_DIR)/Modules/_ctypes/libffi/configure.ac
	$(HOST_STAGING_PREFIX)/bin/autoreconf -vif $(BUILD_DIR)/$(PYTHON3_DIR)
	mkdir -p $(@D)
	( \
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > $(@D)/setup.cfg
	(cd $(@D); \
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON3_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON3_LDFLAGS)" \
		ac_cv_sizeof_off_t=8 \
		ac_cv_file__dev_ptmx=yes \
		ac_cv_file__dev_ptc=no \
		ac_cv_header_bluetooth_bluetooth_h=no \
		ac_cv_header_bluetooth_h=no \
		ac_cv_broken_sem_getvalue=no \
		ac_cv_have_size_t_format=yes \
		ac_cv_have_long_long_format=yes \
		../$(PYTHON3_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--enable-shared \
	)
#		--without-pymalloc \
;
	touch $@

python3-unpack: $(PYTHON3_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON3_BUILD_DIR)/.built: $(PYTHON3_BUILD_DIR)/.configured
	rm -f $@
	GNU_TARGET_NAME=$(GNU_TARGET_NAME) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
python3: $(PYTHON3_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON3_BUILD_DIR)/.staged: $(PYTHON3_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

python3-stage: $(PYTHON3_BUILD_DIR)/.staged

$(HOST_STAGING_PREFIX)/bin/python3.0: host/.configured make/python3.mk
	$(MAKE) $(PYTHON3_BUILD_DIR)/.built
	$(MAKE) -C $(PYTHON3_BUILD_DIR)/buildpython3 DESTDIR=$(HOST_STAGING_DIR) install
	rm -f $(@D)/bin/python

python3-host-stage: $(HOST_STAGING_PREFIX)/bin/python3.0

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON3_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: python3" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON3_PRIORITY)" >>$@
	@echo "Section: $(PYTHON3_SECTION)" >>$@
	@echo "Version: $(PYTHON3_VERSION)-$(PYTHON3_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON3_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON3_SITE)/$(PYTHON3_SOURCE)" >>$@
	@echo "Description: $(PYTHON3_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON3_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON3_IPK_DIR)/opt/sbin or $(PYTHON3_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON3_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON3_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON3_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON3_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON3_IPK): $(PYTHON3_BUILD_DIR)/.built
	rm -rf $(PYTHON3_IPK_DIR) $(BUILD_DIR)/python3*_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PYTHON3_BUILD_DIR) DESTDIR=$(PYTHON3_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON3_IPK_DIR)/opt/bin/python$(PYTHON3_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON3_IPK_DIR)/opt/lib/python$(PYTHON3_VERSION_MAJOR)/lib-dynload/*.so
	for f in $(PYTHON3_IPK_DIR)/opt/lib/libpython$(PYTHON3_VERSION_MAJOR)*.so.1.0 $(PYTHON3_IPK_DIR)/opt/lib/libpython3.so; \
		do chmod 755 $$f; $(STRIP_COMMAND) $$f; chmod 555 $$f; done
	for f in bin/2to3 ; \
	    do mv $(PYTHON3_IPK_DIR)/opt/$$f $(PYTHON3_IPK_DIR)/opt/`echo $$f | sed -e 's/\(\.\|$$\)/-3.1\1/'`; done
	install -d $(PYTHON3_IPK_DIR)/opt/local/bin
	install -d $(PYTHON3_IPK_DIR)/opt/local/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages
	$(MAKE) $(PYTHON3_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON3_SOURCE_DIR)/postinst $(PYTHON3_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON3_SOURCE_DIR)/prerm $(PYTHON3_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON3_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PYTHON3_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python3-ipk: $(PYTHON3_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python3-clean:
	-$(MAKE) -C $(PYTHON3_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python3-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON3_DIR) $(PYTHON3_BUILD_DIR) $(PYTHON3_IPK_DIR) $(PYTHON3_IPK)

#
# Some sanity check for the package.
#
python3-check: $(PYTHON3_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
