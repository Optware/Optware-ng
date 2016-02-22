#############################################################
#
# create bootstrap script for the target
#
#############################################################

.PHONY: bootstrap-script

BOOTSTRAP_SCRIPT_SOURCE_DIR=$(SOURCE_DIR)/bootstrap-script

ifeq ($(LIBC_STYLE), uclibc)
BOOTSTRAP_SCRIPT_SOURCE=$(BOOTSTRAP_SCRIPT_SOURCE_DIR)/bootstrap-uclibc.sh
else
BOOTSTRAP_SCRIPT_SOURCE=$(BOOTSTRAP_SCRIPT_SOURCE_DIR)/bootstrap-glibc.sh
endif

$(OPTWARE_TARGET)-bootstrap.sh: $(BOOTSTRAP_SCRIPT_SOURCE) make/bootstrap-script.mk
	rm -f $@
	cat $(BOOTSTRAP_SCRIPT_SOURCE) | sed -e "s|%OPTWARE_TARGET_PREFIX%|$(TARGET_PREFIX)|g" -e "s|%TARGET%|$(OPTWARE_TARGET)|g" > $@
	chmod 755 $@

bootstrap-script: $(OPTWARE_TARGET)-bootstrap.sh
