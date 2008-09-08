#ifndef _MACHDEFS_H
#define _MACHDEFS_H


#undef MACH_BIG_ENDIAN_WORDS

#undef MACH_BIG_ENDIAN_BITFIELD

typedef signed char MachInt8;
typedef unsigned char MachUInt8;
#define MACH_TYPE_8BIT char

typedef signed short MachInt16;
typedef unsigned short MachUInt16;
#define MACH_TYPE_16BIT short

typedef signed int MachInt32;
typedef unsigned int MachUInt32;
#define MACH_TYPE_32BIT int



#endif
