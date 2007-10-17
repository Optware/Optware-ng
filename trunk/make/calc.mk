###########################################################
#
# calc
#
###########################################################
#
# CALC_VERSION, CALC_SITE and CALC_SOURCE define
# the upstream location of the source code for the package.
# CALC_DIR is the directory which is created when the source
# archive is unpacked.
# CALC_UNZIP is the command used to unzip the source.
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
CALC_SITE=http://www.isthe.com/chongo/src/calc
CALC_VERSION=2.12.2.2
CALC_SOURCE=calc-$(CALC_VERSION).tar.bz2
CALC_DIR=calc-$(CALC_VERSION)
CALC_UNZIP=bzcat
CALC_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
CALC_DESCRIPTION=Calc is arbitrary precision arithmetic system that uses a C-like language.
CALC_SECTION=misc
CALC_PRIORITY=optional
CALC_DEPENDS=
CALC_SUGGESTS=
CALC_CONFLICTS=

#
# CALC_IPK_VERSION should be incremented when the ipk changes.
#
CALC_IPK_VERSION=1

#
# CALC_CONFFILES should be a list of user-editable files
#CALC_CONFFILES=/opt/etc/calc.conf /opt/etc/init.d/SXXcalc

#
# CALC_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#CALC_PATCHES=$(CALC_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
CALC_CPPFLAGS=
CALC_LDFLAGS=

#
# CALC_BUILD_DIR is the directory in which the build is done.
# CALC_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# CALC_IPK_DIR is the directory in which the ipk is built.
# CALC_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
CALC_BUILD_DIR=$(BUILD_DIR)/calc
CALC_SOURCE_DIR=$(SOURCE_DIR)/calc
CALC_IPK_DIR=$(BUILD_DIR)/calc-$(CALC_VERSION)-ipk
CALC_IPK=$(BUILD_DIR)/calc_$(CALC_VERSION)-$(CALC_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: calc-source calc-unpack calc calc-stage calc-ipk calc-clean calc-dirclean calc-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(CALC_SOURCE):
	$(WGET) -P $(DL_DIR) $(CALC_SITE)/$(CALC_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(CALC_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
calc-source: $(DL_DIR)/$(CALC_SOURCE) $(CALC_PATCHES)

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
$(CALC_BUILD_DIR)/.configured: $(DL_DIR)/$(CALC_SOURCE) $(CALC_PATCHES) make/calc.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(CALC_DIR) $(CALC_BUILD_DIR)
	$(CALC_UNZIP) $(DL_DIR)/$(CALC_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(CALC_PATCHES)" ; \
		then cat $(CALC_PATCHES) | \
		patch -d $(BUILD_DIR)/$(CALC_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(CALC_DIR)" != "$(CALC_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(CALC_DIR) $(CALC_BUILD_DIR) ; \
	fi
	sed -i -e 's| -I/usr/include||; s|/usr/include|$(TARGET_INCDIR)|' $(CALC_BUILD_DIR)/Makefile $(CALC_BUILD_DIR)/*/Makefile
	sed -i -e 's|/usr/lib/|/opt/lib|' $(CALC_BUILD_DIR)/hist.h
	touch $(CALC_BUILD_DIR)/longbits.o
	touch $(CALC_BUILD_DIR)/longbits
	cp $(CALC_SOURCE_DIR)/longbits.h $(CALC_BUILD_DIR)/
#	(cd $(CALC_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CALC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CALC_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
#	$(PATCH_LIBTOOL) $(CALC_BUILD_DIR)/libtool
	touch $@

calc-unpack: $(CALC_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(CALC_BUILD_DIR)/.built: $(CALC_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(CALC_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(CALC_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(CALC_LDFLAGS)" \
		CALC_SHAREDIR=/opt/share/calc \
		BINDIR=/opt/bin \
		INCDIR=$(TARGET_INCDIR) \
		MANDIR=/opt/man \
		LIBDIR=/opt/lib \
		DEFAULT_LIB_INSTALL_PATH=/opt/lib \
		;
	touch $@

#
# This is the build convenience target.
#
calc: $(CALC_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(CALC_BUILD_DIR)/.staged: $(CALC_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(CALC_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

calc-stage: $(CALC_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/calc
#
$(CALC_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: calc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(CALC_PRIORITY)" >>$@
	@echo "Section: $(CALC_SECTION)" >>$@
	@echo "Version: $(CALC_VERSION)-$(CALC_IPK_VERSION)" >>$@
	@echo "Maintainer: $(CALC_MAINTAINER)" >>$@
	@echo "Source: $(CALC_SITE)/$(CALC_SOURCE)" >>$@
	@echo "Description: $(CALC_DESCRIPTION)" >>$@
	@echo "Depends: $(CALC_DEPENDS)" >>$@
	@echo "Suggests: $(CALC_SUGGESTS)" >>$@
	@echo "Conflicts: $(CALC_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(CALC_IPK_DIR)/opt/sbin or $(CALC_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(CALC_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(CALC_IPK_DIR)/opt/etc/calc/...
# Documentation files should be installed in $(CALC_IPK_DIR)/opt/doc/calc/...
# Daemon startup scripts should be installed in $(CALC_IPK_DIR)/opt/etc/init.d/S??calc
#
# You may need to patch your application to make it use these locations.
#
$(CALC_IPK): $(CALC_BUILD_DIR)/.built
	rm -rf $(CALC_IPK_DIR) $(BUILD_DIR)/calc_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(CALC_BUILD_DIR) T=$(CALC_IPK_DIR) install \
		CALC_SHAREDIR=/opt/share/calc \
		BINDIR=/opt/bin \
		INCDIR=/opt/include \
		MANDIR=/opt/man \
		LIBDIR=/opt/lib \
		;
	chmod +w $(CALC_IPK_DIR)/opt/bin/calc && \
		$(STRIP_COMMAND) $(CALC_IPK_DIR)/opt/bin/calc && \
	chmod -w $(CALC_IPK_DIR)/opt/bin/calc
	$(STRIP_COMMAND) $(CALC_IPK_DIR)/opt/lib/lib*calc*so.$(CALC_VERSION)
#	install -d $(CALC_IPK_DIR)/opt/etc/
#	install -m 644 $(CALC_SOURCE_DIR)/calc.conf $(CALC_IPK_DIR)/opt/etc/calc.conf
#	install -d $(CALC_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(CALC_SOURCE_DIR)/rc.calc $(CALC_IPK_DIR)/opt/etc/init.d/SXXcalc
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CALC_IPK_DIR)/opt/etc/init.d/SXXcalc
	$(MAKE) $(CALC_IPK_DIR)/CONTROL/control
#	install -m 755 $(CALC_SOURCE_DIR)/postinst $(CALC_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CALC_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(CALC_SOURCE_DIR)/prerm $(CALC_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(CALC_IPK_DIR)/CONTROL/prerm
	echo $(CALC_CONFFILES) | sed -e 's/ /\n/g' > $(CALC_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(CALC_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
calc-ipk: $(CALC_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
calc-clean:
	rm -f $(CALC_BUILD_DIR)/.built
	-$(MAKE) -C $(CALC_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
calc-dirclean:
	rm -rf $(BUILD_DIR)/$(CALC_DIR) $(CALC_BUILD_DIR) $(CALC_IPK_DIR) $(CALC_IPK)
#
#
# Some sanity check for the package.
#
calc-check: $(CALC_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(CALC_IPK)
