###########################################################
#
# phoneme-advanced
#
###########################################################
#
# PHONEME_ADVANCED_VERSION, PHONEME_ADVANCED_SITE and PHONEME_ADVANCED_SOURCE define
# the upstream location of the source code for the package.
# PHONEME_ADVANCED_DIR is the directory which is created when the source
# archive is unpacked.
# PHONEME_ADVANCED_UNZIP is the command used to unzip the source.
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
PHONEME_ADVANCED_SITE=http://download.java.net/mobileembedded/phoneme/advanced
PHONEME_ADVANCED_VERSION=0.0.mr.2.b.21
PHONEME_ADVANCED_SOURCE=phoneme_advanced-mr2-dev-src-b21-04_may_2007.zip
PHONEME_ADVANCED_LEGAL=phoneme_advanced-legal.tar.gz
PHONEME_ADVANCED_REPO=https://phoneme.dev.java.net/svn/phoneme
PHONEME_ADVANCED_DIR=phoneme_advanced_mr2
PHONEME_ADVANCED_UNZIP=unzip
PHONEME_ADVANCED_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PHONEME_ADVANCED_DESCRIPTION=J2ME phoneme advanced, including CDC JVM.
PHONEME_ADVANCED_SECTION=lang
PHONEME_ADVANCED_PRIORITY=optional
PHONEME_ADVANCED_DEPENDS=
PHONEME_ADVANCED_SUGGESTS=
PHONEME_ADVANCED_CONFLICTS=

#
# PHONEME_ADVANCED_IPK_VERSION should be incremented when the ipk changes.
#
PHONEME_ADVANCED_IPK_VERSION=1

#
# PHONEME_ADVANCED_CONFFILES should be a list of user-editable files
#PHONEME_ADVANCED_CONFFILES=/opt/etc/phoneme-advanced.conf /opt/etc/init.d/SXXphoneme-advanced

#
# PHONEME_ADVANCED_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
ifeq (armeb, $(TARGET_ARCH))
PHONEME_ADVANCED_PATCHES=$(PHONEME_ADVANCED_SOURCE_DIR)/armeb-memory_arch.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PHONEME_ADVANCED_CPPFLAGS=
PHONEME_ADVANCED_LDFLAGS=

PHONEME_ADVANCED_ARCH=$(strip \
	$(if $(filter armeb, $(TARGET_ARCH)), arm, \
	$(if $(filter mipsel, $(TARGET_ARCH)), mips, \
	$(TARGET_ARCH))))
PHONEME_ADVANCED_MAKE_OPTIONS=$(strip \
	$(if $(filter arm, $(PHONEME_ADVANCED_ARCH)), \
		CVM_FORCE_HARD_FLOAT=true USE_AAPCS=false, \
		))
# JDK_HOME e.g. /usr/lib/jvm/java-1.5.0-sun-1.5.0.11
ifdef JDK_HOME
PHONEME_ADVANCED_MAKE_OPTIONS+= JDK_HOME=$(JDK_HOME)
endif

#
# PHONEME_ADVANCED_BUILD_DIR is the directory in which the build is done.
# PHONEME_ADVANCED_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PHONEME_ADVANCED_IPK_DIR is the directory in which the ipk is built.
# PHONEME_ADVANCED_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PHONEME_ADVANCED_BUILD_DIR=$(BUILD_DIR)/phoneme-advanced
PHONEME_ADVANCED_CDC_BUILD_DIR=$(PHONEME_ADVANCED_BUILD_DIR)/cdc/build/linux-$(PHONEME_ADVANCED_ARCH)-$(OPTWARE_TARGET)
PHONEME_ADVANCED_SOURCE_DIR=$(SOURCE_DIR)/phoneme-advanced
PHONEME_ADVANCED_IPK_DIR=$(BUILD_DIR)/phoneme-advanced-$(PHONEME_ADVANCED_VERSION)-ipk
PHONEME_ADVANCED_IPK=$(BUILD_DIR)/phoneme-advanced_$(PHONEME_ADVANCED_VERSION)-$(PHONEME_ADVANCED_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: phoneme-advanced-source phoneme-advanced-unpack phoneme-advanced phoneme-advanced-stage phoneme-advanced-ipk phoneme-advanced-clean phoneme-advanced-dirclean phoneme-advanced-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PHONEME_ADVANCED_SOURCE):
	$(WGET) -P $(DL_DIR) $(PHONEME_ADVANCED_SITE)/$(PHONEME_ADVANCED_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(PHONEME_ADVANCED_SOURCE)

$(DL_DIR)/$(PHONEME_ADVANCED_LEGAL): make/phoneme-advanced.mk
	( cd $(BUILD_DIR) ; \
		rm -rf $(PHONEME_ADVANCED_DIR)-legal && \
		svn co $(PHONEME_ADVANCED_REPO)/legal $(PHONEME_ADVANCED_DIR)-legal/legal --username guest --password '' && \
		tar -C $(PHONEME_ADVANCED_DIR)-legal -czf $@ legal --exclude .svn && \
		rm -rf $(PHONEME_ADVANCED_DIR)-legal \
	)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
phoneme-advanced-source: $(DL_DIR)/$(PHONEME_ADVANCED_SOURCE) $(PHONEME_ADVANCED_PATCHES)

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
$(PHONEME_ADVANCED_BUILD_DIR)/.configured: make/phoneme-advanced.mk \
$(DL_DIR)/$(PHONEME_ADVANCED_SOURCE) \
$(DL_DIR)/$(PHONEME_ADVANCED_LEGAL) \
$(PHONEME_ADVANCED_PATCHES)
#	$(MAKE) <bar>-stage <baz>-stage
	rm -rf $(BUILD_DIR)/$(PHONEME_ADVANCED_DIR) $(PHONEME_ADVANCED_BUILD_DIR)
	cd $(BUILD_DIR) && $(PHONEME_ADVANCED_UNZIP) $(DL_DIR)/$(PHONEME_ADVANCED_SOURCE)
	if test -n "$(PHONEME_ADVANCED_PATCHES)" ; \
		then cat $(PHONEME_ADVANCED_PATCHES) | \
		patch -d $(BUILD_DIR)/$(PHONEME_ADVANCED_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(PHONEME_ADVANCED_DIR)" != "$(PHONEME_ADVANCED_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PHONEME_ADVANCED_DIR) $(PHONEME_ADVANCED_BUILD_DIR) ; \
	fi
	tar -C $(PHONEME_ADVANCED_BUILD_DIR) -xvzf $(DL_DIR)/$(PHONEME_ADVANCED_LEGAL)
	mkdir -p $(PHONEME_ADVANCED_CDC_BUILD_DIR)
ifeq ($(PHONEME_ADVANCED_ARCH), $(filter mips powerpc, $(PHONEME_ADVANCED_ARCH)))
	tar -C $(PHONEME_ADVANCED_BUILD_DIR)/cdc -xvzf $(PHONEME_ADVANCED_SOURCE_DIR)/linux-$(PHONEME_ADVANCED_ARCH).tar.gz
endif
ifeq ($(OPTWARE_TARGET),slugosbe)
	tar -C $(PHONEME_ADVANCED_BUILD_DIR)/cdc/src/linux-arm -xvzf $(PHONEME_ADVANCED_SOURCE_DIR)/slugosbe-missing-asm-ucontext-h.tar.gz
endif
	[ -e $(PHONEME_ADVANCED_SOURCE_DIR)/GNUmakefile.$(PHONEME_ADVANCED_ARCH) ] && \
	cp $(PHONEME_ADVANCED_SOURCE_DIR)/GNUmakefile.$(PHONEME_ADVANCED_ARCH) $(PHONEME_ADVANCED_CDC_BUILD_DIR)/GNUmakefile || \
	cp $(PHONEME_ADVANCED_SOURCE_DIR)/GNUmakefile $(PHONEME_ADVANCED_CDC_BUILD_DIR)
	touch $@

phoneme-advanced-unpack: $(PHONEME_ADVANCED_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PHONEME_ADVANCED_BUILD_DIR)/.built: $(PHONEME_ADVANCED_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(PHONEME_ADVANCED_CDC_BUILD_DIR) bin \
		USE_VERBOSE_MAKE=true \
		TOOLS_DIR=$(PHONEME_ADVANCED_BUILD_DIR)/tools \
		J2ME_CLASSLIB=foundation \
		CVM_TARGET_TOOLS_PREFIX=$(TARGET_CROSS) \
		$(PHONEME_ADVANCED_MAKE_OPTIONS) \
		JAVAME_LEGAL_DIR=$(PHONEME_ADVANCED_BUILD_DIR)/legal \
		BINARY_BUNDLE_NAME=phoneme-advanced \
		BINARY_BUNDLE_APPEND_REVISION=false \
		;
	touch $@

#
# This is the build convenience target.
#
phoneme-advanced: $(PHONEME_ADVANCED_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(PHONEME_ADVANCED_BUILD_DIR)/.staged: $(PHONEME_ADVANCED_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(PHONEME_ADVANCED_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

phoneme-advanced-stage: $(PHONEME_ADVANCED_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/phoneme-advanced
#
$(PHONEME_ADVANCED_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: phoneme-advanced" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PHONEME_ADVANCED_PRIORITY)" >>$@
	@echo "Section: $(PHONEME_ADVANCED_SECTION)" >>$@
	@echo "Version: $(PHONEME_ADVANCED_VERSION)-$(PHONEME_ADVANCED_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PHONEME_ADVANCED_MAINTAINER)" >>$@
	@echo "Source: $(PHONEME_ADVANCED_SITE)/$(PHONEME_ADVANCED_SOURCE)" >>$@
	@echo "Description: $(PHONEME_ADVANCED_DESCRIPTION)" >>$@
	@echo "Depends: $(PHONEME_ADVANCED_DEPENDS)" >>$@
	@echo "Suggests: $(PHONEME_ADVANCED_SUGGESTS)" >>$@
	@echo "Conflicts: $(PHONEME_ADVANCED_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(PHONEME_ADVANCED_IPK_DIR)/opt/sbin or $(PHONEME_ADVANCED_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(PHONEME_ADVANCED_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(PHONEME_ADVANCED_IPK_DIR)/opt/etc/phoneme-advanced/...
# Documentation files should be installed in $(PHONEME_ADVANCED_IPK_DIR)/opt/doc/phoneme-advanced/...
# Daemon startup scripts should be installed in $(PHONEME_ADVANCED_IPK_DIR)/opt/etc/init.d/S??phoneme-advanced
#
# You may need to patch your application to make it use these locations.
#
$(PHONEME_ADVANCED_IPK): $(PHONEME_ADVANCED_BUILD_DIR)/.built
	rm -rf $(PHONEME_ADVANCED_IPK_DIR) $(BUILD_DIR)/phoneme-advanced_*_$(TARGET_ARCH).ipk
	install -d $(PHONEME_ADVANCED_IPK_DIR)/opt/lib/java
	cd $(PHONEME_ADVANCED_IPK_DIR)/opt/lib/java && \
	unzip $(PHONEME_ADVANCED_BUILD_DIR)/cdc/install/phoneme-advanced.zip
	$(STRIP_COMMAND) $(PHONEME_ADVANCED_IPK_DIR)/opt/lib/java/phoneme-advanced/bin/cvm
	install -d $(PHONEME_ADVANCED_IPK_DIR)/opt/bin
	cd $(PHONEME_ADVANCED_IPK_DIR)/opt/bin; ln -s ../lib/java/phoneme-advanced/bin/cvm .
	$(MAKE) $(PHONEME_ADVANCED_IPK_DIR)/CONTROL/control
	echo $(PHONEME_ADVANCED_CONFFILES) | sed -e 's/ /\n/g' > $(PHONEME_ADVANCED_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PHONEME_ADVANCED_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
phoneme-advanced-ipk: $(PHONEME_ADVANCED_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
phoneme-advanced-clean:
	rm -f $(PHONEME_ADVANCED_BUILD_DIR)/.built
	-$(MAKE) -C $(PHONEME_ADVANCED_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
phoneme-advanced-dirclean:
	rm -rf $(BUILD_DIR)/$(PHONEME_ADVANCED_DIR) $(PHONEME_ADVANCED_BUILD_DIR) $(PHONEME_ADVANCED_IPK_DIR) $(PHONEME_ADVANCED_IPK)
#
#
# Some sanity check for the package.
#
phoneme-advanced-check: $(PHONEME_ADVANCED_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(PHONEME_ADVANCED_IPK)
