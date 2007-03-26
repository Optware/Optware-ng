###########################################################
#
# bash
#
###########################################################
#
# BASH_VERSION, BASH_SITE and BASH_SOURCE define
# the upstream location of the source code for the package.
# BASH_DIR is the directory which is created when the source
# archive is unpacked.
# BASH_UNZIP is the command used to unzip the source.
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
BASH_SITE=http://ftp.gnu.org/gnu/bash/
BASH_VERSION=3.2
BASH_SOURCE=bash-$(BASH_VERSION).tar.gz
BASH_DIR=bash-$(BASH_VERSION)
BASH_UNZIP=zcat
BASH_MAINTAINER=Christopher Blunck <christopher.blunck@gmail.com>
BASH_DESCRIPTION=A bourne style shell
BASH_SECTION=shell
BASH_PRIORITY=optional
BASH_DEPENDS=readline
ifeq ($(GETTEXT_NLS), enable)
BASH_DEPENDS+=, gettext
endif
BASH_CONFLICTS=
BASH_SUGGESTS=
BASH_CONFLICTS=

#
# BASH_IPK_VERSION should be incremented when the ipk changes.
#
BASH_IPK_VERSION=2
#
# BASH_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#BASH_PATCHES=$(BASH_SOURCE_DIR)/bash-3.1-patches/bash31-*

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
BASH_CPPFLAGS=
BASH_LDFLAGS=

#
# BASH_BUILD_DIR is the directory in which the build is done.
# BASH_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# BASH_IPK_DIR is the directory in which the ipk is built.
# BASH_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
BASH_BUILD_DIR=$(BUILD_DIR)/bash
BASH_SOURCE_DIR=$(SOURCE_DIR)/bash
BASH_IPK_DIR=$(BUILD_DIR)/bash-$(BASH_VERSION)-ipk
BASH_IPK=$(BUILD_DIR)/bash_$(BASH_VERSION)-$(BASH_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(BASH_SOURCE):
	$(WGET) -P $(DL_DIR) $(BASH_SITE)/$(BASH_SOURCE)

.PHONY: bash-source bash-unpack bash bash-stage bash-ipk bash-clean bash-dirclean bash-check

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
bash-source: $(DL_DIR)/$(BASH_SOURCE)
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
$(BASH_BUILD_DIR)/.configured: $(DL_DIR)/$(BASH_SOURCE)
ifeq ($(GETTEXT_NLS), enable)
	$(MAKE) gettext-stage
endif
	$(MAKE) termcap-stage
	rm -rf $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR)
	$(BASH_UNZIP) $(DL_DIR)/$(BASH_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(BASH_PATCHES)" ; \
		then cat $(BASH_PATCHES) | \
		patch -d $(BUILD_DIR)/$(BASH_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(BASH_DIR)" != "$(BASH_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR) ; \
	fi
	(cd $(BASH_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(BASH_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(BASH_LDFLAGS)" \
		CC_FOR_BUILD=$(HOSTCC) \
		ac_cv_func_setvbuf_reversed=no \
		bash_cv_have_mbstate_t=yes \
		bash_cv_ulimit_maxfds=yes \
		bash_cv_func_sigsetjmp=present \
		bash_cv_printf_a_format=yes \
		bash_cv_job_control_missing=present \
		bash_cv_sys_named_pipes=present \
		bash_cv_unusable_rtsigs=no \
		bash_cv_sys_siglist=yes \
		bash_cv_under_sys_siglist=yes \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
	);
	touch $(BASH_BUILD_DIR)/.configured

bash-unpack: $(BASH_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(BASH_BUILD_DIR)/bash: $(BASH_BUILD_DIR)/.configured
	$(MAKE) -C $(BASH_BUILD_DIR)

bash: $(BASH_BUILD_DIR)/bash

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/bash
#
$(BASH_IPK_DIR)/CONTROL/control:
	@install -d $(BASH_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: bash" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(BASH_PRIORITY)" >>$@
	@echo "Section: $(BASH_SECTION)" >>$@
	@echo "Version: $(BASH_VERSION)-$(BASH_IPK_VERSION)" >>$@
	@echo "Maintainer: $(BASH_MAINTAINER)" >>$@
	@echo "Source: $(BASH_SITE)/$(BASH_SOURCE)" >>$@
	@echo "Description: $(BASH_DESCRIPTION)" >>$@
	@echo "Depends: $(BASH_DEPENDS)" >>$@
	@echo "Conflicts: $(BASH_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(BASH_IPK_DIR)/opt/sbin or $(BASH_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(BASH_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(BASH_IPK_DIR)/opt/etc/bash/...
# Documentation files should be installed in $(BASH_IPK_DIR)/opt/doc/bash/...
# Daemon startup scripts should be installed in $(BASH_IPK_DIR)/opt/etc/init.d/S??bash
#
# You may need to patch your application to make it use these locations.
#
$(BASH_IPK): $(BASH_BUILD_DIR)/bash
	rm -rf $(BASH_IPK_DIR) $(BUILD_DIR)/bash_*_$(TARGET_ARCH).ipk
	install -d $(BASH_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(BASH_BUILD_DIR)/bash -o $(BASH_IPK_DIR)/opt/bin/bash
	install -d $(BASH_IPK_DIR)/opt/etc 
	install -m 644 $(BASH_SOURCE_DIR)/profile $(BASH_IPK_DIR)/opt/etc/profile
ifeq ($(OPTWARE_WRITE_OUTSIDE_OPT_ALLOWED),true)
	install -d $(BASH_IPK_DIR)/opt/etc/init.d
	install -m 755 $(BASH_SOURCE_DIR)/rc.bash $(BASH_IPK_DIR)/opt/etc/init.d/S05bash
	install -d $(BASH_IPK_DIR)/bin
	ln -s /opt/bin/bash $(BASH_IPK_DIR)/bin/bash
endif
	$(MAKE) $(BASH_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(BASH_IPK_DIR)

bash-ipk: $(BASH_IPK)

bash-clean:
	-$(MAKE) -C $(BASH_BUILD_DIR) clean

bash-dirclean:
	rm -rf $(BUILD_DIR)/$(BASH_DIR) $(BASH_BUILD_DIR) $(BASH_IPK_DIR) $(BASH_IPK)

#
# Some sanity check for the package.
#
bash-check: $(BASH_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(BASH_IPK)
