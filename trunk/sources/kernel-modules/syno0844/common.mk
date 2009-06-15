GPL_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/dsgpl
GPL_SOURCE=synogpl-844.tbz
GPL_UNZIP=bzcat

.PHONY: gpl-source

$(DL_DIR)/$(GPL_SOURCE):
	$(WGET) -P $(@D) $(GPL_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

gpl-source: $(DL_DIR)/$(GPL_SOURCE)
