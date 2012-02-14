###########################################################
#
# python27
#
###########################################################

#
# PYTHON27_VERSION, PYTHON27_SITE and PYTHON27_SOURCE define
# the upstream location of the source code for the package.
# PYTHON27_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON27_UNZIP is the command used to unzip the source.
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
PYTHON27_VERSION=2.7.2
PYTHON27_VERSION_MAJOR=2.7
PYTHON27_SITE=http://python.org/ftp/python/$(PYTHON27_VERSION)
PYTHON27_SOURCE=Python-$(PYTHON27_VERSION).tar.bz2
PYTHON27_DIR=Python-$(PYTHON27_VERSION)
PYTHON27_UNZIP=bzcat

PYTHON27_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON27_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON27_SECTION=misc
PYTHON27_PRIORITY=optional
PYTHON27_DEPENDS=readline, bzip2, openssl, libdb, zlib, sqlite
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PYTHON27_DEPENDS+=, libstdc++
endif
PYTHON27_DEPENDS+=, $(NCURSES_FOR_OPTWARE_TARGET)
PYTHON27_SUGGESTS=

#
# PYTHON27_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON27_IPK_VERSION=2

#
# PYTHON27_CONFFILES should be a list of user-editable files
#PYTHON27_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON27_CPPFLAGS=
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(LIBC_STYLE),uclibc)
PYTHON27_LDFLAGS=-lbz2 -lcrypt -ldb-$(LIBDB_LIB_VERSION) -lncurses -lreadline -lssl -lz
else
PYTHON27_LDFLAGS=
endif

#
# PYTHON27_BUILD_DIR is the directory in which the build is done.
# PYTHON27_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON27_IPK_DIR is the directory in which the ipk is built.
# PYTHON27_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON27_BUILD_DIR=$(BUILD_DIR)/python27
PYTHON27_SOURCE_DIR=$(SOURCE_DIR)/python27
PYTHON27_IPK_DIR=$(BUILD_DIR)/python27-$(PYTHON27_VERSION)-ipk
PYTHON27_IPK=$(BUILD_DIR)/python27_$(PYTHON27_VERSION)-$(PYTHON27_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# PYTHON27_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON27_PATCHES=\
	$(PYTHON27_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON27_SOURCE_DIR)/README.patch \
	$(PYTHON27_SOURCE_DIR)/config.guess.patch \
	$(PYTHON27_SOURCE_DIR)/config.sub.patch \
	$(PYTHON27_SOURCE_DIR)/configure.in.patch \
	$(PYTHON27_SOURCE_DIR)/setup.py.patch \
	$(PYTHON27_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON27_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \

ifeq ($(NCURSES_FOR_OPTWARE_TARGET), ncurses)
PYTHON27_PATCHES+= $(PYTHON27_SOURCE_DIR)/disable-ncursesw.patch
endif

.PHONY: python27-source python27-unpack python27 python27-stage python27-ipk python27-clean python27-dirclean python27-check python27-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON27_SOURCE):
	$(WGET) -P $(@D) $(PYTHON27_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python27-source: $(DL_DIR)/$(PYTHON27_SOURCE) $(PYTHON27_PATCHES)

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
$(PYTHON27_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON27_SOURCE) $(PYTHON27_PATCHES) make/python27.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) bzip2-stage readline-stage openssl-stage libdb-stage sqlite-stage zlib-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	$(MAKE) autoconf-host-stage
	rm -rf $(BUILD_DIR)/$(PYTHON27_DIR) $(@D)
	$(PYTHON27_UNZIP) $(DL_DIR)/$(PYTHON27_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cat $(PYTHON27_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON27_DIR) -p1
	$(HOST_STAGING_PREFIX)/bin/autoreconf -vif $(BUILD_DIR)/$(PYTHON27_DIR)
	mkdir -p $(@D)
	cd $(@D); (\
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > setup.cfg
	(cd $(@D); \
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON27_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON27_LDFLAGS)" \
		ac_cv_sizeof_off_t=8 \
		ac_cv_file__dev_ptmx=yes \
		ac_cv_file__dev_ptc=no \
		ac_cv_header_bluetooth_bluetooth_h=no \
		ac_cv_header_bluetooth_h=no \
		ac_cv_have_long_long_format=yes \
		../$(PYTHON27_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--enable-shared \
		--enable-unicode=ucs4 \
	)
	touch $@

python27-unpack: $(PYTHON27_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON27_BUILD_DIR)/.built: $(PYTHON27_BUILD_DIR)/.configured
	rm -f $@
	GNU_TARGET_NAME=$(GNU_TARGET_NAME) $(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
python27: $(PYTHON27_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON27_BUILD_DIR)/.staged: $(PYTHON27_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

python27-stage: $(PYTHON27_BUILD_DIR)/.staged

$(HOST_STAGING_PREFIX)/bin/python2.7: host/.configured make/python27.mk
	$(MAKE) $(PYTHON27_BUILD_DIR)/.built
	$(MAKE) -C $(PYTHON27_BUILD_DIR)/buildpython27 DESTDIR=$(HOST_STAGING_DIR) install
	patch -b -p0 < $(PYTHON27_SOURCE_DIR)/disable-host-py_include.patch
	rm -f $(@D)/python

python27-host-stage: $(HOST_STAGING_PREFIX)/bin/python2.7

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON27_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: python27" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON27_PRIORITY)" >>$@
	@echo "Section: $(PYTHON27_SECTION)" >>$@
	@echo "Version: $(PYTHON27_VERSION)-$(PYTHON27_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON27_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON27_SITE)/$(PYTHON27_SOURCE)" >>$@
	@echo "Description: $(PYTHON27_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON27_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON27_IPK_DIR)/opt/sbin or $(PYTHON27_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON27_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON27_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON27_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON27_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON27_IPK): $(PYTHON27_BUILD_DIR)/.built
	rm -rf $(PYTHON27_IPK_DIR) $(BUILD_DIR)/python27_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PYTHON27_BUILD_DIR) DESTDIR=$(PYTHON27_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON27_IPK_DIR)/opt/bin/python$(PYTHON27_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON27_IPK_DIR)/opt/lib/python$(PYTHON27_VERSION_MAJOR)/lib-dynload/*.so
	chmod 755 $(PYTHON27_IPK_DIR)/opt/lib/libpython$(PYTHON27_VERSION_MAJOR).so.1.0
	$(STRIP_COMMAND) $(PYTHON27_IPK_DIR)/opt/lib/libpython$(PYTHON27_VERSION_MAJOR).so.1.0
	chmod 555 $(PYTHON27_IPK_DIR)/opt/lib/libpython$(PYTHON27_VERSION_MAJOR).so.1.0
	rm $(PYTHON27_IPK_DIR)/opt/bin/python $(PYTHON27_IPK_DIR)/opt/bin/python-config
#	cd $(PYTHON27_IPK_DIR)/opt/bin; ln -s python$(PYTHON27_VERSION_MAJOR) python
	for f in bin/pydoc bin/idle bin/smtpd.py; \
	    do mv $(PYTHON27_IPK_DIR)/opt/$$f $(PYTHON27_IPK_DIR)/opt/`echo $$f | sed -e 's/\(\.\|$$\)/-2.7\1/'`; done
	install -d $(PYTHON27_IPK_DIR)/opt/local/bin
	install -d $(PYTHON27_IPK_DIR)/opt/local/lib/python$(PYTHON27_VERSION_MAJOR)/site-packages
	sed -i -e 's|$(TARGET_CROSS)|/opt/bin/|g' \
	       -e 's|$(STAGING_INCLUDE_DIR)|/opt/include|g' \
	       -e 's|$(STAGING_LIB_DIR)|/opt/lib|g' \
	       -e '/^RUNSHARED=/s|=.*|=|' \
	       $(PYTHON27_IPK_DIR)/opt/lib/python2.7/config/Makefile
#ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
#	install -d $(PYTHON27_IPK_DIR)/usr/bin
#	ln -s /opt/bin/python $(PYTHON27_IPK_DIR)/usr/bin/python
#endif
	$(MAKE) $(PYTHON27_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON27_SOURCE_DIR)/postinst $(PYTHON27_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON27_SOURCE_DIR)/prerm $(PYTHON27_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON27_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PYTHON27_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python27-ipk: $(PYTHON27_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python27-clean:
	-$(MAKE) -C $(PYTHON27_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python27-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON27_DIR) $(PYTHON27_BUILD_DIR) $(PYTHON27_IPK_DIR) $(PYTHON27_IPK)

#
# Some sanity check for the package.
#
python27-check: $(PYTHON27_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
