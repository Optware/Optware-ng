PERL_VERSION=5.26.1
PERL_MAJOR_VER := $(shell echo $(PERL_VERSION) | cut -d'.' -f1-2)
PERL_IPK_VERSION=4

PERL_SITE=http://www.cpan.org/src/5.0
PERL_SOURCE=perl-$(PERL_VERSION).tar.gz
PERL_DIR=perl-$(PERL_VERSION)
PERL_UNZIP=zcat
PERL_PRIORITY=optional
PERL_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL_SECTION=interpreters
PERL_DESCRIPTION=Practical Extraction and Report Language.
PERL_DEPENDS=gdbm
PERL_SUGGESTS=
PERL_CONFLICTS=

$(DL_DIR)/$(PERL_SOURCE):
	$(WGET) -P $(@D) $(PERL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

perl-source: $(DL_DIR)/$(PERL_SOURCE)


include $(SOURCE_DIR)/perl/$(PERL_MAJOR_VER)/perl.mk


# the following two targets are here to not confuse autoclean

$(PERL_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_PRIORITY)" >>$@
	@echo "Section: $(PERL_SECTION)" >>$@
	@echo "Version: $(PERL_VERSION)-$(PERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MAINTAINER)" >>$@
	@echo "Source: $(PERL_SITE)/$(PERL_SOURCE)" >>$@
	@echo "Description: $(PERL_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL_DEPENDS)" >>$@
	@echo "Suggests: $(PERL_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL_CONFLICTS)" >>$@

$(PERL-DOC_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(@D)
	@rm -f $@
	@echo "Package: perl-doc" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL_PRIORITY)" >>$@
	@echo "Section: $(PERL_SECTION)" >>$@
	@echo "Version: $(PERL_VERSION)-$(PERL_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL_MAINTAINER)" >>$@
	@echo "Source: $(PERL_SITE)/$(PERL_SOURCE)" >>$@
	@echo "Description: Documentation for perl" >>$@
	@echo "Depends: " >>$@
	@echo "Suggests: " >>$@
	@echo "Conflicts: " >>$@
