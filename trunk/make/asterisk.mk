###########################################################
#
# asterisk
#
###########################################################

#
# ASTERISK_REPOSITORY defines the upstream location of the source code
# for the package.  ASTERISK_DIR is the directory which is created when
# this cvs module is checked out.
#

ASTERISK_REPOSITORY=:pserver:anoncvs@cvs.digium.com:/usr/cvsroot
ASTERISK_DIR=asterisk
ASTERISK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
ASTERISK_DESCRIPTION=Open Source VoIP PBX System
ASTERISK_SECTION=util
ASTERISK_PRIORITY=optional
ASTERISK_DEPENDS=openssl ncurses
ASTERISK_SUGGESTS=
ASTERISK_CONFLICTS=

#
# Software downloaded from CVS repositories must either use a tag or a
# date to ensure that the same sources can be downloaded later.
#

#
# If you want to use a date, uncomment the variables below and modify
# ASTERISK_CVS_DATE
#

ASTERISK_CVS_DATE=20050508
ASTERISK_VERSION=cvs$(ASTERISK_CVS_DATE)
ASTERISK_CVS_OPTS=-D $(ASTERISK_CVS_DATE)

#
# If you want to use a tag, uncomment the variables below and modify
# ASTERISK_CVS_TAG and ASTERISK_CVS_VERSION
#

#ASTERISK_CVS_TAG=version_1_2_3
#ASTERISK_VERSION=1.2.3
#ASTERISK_CVS_OPTS=-r $(ASTERISK_CVS_TAG)

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
		 $(ASTERISK_SOURCE_DIR)/codecs.gsm.Makefile.patch
                                  

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

#
# In this case there is no tarball, instead we fetch the sources
# directly to the builddir with CVS
#
$(DL_DIR)/asterisk-$(ASTERISK_VERSION).tar.gz:
	( cd $(BUILD_DIR) ; \
		rm -rf $(ASTERISK_DIR) && \
		cvs -d $(ASTERISK_REPOSITORY) -z3 co $(ASTERISK_CVS_OPTS) $(ASTERISK_DIR) && \
		tar -czf $@ $(ASTERISK_DIR) && \
		rm -rf $(ASTERISK_DIR) \
	)

asterisk-source: $(DL_DIR)/asterisk-$(ASTERISK_VERSION).tar.gz

#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <foo>-stage <baz>-stage").
#
$(ASTERISK_BUILD_DIR)/.configured: $(DL_DIR)/asterisk-$(ASTERISK_VERSION).tar.gz
	$(MAKE) ncurses-stage openssl-stage
	rm -rf $(ASTERISK_BUILD_DIR)
	tar -C $(BUILD_DIR) -xzf $(DL_DIR)/asterisk-$(ASTERISK_VERSION).tar.gz
	touch $(ASTERISK_BUILD_DIR)/.configured

asterisk-unpack: $(ASTERISK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(ASTERISK_BUILD_DIR)/.built: $(ASTERISK_BUILD_DIR)/.configured
	rm -f $(ASTERISK_BUILD_DIR)/.built
	CPPFLAGS="$(STAGING_CPPFLAGS) $(ASTERISK_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(ASTERISK_LDFLAGS)" \
	$(MAKE) -C $(ASTERISK_BUILD_DIR) INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
	PROC=arm SUB_PROC=xscale \
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
	PROC=arm SUB_PROC=xscale \
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
	@echo "Source: $(ASTERISK_REPOSITORY)" >>$@
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
	($(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
		ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
		ASTBINDIR=$(ASTERISK_BIN_DIR) \
		ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
		ASTMANDIR=$(ASTERISK_MAN_DIR) \
		ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		PROC=arm SUB_PROC=xscale \
		install )
	install -d $(ASTERISK_IPK_DIR)/opt/etc/
	($(MAKE) -C $(ASTERISK_BUILD_DIR) DESTDIR=$(ASTERISK_IPK_DIR) \
		INSTALL_PREFIX=$(ASTERISK_INST_DIR) \
		ASTHEADERDIR=$(ASTERISK_INCLUDE_DIR) \
		ASTBINDIR=$(ASTERISK_BIN_DIR) \
		ASTSBINDIR=$(ASTERISK_SBIN_DIR) \
		ASTMANDIR=$(ASTERISK_MAN_DIR) \
		ASTLIBDIR=$(ASTERISK_LIB_DIR) \
		ASTETCDIR=$(ASTERISK_SYSCONF_SAMPLE_DIR) \
		PROC=arm SUB_PROC=xscale \
		samples )
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
	-$(MAKE) -C $(ASTERISK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
asterisk-dirclean:
	rm -rf $(BUILD_DIR)/$(ASTERISK_DIR) $(ASTERISK_BUILD_DIR) $(ASTERISK_IPK_DIR) $(ASTERISK_IPK)
