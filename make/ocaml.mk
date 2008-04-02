###########################################################
#
# ocaml
#
###########################################################
#
# $Header$
#
# OCAML_VERSION, OCAML_SITE and OCAML_SOURCE define
# the upstream location of the source code for the package.
# OCAML_DIR is the directory which is created when the source
# archive is unpacked.
# OCAML_UNZIP is the command used to unzip the source.
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
OCAML_SITE=http://caml.inria.fr/pub/distrib/ocaml-3.10
OCAML_VERSION=3.10.2
OCAML_SOURCE=ocaml-$(OCAML_VERSION).tar.gz
OCAML_DIR=ocaml-$(OCAML_VERSION)
OCAML_UNZIP=zcat
OCAML_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
OCAML_DESCRIPTION=Objective Caml system is the main implementation of the Caml language.
OCAML_SECTION=lang
OCAML_PRIORITY=optional
OCAML_DEPENDS=
OCAML_SUGGESTS=
OCAML_CONFLICTS=

OCAML_IPK_VERSION=1

#
# OCAML_CONFFILES should be a list of user-editable files
#OCAML_CONFFILES=/opt/etc/ocaml.conf /opt/etc/init.d/SXXocaml

#
# OCAML_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
OCAML_PATCHES=
ifneq ($(HOSTCC), $(TARGET_CC))
OCAML_PATCHES+=\
$(OCAML_SOURCE_DIR)/cross-configure.patch \
$(OCAML_SOURCE_DIR)/cross-Makefile.patch
endif

ifneq (, $(filter arm armeb, $(TARGET_ARCH)))
#OCAML_PATCHES+=\
$(OCAML_SOURCE_DIR)/asmcomp-arm-emit.mlp.patch \
$(OCAML_SOURCE_DIR)/asmcomp-arm-selection.ml.patch
endif

OCAML_CPPFLAGS=
OCAML_LDFLAGS=

ifneq ($(HOSTCC), $(TARGET_CC))
OCAML_CONFIG_ENVS= \
ac_ocaml_sizes="4 4 4 2" \
ac_ocaml_64bit_supported=y \
ac_ocaml_typeof_int64="long long" \
ac_ocaml_typeof_uint64="unsigned long long" \
ac_ocaml_int64_printf_format='"ll"' \
ac_ocaml_align_double=n \
ac_ocaml_align_int64=n \
ac_ocaml_standard_div_mod=y
endif

OCAML_SOURCE_DIR=$(SOURCE_DIR)/ocaml

OCAML_BUILD_DIR=$(BUILD_DIR)/ocaml
OCAML_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/ocaml

OCAML_IPK_DIR=$(BUILD_DIR)/ocaml-$(OCAML_VERSION)-ipk
OCAML_IPK=$(BUILD_DIR)/ocaml_$(OCAML_VERSION)-$(OCAML_IPK_VERSION)_$(TARGET_ARCH).ipk

$(DL_DIR)/$(OCAML_SOURCE):
	$(WGET) -P $(@D) $(OCAML_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

ocaml-source: $(DL_DIR)/$(OCAML_SOURCE) $(OCAML_PATCHES)

$(OCAML_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(OCAML_SOURCE)
	rm -rf $(BUILD_DIR)/$(OCAML_DIR) $(@D)
	$(OCAML_UNZIP) $(DL_DIR)/$(OCAML_SOURCE) | tar -C $(HOST_BUILD_DIR) -xvf -
	mv $(HOST_BUILD_DIR)/$(OCAML_DIR) $(@D)
	cd $(@D) && ./configure -prefix /opt -no-tk
	cd $(@D) && $(MAKE) world
	touch $@

ocaml-hostbuild: $(OCAML_HOST_BUILD_DIR)/.built

# http://wiki.chumby.com/mediawiki/index.php?title=Ocaml&printable=yes
ifeq ($(HOSTCC), $(TARGET_CC))
$(OCAML_BUILD_DIR)/.configured: $(DL_DIR)/$(OCAML_SOURCE) $(OCAML_PATCHES)
else
$(OCAML_BUILD_DIR)/.configured: $(OCAML_HOST_BUILD_DIR)/.built $(DL_DIR)/$(OCAML_SOURCE) $(OCAML_PATCHES)
endif
	rm -rf $(BUILD_DIR)/$(OCAML_DIR) $(OCAML_BUILD_DIR)
	$(OCAML_UNZIP) $(DL_DIR)/$(OCAML_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(OCAML_PATCHES)"; then \
		cat $(OCAML_PATCHES) | patch -bd $(BUILD_DIR)/$(OCAML_DIR) -p1; \
        fi
	mv $(BUILD_DIR)/$(OCAML_DIR) $(@D)
	(cd $(@D); \
if $(TARGET_CC) -E -P $(SOURCE_DIR)/common/endianness.c | grep -q puts.*BIG_ENDIAN; \
then export ac_ocaml_is_big_endian=y; else export ac_ocaml_is_big_endian=n; \
fi; \
		$(OCAML_CONFIG_ENVS) \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(OCAML_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(OCAML_LDFLAGS)" \
		./configure \
		-host $(GNU_TARGET_NAME) \
		-prefix /opt \
		-no-tk \
		-cc $(TARGET_CC) \
		-ranlib $(TARGET_RANLIB) \
		-ld $(TARGET_LD) \
		-ar $(TARGET_AR) \
		-aspp $(TARGET_CC) \
	)
	touch $@

ocaml-unpack: $(OCAML_BUILD_DIR)/.configured

# http://caml.inria.fr/mantis/view.php?id=3746
$(OCAML_BUILD_DIR)/.built: $(OCAML_BUILD_DIR)/.configured
	rm -f $@
#	$(MAKE) -C $(@D) world opt
	$(MAKE) -C $(@D) world
	for f in byterun/ocamlrun yacc/ocamlyacc otherlibs/unix/dllunix.so otherlibs/str/dllstr.so; \
	    do cp -p $(@D)/$${f}.target $(@D)/$$f; done
	touch $@

ocaml: $(OCAML_BUILD_DIR)/.built

$(OCAML_BUILD_DIR)/.staged: $(OCAML_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

ocaml-stage: $(OCAML_BUILD_DIR)/.staged

$(OCAML_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: ocaml" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(OCAML_PRIORITY)" >>$@
	@echo "Section: $(OCAML_SECTION)" >>$@
	@echo "Version: $(OCAML_VERSION)-$(OCAML_IPK_VERSION)" >>$@
	@echo "Maintainer: $(OCAML_MAINTAINER)" >>$@
	@echo "Source: $(OCAML_SITE)/$(OCAML_SOURCE)" >>$@
	@echo "Description: $(OCAML_DESCRIPTION)" >>$@
	@echo "Depends: $(OCAML_DEPENDS)" >>$@
	@echo "Suggests: $(OCAML_SUGGESTS)" >>$@
	@echo "Conflicts: $(OCAML_CONFLICTS)" >>$@

$(OCAML_IPK): $(OCAML_BUILD_DIR)/.built
	rm -rf $(OCAML_IPK_DIR) $(BUILD_DIR)/ocaml_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(OCAML_BUILD_DIR) PREFIX=$(OCAML_IPK_DIR)/opt install
	for exe in ocamlrun ocamlyacc; do $(STRIP_COMMAND) $(OCAML_IPK_DIR)/opt/bin/$$exe; done
	for so in $(OCAML_IPK_DIR)/opt/lib/ocaml/stublibs/*.so; do $(STRIP_COMMAND) $$so; done
	$(MAKE) $(OCAML_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(OCAML_IPK_DIR)

ocaml-ipk: $(OCAML_IPK)

ocaml-clean:
	-$(MAKE) -C $(OCAML_BUILD_DIR) clean

ocaml-dirclean:
	rm -rf $(BUILD_DIR)/$(OCAML_DIR) $(OCAML_BUILD_DIR) $(OCAML_IPK_DIR) $(OCAML_IPK)

ocaml-check: $(OCAML_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $(OCAML_IPK)
