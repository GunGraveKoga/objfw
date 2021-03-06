/*
 * Copyright (c) 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017
 *   Jonathan Schleifer <js@heap.zone>
 *
 * All rights reserved.
 *
 * This file is part of ObjFW. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE.QPL included in
 * the packaging of this file.
 *
 * Alternatively, it may be distributed under the terms of the GNU General
 * Public License, either version 2 or 3, which can be found in the file
 * LICENSE.GPLv2 or LICENSE.GPLv3 respectively included in the packaging of this
 * file.
 */

#ifndef __OBJFW_RUNTIME_H__
#define __OBJFW_RUNTIME_H__

#ifndef __STDC_LIMIT_MACROS
# define __STDC_LIMIT_MACROS
#endif
#ifndef __STDC_CONSTANT_MACROS
# define __STDC_CONSTANT_MACROS
#endif

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifndef __has_feature
# define __has_feature(x) 0
#endif

#ifndef __has_attribute
# define __has_attribute(x) 0
#endif

#if !__has_feature(nullability)
# ifndef _Nonnull
#  define _Nonnull
# endif
# ifndef _Nullable
#  define _Nullable
# endif
# ifndef _Null_unspecified
#  define _Null_unspecified
# endif
#endif

#if !__has_feature(objc_arc) && !defined(__unsafe_unretained)
# define __unsafe_unretained
#endif

#define Nil (Class _Null_unspecified)0
#define nil (id _Null_unspecified)0
#define YES (BOOL)1
#define NO  (BOOL)0

typedef struct objc_class *Class;
typedef struct objc_object *id;
typedef const struct objc_selector *SEL;
typedef signed char BOOL;
typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...);
typedef void (*objc_uncaught_exception_handler)(id _Nullable);
typedef void (*objc_enumeration_mutation_handler)(id _Nonnull);

struct objc_class {
	Class _Nonnull isa;
	Class _Nullable superclass;
	const char *_Nonnull name;
	unsigned long version;
	unsigned long info;
	long instance_size;
	struct objc_ivar_list *_Nullable ivars;
	struct objc_method_list *_Nullable methodlist;
	struct objc_dtable *_Nonnull dtable;
	Class _Nullable *_Nullable subclass_list;
	void *_Nullable sibling_class;
	struct objc_protocol_list *_Nullable protocols;
	void *_Nullable gc_object_type;
	unsigned long abi_version;
	int32_t *_Nonnull *_Nullable ivar_offsets;
	struct objc_property_list *_Nullable properties;
};

enum objc_class_info {
	OBJC_CLASS_INFO_CLASS	    = 0x001,
	OBJC_CLASS_INFO_METACLASS   = 0x002,
	OBJC_CLASS_INFO_NEW_ABI	    = 0x010,
	OBJC_CLASS_INFO_SETUP	    = 0x100,
	OBJC_CLASS_INFO_LOADED	    = 0x200,
	OBJC_CLASS_INFO_DTABLE	    = 0x400,
	OBJC_CLASS_INFO_INITIALIZED = 0x800
};

struct objc_object {
	Class _Nonnull isa;
};

struct objc_selector {
	uintptr_t uid;
	const char *_Nullable types;
};

struct objc_super {
	id __unsafe_unretained _Nullable self;
	Class _Nonnull cls;
};

struct objc_method {
	struct objc_selector sel;
	IMP _Nonnull imp;
};

struct objc_method_list {
	struct objc_method_list *_Nullable next;
	unsigned int count;
	struct objc_method methods[1];
};

struct objc_category {
	const char *_Nonnull category_name;
	const char *_Nonnull class_name;
	struct objc_method_list *_Nullable instance_methods;
	struct objc_method_list *_Nullable class_methods;
	struct objc_protocol_list *_Nullable protocols;
};

struct objc_ivar {
	const char *_Nonnull name;
	const char *_Nonnull type;
	unsigned int offset;
};

struct objc_ivar_list {
	unsigned int count;
	struct objc_ivar ivars[1];
};

enum objc_property_attributes {
	OBJC_PROPERTY_READONLY	= 0x01,
	OBJC_PROPERTY_GETTER	= 0x02,
	OBJC_PROPERTY_ASSIGN	= 0x04,
	OBJC_PROPERTY_READWRITE	= 0x08,
	OBJC_PROPERTY_RETAIN	= 0x10,
	OBJC_PROPERTY_COPY	= 0x20,
	OBJC_PROPERTY_NONATOMIC	= 0x40,
	OBJC_PROPERTY_SETTER	= 0x80
};

enum objc_property_extended_attributes {
	OBJC_PROPERTY_SYNTHESIZE	=  0x1,
	OBJC_PROPERTY_DYNAMIC		=  0x2,
	OBJC_PROPERTY_PROTOCOL		=  0x3,
	OBJC_PROPERTY_ATOMIC		=  0x4,
	OBJC_PROPERTY_WEAK		=  0x8,
	OBJC_PROPERTY_STRONG		= 0x10,
	OBJC_PROPERTY_UNSAFE_UNRETAINED = 0x20
};

struct objc_property {
	const char *_Nonnull name;
	unsigned char attributes, extended_attributes;
	struct {
		const char *_Nullable name;
		const char *_Nullable type;
	} getter, setter;
};

struct objc_property_list {
	unsigned int count;
	struct objc_property_list *_Nullable next;
	struct objc_property properties[1];
};

#ifdef __OBJC__
# if __has_attribute(__objc_root_class__)
__attribute__((__objc_root_class__))
# endif
@interface Protocol
{
@public
#else
typedef struct {
#endif
	Class _Nonnull isa;
	const char *_Nonnull name;
	struct objc_protocol_list *_Nullable protocol_list;
	struct objc_abi_method_description_list *_Nullable instance_methods;
	struct objc_abi_method_description_list *_Nullable class_methods;
#ifdef __OBJC__
}
@end
#else
} Protocol;
#endif

struct objc_protocol_list {
	struct objc_protocol_list *_Nullable next;
	long count;
	Protocol *__unsafe_unretained _Nonnull list[1];
};

#if 1 /* !defined(__MORPHOS__) || defined(OF_COMPILING_OBJFW_RT) */
# ifdef __cplusplus
extern "C" {
# endif
extern SEL _Nonnull sel_registerName(const char *_Nonnull);
extern const char *_Nonnull sel_getName(SEL _Nonnull);
extern bool sel_isEqual(SEL _Nonnull, SEL _Nonnull);
extern Class _Nonnull objc_allocateClassPair(Class _Nullable,
    const char *_Nonnull, size_t);
extern void objc_registerClassPair(Class _Nonnull);
extern unsigned int objc_getClassList(Class _Nonnull *_Nullable, unsigned int);
extern Class _Nonnull *_Nonnull objc_copyClassList(unsigned int *_Nullable);
extern bool class_isMetaClass(Class _Nullable);
extern const char *_Nullable class_getName(Class _Nullable);
extern Class _Nullable class_getSuperclass(Class _Nullable);
extern unsigned long class_getInstanceSize(Class _Nullable);
extern bool class_respondsToSelector(Class _Nullable, SEL _Nonnull);
extern bool class_conformsToProtocol(Class _Nullable, Protocol *_Nonnull);
extern IMP _Nullable class_getMethodImplementation(Class _Nullable,
    SEL _Nonnull);
extern IMP _Nullable class_getMethodImplementation_stret(Class _Nullable,
    SEL _Nonnull);
extern const char *_Nullable class_getMethodTypeEncoding(Class _Nullable,
    SEL _Nonnull);
extern bool class_addMethod(Class _Nonnull, SEL _Nonnull, IMP _Nonnull,
    const char *_Nullable);
extern IMP _Nullable class_replaceMethod(Class _Nonnull, SEL _Nonnull,
    IMP _Nonnull, const char *_Nullable);
extern Class _Nullable object_getClass(id _Nullable);
extern Class _Nullable object_setClass(id _Nullable, Class _Nonnull);
extern const char *_Nullable object_getClassName(id _Nullable);
extern const char *_Nonnull protocol_getName(Protocol *_Nonnull);
extern bool protocol_isEqual(Protocol *_Nonnull, Protocol *_Nonnull);
extern bool protocol_conformsToProtocol(Protocol *_Nonnull, Protocol *_Nonnull);
extern void objc_exit(void);
extern _Nullable objc_uncaught_exception_handler
    objc_setUncaughtExceptionHandler(
    objc_uncaught_exception_handler _Nullable);
extern void objc_setForwardHandler(IMP _Nullable, IMP _Nullable);
extern void objc_setEnumerationMutationHandler(
    objc_enumeration_mutation_handler _Nullable);
extern void objc_zero_weak_references(id _Nonnull);
# ifdef __cplusplus
}
# endif
#else
# define BOOL EXEC_BOOL
# include <ppcinline/macros.h>
# undef BOOL
# ifdef __cplusplus
extern "C" {
# endif
extern struct Library *ObjFWRTBase;
# ifdef __cplusplus
}
# endif
# include "ppcinline.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif
/*
 * Used by the compiler, but can also be called manually.
 *
 * They need to be in the glue code for the MorphOS library.
 *
 * These declarations are also required to prevent Clang's implicit
 * declarations which include __declspec(dllimport) on Windows.
 */
struct objc_abi_module;
extern void __objc_exec_class(void *_Nonnull);
extern IMP _Nonnull objc_msg_lookup(id _Nullable, SEL _Nonnull);
extern IMP _Nonnull objc_msg_lookup_stret(id _Nullable, SEL _Nonnull);
extern IMP _Nonnull objc_msg_lookup_super(struct objc_super *_Nonnull,
    SEL _Nonnull);
extern IMP _Nonnull objc_msg_lookup_super_stret(struct objc_super *_Nonnull,
    SEL _Nonnull);
extern id _Nullable objc_lookUpClass(const char *_Nonnull);
extern id _Nullable objc_getClass(const char *_Nonnull);
extern id _Nonnull objc_getRequiredClass(const char *_Nonnull);
extern void objc_exception_throw(id _Nullable);
extern int objc_sync_enter(id _Nullable);
extern int objc_sync_exit(id _Nullable);
extern id _Nullable objc_getProperty(id _Nonnull, SEL _Nonnull, ptrdiff_t,
    BOOL);
extern void objc_setProperty(id _Nonnull, SEL _Nonnull, ptrdiff_t, id _Nullable,
    BOOL, signed char);
extern void objc_getPropertyStruct(void *_Nonnull, const void *_Nonnull,
    ptrdiff_t, BOOL, BOOL);
extern void objc_setPropertyStruct(void *_Nonnull, const void *_Nonnull,
    ptrdiff_t, BOOL, BOOL);
extern void objc_enumerationMutation(id _Nonnull);
#ifdef __cplusplus
}
#endif

#endif
