###########################################################
#
# sane-backends
#
###########################################################

# You must replace "sane-backends" and "SANE_BACKENDS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SANE_BACKENDS_VERSION, SANE_BACKENDS_SITE and SANE_BACKENDS_SOURCE define
# the upstream location of the source code for the package.
# SANE_BACKENDS_DIR is the directory which is created when the source
# archive is unpacked.
# SANE_BACKENDS_UNZIP is the command used to unzip the source.
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
#SANE_BACKENDS_SITE=ftp://ftp.sane-project.org/pub/sane/sane-backends-1.0.15
#SANE_BACKENDS_SITE=http://gd.tuwien.ac.at/hci/sane/sane-backends-$(SANE_BACKENDS_VERSION)
SANE_BACKEND_RELEASE=1.0.19
SANE_BACKENDS_VERSION=$(SANE_BACKEND_RELEASE)+cvs$(SANE_BACKENDS_CVS_DATE)
SANE_BACKENDS_SITE=ftp://ftp.sane-project.org/pub/sane/sane-backends-$(SANE_BACKENDS_VERSION)
SANE_BACKENDS_SITE_OLD=ftp://ftp.sane-project.org/pub/sane/old-versions/sane-backends-$(SANE_BACKENDS_VERSION)
SANE_BACKENDS_SOURCE=sane-backends-$(SANE_BACKENDS_VERSION).tar.gz
SANE_BACKENDS_DIR=sane-backends
SANE_BACKENDS_UNZIP=zcat
SANE_BACKENDS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SANE_BACKENDS_DESCRIPTION=SANE is a universal scanner interface
SANE_BACKENDS_SECTION=util
SANE_BACKENDS_PRIORITY=optional
SANE_BACKENDS_DEPENDS=libjpeg, libtiff, libusb
SANE_BACKENDS_SUGGESTS=xinetd, inetutils
SANE_BACKENDS_CONFLICTS=

# CVS info
SANE_BACKENDS_CVS_DATE=20090424
SANE_BACKENDS_CVS_OPTS=-D $(SANE_BACKENDS_CVS_DATE)
SANE_BACKENDS_REPOSITORY=:pserver:anonymous@cvs.alioth.debian.org:/cvsroot/sane


#
# SANE_BACKENDS_IPK_VERSION should be incremented when the ipk changes.
#
SANE_BACKENDS_IPK_VERSION=1

#
# SANE_BACKENDS_CONFFILES should be a list of user-editable files
SANE_BACKENDS_CONFFILES=/opt/etc/sane.d/saned.conf /opt/etc/init.d/S01sane-backends

#
# SANE_BACKENDS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SANE_BACKENDS_PATCHES=$(SANE_BACKENDS_SOURCE_DIR)/Makefile.in.patch \
	$(SANE_BACKENDS_SOURCE_DIR)/tools-Makefile.in.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SANE_BACKENDS_CPPFLAGS=
SANE_BACKENDS_LDFLAGS=-Wl,-rpath=/opt/lib/sane -ldl -lpthread

#
# SANE_BACKENDS_BUILD_DIR is the directory in which the build is done.
# SANE_BACKENDS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SANE_BACKENDS_IPK_DIR is the directory in which the ipk is built.
# SANE_BACKENDS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SANE_BACKENDS_BUILD_DIR=$(BUILD_DIR)/sane-backends
SANE_BACKENDS_SOURCE_DIR=$(SOURCE_DIR)/sane-backends
SANE_BACKENDS_IPK_DIR=$(BUILD_DIR)/sane-backends-$(SANE_BACKENDS_VERSION)-ipk
SANE_BACKENDS_IPK=$(BUILD_DIR)/sane-backends_$(SANE_BACKENDS_VERSION)-$(SANE_BACKENDS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/sane-backends-$(SANE_BACKENDS_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(SANE_BACKENDS_DIR) && \
		cvs -d$(SANE_BACKENDS_REPOSITORY) -z3 co $(SANE_BACKENDS_CVS_OPTS) sane-backends && \
		tar -czf $@ $(SANE_BACKENDS_DIR) && \
		rm -rf $(SANE_BACKENDS_DIR) \
	)

#	$(WGET) -P $(DL_DIR) $(SANE_BACKENDS_SITE)/$(SANE_BACKENDS_SOURCE) || \
#	$(WGET) -P $(DL_DIR) $(SANE_BACKENDS_SITE_OLD)/$(SANE_BACKENDS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
sane-backends-source: $(DL_DIR)/$(SANE_BACKENDS_SOURCE) $(SANE_BACKENDS_PATCHES)

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
$(SANE_BACKENDS_BUILD_DIR)/.configured: $(DL_DIR)/$(SANE_BACKENDS_SOURCE) $(SANE_BACKENDS_PATCHES)
	$(MAKE) libusb-stage libjpeg-stage libtiff-stage
	rm -rf $(BUILD_DIR)/$(SANE_BACKENDS_DIR) $(@D)
	$(SANE_BACKENDS_UNZIP) $(DL_DIR)/$(SANE_BACKENDS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SANE_BACKENDS_PATCHES)" ; \
		then cat $(SANE_BACKENDS_PATCHES) | \
		patch -d $(BUILD_DIR)/$(SANE_BACKENDS_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(SANE_BACKENDS_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(SANE_BACKENDS_DIR) $(@D) ; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SANE_BACKENDS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SANE_BACKENDS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-fork-process \
		--without-gphoto2 \
		--disable-translations \
		--disable-nls \
		--disable-static \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

sane-backends-unpack: $(SANE_BACKENDS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SANE_BACKENDS_BUILD_DIR)/.built: $(SANE_BACKENDS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
sane-backends: $(SANE_BACKENDS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SANE_BACKENDS_BUILD_DIR)/.staged: $(SANE_BACKENDS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	rm -f $(STAGING_LIB_DIR)/libsane.la $(STAGING_LIB_DIR)/sane/*.la
	touch $@

sane-backends-stage: $(SANE_BACKENDS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/sane-backends
#
$(SANE_BACKENDS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: sane-backends" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SANE_BACKENDS_PRIORITY)" >>$@
	@echo "Section: $(SANE_BACKENDS_SECTION)" >>$@
	@echo "Version: $(SANE_BACKENDS_VERSION)-$(SANE_BACKENDS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SANE_BACKENDS_MAINTAINER)" >>$@
	@echo "Source: $(SANE_BACKENDS_SITE)/$(SANE_BACKENDS_SOURCE)" >>$@
	@echo "Description: $(SANE_BACKENDS_DESCRIPTION)" >>$@
	@echo "Depends: $(SANE_BACKENDS_DEPENDS)" >>$@
	@echo "Suggests: $(SANE_BACKENDS_SUGGESTS)" >>$@
	@echo "Conflicts: $(SANE_BACKENDS_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SANE_BACKENDS_IPK_DIR)/opt/sbin or $(SANE_BACKENDS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SANE_BACKENDS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SANE_BACKENDS_IPK_DIR)/opt/etc/sane-backends/...
# Documentation files should be installed in $(SANE_BACKENDS_IPK_DIR)/opt/doc/sane-backends/...
# Daemon startup scripts should be installed in $(SANE_BACKENDS_IPK_DIR)/opt/etc/init.d/S??sane-backends
#
# You may need to patch your application to make it use these locations.
#
$(SANE_BACKENDS_IPK): $(SANE_BACKENDS_BUILD_DIR)/.built
	rm -rf $(SANE_BACKENDS_IPK_DIR) $(BUILD_DIR)/sane-backends_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SANE_BACKENDS_BUILD_DIR) DESTDIR=$(SANE_BACKENDS_IPK_DIR) install
	rm -rf $(SANE_BACKENDS_IPK_DIR)/opt/lib/libsane.la
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/bin/gamma4scanimage
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/bin/sane-find-scanner
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/bin/scanimage
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/sbin/saned
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/lib/sane/*.so.*
	$(STRIP_COMMAND) $(SANE_BACKENDS_IPK_DIR)/opt/lib/*.so.*
	rm -rf $(SANE_BACKENDS_IPK_DIR)/opt/lib/sane/*.la
	install -d $(SANE_BACKENDS_IPK_DIR)/opt/etc/init.d
	install -m 755 $(SANE_BACKENDS_SOURCE_DIR)/rc.sane-backends $(SANE_BACKENDS_IPK_DIR)/opt/etc/init.d/S01sane-backends
	$(MAKE) $(SANE_BACKENDS_IPK_DIR)/CONTROL/control
	install -m 755 $(SANE_BACKENDS_SOURCE_DIR)/postinst $(SANE_BACKENDS_IPK_DIR)/CONTROL/postinst
	install -m 755 $(SANE_BACKENDS_SOURCE_DIR)/prerm $(SANE_BACKENDS_IPK_DIR)/CONTROL/prerm
	echo $(SANE_BACKENDS_CONFFILES) | sed -e 's/ /\n/g' > $(SANE_BACKENDS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SANE_BACKENDS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
sane-backends-ipk: $(SANE_BACKENDS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
sane-backends-clean:
	-$(MAKE) -C $(SANE_BACKENDS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
sane-backends-dirclean:
	rm -rf $(BUILD_DIR)/$(SANE_BACKENDS_DIR) $(SANE_BACKENDS_BUILD_DIR) $(SANE_BACKENDS_IPK_DIR) $(SANE_BACKENDS_IPK)

#
#
# Some sanity check for the package.
#
sane-backends-check: $(SANE_BACKENDS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
