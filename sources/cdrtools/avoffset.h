/*
 * This file has been generated automatically
 * by @(#)avoffset.c	1.24 04/05/09 Copyright 1987, 1995-2004 J. Schilling
 * do not edit by hand.
 *
 * This file includes definitions for AV_OFFSET and FP_INDIR.
 * FP_INDIR is the number of fp chain elements above 'main'.
 * AV_OFFSET is the offset of &av[0] relative to the frame pointer in 'main'.
 *
 * If getav0() does not work on a specific architecture
 * the program which generated this include file may dump core.
 * In this case, the generated include file does not include
 * definitions for AV_OFFSET and FP_INDIR but ends after this comment.
 * If AV_OFFSET or FP_INDIR are missing in this file, all programs
 * which use the definitions are automatically disabled.
 */
#define	STACK_DIRECTION	-1
