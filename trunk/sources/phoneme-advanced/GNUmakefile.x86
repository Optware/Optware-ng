#
# Copyright  1990-2006 Sun Microsystems, Inc. All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version
# 2 only, as published by the Free Software Foundation. 
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License version 2 for more details (a copy is
# included at /legal/license.txt). 
# 
# You should have received a copy of the GNU General Public License
# version 2 along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA 
# 
# Please contact Sun Microsystems, Inc., 4150 Network Circle, Santa
# Clara, CA 95054 or visit www.sun.com if you need additional
# information or have any questions. 
#
# @(#)GNUmakefile	1.14 06/10/10
#

#
# GNUmakefile for generic linux/x86 target
#

#
# platform specific architecture flags
#
ASM_ARCH_FLAGS		= -march=i686
CC_ARCH_FLAGS   	= -march=i686
# Fix gcc fp bug on x86 and avoid cvm problems
CC_ARCH_FLAGS_FDLIB	= -ffloat-store
# Don't inline the interpreter loop helper functions. This helps
# reduce register pressure on x86 and improve generated code.
CC_ARCH_FLAGS_LOOP 	= -fno-inline
LINK_ARCH_FLAGS		=
LINK_ARCH_LIBS  	= -lm

CVM_JIT_USE_FP_HARDWARE = false

# Disable CVM_JIT_REGISTER_LOCALS for x86 for now.
CVM_JIT_REGISTER_LOCALS ?= false

include ../share/top.mk
