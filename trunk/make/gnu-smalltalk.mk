###########################################################
#
# gnu-smalltalk
#
###########################################################
#
# GNU_SMALLTALK_VERSION, GNU_SMALLTALK_SITE and GNU_SMALLTALK_SOURCE define
# the upstream location of the source code for the package.
# GNU_SMALLTALK_DIR is the directory which is created when the source
# archive is unpacked.
# GNU_SMALLTALK_UNZIP is the command used to unzip the source.
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
GNU_SMALLTALK_SITE=ftp://ftp.gnu.org/gnu/smalltalk
GNU_SMALLTALK_VERSION=2.3.5
GNU_SMALLTALK_SOURCE=smalltalk-$(GNU_SMALLTALK_VERSION).tar.gz
GNU_SMALLTALK_DIR=smalltalk-$(GNU_SMALLTALK_VERSION)
GNU_SMALLTALK_UNZIP=zcat
GNU_SMALLTALK_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
GNU_SMALLTALK_DESCRIPTION=GNU Smalltalk is a free implementation of the Smalltalk-80 language.
GNU_SMALLTALK_SECTION=lang
GNU_SMALLTALK_PRIORITY=optional
GNU_SMALLTALK_DEPENDS=libgmp # , libsigsegv
GNU_SMALLTALK_SUGGESTS=gdbm, zlib
GNU_SMALLTALK_CONFLICTS=

#
# GNU_SMALLTALK_IPK_VERSION should be incremented when the ipk changes.
#
GNU_SMALLTALK_IPK_VERSION=1

#
# GNU_SMALLTALK_CONFFILES should be a list of user-editable files
#GNU_SMALLTALK_CONFFILES=/opt/etc/gnu-smalltalk.conf /opt/etc/init.d/SXXgnu-smalltalk

#
# GNU_SMALLTALK_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
GNU_SMALLTALK_PATCHES=
ifneq ($(HOSTCC), $(TARGET_CC))
GNU_SMALLTALK_PATCHES+=$(GNU_SMALLTALK_SOURCE_DIR)/hostbuilddir.patch
endif

ifeq ($(TARGET_ARCH), armeb)
ifeq ($(LIBC_STYLE), glibc)
ifneq ($(OPTWARE_TARGET), slugosbe)
GNU_SMALLTALK_PATCHES+=$(GNU_SMALLTALK_SOURCE_DIR)/mmap.patch
endif
endif
endif

ifeq ($(OPTWARE_TARGET), $(filter oleg ddwrt, $(OPTWARE_TARGET)))
GNU_SMALLTALK_PATCHES+=$(GNU_SMALLTALK_SOURCE_DIR)/static-def.patch
endif

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GNU_SMALLTALK_CPPFLAGS=
ifeq ($(OPTWARE_TARGET), $(filter oleg ddwrt, $(OPTWARE_TARGET)))
GNU_SMALLTALK_CPPFLAGS+=-D__error_t_defined=1
endif
GNU_SMALLTALK_LDFLAGS=

#
# GNU_SMALLTALK_BUILD_DIR is the directory in which the build is done.
# GNU_SMALLTALK_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GNU_SMALLTALK_IPK_DIR is the directory in which the ipk is built.
# GNU_SMALLTALK_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GNU_SMALLTALK_SOURCE_DIR=$(SOURCE_DIR)/gnu-smalltalk
GNU_SMALLTALK_BUILD_DIR=$(BUILD_DIR)/gnu-smalltalk
GNU_SMALLTALK_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/gnu-smalltalk

GNU_SMALLTALK_IPK_DIR=$(BUILD_DIR)/gnu-smalltalk-$(GNU_SMALLTALK_VERSION)-ipk
GNU_SMALLTALK_IPK=$(BUILD_DIR)/gnu-smalltalk_$(GNU_SMALLTALK_VERSION)-$(GNU_SMALLTALK_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: gnu-smalltalk-source gnu-smalltalk-unpack gnu-smalltalk gnu-smalltalk-stage gnu-smalltalk-ipk gnu-smalltalk-clean gnu-smalltalk-dirclean gnu-smalltalk-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GNU_SMALLTALK_SOURCE):
	$(WGET) -P $(DL_DIR) $(GNU_SMALLTALK_SITE)/$(GNU_SMALLTALK_SOURCE) || \
	$(WGET) -P $(DL_DIR) $(SOURCES_NLO_SITE)/$(GNU_SMALLTALK_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gnu-smalltalk-source: $(DL_DIR)/$(GNU_SMALLTALK_SOURCE) $(GNU_SMALLTALK_PATCHES)

$(GNU_SMALLTALK_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(GNU_SMALLTALK_SOURCE) #make/gnu-smalltalk.mk
	rm -f $@
	rm -rf $(HOST_BUILD_DIR)/$(GNU_SMALLTALK_DIR) $(GNU_SMALLTALK_BUILD_DIR)
	$(GNU_SMALLTALK_UNZIP) $(DL_DIR)/$(GNU_SMALLTALK_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	if test "$(HOST_BUILD_DIR)/$(GNU_SMALLTALK_DIR)" != "$(GNU_SMALLTALK_HOST_BUILD_DIR)" ; \
		then mv $(HOST_BUILD_DIR)/$(GNU_SMALLTALK_DIR) $(GNU_SMALLTALK_HOST_BUILD_DIR) ; \
	fi
	(cd $(GNU_SMALLTALK_HOST_BUILD_DIR); \
		./configure \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
	)
	$(MAKE) -C $(GNU_SMALLTALK_HOST_BUILD_DIR)
	touch $@

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
ifeq ($(HOSTCC), $(TARGET_CC))
$(GNU_SMALLTALK_BUILD_DIR)/.configured: $(DL_DIR)/$(GNU_SMALLTALK_SOURCE) $(GNU_SMALLTALK_PATCHES) make/gnu-smalltalk.mk
else
$(GNU_SMALLTALK_BUILD_DIR)/.configured: $(GNU_SMALLTALK_HOST_BUILD_DIR)/.built $(GNU_SMALLTALK_PATCHES)
endif
	$(MAKE) libgmp-stage
#	$(MAKE) libsigsegv-stage
#	$(MAKE) readline-stage
	$(MAKE) gdbm-stage
	$(MAKE) zlib-stage
	rm -rf $(BUILD_DIR)/$(GNU_SMALLTALK_DIR) $(GNU_SMALLTALK_BUILD_DIR)
	$(GNU_SMALLTALK_UNZIP) $(DL_DIR)/$(GNU_SMALLTALK_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(GNU_SMALLTALK_PATCHES)" ; \
		then cat $(GNU_SMALLTALK_PATCHES) | \
		patch -d $(BUILD_DIR)/$(GNU_SMALLTALK_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(GNU_SMALLTALK_DIR)" != "$(GNU_SMALLTALK_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(GNU_SMALLTALK_DIR) $(GNU_SMALLTALK_BUILD_DIR) ; \
	fi
#		gst_cv_readline_libs="-lreadline -ltermcap"
	(cd $(GNU_SMALLTALK_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(GNU_SMALLTALK_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GNU_SMALLTALK_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--disable-nls \
		--disable-static \
		--disable-gtk \
		--without-emacs \
		--without-readline \
		--without-tcl \
		--without-tk \
	)
#	sed -i -e 's/ sigsegv//' $(GNU_SMALLTALK_BUILD_DIR)/Makefile
	$(PATCH_LIBTOOL) $(GNU_SMALLTALK_BUILD_DIR)/libtool
	touch $@

gnu-smalltalk-unpack: $(GNU_SMALLTALK_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(GNU_SMALLTALK_BUILD_DIR)/.built: $(GNU_SMALLTALK_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(GNU_SMALLTALK_BUILD_DIR) GNU_SMALLTALK_HOST_BUILD_DIR=$(GNU_SMALLTALK_HOST_BUILD_DIR)
	touch $@

#
# This is the build convenience target.
#
gnu-smalltalk: $(GNU_SMALLTALK_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(GNU_SMALLTALK_BUILD_DIR)/.staged: $(GNU_SMALLTALK_BUILD_DIR)/.built
	rm -f $@
#	$(MAKE) -C $(GNU_SMALLTALK_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $@

gnu-smalltalk-stage: $(GNU_SMALLTALK_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gnu-smalltalk
#
$(GNU_SMALLTALK_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: gnu-smalltalk" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GNU_SMALLTALK_PRIORITY)" >>$@
	@echo "Section: $(GNU_SMALLTALK_SECTION)" >>$@
	@echo "Version: $(GNU_SMALLTALK_VERSION)-$(GNU_SMALLTALK_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GNU_SMALLTALK_MAINTAINER)" >>$@
	@echo "Source: $(GNU_SMALLTALK_SITE)/$(GNU_SMALLTALK_SOURCE)" >>$@
	@echo "Description: $(GNU_SMALLTALK_DESCRIPTION)" >>$@
	@echo "Depends: $(GNU_SMALLTALK_DEPENDS)" >>$@
	@echo "Suggests: $(GNU_SMALLTALK_SUGGESTS)" >>$@
	@echo "Conflicts: $(GNU_SMALLTALK_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GNU_SMALLTALK_IPK_DIR)/opt/sbin or $(GNU_SMALLTALK_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GNU_SMALLTALK_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(GNU_SMALLTALK_IPK_DIR)/opt/etc/gnu-smalltalk/...
# Documentation files should be installed in $(GNU_SMALLTALK_IPK_DIR)/opt/doc/gnu-smalltalk/...
# Daemon startup scripts should be installed in $(GNU_SMALLTALK_IPK_DIR)/opt/etc/init.d/S??gnu-smalltalk
#
# You may need to patch your application to make it use these locations.
#
$(GNU_SMALLTALK_IPK): $(GNU_SMALLTALK_BUILD_DIR)/.built
	rm -rf $(GNU_SMALLTALK_IPK_DIR) $(BUILD_DIR)/gnu-smalltalk_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GNU_SMALLTALK_BUILD_DIR) install-strip \
		DESTDIR=$(GNU_SMALLTALK_IPK_DIR) \
		GNU_SMALLTALK_HOST_BUILD_DIR=$(GNU_SMALLTALK_HOST_BUILD_DIR)
	rm -f $(GNU_SMALLTALK_IPK_DIR)/opt/lib/smalltalk/*.la
#	rm -f $(GNU_SMALLTALK_IPK_DIR)/opt/lib/libsigsegv*
#	rm -f $(GNU_SMALLTALK_IPK_DIR)/opt/include/sigsegv*
	chmod go+w $(GNU_SMALLTALK_IPK_DIR)/opt/share/smalltalk/gst.im
	$(MAKE) $(GNU_SMALLTALK_IPK_DIR)/CONTROL/control
#	install -m 755 $(GNU_SMALLTALK_SOURCE_DIR)/postinst $(GNU_SMALLTALK_IPK_DIR)/CONTROL/postinst
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNU_SMALLTALK_IPK_DIR)/CONTROL/postinst
#	install -m 755 $(GNU_SMALLTALK_SOURCE_DIR)/prerm $(GNU_SMALLTALK_IPK_DIR)/CONTROL/prerm
#	sed -i -e '/^#!/aOPTWARE_TARGET=${OPTWARE_TARGET}' $(GNU_SMALLTALK_IPK_DIR)/CONTROL/prerm
	echo $(GNU_SMALLTALK_CONFFILES) | sed -e 's/ /\n/g' > $(GNU_SMALLTALK_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GNU_SMALLTALK_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gnu-smalltalk-ipk: $(GNU_SMALLTALK_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gnu-smalltalk-clean:
	rm -f $(GNU_SMALLTALK_BUILD_DIR)/.built
	-$(MAKE) -C $(GNU_SMALLTALK_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gnu-smalltalk-dirclean:
	rm -rf $(BUILD_DIR)/$(GNU_SMALLTALK_DIR) $(GNU_SMALLTALK_BUILD_DIR) $(GNU_SMALLTALK_IPK_DIR) $(GNU_SMALLTALK_IPK)
#
#
# Some sanity check for the package.
#
gnu-smalltalk-check: $(GNU_SMALLTALK_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GNU_SMALLTALK_IPK)
