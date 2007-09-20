###########################################################
#
# tcsh
#
###########################################################
#
# TCSH_VERSION, TCSH_SITE and TCSH_SOURCE define
# the upstream location of the source code for the package.
# TCSH_DIR is the directory which is created when the source
# archive is unpacked.
# TCSH_UNZIP is the command used to unzip the source.
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
TCSH_SITE=ftp://ftp.astron.com/pub/tcsh
TCSH_VERSION=6.15.00
TCSH_SOURCE=tcsh-$(TCSH_VERSION).tar.gz
TCSH_DIR=tcsh-$(TCSH_VERSION)
TCSH_UNZIP=zcat
TCSH_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
TCSH_DESCRIPTION=C shell with file name completion and command line editing.
TCSH_SECTION=shell
TCSH_PRIORITY=optional
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
TCSH_DEPENDS=libiconv
else
TCSH_DEPENDS=
endif
TCSH_SUGGESTS=
TCSH_CONFLICTS=

#
# TCSH_IPK_VERSION should be incremented when the ipk changes.
#
TCSH_IPK_VERSION=1

#
# TCSH_CONFFILES should be a list of user-editable files
#TCSH_CONFFILES=/opt/etc/tcsh.conf /opt/etc/init.d/SXXtcsh

#
# TCSH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#TCSH_PATCHES=$(TCSH_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
TCSH_CPPFLAGS=
TCSH_LDFLAGS=

#
# TCSH_BUILD_DIR is the directory in which the build is done.
# TCSH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# TCSH_IPK_DIR is the directory in which the ipk is built.
# TCSH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
TCSH_BUILD_DIR=$(BUILD_DIR)/tcsh
TCSH_SOURCE_DIR=$(SOURCE_DIR)/tcsh
TCSH_IPK_DIR=$(BUILD_DIR)/tcsh-$(TCSH_VERSION)-ipk
TCSH_IPK=$(BUILD_DIR)/tcsh_$(TCSH_VERSION)-$(TCSH_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: tcsh-source tcsh-unpack tcsh tcsh-stage tcsh-ipk tcsh-clean tcsh-dirclean tcsh-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(TCSH_SOURCE):
	$(WGET) -P $(DL_DIR) $(TCSH_SITE)/$(TCSH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(TCSH_SITE)/old/$(TCSH_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(TCSH_SOURCE)
#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
tcsh-source: $(DL_DIR)/$(TCSH_SOURCE) $(TCSH_PATCHES)

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
$(TCSH_BUILD_DIR)/.configured: $(DL_DIR)/$(TCSH_SOURCE) $(TCSH_PATCHES) make/tcsh.mk
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(TCSH_DIR) $(TCSH_BUILD_DIR)
	$(TCSH_UNZIP) $(DL_DIR)/$(TCSH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(TCSH_PATCHES)" ; \
		then cat $(TCSH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(TCSH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(TCSH_DIR)" != "$(TCSH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(TCSH_DIR) $(TCSH_BUILD_DIR) ; \
	fi
	sed -i -e '/^	-strip/s/^/#/' $(TCSH_BUILD_DIR)/Makefile.in
	(cd $(TCSH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(TCSH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(TCSH_LDFLAGS)" \
		ac_cv_func_setpgrp_void=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	sed -i -e 's/^#define NLS_CATALOGS/#undef NLS_CATALOGS/' $(TCSH_BUILD_DIR)/config_p.h
endif
#	$(PATCH_LIBTOOL) $(TCSH_BUILD_DIR)/libtool
	touch $@

tcsh-unpack: $(TCSH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(TCSH_BUILD_DIR)/.built: $(TCSH_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(TCSH_BUILD_DIR) gethost \
		CC=$(HOSTCC) LDFLAGS="" EXTRALIBS=""
	$(MAKE) -C $(TCSH_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
tcsh: $(TCSH_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(TCSH_BUILD_DIR)/.staged: $(TCSH_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(TCSH_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

tcsh-stage: $(TCSH_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/tcsh
#
$(TCSH_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: tcsh" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(TCSH_PRIORITY)" >>$@
	@echo "Section: $(TCSH_SECTION)" >>$@
	@echo "Version: $(TCSH_VERSION)-$(TCSH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(TCSH_MAINTAINER)" >>$@
	@echo "Source: $(TCSH_SITE)/$(TCSH_SOURCE)" >>$@
	@echo "Description: $(TCSH_DESCRIPTION)" >>$@
	@echo "Depends: $(TCSH_DEPENDS)" >>$@
	@echo "Suggests: $(TCSH_SUGGESTS)" >>$@
	@echo "Conflicts: $(TCSH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(TCSH_IPK_DIR)/opt/sbin or $(TCSH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(TCSH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(TCSH_IPK_DIR)/opt/etc/tcsh/...
# Documentation files should be installed in $(TCSH_IPK_DIR)/opt/doc/tcsh/...
# Daemon startup scripts should be installed in $(TCSH_IPK_DIR)/opt/etc/init.d/S??tcsh
#
# You may need to patch your application to make it use these locations.
#
$(TCSH_IPK): $(TCSH_BUILD_DIR)/.built
	rm -rf $(TCSH_IPK_DIR) $(BUILD_DIR)/tcsh_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(TCSH_BUILD_DIR) DESTDIR=$(TCSH_IPK_DIR) install install.man
	$(STRIP_COMMAND) $(TCSH_IPK_DIR)/opt/bin/tcsh
#	install -d $(TCSH_IPK_DIR)/opt/etc/
#	install -m 644 $(TCSH_SOURCE_DIR)/tcsh.conf $(TCSH_IPK_DIR)/opt/etc/tcsh.conf
#	install -d $(TCSH_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(TCSH_SOURCE_DIR)/rc.tcsh $(TCSH_IPK_DIR)/opt/etc/init.d/SXXtcsh
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/opt/etc/init.d/SXXtcsh
	$(MAKE) $(TCSH_IPK_DIR)/CONTROL/control
#	install -m 755 $(TCSH_SOURCE_DIR)/postinst $(TCSH_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(TCSH_SOURCE_DIR)/prerm $(TCSH_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(XINETD_IPK_DIR)/CONTROL/prerm
	echo $(TCSH_CONFFILES) | sed -e 's/ /\n/g' > $(TCSH_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(TCSH_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
tcsh-ipk: $(TCSH_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
tcsh-clean:
	rm -f $(TCSH_BUILD_DIR)/.built
	-$(MAKE) -C $(TCSH_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
tcsh-dirclean:
	rm -rf $(BUILD_DIR)/$(TCSH_DIR) $(TCSH_BUILD_DIR) $(TCSH_IPK_DIR) $(TCSH_IPK)
#
#
# Some sanity check for the package.
#
tcsh-check: $(TCSH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(TCSH_IPK)
