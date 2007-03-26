/*
 * Copyright 2004, Broadcom Corporation      
 * All Rights Reserved.      
 *       
 * THIS SOFTWARE IS OFFERED "AS IS", AND BROADCOM GRANTS NO WARRANTIES OF ANY      
 * KIND, EXPRESS OR IMPLIED, BY STATUTE, COMMUNICATION OR OTHERWISE. BROADCOM      
 * SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS      
 * FOR A SPECIFIC PURPOSE OR NONINFRINGEMENT CONCERNING THIS SOFTWARE.      
 * $Id$
 */

#ifndef _TYPEDEFS_H_
#define _TYPEDEFS_H_


/* Define 'SITE_TYPEDEFS' in the compile to include a site specific
 * typedef file "site_typedefs.h".
 *
 * If 'SITE_TYPEDEFS' is not defined, then the "Inferred Typedefs"
 * section of this file makes inferences about the compile environment
 * based on defined symbols and possibly compiler pragmas.
 *
 * Following these two sections is the "Default Typedefs"
 * section. This section is only prcessed if 'USE_TYPEDEF_DEFAULTS' is
 * defined. This section has a default set of typedefs and a few
 * proprocessor symbols (TRUE, FALSE, NULL, ...).
 */

#ifdef SITE_TYPEDEFS

/*******************************************************************************
 * Site Specific Typedefs
 *******************************************************************************/

#include "site_typedefs.h"

#else

/*******************************************************************************
 * Inferred Typedefs
 *******************************************************************************/

/* Infer the compile environment based on preprocessor symbols and pramas.
 * Override type definitions as needed, and include configuration dependent
 * header files to define types.
 */

#ifdef __cplusplus

#define TYPEDEF_BOOL
#ifndef FALSE
#define FALSE	false
#endif
#ifndef TRUE
#define TRUE	true
#endif

#else	/* ! __cplusplus */

#if defined(_WIN32)

#define TYPEDEF_BOOL
typedef	unsigned char	bool;			/* consistent w/BOOL */

#endif /* _WIN32 */

#endif	/* ! __cplusplus */

/* use the Windows ULONG_PTR type when compiling for 64 bit */
#if defined(_WIN64)
#include <basetsd.h>
#define TYPEDEF_UINTPTR
typedef ULONG_PTR	uintptr;
#endif

#ifdef _MSC_VER	    /* Microsoft C */
#define TYPEDEF_INT64
#define TYPEDEF_UINT64
typedef signed __int64	int64;
typedef unsigned __int64 uint64;
#endif

#if defined(MACOSX) && defined(KERNEL)
#define TYPEDEF_BOOL
#endif


#if defined(linux)
#define TYPEDEF_UINT
#define TYPEDEF_USHORT
#define TYPEDEF_ULONG
#endif

#if !defined(linux) && !defined(_WIN32) && !defined(PMON) && !defined(_CFE_) && !defined(_HNDRTE_) && !defined(_MINOSL_)
#define TYPEDEF_UINT
#define TYPEDEF_USHORT
#endif


/* Do not support the (u)int64 types with strict ansi for GNU C */
#if defined(__GNUC__) && defined(__STRICT_ANSI__)
#define TYPEDEF_INT64
#define TYPEDEF_UINT64
#endif

/* ICL accepts unsigned 64 bit type only, and complains in ANSI mode
 * for singned or unsigned */
#if defined(__ICL)

#define TYPEDEF_INT64

#if defined(__STDC__)
#define TYPEDEF_UINT64
#endif

#endif /* __ICL */


#if !defined(_WIN32) && !defined(PMON) && !defined(_CFE_) && !defined(_HNDRTE_) && !defined(_MINOSL_)

/* pick up ushort & uint from standard types.h */
#if defined(linux) && defined(__KERNEL__)

#include <linux/types.h>	/* sys/types.h and linux/types.h are oil and water */

#else

#include <sys/types.h>	

#endif

#endif /* !_WIN32 && !PMON && !_CFE_ && !_HNDRTE_  && !_MINOSL_ */

#if defined(MACOSX) && defined(KERNEL)
#include <IOKit/IOTypes.h>
#endif


/* use the default typedefs in the next section of this file */
#define USE_TYPEDEF_DEFAULTS

#endif /* SITE_TYPEDEFS */


/*******************************************************************************
 * Default Typedefs
 *******************************************************************************/

#ifdef USE_TYPEDEF_DEFAULTS
#undef USE_TYPEDEF_DEFAULTS

#ifndef TYPEDEF_BOOL
typedef	/*@abstract@*/ unsigned char	bool;
#endif

/*----------------------- define uchar, ushort, uint, ulong ------------------*/

#ifndef TYPEDEF_UCHAR
typedef unsigned char	uchar;
#endif

#ifndef TYPEDEF_USHORT
typedef unsigned short	ushort;
#endif

#ifndef TYPEDEF_UINT
typedef unsigned int	uint;
#endif

#ifndef TYPEDEF_ULONG
typedef unsigned long	ulong;
#endif

/*----------------------- define [u]int8/16/32/64, uintptr --------------------*/

#ifndef TYPEDEF_UINT8
typedef unsigned char	uint8;
#endif

#ifndef TYPEDEF_UINT16
typedef unsigned short	uint16;
#endif

#ifndef TYPEDEF_UINT32
typedef unsigned int	uint32;
#endif

#ifndef TYPEDEF_UINT64
typedef unsigned long long uint64;
#endif

#ifndef TYPEDEF_UINTPTR
typedef unsigned int	uintptr;
#endif

#ifndef TYPEDEF_INT8
typedef signed char	int8;
#endif

#ifndef TYPEDEF_INT16
typedef signed short	int16;
#endif

#ifndef TYPEDEF_INT32
typedef signed int	int32;
#endif

#ifndef TYPEDEF_INT64
typedef signed long long int64;
#endif

/*----------------------- define float32/64, float_t -----------------------*/

#ifndef TYPEDEF_FLOAT32
typedef float		float32;
#endif

#ifndef TYPEDEF_FLOAT64
typedef double		float64;
#endif

/*
 * abstracted floating point type allows for compile time selection of
 * single or double precision arithmetic.  Compiling with -DFLOAT32
 * selects single precision; the default is double precision.
 */

#ifndef TYPEDEF_FLOAT_T

#if defined(FLOAT32)
typedef float32 float_t;
#else /* default to double precision floating point */
typedef float64 float_t;
#endif

#endif /* TYPEDEF_FLOAT_T */

/*----------------------- define macro values -----------------------------*/

#ifndef FALSE
#define FALSE	0
#endif

#ifndef TRUE
#define TRUE	1
#endif

#ifndef NULL
#define	NULL	0
#endif

#ifndef OFF
#define	OFF	0
#endif

#ifndef ON
#define	ON	1
#endif

#define	AUTO	(-1)

/* Reclaiming text and data :
   The following macros specify special linker sections that can be reclaimed
   after a system is considered 'up'.
 */ 
#if defined(__GNUC__) && defined(BCMRECLAIM)
extern bool	bcmreclaimed;
#define BCMINITDATA(_data)	__attribute__ ((__section__ (".dataini." #_data))) _data##_ini		
#define BCMINITFN(_fn)		__attribute__ ((__section__ (".textini." #_fn))) _fn##_ini
#define BCMINIT(_id)		_id##_ini
#else 
#define BCMINITDATA(_data)	_data		
#define BCMINITFN(_fn)		_fn
#define BCMINIT(_id)		_id
#define bcmreclaimed		0
#endif

/*----------------------- define PTRSZ, INLINE ----------------------------*/

#ifndef PTRSZ
#define	PTRSZ	sizeof (char*)
#endif

#ifndef INLINE

#ifdef _MSC_VER

#define INLINE __inline

#elif __GNUC__

#define INLINE __inline__

#else

#define INLINE

#endif /* _MSC_VER */

#endif /* INLINE */

#undef TYPEDEF_BOOL
#undef TYPEDEF_UCHAR
#undef TYPEDEF_USHORT
#undef TYPEDEF_UINT
#undef TYPEDEF_ULONG
#undef TYPEDEF_UINT8
#undef TYPEDEF_UINT16
#undef TYPEDEF_UINT32
#undef TYPEDEF_UINT64
#undef TYPEDEF_UINTPTR
#undef TYPEDEF_INT8
#undef TYPEDEF_INT16
#undef TYPEDEF_INT32
#undef TYPEDEF_INT64
#undef TYPEDEF_FLOAT32
#undef TYPEDEF_FLOAT64
#undef TYPEDEF_FLOAT_T

#endif /* USE_TYPEDEF_DEFAULTS */

#endif /* _TYPEDEFS_H_ */
