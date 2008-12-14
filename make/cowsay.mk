###########################################################
#
# cowsay
#
###########################################################

# You must replace "cowsay" and "COWSAY" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# COWSAY_VERSION, COWSAY_SITE and COWSAY_SOURCE define
# the upstream location of the source code for the package.
# COWSAY_DIR is the directory which is created when the source
# archive is unpacked.
# COWSAY_UNZIP is the command used to unzip the source.
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
COWSAY_SITE=http://www.nog.net/~tony/warez/
COWSAY_VERSION=3.03
COWSAY_SOURCE=cowsay-$(COWSAY_VERSION).tar.gz
COWSAY_DIR=cowsay-$(COWSAY_VERSION)
COWSAY_UNZIP=zcat
COWSAY_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
COWSAY_DESCRIPTION=A Configurable Speaking/Thinking Cow
COWSAY_SECTION=util
COWSAY_PRIORITY=optional
COWSAY_DEPENDS=perl
COWSAY_SUGGESTS=
COWSAY_CONFLICTS=

#
# COWSAY_IPK_VERSION should be incremented when the ipk changes.
#
COWSAY_IPK_VERSION=3

#
# COWSAY_CONFFILES should be a list of user-editable files
#COWSAY_CONFFILES=

#
# COWSAY_BUILD_DIR is the directory in which the build is done.
# COWSAY_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COWSAY_IPK_DIR is the directory in which the ipk is built.
# COWSAY_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COWSAY_BUILD_DIR=$(BUILD_DIR)/cowsay
COWSAY_SOURCE_DIR=$(SOURCE_DIR)/cowsay
COWSAY_IPK_DIR=$(BUILD_DIR)/cowsay-$(COWSAY_VERSION)-ipk
COWSAY_IPK=$(BUILD_DIR)/cowsay_$(COWSAY_VERSION)-$(COWSAY_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COWSAY_SOURCE):
	$(WGET) -P $(DL_DIR) $(COWSAY_SITE)/$(@F) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
cowsay-source: $(DL_DIR)/$(COWSAY_SOURCE) $(COWSAY_PATCHES)

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
$(COWSAY_BUILD_DIR)/.configured: $(DL_DIR)/$(COWSAY_SOURCE) $(COWSAY_PATCHES) make/cowsay.mk
	rm -rf $(BUILD_DIR)/$(COWSAY_DIR) $(@D)
	$(COWSAY_UNZIP) $(DL_DIR)/$(COWSAY_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(COWSAY_PATCHES)" ; \
		then cat $(COWSAY_PATCHES) | \
		patch -d $(BUILD_DIR)/$(COWSAY_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(COWSAY_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(COWSAY_DIR) $(@D) ; \
	fi
	sed -i -e '/%BANGPERL%/s|$$usethisperl|/opt/bin/perl|' \
	       -e '/%PREFIX%/s|$$PREFIX|/opt|' \
	       $(@D)/install.sh
	touch $@

cowsay-unpack: $(COWSAY_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(COWSAY_BUILD_DIR)/.built: $(COWSAY_BUILD_DIR)/.configured
	rm -f $@
	#$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
cowsay: $(COWSAY_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(COWSAY_BUILD_DIR)/.staged: $(COWSAY_BUILD_DIR)/.built

cowsay-stage: $(COWSAY_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/cowsay
#
$(COWSAY_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: cowsay" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COWSAY_PRIORITY)" >>$@
	@echo "Section: $(COWSAY_SECTION)" >>$@
	@echo "Version: $(COWSAY_VERSION)-$(COWSAY_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COWSAY_MAINTAINER)" >>$@
	@echo "Source: $(COWSAY_SITE)/$(COWSAY_SOURCE)" >>$@
	@echo "Description: $(COWSAY_DESCRIPTION)" >>$@
	@echo "Depends: $(COWSAY_DEPENDS)" >>$@
	@echo "Suggests: $(COWSAY_SUGGESTS)" >>$@
	@echo "Conflicts: $(COWSAY_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(COWSAY_IPK_DIR)/opt/sbin or $(COWSAY_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COWSAY_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(COWSAY_IPK_DIR)/opt/etc/cowsay/...
# Documentation files should be installed in $(COWSAY_IPK_DIR)/opt/doc/cowsay/...
# Daemon startup scripts should be installed in $(COWSAY_IPK_DIR)/opt/etc/init.d/S??cowsay
#
# You may need to patch your application to make it use these locations.
#
$(COWSAY_IPK): $(COWSAY_BUILD_DIR)/.built
	rm -rf $(COWSAY_IPK_DIR) $(BUILD_DIR)/cowsay_*_$(TARGET_ARCH).ipk
	install -m 644 $(COWSAY_SOURCE_DIR)/nslu2.cow $(COWSAY_BUILD_DIR)/cows/nslu2.cow
	cd $(COWSAY_BUILD_DIR); sh ./install.sh $(COWSAY_IPK_DIR)/opt
	$(MAKE) $(COWSAY_IPK_DIR)/CONTROL/control
	echo $(COWSAY_CONFFILES) | sed -e 's/ /\n/g' > $(COWSAY_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COWSAY_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
cowsay-ipk: $(COWSAY_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
cowsay-clean:
	rm -f $(COWSAY_BUILD_DIR)/.built
	-$(MAKE) -C $(COWSAY_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
cowsay-dirclean:
	rm -rf $(BUILD_DIR)/$(COWSAY_DIR) $(COWSAY_BUILD_DIR) $(COWSAY_IPK_DIR) $(COWSAY_IPK)
#
#
# Some sanity check for the package.
#
cowsay-check: $(COWSAY_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(COWSAY_IPK)
