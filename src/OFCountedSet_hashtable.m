/*
 * Copyright (c) 2008, 2009, 2010, 2011
 *   Jonathan Schleifer <js@webkeks.org>
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

#include "config.h"

#define OF_COUNTED_SET_HASHTABLE_M

#import "OFMutableSet_hashtable.h"
#import "OFCountedSet_hashtable.h"
#import "OFMutableDictionary_hashtable.h"
#import "OFNumber.h"
#import "OFArray.h"
#import "OFAutoreleasePool.h"

@implementation OFCountedSet_hashtable
+ (void)initialize
{
	if (self == [OFCountedSet_hashtable class])
		[self inheritMethodsFromClass: [OFMutableSet_hashtable class]];
}

- initWithSet: (OFSet*)set
{
	self = [self init];

	@try {
		OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];

		if ([set isKindOfClass: [OFCountedSet class]]) {
			OFCountedSet *countedSet = (OFCountedSet*)countedSet;
			OFEnumerator *enumerator =
			    [countedSet objectEnumerator];
			id object;

			while ((object = [enumerator nextObject]) != nil) {
				size_t i, count;

				count = [countedSet countForObject: object];

				for (i = 0; i < count; i++)
					[self addObject: object];
			}
		} else {
			OFEnumerator *enumerator = [set objectEnumerator];
			id object;

			while ((object = [enumerator nextObject]) != nil)
				[self addObject: object];
		}

		[pool release];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithArray: (OFArray*)array
{
	self = [self init];

	@try {
		id *cArray = [array cArray];
		size_t i, count = [array count];

		for (i = 0; i < count; i++)
			[self addObject: cArray[i]];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- initWithObject: (id)firstObject
       arguments: (va_list)arguments
{
	self = [self init];

	@try {
		id object;

		[self addObject: firstObject];

		while ((object = va_arg(arguments, id)) != nil)
			[self addObject: object];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (size_t)countForObject: (id)object
{
	return [[dictionary objectForKey: object] sizeValue];
}

#ifdef OF_HAVE_BLOCKS
- (void)enumerateObjectsAndCountUsingBlock:
    (of_counted_set_enumeration_block_t)block
{
	[dictionary enumerateKeysAndObjectsUsingBlock: ^ (id key, id object,
	    BOOL *stop) {
		block(key, [object sizeValue], stop);
	}];
}
#endif

- (void)addObject: (id)object
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFNumber *count;

	count = [[dictionary objectForKey: object] numberByIncreasing];

	if (count == nil)
		count = [OFNumber numberWithSize: 1];

	[dictionary _setObject: count
			forKey: object
		       copyKey: NO];

	mutations++;

	[pool release];
}

- (void)removeObject: (id)object
{
	OFNumber *count = [dictionary objectForKey: object];
	OFAutoreleasePool *pool;

	if (count == nil)
		return;

	pool = [[OFAutoreleasePool alloc] init];
	count = [count numberByDecreasing];

	if ([count sizeValue] > 0)
		[dictionary _setObject: count
				forKey: object
			       copyKey: NO];
	else
		[dictionary removeObjectForKey: object];

	mutations++;

	[pool release];
}

- (void)makeImmutable
{
}
@end