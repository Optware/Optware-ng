/*
 * This file has been generated automatically
 * by @(#)align_test.c	1.19 03/11/25 Copyright 1995 J. Schilling
 * do not edit by hand.
 */
#ifndef	_UTYPES_H
#include <utypes.h>
#endif

#define	ALIGN_SHORT	2	/* alignment value for (short *)	*/
#define	ALIGN_SMASK	1	/* alignment mask  for (short *)	*/
#define	SIZE_SHORT	2	/* sizeof (short)			*/

#define	ALIGN_INT	4	/* alignment value for (int *)		*/
#define	ALIGN_IMASK	3	/* alignment mask  for (int *)		*/
#define	SIZE_INT	4	/* sizeof (int)				*/

#define	ALIGN_LONG	4	/* alignment value for (long *)		*/
#define	ALIGN_LMASK	3	/* alignment mask  for (long *)		*/
#define	SIZE_LONG	4	/* sizeof (long)			*/

#define	ALIGN_LLONG	4	/* alignment value for (long long *)	*/
#define	ALIGN_LLMASK	3	/* alignment mask  for (long long *)	*/
#define	SIZE_LLONG	8	/* sizeof (long long)			*/

#define	ALIGN_FLOAT	4	/* alignment value for (float *)	*/
#define	ALIGN_FMASK	3	/* alignment mask  for (float *)	*/
#define	SIZE_FLOAT	4	/* sizeof (float)			*/

#define	ALIGN_DOUBLE	4	/* alignment value for (double *)	*/
#define	ALIGN_DMASK	3	/* alignment mask  for (double *)	*/
#define	SIZE_DOUBLE	8	/* sizeof (double)			*/

#define	ALIGN_PTR	4	/* alignment value for (pointer *)	*/
#define	ALIGN_PMASK	3	/* alignment mask  for (pointer *)	*/
#define	SIZE_PTR	4	/* sizeof (pointer)			*/


/*
 * There used to be a cast to an int but we get a warning from GCC.
 * This warning message from GCC is wrong.
 * Believe me that this macro would even be usable if I would cast to short.
 * In order to avoid this warning, we are now using UIntptr_t
 */
#define	xaligned(a, s)		((((UIntptr_t)(a)) & (s)) == 0 )
#define	x2aligned(a, b, s)	(((((UIntptr_t)(a)) | ((UIntptr_t)(b))) & (s)) == 0 )

#define	saligned(a)		xaligned(a, ALIGN_SMASK)
#define	s2aligned(a, b)		x2aligned(a, b, ALIGN_SMASK)

#define	ialigned(a)		xaligned(a, ALIGN_IMASK)
#define	i2aligned(a, b)		x2aligned(a, b, ALIGN_IMASK)

#define	laligned(a)		xaligned(a, ALIGN_LMASK)
#define	l2aligned(a, b)		x2aligned(a, b, ALIGN_LMASK)

#define	llaligned(a)		xaligned(a, ALIGN_LLMASK)
#define	ll2aligned(a, b)	x2aligned(a, b, ALIGN_LLMASK)

#define	faligned(a)		xaligned(a, ALIGN_FMASK)
#define	f2aligned(a, b)		x2aligned(a, b, ALIGN_FMASK)

#define	daligned(a)		xaligned(a, ALIGN_DMASK)
#define	d2aligned(a, b)		x2aligned(a, b, ALIGN_DMASK)

#define	paligned(a)		xaligned(a, ALIGN_PMASK)
#define	p2aligned(a, b)		x2aligned(a, b, ALIGN_PMASK)


/*
 * There used to be a cast to an int but we get a warning from GCC.
 * This warning message from GCC is wrong.
 * Believe me that this macro would even be usable if I would cast to short.
 * In order to avoid this warning, we are now using UIntptr_t
 */
#define	xalign(x, a, m)		( ((char *)(x)) + ( (a) - 1 - ((((UIntptr_t)(x))-1)&(m))) )

#define	salign(x)		xalign((x), ALIGN_SHORT, ALIGN_SMASK)
#define	ialign(x)		xalign((x), ALIGN_INT, ALIGN_IMASK)
#define	lalign(x)		xalign((x), ALIGN_LONG, ALIGN_LMASK)
#define	llalign(x)		xalign((x), ALIGN_LLONG, ALIGN_LLMASK)
#define	falign(x)		xalign((x), ALIGN_FLOAT, ALIGN_FMASK)
#define	dalign(x)		xalign((x), ALIGN_DOUBLE, ALIGN_DMASK)
#define	palign(x)		xalign((x), ALIGN_PTR, ALIGN_PMASK)
