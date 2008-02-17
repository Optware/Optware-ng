###########################################################
#
# snownews
#
###########################################################

# You must replace "snownews" and "SNOWNEWS" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# SNOWNEWS_VERSION, SNOWNEWS_SITE and SNOWNEWS_SOURCE define
# the upstream location of the source code for the package.
# SNOWNEWS_DIR is the directory which is created when the source
# archive is unpacked.
# SNOWNEWS_UNZIP is the command used to unzip the source.
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
SNOWNEWS_SITE=http://kiza.kcore.de/software/snownews/download
SNOWNEWS_VERSION=1.5.9
SNOWNEWS_SOURCE=snownews-$(SNOWNEWS_VERSION).tar.gz
SNOWNEWS_DIR=snownews-$(SNOWNEWS_VERSION)
SNOWNEWS_UNZIP=zcat
SNOWNEWS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
SNOWNEWS_DESCRIPTION=Text mode RSS newsreader for Linux and Unix
SNOWNEWS_SECTION=misc
SNOWNEWS_PRIORITY=optional
SNOWNEWS_DEPENDS=libxml2, ncurses, gettext
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
SNOWNEWS_DEPENDS+=, libiconv
else
SNOWNEWS_DEPENDS+=, gconv-modules
endif

#
# SNOWNEWS_IPK_VERSION should be incremented when the ipk changes.
#
SNOWNEWS_IPK_VERSION=1

#
# SNOWNEWS_CONFFILES should be a list of user-editable files
#SNOWNEWS_CONFFILES=/opt/etc/snownews.conf /opt/etc/init.d/SXXsnownews

#
# SNOWNEWS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#SNOWNEWS_PATCHES=$(SNOWNEWS_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
SNOWNEWS_CPPFLAGS=-I$(STAGING_INCLUDE_DIR)/libxml2
SNOWNEWS_LDFLAGS=-lncurses -lxml2 -lz -lpthread -lm
ifeq ($(LIBC_STYLE), uclibc)
SNOWNEWS_LDFLAGS+= -lintl
endif
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
SNOWNEWS_LDFLAGS+= -liconv
endif

#
# SNOWNEWS_BUILD_DIR is the directory in which the build is done.
# SNOWNEWS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# SNOWNEWS_IPK_DIR is the directory in which the ipk is built.
# SNOWNEWS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
SNOWNEWS_BUILD_DIR=$(BUILD_DIR)/snownews
SNOWNEWS_SOURCE_DIR=$(SOURCE_DIR)/snownews
SNOWNEWS_IPK_DIR=$(BUILD_DIR)/snownews-$(SNOWNEWS_VERSION)-ipk
SNOWNEWS_IPK=$(BUILD_DIR)/snownews_$(SNOWNEWS_VERSION)-$(SNOWNEWS_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: snownews-source snownews-unpack snownews snownews-stage snownews-ipk snownews-clean snownews-dirclean snownews-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(SNOWNEWS_SOURCE):
	$(WGET) -P $(DL_DIR) $(SNOWNEWS_SITE)/$(SNOWNEWS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
snownews-source: $(DL_DIR)/$(SNOWNEWS_SOURCE) $(SNOWNEWS_PATCHES)

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
$(SNOWNEWS_BUILD_DIR)/.configured: $(DL_DIR)/$(SNOWNEWS_SOURCE) \
		$(SNOWNEWS_PATCHES) make/snownews.mk
	$(MAKE) libxml2-stage ncurses-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
else
	$(MAKE) gconv-modules-stage
endif
	rm -rf $(BUILD_DIR)/$(SNOWNEWS_DIR) $(@D)
	$(SNOWNEWS_UNZIP) $(DL_DIR)/$(SNOWNEWS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(SNOWNEWS_PATCHES)"; then \
		cat $(SNOWNEWS_PATCHES) | patch -d $(BUILD_DIR)/$(SNOWNEWS_DIR) -p1; \
	fi
	mv $(BUILD_DIR)/$(SNOWNEWS_DIR) $(@D)
	(cd $(@D); \
                $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SNOWNEWS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SNOWNEWS_LDFLAGS)" \
		PATH=$(STAGING_PREFIX)/bin:$$PATH \
		./configure \
		--prefix=/opt \
		--disable-nls \
		; \
	)
	sed -i -e '/$$(INSTALL)/s/-s //' $(@D)/Makefile
	touch $@

snownews-unpack: $(SNOWNEWS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(SNOWNEWS_BUILD_DIR)/.built: $(SNOWNEWS_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
                $(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(SNOWNEWS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(SNOWNEWS_LDFLAGS)" \
		;
	touch $@

#
# This is the build convenience target.
#
snownews: $(SNOWNEWS_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(SNOWNEWS_BUILD_DIR)/.staged: $(SNOWNEWS_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

snownews-stage: $(SNOWNEWS_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/snownews
#
$(SNOWNEWS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: snownews" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(SNOWNEWS_PRIORITY)" >>$@
	@echo "Section: $(SNOWNEWS_SECTION)" >>$@
	@echo "Version: $(SNOWNEWS_VERSION)-$(SNOWNEWS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(SNOWNEWS_MAINTAINER)" >>$@
	@echo "Source: $(SNOWNEWS_SITE)/$(SNOWNEWS_SOURCE)" >>$@
	@echo "Description: $(SNOWNEWS_DESCRIPTION)" >>$@
	@echo "Depends: $(SNOWNEWS_DEPENDS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(SNOWNEWS_IPK_DIR)/opt/sbin or $(SNOWNEWS_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(SNOWNEWS_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(SNOWNEWS_IPK_DIR)/opt/etc/snownews/...
# Documentation files should be installed in $(SNOWNEWS_IPK_DIR)/opt/doc/snownews/...
# Daemon startup scripts should be installed in $(SNOWNEWS_IPK_DIR)/opt/etc/init.d/S??snownews
#
# You may need to patch your application to make it use these locations.
#
$(SNOWNEWS_IPK): $(SNOWNEWS_BUILD_DIR)/.built
	rm -rf $(SNOWNEWS_IPK_DIR) $(BUILD_DIR)/snownews_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(SNOWNEWS_BUILD_DIR) DESTDIR=$(SNOWNEWS_IPK_DIR) install
	$(TARGET_STRIP) $(SNOWNEWS_IPK_DIR)/opt/bin/snownews
	$(MAKE) $(SNOWNEWS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(SNOWNEWS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
snownews-ipk: $(SNOWNEWS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
snownews-clean:
	-$(MAKE) -C $(SNOWNEWS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
snownews-dirclean:
	rm -rf $(BUILD_DIR)/$(SNOWNEWS_DIR) $(SNOWNEWS_BUILD_DIR) $(SNOWNEWS_IPK_DIR) $(SNOWNEWS_IPK)
#
#
# Some sanity check for the package.
#
snownews-check: $(SNOWNEWS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(SNOWNEWS_IPK)
