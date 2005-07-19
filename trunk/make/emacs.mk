###########################################################
#
# emacs
#
###########################################################

#
# <FOO>_VERSION, <FOO>_SITE and <FOO>_SOURCE define
# the upstream location of the source code for the package.
# <FOO>_DIR is the directory which is created when the source
# archive is unpacked.
# <FOO>_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
#
EMACS_SITE=http://ftp.gnu.org/gnu/emacs
EMACS_VERSION=21.3
EMACS_SOURCE=emacs-$(EMACS_VERSION).tar.gz
EMACS_DIR=emacs-$(EMACS_VERSION)
EMACS_UNZIP=zcat
EMACS_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
EMACS_DESCRIPTION=Extensible, real-time editor
EMACS_SECTION=util
EMACS_PRIORITY=optional
EMACS_DEPENDS=ncurses, xaw, xmu, libpng, libjpeg, libtiff
EMACS_SUGGESTS=
EMACS_CONFLICTS=

#
# EMACS_IPK_VERSION should be incremented when the ipk changes.
#
EMACS_IPK_VERSION=5

#
# EMACS_CONFFILES should be a list of user-editable files
#EMACS_CONFFILES=/opt/etc/emacs.conf /opt/etc/init.d/SXXemacs

#
# EMACS_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
EMACS_PATCHES=#$(EMACS_SOURCE_DIR)/dont-dump.patch

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
ifeq ($(HOST_MACHINE),armv5b)
EMACS_CPPFLAGS=
EMACS_LDFLAGS=
else
EMACS_CPPFLAGS=-DCANNOT_DUMP
EMACS_LDFLAGS=
endif

#
# EMACS_BUILD_DIR is the directory in which the build is done.
# EMACS_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# EMACS_IPK_DIR is the directory in which the ipk is built.
# EMACS_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
EMACS_BUILD_DIR=$(BUILD_DIR)/emacs
EMACS_SOURCE_DIR=$(SOURCE_DIR)/emacs
EMACS_IPK_DIR=$(BUILD_DIR)/emacs-$(EMACS_VERSION)-ipk
EMACS_IPK=$(BUILD_DIR)/emacs_$(EMACS_VERSION)-$(EMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

EMACS_LISP_IPK_DIR=$(BUILD_DIR)/emacs-lisp-$(EMACS_VERSION)-ipk
EMACS_LISP_IPK=$(BUILD_DIR)/emacs-lisp_$(EMACS_VERSION)-$(EMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

EMACS_LISP_SRC_IPK_DIR=$(BUILD_DIR)/emacs-lisp-src-$(EMACS_VERSION)-ipk
EMACS_LISP_SRC_IPK=$(BUILD_DIR)/emacs-lisp-src_$(EMACS_VERSION)-$(EMACS_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(EMACS_SOURCE):
	$(WGET) -P $(DL_DIR) $(EMACS_SITE)/$(EMACS_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
emacs-source: $(DL_DIR)/$(EMACS_SOURCE) $(EMACS_PATCHES)

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
$(EMACS_BUILD_DIR)/.configured: $(DL_DIR)/$(EMACS_SOURCE) $(EMACS_PATCHES)
	$(MAKE) ncurses-stage xaw-stage xmu-stage libjpeg-stage libpng-stage libtiff-stage
	rm -rf $(BUILD_DIR)/$(EMACS_DIR) $(EMACS_BUILD_DIR)
	$(EMACS_UNZIP) $(DL_DIR)/$(EMACS_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(EMACS_DIR) $(EMACS_BUILD_DIR)
	#cat $(EMACS_PATCHES) | patch -d $(EMACS_BUILD_DIR) -p1
	(cd $(EMACS_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(EMACS_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(EMACS_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--x-includes=$(STAGING_INCLUDE_DIR) \
		--x-libraries=$(STAGING_LIB_DIR) \
		--with-x \
		--with-x-toolkit=lucid \
	)
	sed -i -e 's%/usr/lib/crt%$(TARGET_LIBDIR)/crt%g' $(EMACS_BUILD_DIR)/src/Makefile
	sed -i -e 's%`./prefix-args.*`%-Xlinker -z -Xlinker nocombreloc $(LDFLAGS)%' $(EMACS_BUILD_DIR)/src/Makefile
	sed -i -e 's%LIBES =%LIBES = -Wl,-rpath-link=$(STAGING_LIB_DIR) -Wl,-rpath=/opt/lib%' $(EMACS_BUILD_DIR)/src/Makefile
	touch $(EMACS_BUILD_DIR)/.configured

emacs-unpack: $(EMACS_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(EMACS_BUILD_DIR)/.built: $(EMACS_BUILD_DIR)/.configured
	rm -f $(EMACS_BUILD_DIR)/.built
	$(MAKE) -C $(EMACS_BUILD_DIR)/lib-src make-docfile test-distrib CC=$(HOSTCC)
	$(MAKE) -C $(EMACS_BUILD_DIR) lib-src src leim TARGET_LIBDIR=$(TARGET_LIBDIR)
	touch $(EMACS_BUILD_DIR)/.built

#
#
emacs: $(EMACS_BUILD_DIR)/.built

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/emacs
#
$(EMACS_IPK_DIR)/CONTROL/control:
	@install -d $(EMACS_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: emacs" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EMACS_PRIORITY)" >>$@
	@echo "Section: $(EMACS_SECTION)" >>$@
	@echo "Version: $(EMACS_VERSION)-$(EMACS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EMACS_MAINTAINER)" >>$@
	@echo "Source: $(EMACS_SITE)/$(EMACS_SOURCE)" >>$@
	@echo "Description: $(EMACS_DESCRIPTION)" >>$@
	@echo "Depends: $(EMACS_DEPENDS), emacs-lisp" >>$@
	@echo "Suggests: $(EMACS_SUGGESTS)" >>$@
	@echo "Conflicts: $(EMACS_CONFLICTS)" >>$@

$(EMACS_LISP_IPK_DIR)/CONTROL/control:
	@install -d $(EMACS_LISP_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: emacs-lisp" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EMACS_PRIORITY)" >>$@
	@echo "Section: $(EMACS_SECTION)" >>$@
	@echo "Version: $(EMACS_VERSION)-$(EMACS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EMACS_MAINTAINER)" >>$@
	@echo "Source: $(EMACS_SITE)/$(EMACS_SOURCE)" >>$@
	@echo "Description: Lisp files - part of emacs" >>$@

$(EMACS_LISP_SRC_IPK_DIR)/CONTROL/control:
	@install -d $(EMACS_LISP_SRC_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: emacs-lisp-src" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(EMACS_PRIORITY)" >>$@
	@echo "Section: $(EMACS_SECTION)" >>$@
	@echo "Version: $(EMACS_VERSION)-$(EMACS_IPK_VERSION)" >>$@
	@echo "Maintainer: $(EMACS_MAINTAINER)" >>$@
	@echo "Source: $(EMACS_SITE)/$(EMACS_SOURCE)" >>$@
	@echo "Description: Lisp source files - an optional part of emacs" >>$@

#
# This builds the IPK file.
#
$(EMACS_IPK): $(EMACS_BUILD_DIR)/.built
	rm -rf $(EMACS_IPK_DIR) $(BUILD_DIR)/emacs_*_$(TARGET_ARCH).ipk
	rm -rf $(EMACS_LISP_IPK_DIR) $(BUILD_DIR)/emacs-lisp_*_$(TARGET_ARCH).ipk
	rm -rf $(EMACS_LISP_SRC_IPK_DIR) $(BUILD_DIR)/emacs-lisp-src_*_$(TARGET_ARCH).ipk
	$(MAKE) $(EMACS_IPK_DIR)/CONTROL/control
	$(MAKE) -C $(EMACS_BUILD_DIR) prefix=$(EMACS_IPK_DIR)/opt install TARGET_LIBDIR=$(TARGET_LIBDIR)
	rm -f $(EMACS_IPK_DIR)/opt/bin/emacs
	for F in \
		$(EMACS_IPK_DIR)/opt/bin/* \
		$(EMACS_IPK_DIR)/opt/libexec/emacs/$(EMACS_VERSION)/*/* ; \
		do $(STRIP_COMMAND) $$F || : ; \
	done
	ln -s /opt/bin/emacs-$(EMACS_VERSION) $(EMACS_IPK_DIR)/opt/bin/emacs
	$(MAKE) $(EMACS_LISP_SRC_IPK_DIR)/CONTROL/control
	( \
		cd $(EMACS_IPK_DIR) ; \
		find opt/share/emacs/$(EMACS_VERSION)/lisp -type d \
		-exec mkdir -p "$(EMACS_LISP_SRC_IPK_DIR)/{}" ";" ; \
		find opt/share/emacs/$(EMACS_VERSION)/lisp -name '*.elc' | \
			sed -e 's/[.]elc$$/.el/' | \
			while read F ; \
			do mv $$F $(EMACS_LISP_SRC_IPK_DIR)/$$F ; \
			done ; \
	)
	$(MAKE) $(EMACS_LISP_IPK_DIR)/CONTROL/control
	install -d $(EMACS_LISP_IPK_DIR)/opt/share/emacs/$(EMACS_VERSION)
	mv $(EMACS_IPK_DIR)/opt/share/emacs/$(EMACS_VERSION)/lisp $(EMACS_LISP_IPK_DIR)/opt/share/emacs/$(EMACS_VERSION)
#	install -m 644 $(EMACS_SOURCE_DIR)/postinst $(EMACS_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(EMACS_SOURCE_DIR)/prerm $(EMACS_IPK_DIR)/CONTROL/prerm
#	echo $(EMACS_CONFFILES) | sed -e 's/ /\n/g' > $(EMACS_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EMACS_LISP_SRC_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EMACS_LISP_IPK_DIR)
	cd $(BUILD_DIR); $(IPKG_BUILD) $(EMACS_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
emacs-ipk: $(EMACS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
emacs-clean:
	-$(MAKE) -C $(EMACS_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
emacs-dirclean:
	rm -rf $(BUILD_DIR)/$(EMACS_DIR) $(EMACS_BUILD_DIR) $(EMACS_IPK_DIR) $(EMACS_IPK)
