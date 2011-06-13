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

#include <stdarg.h>

#import "OFObject.h"

/**
 * \brief A class for storing and manipulating vectors of floats.
 */
@interface OFFloatVector: OFObject <OFCopying>
{
	size_t dimension;
	float *data;
}

/**
 * \brief Creates a new vector with the specified dimension.
 *
 * \param dimension The dimension for the vector
 * \return A new autoreleased OFFloatVector
 */
+ vectorWithDimension: (size_t)dimension;

/**
 * \brief Creates a new vector with the specified dimension and data.
 *
 * \param dimension The dimension for the vector
 * \return A new autoreleased OFFloatVector
 */
+ vectorWithDimensionAndData: (size_t)dimension, ...;

/**
 * \brief Initializes the vector with the specified dimension.
 *
 * \param dimension The dimension for the vector
 * \return An initialized OFFloatVector
 */
- initWithDimension: (size_t)dimension;

/**
 * \brief Initializes the vector with the specified dimension and data.
 *
 * \param dimension The dimension for the vector
 * \return An initialized OFFloatVector
 */
- initWithDimensionAndData: (size_t)dimension, ...;

/**
 * \brief Initializes the vector with the specified dimension and arguments.
 *
 * \param dimension The dimension for the vector
 * \param arguments A va_list with data for the vector
 * \return An initialized OFFloatVector
 */
- initWithDimension: (size_t)dimension
	   arguments: (va_list)arguments;

/**
 * \brief Sets the value for the specified index.
 *
 * \param value The value
 * \param index The index for the value
 */
- (void)setValue: (float)value
	 atIndex: (size_t)index;

/**
 * \brief Returns the value for the specified index.
 *
 * \param index The index for which the value should be returned
 * \return The value for the specified index
 */
- (float)valueAtIndex: (size_t)index;

/**
 * \brief Returns the dimension of the vector.
 *
 * \return The dimension of the vector
 */
- (size_t)dimension;

/**
 * \brief Returns an array of floats with the contents of the vector.
 *
 * Modifying the returned array is allowed and will change the vector.
 *
 * \brief An array of floats with the contents of the vector
 */
- (float*)floatArray;

/**
 * \brief Adds the specified vector to the receiver.
 *
 * \param vector The vector to add
 */
- (void)addVector: (OFFloatVector*)vector;

/**
 * \brief Subtracts the specified vector from the receiver.
 *
 * \param vector The vector to subtract
 */
- (void)subtractVector: (OFFloatVector*)vector;

/**
 * \brief Multiplies the receiver with the specified scalar.
 *
 * \param scalar The scalar to multiply with
 */
- (void)multiplyWithScalar: (float)scalar;

/**
 * \brief Divides the receiver by the specified scalar.
 *
 * \param scalar The scalar to divide by
 */
- (void)divideByScalar: (float)scalar;

/**
 * \brief Multiplies the components of the receiver with the components of the
 *	  specified vector.
 *
 * \param vector The vector to multiply the receiver with
 */
- (void)multiplyWithComponentsOfVector: (OFFloatVector*)vector;

/**
 * \brief Divides the components of the receiver by the components of the
 *	  specified vector.
 *
 * \param vector The vector to divide the receiver by
 */
- (void)divideByComponentsOfVector: (OFFloatVector*)vector;

/**
 * \brief Returns the dot product of the receiver and the specified vector.
 *
 * \return The dot product of the receiver and the specified vector
 */
- (float)dotProductWithVector: (OFFloatVector*)vector;

/**
 * \brief Returns the magnitude or length of the vector.
 *
 * \return The magnitude or length of the vector
 */
- (float)magnitude;

/**
 * \brief Normalizes the vector.
 */
- (void)normalize;
@end