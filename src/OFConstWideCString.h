/*
 * Copyright (c) 2008
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of libobjfw. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#import <wchar.h>
#import <stddef.h>
#import "OFString.h"

@interface OFConstWideCString: OFString
{
	const wchar_t *string;
	size_t	      length;
}

- initWithConstWideCString: (const wchar_t*)wstr;
- (const wchar_t*)wcString;
- (size_t)length;
- (OFString*)clone;
- (int)compareTo: (OFString*)str;
@end
