###########################################################
#
# littlesmalltalk
#
###########################################################
#
# LITTLESMALLTALK_VERSION, LITTLESMALLTALK_SITE and LITTLESMALLTALK_SOURCE define
# the upstream location of the source code for the package.
# LITTLESMALLTALK_DIR is the directory which is created when the source
# archive is unpacked.
# LITTLESMALLTALK_UNZIP is the command used to unzip the source.
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
LITTLESMALLTALK_SVN_REPO=https://littlesmalltalk.svn.sourceforge.net/svnroot/littlesmalltalk/lst5
LITTLESMALLTALK_SVN_REV=0075
#LITTLESMALLTALK_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/littlesmalltalk
LITTLESMALLTALK_VERSION=5.0a08+svn$(LITTLESMALLTALK_SVN_REV)
LITTLESMALLTALK_SOURCE=littlesmalltalk-$(LITTLESMALLTALK_VERSION).tar.gz
LITTLESMALLTALK_DIR=littlesmalltalk-$(LITTLESMALLTALK_VERSION)
LITTLESMALLTALK_UNZIP=zcat
LITTLESMALLTALK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
LITTLESMALLTALK_DESCRIPTION=A minimalistic implementation of the Smalltalk programming language. Originally developed by Timothy A. Budd.
LITTLESMALLTALK_SECTION=lang
LITTLESMALLTALK_PRIORITY=optional
LITTLESMALLTALK_DEPENDS=
LITTLESMALLTALK_SUGGESTS=
LITTLESMALLTALK_CONFLICTS=

#
# LITTLESMALLTALK_IPK_VERSION should be incremented when the ipk changes.
#
LITTLESMALLTALK_IPK_VERSION=1

#
# LITTLESMALLTALK_CONFFILES should be a list of user-editable files
LITTLESMALLTALK_CONFFILES=/opt/share/littlesmalltalk/LittleSmalltalk.image

#
# LITTLESMALLTALK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#LITTLESMALLTALK_PATCHES=$(LITTLESMALLTALK_SOURCE_DIR)/endianness.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
LITTLESMALLTALK_CPPFLAGS=
LITTLESMALLTALK_LDFLAGS=

#
# LITTLESMALLTALK_BUILD_DIR is the directory in which the build is done.
# LITTLESMALLTALK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# LITTLESMALLTALK_IPK_DIR is the directory in which the ipk is built.
# LITTLESMALLTALK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
LITTLESMALLTALK_SOURCE_DIR=$(SOURCE_DIR)/littlesmalltalk
LITTLESMALLTALK_BUILD_DIR=$(BUILD_DIR)/littlesmalltalk
LITTLESMALLTALK_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/littlesmalltalk

LITTLESMALLTALK_IPK_DIR=$(BUILD_DIR)/littlesmalltalk-$(LITTLESMALLTALK_VERSION)-ipk
LITTLESMALLTALK_IPK=$(BUILD_DIR)/littlesmalltalk_$(LITTLESMALLTALK_VERSION)-$(LITTLESMALLTALK_IPK_VERSION)_$(TARGET_ARCH).ipk

ifeq ($(TARGET_CC), $(HOSTCC))
LITTLESMALLTALK_TARGET=all
LITTLESMALLTALK_IMAGE=$(LITTLESMALLTALK_BUILD_DIR)/bin/LittleSmalltalk.image
else
LITTLESMALLTALK_TARGET=bin/st
LITTLESMALLTALK_IMAGE=$(LITTLESMALLTALK_HOST_BUILD_DIR)/bin/LittleSmalltalk.image
endif

.PHONY: littlesmalltalk-source littlesmalltalk-unpack littlesmalltalk littlesmalltalk-stage littlesmalltalk-ipk littlesmalltalk-clean littlesmalltalk-dirclean littlesmalltalk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(LITTLESMALLTALK_SOURCE):
ifndef LITTLESMALLTALK_SVN_REV
	$(WGET) -P $(DL_DIR) $(LITTLESMALLTALK_SITE)/$(LITTLESMALLTALK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(LITTLESMALLTALK_SOURCE)
else
	( cd $(BUILD_DIR) ; \
		rm -rf $(LITTLESMALLTALK_DIR) && \
		svn co -r$(LITTLESMALLTALK_SVN_REV) $(LITTLESMALLTALK_SVN_REPO) $(LITTLESMALLTALK_DIR) && \
		tar -czf $@ $(LITTLESMALLTALK_DIR) --exclude .svn --exclude thirdparty && \
		rm -rf $(LITTLESMALLTALK_DIR) \
	)
endif

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
littlesmalltalk-source: $(DL_DIR)/$(LITTLESMALLTALK_SOURCE) $(LITTLESMALLTALK_PATCHES)

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
$(LITTLESMALLTALK_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(LITTLESMALLTALK_SOURCE) $(LITTLESMALLTALK_PATCHES) make/littlesmalltalk.mk
	rm -rf $(HOST_BUILD_DIR)/$(LITTLESMALLTALK_DIR) $(LITTLESMALLTALK_HOST_BUILD_DIR)
	$(LITTLESMALLTALK_UNZIP) $(DL_DIR)/$(LITTLESMALLTALK_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test -n "$(LITTLESMALLTALK_PATCHES)" ; \
		then cat $(LITTLESMALLTALK_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(LITTLESMALLTALK_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(LITTLESMALLTALK_DIR)" != "$(LITTLESMALLTALK_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(LITTLESMALLTALK_DIR) $(LITTLESMALLTALK_HOST_BUILD_DIR) ; \
	fi
	$(MAKE) -C $(LITTLESMALLTALK_HOST_BUILD_DIR)
	touch $@

ifeq ($(TARGET_CC), $(HOSTCC))
$(LITTLESMALLTALK_BUILD_DIR)/.configured: $(DL_DIR)/$(LITTLESMALLTALK_SOURCE) $(LITTLESMALLTALK_PATCHES) make/littlesmalltalk.mk
else
$(LITTLESMALLTALK_BUILD_DIR)/.configured: $(LITTLESMALLTALK_HOST_BUILD_DIR)/.built $(LITTLESMALLTALK_PATCHES)
endif
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(LITTLESMALLTALK_DIR) $(LITTLESMALLTALK_BUILD_DIR)
	$(LITTLESMALLTALK_UNZIP) $(DL_DIR)/$(LITTLESMALLTALK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(LITTLESMALLTALK_PATCHES)" ; \
		then cat $(LITTLESMALLTALK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(LITTLESMALLTALK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(LITTLESMALLTALK_DIR)" != "$(LITTLESMALLTALK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(LITTLESMALLTALK_DIR) $(LITTLESMALLTALK_BUILD_DIR) ; \
	fi
	touch $@

littlesmalltalk-unpack: $(LITTLESMALLTALK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(LITTLESMALLTALK_BUILD_DIR)/.built: $(LITTLESMALLTALK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(LITTLESMALLTALK_BUILD_DIR) $(LITTLESMALLTALK_TARGET) \
		UNAME_O=Linux \
		UNAME_M=$(TARGET_ARCH) \
		CC=$(TARGET_CC) \
		CPPFLAGS='-DDefaultImageFile=\"/opt/share/littlesmalltalk/LittleSmalltalk.image\"' \
		;
	touch $@

#
# This is the build convenience target.
#
littlesmalltalk: $(LITTLESMALLTALK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(LITTLESMALLTALK_BUILD_DIR)/.staged: $(LITTLESMALLTALK_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(LITTLESMALLTALK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

littlesmalltalk-stage: $(LITTLESMALLTALK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/littlesmalltalk
#
$(LITTLESMALLTALK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: littlesmalltalk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(LITTLESMALLTALK_PRIORITY)" >>$@
	@echo "Section: $(LITTLESMALLTALK_SECTION)" >>$@
	@echo "Version: $(LITTLESMALLTALK_VERSION)-$(LITTLESMALLTALK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(LITTLESMALLTALK_MAINTAINER)" >>$@
	@echo "Source: $(LITTLESMALLTALK_SITE)/$(LITTLESMALLTALK_SOURCE)" >>$@
	@echo "Description: $(LITTLESMALLTALK_DESCRIPTION)" >>$@
	@echo "Depends: $(LITTLESMALLTALK_DEPENDS)" >>$@
	@echo "Suggests: $(LITTLESMALLTALK_SUGGESTS)" >>$@
	@echo "Conflicts: $(LITTLESMALLTALK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(LITTLESMALLTALK_IPK_DIR)/opt/sbin or $(LITTLESMALLTALK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(LITTLESMALLTALK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(LITTLESMALLTALK_IPK_DIR)/opt/etc/littlesmalltalk/...
# Documentation files should be installed in $(LITTLESMALLTALK_IPK_DIR)/opt/doc/littlesmalltalk/...
# Daemon startup scripts should be installed in $(LITTLESMALLTALK_IPK_DIR)/opt/etc/init.d/S??littlesmalltalk
#
# You may need to patch your application to make it use these locations.
#
$(LITTLESMALLTALK_IPK): $(LITTLESMALLTALK_BUILD_DIR)/.built
	rm -rf $(LITTLESMALLTALK_IPK_DIR) $(BUILD_DIR)/littlesmalltalk_*_$(TARGET_ARCH).ipk
#	$(MAKE) -C $(LITTLESMALLTALK_BUILD_DIR) DESTDIR=$(LITTLESMALLTALK_IPK_DIR) install-strip
	install -d $(LITTLESMALLTALK_IPK_DIR)/opt/bin
	install -m 755 $(LITTLESMALLTALK_BUILD_DIR)/bin/st $(LITTLESMALLTALK_IPK_DIR)/opt/bin/lst5
	$(STRIP_COMMAND) $(LITTLESMALLTALK_IPK_DIR)/opt/bin/lst5
	install -d $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk
	install -m 777 $(LITTLESMALLTALK_IMAGE) $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk/LittleSmalltalk.image
	install -m 444 $(LITTLESMALLTALK_IMAGE) $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk/LittleSmalltalk-dist.image
	install -m 444 $(LITTLESMALLTALK_BUILD_DIR)/README $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk/
	install -m 444 $(LITTLESMALLTALK_BUILD_DIR)/LICENSE $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk/
	cp -rp $(LITTLESMALLTALK_BUILD_DIR)/examples/ $(LITTLESMALLTALK_IPK_DIR)/opt/share/littlesmalltalk/
	$(MAKE) $(LITTLESMALLTALK_IPK_DIR)/CONTROL/control
	echo $(LITTLESMALLTALK_CONFFILES) | sed -e 's/ /\n/g' > $(LITTLESMALLTALK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(LITTLESMALLTALK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
littlesmalltalk-ipk: $(LITTLESMALLTALK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
littlesmalltalk-clean:
	rm -f $(LITTLESMALLTALK_BUILD_DIR)/.built
	-$(MAKE) -C $(LITTLESMALLTALK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
littlesmalltalk-dirclean:
	rm -rf $(BUILD_DIR)/$(LITTLESMALLTALK_DIR) $(LITTLESMALLTALK_BUILD_DIR) $(LITTLESMALLTALK_IPK_DIR) $(LITTLESMALLTALK_IPK)
#
#
# Some sanity check for the package.
#
littlesmalltalk-check: $(LITTLESMALLTALK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(LITTLESMALLTALK_IPK)
