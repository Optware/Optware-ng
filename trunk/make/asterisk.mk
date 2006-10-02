###########################################################
#
# asterisk
#
###########################################################

# You must replace "asterisk" and "ASTERISK" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# ASTERISK_VERSION, ASTERISK_SITE and ASTERISK_SOURCE define
# the upstream location of the source code for the package.
# ASTERISK_DIR is the directory which is created when the source
# archive is unpacked.
# ASTERISK_UNZIP is the command used to unzip the source.
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
ASTERISK_SITE=http://ftp.digium.com/pub/asterisk/releases/
ASTERISK_VERSION=1.2.12.1
ASTERISK_SOURCE=asterisk-$(ASTERISK_VERSION).tar.gz
ASTERISK_DIR=asterisk-$(ASTERISK_VERSION)
ASTERISK_UNZIP=zcat
ASTERISK_MAINTAINER=Corneliu Doban <corneliu_doban@yahoo.com>
ASTERISK_DESCRIPTION=Open Source VoIP PBX System
ASTERISK_SECTION=util
ASTERISK_PRIORITY=optional
ASTERISK_DEPENDS=openssl,ncurses,libcurl
ASTERISK_SUGGESTS=
ASTERISK_CONFLICTS=

#
# ASTERISK_IPK_VERSION should be incremented when the ipk changes.
#
ASTERISK_IPK_VERSION=1

#
# ASTERISK_CONFFILES should be a list of user-editable files
ASTERISK_CONFFILES=

#
# ASTERISK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ASTERISK_PATCHES=$(ASTERISK_SOURCE_DIR)/Makefile.patch \
		$(ASTERISK_SOURCE_DIR)/editline.makelist.patch \
		$(ASTERISK_SOURCE_DIR)/codecs.gsm.Makefile.patch \
		$(ASTERISK_SOURCE_DIR)/asterisk.c.patch \
		$(ASTERISK_SOURCE_DIR)/asterisk-1.2.10-dns.patch \
		$(ASTERISK_SOURCE_DIR)/chan_modem.patch

#		http://bugs.digium.com/view.php?id=5549



#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ASTERISK_CPPFLAGS=-fsigned-char
ASTERISK_LDFLAGS=

#
# ASTERISK_BUILD_DIR is the directory in which the build is done.
# ASTERISK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# ASTERISK_IPK_DIR is the directory in which the ipk is built.
# ASTERISK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
ASTERISK_BUILD_DIR=$(BUILD_DIR)/asterisk
ASTERISK_SOURCE_DIR=$(SOURCE_DIR)/asterisk
ASTERISK_IPK_DIR=$(BUILD_DIR)/asterisk-$(ASTERISK_VERSION)-ipk
ASTERISK_IPK=$(BUILD_DIR)/asterisk_$(ASTERISK_VERSION)-$(ASTERISK_IPK_VERSION)_$(TARGET_ARCH).ipk


ASTERISK_INST_DIR=/opt
ASTERISK_BIN_DIR=$(ASTERISK_INST_DIR)/bin
ASTERISK_SBIN_DIR=$(ASTERISK_INST_DIR)/sbin
ASTERISK_LIBEXEC_DIR=$(ASTERISK_INST_DIR)/libexec
ASTERISK_DATA_DIR=$(ASTERISK_INST_DIR)/share/asterisk
ASTERISK_SYSCONF_DIR=$(ASTERISK_INST_DIR)/etc/asterisk
ASTERISK_SHAREDSTATE_DIR=$(ASTERISK_INST_DIR)/com/asterisk
ASTERISK_LOCALSTATE_DIR=$(ASTERISK_INST_DIR)/var/asterisk
ASTERISK_LIB_DIR=$(ASTERISK_INST_DIR)/lib/asterisk
ASTERISK_INCLUDE_DIR=$(ASTERISK_INST_DIR)/include/asterisk
ASTERISK_INFO_DIR=$(ASTERISK_INST_DIR)/info
ASTERISK_MAN_DIR=$(ASTERISK_INST_DIR)/man
ASTERISK_SYSCONF_SAMPLE_DIR=$(ASTERISK_INST_DIR)/etc/asterisk/sample


ifeq ($(OPTWARE_TARGET),ts72xx)
TARGET_PROC=arm
TARGET_SUB_PROC=maverick
else
    ifeq ($(OPTWARE_TARGET),ds101g)
    TARGET_PROC=ppc
    TARGET_SUB_PROC=
    else
	ifeq ($(LIBC_STYLE),uclibc)
	TARGET_PROC=mips1
	TARGET_SUB_PROC=
	else
	TARGET_PROC=arm
	TARGET_SUB_PROC=xscale
	endif
    endif
endif

ifeq ($(LIBC_STYLE),uclibc)
ASTERISK_CROSS_COMPILE_TARGET=$(TOOL_BUILD_DIR)/$(TARGET_ARCH)-$(TARGET_OS)/$(CROSS_CONFIGURATION)
else
ASTERISK_CROSS_COMPILE_TARGET=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)
endif

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(ASTERISK_SOURCE):
	$(WGET) -P $(DL_DIR) $(ASTERISK_SITE)/$(ASTERISK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
asterisk-source: $(DL_DIR)/$(ASTERISK_SOURCE) $(ASTERISK_PATCHES)

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
$(ASTERISK_BUILD_DIR)/.configured: $(DL_DIR)/$(ASTERISK_SOURCE) $(ASTERISK_PATCHES)
	$(MAKE) ncurses-stage openssl-stage libcurl-stage
	rm -rf $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR)
	$(ASTERISK_UNZIP) $(DL_DIR)/$(ASTERISK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(ASTERISK_PATCHES)" ; \
		then cat $(ASTERISK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(ASTERISK_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(ASTERISK_DIR)" != "$(ASTERISK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR) ; \
	fi
	touch $(ASTERISK_BUILD_DIR)/.configured

asterisk-unpack: $(ASTERISK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK_BUILD_DIR)/.built: $(ASTERISK_BUILD_DIR)/.configured
	rm -f $(ASTERISK_BUILD_DIR)/.built
	CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK_BUILD_DIR) \
	INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	CROSS_COMPILE_TARGET=$(ASTERISK_CROSS_COMPILE_TARGET) \
	CROSS_COMPILE_BIN=$(STAGING_DIR)/bin/ \
	CROSS_ARCH=Linux \
	CROSS_PROC=$(TARGET_PROC) \
	SUB_PROC=$(TARGET_SUB_PROC) \
	$(TARGET_CONFIGURE_OPTS)
	touch $(ASTERISK_BUILD_DIR)/.built

#
# This is the build convenience target.
#
asterisk: $(ASTERISK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(ASTERISK_BUILD_DIR)/.staged: $(ASTERISK_BUILD_DIR)/.built
	rm -f $(ASTERISK_BUILD_DIR)/.staged
	$(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(STAGING_DIR) \
	INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
	CROSS_COMPILE=$(TARGET_CROSS) \
	CROSS_COMPILE_TARGET=$(ASTERISK_CROSS_COMPILE_TARGET) \
	CROSS_COMPILE_BIN=$(STAGING_DIR)/bin \
	CROSS_ARCH=Linux \
	CROSS_PROC=$(TARGET_PROC) \
	SUB_PROC=$(TARGET_SUB_PROC) \
	install
	touch $(ASTERISK_BUILD_DIR)/.staged

asterisk-stage: $(ASTERISK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/asterisk
#
$(ASTERISK_IPK_DIR)/CONTROL/control:
	@install -d $(ASTERISK_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: asterisk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(ASTERISK_PRIORITY)" >>$@
	@echo "Section: $(ASTERISK_SECTION)" >>$@
	@echo "Version: $(ASTERISK_VERSION)-$(ASTERISK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(ASTERISK_MAINTAINER)" >>$@
	@echo "Source: $(ASTERISK_SITE)/$(ASTERISK_SOURCE)" >>$@
	@echo "Description: $(ASTERISK_DESCRIPTION)" >>$@
	@echo "Depends: $(ASTERISK_DEPENDS)" >>$@
	@echo "Suggests: $(ASTERISK_SUGGESTS)" >>$@
	@echo "Conflicts: $(ASTERISK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(ASTERISK_IPK_DIR)/opt/sbin or $(ASTERISK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(ASTERISK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(ASTERISK_IPK_DIR)/opt/etc/asterisk/...
# Documentation files should be installed in $(ASTERISK_IPK_DIR)/opt/doc/asterisk/...
# Daemon startup scripts should be installed in $(ASTERISK_IPK_DIR)/opt/etc/init.d/S??asterisk
#
# You may need to patch your application to make it use these locations.
#
$(ASTERISK_IPK): $(ASTERISK_BUILD_DIR)/.built
	rm -rf $(ASTERISK_IPK_DIR) $(BUILD_DIR)/asterisk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
		ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
		ASTBINDIR=$(ASTERISK_BIN_DIR) \
		ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
		ASTMANDIR=$(ASTERISK_MAN_DIR) \
		ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		CROSS_COMPILE_TARGET=$(ASTERISK_CROSS_COMPILE_TARGET) \
		CROSS_COMPILE_BIN=$(STAGING_DIR)/bin/ \
		CROSS_ARCH=Linux \
		CROSS_PROC=$(TARGET_PROC) \
		SUB_PROC=$(TARGET_SUB_PROC) \
		install
	install -d $(ASTERISK_IPK_DIR)/opt/etc/
	$(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
		ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
		ASTBINDIR=$(ASTERISK_BIN_DIR) \
		ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
		ASTMANDIR=$(ASTERISK_MAN_DIR) \
		ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		ASTETCDIR=$(ASTERISK_SYSCONF_SAMPLE_DIR) \
		CROSS_COMPILE=$(TARGET_CROSS) \
		CROSS_COMPILE_TARGET=$(TOOL_BUILD_DIR)/$(GNU_TARGET_NAME)/$(CROSS_CONFIGURATION)/$(GNU_TARGET_NAME)  \
		CROSS_COMPILE_BIN=$(STAGING_DIR)/bin \
		CROSS_ARCH=Linux \
		CROSS_PROC=$(TARGET_PROC) \
		SUB_PROC=$(TARGET_SUB_PROC) \
		samples
	$(MAKE) $(ASTERISK_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(ASTERISK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
asterisk-ipk: $(ASTERISK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
asterisk-clean:
	rm -f $(ASTERISK_BUILD_DIR)/.built
	-$(MAKE) -C $(ASTERISK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR) $(ASTERISK_IPK_DIR) $(ASTERISK_IPK)
