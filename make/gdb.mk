###########################################################
#
# gdb
#
###########################################################

# You must replace "gdb" and "GDB" with the lower case name and
# upper case name of your new package.  Some places below will say
# "Do not change this" - that does not include this global change,
# which must always be done to ensure we have unique names.

#
# GDB_VERSION, GDB_SITE and GDB_SOURCE define
# the upstream location of the source code for the package.
# GDB_DIR is the directory which is created when the source
# archive is unpacked.
# GDB_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
GDB_SITE=http://ftp.gnu.org/gnu/gdb
GDB_VERSION=8.0.1
GDB_IPK_VERSION=2
GDB_SOURCE=gdb-$(GDB_VERSION).tar.xz
GDB_UNZIP=xzcat
GDB_DIR=gdb-$(GDB_VERSION)
GDB_MAINTAINER=Steve Henson <snhenson@gmail.com>
GDB_DESCRIPTION=gdb is the standard GNU debugger
GDB_SECTION=utility
GDB_PRIORITY=optional
GDB_DEPENDS=termcap, ncurses, expat, liblzma0
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
GDB_DEPENDS+=, libiconv
endif
GDB_CONFLICTS=


#
# GDB_CONFFILES should be a list of user-editable files
# GDB_CONFFILES=$(TARGET_PREFIX)/etc/gdb.conf $(TARGET_PREFIX)/etc/init.d/SXXgdb

#
# GDB_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
# GDB_PATCHES=$(GDB_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
GDB_CPPFLAGS=
# Note: added -s in here to strip binaries.
#
GDB_LDFLAGS=-s -lpthread -lm

#
# GDB_BUILD_DIR is the directory in which the build is done.
# GDB_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# GDB_IPK_DIR is the directory in which the ipk is built.
# GDB_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
GDB_BUILD_DIR=$(BUILD_DIR)/gdb
GDB_SOURCE_DIR=$(SOURCE_DIR)/gdb
GDB_IPK_DIR=$(BUILD_DIR)/gdb-$(GDB_VERSION)-ipk
GDB_IPK=$(BUILD_DIR)/gdb_$(GDB_VERSION)-$(GDB_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(GDB_SOURCE):
	$(WGET) -P $(DL_DIR) $(GDB_SITE)/$(GDB_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
gdb-source: $(DL_DIR)/$(GDB_SOURCE) $(GDB_PATCHES)

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

#
# Note: there is a problem with TUI in that some parts of the configuration
# can correctly detect the presence of ncurses while the actual compilation
# doesn't find the ncurses.h header file. Workaround is to disable TUI.
# 

$(GDB_BUILD_DIR)/.configured: $(DL_DIR)/$(GDB_SOURCE) $(GDB_PATCHES) make/gdb.mk
	$(MAKE) termcap-stage expat-stage ncurses-stage xz-utils-stage
ifeq (libiconv, $(filter libiconv, $(PACKAGES)))
	$(MAKE) libiconv-stage
endif
	rm -rf $(BUILD_DIR)/$(GDB_DIR) $(@D)
	$(GDB_UNZIP) $(DL_DIR)/$(GDB_SOURCE) | tar -C $(BUILD_DIR) -xvf -
#	cat $(GDB_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(GDB_DIR) -p1
	mv $(BUILD_DIR)/$(GDB_DIR) $(@D)
	for f in `find $(@D) -name config.rpath`; do \
		sed -i.orig -e 's|^hardcode_libdir_flag_spec=.*"$$|hardcode_libdir_flag_spec=""|' $$f; \
	done
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="`echo '$(STAGING_CPPFLAGS) $(GDB_CPPFLAGS)' | sed 's/  */ /g'`" \
		CFLAGS="-std=gnu89" \
		LDFLAGS="$(STAGING_LDFLAGS) $(GDB_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-tui \
	)
ifeq ($(OPTWARE_TARGET), $(filter ct-ng-ppc-e500v2, $(OPTWARE_TARGET)))
	# some strange bug: this is done automatically for other targets
	mkdir -p $(@D)/sim/ppc/build
	(cd $(@D)/sim/ppc/build; \
		../configure \
	)
	mv -f $(@D)/sim/ppc/build/config.h $(@D)/sim/ppc/build-config.h
	rm -rf $(@D)/sim/ppc/build
endif
	touch $@

gdb-unpack: $(GDB_BUILD_DIR)/.configured

#
# This builds the actual binary.
#

#
# Note: but various defines in here that will be picked up
# by the extra configure scripts called when gdb is compiled.
# Normally these are guessed at when cross compiling.
#
# Also need to pass in LDFLAGS and CPPFLAGS
#

$(GDB_BUILD_DIR)/.built: $(GDB_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D) \
	ac_cv_func_fork_works=yes \
	bash_cv_func_sigsetjmp=present \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_strcoll_broken=no \
	bash_cv_have_mbstate_t=yes \
	CPPFLAGS="`echo '$(STAGING_CPPFLAGS) $(GDB_CPPFLAGS)' | sed 's/  */ /g'`" \
	PROFILE_CFLAGS="$(STAGING_CPPFLAGS) $(GDB_CPPFLAGS)" \
	LDFLAGS="$(STAGING_LDFLAGS) $(GDB_LDFLAGS)" 
	touch $@

#
# This is the build convenience target.
#
gdb: $(GDB_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(GDB_BUILD_DIR)/.staged: $(GDB_BUILD_DIR)/.built
#	rm -f $(GDB_BUILD_DIR)/.staged
#	$(MAKE) -C $(GDB_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
#	touch $(GDB_BUILD_DIR)/.staged

#gdb-stage: $(GDB_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/gdb
#
$(GDB_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: gdb" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(GDB_PRIORITY)" >>$@
	@echo "Section: $(GDB_SECTION)" >>$@
	@echo "Version: $(GDB_VERSION)-$(GDB_IPK_VERSION)" >>$@
	@echo "Maintainer: $(GDB_MAINTAINER)" >>$@
	@echo "Source: $(GDB_SITE)/$(GDB_SOURCE)" >>$@
	@echo "Description: $(GDB_DESCRIPTION)" >>$@
	@echo "Depends: $(GDB_DEPENDS)" >>$@
	@echo "Conflicts: $(GDB_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(GDB_IPK_DIR)$(TARGET_PREFIX)/sbin or $(GDB_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(GDB_IPK_DIR)$(TARGET_PREFIX)/{lib,include}
# Configuration files should be installed in $(GDB_IPK_DIR)$(TARGET_PREFIX)/etc/gdb/...
# Documentation files should be installed in $(GDB_IPK_DIR)$(TARGET_PREFIX)/doc/gdb/...
# Daemon startup scripts should be installed in $(GDB_IPK_DIR)$(TARGET_PREFIX)/etc/init.d/S??gdb
#
# You may need to patch your application to make it use these locations.
#

#
# Note: passing DESTDIR to make install doesn't end up being passed to all
# subdirectories but passing prefix instead seems to work.
# Deleted standards.info because its not GDB specific and can conflict with
# other packages that install it.
#


$(GDB_IPK): $(GDB_BUILD_DIR)/.built
	ls -la $(GDB_BUILD_DIR)/.built
	rm -rf $(GDB_IPK_DIR) $(BUILD_DIR)/gdb_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(GDB_BUILD_DIR) prefix=$(GDB_IPK_DIR)$(TARGET_PREFIX) install
	rm -f $(GDB_IPK_DIR)$(TARGET_PREFIX)/info/standards.info \
		$(GDB_IPK_DIR)$(TARGET_PREFIX)/include/plugin-api.h
	-$(STRIP_COMMAND) $(GDB_IPK_DIR)$(TARGET_PREFIX)/bin/run
	# rm the following files to avoid conflict with binutils
	for f in \
		$(TARGET_PREFIX)/include/ansidecl.h \
		$(TARGET_PREFIX)/include/bfd.h \
		$(TARGET_PREFIX)/include/bfdlink.h \
		$(TARGET_PREFIX)/include/dis-asm.h \
		$(TARGET_PREFIX)/plugin-api.h \
		$(TARGET_PREFIX)/include/symcat.h \
		$(TARGET_PREFIX)/info/bfd.info \
		$(TARGET_PREFIX)/share/info/bfd.info \
		$(TARGET_PREFIX)/info/configure.info \
		$(TARGET_PREFIX)/share/info/configure.info \
		$(TARGET_PREFIX)/lib/libbfd.a \
		$(TARGET_PREFIX)/lib/libbfd.la \
		$(TARGET_PREFIX)/lib/libiberty.a \
		$(TARGET_PREFIX)/lib/libopcodes.a \
		$(TARGET_PREFIX)/lib/libopcodes.la \
		; \
	do rm -f $(GDB_IPK_DIR)/$$f; done
	rm -f $(GDB_IPK_DIR)$(TARGET_PREFIX)/share/info/dir
	$(MAKE) $(GDB_IPK_DIR)/CONTROL/control
#	$(INSTALL) -m 644 $(GDB_SOURCE_DIR)/postinst $(GDB_IPK_DIR)/CONTROL/postinst
#	$(INSTALL) -m 644 $(GDB_SOURCE_DIR)/prerm $(GDB_IPK_DIR)/CONTROL/prerm
#	echo $(GDB_CONFFILES) | sed -e 's/ /\n/g' > $(GDB_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(GDB_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
gdb-ipk: $(GDB_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
gdb-clean:
	-$(MAKE) -C $(GDB_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
gdb-dirclean:
	rm -rf $(BUILD_DIR)/$(GDB_DIR) $(GDB_BUILD_DIR) $(GDB_IPK_DIR) $(GDB_IPK)

#
# Some sanity check for the package.
#
gdb-check: $(GDB_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(GDB_IPK)
