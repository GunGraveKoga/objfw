/*
 * Copyright (c) 2008 - 2009
 *   Jonathan Schleifer <js@webkeks.org>
 *
 * All rights reserved.
 *
 * This file is part of libobjfw. It may be distributed under the terms of the
 * Q Public License 1.0, which can be found in the file LICENSE included in
 * the packaging of this file.
 */

#include <stdio.h>
#include <stdarg.h>

#import "OFObject.h"
#import "OFArray.h"

extern int of_string_check_utf8(const char*, size_t);
extern size_t of_string_unicode_to_utf8(uint32_t, uint8_t*);

/**
 * A class for managing strings.
 */
@interface OFString: OFObject <OFCopying, OFMutableCopying>
{
	char	     *string;
#ifdef __objc_INCLUDE_GNU
	unsigned int length;
#else
	int	     length;
#if __LP64__
	int	     _unused;
#endif
#endif
	BOOL	     is_utf8;
}

/**
 * \return A new autoreleased OFString
 */
+ string;

/**
 * Creates a new OFString from a C string.
 *
 * \param str A C string to initialize the OFString with
 * \return A new autoreleased OFString
 */
+ stringWithCString: (const char*)str;

/**
 * Creates a new OFString from a C string with the specified length.
 *
 * \param str A C string to initialize the OFString with
 * \param len The length of the string
 * \return A new autoreleased OFString
 */
+ stringWithCString: (const char*)str
	  andLength: (size_t)len;

/**
 * Creates a new OFString from a format string.
 * See printf for the format syntax.
 *
 * \param fmt A string used as format to initialize the OFString
 * \return A new autoreleased OFString
 */
+ stringWithFormat: (OFString*)fmt, ...;

/**
 * Creates a new OFString from another string.
 *
 * \param str A string to initialize the OFString with
 * \return A new autoreleased OFString
 */
+ stringWithString: (OFString*)str;

/**
 * Initializes an already allocated OFString.
 *
 * \return An initialized OFString
 */
- init;

/**
 * Initializes an already allocated OFString from a C string.
 *
 * \param str A C string to initialize the OFString with
 * \return An initialized OFString
 */
- initWithCString: (const char*)str;

/**
 * Initializes an already allocated OFString from a C string with the specified
 * length.
 *
 * \param str A C string to initialize the OFString with
 * \param len The length of the string
 * \return An initialized OFString
 */
- initWithCString: (const char*)str
	andLength: (size_t)len;

/**
 * Initializes an already allocated OFString with a format string.
 * See printf for the format syntax.
 *
 * \param fmt A string used as format to initialize the OFString
 * \return An initialized OFString
 */
- initWithFormat: (OFString*)fmt, ...;

/**
 * Initializes an already allocated OFString with a format string.
 * See printf for the format syntax.
 *
 * \param fmt A string used as format to initialize the OFString
 * \param args The arguments used in the format string
 * \return An initialized OFString
 */
- initWithFormat: (OFString*)fmt
    andArguments: (va_list)args;

/**
 * Initializes an already allocated OFString with another string.
 *
 * \param str A string to initialize the OFString with
 * \return An initialized OFString
 */
- initWithString: (OFString*)str;

/**
 * \return The OFString as a C string
 */
- (const char*)cString;

/**
 * \return The length of the OFString
 */
- (size_t)length;

/**
 * Compares the OFString to another object.
 *
 * \param obj An object to compare with
 * \return An integer which is the result of the comparison, see for example
 *	   strcmp
 */
- (int)compare: (id)obj;

/**
 * \param str The string to search
 * \return The index of the first occurrence of the string or SIZE_MAX if it
 *	   wasn't found
 */
- (size_t)indexOfFirstOccurrenceOfString: (OFString*)str;

/**
 * \param str The string to search
 * \return The index of the last occurrence of the string or SIZE_MAX if it
 *	   wasn't found
 */
- (size_t)indexOfLastOccurrenceOfString: (OFString*)str;

/**
 * \param start The index where the substring starts
 * \param end The index where the substring ends.
 *	      This points BEHIND the last character!
 * \return The substring as a new autoreleased OFString
 */
- (OFString*)substringFromIndex: (size_t)start
			toIndex: (size_t)end;

/**
 * Splits an OFString into an OFArray of OFStrings.
 *
 * \param delimiter The delimiter for splitting
 * \return An autoreleased OFArray with the splitted string
 */
- (OFArray*)splitWithDelimiter: (OFString*)delimiter;

- setToCString: (const char*)str;
- appendCString: (const char*)str;
- appendCString: (const char*)str
     withLength: (size_t)len;
- appendCStringWithoutUTF8Checking: (const char*)str;
- appendCStringWithoutUTF8Checking: (const char*)str
			 andLength: (size_t)len;
- appendString: (OFString*)str;
- appendWithFormat: (OFString*)fmt, ...;
- appendWithFormat: (OFString*)fmt
      andArguments: (va_list)args;
- reverse;
- upper;
- lower;
- replaceOccurrencesOfString: (OFString*)str
		  withString: (OFString*)repl;
- removeLeadingWhitespaces;
- removeTrailingWhitespaces;
- removeLeadingAndTrailingWhitespaces;
@end

#import "OFConstString.h"
#import "OFMutableString.h"
#import "OFURLEncoding.h"
#import "OFXMLElement.h"
#import "OFXMLParser.h"
