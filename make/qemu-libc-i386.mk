###########################################################
#
# qemu-libc-i386
#
###########################################################
#
QEMU_LIBC_I386_SITE=http://kegel.com/crosstool
QEMU_LIBC_I386_VERSION=$(QEMU_LIBC_I386_GLIBC_VERSION)
QEMU_LIBC_I386_CROSSTOOL_VERSION=0.43
QEMU_LIBC_I386_SOURCE=crosstool-$(QEMU_LIBC_I386_CROSSTOOL_VERSION).tar.gz
QEMU_LIBC_I386_DIR=crosstool-$(QEMU_LIBC_I386_CROSSTOOL_VERSION)
QEMU_LIBC_I386_UNZIP=zcat
QEMU_LIBC_I386_MAINTAINER=Josh Parsons <jbparsons@ucdavis.edu>
QEMU_LIBC_I386_DESCRIPTION=GNU/linux i386 libraries for use with qemu
QEMU_LIBC_I386_SECTION=misc
QEMU_LIBC_I386_PRIORITY=optional
QEMU_LIBC_I386_DEPENDS=qemu-user
QEMU_LIBC_I386_SUGGESTS=
QEMU_LIBC_I386_CONFLICTS=qemu-gnemul

#
# The variables below control the way we use crosstool.
# They are pretty standard, except that it important not to use a linux
# kernel newer than 2.4.19.  Newer kernels cause glibc to call the 
# exit_group syscall, which is not available in qemu/unslung.
#
QEMU_LIBC_I386_GCC_VERSION=3.4.5
QEMU_LIBC_I386_GLIBC_VERSION=2.3.6
QEMU_LIBC_I386_BINUTILS_VERSION=2.16.1
QEMU_LIBC_I386_LINUX_VERSION=2.4.19
QEMU_LIBC_I386_TARGET=i386-unknown-linux-gnu

QEMU_LIBC_I386_CROSS_CONFIGURATION=gcc-$(QEMU_LIBC_I386_GCC_VERSION)-glibc-$(QEMU_LIBC_I386_GLIBC_VERSION)
QEMU_LIBC_I386_RESULT_TOP=$(QEMU_LIBC_I386_BUILD_DIR)/result
QEMU_LIBC_I386_PREFIX=$(QEMU_LIBC_I386_RESULT_TOP)/$(QEMU_LIBC_I386_TARGET)/$(QEMU_LIBC_I386_CROSS_CONFIGURATION)

#
# QEMU_LIBC_I386_IPK_VERSION should be incremented when the ipk changes.
#
QEMU_LIBC_I386_IPK_VERSION=1

#
# QEMU_LIBC_I386_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
#QEMU_LIBC_I386_PATCHES=$(QEMU_LIBC_I386_SOURCE_DIR)/configure.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
QEMU_LIBC_I386_CPPFLAGS=
QEMU_LIBC_I386_LDFLAGS=

#
# QEMU_LIBC_I386_BUILD_DIR is the directory in which the build is done.
# QEMU_LIBC_I386_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# QEMU_LIBC_I386_IPK_DIR is the directory in which the ipk is built.
# QEMU_LIBC_I386_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
QEMU_LIBC_I386_BUILD_DIR=$(HOST_BUILD_DIR)/qemu-libc-i386
QEMU_LIBC_I386_SOURCE_DIR=$(SOURCE_DIR)/qemu-libc-i386
QEMU_LIBC_I386_IPK_DIR=$(BUILD_DIR)/qemu-libc-i386-$(QEMU_LIBC_I386_VERSION)-ipk
QEMU_LIBC_I386_IPK=$(BUILD_DIR)/qemu-libc-i386_$(QEMU_LIBC_I386_VERSION)-$(QEMU_LIBC_I386_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
#$(DL_DIR)/$(QEMU_LIBC_I386_SOURCE):
#	$(WGET) -P $(DL_DIR) $(QEMU_LIBC_I386_SITE)/$(QEMU_LIBC_I386_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
qemu-libc-i386-source: $(DL_DIR)/$(QEMU_LIBC_I386_SOURCE) $(QEMU_LIBC_I386_PATCHES)

#
# This target unpacks the source code in the build directory.
#
$(QEMU_LIBC_I386_BUILD_DIR)/.configured: host/.configured $(DL_DIR)/$(QEMU_LIBC_I386_SOURCE) $(QEMU_LIBC_I386_PATCHES)
	rm -rf $(BUILD_DIR)/$(QEMU_LIBC_I386_DIR) $(QEMU_LIBC_I386_BUILD_DIR)
	$(QEMU_LIBC_I386_UNZIP) $(DL_DIR)/$(QEMU_LIBC_I386_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(QEMU_LIBC_I386_DIR) $(QEMU_LIBC_I386_BUILD_DIR)
	touch $@

qemu-libc-i386-unpack: $(QEMU_LIBC_I386_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(QEMU_LIBC_I386_BUILD_DIR)/.built: $(QEMU_LIBC_I386_BUILD_DIR)/.configured
	rm -f $@
	( cd $(QEMU_LIBC_I386_BUILD_DIR) ; \
		mkdir -p $(QEMU_LIBC_I386_RESULT_TOP) ; \
		TARBALLS_DIR=$(DL_DIR) \
		GCC_LANGUAGES="c,c++" \
		RESULT_TOP=$(QEMU_LIBC_I386_RESULT_TOP) \
		PREFIX=$(QEMU_LIBC_I386_PREFIX) \
		TARGET=$(QEMU_LIBC_I386_TARGET) \
		TARGET_CFLAGS=-O1 \
		BINUTILS_DIR=binutils-$(QEMU_LIBC_I386_BINUTILS_VERSION) \
		GCC_DIR=gcc-$(QEMU_LIBC_I386_GCC_VERSION) \
		GLIBC_DIR=glibc-$(QEMU_LIBC_I386_GLIBC_VERSION) \
		GLIBCTHREADS_FILENAME=glibc-linuxthreads-$(QEMU_LIBC_I386_GLIBC_VERSION) \
		LINUX_DIR=linux-$(QEMU_LIBC_I386_LINUX_VERSION) \
		sh all.sh --notest \
	)
	touch $@

#
# This is the build convenience target.
#
qemu-libc-i386: $(QEMU_LIBC_I386_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/qemu-libc-i386
#
$(QEMU_LIBC_I386_IPK_DIR)/CONTROL/control:
	@install -d $(QEMU_LIBC_I386_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: qemu-libc-i386" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(QEMU_LIBC_I386_PRIORITY)" >>$@
	@echo "Section: $(QEMU_LIBC_I386_SECTION)" >>$@
	@echo "Version: $(QEMU_LIBC_I386_VERSION)-$(QEMU_LIBC_I386_IPK_VERSION)" >>$@
	@echo "Maintainer: $(QEMU_LIBC_I386_MAINTAINER)" >>$@
	@echo "Source: $(QEMU_LIBC_I386_SITE)/$(QEMU_LIBC_I386_SOURCE)" >>$@
	@echo "Description: $(QEMU_LIBC_I386_DESCRIPTION)" >>$@
	@echo "Depends: $(QEMU_LIBC_I386_DEPENDS)" >>$@
	@echo "Suggests: $(QEMU_LIBC_I386_SUGGESTS)" >>$@
	@echo "Conflicts: $(QEMU_LIBC_I386_CONFLICTS)" >>$@

$(QEMU_LIBC_I386_IPK_DIR)/CONTROL/postinst:
	@install -d $(QEMU_LIBC_I386_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "#!/bin/sh" >>$@
	@echo "mkdir -p /opt/$(QEMU_LIBC_I386_TARGET)/etc" >>$@
	@echo "test -e /opt/$(QEMU_LIBC_I386_TARGET)/etc/ld.so.cache || /opt/bin/qemu-i386 /opt/$(QEMU_LIBC_I386_TARGET)/sbin/ldconfig -C /opt/$(QEMU_LIBC_I386_TARGET)/etc/ld.so.cache" >>$@

#
# This builds the IPK file.
#
$(QEMU_LIBC_I386_IPK): $(QEMU_LIBC_I386_BUILD_DIR)/.built
	rm -rf $(QEMU_LIBC_I386_IPK_DIR) $(BUILD_DIR)/qemu-libc-i386_*_$(TARGET_ARCH).ipk
	$(MAKE) $(QEMU_LIBC_I386_IPK_DIR)/CONTROL/control
	$(MAKE) $(QEMU_LIBC_I386_IPK_DIR)/CONTROL/postinst
	mkdir -p $(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/lib
	cp -a $(QEMU_LIBC_I386_PREFIX)/$(QEMU_LIBC_I386_TARGET)/lib/*.so.* \
		$(QEMU_LIBC_I386_PREFIX)/$(QEMU_LIBC_I386_TARGET)/lib/*.so \
		$(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/lib
	rm -rf $(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/lib/*.dir
	( cd $(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/lib ; \
		for F in *.so *.so.* ; \
		do if test -x $$F ; then \
		$(QEMU_LIBC_I386_PREFIX)/bin/$(QEMU_LIBC_I386_TARGET)-strip \
			$$F ; \
		fi ; done ; \
	)
	mkdir -p $(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/sbin
	$(QEMU_LIBC_I386_PREFIX)/bin/$(QEMU_LIBC_I386_TARGET)-strip \
		$(QEMU_LIBC_I386_PREFIX)/$(QEMU_LIBC_I386_TARGET)/sbin/ldconfig \
		-o $(QEMU_LIBC_I386_IPK_DIR)/opt/$(QEMU_LIBC_I386_TARGET)/sbin/ldconfig
	mkdir -p $(QEMU_LIBC_I386_IPK_DIR)/opt/lib/gnemul
	ln -s ../../$(QEMU_LIBC_I386_TARGET) \
		$(QEMU_LIBC_I386_IPK_DIR)/opt/lib/gnemul/qemu-i386
	chmod a+rX -R $(QEMU_LIBC_I386_IPK_DIR)/opt
	cd $(BUILD_DIR); $(IPKG_BUILD) $(QEMU_LIBC_I386_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
qemu-libc-i386-ipk: $(QEMU_LIBC_I386_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
qemu-libc-i386-clean:
	rm -f $(QEMU_LIBC_I386_BUILD_DIR)/.built
	-$(MAKE) -C $(QEMU_LIBC_I386_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
qemu-libc-i386-dirclean:
	rm -rf $(BUILD_DIR)/$(QEMU_LIBC_I386_DIR) $(QEMU_LIBC_I386_BUILD_DIR) $(QEMU_LIBC_I386_IPK_DIR) $(QEMU_LIBC_I386_IPK)
