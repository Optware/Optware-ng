SYNO-GPL_SOURCE_SITE=http://gpl.nas-central.org/SYNOLOGY
SYNO-FW_VERSION=631
SYNO-GPL_SOURCE=synogpl-$(SYNO-FW_VERSION).tbz

$(DL_DIR)/$(SYNO-GPL_SOURCE):
	$(WGET) -P $(@D) $(SYNO-GPL_SOURCE_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)