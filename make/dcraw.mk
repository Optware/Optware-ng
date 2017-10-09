###########################################################
#
# dcraw
#
###########################################################

#
# DCRAW_VERSION, DCRAW_SITE and DCRAW_SOURCE define
# the upstream location of the source code for the package.
# DCRAW_DIR is the directory which is created when the source
# archive is unpacked.
# DCRAW_UNZIP is the command used to unzip the source.
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
DCRAW_SITE=http://www.cybercom.net/~dcoffin/dcraw
DCRAW_HEAD_VERSION=`wget -qO- $(DCRAW_SITE)/RCS/dcraw.c,v|head -1|cut -f2|tr -d ';'`
DCRAW_VERSION=1.476
DCRAW_SOURCE=dcraw.c,v
DCRAW_DIR=dcraw-$(DCRAW_VERSION)
DCRAW_UNZIP=zcat
DCRAW_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
DCRAW_DESCRIPTION=Decoding raw digital photos.
DCRAW_SECTION=graphics
DCRAW_PRIORITY=optional
DCRAW_DEPENDS=libjpeg, liblcms2
DCRAW_SUGGESTS=
DCRAW_CONFLICTS=

#
# DCRAW_IPK_VERSION should be incremented when the ipk changes.
#
DCRAW_IPK_VERSION=3

#
# DCRAW_CONFFILES should be a list of user-editable files
#DCRAW_CONFFILES=$(TARGET_PREFIX)/etc/dcraw.conf $(TARGET_PREFIX)/etc/init.d/SXXdcraw

#
# DCRAW_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#DCRAW_PATCHES=$(DCRAW_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
DCRAW_CPPFLAGS=-lm -ljpeg -llcms2 -DNO_JASPER
DCRAW_LDFLAGS=

#
# DCRAW_BUILD_DIR is the directory in which the build is done.
# DCRAW_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# DCRAW_IPK_DIR is the directory in which the ipk is built.
# DCRAW_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
DCRAW_BUILD_DIR=$(BUILD_DIR)/dcraw
DCRAW_SOURCE_DIR=$(SOURCE_DIR)/dcraw
DCRAW_IPK_DIR=$(BUILD_DIR)/dcraw-$(DCRAW_VERSION)-ipk
DCRAW_IPK=$(BUILD_DIR)/dcraw_$(DCRAW_VERSION)-$(DCRAW_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: dcraw-source dcraw-unpack dcraw dcraw-stage dcraw-ipk dcraw-clean dcraw-dirclean dcraw-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(DCRAW_SOURCE): make/dcraw.mk
	rm -f $(DL_DIR)/dcraw*
	export CREATE_CHECKSUM=1; \
	head_ver=$(DCRAW_HEAD_VERSION) && \
		$(WGET) -O $(@D)/dcraw.c,v-$${head_ver} $(DCRAW_SITE)/RCS/$(@F) && \
		$(WGET) -O $(@D)/dcraw.1-$${head_ver} $(DCRAW_SITE)/dcraw.1 && \
		mv -f $(@D)/dcraw.c,v-$${head_ver} $@ && \
		mv -f $(@D)/dcraw.1-$${head_ver} $(@D)/dcraw.1
	touch $@

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
dcraw-source: $(DL_DIR)/$(DCRAW_SOURCE) $(DCRAW_PATCHES)

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
$(DCRAW_BUILD_DIR)/.configured: $(DL_DIR)/$(DCRAW_SOURCE) $(DCRAW_PATCHES) make/dcraw.mk
	$(MAKE) libjpeg-stage liblcms2-stage
	rm -rf $(BUILD_DIR)/$(DCRAW_DIR) $(DCRAW_BUILD_DIR)
#	$(DCRAW_UNZIP) $(DL_DIR)/$(DCRAW_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mkdir -p $(BUILD_DIR)/$(DCRAW_DIR)
	cd $(BUILD_DIR)/$(DCRAW_DIR) && co -r$(DCRAW_VERSION) $(DL_DIR)/$(DCRAW_SOURCE)
	if test -n "$(DCRAW_PATCHES)" ; \
		then cat $(DCRAW_PATCHES) | \
		$(PATCH) -d $(BUILD_DIR)/$(DCRAW_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(DCRAW_DIR)" != "$(DCRAW_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(DCRAW_DIR) $(DCRAW_BUILD_DIR) ; \
	fi
	touch $(DCRAW_BUILD_DIR)/.configured

dcraw-unpack: $(DCRAW_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(DCRAW_BUILD_DIR)/.built: $(DCRAW_BUILD_DIR)/.configured
	rm -f $(DCRAW_BUILD_DIR)/.built
	(cd $(DCRAW_BUILD_DIR); \
	$(TARGET_CC) -O4 -o dcraw dcraw.c \
		$(STAGING_CPPFLAGS) $(DCRAW_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(DCRAW_LDFLAGS); \
		)
	touch $(DCRAW_BUILD_DIR)/.built

#
# This is the build convenience target.
#
dcraw: $(DCRAW_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(DCRAW_BUILD_DIR)/.staged: $(DCRAW_BUILD_DIR)/.built
	rm -f $(DCRAW_BUILD_DIR)/.staged
#	$(MAKE) -C $(DCRAW_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(DCRAW_BUILD_DIR)/.staged

dcraw-stage: $(DCRAW_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/dcraw
#
$(DCRAW_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(DCRAW_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: dcraw" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(DCRAW_PRIORITY)" >>$@
	@echo "Section: $(DCRAW_SECTION)" >>$@
	@echo "Version: $(DCRAW_VERSION)-$(DCRAW_IPK_VERSION)" >>$@
	@echo "Maintainer: $(DCRAW_MAINTAINER)" >>$@
	@echo "Source: $(DCRAW_SITE)/RCS/$(DCRAW_SOURCE)" >>$@
	@echo "Description: $(DCRAW_DESCRIPTION)" >>$@
	@echo "Depends: $(DCRAW_DEPENDS)" >>$@
	@echo "Suggests: $(DCRAW_SUGGESTS)" >>$@
	@echo "Conflicts: $(DCRAW_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/sbin or $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/dcraw/...
# Documentation files should be installed in $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/doc/dcraw/...
# Daemon startup scripts should be installed in $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??dcraw
#
# You may need to patch your application to make it use these locations.
#
$(DCRAW_IPK): $(DCRAW_BUILD_DIR)/.built
	rm -rf $(DCRAW_IPK_DIR) $(BUILD_DIR)/dcraw_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/bin/
	$(INSTALL) $(DCRAW_BUILD_DIR)/dcraw $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/bin/
	$(STRIP_COMMAND) $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/bin/dcraw
	$(INSTALL) -d $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/share/man/man1
	$(INSTALL) $(DL_DIR)/dcraw.1 $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/share/man/man1/dcraw.1
#	$(MAKE) -C $(DCRAW_BUILD_DIR) DESTDIR=$(DCRAW_IPK_DIR) install-strip
#	$(INSTALL) -d $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/
#	$(INSTALL) -m 644 $(DCRAW_SOURCE_DIR)/dcraw.conf $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/dcraw.conf
#	$(INSTALL) -d $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d
#	$(INSTALL) -m 755 $(DCRAW_SOURCE_DIR)/rc.dcraw $(DCRAW_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/SXXdcraw
	$(MAKE) $(DCRAW_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 755 $(DCRAW_SOURCE_DIR)/postinst $(DCRAW_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 755 $(DCRAW_SOURCE_DIR)/prerm $(DCRAW_IPK_DIR)/CONTROL/prerm
	echo $(DCRAW_CONFFILES) | sed -e 's/ /\n/g' > $(DCRAW_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(DCRAW_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
dcraw-ipk: $(DCRAW_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
dcraw-clean:
	rm -f $(DCRAW_BUILD_DIR)/.built
	-$(MAKE) -C $(DCRAW_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
dcraw-dirclean:
	rm -rf $(BUILD_DIR)/$(DCRAW_DIR) $(DCRAW_BUILD_DIR) $(DCRAW_IPK_DIR) $(DCRAW_IPK)

#
# Some sanity check for the package.
#
dcraw-check: $(DCRAW_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(DCRAW_IPK)
