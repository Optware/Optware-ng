###########################################################
#
# ser
#
###########################################################

# You must replace "ser" and "SER" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SER_VERSION, SER_SITE and SER_SOURCE define
# the upstream location of the source code for the package.
# SER_DIR is the directory which is created when the source
# archive is unpacked.
# SER_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
SER_SITE=ftp://ftp.berlios.de/pub/ser/0.8.14/src
SER_VERSION=0.8.14
SER_SOURCE=ser-$(SER_VERSION)_src.tar.gz
SER_DIR=ser-$(SER_VERSION)
SER_UNZIP=zcat
SER_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SER_DESCRIPTION=SIP Express Router
SER_SECTION=util
SER_PRIORITY=optional
SER_DEPENDS=flex
SER_SUGGESTS=
SER_CONFLICTS=

#
# SER_IPK_VERSION should be incremented when the ipk changes.
#
SER_IPK_VERSION=4

#
# SER_CONFFILES should be a list of user-editable files
#SER_CONFFILES=/opt/etc/ser.conf /opt/etc/init.d/SXXser

#
# SER_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
SER_PATCHES=$(SER_SOURCE_DIR)/Makefile.defs.patch \
	    $(SER_SOURCE_DIR)/utils.gen_ha1.Makefile.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SER_CPPFLAGS=-fsigned-char
SER_LDFLAGS=

SER_MAKEFLAGS=$(strip \
        $(if $(filter powerpc, $(TARGET_ARCH)), ARCH=ppc, \
        $(if $(filter mipsel mips, $(TARGET_ARCH)), ARCH=mips, \
        $(if $(filter i386 i686, $(TARGET_ARCH)), ARCH=i386, \
        ARCH=arm)))) OS=linux

#
# SER_BUILD_DIR is the directory in which the build is done.
# SER_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SER_IPK_DIR is the directory in which the ipk is built.
# SER_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SER_BUILD_DIR=$(BUILD_DIR)/ser
SER_SOURCE_DIR=$(SOURCE_DIR)/ser
SER_IPK_DIR=$(BUILD_DIR)/ser-$(SER_VERSION)-ipk
SER_IPK=$(BUILD_DIR)/ser_$(SER_VERSION)-$(SER_IPK_VERSION)_${TARGET_ARCH}.ipk

.PHONY: ser-source ser-unpack ser ser-stage ser-ipk ser-clean ser-dirclean ser-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SER_SOURCE):
	$(WGET) -P $(DL_DIR) $(SER_SITE)/$(SER_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
ser-source: $(DL_DIR)/$(SER_SOURCE) $(SER_PATCHES)

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
$(SER_BUILD_DIR)/.configured: $(DL_DIR)/$(SER_SOURCE) $(SER_PATCHES)
	$(MAKE) flex-stage
	rm -rf $(BUILD_DIR)/$(SER_DIR) $(SER_BUILD_DIR)
	$(SER_UNZIP) $(DL_DIR)/$(SER_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(SER_PATCHES) | patch -d $(BUILD_DIR)/$(SER_DIR) -p1
	mv $(BUILD_DIR)/$(SER_DIR) $(SER_BUILD_DIR)
#	(cd $(SER_BUILD_DIR); \
#		$(TARGET_CONFIGURE_OPTS) \
#		CPPFLAGS="$(STAGING_CPPFLAGS) $(SER_CPPFLAGS)" \
#		LDFLAGS="$(STAGING_LDFLAGS) $(SER_LDFLAGS)" \
#		./configure \
#		--build=$(GNU_HOST_NAME) \
#		--host=$(GNU_TARGET_NAME) \
#		--target=$(GNU_TARGET_NAME) \
#		--prefix=/opt \
#		--disable-nls \
	)
	touch $(SER_BUILD_DIR)/.configured

ser-unpack: $(SER_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SER_BUILD_DIR)/.built: $(SER_BUILD_DIR)/.configured
	rm -f $(SER_BUILD_DIR)/.built
	CC_EXTRA_OPTS="$(STAGING_CPPFLAGS) $(SER_CPPFLAGS)" \
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS) $(SER_LDFLAGS)" \
	CC="$(TARGET_CC)" \
	$(MAKE) -C $(SER_BUILD_DIR) DESTDIR=/opt \
		$(SER_MAKEFLAGS) all
	touch $(SER_BUILD_DIR)/.built

#
# This is the build convenience target.
#
ser: $(SER_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SER_BUILD_DIR)/.staged: $(SER_BUILD_DIR)/.built
	rm -f $(SER_BUILD_DIR)/.staged
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS) $(SER_LDFLAGS)" \
	CC="$(TARGET_CC)" \
	$(MAKE) -C $(SER_BUILD_DIR) DESTDIR=/opt \
	BASEDIR=$(STAGING_DIR) \
	LOCALBASE=$(STAGING_DIR) \
		$(SER_MAKEFLAGS) install
	touch $(SER_BUILD_DIR)/.staged

ser-stage: $(SER_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/ser
#
$(SER_IPK_DIR)/CONTROL/control:
	@install -d $(SER_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: ser" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SER_PRIORITY)" >>$@
	@echo "Section: $(SER_SECTION)" >>$@
	@echo "Version: $(SER_VERSION)-$(SER_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SER_MAINTAINER)" >>$@
	@echo "Source: $(SER_SITE)/$(SER_SOURCE)" >>$@
	@echo "Description: $(SER_DESCRIPTION)" >>$@
	@echo "Depends: $(SER_DEPENDS)" >>$@
	@echo "Suggests: $(SER_SUGGESTS)" >>$@
	@echo "Conflicts: $(SER_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SER_IPK_DIR)/opt/sbin or $(SER_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SER_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SER_IPK_DIR)/opt/etc/ser/...
# Documentation files should be installed in $(SER_IPK_DIR)/opt/doc/ser/...
# Daemon startup scripts should be installed in $(SER_IPK_DIR)/opt/etc/init.d/S??ser
#
# You may need to patch your application to make it use these locations.
#
$(SER_IPK): $(SER_BUILD_DIR)/.built
	rm -rf $(SER_IPK_DIR) $(BUILD_DIR)/ser_*_${TARGET_ARCH}.ipk
	LD_EXTRA_OPTS="$(STAGING_LDFLAGS) $(SER_LDFLAGS)" \
	CC="$(TARGET_CC)" \
	$(MAKE) -C $(SER_BUILD_DIR) DESTDIR=/opt \
		BASEDIR=$(SER_IPK_DIR) LOCALBASE=$(SER_IPK_DIR) \
		$(SER_MAKEFLAGS) install
	$(STRIP_COMMAND) $(SER_IPK_DIR)/opt/sbin/ser $(SER_IPK_DIR)/opt/sbin/gen_ha1
	$(STRIP_COMMAND) $(SER_IPK_DIR)/opt/lib/ser/modules/*.so
#	install -d $(SER_IPK_DIR)/opt/etc/
#	install -m 644 $(SER_SOURCE_DIR)/ser.conf $(SER_IPK_DIR)/opt/etc/ser.conf
#	install -d $(SER_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(SER_SOURCE_DIR)/rc.ser $(SER_IPK_DIR)/opt/etc/init.d/SXXser
	$(MAKE) $(SER_IPK_DIR)/CONTROL/control
#	install -m 755 $(SER_SOURCE_DIR)/postinst $(SER_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(SER_SOURCE_DIR)/prerm $(SER_IPK_DIR)/CONTROL/prerm
#	echo $(SER_CONFFILES) | sed -e 's/ /\n/g' > $(SER_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SER_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
ser-ipk: $(SER_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
ser-clean:
	-$(MAKE) -C $(SER_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
ser-dirclean:
	rm -rf $(BUILD_DIR)/$(SER_DIR) $(SER_BUILD_DIR) $(SER_IPK_DIR) $(SER_IPK)

#
# Some sanity check for the package.
#
ser-check: $(SER_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SER_IPK)
