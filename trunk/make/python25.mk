###########################################################
#
# python25
#
###########################################################

#
# PYTHON25_VERSION, PYTHON25_SITE and PYTHON25_SOURCE define
# the upstream location of the source code for the package.
# PYTHON25_DIR is the directory which is created when the source
# archive is unpacked.
# PYTHON25_UNZIP is the command used to unzip the source.
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
PYTHON25_VERSION=2.5.1
PYTHON25_VERSION_MAJOR=2.5
PYTHON25_SITE=http://www.python.org/ftp/python/$(PYTHON25_VERSION)/
PYTHON25_SOURCE=Python-$(PYTHON25_VERSION).tar.bz2
PYTHON25_DIR=Python-$(PYTHON25_VERSION)
PYTHON25_UNZIP=bzcat

PYTHON25_MAINTAINER=Brian Zhou<bzhou@users.sf.net>
PYTHON25_DESCRIPTION=Python is an interpreted, interactive, object-oriented programming language.
PYTHON25_SECTION=misc
PYTHON25_PRIORITY=optional
PYTHON25_DEPENDS=readline, bzip2, openssl, libdb, zlib, sqlite
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
PYTHON25_DEPENDS+=, libstdc++
endif
PYTHON25_DEPENDS+=, $(NCURSES_FOR_OPTWARE_TARGET)
PYTHON25_SUGGESTS=

#
# PYTHON25_IPK_VERSION should be incremented when the ipk changes.
#
PYTHON25_IPK_VERSION=2

#
# PYTHON25_CONFFILES should be a list of user-editable files
#PYTHON25_CONFFILES=/opt/etc/python.conf /opt/etc/init.d/SXXpython

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PYTHON25_CPPFLAGS=
# workaround for uclibc bug, see http://www.geocities.com/robm351/uclibc/index-8.html?20063#sec:ldso-python
ifeq ($(LIBC_STYLE),uclibc)
PYTHON25_LDFLAGS=-lbz2 -lcrypt -ldb-$(LIBDB_LIB_VERSION) -lncurses -lreadline -lssl -lz
else
PYTHON25_LDFLAGS=
endif

#
# PYTHON25_BUILD_DIR is the directory in which the build is done.
# PYTHON25_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PYTHON25_IPK_DIR is the directory in which the ipk is built.
# PYTHON25_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PYTHON25_BUILD_DIR=$(BUILD_DIR)/python25
PYTHON25_SOURCE_DIR=$(SOURCE_DIR)/python25
PYTHON25_IPK_DIR=$(BUILD_DIR)/python25-$(PYTHON25_VERSION)-ipk
PYTHON25_IPK=$(BUILD_DIR)/python25_$(PYTHON25_VERSION)-$(PYTHON25_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# PYTHON25_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# http://mail.python.org/pipermail/patches/2004-October/016312.html
PYTHON25_PATCHES=\
	$(PYTHON25_SOURCE_DIR)/Makefile.pre.in.patch \
	$(PYTHON25_SOURCE_DIR)/README.patch \
	$(PYTHON25_SOURCE_DIR)/config.guess.patch \
	$(PYTHON25_SOURCE_DIR)/config.sub.patch \
	$(PYTHON25_SOURCE_DIR)/configure.in.patch \
	$(PYTHON25_SOURCE_DIR)/setup.py.patch \
	$(PYTHON25_SOURCE_DIR)/Lib-site.py.patch \
	$(PYTHON25_SOURCE_DIR)/Lib-distutils-distutils.cfg.patch \

ifeq ($(NCURSES_FOR_OPTWARE_TARGET), ncurses)
PYTHON25_PATCHES+= $(PYTHON25_SOURCE_DIR)/disable-ncursesw.patch
endif

.PHONY: python25-source python25-unpack python25 python25-stage python25-ipk python25-clean python25-dirclean python25-check python25-host-stage

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PYTHON25_SOURCE):
	$(WGET) -P $(DL_DIR) $(PYTHON25_SITE)/$(PYTHON25_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PYTHON25_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
python25-source: $(DL_DIR)/$(PYTHON25_SOURCE) $(PYTHON25_PATCHES)

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
$(PYTHON25_BUILD_DIR)/.configured: $(DL_DIR)/$(PYTHON25_SOURCE) $(PYTHON25_PATCHES) make/python25.mk
ifeq (libstdc++, $(filter libstdc++, $(PACKAGES)))
	$(MAKE) libstdc++-stage
endif
	$(MAKE) bzip2-stage readline-stage openssl-stage libdb-stage sqlite-stage zlib-stage
	$(MAKE) $(NCURSES_FOR_OPTWARE_TARGET)-stage
	rm -rf $(BUILD_DIR)/$(PYTHON25_DIR) $(PYTHON25_BUILD_DIR)
	$(PYTHON25_UNZIP) $(DL_DIR)/$(PYTHON25_SOURCE) | tar -C $(BUILD_DIR) -xf -
	cd $(BUILD_DIR)/$(PYTHON25_DIR); \
	    cat $(PYTHON25_PATCHES) | patch -bd $(BUILD_DIR)/$(PYTHON25_DIR) -p1; \
	    autoconf configure.in > configure
	mkdir $(PYTHON25_BUILD_DIR)
	(cd $(PYTHON25_BUILD_DIR); \
	( \
	echo "[build_ext]"; \
	echo "include-dirs=$(STAGING_INCLUDE_DIR):$(STAGING_INCLUDE_DIR)/ncurses"; \
	echo "library-dirs=$(STAGING_LIB_DIR)"; \
	echo "rpath=/opt/lib") > setup.cfg; \
	\
	 $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PYTHON25_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PYTHON25_LDFLAGS)" \
		ac_cv_sizeof_off_t=8 \
		ac_cv_file__dev_ptmx=yes \
		ac_cv_file__dev_ptc=no \
		ac_cv_header_bluetooth_bluetooth_h=no \
		ac_cv_header_bluetooth_h=no \
		../$(PYTHON25_DIR)/configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=/opt/man \
		--enable-shared \
		--enable-unicode=ucs4 \
	)
	touch $@

python25-unpack: $(PYTHON25_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PYTHON25_BUILD_DIR)/.built: $(PYTHON25_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
python25: $(PYTHON25_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PYTHON25_BUILD_DIR)/.staged: $(PYTHON25_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

python25-stage: $(PYTHON25_BUILD_DIR)/.staged

$(HOST_STAGING_PREFIX)/bin/python2.5: host/.configured make/python25.mk
	$(MAKE) $(PYTHON25_BUILD_DIR)/.built
	$(MAKE) -C $(PYTHON25_BUILD_DIR)/buildpython25 DESTDIR=$(HOST_STAGING_DIR) install
	rm -f $(@D)/python

python25-host-stage: $(HOST_STAGING_PREFIX)/bin/python2.5

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/python
#
$(PYTHON25_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: python25" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PYTHON25_PRIORITY)" >>$@
	@echo "Section: $(PYTHON25_SECTION)" >>$@
	@echo "Version: $(PYTHON25_VERSION)-$(PYTHON25_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PYTHON25_MAINTAINER)" >>$@
	@echo "Source: $(PYTHON25_SITE)/$(PYTHON25_SOURCE)" >>$@
	@echo "Description: $(PYTHON25_DESCRIPTION)" >>$@
	@echo "Depends: $(PYTHON25_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PYTHON25_IPK_DIR)/opt/sbin or $(PYTHON25_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PYTHON25_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PYTHON25_IPK_DIR)/opt/etc/python/...
# Documentation files should be installed in $(PYTHON25_IPK_DIR)/opt/doc/python/...
# Daemon startup scripts should be installed in $(PYTHON25_IPK_DIR)/opt/etc/init.d/S??python
#
# You may need to patch your application to make it use these locations.
#
$(PYTHON25_IPK): $(PYTHON25_BUILD_DIR)/.built
	rm -rf $(PYTHON25_IPK_DIR) $(BUILD_DIR)/python25_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PYTHON25_BUILD_DIR) DESTDIR=$(PYTHON25_IPK_DIR) install
	$(STRIP_COMMAND) $(PYTHON25_IPK_DIR)/opt/bin/python$(PYTHON25_VERSION_MAJOR)
	$(STRIP_COMMAND) $(PYTHON25_IPK_DIR)/opt/lib/python$(PYTHON25_VERSION_MAJOR)/lib-dynload/*.so
	chmod 755 $(PYTHON25_IPK_DIR)/opt/lib/libpython$(PYTHON25_VERSION_MAJOR).so.1.0
	$(STRIP_COMMAND) $(PYTHON25_IPK_DIR)/opt/lib/libpython$(PYTHON25_VERSION_MAJOR).so.1.0
	chmod 555 $(PYTHON25_IPK_DIR)/opt/lib/libpython$(PYTHON25_VERSION_MAJOR).so.1.0
	rm $(PYTHON25_IPK_DIR)/opt/bin/python
#	cd $(PYTHON25_IPK_DIR)/opt/bin; ln -s python$(PYTHON25_VERSION_MAJOR) python
	for f in bin/pydoc bin/idle bin/smtpd.py man/man1/python.1; \
	    do mv $(PYTHON25_IPK_DIR)/opt/$$f $(PYTHON25_IPK_DIR)/opt/`echo $$f | sed -e 's/\(\.\|$$\)/2.5\1/'`; done
	install -d $(PYTHON25_IPK_DIR)/opt/local/bin
	install -d $(PYTHON25_IPK_DIR)/opt/local/lib/python$(PYTHON25_VERSION_MAJOR)/site-packages
	sed -i -e 's|$(TARGET_CROSS)|/opt/bin/|g' \
	       -e 's|$(STAGING_INCLUDE_DIR)|/opt/include|g' \
	       -e 's|$(STAGING_LIB_DIR)|/opt/lib|g' \
	       -e '/^RUNSHARED=/s|=.*|=|' \
	       $(PYTHON25_IPK_DIR)/opt/lib/python2.5/config/Makefile
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
#	install -d $(PYTHON25_IPK_DIR)/usr/bin
#	ln -s /opt/bin/python $(PYTHON25_IPK_DIR)/usr/bin/python
endif
	$(MAKE) $(PYTHON25_IPK_DIR)/CONTROL/control
#	install -m 755 $(PYTHON25_SOURCE_DIR)/postinst $(PYTHON25_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(PYTHON25_SOURCE_DIR)/prerm $(PYTHON25_IPK_DIR)/CONTROL/prerm
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PYTHON25_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
python25-ipk: $(PYTHON25_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
python25-clean:
	-$(MAKE) -C $(PYTHON25_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
python25-dirclean:
	rm -rf $(BUILD_DIR)/$(PYTHON25_DIR) $(PYTHON25_BUILD_DIR) $(PYTHON25_IPK_DIR) $(PYTHON25_IPK)

#
# Some sanity check for the package.
#
python25-check: $(PYTHON25_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PYTHON25_IPK)
