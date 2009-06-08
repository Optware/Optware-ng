for CODEPAGE in ${CODEPAGES}
	do
		cp -f ${SAMBA_SOURCE_DIR}/codepage/${CODEPAGE}.c ${SAMBA_BUILD_DIR}/source/modules
		echo "#undef charset_$CODEPAGE_init" >> ${SAMBA_BUILD_DIR}/source/include/config.h.in
		echo "#define charset_$CODEPAGE_init init_samba_module" >> ${SAMBA_BUILD_DIR}/include/config.h
		sed -i -e "/^CHARSET_MODULES/s|$| bin/${CODEPAGE}.so|" \
		-e "/CP850_OBJ =/s|^|${CODEPAGE}_OBJ = modules/${CODEPAGE}.o\n|" \
		-e "/^bin\/CP850\.so:/s|^|bin/${CODEPAGE}.so: \$(BINARY_PREREQS) \$(${CODEPAGE}_OBJ)\n	@echo \"Building plugin \$@\"\n	@\$(SHLD_MODULE) \$(${CODEPAGE}_OBJ)\n\n|" ${SAMBA_BUILD_DIR}/Makefile
	done
