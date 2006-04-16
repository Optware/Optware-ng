###########################################################
#
# flip
#
###########################################################

#
# FLIP_VERSION, FLIP_SITE and FLIP_SOURCE define
# the upstream location of the source code for the package.
# FLIP_DIR is the directory which is created when the source
# archive is unpacked.
# FLIP_UNZIP is the command used to unzip the source.
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
FLIP_SITE=http://www-ccrma.stanford.edu/~craig/utility/flip
FLIP_VERSION=20050821
FLIP_SOURCE=flip.cpp
FLIP_DIR=flip-$(FLIP_VERSION)
FLIP_UNZIP=zcat
FLIP_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
FLIP_DESCRIPTION=Utility program to convert text files between UNIX or Mac newlines and DOS linefeed + newlines.
FLIP_SECTION=textproc
FLIP_PRIORITY=optional
FLIP_DEPENDS=libstdc++
FLIP_SUGGESTS=
FLIP_CONFLICTS=

#
# FLIP_IPK_VERSION should be incremented when the ipk changes.
#
FLIP_IPK_VERSION=1

#
# FLIP_CONFFILES should be a list of user-editable files
#FLIP_CONFFILES=/opt/etc/flip.conf /opt/etc/init.d/SXXflip

#
# FLIP_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#FLIP_PATCHES=$(FLIP_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
FLIP_CPPFLAGS=
FLIP_LDFLAGS=

#
# FLIP_BUILD_DIR is the directory in which the build is done.
# FLIP_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# FLIP_IPK_DIR is the directory in which the ipk is built.
# FLIP_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
FLIP_BUILD_DIR=$(BUILD_DIR)/flip
FLIP_SOURCE_DIR=$(SOURCE_DIR)/flip
FLIP_IPK_DIR=$(BUILD_DIR)/flip-$(FLIP_VERSION)-ipk
FLIP_IPK=$(BUILD_DIR)/flip_$(FLIP_VERSION)-$(FLIP_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(FLIP_SOURCE):
	$(WGET) -P $(DL_DIR) $(FLIP_SITE)/$(FLIP_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
flip-source: $(DL_DIR)/$(FLIP_SOURCE) $(FLIP_PATCHES)

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
$(FLIP_BUILD_DIR)/.configured: $(DL_DIR)/$(FLIP_SOURCE) $(FLIP_PATCHES) make/flip.mk
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(FLIP_DIR) $(FLIP_BUILD_DIR)
#	$(FLIP_UNZIP) $(DL_DIR)/$(FLIP_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mkdir -p $(BUILD_DIR)/$(FLIP_DIR)
	cp $(DL_DIR)/$(FLIP_SOURCE) $(BUILD_DIR)/$(FLIP_DIR)
	if test -n "$(FLIP_PATCHES)" ; \
		then cat $(FLIP_PATCHES) | \
		patch -d $(BUILD_DIR)/$(FLIP_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(FLIP_DIR)" != "$(FLIP_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(FLIP_DIR) $(FLIP_BUILD_DIR) ; \
	fi
	touch $(FLIP_BUILD_DIR)/.configured

flip-unpack: $(FLIP_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(FLIP_BUILD_DIR)/.built: $(FLIP_BUILD_DIR)/.configured
	rm -f $(FLIP_BUILD_DIR)/.built
	(cd $(FLIP_BUILD_DIR); \
	$(TARGET_CXX) -ansi -O3 -o flip flip.cpp \
		$(STAGING_CPPFLAGS) $(FLIP_CPPFLAGS) \
		$(STAGING_LDFLAGS) $(FLIP_LDFLAGS); \
		)
	touch $(FLIP_BUILD_DIR)/.built

#
# This is the build convenience target.
#
flip: $(FLIP_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(FLIP_BUILD_DIR)/.staged: $(FLIP_BUILD_DIR)/.built
	rm -f $(FLIP_BUILD_DIR)/.staged
#	$(MAKE) -C $(FLIP_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(FLIP_BUILD_DIR)/.staged

flip-stage: $(FLIP_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/flip
#
$(FLIP_IPK_DIR)/CONTROL/control:
	@install -d $(FLIP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: flip" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(FLIP_PRIORITY)" >>$@
	@echo "Section: $(FLIP_SECTION)" >>$@
	@echo "Version: $(FLIP_VERSION)-$(FLIP_IPK_VERSION)" >>$@
	@echo "Maintainer: $(FLIP_MAINTAINER)" >>$@
	@echo "Source: $(FLIP_SITE)/$(FLIP_SOURCE)" >>$@
	@echo "Description: $(FLIP_DESCRIPTION)" >>$@
	@echo "Depends: $(FLIP_DEPENDS)" >>$@
	@echo "Suggests: $(FLIP_SUGGESTS)" >>$@
	@echo "Conflicts: $(FLIP_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(FLIP_IPK_DIR)/opt/sbin or $(FLIP_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(FLIP_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(FLIP_IPK_DIR)/opt/etc/flip/...
# Documentation files should be installed in $(FLIP_IPK_DIR)/opt/doc/flip/...
# Daemon startup scripts should be installed in $(FLIP_IPK_DIR)/opt/etc/init.d/S??flip
#
# You may need to patch your application to make it use these locations.
#
$(FLIP_IPK): $(FLIP_BUILD_DIR)/.built
	rm -rf $(FLIP_IPK_DIR) $(BUILD_DIR)/flip_*_$(TARGET_ARCH).ipk
	install -d $(FLIP_IPK_DIR)/opt/bin/
	install $(FLIP_BUILD_DIR)/flip $(FLIP_IPK_DIR)/opt/bin/
	$(STRIP_COMMAND) $(FLIP_IPK_DIR)/opt/bin/flip
	install -d $(FLIP_IPK_DIR)/opt/share/doc/flip/
	echo $(FLIP_SITE) > $(FLIP_IPK_DIR)/opt/share/doc/flip/url.txt
#	$(MAKE) -C $(FLIP_BUILD_DIR) DESTDIR=$(FLIP_IPK_DIR) install-strip
#	install -d $(FLIP_IPK_DIR)/opt/etc/
#	install -m 644 $(FLIP_SOURCE_DIR)/flip.conf $(FLIP_IPK_DIR)/opt/etc/flip.conf
#	install -d $(FLIP_IPK_DIR)/opt/etc/init.d
#	install -m 755 $(FLIP_SOURCE_DIR)/rc.flip $(FLIP_IPK_DIR)/opt/etc/init.d/SXXflip
	$(MAKE) $(FLIP_IPK_DIR)/CONTROL/control
#	install -m 755 $(FLIP_SOURCE_DIR)/postinst $(FLIP_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(FLIP_SOURCE_DIR)/prerm $(FLIP_IPK_DIR)/CONTROL/prerm
	echo $(FLIP_CONFFILES) | sed -e 's/ /\n/g' > $(FLIP_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(FLIP_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
flip-ipk: $(FLIP_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
flip-clean:
	rm -f $(FLIP_BUILD_DIR)/.built
	-$(MAKE) -C $(FLIP_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
flip-dirclean:
	rm -rf $(BUILD_DIR)/$(FLIP_DIR) $(FLIP_BUILD_DIR) $(FLIP_IPK_DIR) $(FLIP_IPK)
