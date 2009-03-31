###########################################################
#
# inferno
#
###########################################################
#
# INFERNO_VERSION, INFERNO_SITE and INFERNO_SOURCE define
# the upstream location of the source code for the package.
# INFERNO_DIR is the directory which is created when the source
# archive is unpacked.
# INFERNO_UNZIP is the command used to unzip the source.
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
INFERNO_SVN_REPO=http://inferno-os.googlecode.com/svn/trunk
INFERNO_SVN_REV=00381
INFERNO_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/inferno
INFERNO_VERSION=4.svn$(INFERNO_SVN_REV)
INFERNO_SOURCE=inferno-$(INFERNO_VERSION).tar.gz
INFERNO_DIR=inferno-$(INFERNO_VERSION)
INFERNO_UNZIP=zcat
INFERNO_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
INFERNO_DESCRIPTION=Inferno is an operating system for creating and supporting distributed services, it can either run natively or be hosted under other OS
INFERNO_SECTION=misc
INFERNO_PRIORITY=optional
INFERNO_DEPENDS=
INFERNO_SUGGESTS=
INFERNO_CONFLICTS=

INFERNO_IPK_VERSION=2

#INFERNO_CONFFILES=

INFERNO_HOST_PATCHES=$(INFERNO_SOURCE_DIR)/386-g.patch

INFERNO_ARCH=$(strip \
$(if $(filter arm armeb armel, $(TARGET_ARCH)), arm, \
$(if $(filter i686 i386, $(TARGET_ARCH)), 386, \
$(if $(filter powerpc ppc, $(TARGET_ARCH)), power, \
$(if $(filter mipsel, $(TARGET_ARCH)), spim, \
$(TARGET_ARCH))))))

INFERNO_PATCHES=$(INFERNO_SOURCE_DIR)/$(INFERNO_ARCH)-g.patch

INFERNO_PATCHES += $(strip \
$(if $(filter arm, $(INFERNO_ARCH)), \
	$(INFERNO_SOURCE_DIR)/asm-arm-SYS_exit.patch, \
))

ifeq ($(TARGET_ARCH), $(filter mips mipsel, $(TARGET_ARCH)))
INFERNO_CPPFLAGS=-mips32
endif

ifeq (uclibc, $(LIBC_STYLE))
INFERNO_LDFLAGS=-lm
endif

INFERNO_SOURCE_DIR=$(SOURCE_DIR)/inferno

INFERNO_BUILD_DIR=$(BUILD_DIR)/inferno
INFERNO_HOST_BUILD_DIR=$(HOST_BUILD_DIR)/inferno

INFERNO_IPK_DIR=$(BUILD_DIR)/inferno-$(INFERNO_VERSION)-ipk
INFERNO_IPK=$(BUILD_DIR)/inferno_$(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)_$(TARGET_ARCH).ipk

INFERNO-MINIMAL_IPK_DIR=$(BUILD_DIR)/inferno-minimal-$(INFERNO_VERSION)-ipk
INFERNO-MINIMAL_IPK=$(BUILD_DIR)/inferno-minimal_$(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)_$(TARGET_ARCH).ipk

INFERNO-UTILS_IPK_DIR=$(BUILD_DIR)/inferno-utils-$(INFERNO_VERSION)-ipk
INFERNO-UTILS_IPK=$(BUILD_DIR)/inferno-utils_$(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: inferno-source inferno-unpack inferno inferno-stage inferno-ipk inferno-clean inferno-dirclean inferno-check

$(DL_DIR)/$(INFERNO_SOURCE):
ifdef INFERNO_SVN_REV
	(cd $(BUILD_DIR); \
		rm -rf $(INFERNO_DIR) && \
		svn co -r $(INFERNO_SVN_REV) \
			$(INFERNO_SVN_REPO) $(INFERNO_DIR) && \
		tar -czf $@ \
			--exclude .svn \
			--exclude '*.dis' \
			--exclude '*.exe' \
			$(INFERNO_DIR) && \
		rm -rf $(INFERNO_DIR) \
	)
else
	$(WGET) -P $(@D) $(INFERNO_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)
endif

inferno-source: $(DL_DIR)/$(INFERNO_SOURCE) $(INFERNO_PATCHES)

$(INFERNO_HOST_BUILD_DIR)/.built: host/.configured $(DL_DIR)/$(INFERNO_SOURCE) $(INFERNO_HOST_PATCHES) # make/inferno.mk
	rm -rf $(HOST_BUILD_DIR)/$(INFERNO_DIR) $(@D)
	$(INFERNO_UNZIP) $(DL_DIR)/$(INFERNO_SOURCE) | tar -C $(HOST_BUILD_DIR) -xf -
	if test -n "$(INFERNO_HOST_PATCHES)" ; \
		then cat $(INFERNO_HOST_PATCHES) | \
		patch -d $(HOST_BUILD_DIR)/$(INFERNO_DIR) -p0 ; \
	fi
	if test "$(HOST_BUILD_DIR)/$(INFERNO_DIR)" != "$(@D)" ; \
		then mv $(HOST_BUILD_DIR)/$(INFERNO_DIR) $(@D) ; \
	fi
	sed -i.orig \
		-e '/^ROOT=/s|=.*|=$(@D)|' \
		-e '/^SYSHOST=/s|=.*|=Linux|' \
		-e '/^OBJTYPE=/s|=.*|=386|' \
		$(@D)/mkconfig
	sed -i.orig \
		-e '/^CC=/s/gcc -c/& -m32/' \
		-e '/^LD=/s/gcc/& -m32/' \
		$(@D)/makemk.sh
	(cd $(@D); \
		./makemk.sh; \
		export PATH=$(@D)/Linux/386/bin:$$PATH; \
		mk nuke install; \
	)
	touch $@

inferno-host: $(INFERNO_HOST_BUILD_DIR)/.built

$(INFERNO_BUILD_DIR)/.configured: $(INFERNO_HOST_BUILD_DIR)/.built $(INFERNO_PATCHES) make/inferno.mk
	rm -rf $(BUILD_DIR)/$(INFERNO_DIR) $(@D)
	$(INFERNO_UNZIP) $(DL_DIR)/$(INFERNO_SOURCE) | tar -C $(BUILD_DIR) -xf -
ifeq (spim, $(INFERNO_ARCH))
	cd $(BUILD_DIR)/$(INFERNO_DIR); tar -xzv --exclude emu/Linux/mkfile -f $(INFERNO_SOURCE_DIR)/wrt54g-src.tar.gz
	cd $(BUILD_DIR)/$(INFERNO_DIR)/libdynld; cp -p dynld-mips.c dynld-spim.c
endif
	if test -n "$(INFERNO_PATCHES)" ; \
		then cat $(INFERNO_PATCHES) | \
		patch -d $(BUILD_DIR)/$(INFERNO_DIR) -p0 ; \
	fi
	if test "$(BUILD_DIR)/$(INFERNO_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(INFERNO_DIR) $(@D) ; \
	fi
	sed -i.orig \
		-e '/^ROOT=/s|=.*|=$(@D)|' \
		-e '/^SYSHOST=/s|=.*|=Linux|' \
		-e '/^OBJTYPE=/s|=.*|=$(INFERNO_ARCH)|' \
		$(@D)/mkconfig
	sed -i.orig \
		-e '/^AR=/s|=.*|=$(TARGET_AR)|' \
		-e '/^AS=/s|=.*|=$(TARGET_CC) $(INFERNO_CPPFLAGS) -c|' \
		-e '/^CC=/s|=.*|=$(TARGET_CC) $(INFERNO_CPPFLAGS) -c|' \
		-e '/^LD=/s|=.*|=$(TARGET_CC) $(STAGING_LDFLAGS) $(INFERNO_LDFLAGS)|' \
		-e '/^YACC=/s|=.*|=iyacc|' \
		$(@D)/mkfiles/mkfile-Linux-$(INFERNO_ARCH)
	touch $@

inferno-unpack: $(INFERNO_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(INFERNO_BUILD_DIR)/.built: $(INFERNO_BUILD_DIR)/.configured
	rm -f $@
	(cd $(@D); \
		export PATH=$(INFERNO_HOST_BUILD_DIR)/Linux/386/bin:$$PATH; \
		mk nuke install \
			AR=$(TARGET_AR) \
		; \
	)
	touch $@

#
# This is the build convenience target.
#
inferno: $(INFERNO_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
#$(INFERNO_BUILD_DIR)/.staged: $(INFERNO_BUILD_DIR)/.built
#	rm -f $@
#	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
#	touch $@
#
#inferno-stage: $(INFERNO_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/inferno
#
$(INFERNO-MINIMAL_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: inferno-minimal" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INFERNO_PRIORITY)" >>$@
	@echo "Section: $(INFERNO_SECTION)" >>$@
	@echo "Version: $(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INFERNO_MAINTAINER)" >>$@
	@echo "Source: $(INFERNO_SITE)/$(INFERNO_SOURCE)" >>$@
	@echo "Description: $(INFERNO_DESCRIPTION)" >>$@
	@echo "Depends: $(INFERNO_DEPENDS)" >>$@
	@echo "Suggests: $(INFERNO_SUGGESTS)" >>$@
	@echo "Conflicts: $(INFERNO_CONFLICTS)" >>$@

$(INFERNO-UTILS_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: inferno-utils" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INFERNO_PRIORITY)" >>$@
	@echo "Section: $(INFERNO_SECTION)" >>$@
	@echo "Version: $(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INFERNO_MAINTAINER)" >>$@
	@echo "Source: $(INFERNO_SITE)/$(INFERNO_SOURCE)" >>$@
	@echo "Description: $(INFERNO_DESCRIPTION)" >>$@
	@echo "Depends: $(INFERNO_DEPENDS)" >>$@
	@echo "Suggests: $(INFERNO_SUGGESTS)" >>$@
	@echo "Conflicts: $(INFERNO_CONFLICTS)" >>$@

$(INFERNO_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: inferno" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(INFERNO_PRIORITY)" >>$@
	@echo "Section: $(INFERNO_SECTION)" >>$@
	@echo "Version: $(INFERNO_VERSION)-$(INFERNO_IPK_VERSION)" >>$@
	@echo "Maintainer: $(INFERNO_MAINTAINER)" >>$@
	@echo "Source: $(INFERNO_SITE)/$(INFERNO_SOURCE)" >>$@
	@echo "Description: $(INFERNO_DESCRIPTION)" >>$@
	@echo "Depends: $(INFERNO_DEPENDS)" >>$@
	@echo "Suggests: $(INFERNO_SUGGESTS)" >>$@
	@echo "Conflicts: $(INFERNO_CONFLICTS)" >>$@

#
# This builds the IPK file.
#
# Binaries should be installed into $(INFERNO_IPK_DIR)/opt/sbin or $(INFERNO_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(INFERNO_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(INFERNO_IPK_DIR)/opt/etc/inferno/...
# Documentation files should be installed in $(INFERNO_IPK_DIR)/opt/doc/inferno/...
# Daemon startup scripts should be installed in $(INFERNO_IPK_DIR)/opt/etc/init.d/S??inferno
#
# You may need to patch your application to make it use these locations.
#
$(INFERNO-MINIMAL_IPK) $(INFERNO-UTILS_IPK): $(INFERNO_BUILD_DIR)/.built
	rm -rf $(BUILD_DIR)/inferno*_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/inferno*-ipk
	# inferno
	install -d $(INFERNO_IPK_DIR)/opt/bin $(INFERNO_IPK_DIR)/opt/share/inferno
	install $(<D)/Linux/$(INFERNO_ARCH)/bin/* $(INFERNO_IPK_DIR)/opt/bin
	$(STRIP_COMMAND) $(INFERNO_IPK_DIR)/opt/bin/*
	rsync -av $(<D)/dis $(INFERNO_IPK_DIR)/opt/share/inferno/
	# inferno-minimal
	install -d $(INFERNO-MINIMAL_IPK_DIR)/opt/bin
	mv $(INFERNO_IPK_DIR)/opt/bin/emu-g $(INFERNO-MINIMAL_IPK_DIR)/opt/bin/
	install -d $(INFERNO-MINIMAL_IPK_DIR)/opt/share/inferno/dis/lib
	for f in \
		dis/lib/arg.dis \
		dis/lib/attrdb.dis \
		dis/lib/bufio.dis \
		dis/lib/daytime.dis \
		dis/lib/env.dis \
		dis/lib/filepat.dis \
		dis/lib/ip.dis \
		dis/lib/ipattr.dis \
		dis/lib/readdir.dis \
		dis/lib/string.dis \
		dis/ndb/cs.dis \
		dis/emuinit.dis \
		dis/ls.dis \
		dis/mount.dis \
		dis/os.dis \
		dis/sh.dis \
		; \
	do \
		d=`dirname $$f`; \
		mv $(INFERNO_IPK_DIR)/opt/share/inferno/$$f \
		   $(INFERNO-MINIMAL_IPK_DIR)/opt/share/inferno/$$d; \
	done
	$(MAKE) $(INFERNO-MINIMAL_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INFERNO-MINIMAL_IPK_DIR)
	# inferno-utils
	install -d $(INFERNO-UTILS_IPK_DIR)/opt/share/inferno
	mv $(INFERNO_IPK_DIR)/opt/bin $(INFERNO-UTILS_IPK_DIR)/opt/share/inferno
	$(MAKE) $(INFERNO-UTILS_IPK_DIR)/CONTROL/control
	cd $(BUILD_DIR); $(IPKG_BUILD) $(INFERNO-UTILS_IPK_DIR)
#	# rest in inferno
#	$(MAKE) $(INFERNO_IPK_DIR)/CONTROL/control
#	echo $(INFERNO_CONFFILES) | sed -e 's/ /\n/g' > $(INFERNO_IPK_DIR)/CONTROL/conffiles
#	cd $(BUILD_DIR); $(IPKG_BUILD) $(INFERNO_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
inferno-ipk: $(INFERNO-MINIMAL_IPK) $(INFERNO-UTILS_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
inferno-clean:
	rm -f $(INFERNO_BUILD_DIR)/.built
	-$(MAKE) -C $(INFERNO_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
inferno-dirclean:
	rm -rf $(BUILD_DIR)/$(INFERNO_DIR) $(INFERNO_BUILD_DIR)
	rm -rf $(INFERNO-MINIMAL_IPK_DIR) $(INFERNO-MINIMAL_IPK)
	rm -rf $(INFERNO-UTILS_IPK_DIR) $(INFERNO-UTILS_IPK)
	rm -rf $(INFERNO_IPK_DIR) $(INFERNO_IPK)
#
#
# Some sanity check for the package.
#
inferno-check: $(INFERNO-MINIMAL_IPK) $(INFERNO-UTILS_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
