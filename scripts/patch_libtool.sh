#!/bin/bash

cat_patch()
{
cat << 'EOF'
--- a/libtool
+++ b/libtool
@@ -6872,6 +6872,13 @@
 	  func_append finalize_command " $wl$qarg"
 	  continue
 	  ;;
+	xassembler)
+	  func_append compiler_flags " -Xassembler $qarg"
+	  prev=
+	  func_append compile_command " -Xassembler $qarg"
+	  func_append finalize_command " -Xassembler $qarg"
+	  continue
+	  ;;
 	*)
 	  eval "$prev=\"\$arg\""
 	  prev=
@@ -7237,6 +7244,11 @@
 	arg=$func_stripname_result
 	;;
 
+      -Xassembler)
+        prev=xassembler
+        continue
+        ;;
+
       -Xcompiler)
 	prev=xcompiler
 	continue
EOF
}

xassembler_patch()
{
	for file in "$@"; do
	if cat "$file" | grep -xq "      -Xassembler)"; then
		continue
	fi
	cat_patch | patch -s --no-backup-if-mismatch "$file" || exit 1
	done
}

sed "$@" || exit 1

next_is_script=1
no_more_flags=0

for arg in "$@"; do
	if [[ "$arg" == "--" ]] && [[ "$no_more_flags" == "0" ]]; then
		no_more_flags=1
		continue
	fi

	if [[ "$arg" == "-e" ]] && [[ "$no_more_flags" == "0" ]]; then
		next_is_script=1
		continue
	fi

	if [[ "$next_is_script" == "1" ]]; then
		next_is_script=0
		continue
	fi

	if [[ $arg == -* ]] && [[ "$no_more_flags" == "0" ]]; then
		continue
	fi

	xassembler_patch "$arg"
done
